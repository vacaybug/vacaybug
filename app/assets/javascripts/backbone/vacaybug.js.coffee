$(document).ready ->
  if window.Vacaybug
    Vacaybug.start = ->
      $('a.backbone').click (e) =>
        e.preventDefault()
        # e.stopPropagation()
        Vacaybug.router.navigate($(e.currentTarget).attr('href'), true)

      if Vacaybug.PREFETCH_DATA && Vacaybug.PREFETCH_DATA.current_user
        Vacaybug.current_user = new Vacaybug.UserModel(Vacaybug.PREFETCH_DATA.current_user)

      Vacaybug.appView = new Vacaybug.AppView
      Vacaybug.router = new Vacaybug.Router
      if !Backbone.History.started
        Backbone.history.start
          pushState: true

