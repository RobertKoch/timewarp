getWebSafeColor = (color) ->
  # convert color to RGB
  colorRGB = tinycolor(color).toRgb()
  # webSafe colors in RGB values
  webSafeArr = [0, 51, 102, 153, 204, 255]

  # get array position of every color
  red = webSafeArr[Math.round(colorRGB.r / 51)]
  green = webSafeArr[Math.round(colorRGB.g / 51)]
  blue = webSafeArr[Math.round(colorRGB.b / 51)]
  
  # return hex value
  return '#' + tinycolor("rgb (" + red + "," + green + "," + blue + ")").toHex()

getColorName = (color) ->
  colorHexArr = []
  # convert color to RGB
  colorRGB = tinycolor(color).toRgb()

  $.each colorRGB, (index, value) ->
    # lower than 128 -> 0, higher than 128 -> 255
    if value < 128
      colorHexArr.push 0
    else
      colorHexArr.push 255

  # return color name
  return tinycolor("rgb (" + colorHexArr[0] + "," + colorHexArr[1] + "," + colorHexArr[2] + ")").toName()

reloadVersion = (version) ->
  version_path = $('#timeline_config').attr('sites_path') + '/' + version + '/index.html'
  frame = $('#version_frame')
  browser = $('#browser')

  $(frame).attr('src', version_path)

  switch version
    when '1994'
      $(frame).attr
        width: 640
        height: 480
      $(browser).attr 'class', 'browser_1994'

    when '1998'
      $(frame).attr
        width: 800
        height: 600

      $(browser).attr 'class', 'browser_1998'

    when '2003', '2008'
      $(frame).attr
        width: 1024
        height: 768

      $(browser).attr 'class', 'browser_2003' 

      if version is '2008'
        $(browser).addClass 'browser_2008'

    else 
      $(frame).attr('width', '100%')
      $(browser).attr 'class', 'browser_current'

      if $(window).height() > 768
        $(frame).attr 'height', $(window).height() - 295
      else
        $(frame).attr 'height', 450 
      
saveVersion = (version) ->
  host = $('#app_config').attr 'host'

  # get path information
  token   = $('#timeline_token').attr('token')
  content = $('#version_frame').contents().find('html')[0].outerHTML

  # save new index at considering year
  $.ajax(
    type: 'POST',
    dataType: 'json',
    url: "/sites/rewrite_content",
    data: {
      token: token,
      version: version,
      content: content
    },
    async: false
  )

addCssClasses = (version) ->
  host = $('#app_config').attr 'host'

  css = '<link class="cssVersion" rel="stylesheet" href="'+host+'/tw_assets/stylesheets/'+version+'.css" type="text/css" media="screen" />'
  $(window.frameContent).find('head').append css

initNavigation = () ->
  # on timeline path? Let's do some magic now ;)
  if $('#timeline_config').length isnt 0
    $('a.change_version').first().addClass 'active'

    $('a.change_version').on 'click', ->
      $('a.change_version').removeClass 'active'
      reloadVersion $(this).attr 'attr_version'
      $(this).addClass 'active'

getValueFromSessionStorage = () ->
  if sessionStorage
    topColors = sessionStorage.getItem 'timewarp_colorPicker'

    if topColors isnt null
      # save topColors globally
      # access with window.topColors[i].color
      window.topColors = JSON.parse(topColors)

changePageStructure = (structure, prefix, warpClasses) ->
  # current width df content
  currentWidth = 60;

  $.ajax(
    url: '/tw_assets/templates/'+structure+'.html',
    async: false
  ).done (fileContent) ->
    # insert new structure in site
    $(window.frameContent).find('body').after fileContent

    $.each warpClasses, (i, v) ->
      # element was found in current structure
      if $(window.frameContent).find(prefix+v)[0]

        # if can only be true if structure == tableStructure
        # if current area is part of twNotFound array -> remove area from tableStructure
        if v in window.twNotFound
          $(window.frameContent).find('#'+v).remove()
        
        else  
          # if header contains main navigation, remove ist from header part
          if v is 'header'
            if $(window.frameContent).find('.tw_root_header').has('.tw_root_hauptnavigation').length > 0
              $(window.frameContent).find('.tw_root_header').find('.tw_root_hauptnavigation').remove()

          try
            # get content - usw prefix to find right container to access
            content = $(window.frameContent).find(prefix+v)

            # insert content to new structure
            $(window.frameContent).find('#'+structure).find('#'+v).html content[0].innerHTML
          catch e

      else
        # add not founded area to twNotFound array
        window.twNotFound.push v

        # extend content-width if sidebar or unternavigation couldnt be found
        if v is 'sidebar' or v is 'unternavigation'
          # add 20 percentage for each missing block
          currentWidth += 20
          $(window.frameContent).find('#divStructure > #content').css width: currentWidth+'%'

  # remove remaining content of body
  $(window.frameContent).find('body').children().remove()

