animationTimeSlow = 500;
animationTimeFast = 300;

setArchiveArticleHeight = () ->
  archiveImageHeight = $('#archive article img').height();
  $('#archive article').css
    'height' : archiveImageHeight + 35

$(document).ready ->

  if $('#tagcloud_config').length != 0    
    tag_list = JSON.parse $('#tagcloud_config').attr('tags')
    $("#tagcloud").jQCloud( tag_list, {
      width: 600,
      height: 300
    });

  if $('#site_analyse').length != 0
    $('#crawled_site').attr
      'height' : 500
      #$(window).height() - 350 

  setArchiveArticleHeight();

  $.each $('#archive article'), (i) ->
    $(this).mouseenter ->
      $(this).find('.hover')
        .css
          'display' : 'block'
        .animate
          'opacity' : 1
          animationTimeSlow
      $(this).find('.sites_meta')
        .animate
          'bottom' : 37
          animationTimeFast
    $(this).mouseleave ->
      $(this).find('.hover')
        .animate
          'opacity' : 0
          animationTimeSlow
      $(this).find('.sites_meta')
        .animate
          'bottom' : 0
          animationTimeFast

$(window).load ->
  setArchiveArticleHeight();

$(window).resize ->
  setArchiveArticleHeight();
