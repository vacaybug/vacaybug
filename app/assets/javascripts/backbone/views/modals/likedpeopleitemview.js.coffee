jQuery ->
  class LikedPeopleItemView extends window.Vacaybug.GenericView
    template: JST['backbone/templates/modals/liked-people-item']

    events:
      'click .js-follow': 'follow'
      'click .js-unfollow': 'unfollow'

    initialize: (options) ->
      @listenTo @model, 'change', @render

    follow: ->
      @model.follow()

    unfollow: ->
      @model.unfollow()

    render: ->
      return if !@model.sync_status

      $(@el).html @template
        model: @model
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.LikedPeopleItemView = LikedPeopleItemView
