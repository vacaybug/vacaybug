jQuery ->
  class NotFoundView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/not-found"]
    className: 'row'
    isPublic: true

    remove: ->
      $('#wrapper').removeClass('container-fluid error-container')
      $('#wrapper').addClass('container')

    initialize: (options) ->
      $('#wrapper').addClass('container-fluid error-container')
      $('#wrapper').removeClass('container')

    render: ->
      $(@el).html @template
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.NotFoundView = NotFoundView
