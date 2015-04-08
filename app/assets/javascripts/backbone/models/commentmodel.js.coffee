jQuery ->
  Vacaybug = window.Vacaybug ? {}

  class CommentModel extends window.Vacaybug.GenericModel
    restURL: ->
    	if @get('id')
    		"/rest/stories/#{@get('story_id')}/comments/#{@get('id')}"
    	else
    		"/rest/stories/#{@get('story_id')}/comments"

  Vacaybug.CommentModel = CommentModel

  class CommentsCollection extends window.Vacaybug.GenericCollection
    model: window.Vacaybug.CommentModel

    restURL: ->
      "/rest/stories/#{@story_id}/comments"

    queryParams: ->
      query = "#{super()}"
      query += "&offset=#{@next_offset}" if @next_offset
      query

    setStoryId: (@story_id) ->

    parse: (resp, options) ->
      @has_more = resp.has_more
      @next_offset = resp.next_offset
      @total_count = resp.total_count
      super(resp, options)

  Vacaybug.CommentsCollection = CommentsCollection
