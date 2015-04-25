jQuery ->
  class GuideModel extends window.Vacaybug.GenericModel
    restURL: ->
      if @get('id')
        "/rest/guides/#{@get('id')}"
      else
        "/rest/guides"

    duplicate: ->
      $.ajax
        type: 'POST',
        url: @restURL() + "/duplicate"

        success: =>
          Vacaybug.flash_message({text: "You have successfully added this guide to your wishlist", type: 'notice'})

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.GuideModel = GuideModel

  class GuideCollection extends window.Vacaybug.GenericCollection
    model: window.Vacaybug.GuideModel

    comparator: (item) ->
      -item.get('id')

    initialize: (options) ->
      @type = options.type
      @username = options.username
      super(options)

    queryParams: ->
      "type=#{@type}&find_user_by_name=1"

    restURL: ->
      "/rest/users/#{@username}/guides"

  Vacaybug.GuideCollection = GuideCollection
