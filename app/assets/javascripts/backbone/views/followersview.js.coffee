jQuery ->
  class FollowersView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/followers"]

    initialize: (options) ->
      @listenTo @collection, 'sync', @render

    render: ->
      if @collection.sync_status
        $(@el).html @template
          collection: @collection

        _.each @collection.models, (model) =>
          itemView = new Vacaybug.FollowersItemView
            model: model

          $(".timeline").append(itemView.render().el)

        new Masonry(document.querySelector('.timeline'), {columnWidth: 130,itemSelector: '.timeline-block'});
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.FollowersView = FollowersView
