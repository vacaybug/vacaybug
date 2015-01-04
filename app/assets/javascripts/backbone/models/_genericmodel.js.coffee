jQuery ->
  class GenericModel extends Backbone.Model
    url: ->
      "#{@restURL()}?#{@queryParams()}"

    queryParams: ->
      ""

    parse: (resp, options) ->
      @sync_status = true

      if options.collection
        super(resp, options)
      else
        super(resp.model, options)

  class GenericCollection extends Backbone.Collection
    url: ->
      "#{@restURL()}?#{@queryParams()}"

    queryParams: ->
      ""

    initialize: ->

    parse: (resp, options) ->
      @sync_status = true
      @total = resp.total
      super(resp.models, options)

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.GenericModel = GenericModel
  Vacaybug.GenericCollection = GenericCollection
