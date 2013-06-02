getValue = (e) ->
  value = e.target.innerText.toLowerCase()

  # return false is ( is found or choosen element (-class) doesnt exist in frame
  if value.indexOf('(') >= 0 or !$(window.frameContent).find('.tw_root_'+value).text()
    return false

  return value  

$(window).load ->
  $('#legend').on click: (e) ->
    e.preventDefault()
    value = getValue(e)

    if value 
      # scroll to element
      $(window.frameContent).find('body').animate
        scrollTop: $(window.frameContent).find('.tw_root_'+value).offset().top
      , 1000
  , 'li'

  $('#legend li').mouseover( (e) ->
    value = getValue(e)

    if value
      # add class to hovered element
      $(e.target).addClass 'scrollTo'

      # find element in iframe and add class
      elem = $(window.frameContent).find('.tw_root_'+value)
      window.overlay = elem[0].lastChild.firstChild
      $(overlay).addClass 'tw_highlight'

  ).mouseout (e) ->
    # remove classes
    $(e.target).removeClass 'scrollTo'
    $(window.overlay).removeClass 'tw_highlight'


