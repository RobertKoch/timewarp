$(window).load ->
  # store in window element
  window.frameContent = $('#crawled_site').contents().find('html')

  defineAdditionalAddons()

  recursiveIterate(window.frameContent)

  declareListener()

  removeUnsolicitedTags()

  validateNavigations()

  # if everything has finished set opacity to 1
  $('#crawled_site').css opacity: 1

removeUnsolicitedTags = () ->
  $(window.frameContent).find('a').removeAttr 'href'

  #regex = new Array(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/g, /<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>/g);
  #i = 0;

  #while i < regex.length
  #  while regex[i].test(frameContent)
  #    frameContent = frameContent.replace(regex[i], ""); 
  #  i++;

defineAdditionalAddons = () ->
  $.ajax(
    url: "/assets/templates/overlay.html",
    async: false
  ).done (fileContent) ->
    $(window.frameContent).find('body').append fileContent
  
  $(window.frameContent).find('body').append '<span class="tw_background_overlay"></span>'

  $(window.frameContent).find('.tw_background_overlay').css 'height': window.frameContent[0].offsetHeight

  $(window.frameContent).find('head').append '<link rel="stylesheet" href="http://localhost:3000/assets/stylesheets/analyse.css" type="text/css" media="screen" />'

# recursive iteration through every element
recursiveIterate = (node) ->
  $.each $(node).children(), (i) ->

    if $(this)[0].attributes.length != 0
      exploreAttributes($(this));

    #console.log $(this);
    #if $(this)[0].attributes.length != 0
      #exploreAttributes($(this))
      #console.log($(this)[0].attributes)

    if $(this)[0].localName == 'ul'
      exploreTagUl($(this))

    recursiveIterate($(this));    

exploreAttributes = (node) ->
  objArr = new Object(
    navi: ["tw_navigation", "Navigation"], 
    header: ["tw_header", "Header"], 
    content: ["tw_content", "Content"],
    footer: ["tw_footer", "Footer"]
  );

  # get attributes of node reference
  attributes = node[0].attributes;

  $.each attributes, (i, v) ->
    nodeName = $(v)[0].nodeName

    # continue if atribute is id or class
    if nodeName == 'id' || nodeName == 'class'
      # split to get every element of example multiple classes
      splitValues = nodeName.split(' ')

      $.each splitValues, (j, w) ->
        param = w.toLowerCase()
        # continue param is part of objArr
        if objArr[param] != undefined
          $(node).addClass objArr[param][0]
          generateOverlay($(node), objArr[param][1])

exploreTagUl = (node) ->
  # reset variables
  window.cnt = 0;
  window.galleryCnt = 0;
  length = $(node).children().length

  $.each $(node).children(), (i) ->
    el = $(this)[0].children[0]

    if el != undefined
      # element contains only one tag, spezially a link tag 
      if $(el).length == 1 && $(el)[0].localName == 'a'
        # increment navigation-count if the <a> tag doesnt contain an image tag
        if $(el)[0].innerHTML.indexOf('<img') < 0
          window.cnt++
        else
          window.galleryCnt++ 

  # additional increment to allow 1 extra element like span in navigation-block
  if window.cnt > 3 && (window.cnt == length || window.cnt+1 == length)
    generateOverlay($(node), 'SubNavigation')
  else 
    if window.galleryCnt > 3
      generateOverlay($(node), 'Gallery')

setClass = (node, value) ->
  $(node).addClass 'tw_root_'+value

generateOverlay = (node, value) -> 
  # node will be empty when click at breadbrumb navigation
  if node.length <= 0
    node = window.activeOverlay

  classParam = value.toLowerCase()
  
  # set class to overlay root
  setClass(node, classParam)

  # overlayCnt correlates to z-index
  window.overlayCnt = window.overlayCnt || 0

  overlay    = '<div class="overlay_wrap">'
  overlay   += '<span class="tw_overlay"></span>' 
  overlay   += '<span class="tw_overlay_text">' + value + '</span>'
  overlay   += '</div>'

  $(node).append overlay

  # chose parentNode if no height or width is available
  #if $(node)[0].offsetHeight > 0 && $(node)[0].offsetWidth > 0
  #  attributes = $(node)[0];
  #else
  #  attributes = $(node)[0].parentNode;  

  attributes = $(node)[0]

  # set height if not available
  attributeHeight = (if (attributes.offsetHeight > 0) then attributes.offsetHeight else 20)  

  $(node).find('.overlay_wrap')
    .css
      'width': attributes.offsetWidth,
      'height': attributeHeight,
      'z-index': window.overlayCnt,
      'left': attributes.offsetLeft,
      'top': attributes.offsetTop;
  
  # increase cnt for increasing z-index
  window.overlayCnt++

