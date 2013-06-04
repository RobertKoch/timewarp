$(document).ready ->
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

  if checkFeasibility()
    initIntroJs()

    # store new id's and save it at end to database
    window.fieldsToLearn = []

    getDatabaseAttributes()

    defineAdditionalAddons()

    declareListener()

    removeUnsolicitedTags()

    # prevent position bug
    setTimeout (->
      startAnalyse()

      startValidation()
    ), 500
  else
    showFeasibilityFail()

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

showFeasibilityFail = () ->
  $('.crawling_impossible').fadeIn()

  $('.crawling_impossible .close_ok').click (e) ->
    window.location.replace window.location.origin

checkFeasibility = () ->
  if $(window.frameContent).find('body').length is 0
    false
  else
    true
    
startAnalyse = () ->
  # declare object for tagged fields (by customer and application)
  # reset it in case of new calculation
  resetTaggedFields()

  recursiveIterate(window.frameContent)

resetAnalyse = () ->
  # reset all classes which start with tw_
  $(window.frameContent).find('.overlay_wrap').parent().alterClass 'tw_*', ''
  # remove all overlays
  $(window.frameContent).find('.overlay_wrap').remove()  

  # reset it in case of new calculation
  resetTaggedFields()

startValidation = () ->
  validateNavigations()
  validateFooter()

removeUnsolicitedTags = () ->
  $(window.frameContent).find('a').removeAttr 'href'

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

getDatabaseAttributes = () ->
  window.jsonData = ''

  # get stored id's
  $.ajax(
    type: 'GET',
    dataType: 'json',
    url: "/elements/teach",
    async: false
  ).done (data) ->
    if data
      window.jsonData = data

exploreAttributes = (node) ->
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

          # go through id's
          $.each window.jsonData, (key, value) ->
            # add class and generate overlay if value of an element contains param
            if param in value
              $(node).addClass 'tw_'+key.toLowerCase()
              generateOverlay($(node), key)

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

generateOverlay = (node, value, userGenerated) -> 
  userGenerated = userGenerated or false

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

  # increment tagged field in json object
  incrementTaggedFields(value)

  # if tag is generated by user, lern attributes from element
  if userGenerated
    overlayID = $(node).attr 'id'
    if overlayID
      saveLearnElements(overlayID, value)

saveLearnElements = (id, value) ->
  obj = {}
  obj[value] = id
  window.fieldsToLearn.push(obj)

storeLearnElements = (elements) ->
  $.ajax(
    type: 'POST',
    dataType: 'json',
    url: "/elements/learn",
    data: {
      elements: elements
    },
    async: false
  )

changeOverlayAndClass = (value) ->
  # update tagged fields before changing values
  changeTaggedFields(window.activeOverlay.target.innerText, value)

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

resetTaggedFields = () ->
  window.taggedFields = {}
  $('.twl_set').removeClass 'twl_set'
    
decrementTaggedFields = (value) ->
  if value is 'Hauptnavigation'
    value = 'Unternavigation'

    # decrement unternavigation field in json object
    window.taggedFields[value]--

    if window.taggedFields[value] is 1
      $('.twl_unternavigation').removeClass 'twl_set'

    if window.taggedFields[value] is 0
      $('.twl_hauptnavigation').removeClass 'twl_set'

  else
    # decrement tagged field in json object
    window.taggedFields[value]--

    if window.taggedFields[value] <= 0
      # remove class from element in legend
      $('.twl_'+value.toLowerCase()).removeClass 'twl_set'

incrementTaggedFields = (value) ->
  # set tagged field to 1 if it isnt in taggedFields object
  if window.taggedFields[value] is undefined or window.taggedFields[value] is 0
    window.taggedFields[value] = 1

    # if first navigation is declared set value to main navigation
    if value is 'Unternavigation'
      value = 'hauptnavigation'

    # add class to element in legend
    $('.twl_'+value.toLowerCase()).addClass 'twl_set'

  # increment number of tagged element
  else
    window.taggedFields[value]++

    # if value of Unternavigation is 2, set class to unternavigation in legend
    if value is 'Unternavigation' and window.taggedFields[value] is 2
      $('.twl_unternavigation').addClass 'twl_set'

