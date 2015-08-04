jQuery ->
  class SearchResultView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/search-result"]
    className: 'row search-result'

    events:
      'click .js-guide-item': '_openModal'

    initialize: (options) ->
      @listenTo @collection, 'sync', @render
      @key = 'popular'

    remove: ->
      $('.search-result-navbar').remove()
      super()

    _openModal: (e) ->
      guide_id = $(e.currentTarget).attr('data-id')
      modal = new Vacaybug.GuideModalView
        guide: @collection.where({id: parseInt(guide_id)})[0]
      modal.render()

    renderNavBar: ->
      return if @navBarRendered
      @navBarRendered = true

      html = '
        <div class="navbar-sort search-result-navbar">
          <div class="col-md-6 col-md-offset-3 col-xs-12">
            <div class="btn-group" role="group" aria-label="...">
              <button type="button" class="js-search-key btn active" data-key="popular">Popular</button>
              <button type="button" class="js-search-key btn" data-key="recent">Recent</button>
<!--               <button type="button" class="js-search-key btn active" data-key="popular">Guides</button>
              <button type="button" class="js-search-key btn" data-key="recent">Places</button> -->
            </div>
          </div>
        </div>
      '
      $(html).insertBefore($('#wrapper'))
      $('.js-search-key').on 'click', (event) =>
        key = $(event.currentTarget).attr('data-key')
        @key = key
        $('.js-search-key').removeClass('active')
        $(".js-search-key[data-key=#{key}]").addClass('active')
        @collection.key = key
        @collection.fetch()

    render: ->
      return @ if !@collection.sync_status

      $(@el).html @template
        collection: @collection

      view = new Vacaybug.GuidesView
        collection: @collection
        where: 'search'
      view.setElement(@$('.guides-container')).render()

      @renderNavBar()
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.SearchResultView = SearchResultView
