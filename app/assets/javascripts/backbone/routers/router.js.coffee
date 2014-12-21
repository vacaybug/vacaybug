jQuery ->
  class Router extends Backbone.Router
    routes:
      "user/:user": "profile"
    
    initialize: ->

    profile: (user) ->
      model = new Vacaybug.UserModel({username: user})
      model.fetch()

      view = new Vacaybug.ProfileView
        model: model
      Vacaybug.appView.setView(view)

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.Router = Router
