jQuery ->
  class PlacesView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/places"]

    initialize: (options) ->
      @listenTo @collection, 'sync', @render
      @listenTo @collection, 'change', @render
      @listenTo @collection, 'add', @render
      @listenTo @collection, 'remove', @render

    render: ->
      return @ unless @collection.sync_status

      $(@el).html @template
        collection: @collection
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.PlacesView = PlacesView
