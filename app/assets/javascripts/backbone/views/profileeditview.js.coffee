jQuery ->
  class ProfileEditView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/profile-edit"]

    initialize: (options) ->
      @listenTo @model, 'sync', @render
      @listenTo @model, 'change', @render

    render: ->
      $(@el).html @template
        model: @model.toJSON()
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.ProfileEditView = ProfileEditView
