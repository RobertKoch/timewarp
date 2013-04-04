chosen_tags = []

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

$("a.add_tag").on 'click', ->
  input = $("input.autocomplete")
  if !isValueInArray(chosen_tags, input.val()) && input.val() != ''
    chosen_tags.push input.val() 
    saveAndPrintTagList()
  input.val ''


saveAndPrintTagList = () ->
  chosen_tags.sort()
  $('input.taglist').val chosen_tags.join ','
  $('#chosen_tags').empty()
  printTag(i) for i in chosen_tags
  bindClickHandler()

printTag = (tag) ->
  $('#chosen_tags').append('<span>'+tag+' <a href="javascript:void(0)" class="delete_tag" attr-tag="'+tag+'">löschen</a></span>')

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
