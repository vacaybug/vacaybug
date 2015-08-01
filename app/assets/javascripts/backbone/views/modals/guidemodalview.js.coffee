jQuery ->
  class GuideModalView extends window.Vacaybug.GenericView
    template: JST['backbone/templates/modals/guide-modal']

    removeModal: ->
      @$('.modal').modal('hide')
      @remove()

    initialize: (options) ->
      @modalRendered = false
      @guide = options.guide
      @places = new Vacaybug.PlaceCollection
        guide_id: @guide.get('slug')
      @places.fetch()

      @listenTo @places, 'sync', @render

    renderModal: ->
      $('body').append("<div id='quick-view-modal'></div>")
      @setElement($('#quick-view-modal'))
      @modalRendered = true

    render: ->
      @renderModal() if !@modalRendered
      return @ if !@places.sync_status

      $(@el).html @template
        places: @places
        guide: @guide

      @$('.modal').modal('show')
      @$('.modal').on 'hidden.bs.modal', =>
        @removeModal()
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.GuideModalView = GuideModalView
