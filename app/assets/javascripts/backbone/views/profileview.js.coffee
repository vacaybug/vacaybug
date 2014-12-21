jQuery ->
  class ProfileView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/profile"]

    initialize: (options) ->
      @listenTo @model, 'sync', @render

    render: ->
      if @model.sync_status
        $(@el).html @template
          model: @model.toJSON()
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.ProfileView = ProfileView
