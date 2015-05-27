jQuery ->
  class MembersView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/members"]

    initialize: (options) ->
      @listenTo @collection, 'sync', @render

    render: ->
      if @collection.sync_status
        if @collection.page > @collection.total_pages
          return Vacaybug.show404()

        $(@el).html @template
          collection: @collection

        _.each @collection.models, (model) =>
          itemView = new Vacaybug.FollowersItemView
            model: model

          @$(".timeline").append(itemView.render().el)

        @$(".timeline").masonry
          itemSelector: '.timeline-block'
          isFitWidth: true
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.MembersView = MembersView
