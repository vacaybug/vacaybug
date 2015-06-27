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
        $(".guide-caption[data-assoc-id=#{model.get('assoc_id')}] .guide-caption-div").editable (value, settings) =>
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
        assoc_id = $(e.currentTarget).attr('data-assoc-id')
        model = @collection.where({assoc_id: parseInt(assoc_id)})[0]
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

    shapeshift: ->
      $(".places-container").trigger("ss-destroy")
      $(".places-container").attr("style", "")
      $(".places-container").unbind("ss-rearranged")
      if @collection.models.length > 0
        $(".places-container").shapeshift
          align: "left"
          enableDrag: @isPrivate
          gutterX: 22
        $(".places-container").on "ss-rearranged", () =>
          @rearrange()

    render: ->
      return @ unless @collection.sync_status

      $(@el).html @template
        collection: @collection
        isPrivate: @isPrivate

      @shapeshift()
      @initInputs()
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.PlacesView = PlacesView
