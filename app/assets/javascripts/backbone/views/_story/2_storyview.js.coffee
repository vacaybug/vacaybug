jQuery ->
  class StoryView extends window.Vacaybug.GenericView
    initialize: (options) ->
      @listenTo @model, 'sync', @render
      @listenTo @model, 'change', @render

    render: ->
      return @ unless @model.sync_status

      if @model.get('story_type') == 1
        @view = new Vacaybug.StoryGuideView
          model: @model

      @view.render()

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.StoryView = StoryView
