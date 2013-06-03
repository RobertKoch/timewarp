s = $('.period')
numberOfPeriods = curr = $('.period').length - 1
node = undefined
greenPendulum = $('#logo .up')
bluePendulum = $('#logo .down')

$(document).ready ->

  # set periods height to 100% and revoke display none
  $('.period').css
    'height' : $(window).height() - 80
    'display': 'block'

  # scroll to introduction
  $('html, body').animate
    scrollTop: $(document).height()
  , 100

  # fade in elements when page is fully loaded and scrolled to bottom of page
  $('.period').animate
      'opacity': 1
    , 1000

  # set position of introduction headlines 
  $('#introduction h1').css
    'margin-top': $(window).height() - ($(window).height() / 1.3)

$(window).load ->

  $.stellar
    horizontalScrolling: false
    verticalOffset: 80

$(document).keydown (e) ->
  switch e.keyCode
    # arrow down
    when 40
      e.preventDefault();
      node = s[++curr]
      if node
        $('html, body').animate
          scrollTop: $(node).offset().top - 80
        , 2000

        rotateLogo -360
        movePendulum greenPendulum, greenPendulum.height(), 'down'
        movePendulum bluePendulum, bluePendulum.height(), 'up'
      else
        curr = s.length - 1
    # arrow up
    when 38
      e.preventDefault();
      node = s[--curr]
      if node
        $('html, body').animate
          scrollTop: $(node).offset().top - 80
        , 2000

        rotateLogo 360
        movePendulum greenPendulum, greenPendulum.height(), 'up'
        movePendulum bluePendulum, bluePendulum.height(), 'down'

      else
        curr = numberOfPeriods

# logo rotation
rotateLogo = (d) ->
  elem = $("#logo a")
  $(deg: 0).animate
    deg: d
  ,
    duration: 2000
    step: (now) ->
      elem.css transform: "rotate(" + now + "deg)"

# pendulum movement
movePendulum = (p, h, d) ->
  pendulum = p
  height = h
  movementHeight = $('#logo .up').height() / numberOfPeriods

  if (d == 'down')
    $(pendulum).animate
      'height': height + movementHeight
    , 2000
  else if (d == 'up')
    $(pendulum).animate
      'height': height - movementHeight
    , 2000
