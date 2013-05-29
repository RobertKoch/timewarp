$(document).ready ->

  $('.period').css
    'height' : $(window).height() - 80

  $('.period').css
    'display': 'block'

  $('.period').animate
      'opacity': 1
    , 1000

  $('html, body').animate
    scrollTop: $(document).height()
  , 100

$(window).load ->

  $.stellar
    horizontalScrolling: false
    verticalOffset: 80