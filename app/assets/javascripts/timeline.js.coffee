reloadVersion = (version) ->
  version_path = $('#timeline_config').attr('sites_path') + '/' + version + '/index.html'
  $('#version_frame').attr( 'src', version_path)

saveVersion = (version) ->
  host = $('#app_config').attr 'host'
  
  # possibility 2: switch css files
  #href = host+'/assets/stylesheets/'+version+'.css'
  #$(window.frameContent).find('#cssVersion').attr href: href

  css = '<link class="cssVersion" rel="stylesheet" href="'+host+'/assets/stylesheets/'+version+'.css" type="text/css" media="screen" />'
  $(window.frameContent).find('head').append css

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

$(window).load ->
  # get current frame id to load frame-content
  frameID = $('iframe').attr('id')
  window.frameContent = $('#'+frameID).contents().find('html')

  # save individual versions
  warpSteps = [2008, 2003, 1998, 1994]
  $.each warpSteps, (i, version) ->
    saveVersion(version)

  # remove all additional css files to show current version
  $(window.frameContent).find('head').find('.cssVersion').remove()

  # init navigation
  initNavigation()

  getValueFromSessionStorage()