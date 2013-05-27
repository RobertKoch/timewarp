$(window).load ->
  currentSrc = $('#site_images a img').first().attr 'src'

  $('#site_images').mouseover( (e) ->
    src = $(e.target).attr('src')

    if src != undefined
      if src.indexOf('current') < 0
        $('#site_images a img').first().attr 'src', src

  ).mouseout (e) ->
    $('#site_images a img').first().attr 'src', currentSrc