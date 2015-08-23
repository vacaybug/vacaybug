jQuery ->
  class GuideView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/guide"]
    isPublic: true

    events:
      "click .guide-description-save": "saveDescription"
      "click .js-share-facebook": "shareFacebook"
      "click .btn-guide-delete": "deleteGuide"

    remove: ->
      $("#wrapper").addClass("container")

    initialize: (options) ->
      $("#wrapper").removeClass('container')
      @listenTo @model, 'sync', @render
      @places = new Vacaybug.PlaceCollection
        guide_id: @model.get('slug')
      @places.fetch()
      @placesView = new Vacaybug.PlacesView
        collection: @places

      @listenTo @places, 'sync', @initializeMap
      @listenTo @places, 'add', @initializeMap
      @listenTo @places, 'change', @initializeMap
      @listenTo @places, 'remove', @initializeMap

    initializeMap: ->
      return if $('.map-container').length == 0

      w = Math.max(document.documentElement.clientWidth, window.innerWidth || 0);
      isDraggable = w > 480 ? true : false;
      mapOptions = {
        draggable: isDraggable,
        scrollwheel: false
      };

      if @places.sync_status
        if @places.models.length > 0
          mapOptions = {scrollwheel: false}
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
          mapOptions = {zoom: 5, scrollwheel: false}
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

    initInputs: ->
      if @isPrivate
        $('.city-guide-heading').css
          "border" : "2px dashed #fff"
          "-webkit-border-radius": "8px"
          "-moz-border-radius": "8px"
          "border-radius": "8px"
          "margin-bottom": "10px"
        $('.guide-description-div').css
          "border": "2px dashed #98d6ec"
          "cursor": "pointer"
      else
        return

      $('.guide-description-div').editable (value, settings) =>
        @model.set('description', value)
        @model.save(null, {silent: true})
        value
      , {
        cssclass: 'text-center',
        type    : 'textarea',
        maxlength: 300,
        indicator: 'Saving...',
        submit  : '<button type="submit" class="btn btn-save"><i class="fa fa-check"></i> Save</button>',
        cancel  : '<button class="btn btn-cancel"><i class="fa fa-times"></i> Cancel</button>',
        onblur  : 'ignore',
      }

      $('.city-guide-heading').editable (value, settings) =>
        @model.set('title', value)
        @model.save(null, {silent: true})
        value
      , {
        type    : 'text',
        maxlength: 50,
        indicator: 'Saving...',
        submit  : '<button type="submit" class="btn btn-save"><i class="fa fa-check"></i> Save</button>',
        cancel  : '<button class="btn btn-cancel"><i class="fa fa-times"></i> Cancel</button>',
        onblur  : 'ignore',
      }

    render: ->
      return @ unless @model.sync_status

      @isPrivate = Vacaybug.current_user && @model.get('user').username == Vacaybug.current_user.get('username')
      @placesView.isPrivate = @isPrivate
      location = "#{@model.get('city')}, #{@model.get('region')}, #{@model.get('country')}"

      $(@el).html @template
        model: @model
        isPrivate: @isPrivate

      @initializeMap()
      @initInputs()

      @placesView.setElement(@$('.places-container')).render()

      timeout = null
      $(".js-search-places").typeahead(
        {
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
        $(".js-search-places").val("")
        place = new Vacaybug.PlaceModel
          guide_id: @model.get('id')
          fs_data: selected.data
        place.save null,
          success: (model) =>
            @places.add(place)
      )
      @

    shareFacebook: (e) ->
      e.preventDefault()
      url_prefix = "#{location.protocol}//#{location.host}"
      FB.ui
        method: 'feed',
        link: "#{url_prefix}/#{@model.get('user').username}/guides/#{@model.get('slug')}"
        name: "#{@model.get('user').full_name}'s #{@model.get('city')} trip"
        description: "Check out my #{@model.get('title')}"
        picture: "#{url_prefix}/#{@model.get('image').medium}"

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.GuideView = GuideView
