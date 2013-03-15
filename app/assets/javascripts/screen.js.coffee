setNavigationWidth = () ->
  headerWidth = $('#header').width();
  $('#navigation').css({
    'width' : headerWidth - 130;
  });

$(document).ready ->
  setNavigationWidth();

$(window).resize ->
  setNavigationWidth();
