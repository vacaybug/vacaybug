jQuery ->
  class GuideView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/guide"]

    events:
      "input .js-guide-title": "onDescriptionChange"
      "input .js-guide-description": "onDescriptionChange"
      "click .guide-description-save": "saveDescription"

    initialize: (options) ->
      @listenTo @model, 'sync', @render

      @places = new Vacaybug.PlaceCollection
        guide_id: @model.get('id')
      @places.fetch()
      @placesView = new Vacaybug.PlacesView
        collection: @places

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
                    name = venue.name + " - " + venue.location.formattedAddress[0]  + ", " + venue.location.formattedAddress[1]
                    matches.push({value: name, data: venue})
                  callback(matches)
            ), 300)
        }
      ).bind('typeahead:selected', (obj, selected, name) =>
        place = new Vacaybug.PlaceModel
          guide_id: @model.get('id')
          fs_data: selected.data
        place.save()
      )
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.GuideView = GuideView