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
      "/rest/users/#{@username}/followers"

    queryParams: ->
      "#{super()}&find_user_by_name=1&types=#{@types.join(",")}"

    initialize: (options) ->
      @types = options.types

    setUsername: (@username) ->

    setTypes: (@types) ->

    parse: (resp, options) ->
      @user = new Vacaybug.UserModel(resp.user)
      @_models = []
      _.each resp.models, (model) =>
        userModel = new Vacaybug.UserModel(model)
        userModel.sync_status = true
        @_models.push(userModel)
      super(resp, options)

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

  class AllUsersCollection extends window.Vacaybug.GenericCollection
      model: Vacaybug.UserModel

      restURL: ->
        "/rest/users"

      queryParams: ->
        "#{super()}&page=#{@page}"

      initialize: (options) ->
        @page = options.page || 1

      parse: (resp, options) ->
        @total_pages = resp.total_pages
        super(resp, options)

  Vacaybug.AllUsersCollection = AllUsersCollection
