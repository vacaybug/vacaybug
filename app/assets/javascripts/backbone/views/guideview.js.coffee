jQuery ->
  class GuideView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/guide"]

    events:
      "input .js-guide-title": "onDescriptionChange"
      "input .js-guide-description": "onDescriptionChange"
      "click .guide-description-save": "saveDescription"
      "click .btn-guide-delete": "deleteGuide"

    initialize: (options) ->
      @listenTo @model, 'sync', @render

      @places = new Vacaybug.PlaceCollection
        guide_id: @model.get('id')
      @places.fetch()
      @placesView = new Vacaybug.PlacesView
        collection: @places

      @listenTo @places, 'sync', @initializeMap
      @listenTo @places, 'add', @initializeMap
      @listenTo @places, 'change', @initializeMap
      @listenTo @places, 'remove', @initializeMap

    initializeMap: ->
      if @places.sync_status
        if @places.models.length > 0
          mapOptions = {}
          map = new google.maps.Map($('.map-container')[0], mapOptions)
          bounds = new google.maps.LatLngBounds()
          for place in @places.models
            position = new google.maps.LatLng(place.get('location')['lat'], place.get('location')['lng'])
            bounds.extend(position)

            marker = new google.maps.Marker
              position: position
              map: map
              title: place.get('title')
              icon: "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=#{place.get('order_num')}|33CCFF|000000"

          map.fitBounds(bounds)
        else
          mapOptions = {zoom: 5}
          map = new google.maps.Map($('.map-container')[0], mapOptions)
          centerAddress = @model.get('city') + " " + @model.get('region') + " " + @model.get('country')
          geocoder = new google.maps.Geocoder();
          geocoder.geocode { 'address': centerAddress }, (results, status) ->
            if status == google.maps.GeocoderStatus.OK
              if status != google.maps.GeocoderStatus.ZERO_RESULTS
                map.setCenter results[0].geometry.location

    deleteGuide: ->
      if confirm('Are you sure you want to delete this guide?')
        @model.destroy
          success: ->
            Vacaybug.router.navigate('/profile', {trigger: true, replace: true})

    saveDescription: ->
      title = $(".js-guide-title").val()
      description = $(".js-guide-description").val()

      @model.set({"title": title, "description": description})
      @model.save()
      $(".guide-description-save").css("visibility", "hidden")

    onDescriptionChange: ->
      $(".guide-description-save").css("visibility", "visible")

    render: ->
      return @ unless @model.sync_status

      location = "#{@model.get('city')}, #{@model.get('region')}, #{@model.get('country')}"

      $(@el).html @template
        model: @model

      @initializeMap()

      @$('.places-container').html(@placesView.render().el)

      timeout = null
      $(".js-search-places").typeahead(
        {
          hint: true,
          highlight: true,
          minLength: 3
        },
        {
          displayKey: 'value',
          source: (query, callback) =>
            if (timeout)
              clearTimeout(timeout)
            
            timeout = setTimeout((->
              matches = []
              $.ajax
                url: "/api/fs/search_places?query=#{encodeURIComponent(query)}&near_location=#{encodeURIComponent(location)}"
                success: (resp) ->
                  matches = []
                  for venue in resp.venues
                    name = venue.name + " - " + venue.location.formattedAddress.join(", ")
                    matches.push({value: name, data: venue})
                  callback(matches)
            ), 300)
        }
      ).bind('typeahead:selected', (obj, selected, name) =>
        place = new Vacaybug.PlaceModel
          guide_id: @model.get('id')
          fs_data: selected.data
        place.save null,
          success: (model) =>
            @places.add(place)
      )
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.GuideView = GuideView
