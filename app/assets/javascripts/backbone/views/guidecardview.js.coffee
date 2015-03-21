jQuery ->
  class GuideCardView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/guide-card"]

    events:
      'click .js-like': 'like'
      'click .js-show-likes': 'showLikes'

    initialize: (options) ->
      @listenTo @model, 'change', @render

    render: ->
      return @ unless @model.sync_status

      $(@el).html @template
        model: @model
      @

    like: (e) ->
      e.preventDefault()
      e.stopPropagation()
      $.ajax
        url: "/rest/likes/like_guide?guide_id=#{@model.get('id')}"
        success: (response) =>
          if response.status
            likes_count = @model.get('likes_count')
            @model.set('likes_count', likes_count + response.change)
            @model.save()

    showLikes: (e) ->
      modal = new Vacaybug.LikeModalView({guide_id: @model.get('id')})
      modal.render()

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.GuideCardView = GuideCardView