setColors = (warpClasses, prefix, webSafe) ->
  # break if there are no colors available
  if window.topColors isnt undefined
    i = 0

    $.each warpClasses, (j, v) ->
      elem = $(window.frameContent).find(prefix+v)
      
      if elem.length > 0 and i < window.topColors.length
        height = $(elem).css 'height'

        # get color from global element
        color = window.topColors[i].color

        # if color should be websafe edit color varibale
        if webSafe
          color = getWebSafeColor(color)

        # if navigation element has no height, set background-color to including a tags
        if parseInt(height) < 1 and v.indexOf('navigation') >= 0
          aTags = $(window.frameContent).find(prefix+v+' > li > a')
          $(aTags).attr('style', 'background-color: '+color+' !important')
        else
          $(elem).attr('style', 'background-color: '+color+' !important')

        i++

getPath = () ->
  host = $('#app_config').attr 'host'

  return host+'/tw_assets'

getRandomNumer = (max) ->
  return Math.floor (Math.random() * max) + 1

getImageTag = (name, max, additionalClass) ->
  if additionalClass is undefined
    additionalClass = ''

  return '<img src="'+getPath()+'/images/'+name+'_'+getRandomNumer(max)+'.gif" class="tw_image '+additionalClass+'" />'

warpVersion = (version) ->
  # note: hauptnavigation has to be before header
  warpClasses = ['hauptnavigation', 'header', 'sidebar', 'content', 'footer', 'unternavigation', 'logo']

  switch version
      when 2008
        # set most commen color to different areas
        setColors(warpClasses, '.tw_root_', false)

        # rebuild site with div structure
        changePageStructure('divStructure', '.tw_root_', warpClasses)

        # remove facebook like-box plugin
        $(window.frameContent).find('iframe[src*="facebook"]').remove()

        removeElements = ['slider', 'facebook', 'twitter', 'rss', 'social', 'socialmedia', 'gplus', 'googleplus']
        $.each removeElements, (i, element) ->
          # try removing slider
          $(window.frameContent).find('*[id*="'+element+'"]').remove()
          $(window.frameContent).find('*[class*="'+element+'"]').remove()

      when 2003
        # find all headlines in content
        headlines = $(window.frameContent).find('#content').find(':header')
        
        # animate headlines
        $.each headlines, (i, headline) ->
          random = Math.random()
          if random < 0.5
            # marquee tag
            $(headline).html '<marquee class="tw_animation" scrollamount="5" behavior="alternate" direction="left">'+$(headline).text()+'</marquee>'
          else
            # blink tag
            $(headline).html '<span class="tw_animation animation_blink">'+$(headline).text()+'</span>'

        # background gradient
        $(window.frameContent).find('body').addClass 'bgGrandient_'+getRandomNumer(3)

        # add shadow to buttons
        $(window.frameContent).find('[type="submit"]').addClass 'tw_button'

      when 1998
        # add additional css class - bootstrap geo cities
        addCssClasses('bootstrap_geo')

        # rebuild site with table structure
        changePageStructure('tableStructure', '#divStructure > #', warpClasses)

        # remove remaining div structure
        $(window.frameContent).find('#divStructure').remove()

        # remove headline animations
        animationBlocks = $(window.frameContent).find('.tw_animation')
        $.each animationBlocks, (i, animationBlock) ->
          $(animationBlock)[0].outerHTML = $(animationBlock).text()

        # set background image
        path = getPath()+'/images/background_'+getRandomNumer(10)+'.png'
        $(window.frameContent).find('body').css 'background', 'url('+path+') 0 0 repeat'

        # insert animated email gif
        mails = $(window.frameContent).find('a:contains("@")')
        $.each mails, (i, mail) ->
          $(mail).html getImageTag('email', 10)+'<span class="tw_hide">'+$(mail).html()+'</span>'

        # find possibile urls
        urls = $(window.frameContent).find('a:contains(".")').not('a:contains("@")')
        # compare urls with domain-regex
        regex = new RegExp(/[-a-zA-Z0-9@:%_\+.~#?&//=]{2,256}\.[a-z]{2,4}\b(\/[-a-zA-Z0-9@:%_\+.~#?&//=]*)?/gi)
        $.each urls, (i, url) ->
          txt = $(url).text()
          # add gif if url matches with regex
          if txt.match(regex)
            $(url).prepend getImageTag('weltkugel', 3, 'tw_gif_earth')

        # insert counter
        $(window.frameContent).find('#content').append 'Besucher: '+getImageTag('counter', 5)

        # add gif to navigation elements
        path = getPath()+'/images/navigation_'+getRandomNumer(4)+'.gif'
        $(window.frameContent).find('#unternavigation li a').css 'background', 'url('+path+') 0 0 no-repeat'

        # set webSafe colors
        setColors(warpClasses, '#', true)

        # prepend alarm to first headline
        $(window.frameContent).find('#content').find(':header:first').prepend getImageTag('alarm', 6)

        # add gifs to main navigation
        mainNavCnt = $(window.frameContent).find('#hauptnavigation > li').length
        # array of gif animations
        symbols = ['pfeil_links', 'pfeil_rechts', 'neu']
        for i in [0...2]
          # random element of main navigation
          randNum = Math.floor (Math.random() * mainNavCnt) + 1
          # choose random symbol
          randSym = Math.floor (Math.random() * 3)

          # find navigation element at position randNum
          randomElement = $(window.frameContent).find('#hauptnavigation > li').eq(randNum)

          # left array after element
          if randSym is 0
            $(randomElement).append getImageTag(symbols[randSym], 6, 'tw_gif_mainNavigation')
          else
            $(randomElement).prepend getImageTag(symbols[randSym], 6, 'tw_gif_mainNavigation')

        # addons to sidebar
        if 'sidebar' not in window.twNotFound
          $(window.frameContent).find('#sidebar').prepend getImageTag('computer', 9)

        # addons to subnavigation
        if 'unternavigation' not in window.twNotFound
          $(window.frameContent).find('#unternavigation').append getImageTag('anti_ie', 3)
 
        # add additional button class btn
        buttonclass = ['btn', 'btn-primary', 'btn-info', 'btn-success', 'btn-warning', 'btn-danger', 'btn-inverse']
        randClassNum = getRandomNumer(7) - 1
        $(window.frameContent).find('button, [type="submit"]').addClass buttonclass[randClassNum]

        # add banner after tw_bar to keep bar on left side
        $(window.frameContent).find('.tw_bar').after getImageTag('banner', 4, 'tw_banner')

        # bar at left side
        siteHeight = $(window.frameContent).find('body').css 'height'
        # are colors available
        if window.topColors isnt undefined
          sidecolor = window.topColors[0].color
        else
          sidecolor = '#b2c400'

        $(window.frameContent).find('.tw_bar').css 
          'height': siteHeight
          'background-color': sidecolor

      when 1994
        # seperate content from structure
        # use horizontal rule als seperator
        $.each warpClasses, (i, v) ->
          # add only areas which arent in twNotFound array
          if v not in window.twNotFound
            content = $(window.frameContent).find('#'+v)
            content = content[0].innerHTML + '<br><hr></br>'

            $(window.frameContent).find('body').append content

        # remove link tags
        $(window.frameContent).find('link:not(:last)').remove()
        # remove script tags
        $(window.frameContent).find('script').remove()
        # remove timewarp generated elements
        $(window.frameContent).find('.tw_navigation_change').remove()
        $(window.frameContent).find('#tableStructure').remove()
        # remove inline styles
        $(window.frameContent).find('*[style]').removeAttr 'style'
        # remove onload attribute
        $(window.frameContent).find('*[onload]').removeAttr 'onload'
        # define image sizes
        $(window.frameContent).find('img').attr( {width: '200px', height: 'auto'} )
        # remove gifs
        $(window.frameContent).find('.tw_image').remove()

$(window).load ->
  if $('#timeline_config').attr('site_published') == "false"
    # get current frame id to load frame-content
    frameID = $('iframe').attr('id')
    window.frameContent = $('#'+frameID).contents().find('html')

    # get top used colors of website
    getValueFromSessionStorage()

    # save not founded areas
    window.twNotFound = []

    # save individual versions
    # starting with 1994 enables css inline styles in following years
    warpSteps = [2008, 2003, 1998, 1994]
    $.each warpSteps, (i, version) ->
      addCssClasses(version)
      warpVersion(version)
      saveVersion(version)

    # remove all additional css files to show current version
    $(window.frameContent).find('head').find('.cssVersion').remove()

    # init navigation
    initNavigation()

    # display current version
    reloadVersion('current')
  else
    initNavigation()
    reloadVersion('current')
