jQuery ->
  class GuideModel extends window.Vacaybug.GenericModel
    restURL: ->
      if @get('id')
        "/rest/guides/#{@get('id')}"
      else
        "/rest/guides"

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.GuideModel = GuideModel
