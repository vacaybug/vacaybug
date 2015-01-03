jQuery ->
  class GenericModel extends Backbone.Model
    url: ->
      "#{@restURL()}?#{@queryParams()}"

    queryParams: ->
      ""

    parse: (resp, xhr) ->
      @sync_status = true
      super(resp.model, xhr)

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.GenericModel = GenericModel
