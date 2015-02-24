jQuery ->
  class GuideModel extends window.Vacaybug.GenericModel
    restURL: ->
      if @get('id')
        "/rest/guides/#{@get('id')}"
      else
        "/rest/guides"

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.GuideModel = GuideModel

  class GuideCollection extends window.Vacaybug.GenericCollection
    model: window.Vacaybug.GuideModel

    initialize: (options) ->
      @username = options.username
      super(options)

    restURL: ->
      "/rest/users/#{@username}/guides"

  Vacaybug.GuideCollection = GuideCollection
