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

    setTitle: (title) ->
      if title && title.length > 0
        document.title = "#{title} | VacayBug"
      else
        document.title = "Vacaybug"

    setView: (view, title="") ->
      $(".navbar-tab").removeClass("active")
      @setTitle(title)

      @old_view = @view
      @old_view.remove() if @old_view

      @view = view
      @render()

    render: ->
      if !Vacaybug.current_user && !@view.isPublic
        window.location = "/login"
      $(@el).html(@view.render().el)

    navigate: (event) ->
      event.preventDefault()
      event.stopPropagation()

      url = $(event.currentTarget).attr('href')

      if (event.ctrlKey || event.shiftKey || event.metaKey || event.which == 2)
        window.open(url, '_blank')
      else
        Vacaybug.router.navigate(url, {trigger: true})

    setNavbarTab: (tab) ->
      $(".navbar-tab").removeClass('active')
      $(".navbar-tab[data-tab=#{tab}]").addClass('active')

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.AppView = AppView
