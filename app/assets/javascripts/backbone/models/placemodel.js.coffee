jQuery ->
  Vacaybug = window.Vacaybug ? {}

  class PlaceModel extends window.Vacaybug.GenericModel
    restURL: ->
    	if @get('id')
    		"/rest/guides/#{@get('guide_id')}/places/#{@get('id')}"
    	else
    		"/rest/guides/#{@get('guide_id')}/places"

  Vacaybug.PlaceModel = PlaceModel

  class PlaceCollection extends window.Vacaybug.GenericCollection
    model: window.Vacaybug.PlaceModel

    restURL: ->
    	"/rest/guides/#{@guide_id}/places"

    initialize: (options) ->
      @guide_id = options.guide_id
      super(options)

  Vacaybug.PlaceCollection = PlaceCollection
