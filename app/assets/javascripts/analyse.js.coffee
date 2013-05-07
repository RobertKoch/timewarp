$(window).load ->
  frameContent = $('#crawled_site').contents().find('html');

  defineAdditionalAddons(frameContent);

  recursiveIterate(frameContent);

  declareListener(frameContent); 

  removeUnsolicitedTags(frameContent);

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
  window.cnt = 0;
  length = $(node).children().length;

  $.each $(node).children(), (i) ->
    el = $(this)[0].children[0];

    if el != undefined
      # element contains only one tag, spezially a link tag 
      if $(el).length == 1 && $(el)[0].localName == 'a'
        # increment navigation-count if the <a> tag doesnt contain an image tag
        if $(el)[0].innerHTML.indexOf('<img') < 0
          window.cnt++;

  # additional increment to allow 1 extra element like span in navigation-block
  if window.cnt > 3 && (window.cnt == length || window.cnt+1 == length)
    generateOverlay($(node), 'Navigation');

generateOverlay = (node, value) -> 
  window.overlayCnt = window.overlayCnt || 0;
  
  classParam = value.toLowerCase();

  overlay    = '<div class="overlay_wrap">';
  overlay   += '<span class="tw_overlay tw_' + classParam + '"></span>';
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

  $(frameContent).find('.tw_editOverlay_breadcrumbs').html(path)

fadeOutOverlays = (frameContent, changeOverlay) ->
  $(changeOverlay).fadeOut 'slow', ->
    $(frameContent).find('.tw_background_overlay').fadeOut() 

declareListener = (frameContent) ->
  el = $(frameContent).find('.tw_navigation_change');

  $(frameContent).click (e) ->
    switch e.target.className
      when 'tw_highlight', 'tw_overlay_text'
        if e.target.className == 'tw_highlight'
          $(e.target).addClass 'highlight_current';
          window.setOverlay = 1;

        # define breadcrumb navigation for current element
        getBreadcrumbs(frameContent, e.target.parentNode)

        $(el).css
          'top': e.pageY,
          'left': e.pageX;

        window.activeOverlay = e;

        $(frameContent).find('.tw_background_overlay').fadeIn "slow", ->
          $(el).fadeIn();

      when 'tw_editOverlay_close', 'tw_background_overlay'
        fadeOutOverlays(frameContent, el)
           

  $(frameContent).find('.tw_overlayDefinition').change (e) ->
    value         = e.currentTarget.value;
    overlayTarget = $(window.activeOverlay.target);

    if window.setOverlay == undefined
      # change field value
      window.activeOverlay.target.innerText = value
    else
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
        if !$(frameContent).find('.tw_navigation_change').is(':visible')
          $(e.target).addClass 'tw_highlight';

          $(e.target).mouseout (e) ->
            $(e.target).removeClass 'tw_highlight';