jQuery ->
  Vacaybug = window.Vacaybug ? {}

  class StoryModel extends window.Vacaybug.GenericModel
    restURL: ->
    	if @get('id')
    		"/rest/stories/#{@get('id')}"
    	else
    		"/rest/stories"

    like: (callback) ->
      $.ajax
        type: 'PUT'
        url: "/rest/stories/#{@get('id')}/like"
        success: (response) =>
          if response.status
            likes_count = @get('likes_count')
            change = response.change
            callback(likes_count + change)

    showLikes: ->
      modal = new Vacaybug.LikeModalView({story_id: @get('id')})
      modal.render()

    showComments: ->
      modal = new Vacaybug.CommentModalView({story_id: @get('id'), model: @})
      modal.render()

    addComment: (text) ->
      return if text == null || text.length == 0
      comment = new Vacaybug.CommentModel({story_id: @get('id'), text: text})
      comment.save null,
        success: =>
          @set('comments_count', @get('comments_count') + 1)
          @trigger('comment_added', {comment: comment})

  Vacaybug.StoryModel = StoryModel

  class NewsfeedStoryCollection extends window.Vacaybug.GenericCollection
    model: window.Vacaybug.StoryModel

    restURL: ->
    	"/rest/newsfeed/stories"

    queryParams: ->
      query = "#{super()}"
      if @next_offset
        query += "&offset=#{@next_offset}"
      query

    parse: (resp, options) ->
      @next_offset = resp.next_offset
      @has_more = resp.has_more
      super(resp, options)

  Vacaybug.NewsfeedStoryCollection = NewsfeedStoryCollection
