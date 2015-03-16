jQuery ->
  class SearchResultView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/search-result"]
    className: 'row search-result'

    events:
      'keydown .js-searchbar': 'keydown'
      'click .js-guide-item': '_openModal'

    initialize: (options) ->
      @listenTo @collection, 'sync', @render

    _openModal: (e) ->
      guide_id = $(e.currentTarget).attr('data-id')
      modal = new Vacaybug.GuideModalView
        guide: @collection.where({id: parseInt(guide_id)})[0]
      modal.render()

    renderNavBar: ->
      html = '
        <div class="row navbar-sort search-result-navbar">
          <div class="col-md-6 col-lg-offset-3 col-sm-6 col-sm-offset-3">
            <div class="btn-group" role="group" aria-label="...">
              <button type="button" class="btn active">Popular</button>
              <button type="button" class="btn">Relevant</button>
              <button type="button" class="btn">Recent</button>
            </div>
          </div>
        </div>
      '
      $(html).insertBefore($('#wrapper'))

    render: ->
      return @ if !@collection.sync_status

      $(@el).html @template
        collection: @collection
      @renderNavBar()
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.SearchResultView = SearchResultView
