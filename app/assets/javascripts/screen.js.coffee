setNavigationWidth = () ->
  headerWidth = $('#header').width();
  $('#navigation').css
    'width' : headerWidth - 130

setNarrowWrapperWidth = () ->
  wrapperWidth = $('#wrapper').width();
  $('#wrapper section').css
    'width' : wrapperWidth - 124

$(document).ready ->
  setNavigationWidth();
  setNarrowWrapperWidth();

$(window).resize ->
  setNavigationWidth();
  setNarrowWrapperWidth();
