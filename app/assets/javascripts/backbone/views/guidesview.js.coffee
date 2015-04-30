jQuery ->
  class GuidesView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/guides"]
    showSpinner: true

    initialize: (options) ->
      @where = options.where
      @profileView = options.profileView
      @type = options.type

      @listenTo @collection, 'sync', @render
      @listenTo @collection, 'remove', @render

    render: ->
      return @ unless @collection.sync_status

      $(@el).html @template
        collection: @collection
        type: @type

      _.each @collection.models, (@model) =>
        container = @$(".guide-card-container[data-id=#{@model.get('id')}]")[0]
        view = new Vacaybug.GuideCardView
          profileView: @profileView
          model: @model
          where: @where
        view.setElement(container).render()
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.GuidesView = GuidesView
