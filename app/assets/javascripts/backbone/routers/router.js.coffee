jQuery ->
  class Router extends Backbone.Router
    routes:
      # Profile routes
      "users/:user": "profile"
      "profile": "my_profile"

      "users/:user/follower": "follower"
      "users/:user/following": "following"

      "users/:user/guides/:id": "guide"
      "guides/:id": "guide"

      # "*notFound": "notFound"
    
    initialize: ->

    show404: ->
      $("body").html("Not found")
      alert('Found nothing brotha')

    profile: (user) ->
      model = new Vacaybug.UserModel({username: user})
      model.fetch()

      view = new Vacaybug.ProfileView
        model: model
      Vacaybug.appView.setView(view)

    my_profile: ->
      if Vacaybug.current_user
        @profile(Vacaybug.current_user.get('username'))
      else
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
        username: user
      guide.fetch
        error: =>
          @show404()

      view = new Vacaybug.GuideView
        model: guide

      Vacaybug.appView.setView(view)

    guide: (user, id) ->
      guide = new Vacaybug.GuideModel
        id: id
        username: user
      guide.fetch
        error: =>
          @show404()

      view = new Vacaybug.GuideView
        model: guide

      Vacaybug.appView.setView(view)

    notFound: ->
      @show404()

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.Router = Router
