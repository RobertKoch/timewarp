$(document).ready ->
  initIntroJs()
  
  # set iframe height
  if ($(window).height() > 768)
    dynamicFrameHeight = $(window).height() - 255
    $('#crawled_site').attr('height', dynamicFrameHeight)
    $('#sidebar').css('height', dynamicFrameHeight)
  else
    $('#crawled_site').attr('height', 600)
    $('#sidebar').css('height', 600)

$(window).load ->
  # store in window element
  window.frameContent = $('#crawled_site').contents().find('html')

  defineAdditionalAddons()

  declareListener()

  removeUnsolicitedTags()

  # prevent position bug
  setTimeout (->
    startAnalyse()

    startValidation() 
  ), 500

initIntroJs = () ->
  introJs()
    .setOptions
      skipLabel: "Abbrechen",
      nextLabel: "Weiter",
      prevLabel: "Zurück",
      doneLabel: "Schließen"
    .start()
    .oncomplete ->
      introJs().exit()
      $('#analyse_frame span').hide()
    .onexit ->
      introJs().exit()
      $('#analyse_frame span').hide()
    
startAnalyse = () ->
  recursiveIterate(window.frameContent)

resetAnalyse = () ->
  # reset all classes which start with tw_
  $(window.frameContent).find('.overlay_wrap').parent().alterClass 'tw_*', ''
  # remove all overlays
  $(window.frameContent).find('.overlay_wrap').remove()  

startValidation = () ->
  validateNavigations()
  validateFooter()

removeUnsolicitedTags = () ->
  $(window.frameContent).find('a').removeAttr 'href'

  #regex = new Array(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/g, /<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>/g);
  #i = 0;

  #while i < regex.length
  #  while regex[i].test(frameContent)
  #    frameContent = frameContent.replace(regex[i], ""); 
  #  i++;

defineAdditionalAddons = () ->
  host = $('#app_config').attr 'host'
  $.ajax(
    url: "/tw_assets/templates/overlay.html",
    async: false
  ).done (fileContent) ->
    $(window.frameContent).find('body').append fileContent
  
  $(window.frameContent).find('body').append '<span class="tw_background_overlay"></span>'

  $(window.frameContent).find('.tw_background_overlay').css 'height': window.frameContent[0].offsetHeight

  $(window.frameContent).find('head').append "<link rel='stylesheet' href='#{host}/tw_assets/stylesheets/analyse.css' type='text/css' media='screen' />"

# recursive iteration through every element
recursiveIterate = (node) ->
  $.each $(node).children(), (i) ->

    if $(this)[0].attributes.length isnt 0
      exploreAttributes($(this));

    if $(this)[0].localName is 'ul'
      exploreTagUl($(this))

    # firefox forces check for null value
    if $(this)[0].nodeValue isnt null
      if $(this)[0].nodeValue.indexOf('©') >= 0
        window.elemFooter = $(this)

    recursiveIterate($(this));    

exploreAttributes = (node) ->
  objArr = new Object(
    #navi: ["tw_navigation", "Navigation"], 
    header: ["tw_header", "Header"], 
    content: ["tw_content", "Content"],
    footer: ["tw_footer", "Footer"]
  );

  # get attributes of node reference
  attributes = node[0].attributes;

  $.each attributes, (i, v) ->
    nodeName = $(v)[0].nodeName

    # continue if atribute is id or class
    if nodeName and 'id' or nodeName and 'class'
      # impose timewarp generated classes
      if $(v)[0].value.indexOf('tw_') < 0 and $(v)[0].value.indexOf('overlay_wrap') < 0
        # split to get every element of example multiple classes
        splitValues = $(v)[0].value.split(' ')
        
        $.each splitValues, (j, w) ->
          param = w.toLowerCase()
          # continue param is part of objArr
          if objArr[param] isnt undefined
            $(node).addClass objArr[param][0]
            generateOverlay($(node), objArr[param][1])

