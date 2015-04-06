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
      modal = new Vacaybug.CommentModalView({story_id: @get('id')})
      modal.render()

  Vacaybug.StoryModel = StoryModel

  class NewsfeedStoryCollection extends window.Vacaybug.GenericCollection
    model: window.Vacaybug.StoryModel

    restURL: ->
    	"/rest/newsfeed/stories"

  Vacaybug.NewsfeedStoryCollection = NewsfeedStoryCollection
