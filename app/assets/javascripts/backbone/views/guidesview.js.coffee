jQuery ->
  class GuidesView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/guides"]

    initialize: (options) ->
      @isPrivate = options.isPrivate

      @listenTo @collection, 'sync', @render
      @listenTo @collection, 'add', @render
      @listenTo @collection, 'remove', @render

    render: ->
      return @ unless @collection.sync_status

      $(@el).html @template
        collection: @collection
        isPrivate: @isPrivate
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.GuidesView = GuidesView
