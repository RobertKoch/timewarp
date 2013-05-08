$(window).load ->
  frameContent = $('#crawled_site').contents().find('html');

  defineAdditionalAddons(frameContent);

  recursiveIterate(frameContent);

  declareListener(frameContent); 

  removeUnsolicitedTags(frameContent);

  validateNavigations(frameContent)

  # if everything has finished set opacity to 1
  $('#crawled_site').css opacity: 1

removeUnsolicitedTags = (frameContent) ->
  $(frameContent).find('a').removeAttr 'href';

  #regex = new Array(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/g, /<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>/g);
  #i = 0;

  #while i < regex.length
  #  while regex[i].test(frameContent)
  #    frameContent = frameContent.replace(regex[i], ""); 
  #  i++;

defineAdditionalAddons = (frameContent) ->
  $.ajax(
    url: "/assets/templates/overlay.html",
    async: false
  ).done (fileContent) ->
    $(frameContent).find('body').append fileContent
  
  $(frameContent).find('body').append '<span class="tw_background_overlay"></span>'

  $(frameContent).find('.tw_background_overlay').css 'height': frameContent[0].offsetHeight


  $(frameContent).find('head').append '<link rel="stylesheet" href="http://localhost:3000/assets/stylesheets/analyse.css" type="text/css" media="screen" />';

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
      exploreTagUl($(this));

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

  $.each attributes, (i) ->
    if objArr[$(this)[0].nodeValue] != undefined
      # add appropriated class to node element
      $(node).addClass objArr[$(this)[0].nodeValue][0]
      generateOverlay($(node), objArr[$(this)[0].nodeValue][1])


exploreTagUl = (node) ->
  # reset variables
  window.cnt = 0;
  window.galleryCnt = 0;
  length = $(node).children().length;

  $.each $(node).children(), (i) ->
    el = $(this)[0].children[0];

    if el != undefined
      # element contains only one tag, spezially a link tag 
      if $(el).length == 1 && $(el)[0].localName == 'a'
        # increment navigation-count if the <a> tag doesnt contain an image tag
        if $(el)[0].innerHTML.indexOf('<img') < 0
          window.cnt++;
        else
          window.galleryCnt++; 

  # additional increment to allow 1 extra element like span in navigation-block
  if window.cnt > 3 && (window.cnt == length || window.cnt+1 == length)
    generateOverlay($(node), 'SubNavigation');
  else 
    if window.galleryCnt > 3
      generateOverlay($(node), 'Gallery');

setClass = (node, value) ->
  $(node).addClass 'tw_root_'+value

generateOverlay = (node, value) -> 
  classParam = value.toLowerCase()
  
  # set class to overlay root
  setClass(node, classParam)

  # overlayCnt correlates to z-index
  window.overlayCnt = window.overlayCnt || 0

  overlay    = '<div class="overlay_wrap">';
  #overlay   += '<span class="tw_overlay tw_' + classParam + '"></span>';
  overlay   += '<span class="tw_overlay"></span>';  
  overlay   += '<span class="tw_overlay_text">' + value + '</span>';
  overlay   += '</div>';

  $(node).append overlay;

  # chose parentNode if no height or width is available
  if $(node)[0].offsetHeight > 0 && $(node)[0].offsetWidth > 0
    attributes = $(node)[0];
  else
    attributes = $(node)[0].parentNode;  
    #check for height otherwise usw default

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
  window.overlayCnt++;

getBreadcrumbs = (frameContent, node) ->
  path = ''
  pNodes = $(node).parents('*')

  $.each pNodes, (i) ->
    # get localName 'div' etc.
    breadcrumb = $(this)[0].localName

    # add value of id if exists
    if ($(this)[0].id)
      breadcrumb += '#'+$(this)[0].id

    if (i > 0)
      breadcrumb += ' > '  
    
    # build breadcrumb navigation
    path = breadcrumb + path

  $(frameContent).find('.tw_overlayBreadcrumbs').html(path)

fadeOutOverlays = (frameContent, changeOverlay) ->
  $(changeOverlay).fadeOut 'slow', ->
    $(frameContent).find('.tw_background_overlay').fadeOut() 

declareListener = (frameContent) ->
  el = $(frameContent).find('.tw_navigation_change');

  $(frameContent).click (e) ->
    switch e.target.className
      when 'tw_overlayClose', 'tw_background_overlay'
        fadeOutOverlays(frameContent, el)

      when 'tw_overlayRemove'
        fadeOutOverlays(frameContent, el)

        # remove block
        clickedOverlay = window.activeOverlay.target.parentNode
        $(clickedOverlay).remove()

      else 
        if e.target.className == 'tw_highlight'
          $(e.target).addClass 'highlight_current';

        # if overlay even exists, set value to create new to undefined
        if e.target.parentNode.className.indexOf('overlay_wrap') >= 0
          window.setOverlay = undefined;
        else
          window.setOverlay = 1;

        # define breadcrumb navigation for current element
        getBreadcrumbs(frameContent, e.target.parentNode)

        $(el).css
          'top': e.pageY,
          'left': e.pageX;

        # set current overlay
        window.activeOverlay = e;

        # show overlay
        $(frameContent).find('.tw_background_overlay').fadeIn "slow", ->
          $(el).fadeIn();

  $(frameContent).find('.tw_overlayDefinition').change (e) ->
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
      console.log 'doch da'
      # generate overlay
      generateOverlay(overlayTarget, value);
      # remove class highlighed 
      overlayTarget.removeClass 'highlight_current';
      # add class of type like tw_navigation
      overlayTarget.addClass 'tw_' + value.toLowerCase();

    # reset select-box to first option
    e.currentTarget.selectedIndex = 0
    
    #fadeOut overlays
    fadeOutOverlays(frameContent, el)

  $(frameContent).mouseover (e) ->
    switch e.target.className 
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
        if e.target.className != 'tw_overlay_text' && $(frameContent).find('.tw_navigation_change').is(':hidden')
          $(e.target).addClass 'tw_highlight';
          
          $(e.target).mouseout (e) ->
            $(e.target).removeClass 'tw_highlight';

validateNavigations = (frameContent) -> 
  #navFooterValues = new Array('Kontakt', 'Impressum', 'Datenschutz')

  # array of elements
  listMain = new Array('startseite', 'home', 'über uns')
  # array which stores navigation points
  navCnt = new Array();
  # list that contains every subnavigation
  subNav = $(frameContent).find('.tw_root_subnavigation')
  
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
  maxCnt = Math.max.apply(Math, navCnt);
  # get array index of max value
  posOfMax = navCnt.indexOf(maxCnt);

  # change subnavigation to main navigation
  elem = subNav[posOfMax]

  # change subnavigation to navigation
  $(elem).alterClass 'tw_*', 'tw_root_navigation'
  $(elem).find('.tw_overlay_text').text 'Navigation'