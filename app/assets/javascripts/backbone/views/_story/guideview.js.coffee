jQuery ->
  class StoryGuideView extends window.Vacaybug.StoryView
    template: JST["backbone/templates/story/guide"]
    className: "timeline-block"

    events:
      'click .js-like': 'like'
      'click .js-show-likes': 'showLikes'
      'click .js-show-comments': 'showComments'

    initialize: (options) ->
      @listenTo @model, 'sync', @render
      @listenTo @model, 'change', @render

    render: ->
      return @ unless @model.sync_status

      $(@el).html @template
        model: @model
      @

    like: (e) ->
      e.preventDefault()
      e.stopPropagation()
      @model.like (count) =>
        @model.set('likes_count', count)

    showLikes: (e) ->
      e.preventDefault()
      e.stopPropagation()
      @model.showLikes()

    showComments: (e) ->
      @model.showComments()

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.StoryGuideView = StoryGuideView
