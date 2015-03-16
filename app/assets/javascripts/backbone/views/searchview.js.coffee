jQuery ->
  class SearchView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/search"]
    className: 'row'

    events:
      'keydown .js-searchbar': 'keydown'

    initialize: (options) ->

    search: (input) ->
      return if !input

    keydown: (e) ->
      if (e.keyCode || e.which) == 13
        @search($('.js-searchbar').val())

    render: ->
      $(@el).html @template
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.SearchView = SearchView
