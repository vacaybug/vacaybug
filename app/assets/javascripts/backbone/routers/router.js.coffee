jQuery ->
  class Router extends Backbone.Router
    routes:
      # Profile routes
      "users/:user": "profile"
      "profile": "my_profile"
      "profile/edit": "profile_edit"
    
    initialize: ->

    render404: ->


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
        @render404()

    profile_edit: ->
      if Vacaybug.current_user
        view = new Vacaybug.ProfileEditView
          model: Vacaybug.current_user
        Vacaybug.appView.setView(view)
      else
        @render404()

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.Router = Router