changeTaggedFields = (oldValue, newValue) ->
  # decrement number of "current" overlay
  decrementTaggedFields(oldValue)

  # increment number of set overlay 
  incrementTaggedFields(newValue)

declareListener = () ->
  el = $(window.frameContent).find('.tw_navigation_change')

  $(window.frameContent).click (e) ->
    switch e.target.className
      when 'tw_navigation_change', 'tw_overlayDefinition', ''
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

        # innerText of overlay box
        # if innertext from target element is empty go for next sibling
        value = window.activeOverlay.target.innerText or window.activeOverlay.target.nextSibling.innerText

        # remove class
        $(window.activeOverlay.target.parentNode.parentNode).alterClass 'tw_*', ''

        # remove overlay block
        clickedOverlay = window.activeOverlay.target.parentNode
        $(clickedOverlay).remove()

        # decrement tagged Field
        decrementTaggedFields(value)

        # if navigation is removed, validate new if possible
        if value is 'Hauptnavigation'
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

        # move overlay box down from top of page
        movementTop = e.pageY - 80
        if movementTop < 10
          movementTop = 10

        $(el).css
          'top': movementTop,
          'left': '270px'

        # set current overlay
        window.activeOverlay = e

        # define breadcrumb navigation for current element
        if e.target.firstChild is null or e.target.className is 'tw_overlay_text'
          getBreadcrumbs(e.target.parentNode)
        else
          getBreadcrumbs(e.target.firstChild)

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
      # if a tag - assume that it is an navigation element and go tree up to ul element
      if overlayTarget[0].localName is 'a'
        overlayTarget = $(overlayTarget).parent().parent()

      # generate overlay
      generateOverlay(overlayTarget, value, true);
      # add class of type like tw_navigation
      overlayTarget.addClass 'tw_' + value.toLowerCase()    

    # set overlay via breadcrumb navigation
    else 
      # generate overlay
      generateOverlay(overlayTarget, value, true);
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

    mandatoryFields = ['Header', 'Content', 'Unternavigation', 'Footer']
    missingFields = []

    $.each mandatoryFields, (i, mandatoryField) ->
      # add missing element to array if its undefined or count is zero
      if window.taggedFields[mandatoryField] is undefined or window.taggedFields[mandatoryField] <= 0
        missingFields.push mandatoryField

    if missingFields.length is 0
      # remove all overlays
      $(window.frameContent).find('.overlay_wrap').remove()
      
      # prepare element json to store to database
      elements = JSON.stringify(window.fieldsToLearn)

      # save learned fields to database
      storeLearnElements(elements)

      # save analysed page and redirect to timeline
      saveAnalysedPage()

    else
      $('.missing_fields .fields').html missingFields.join(', ')
      $('.missing_fields').fadeIn()

      $('.missing_fields .close, .missing_fields .close_ok').click (e) ->
        $('.missing_fields').fadeOut()

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

saveAnalysedPage = () ->
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

validateFooter = () ->
  # element has no footer-overlay
  if window.elemFooter isnt undefined
    if $(window.elemFooter)[0].className.indexOf('tw_') < 0
      generateOverlay($(window.elemFooter), 'Footer')
    
# every change of navigation must be validated
validateNavigations = (nesting) ->
  # reset root navigation
  $(window.frameContent).find('.tw_root_hauptnavigation').alterClass 'tw_root_hauptnavigation', 'tw_root_unternavigation'

  # stop is no navigation can be found
  if $(window.frameContent).find('.tw_root_unternavigation').length > 0

    nesting = nesting or false

    # array of elements
    listMain = new Array('startseite', 'home', 'über uns')
    # array which stores navigation points
    navCnt = new Array();
    # list that contains every subnavigation
    subNav = $(window.frameContent).find('.tw_root_unternavigation')

    $.each subNav, (i) ->
      # is parent element is li, navigation has to be the subnavigation
      if $(this)[0].parentNode.localName isnt 'li' or nesting
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

    # is no main navigation could be found, retry with nested navigations
    if elem is undefined
      validateNavigations(true)

    # change subnavigation to navigation
    $(elem).alterClass 'tw_*', 'tw_root_hauptnavigation'
    $(elem).find('.tw_overlay_text:last').text 'Hauptnavigation' 

    # change highlighting class
    $(elem).find('.overlay_wrap:last').alterClass 'unternavigation', 'hauptnavigation'
