$(window).load ->
  frameContent = $('#crawled_site').contents().find('html');

  defineAdditionalTags(frameContent);

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

defineAdditionalTags = (frameContent) ->
  box  = '<div class="tw_navigation_change">';
  box += '<ul>';
  box += '<li class="tw_editOverlay">Header</li>';
  box += '<li class="tw_editOverlay">Content</li>';
  box += '<li class="tw_editOverlay">Navigation</li>';
  box += '<li class="tw_editOverlay">usw.</li>';
  box += '</ul>';
  box += '</div>';

  $(frameContent).find('body').append box;
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

exploreAttributes = (_node) ->
  objArr = new Object(
    navi: ["tw_navigation", "Navigation"], 
    header: ["tw_header", "Header"], 
    content: ["tw_content", "Content"]
  );

  # get attributes of node reference
  attributes = _node[0].attributes;

  $.each attributes, (i) ->
    if objArr[$(this)[0].nodeValue] != undefined
      # add appropriated class to node element
      $(_node).addClass objArr[$(this)[0].nodeValue][0]
      generateOverlay($(_node), objArr[$(this)[0].nodeValue][1])


exploreTagUl = (node) ->
  window.cnt = 0;
  length = $(node).children().length;

  $.each $(node).children(), (i) ->
    el = $(this)[0].children[0];

    if el != undefined
      # element only a link tag 
      if $(el).length == 1 && $(el)[0].localName == 'a'
        window.cnt++;

  if window.cnt > 3 && window.cnt == length
    generateOverlay($(node), 'Navigation');

generateOverlay = (node, value) ->
  window.overlayCnt = window.overlayCnt || 0;
  
  classParam = value.toLowerCase();

  overlay    = '<div class="overlay_wrap">';
  overlay   += '<span class="tw_overlay tw_' + classParam + '"></span>';
  overlay   += '<span class="tw_overlay_text">' + value + '</span>';
  overlay   += '</div>';

  $(node).append overlay;

  attributes = $(node)[0];

  console.log node;

  $(node).find('.overlay_wrap')
    .css
      'width': attributes.offsetWidth,
      'height': attributes.offsetHeight,
      'z-index': window.overlayCnt,
      'left': attributes.offsetLeft,
      'top': attributes.offsetTop;

  window.overlayCnt++;

declareListener = (frameContent) ->
  el = $(frameContent).find('.tw_navigation_change');

  $(frameContent).click (e) ->
    if (e.target.className.indexOf('tw_highlight') >= 0)
      console.log (e.pageY + ' - ' + e.pageX);
      $(e.target).addClass 'highlight_current';
      $(el).css
        'top': e.pageY,
        'left': e.pageX;
      $(el).fadeIn();
      window.activeOverlay = e;
      window.setOverlay = 1;
    else  

      switch e.target.className
        when 'tw_overlay_text' 
          $(el).css
            'top': e.pageY,
            'left': e.pageX;
          $(el).fadeIn(); 
          window.activeOverlay = e;

        when 'tw_editOverlay'  
          if window.setOverlay == undefined
            # change field value
            window.activeOverlay.target.innerText = e.target.innerText;
          else
            # generate overlay
            generateOverlay($(window.activeOverlay.target), e.target.innerText);
            # remove class highlighed 
            $(window.activeOverlay.target).removeClass 'highlight_current';
            # add class of type like tw_navigation
            $(window.activeOverlay.target).addClass 'tw_' + e.target.innerText.toLowerCase();
          $(el).fadeOut();

        

  $(frameContent).mouseover (e) ->
    switch e.target.className 
      when 'tw_overlay_text' 
        $(e.target.previousSibling).addClass 'tw_overlay_hover';

        $(e.target).mouseout (e) ->
          $(e.target.previousSibling).removeClass 'tw_overlay_hover';
      else
        # dont highlight overlay
        if !$(frameContent).find('.tw_navigation_change').is(':visible')
          $(e.target).addClass 'tw_highlight';

          $(e.target).mouseout (e) ->
            $(e.target).removeClass 'tw_highlight';