jQuery ->
  class StoryGuideView extends window.Vacaybug.StoryView
    template: JST["backbone/templates/story/guide"]
    className: 'timeline-block'

    events:
      'click .js-like': 'like'
      'click .js-show-likes': 'showLikes'
      'click .js-show-comments': 'showComments'
      'click .js-passport': 'moveToPassport'
      'click .js-wishlist': 'moveToWishlist'
      'click .js-passport': 'moveToPassport'
      'click .js-save'    : 'copyGuide'
      'click .js-delete-story' : 'deleteStory'
      'keydown .comment-form input': 'addComment'

    initialize: (options) ->
      @listenTo @model, 'change', @render

    render: ->
      return @ unless @model.sync_status

      if !@guide
        @guide = new Vacaybug.GuideModel(@model.get('data'))
        @listenTo @guide, 'change', @render

      if !@comments
        @comments = new Vacaybug.CommentsCollection(@model.get('comments_preview'))
        @listenTo @comments, 'add', @renderComments
        @listenTo @model, 'comment_added', (data) =>
          @comments.add(data.comment)
          $('.newsfeed-items').masonry()

      $(@el).html @template
        model: @model
        guide: @guide

      @renderComments()
      @

    moveToPassport: ->
      @guide.set('guide_type', 1)
      @guide.save()

    moveToWishlist: ->
      @guide.set('guide_type', 2)
      @guide.save()

    copyGuide: ->
      @guide.duplicate()

    deleteStory: ->
      if confirm('Are you sure you want to delete this story? (Your guide will not be deleted)')
        @model.destroy()
        $(".newsfeed-items").masonry("remove", @el)
        $(".newsfeed-items").masonry("layout")

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.StoryGuideView = StoryGuideView
