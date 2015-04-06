jQuery ->
  class CommentModalView extends window.Vacaybug.GenericView
    template: JST['backbone/templates/modals/comment-modal']

    events:
      'click .js-more': 'seeMore'

    initialize: (options) ->
      @modalRendered = false

      @collection = new Vacaybug.CommentsCollection()
      @collection.setStoryId(options.story_id)
      @collection.fetch()

      @listenTo @collection, 'sync', @render

    getTitle: ->
      if @collection.models.length == 0
        "Be the first one to comment on this story!"
      else if @collection.models.length == 1
        "1 comment on this post"
      else
        "#{@collection.total_count} comments on this post"

    renderModal: ->
      id = Math.floor((Math.random() * 10000000) + 1);
      $('body').append("<div id='#{id}'></div>")
      @setElement($("##{id}"))
      @modalRendered = true

    render: ->
      @renderModal() if !@modalRendered
      return if !@collection.sync_status

      $(@el).html @template
        collection: @collection
        title: @getTitle()

      _.each @collection.models, (model) =>
        view = new Vacaybug.CommentModalItemView({model: model})
        view.setElement(@$(".item[data-id=#{model.get('id')}]")).render()

      @$('.modal').modal('show')
      @

    seeMore: ->
      newCollection = new Vacaybug.CommentsCollection()
      newCollection.setStoryId(@collection.story_id)
      newCollection.next_offset = @collection.next_offset
      newCollection.fetch
        success: (c) =>
          _.each c.models, (model) =>
            @collection.add(model)
            @$('.comments').append("<li class='item' data-id='#{model.get('id')}'></li>")
            view = new Vacaybug.CommentModalItemView({model: model})
            view.setElement(@$(".item[data-id=#{model.get('id')}]")).render()

          @collection.has_more = c.has_more
          @collection.next_offset = c.next_offset
          if !@collection.has_more
            @$('.js-more').remove()

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.CommentModalView = CommentModalView
