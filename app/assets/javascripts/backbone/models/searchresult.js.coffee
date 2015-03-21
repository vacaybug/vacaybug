jQuery ->
  Vacaybug = window.Vacaybug ? {}

  class SearchResultCollection extends window.Vacaybug.GenericCollection
    model: window.Vacaybug.GuideModel

    restURL: ->
    	"/rest/search"

    queryParams: ->
    	"#{super()}&query=#{encodeURIComponent(@query)}&id=#{@id}&key=#{@key}"

    initialize: (options) ->
      @key = 'popular'
      @query = options.query
      @id = options.id
      super(options)

  Vacaybug.SearchResultCollection = SearchResultCollection
