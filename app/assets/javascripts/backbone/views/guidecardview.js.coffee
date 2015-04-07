jQuery ->
  class GuideCardView extends window.Vacaybug.StoryView
    template: JST["backbone/templates/guide-card"]

    events:
      'click .js-like': 'like'
      'click .js-show-likes': 'showLikes'
      'click .js-show-comments': 'showComments'

    initialize: (options) ->
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

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.GuideCardView = GuideCardView
