jQuery ->
  Vacaybug = window.Vacaybug || {}

  TxtOverlay = (pos, txt, cls, map) ->
    # Now initialize all properties.
    @pos = pos
    @txt_ = txt
    @cls_ = cls
    @map_ = map
    # We define a property to hold the image's
    # div. We'll actually create this div
    # upon receipt of the add() method so we'll
    # leave it null for now.
    @div_ = null
    # Explicitly call setMap() on this overlay
    @setMap map
    return

  TxtOverlay.prototype = new (google.maps.OverlayView)

  TxtOverlay::onAdd = ->
    # Note: an overlay's receipt of onAdd() indicates that
    # the map's panes are now available for attaching
    # the overlay to the map via the DOM.
    # Create the DIV and set some basic attributes.
    div = document.createElement('DIV')
    div.className = @cls_
    div.innerHTML = @txt_
    # Set the overlay's div_ property to this DIV
    @div_ = div
    overlayProjection = @getProjection()
    position = overlayProjection.fromLatLngToDivPixel(@pos)
    div.style.left = position.x + 'px'
    div.style.top = position.y + 'px'
    # We add an overlay to a map via one of the map's panes.
    panes = @getPanes()
    panes.floatPane.appendChild div
    return

  TxtOverlay::draw = ->
    overlayProjection = @getProjection()
    # Retrieve the southwest and northeast coordinates of this overlay
    # in latlngs and convert them to pixels coordinates.
    # We'll use these coordinates to resize the DIV.
    position = overlayProjection.fromLatLngToDivPixel(@pos)
    div = @div_
    div.style.left = position.x + 'px'
    div.style.top = position.y + 'px'
    return

  #Optional: helper methods for removing and toggling the text overlay.  

  TxtOverlay::onRemove = ->
    @div_.parentNode.removeChild @div_
    @div_ = null
    return

  TxtOverlay::hide = ->
    if @div_
      @div_.style.visibility = 'hidden'
    return

  TxtOverlay::show = ->
    if @div_
      @div_.style.visibility = 'visible'
    return

  TxtOverlay::toggle = ->
    if @div_
      if @div_.style.visibility == 'hidden'
        @show()
      else
        @hide()
    return

  TxtOverlay::toggleDOM = ->
    if @getMap()
      @setMap null
    else
      @setMap @map_
    return

  $.fn.flash_message = (options) ->
    options = $.extend(
      text: ""
      time: 5000
      how: "before"
      class_name: ""
      type: "notice"
    , options)
    $(this).each ->
      return if $(this).parent().find(".flash-message").get(0)
      message = $("<div class='flash-message flash-#{options.type} #{options.class_name}'>#{options.text}</div>").hide().fadeIn("fast")
      $(this)[options.how] message
      message.delay(options.time).fadeOut "normal", ->
        $(this).remove()

  flash_message = (options) ->
    options = $.extend(
      how: "append"
    , options)

    $("#notification").flash_message options

  $.getParameterByName = (name) ->
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
    regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
    results = regex.exec(location.search);
    return if results == null then "" else decodeURIComponent(results[1].replace(/\+/g, " "));

  Vacaybug.flash_message = flash_message
  window.Vacaybug ||= Vacaybug
  window.TxtOverlay = TxtOverlay
