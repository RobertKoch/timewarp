reloadVersion = (version) ->
  version_path = $('#timeline_config').attr('sites_path') + '/' + version + '/index.html'
  $('#version_frame').attr( 'src', version_path);


$(document).ready ->
  #on timeline path? Let's do some magic now ;)
  if $('#timeline_config').length != 0
    $('a.change_version').first().addClass 'active'

    $('a.change_version').on 'click', ->
      $('a.change_version').removeClass 'active'
      reloadVersion $(this).attr 'attr_version'
      $(this).addClass 'active'
    
