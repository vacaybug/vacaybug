jQuery ->
  class StoryGuideView extends window.Vacaybug.StoryView
    template: JST["backbone/templates/story/guide"]
    className: "timeline-block"

    events:
      'click .js-like': 'like'
      'click .js-show-likes': 'showLikes'
      'click .js-show-comments': 'showComments'
      'keydown .comment-form input': 'addComment'

    initialize: (options) ->
      @listenTo @model, 'sync', @render
      @listenTo @model, 'change', @render

    getViewLikesLink: ->
      if @model.get('likes_count') > 0
        if @model.get('likes_count') == 1
          text = 'View 1 like'
        else
          text = "View #{@model.get('likes_count')} likes"
        "<a class='js-show-likes cursor-pointer margin-left-10'>#{text}</a>"
      else
        ""

    getViewCommentsLink: ->
      if @model.get('comments_count') > 3
        "<a class='js-show-comments cursor-pointer margin-left-25'>View #{@model.get('comments_count')} comments</a>"
      else
        ""

    renderComments: ->
      @$(".comments").html('')

      html = @getViewLikesLink() + @getViewCommentsLink()
      if html.length > 0
        @$('.comments').append($("<li>#{html}</li>"))

      _.each @comments.models.slice(Math.max(@comments.models.length - 3, 0)), (comment) =>
        html = $("
          <li>
            <div class='media'>
                <a href='#{comment.get('user').username}' class='pull-left backbone'>
                    <img src='#{comment.get('user').avatar.thumb}' class='media-object avatar-thumb'>
                </a>
                <div class='media-body'>
                    <a href='/#{comment.get('user').username}' class='backbone comment-author'>#{_.escape(comment.get('user').full_name)}</a>
                    <span class='comment-content'>#{comment.get('text')}</span>
                    <div class='comment-date'>#{$.timeago(comment.get('created_at'))}</div>
                </div>
            </div>
          </li>")
        @$('.comments').append(html)

      html = $("
        <li class='comment-form'>
          <input type='text' class='form-control' placeholder='Write a comment...'' />
        </li>")
      @$('.comments').append(html)

    render: ->
      return @ unless @model.sync_status

      if !@comments
        @comments = new Vacaybug.CommentsCollection(@model.get('comments_preview'))
        @listenTo @comments, 'add', @renderComments
        @listenTo @model, 'comment_added', (data) =>
          @comments.add(data.comment)
          $('.newsfeed-container').masonry()

      $(@el).html @template
        model: @model

      @renderComments()
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

    addComment: (e) ->
      text = @$(".comment-form input").val()
      if (e.keyCode || e.which) == 13
        @model.addComment(text)

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.StoryGuideView = StoryGuideView