exploreTagUl = (node) ->
  # reset variables
  window.cnt = 0;
  window.galleryCnt = 0;
  length = $(node).children().length

  $.each $(node).children(), (i) ->
    el = $(this)[0].children[0]

    if el isnt undefined
      # element contains only one tag, spezially a link tag 
      if $(el).length is 1 and $(el)[0].localName is 'a'
        # increment navigation-count if the <a> tag doesnt contain an image tag
        if $(el)[0].innerHTML.indexOf('<img') < 0
          window.cnt++
        else
          window.galleryCnt++ 

  # additional increment to allow 1 extra element like span in navigation-block
  if window.cnt > 3 and (window.cnt is length or window.cnt+1 is length)
    generateOverlay($(node), 'Unternavigation')
  else 
    if window.galleryCnt > 3
      generateOverlay($(node), 'Gallery')

setRootClass = (node, value) ->
  if node[0].className.indexOf('tw_root') < 0
    $(node).addClass 'tw_root_'+value

generateOverlay = (node, value) -> 
  # node will be empty when click at breadbrumb navigation
  if node.length <= 0
    node = window.activeOverlay

  classParam = value.toLowerCase()

  # set class to overlay root
  setRootClass(node, classParam)

  # overlayCnt correlates to z-index, start with value 1000
  window.overlayCnt = window.overlayCnt or 1000

  overlay    = '<div class="overlay_wrap ' + value.toLowerCase() + '">'
  overlay   += '<span class="tw_overlay"></span>' 
  overlay   += '<span class="tw_overlay_text">' + value + '</span>'
  overlay   += '</div>'

  $(node).append overlay

  attributes = $(node)[0]

  # set height if not available
  attributeHeight = (if (attributes.offsetHeight > 0) then attributes.offsetHeight else 30)  

  $(node).children('.overlay_wrap')
    .css
      'width': attributes.offsetWidth,
      'height': attributeHeight,
      'z-index': window.overlayCnt,
      'left': attributes.offsetLeft,
      'top': attributes.offsetTop
  
  # increase cnt for increasing z-index
  window.overlayCnt++

changeOverlayAndClass = (value) ->
  parentElement = window.activeOverlay.target.parentNode.parentNode
  $(parentElement).alterClass 'tw_*', 'tw_root_'+value.toLowerCase()

  if window.activeOverlay.target.className is 'tw_overlay_text'
    window.activeOverlay.target.innerText = value
  else
    window.activeOverlay.target.nextSibling.innerText = value

noBreadcrumbs = () ->
  # show info message
  $(window.frameContent).find('.tw_overlayBreadcrumbs').html('no HTML structure found! Try again')
  # hide select box to force user to use close button
  $(window.frameContent).find('.tw_overlayDefinition').hide()

getBreadcrumbs = (node) -> 
  path = ''
  pNodes = $(node).parents('*')
  dataIDCnt = pNodes.length

  if dataIDCnt < 2
    noBreadcrumbs()
  else
    # check visibility of select box
    if $(window.frameContent).find('.tw_overlayDefinition').is(':hidden')
      $(window.frameContent).find('.tw_overlayDefinition').show()

    $.each pNodes, (i) ->
      setClass = (if (dataIDCnt > 2) then setClass = 'class="tw_bc"' else setClass = '') 

      # get localName 'div' etc.   
      breadcrumb = '<span '+setClass+' data-id="'+dataIDCnt+'">'+$(this)[0].localName   

      # add value of id if exists
      if ($(this)[0].id)
        breadcrumb += '#'+$(this)[0].id

      if (i > 0)
        breadcrumb += '</span> > '  
      
      # build breadcrumb navigation
      path = breadcrumb + path

      dataIDCnt--

    $(window.frameContent).find('.tw_overlayBreadcrumbs').html(path)

fadeOutOverlays = (changeOverlay) ->
  $(changeOverlay).fadeOut 'slow', ->
    $(window.frameContent).find('.tw_background_overlay').fadeOut() 

splitBreadcrumb = (element, splitter) ->
  splitPosition = element.indexOf(splitter)
  accessElem = element.substring splitPosition, element.length

  return accessElem

