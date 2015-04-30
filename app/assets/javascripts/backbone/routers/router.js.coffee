jQuery ->
  class Router extends Backbone.Router
    routes:
      "discover": "discover"
      "search": "search"
      "newsfeed": "newsfeed"
      "friends": "friends"

      ":user": "profile"
      ":user/followers": "followers"
      ":user/following": "following"
      ":user/guides/:id": "guide"

      "*notFound": "notFound"

    initialize: ->

    show404: ->
      view = new Vacaybug.NotFoundView()
      Vacaybug.appView.setView(view, "Not found")

    profile: (user) ->
      model = new Vacaybug.UserModel({username: user})
      model.fetch
        success: =>
          view = new Vacaybug.ProfileView
            model: model
          Vacaybug.appView.setView(view, "Profile")
          Vacaybug.appView.setNavbarTab('profile')
        error: =>
          @show404()

    friends: ->
      collection = new Vacaybug.FollowersCollection
        types: ["followers", "following", "recommended"]
      collection.setUsername(Vacaybug.current_user.get('username'))
      collection.fetch()

      view = new Vacaybug.FollowersView
        collection: collection
        types: {followers: true, following: true, recommended: true}

      Vacaybug.appView.setView(view, "Friends")
      Vacaybug.appView.setNavbarTab('friends')

    followers: (user) ->
      if user
        collection = new Vacaybug.FollowersCollection
          types: ["followers", "recommended"]
        collection.setUsername(user)
        collection.fetch()

        view = new Vacaybug.FollowersView
          collection: collection
          types: {followers: true, recommended: true}

        Vacaybug.appView.setView(view, "Network")
      else
        @show404()

    following: (user) ->
      if user
        collection = new Vacaybug.FollowersCollection
          types: ["following", "recommended"]
        collection.setUsername(user)
        collection.fetch()

        view = new Vacaybug.FollowersView
          collection: collection
          types: {following: true, recommended: true}

        Vacaybug.appView.setView(view, "Network")
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

      Vacaybug.appView.setView(view, "Guide")

    search: ->
      geonames_id = $.getParameterByName('id')
      query = $.getParameterByName('query')

      collection = new Vacaybug.SearchResultCollection({query: query, id: geonames_id})
      collection.fetch()

      view = new Vacaybug.SearchResultView({collection: collection})
      Vacaybug.appView.setView(view, "Search")
      Vacaybug.appView.setNavbarTab('search')

    discover: ->
      collection = new Vacaybug.FamousGuideCollection()
      collection.fetch()

      view = new Vacaybug.DiscoverView
        collection: collection
      Vacaybug.appView.setView(view, "Discover")
      Vacaybug.appView.setNavbarTab('search')

    newsfeed: ->
      collection = new Vacaybug.NewsfeedStoryCollection()
      collection.fetch()
      view = new Vacaybug.NewsfeedView({collection: collection})

      Vacaybug.appView.setView(view, "Newsfeed")
      Vacaybug.appView.setNavbarTab('newsfeed')

    notFound: ->
      @show404()

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.Router = Router
