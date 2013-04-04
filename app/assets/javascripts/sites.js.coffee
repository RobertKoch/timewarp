setArchiveArticleHeight = () ->
  archiveImageHeight = $('#archive article img').height();
  $('#archive article').css
    'height' : archiveImageHeight

$(document).ready ->

  if $('#tagcloud_config').length != 0    
    tag_list = JSON.parse $('#tagcloud_config').attr('tags')
    $("#tagcloud").jQCloud( tag_list, {
      width: 600,
      height: 300
    });

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

$(window).resize ->
  setArchiveArticleHeight();
