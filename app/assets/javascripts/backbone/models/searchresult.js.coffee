jQuery ->
  Vacaybug = window.Vacaybug ? {}

  class SearchResultCollection extends window.Vacaybug.GenericCollection
    model: window.Vacaybug.GuideModel

    restURL: ->
    	"/rest/search/search"

    queryParams: ->
    	"#{super()}&query=#{encodeURIComponent(@query)}&id=#{@id}&key=#{@key}"

    initialize: (options) ->
      @key = 'popular'
      @query = options.query
      @id = options.id
      super(options)

  Vacaybug.SearchResultCollection = SearchResultCollection

  class FamousGuideCollection extends window.Vacaybug.GenericCollection
    restURL: ->
      "/rest/search/famous"

    parse: (resp, options) ->
      @most_commented = _.map resp.most_commented, (model) -> new Vacaybug.GuideModel(model)
      @most_liked = _.map resp.most_liked, (model) -> new Vacaybug.GuideModel(model)
      super(resp, options)

  Vacaybug.FamousGuideCollection = FamousGuideCollection
