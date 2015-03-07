jQuery ->
  class PlacesView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/places"]

    events:
      'click .js-delete-place': 'deleteGuide'

    initialize: (options) ->
      @listenTo @collection, 'sync', @render
      @listenTo @collection, 'change', @render
      @listenTo @collection, 'add', @render
      @listenTo @collection, 'remove', @render

    deleteGuide: (e) ->
      if (confirm('Are you sure you want to delete this place?'))
        place_id = $(e.currentTarget).attr('data-id')
        model = @collection.where({id: parseInt(place_id)})[0]
        order = model.get('order')
        model.destroy
          success: =>
            _.each @collection.models, (model) =>
              if model.get('order') > order
                new_order = model.get('order') - 1
                model.set('order', new_order)

    render: ->
      return @ unless @collection.sync_status

      $(@el).html @template
        collection: @collection
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.PlacesView = PlacesView
