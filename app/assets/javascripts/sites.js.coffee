setArchiveArticleHeight = () ->
  archiveImageHeight = $('#archive article img').height();
  $('#archive article').css
    'height' : archiveImageHeight

$(document).ready ->
  setArchiveArticleHeight();

  $.each $('#archive article'), (i) ->
    $(this).mouseenter ->
      $(this).find('.hover')
        .css
          'display' : 'block'
        .animate
          'opacity' : 1
          500
    $(this).mouseleave ->
      $(this).find('.hover')
        .animate
          'opacity' : 0
          500

$(window).load ->
  setArchiveArticleHeight();

$(window).resize ->
  setArchiveArticleHeight();