declareListener = () ->
  el = $(window.frameContent).find('.tw_navigation_change')

  $(window.frameContent).click (e) ->
    switch e.target.className
      when 'tw_navigation_change'
        # do nothing, prevent click only
        nothing = true

      when 'tw_bc'
        # split path to get single elements
        arrBreadcrumbs = $(el).find('.tw_overlayBreadcrumbs').text().split(' > ')

        # get number of clicked element to break in for loop
        elementPosition = $(e.target).attr('data-id')
        
        # start at body tag
        pathLoop = $(window.frameContent).find('body')
        
        # start at 2 because body is element 2
        for i in [2...elementPosition]
          
          # if element contains splitter, split at this position
          if arrBreadcrumbs[i].indexOf('#') >= 0
            nextElement = splitBreadcrumb(arrBreadcrumbs[i], '#')
          else if arrBreadcrumbs[i].indexOf('.') >= 0
            nextElement = splitBreadcrumb(arrBreadcrumbs[i], '.')  
          else
            nextElement = arrBreadcrumbs[i]  
          
          # find next element in hierarchie
          pathLoop = $(pathLoop).children(nextElement)

        # set activeOverlay to pass new current element to breadcrumb and select-change function
        window.activeOverlay = pathLoop

        # pass firstChild to get a correct new breadcrumb hierarchie
        getBreadcrumbs($(pathLoop[0].firstChild))

      when 'tw_bc_highlight'
        # get current tag like span
        tag = e.target.localName
        # remove tag from innerText like span#id -> #id
        accessElem = e.target.innerText.replace(tag, '')
        # get element from DOM
        elem = $(window.frameContent).find(accessElem)

        # set overlay by default
        window.setOverlay = 1;

        $.each elem[0].children, (i, v) ->
          # dont set overlay if its still generated
          if v.classList.contains 'overlay_wrap'
            window.setOverlay = undefined
        
        # set activeOverlay to pass new current element to breadcrumb and select-change function
        window.activeOverlay = elem
        # pass firstChild to get a correct new breadcrumb hierarchie
        getBreadcrumbs($(elem[0].firstChild))

      when 'tw_overlayClose', 'tw_background_overlay'
        fadeOutOverlays(el)

      when 'tw_overlayRemove'
        fadeOutOverlays(el)

        # remove class
        $(window.activeOverlay.target.parentNode.parentNode).alterClass 'tw_*', ''

        # remove overlay block
        clickedOverlay = window.activeOverlay.target.parentNode
        $(clickedOverlay).remove()

        # if navigation is removed, validate new if possible
        if window.activeOverlay.target.innerText is 'Hauptnavigation'
          validateNavigations()

      else 
        # if click on image, change e.target to parent element to prevent an overlay inside the image tag
        if e.target.nodeName is 'IMG'
          e.target = e.target.parentNode

        # if click element an overlay enable remove link, otherwise hide link
        if e.target.className is 'tw_overlay_text' or e.target.className.indexOf('tw_overlay') >= 0
          $(el).find('.tw_overlayRemove').show()
        else
          $(el).find('.tw_overlayRemove').hide()

        # if overlay even exists, set value to create new to undefined
        if e.target.parentNode.className.indexOf('overlay_wrap') >= 0
          window.setOverlay = undefined;
        else
          window.setOverlay = 1

        $(el).css
          'top': e.pageY,
          'left': e.pageX

        # set current overlay
        window.activeOverlay = e

        # define breadcrumb navigation for current element
        getBreadcrumbs(e.target.parentNode)

        # show overlay
        $(window.frameContent).find('.tw_background_overlay').fadeIn "slow", ->
          $(el).fadeIn();

  $(window.frameContent).find('.tw_overlayDefinition').change (e) ->
    value         = e.currentTarget.value;
    overlayTarget = $(window.activeOverlay.target);
    
    if value == 'Navigation'
      value = 'Unternavigation'

    # change value if navigation element is choosen
    if window.setOverlay is undefined

      # change highlighting class
      oldValue = overlayTarget[0].innerText.toLowerCase()
      $(overlayTarget[0].parentNode).alterClass oldValue, value.toLowerCase()

      # change overlay via breadcrumb navigation
      if window.activeOverlay.selector isnt undefined
        $(window.activeOverlay).alterClass 'tw_*', 'tw_root_'+value.toLowerCase()
        window.activeOverlay[0].lastChild.lastChild.innerText = value

      # change overlay by clicking at once
      else
        changeOverlayAndClass(value)

    # set new overlay
    else if window.activeOverlay.target
      # generate overlay
      generateOverlay(overlayTarget, value);
      # add class of type like tw_navigation
      overlayTarget.addClass 'tw_' + value.toLowerCase()    

    # set overlay via breadcrumb navigation
    else 
      # generate overlay
      generateOverlay(overlayTarget, value);
      # add class of type like tw_navigation
      overlayTarget.addClass 'tw_' + value.toLowerCase()

    # reset select-box to first option
    e.currentTarget.selectedIndex = 0
    
    # fadeOut overlays
    fadeOutOverlays(el)

    # validate navigation to check if main navigation has changed
    if value is 'Unternavigation'
      validateNavigations()

  $(window.frameContent).mouseover (e) ->
    switch e.target.className 
      when 'tw_bc'
        innerText = e.target.innerText
        
        if innerText.indexOf('#') > 0
          $(e.target).alterClass 'tw_*', 'tw_bc_highlight'

          $(e.target).mouseout (e) ->
            $(e.target).alterClass 'tw_*', 'tw_bc'

      when 'tw_overlay_text' 
        # bring overlay to front -> z-index: 9999
        $(e.target.parentNode).addClass 'tw_overlay_warp_hover'
        # highlight overlay container
        $(e.target.previousSibling).addClass 'tw_overlay_hover';

        $(e.target).mouseout (e) ->
          $(e.target.parentNode).removeClass 'tw_overlay_warp_hover'
          $(e.target.previousSibling).removeClass 'tw_overlay_hover'

      else
        # dont highlight overlay
        if e.target.className isnt 'tw_overlay_text' and $(window.frameContent).find('.tw_navigation_change').is(':hidden')
          if e.target.nodeName is 'IMG'
            target = e.target.parentNode
          else
            target = e.target  
          
          $(target).addClass 'tw_highlight'
          
          $(target).mouseout (e) ->
            $(target).removeClass 'tw_highlight'

  $('.back_to_future').click (e) ->
    e.preventDefault()

    $(window.frameContent).find('.overlay_wrap').remove();

    token   = $('#analyse_token').attr('token')
    content = $('#crawled_site').contents().find('html')[0].outerHTML

    $.ajax(
      type: 'POST',
      dataType: 'json',
      url: "/sites/rewrite_content",
      data: {
        token: token,
        version: 'current',
        content: content
      },
      async: false
    ).done (bool) ->
      if bool
        window.location.replace window.location.origin+'/sites/'+token+'/timeline'

  $('.reset_analyse').click (e) ->
    e.preventDefault()
    resetAnalyse()

  $('.new_analyse').click (e) ->
    e.preventDefault()
    # remove overlays if some are existing
    if $(window.frameContent).find('.overlay_wrap').length > 0
      resetAnalyse()
    startAnalyse()
    startValidation()

