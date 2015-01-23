jQuery ->
  class FollowersItemView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/followers-item"]
    className: "timeline-block"

    events:
      'click .js-follow': 'follow'
      'click .js-unfollow': 'unfollow'

    initialize: (options) ->
      @listenTo @model, 'sync', @render
      @listenTo @model, 'change', @render

    render: ->
      if @model.sync_status
        $(@el).html @template
          model: @model
      @

    follow: ->
      @model.follow()

    unfollow: ->
      @model.unfollow()

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.FollowersItemView = FollowersItemView
