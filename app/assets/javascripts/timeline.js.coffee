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
  return tinycolor("rgb (" + red + "," + green + "," + blue + ")").toHex()

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
  $('#version_frame').attr( 'src', version_path)

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
  if $('#timeline_config').length != 0
    $('a.change_version').first().addClass 'active'

    $('a.change_version').on 'click', ->
      $('a.change_version').removeClass 'active'
      reloadVersion $(this).attr 'attr_version'
      $(this).addClass 'active'

getValueFromSessionStorage = () ->
  if sessionStorage
    topColors = sessionStorage.getItem 'timewarp_colorPicker'

    if topColors != null
      # save topColors globally
      # access with window.topColors[i].color
      window.topColors = JSON.parse(topColors)

warpVersion = (version) ->
  #'unternavigation',
  warpClasses = ['header', 'hauptnavigation', 'content', 'footer']

  switch version
      when 2008
        $.each warpClasses, (i, v) ->
          height = $(window.frameContent).find('.tw_root_'+v).css 'height'

          # if navigation element has no height, set background-color to including a tags
          if parseInt(height) < 1 && v.indexOf('navigation') >= 0
            aTags = $(window.frameContent).find('.tw_root_'+v+' > li > a')
            $(aTags).attr('style', 'background-color: '+window.topColors[i].color+' !important')
          else
            $(window.frameContent).find('.tw_root_'+v)
              .attr('style', 'background-color: '+window.topColors[i].color+' !important') 

      #when 2003
        

      when 1998
        # get table structure
        $.ajax(
          url: "/tw_assets/templates/tableStructure.html",
          async: false
        ).done (fileContent) ->
          # insert new structure in site
          $(window.frameContent).find('body').after fileContent

          $.each warpClasses, (i, v) ->
            content = $(window.frameContent).find('.tw_root_'+v)

            $(window.frameContent).find('#tableStructure').find('#'+v).html content[0].innerHTML

        # remove remaining content of body
        $(window.frameContent).find('body').children().remove()

      when 1994
        $.each warpClasses, (i, v) ->
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
        # define image sizes
        $(window.frameContent).find('img').attr( {width: '200px', height: 'auto'} )

$(window).load ->
  # get current frame id to load frame-content
  frameID = $('iframe').attr('id')
  window.frameContent = $('#'+frameID).contents().find('html')

  # get top used colors of website
  getValueFromSessionStorage()

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