validateFooter = () ->
  # element has no footer-overlay
  if window.elemFooter isnt undefined
    if $(window.elemFooter)[0].className.indexOf('tw_') < 0
      generateOverlay($(window.elemFooter), 'Footer')
    
# every change of navigation must be validated
validateNavigations = () -> 
  # reset root navigation
  $(window.frameContent).find('.tw_root_hauptnavigation').alterClass 'tw_root_hauptnavigation', 'tw_root_unternavigation'

  # array of elements
  listMain = new Array('startseite', 'home', 'über uns')
  # array which stores navigation points
  navCnt = new Array();
  # list that contains every subnavigation
  subNav = $(window.frameContent).find('.tw_root_unternavigation')

  $.each subNav, (i) ->
    # navigation must be visible
    if $(this).css('opacity') is 0 or $(this).css('display').indexOf('block') < 0
      navCnt.push(-1)
    else   
      # first navigation will be rated better
      if i == 0 then cnt = 2 else cnt = 0
      $.each this.children, (j) ->
        if this.innerText and this.innerText isnt 'Unternavigation'
          # is current value part of array
          if this.innerText.toLowerCase() in listMain
            cnt++
      # push final points to array    
      navCnt.push(cnt)  

  # get max value of cnt array
  maxCnt = Math.max.apply(Math, navCnt)
  # get array index of max value
  posOfMax = navCnt.indexOf(maxCnt)

  # change subnavigation to main navigation
  elem = subNav[posOfMax]

  # change subnavigation to navigation
  $(elem).alterClass 'tw_*', 'tw_root_hauptnavigation'
  $(elem).find('.tw_overlay_text').text 'Hauptnavigation' 

  # change highlighting class
  $(elem).find('.overlay_wrap').alterClass 'unternavigation', 'hauptnavigation'
