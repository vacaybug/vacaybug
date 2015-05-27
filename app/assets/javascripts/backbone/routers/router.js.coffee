jQuery ->
  class Router extends Backbone.Router
    routes:
      "discover": "discover"
      "search": "search"
      "newsfeed": "newsfeed"
      "members/:page": "members"
      "members": "members"

      ":user": "profile"
      ":user/followers": "followers"
      ":user/following": "following"
      ":user/guides/:id": "guide"

      "*notFound": "notFound"

    initialize: ->

    profile: (user) ->
      model = new Vacaybug.UserModel({username: user})
      model.fetch
        success: =>
          view = new Vacaybug.ProfileView
            model: model
          Vacaybug.appView.setView(view, "Profile")
          Vacaybug.appView.setNavbarTab('profile')
        error: =>
          Vacaybug.show404()

    members: (page=1) ->
      collection = new Vacaybug.AllUsersCollection
        page: page
      collection.fetch()

      view = new Vacaybug.MembersView
        collection: collection

      Vacaybug.appView.setView(view, "Members")
      Vacaybug.appView.setNavbarTab('members')

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
        Vacaybug.show404()

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
        Vacaybug.show404()

    guide: (user, id) ->
      guide = new Vacaybug.GuideModel
        id: id
      guide.fetch
        error: =>
          Vacaybug.show404()

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
      Vacaybug.show404()

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.Router = Router
