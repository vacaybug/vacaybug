jQuery ->
  class GuidesView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/guides"]

    initialize: (options) ->
      @where = options.where

      @listenTo @collection, 'sync', @render
      @listenTo @collection, 'add', @render
      @listenTo @collection, 'remove', @render

    render: ->
      return @ unless @collection.sync_status

      $(@el).html @template
        collection: @collection

      _.each @collection.models, (@model) =>
        container = @$(".guide-card-container[data-id=#{@model.get('id')}]")[0]
        view = new Vacaybug.GuideCardView
          model: @model
          where: @where
        view.setElement(container).render()
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.GuidesView = GuidesView
