animationTimeSlow = 500;
animationTimeFast = 300;

setArchiveArticleHeight = () ->
  archiveImageHeight = $('#archive article img').height();
  $('#archive article').css
    'height' : archiveImageHeight + 35

addLikeListener = () ->
  $('a.likes').on 'click', ->
    $.ajax $('#likes_config').attr('attr_link'),
      type: 'GET'
      dataType: 'json'
      success: (data, textStatus, jqXHR) ->
        $('a.likes span.number').html(data);
        $('a.likes').off 'click'

$(document).ready ->
  if $('#site_analyse').length != 0
    $('#crawled_site').attr
      'height' : 500
      #$(window).height() - 350 

  if $('#site_meta').length != 0
    addLikeListener()

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
