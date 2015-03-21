jQuery ->
  class UserModel extends window.Vacaybug.GenericModel
    restURL: ->
      if @get('username')
        "/rest/users/#{@get('username')}"
      else
        "/rest/users"

    initialize: ->

    follow: ->
      $.ajax
        url: "/rest/users/#{@get('username')}/follow"
        type: 'PUT'
        success: (resp) =>
          if resp.status
            @set({follows: true})
          else
            Vacaybug.flash_message({text: resp.message, type: 'alert'})
        error: ->
          Vacaybug.flash_message({text: 'There was an error while completing your request. Please try again', type: 'alert'})

    unfollow: ->
      $.ajax
        url: "/rest/users/#{@get('username')}/unfollow"
        type: 'PUT'
        success: (resp) =>
          if resp.status
            @set({follows: false})
          else
            Vacaybug.flash_message({text: resp.message, type: 'alert'})
        error: ->
          Vacaybug.flash_message({text: 'There was an error while completing your request. Please try again', type: 'alert'})

  Vacaybug = window.Vacaybug ? {}  
  Vacaybug.UserModel = UserModel

  class FollowersCollection extends window.Vacaybug.GenericCollection
    model: Vacaybug.UserModel

    restURL: ->
      "/rest/users/#{@username}/#{@type}"

    initialize: ->
      @type = 'followers'

    setUsername: (@username) ->

    setType: (@type) ->

  Vacaybug.FollowersCollection = FollowersCollection

  class LikedPeopleCollection extends window.Vacaybug.GenericCollection
    model: Vacaybug.UserModel

    restURL: ->
      "/rest/guides/#{@guide_id}/people_liked"

    queryParams: ->
      "#{super()}&offset=#{@next_offset}"

    setGuideId: (@guide_id) ->

    parse: (resp, options) ->
      @has_more = resp.has_more
      @next_offset = resp.next_offset
      super(resp, options)

  Vacaybug.LikedPeopleCollection = LikedPeopleCollection
