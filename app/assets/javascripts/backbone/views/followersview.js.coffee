jQuery ->
  class FollowersView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/followers"]

    initialize: (options) ->
      @listenTo @collection, 'sync', @render
      @types = options.types

    render: ->
      if @collection.sync_status
        $(@el).html @template
          collection: @collection
          user: @collection.user
          types: @types
          count: @collection.length
        console.log(@collection.length)

        _.each @collection._models, (model) =>
          itemView = new Vacaybug.FollowersItemView
            model: model

          if model.get('type') == 'follower'
            @$(".timeline.followers").append(itemView.render().el)
          else if model.get('type') == 'following'
            @$(".timeline.following").append(itemView.render().el)

        @$(".timeline.following").masonry
          itemSelector: '.timeline-block'
          isFitWidth: true
        @$(".timeline.followers").masonry
          itemSelector: '.timeline-block'
          isFitWidth: true
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.FollowersView = FollowersView
