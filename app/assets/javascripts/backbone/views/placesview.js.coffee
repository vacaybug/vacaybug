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
      @isPrivate = options.isPrivate

    initInputs: ->
      return if !@isPrivate
      _.each @collection.models, (model) =>
        $(".guide-caption[data-id=#{model.get('id')}] .guide-caption-div").editable (value, settings) =>
          model.set('note', value)
          model.save(null, {silent: true})
          value
        , {
          type    : 'textarea',
          submit  : '<button type="submit" class="btn-none"><i class="fa fa-check"></i> Save</button>',
          cancel  : '<button class="btn-none"><i class="fa fa-times"></i> Cancel</button>',
          maxlength: 155,
          onblur  : 'ignore',
        }

    deleteGuide: (e) ->
      if (confirm('Are you sure you want to delete this place?'))
        place_id = $(e.currentTarget).attr('data-id')
        model = @collection.where({id: parseInt(place_id)})[0]
        order = model.get('order_num')
        model.destroy
          success: =>
            _.each @collection.models, (model) =>
              if model.get('order_num') > order
                new_order = model.get('order_num') - 1
                model.set('order_num', new_order)

    rearrange: ->
      new_order = {}
      _.each $(".places-container").children(), (place, index) =>
        assoc_id = $(place).attr('data-assoc-id')
        new_order[assoc_id] = index + 1
      data = {new_order: new_order}

      $.ajax
        url: "/rest/guides/#{@collection.guide_id}/places/rearrange"
        type: "POST"
        data: data

      _.each @collection.models, (model) =>
        model.set('order_num', new_order[model.get('assoc_id')], {silent: true})
      @collection.sort()
      @collection.trigger('change')

    render: ->
      return @ unless @collection.sync_status

      $(@el).html @template
        collection: @collection
        isPrivate: @isPrivate

      $(".places-container").trigger("ss-destroy")
      $(".places-container").unbind("ss-rearranged")
      $(".places-container").shapeshift()
      $(".places-container").on "ss-rearranged", () =>
        @rearrange()

      @initInputs()
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.PlacesView = PlacesView
