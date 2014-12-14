$(document).ready ->
  Vacaybug = window.Vacaybug
  Vacaybug.router = new Vacaybug.Router
  Backbone.history.start
    pushState: true
