jQuery ->
  class AppView extends window.Vacaybug.GenericView
    el: '#wrapper'
    
    events:
      'click a.backbone': 'navigate'

    initialize: ->
      $(".js-top-search input").typeahead(
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

    # if you did something special for
    # some view, it is best place to free it up
    # for other views

    setView: (view) ->
      @old_view = @view
      @old_view.remove() if @old_view

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