getBreadcrumbs = (node) ->
  path = ''
  pNodes = $(node).parents('*')
  dataIDCnt = pNodes.length

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
  el = $(window.frameContent).find('.tw_navigation_change');

  $(window.frameContent).click (e) ->
    switch e.target.className
      when 'tw_navigation_change'
        #do nothing, prevent click only
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
        
        # set activeOverlay to pass new current element to breadcrumb and select-change function
        window.activeOverlay = elem
        # pass firstChild to get a correct new breadcrumb hierarchie
        getBreadcrumbs($(elem[0].firstChild))

      when 'tw_overlayClose', 'tw_background_overlay'
        fadeOutOverlays(el)

      when 'tw_overlayRemove'
        fadeOutOverlays(el)

        # remove block
        clickedOverlay = window.activeOverlay.target.parentNode
        $(clickedOverlay).remove()

      else 
        # if click on image, change e.target to parent element to prevent an overlay inside the image tag
        if e.target.nodeName == 'IMG'
          e.target = e.target.parentNode

        if e.target.className == 'tw_highlight'
          $(e.target).addClass 'highlight_current';

        # if click element an overlay enable remove link, otherwise hide link
        if e.target.className == 'tw_overlay_text' || e.target.className.indexOf('tw_overlay') >= 0
          $(el).find('.tw_overlayRemove').show()
        else
          $(el).find('.tw_overlayRemove').hide()

        # if overlay even exists, set value to create new to undefined
        if e.target.parentNode.className.indexOf('overlay_wrap') >= 0
          window.setOverlay = undefined;
        else
          window.setOverlay = 1;

        # define breadcrumb navigation for current element
        getBreadcrumbs(e.target.parentNode)

        $(el).css
          'top': e.pageY,
          'left': e.pageX;

        # set current overlay
        window.activeOverlay = e;

        # show overlay
        $(window.frameContent).find('.tw_background_overlay').fadeIn "slow", ->
          $(el).fadeIn();

  $(window.frameContent).find('.tw_overlayDefinition').change (e) ->
    value         = e.currentTarget.value;
    overlayTarget = $(window.activeOverlay.target);

    if window.setOverlay == undefined
      # change class of parent element
      parentElement = window.activeOverlay.target.parentNode.parentNode
      $(parentElement).alterClass 'tw_*', 'tw_root_'+value.toLowerCase()

      # change field value
      if window.activeOverlay.target.className == 'tw_overlay_text'
        window.activeOverlay.target.innerText = value
      else
        window.activeOverlay.target.nextSibling.innerText = value
    else
      # generate overlay
      generateOverlay(overlayTarget, value);
      # remove class highlighed 
      overlayTarget.removeClass 'highlight_current'
      # add class of type like tw_navigation
      overlayTarget.addClass 'tw_' + value.toLowerCase()

    # reset select-box to first option
    e.currentTarget.selectedIndex = 0
    
    #fadeOut overlays
    fadeOutOverlays(el)

    # validate navigation to check if main navigation has changed
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
          $(e.target.previousSibling).removeClass 'tw_overlay_hover';
      else
        # dont highlight overlay
        if e.target.className != 'tw_overlay_text' && $(window.frameContent).find('.tw_navigation_change').is(':hidden')
          if e.target.nodeName == 'IMG'
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
      }
      async: false
    ).done (bool) ->
      if bool
        window.location.replace window.location.origin+'/sites/'+token+'/timeline'

  $('.reset_analyse').click (e) ->
    e.preventDefault()

    # reset all classes which start with tw_
    $(window.frameContent).find('.overlay_wrap').parent().alterClass 'tw_*', ''
    # remove all overlays
    $(window.frameContent).find('.overlay_wrap').remove()

# every change of navigation must be validated
validateNavigations = () -> 
  # reset root navigation
  $(window.frameContent).find('.tw_root_navigation').alterClass 'tw_root_navigation', 'tw_root_subnavigation'
  #navFooterValues = new Array('Kontakt', 'Impressum', 'Datenschutz')

  # array of elements
  listMain = new Array('startseite', 'home', 'über uns')
  # array which stores navigation points
  navCnt = new Array();
  # list that contains every subnavigation
  subNav = $(window.frameContent).find('.tw_root_subnavigation')
  
  $.each subNav, (i) ->
    # first navigation will be rated better
    if i == 0 then cnt = 2 else cnt = 0
    $.each this.children, (j) ->
      if this.innerText && this.innerText != 'SubNavigation'
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
  $(elem).alterClass 'tw_*', 'tw_root_navigation'
  $(elem).find('.tw_overlay_text').text 'Navigation'  