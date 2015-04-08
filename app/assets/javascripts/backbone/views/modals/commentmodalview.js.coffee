jQuery ->
  class CommentModalView extends window.Vacaybug.GenericView
    template: JST['backbone/templates/modals/comment-modal']

    events:
      'click .js-more': 'seeMore'
      'keydown .comment-form input': 'addComment'

    initialize: (options) ->
      @modalRendered = false

      @collection = new Vacaybug.CommentsCollection()
      @collection.setStoryId(options.story_id)
      @collection.fetch()

      @listenTo @collection, 'sync', @render

      @listenTo @model, 'comment_added', (data) =>
        @collection.models.push(data.comment)
        @collection.total_count += 1
        @renderBody()

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

    appendComment: (model) ->
      view = new Vacaybug.CommentModalItemView({model: model})
      item_container = $("<li class='item' data-id='#{model.get('id')}'></li>")
      @$(".comments").append(item_container)
      view.setElement(item_container).render()

    renderBody: ->
      body = @$(".modal-body")
      body.html('')
      if @collection.has_more
        body.append('<p class="text-center"><a class="js-more" href="javascript:void(0)">See more</a></p>')
      body.append('<ul class="comments" style="max-height: 300px; overflow: scroll"></ul>')
      if @collection.models.length == 0
        body.append('<h4 class="text-center js-empty">Be the first one to comment on this story!</h4>')
      body.append('<div class="comment-form"><input type="text" class="form-control" placeholder="Write a comment..." /></div>')

      _.each @collection.models, (model) =>
        @appendComment(model)

    render: ->
      @renderModal() if !@modalRendered
      return if !@collection.sync_status

      $(@el).html @template
        collection: @collection
        title: @getTitle()

      @renderBody()

      @$('.modal').modal('show')
      @

    seeMore: ->
      newCollection = new Vacaybug.CommentsCollection()
      newCollection.setStoryId(@collection.story_id)
      newCollection.next_offset = @collection.next_offset
      newCollection.fetch
        success: (c) =>
          _.each c.models.reverse(), (model) =>
            @collection.add(model, {at: 0})
            @$('.comments').prepend("<li class='item' data-id='#{model.get('id')}'></li>")
            view = new Vacaybug.CommentModalItemView({model: model})
            view.setElement(@$(".item[data-id=#{model.get('id')}]")).render()

          @collection.has_more = c.has_more
          @collection.next_offset = c.next_offset
          if !@collection.has_more
            @$('.js-more').remove()

    addComment: (e) ->
      text = @$(".comment-form input").val()
      if (e.keyCode || e.which) == 13
        @model.addComment(text)

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.CommentModalView = CommentModalView
