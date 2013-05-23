$(document).ready ->
  
  # fancybox
  $('a.fancybox').fancybox();

  $('a.fancybox_inline').fancybox({
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

  # timewarp form on front page
  $('.errors').append '<span class="arrow"></span>'