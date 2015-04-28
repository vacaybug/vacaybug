jQuery ->
  class Router extends Backbone.Router
    routes:
      "discover": "discover"
      "search": "search"

      "newsfeed": "newsfeed"

      "profile": "my_profile"

      # Profile routes
      ":user": "profile"

      ":user/follower": "follower"
      ":user/following": "following"

      ":user/guides/:id": "guide"

      "*notFound": "notFound"

    initialize: ->

    show404: ->
      $("body").html("Not found")

    profile: (user) ->
      model = new Vacaybug.UserModel({username: user})
      model.fetch
        success: =>
          view = new Vacaybug.ProfileView
            model: model
          Vacaybug.appView.setView(view)
          Vacaybug.appView.setNavbarTab('profile')
        error: =>
          @show404()

    follower: (user) ->
      user ||= Vacaybug.current_user.get('username') if Vacaybug.current_user

      if user
        model = new Vacaybug.UserModel({username: user})
        model.fetch()

        collection = new Vacaybug.FollowersCollection()
        collection.setUsername(user)
        collection.fetch()

        view = new Vacaybug.FollowersView
          collection: collection
          model: model

        Vacaybug.appView.setView(view)
      else
        @show404()

    following: (user) ->
      user ||= Vacaybug.current_user.get('username') if Vacaybug.current_user

      if user
        model = new Vacaybug.UserModel({username: user})
        model.fetch()

        collection = new Vacaybug.FollowersCollection()
        collection.setType('following')
        collection.setUsername(user)
        collection.fetch()

        view = new Vacaybug.FollowersView
          collection: collection
          model: model

        Vacaybug.appView.setView(view)
      else
        @show404()

    guide: (user, id) ->
      guide = new Vacaybug.GuideModel
        id: id
      guide.fetch
        error: =>
          @show404()

      view = new Vacaybug.GuideView
        model: guide

      Vacaybug.appView.setView(view)

    search: ->
      geonames_id = $.getParameterByName('id')
      query = $.getParameterByName('query')

      collection = new Vacaybug.SearchResultCollection({query: query, id: geonames_id})
      collection.fetch()

      view = new Vacaybug.SearchResultView({collection: collection})
      Vacaybug.appView.setView(view)
      Vacaybug.appView.setNavbarTab('search')

    discover: ->
      collection = new Vacaybug.FamousGuideCollection()
      collection.fetch()

      view = new Vacaybug.DiscoverView
        collection: collection
      Vacaybug.appView.setView(view)
      Vacaybug.appView.setNavbarTab('search')

    newsfeed: ->
      collection = new Vacaybug.NewsfeedStoryCollection()
      collection.fetch()
      view = new Vacaybug.NewsfeedView({collection: collection})

      Vacaybug.appView.setView(view)
      Vacaybug.appView.setNavbarTab('newsfeed')

    notFound: ->
      @show404()

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.Router = Router
