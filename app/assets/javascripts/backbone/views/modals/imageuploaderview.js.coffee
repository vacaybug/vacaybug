jQuery ->
  class ImageUploaderModalView extends window.Vacaybug.GenericView
    template: JST['backbone/templates/modals/image-uploader-modal']

    events:
      'click .js-upload-url': 'uploadFromURL'

    remove: ->
      @$('.modal').modal('hide')

    initialize: (options) ->
      @modalRendered = false

    disable: ->
      @$(".js-upload-url").attr("disabled", "disabled")
      @$(".js-upload-computer").attr("disabled", "disabled")

    enable: ->
      @$(".js-upload-url").removeAttr("disabled")
      @$(".js-upload-computer").removeAttr("disabled")

    uploadStarted: ->
      @disable()
      @$(".upload-info").show()

    uploadDone: (image) ->
      @trigger('done', {data: image})
      @remove()

    uploadFailed: ->
      @enable()

    uploadFromURL: (e) ->
      image_url = @$(".js-image-url").val()
      return if image_url.length == 0

      data = {image_url: image_url}
      @uploadStarted()

      $.ajax
        data: data
        type: 'POST'
        url:   '/rest/images/create_from_url'
        success: (response) =>
          @uploadDone(response.model)
        error: =>
          @uploadFailed()

    renderModal: ->
      @id = Math.floor((Math.random() * 10000000) + 1);
      $('body').append("<div id='#{@id}'></div>")
      @setElement($("##{@id}"))
      @modalRendered = true

    render: ->
      @renderModal() if !@modalRendered

      $(@el).html @template
        collection: @collection

      that = @
      @$(".dropzone").dropzone
        init: ->
          @on 'success', (file, response) =>
            that.uploadDone(response.model)
          @on 'addedfile', (file) =>
            that.uploadStarted()
          @on 'error', () =>
           that.uploadFailed()

      @$('.modal').modal('show')
      @$('.modal').on 'hidden.bs.modal', =>
        @remove()
      @

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.ImageUploaderModalView = ImageUploaderModalView
