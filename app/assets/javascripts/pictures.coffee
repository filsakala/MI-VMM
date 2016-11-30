# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $('.pop_up').popup({
    hoverable: true,
    position: 'top left'
  });

  $('.ui.checkbox').checkbox();

  $('#type-select').on 'change', ->
    value = this.value
    if value == 'euclidean'
      $('#type-selected').html(
        '<label>Euclidean distance threshold: <span class="ui teal circular label" id="write-threshold">0.5</span></label>' +
          '<input type="range" min="0" max="" value="0.5" step="0.05" id="threshold-changer">' +
          '<input type="hidden" name="threshold" id="threshold" value="0">'
      )
    else if value == 'sqft'
      $('#type-selected').html(
        '<label>Signature Quadratic Form Distance threshold: <span class="ui teal circular label" id="write-threshold">10</span></label>' +
          '<input type="range" min="0" max="20" value="10" id="threshold-changer">' +
          '<input type="hidden" name="threshold" id="threshold" value="0">'
      )

  $('.rating').rating({
    initialRating: 2,
    maxRating: 4
  })

  $('#threshold-changer').on 'mousemove', ->
    $('#write-threshold').html(this.value)
    $('#threshold').val(this.value)

  $('#threshold-changer-sqft').on 'mousemove', ->
    $('#write-threshold-sqft').html(this.value)
    $('#threshold_sqft').val(this.value)

  $('.menu .item').tab()

  $('.special.cards .image').dimmer({
    on: 'hover'
  });

  $('.minicolors-input').minicolors()