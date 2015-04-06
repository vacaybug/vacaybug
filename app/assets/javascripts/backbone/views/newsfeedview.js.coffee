jQuery ->
  class NewsfeedView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/newsfeed"]
    className: "newsfeed-container"

    initialize: (options) ->
      @listenTo @collection, 'sync', @render

    render: ->
      return @ unless @collection.sync_status

      $(@el).html @template
        collection: @collection

      _.each @collection.models, (model) =>
        itemView = new Vacaybug.StoryView({model: model})
        $(@el).append itemView.render().el

      $(".newsfeed-container").imagesLoaded () =>
        $(".newsfeed-container").masonry
          itemSelector: '.timeline-block'
          isFitWidth: true
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.NewsfeedView = NewsfeedView
