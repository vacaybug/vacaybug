jQuery ->
  class AppView extends window.Vacaybug.GenericView
    el: '#wrapper'
    
    events:
      'click a.backbone': 'navigate'

    initialize: ->

    setView: (view) ->
      $(@el).addClass('container')
      @view = view

      if @view instanceof Vacaybug.GuideView
        $(@el).removeClass('container')
      @render()

    render: ->
      $(@el).html(@view.render().el)

    navigate: (e) ->
      e.preventDefault()
      e.stopPropagation()

      Vacaybug.router.navigate($(e.currentTarget).attr('href'), true)

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.AppView = AppView
