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

    follow: ->
      $.ajax
        url: "/rest/users/#{@get('id')}/follow"
        type: 'PUT'
        success: (data) =>
          @set({follows: true})

    unfollow: ->
      $.ajax
        url: "/rest/users/#{@get('id')}/unfollow"
        type: 'PUT'
        success: (data) =>
          @set({follows: false})

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.UserModel = UserModel
