jQuery ->
  class DiscoverView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/discover"]
    className: 'row'

    events:
      'keydown .js-searchbar': 'keydown'

    remove: ->
      $('#wrapper').removeClass('search-container')

    initialize: (options) ->
      @listenTo @collection, 'sync', @render
      $('#wrapper').addClass('search-container')

    search: (input) ->
      return if !input
      Vacaybug.router.navigate("/search/#{input}", {trigger: true})

    keydown: (e) ->
      if (e.keyCode || e.which) == 13
        @search($('.js-searchbar').val())

    render: ->
      return @ unless @collection.sync_status

      $(@el).html @template
        most_commented: @collection.most_commented
        most_liked: @collection.most_liked

      $(".discover-searchbar input").typeahead(
        {
          hint: true,
          highlight: true,
          minLength: 3
        },
        {
          displayKey: 'value',
          source: (query, callback) ->
            if (timeout)
              clearTimeout(timeout)

            timeout = setTimeout((->
              matches = []
              $.ajax
                url: "http://api.geonames.org/search?name_startsWith=#{encodeURIComponent(query)}&username=vacaybug&maxRows=10&featureClass=P&order=population&type=json"
                success: (resp) ->
                  matches = []
                  for location in resp.geonames
                    name = location.toponymName
                    name += ", #{location.adminName1}" if location.adminName1 != location.toponymName
                    name += ", #{location.countryName}"
                    matches.push({value: name, data: location})
                  callback(matches)
            ), 300)
        }
      ).bind('typeahead:selected', (event, selected, name) =>
        Vacaybug.router.navigate("/search?query=#{encodeURIComponent(selected.value)}&id=#{selected.data.geonameId}", true)
      )
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.DiscoverView = DiscoverView
