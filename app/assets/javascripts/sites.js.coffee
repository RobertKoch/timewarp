animationTimeSlow = 500;
animationTimeFast = 300;

setArchiveArticleHeight = () ->
  archiveImageHeight = $('.site_preview img').height();
  $('.site_preview').css
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

  if $('#site_meta').length != 0
    addLikeListener()

  setArchiveArticleHeight();

  $.each $('.site_preview'), (i) ->
    $(this).mouseenter ->
      $(this).find('.hover')
        .css
          'display' : 'block'
        .animate
          'opacity' : 1
          animationTimeSlow
      $(this).find('.site_meta')
        .animate
          'bottom' : 37
          animationTimeFast
    $(this).mouseleave ->
      $(this).find('.hover')
        .animate
          'opacity' : 0
          animationTimeSlow
      $(this).find('.site_meta')
        .animate
          'bottom' : 0
          animationTimeFast

  $('#sub_navigation a').append('<span></span>');

$(window).load ->
  setArchiveArticleHeight();

$(window).resize ->
  setArchiveArticleHeight();
