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


  $('#introduction h1').css
    'margin-top': $(window).height() - ($(window).height() / 1.3)

$(window).load ->

  $.stellar
    horizontalScrolling: false
    verticalOffset: 80

s = $('.period')
curr = $('.period').length - 1
node = undefined
$(document).keydown (e) ->
  switch e.keyCode
    when 40
      e.preventDefault();
      node = s[++curr]
      if node
        $('html, body').animate
          scrollTop: $(node).offset().top - 80
        , 2000
      else
        curr = s.length - 1
    when 38
      e.preventDefault();
      node = s[--curr]
      if node
        $('html, body').animate
          scrollTop: $(node).offset().top - 80
        , 2000
      else
        curr = $('.period').length - 1