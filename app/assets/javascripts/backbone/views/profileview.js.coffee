jQuery ->
  class ProfileView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/profile"]

    events:
      'click .js-follow': 'follow'
      'click .js-unfollow': 'unfollow'

    initialize: (options) ->
      @listenTo @model, 'sync', @render
      @listenTo @model, 'change', @render

    render: ->
      if @model.sync_status
        $(@el).html @template
          model: @model.toJSON()
      @

    follow: ->
      @model.follow()

    unfollow: ->
      @model.unfollow()

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.ProfileView = ProfileView
