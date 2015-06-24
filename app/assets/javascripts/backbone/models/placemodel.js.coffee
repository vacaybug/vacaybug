jQuery ->
  Vacaybug = window.Vacaybug ? {}

  class PlaceModel extends window.Vacaybug.GenericModel
    idAttribute: 'assoc_id'

    getGuideId: ->
      if @get('guide_id')
        @get('guide_id')
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

    comparator: (item) ->
      item.get('order_num')

    restURL: ->
    	"/rest/guides/#{@guide_id}/places"

    initialize: (options) ->
      @guide_id = options.guide_id
      super(options)

  Vacaybug.PlaceCollection = PlaceCollection
