jQuery ->
  class GuideCardView extends window.Vacaybug.StoryView
    template: JST["backbone/templates/guide-card"]

    events:
      'click .js-like': 'like'
      'click .js-show-likes': 'showLikes'
      'click .js-show-comments': 'showComments'
      'click .js-passport': 'moveToPassport'
      'click .js-wishlist': 'moveToWishlist'

    initialize: (options) ->
      @profileView = options.profileView
      @where = options.where
      @listenTo @model, 'change', @render

      @story = new Vacaybug.StoryModel(@model.get('story'))
      @story.set('data', @model.attributes)

      @listenTo @story, 'change', @render

    render: ->
      return @ unless @model.sync_status

      $(@el).html @template
        model: @model
        story: @story
        where: @where
      @

    like: (e) ->
      e.preventDefault()
      e.stopPropagation()
      @story.like (count) =>
        @story.set('likes_count', count)
        @render()

    showLikes: (e) ->
      @story.showLikes()

    showComments: (e) ->
      @story.showComments()

    moveToWishlist: (e) ->
      e.stopPropagation()
      @profileView.moveToWishlist(@model)

    moveToPassport: (e) ->
      e.stopPropagation()
      @profileView.moveToPassport(@model)

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.GuideCardView = GuideCardView
