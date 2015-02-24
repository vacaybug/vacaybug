jQuery ->
  Vacaybug = window.Vacaybug ? {}

  class PlaceModel extends window.Vacaybug.GenericModel
    getGuideId: ->
      if @guide_id
        @guide_id
      else
        @collection.guide_id

    restURL: ->
    	if @get('id')
    		"/rest/guides/#{@getGuideId()}/places/#{@get('id')}"
    	else
    		"/rest/guides/#{@getGuideId()}/places"

  Vacaybug.PlaceModel = PlaceModel

  class PlaceCollection extends window.Vacaybug.GenericCollection
    model: window.Vacaybug.PlaceModel

    restURL: ->
    	"/rest/guides/#{@guide_id}/places"

    initialize: (options) ->
      @guide_id = options.guide_id
      super(options)

  Vacaybug.PlaceCollection = PlaceCollection
