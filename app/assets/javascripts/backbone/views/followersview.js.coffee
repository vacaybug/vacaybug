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
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.FollowersView = FollowersView
