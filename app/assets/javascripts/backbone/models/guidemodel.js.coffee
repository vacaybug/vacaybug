jQuery ->
  class GuideModel extends window.Vacaybug.GenericModel
    restURL: ->
      if @get('id')
        "/rest/users/#{@get('user_id')}/guides/#{@get('id')}"
      else
        "/rest/users/#{@Get('user_id')}/guides"

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.GuideModel = GuideModel

  class GuideCollection extends window.Vacaybug.GenericCollection
    model: window.Vacaybug.GuideModel

    restURL: ->
      "/rest/users/#{@get('user_id')}/guides/#{@get('guide_id')}"

  Vacaybug.GuideCollection = GuideCollection
