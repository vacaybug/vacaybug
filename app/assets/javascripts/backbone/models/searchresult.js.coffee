jQuery ->
  Vacaybug = window.Vacaybug ? {}

  class SearchResultCollection extends window.Vacaybug.GenericCollection
    model: window.Vacaybug.GuideModel

    restURL: ->
    	"/rest/search"

    queryParams: ->
    	"#{super()}&query=#{@query}"

    initialize: (options) ->
      @query = options.query
      super(options)

  Vacaybug.SearchResultCollection = SearchResultCollection
