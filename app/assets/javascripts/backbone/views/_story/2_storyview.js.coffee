jQuery ->
  class StoryView extends window.Vacaybug.GenericView
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
          <input type='text' class='form-control' maxlength='300' placeholder='Write a comment...'' />
        </li>")
      @$('.comments').append(html)

    like: (e) ->
      e.preventDefault()
      e.stopPropagation()
      @model.like (count) =>
        @model.set('likes_count', count)
        $('.newsfeed-container').masonry()

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

    render: ->
      return @ unless @model.sync_status

      switch @model.get('story_type')
        when 1
          @view ||= new Vacaybug.StoryGuideView
            model: @model
        when 2
          @view ||= new Vacaybug.StoryPostView
            model: @model

      @view.render()

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.StoryView = StoryView
