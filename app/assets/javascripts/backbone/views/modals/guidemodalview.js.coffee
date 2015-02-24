jQuery ->
  class GuideModalView extends window.Vacaybug.GenericView
    template: JST['backbone/templates/modals/guide-modal']

    initialize: (options) ->
      @modalRendered = false
      @guide = options.guide
      @places = new Vacaybug.PlaceCollection
        guide_id: @guide.get('id')
      @places.fetch()

      @listenTo @places, 'sync', @render

    renderModal: ->
      $(@el).html @template
        guide: @guide
        place: @places

      $('body').append(@el)
      @$('.modal').modal()
      @modalRendered = true

    render: ->
      @renderModal() if !@modalRendered
      return @ if !@places.sync_status

      $(@el).html @template
        places: @places
        guide: @guide
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.GuideModalView = GuideModalView
