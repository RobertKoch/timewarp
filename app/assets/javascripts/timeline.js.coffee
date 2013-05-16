reloadVersion = (version) ->
  version_path = $('#timeline_config').attr('sites_path') + '/' + version + '/index.html'
  $('#version_frame').attr( 'src', version_path);

navigation = () ->
  # on timeline path? Let's do some magic now ;)
  if $('#timeline_config').length != 0
    $('a.change_version').first().addClass 'active'

    $('a.change_version').on 'click', ->
      $('a.change_version').removeClass 'active'
      reloadVersion $(this).attr 'attr_version'
      $(this).addClass 'active'

defineAdditionalAddons = () ->
  $(window.frameContent).find('head').append '<link rel="stylesheet" href="http://localhost:3000/assets/stylesheets/timeline.css" type="text/css" media="screen" />';

$(window).load ->
  # get current frame id to load frame-content
  frameID = $('iframe').attr('id')
  window.frameContent = $('#'+frameID).contents().find('html')

  # init navigation
  navigation()

  # load addons like css files
  defineAdditionalAddons()