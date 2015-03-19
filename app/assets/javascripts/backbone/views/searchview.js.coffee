jQuery ->
  class SearchView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/search"]
    className: 'row'

    events:
      'keydown .js-searchbar': 'keydown'

    remove: ->
      $('#wrapper').removeClass('search-container')

    initialize: (options) ->
      $('#wrapper').addClass('search-container')

    search: (input) ->
      return if !input
      Vacaybug.router.navigate("/search/#{input}", {trigger: true})

    keydown: (e) ->
      if (e.keyCode || e.which) == 13
        @search($('.js-searchbar').val())

    render: ->
      $(@el).html @template
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.SearchView = SearchView
