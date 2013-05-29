chosen_tags = []

$(document).ready ->

  if $(".autocomplete").length > 0
    $(".autocomplete").autocomplete {
      source: tag_search_url,
      minLength: 3,
      select: (event, ui) ->
        chosen_tags.push ui.item.value if !isValueInArray(chosen_tags, ui.item.value)
        return
      close: () ->
        saveAndPrintTagList()
        $(this).val ''
    }

    #possibility to enter tags with enter-key
    $("input.autocomplete").on 'keyup', (evt) ->
      if(evt.keyCode == 13)
          $("a.add_tag").trigger 'click';

    $("a.add_tag").on 'click', ->
      input = $("input.autocomplete")
      if !isValueInArray(chosen_tags, input.val()) && input.val() != ''
        chosen_tags.push input.val() 
        saveAndPrintTagList()
      input.val ''

    $("a.submit_form").on 'click', ->
      $("form#edit_site").trigger 'submit'

    $("a.cancel_form").on 'click', ->
      #todo: hide form_container to go back to timeline
      chosen_tags = []
      $('input.taglist').val ''
      $('#chosen_tags').empty()


saveAndPrintTagList = () ->
  chosen_tags.sort()
  $('input.taglist').val chosen_tags.join ','
  $('#chosen_tags').empty()
  
  if chosen_tags.length == 0
    $('#chosen_tags').html('Keine Tags hinzugefügt.');
  else
    printTag(i) for i in chosen_tags
    
  bindClickHandler()

printTag = (tag) ->
  $('#chosen_tags').append('<span>'+tag+'&nbsp;<a href="javascript:void(0)" class="delete_tag" attr-tag="'+tag+'">löschen</a></span>')

deleteTag = (tag) ->
  idx = chosen_tags.indexOf tag
  chosen_tags.splice(idx, 1)
  saveAndPrintTagList()

bindClickHandler = () ->
  $("a.delete_tag").bind 'click', ->
    deleteTag($(this).attr('attr-tag'))

isValueInArray = (arr, val) ->
  i = 0
  while i < arr.length
    if val == arr[i]
      return true;
    i++
  return false
