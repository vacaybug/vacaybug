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
      $('body').append("<div id='somecrazymodal'></div>")
      @setElement($('#somecrazymodal'))
      @modalRendered = true

    render: ->
      @renderModal() if !@modalRendered
      return @ if !@places.sync_status

      $(@el).html @template
        places: @places
        guide: @guide

      @$('.modal').modal('show')
      @$('.modal').on 'hidden.bs.modal', =>
        @remove()
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.GuideModalView = GuideModalView
