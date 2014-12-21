jQuery ->
  class UserModel extends window.Vacaybug.GenericModel
    restURL: ->
      if @get('id')
        "/rest/users/#{@get('id')}"
      else if @get('username')
        "/rest/users/#{@get('username')}"
      else
        "/rest/users"

    initialize: ->

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.UserModel = UserModel
