jQuery ->
  class Router extends Backbone.Router
    routes:
      "somepage": "somePage"
    
    initialize: ->

    somePage: ->
      

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.Router = Router
