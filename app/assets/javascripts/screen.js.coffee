setNavigationWidth = () ->
  headerWidth = $('#header').width();
  $('#navigation').css
    'width' : headerWidth - 130

setNarrowWrapperWidth = () ->
  wrapperWidth = $('#wrapper').width();
  $('#wrapper section').css
    'width' : wrapperWidth - 124

$(document).ready ->
  # setNavigationWidth();
  # setNarrowWrapperWidth();

  $('a.fancybox').fancybox();

  $("a.fancybox_inline").fancybox({
    fitToView : false,
    width   : 500,
    height    : 320,
    autoSize  : false,
    closeClick  : false,
    closeBtn : false,
    padding : 2,
    helpers:  {
      overlay : {
        closeClick  : false
      }
    }
  });

$(window).load ->
  # setNavigationWidth();
  # setNarrowWrapperWidth();

$(window).resize ->
  # setNavigationWidth();
  # setNarrowWrapperWidth();
