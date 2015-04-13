jQuery ->
  class NewsfeedView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/newsfeed"]
    className: "newsfeed-container"

    events:
      'click .js-post': 'postStatus'

    initialize: (options) ->
      @listenTo @collection, 'sync', @render

    addStory: (story) ->
      itemView = new Vacaybug.StoryView({model: story})
      $(".newsfeed.share").parent().after(itemView.render().el)
      $(".newsfeed-container").masonry("reloadItems")
      $(".newsfeed-container").masonry()

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

    postStatus: (e) ->
      elem = $(e.currentTarget)
      content = @$(".js-status").val()
      data = {
        raw_content: content
      }

      if content.length > 0
        elem.html("Posting&hellip;")
        elem.attr("disabled", "disabled")
        $.ajax
          data: data
          type: 'POST'
          url: "/rest/posts"
          success: (response) =>
            story = new Vacaybug.StoryModel(response.model.data)
            story.sync_status = true
            @addStory(story)
            @$(".js-status").val("")

            elem.html("Post")
            elem.removeAttr("disabled")
          error: (response) =>
            Vacaybug.flash_message({type: 'alert'})
            elem.html("Post")
            elem.removeAttr("disabled")

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.NewsfeedView = NewsfeedView
