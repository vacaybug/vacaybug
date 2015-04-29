jQuery ->
  class UserModel extends window.Vacaybug.GenericModel
    restURL: ->
      if @get('id')
        "/rest/users/#{@get('id')}"
      else
        if @get('username')
          "/rest/users/#{@get('username')}"
        else
          "/rest/users/"

    queryParams: ->
      if !@get('id') && @get('username')
        "#{super()}&find_user_by_name=1"
      else
        "#{super()}"

    initialize: ->

    follow: ->
      $.ajax
        url: "/rest/users/#{@get('id')}/follow"
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
        url: "/rest/users/#{@get('id')}/unfollow"
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

    queryParams: ->
      "#{super()}&find_user_by_name=1"

    initialize: ->
      @type = 'followers'

    setUsername: (@username) ->

    setType: (@type) ->

  Vacaybug.FollowersCollection = FollowersCollection

  class LikedPeopleCollection extends window.Vacaybug.GenericCollection
    model: Vacaybug.UserModel

    restURL: ->
      "/rest/stories/#{@story_id}/people_liked"

    queryParams: ->
      "#{super()}&offset=#{@next_offset || 0}"

    setStoryId: (@story_id) ->

    parse: (resp, options) ->
      @has_more = resp.has_more
      @next_offset = resp.next_offset
      super(resp, options)

  Vacaybug.LikedPeopleCollection = LikedPeopleCollection
