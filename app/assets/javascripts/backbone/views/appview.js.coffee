jQuery ->
  class AppView extends window.Vacaybug.GenericView
    el: '#wrapper'
    
    events:
      'click a.backbone': 'navigate'

    initialize: ->

    # if you did something special for
    # some view, it is best place to free it up
    # for other views
    beforeNavigate: ->
      $('#wrapper').removeClass('search-container')
      $('')

    bindEvents: ->
      $(".js-top-search").keydown(@_searchKeyDown)
      $('.search-result-navbar').remove()

    setView: (view) ->
      $(@el).addClass('container')
      @view = view

      if @view instanceof Vacaybug.GuideView
        $(@el).removeClass('container')
      @render()

    render: ->
      @beforeNavigate()
      $(@el).html(@view.render().el)
      @bindEvents()

    navigate: (e) ->
      e.preventDefault()
      e.stopPropagation()

      Vacaybug.router.navigate($(e.currentTarget).attr('href'), true)

    _searchKeyDown: (e) ->
      if (e.keycode || e.which) == 13
        query = $('.js-top-search input').val()
        console.log(query)
        if query
          Vacaybug.router.navigate("/search/#{query}", true)

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.AppView = AppView
