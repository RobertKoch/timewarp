getCssContent = () ->
  linkTags = $(window.frameContent).find('link')
  cssContent = ''

  $.each linkTags, (i, elem) ->
    if $(elem)[0].type == 'text/css' && $(elem)[0].href.indexOf('.css') >= 0 && $(elem)[0].href.indexOf('localhost') == -1
      # get content from current css file
      $.ajax(
        type: 'POST',
        dataType: 'text',
        url: "/sites/get_css_content",
        data: {
          path: $(elem)[0].href
        }
        async: false
      ).done (data) ->
        cssContent += data

  return cssContent

validateColors = (css) ->
  # create new Paser
  parser = new CSSParser()
  parseCss = parser.parse(css, false, true)

  sum = null
  colorBar = ''
  colorsIndex = {}
  colorArr = []

  objArr = new Object(
    #color: true,
    backbround: true,
    'background-color': true
  );

  if parseCss && parseCss.cssRules
    for i in [0...parseCss.cssRules.length]
      rule = parseCss.cssRules[i];

      if !rule.declarations
        continue

      declarations = rule.declarations;
      for j in [0...declarations.length]
        
        if !declarations[j].property
          continue

        # should element be counted
        if objArr[declarations[j].property] != undefined
          color = declarations[j].valueText.toLowerCase()

          if colorsIndex[color]
            colorsIndex[color]++ 
          else
            colorsIndex[color] = 1

  # fill array with color und count value of frequency
  for color, cnt of colorsIndex
    if color.indexOf '#' >= 0
      if color.charAt(0) == '#'
        sum += cnt
        colorArr.push([color, cnt])
  
  # sort array like DESC
  colorArr = colorArr.sort (a, b) ->
    b[1] - a[1]

  $.each colorArr, (i, v) ->
    percent = v[1] * 100 / sum
    colorBar += '<span data-cnt="'+v[1]+'" data-color="'+v[0]+'" style="width:'+percent+'%;background-color:'+v[0]+'"></span>'

  $('#colorBar').prepend colorBar

$(window).load ->
  css = getCssContent()

  validateColors(css)

  $('#colorBar span').mouseover (e) ->
    # get values of color and count
    color = e.target.attributes[1].nodeValue
    cnt = e.target.attributes[0].nodeValue

    # show every color with 6 digits
    if color.length < 5
      color += color.replace '#', ''

    # move box from left border
    # alternative use: e.target.offsetLeft
    $('#colorBarInfo').css 'margin-left': (e.pageX - 75)

    $('#colorBarInfo').html(cnt+'x '+color)

    if $('#colorBarInfo').is(':hidden')
      $('#colorBarInfo').fadeIn()

    # fadeOut infobox
    $('#colorBar').mouseleave (e) ->
      $('#colorBarInfo').fadeOut()