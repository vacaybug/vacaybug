jQuery ->
  class CommentModalItemView extends window.Vacaybug.GenericView
    template: JST['backbone/templates/modals/comment-modal-item']

    initialize: (options) ->
      @listenTo @model, 'change', @render

    render: ->
      return if !@model.sync_status

      $(@el).html @template
        model: @model
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.CommentModalItemView = CommentModalItemView
