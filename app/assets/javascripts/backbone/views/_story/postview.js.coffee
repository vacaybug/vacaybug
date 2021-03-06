jQuery ->
  class StoryPostView extends window.Vacaybug.StoryView
    template: JST["backbone/templates/story/post"]
    className: 'timeline-block'

    events:
      'click .js-like': 'like'
      'click .js-show-likes': 'showLikes'
      'click .js-show-comments': 'showComments'
      'click .js-delete-story' : 'deleteStory'
      'keydown .comment-form input': 'addComment'

    initialize: (options) ->
      @listenTo @model, 'sync', @render
      @listenTo @model, 'change', @render

    render: ->
      return @ unless @model.sync_status

      if !@comments
        @comments = new Vacaybug.CommentsCollection(@model.get('comments_preview'))
        @listenTo @comments, 'add', @renderComments
        @listenTo @model, 'comment_added', (data) =>
          @comments.add(data.comment)
          $('.newsfeed-items').masonry()

      $(@el).html @template
        model: @model

      @renderComments()
      @

    deleteStory: ->
      if confirm('Are you sure you want to delete this story?')
        @model.destroy()
        $(".newsfeed-items").masonry("remove", @el)
        $(".newsfeed-items").masonry("layout")

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.StoryPostView = StoryPostView
