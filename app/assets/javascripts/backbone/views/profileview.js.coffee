jQuery ->
  class ProfileView extends window.Vacaybug.GenericView
    events:
      'click .js-follow': 'follow'
      'click .js-unfollow': 'unfollow'
      'click .js-edit': 'edit'
      'click .js-cancel': 'cancel'
      'click .js-save': 'save'
      'click .js-tab': 'clickTab'
      'click .js-continue': 'createGuide'
      'click .js-guide-item': '_openModal'
      'click .js-change-photo': 'changePhoto'
      'click .js-delete-guide': 'deleteGuide'

    initialize: (options) ->
      @listenTo @model, 'change', @render
      @listenTo @model, 'sync', @render
      @activeTab = 'passport'
      @isPrivate = @model.get('username') == Vacaybug.current_user.get('username')
      @editMode = false

      @guides = new Vacaybug.GuideCollection
        username: @model.get('username')
      @guides.fetch()

      @listenTo @guides, 'sync', @render
      @listenTo @guides, 'change', @render
      @listenTo @guides, 'remove', @render
      @listenTo @guides, 'add', @render

    initializeMap: ->
      return if $('.map-container').length == 0

      mapOptions = {zoom: 5}
      map = new google.maps.Map($('.map-container')[0], mapOptions)
      window.map = map

      if @guides.sync_status
        if @guides.models.length > 0
          bounds = new google.maps.LatLngBounds()
          for guide in @guides.models
            position = new google.maps.LatLng(parseFloat(guide.get('gn_data')['lat']), parseFloat(guide.get('gn_data')['lng']))
            bounds.extend(position)

            marker = new google.maps.Marker
              position: position
              map: map
              icon: "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=|33CCFF|000000"

          map.fitBounds(bounds)
        else
          centerAddress = 'California, United States'
          geocoder = new google.maps.Geocoder();
          geocoder.geocode { 'address': centerAddress }, (results, status) ->
            if status == google.maps.GeocoderStatus.OK
              if status != google.maps.GeocoderStatus.ZERO_RESULTS
                map.setCenter results[0].geometry.location

    _openModal: (e) ->
      guide_id = $(e.currentTarget).attr('data-id')
      modal = new Vacaybug.GuideModalView
        guide: @guides.where({id: parseInt(guide_id)})[0]
      modal.render()

    deleteGuide: (e) ->
      if (confirm('Are you sure you want to delete this guide?'))
        guide_id = $(e.currentTarget).attr('data-id')
        model = @guides.where({id: parseInt(guide_id)})[0]
        model.destroy()

    createGuide: (event) ->
      guide = new Vacaybug.GuideModel
        country:     @selected.data.countryName
        region:      if @selected.data.name != @selected.data.adminName1 then @selected.data.adminName1 else ''
        city:        @selected.data.name
        geonames_id: @selected.data.geonameId
        gn_data:     @selected.data

      elem = $(event.currentTarget)
      elem.attr("disabled", "disabled")
      elem.html("Saving&hellip;")

      guide.save null,
        success: (model, resp) ->
          Vacaybug.router.navigate("/guides/#{guide.get('id')}", true)
        error: ->
          elem.removeAttr("disabled")
          elem.html("Continue")

    render: ->
      return @ unless @model.sync_status

      if @isPrivate
        @template = JST["backbone/templates/profile-private"]
      else
        @template = JST["backbone/templates/profile-public"]

      @birth_year = null
      @birth_date = null
      if @model.get('birthday')
        @date = new Date(@model.get('birthday') + " 00:00:00")
        @birth_year = $.format.date(@date, "yyyy")
        @birth_date = $.format.date(@date, "MMM, dd")

      $(@el).html @template
        model: @model.toJSON()
        guides: @guides
        activeTab: @activeTab
        editMode: @editMode
        birth_year: @birth_year
        birth_date: @birth_date

      @initializeMap()

      $("#fileupload").fileupload(
        url: "/rest/users/upload_photo"
        dataType: "json"
        autoUpload: false
        acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i
        maxFileSize: 5000000

        previewMaxWidth: 100
        previewMaxHeight: 100
      ).on('fileuploadadd', (e, data) =>
        $(".js-select").html('Uploading')
      ).on('fileuploadprocessalways', (e, data) ->
        # TODO: get it work
      ).on('fileuploaddone', (e, data) =>
        @model.set('avatar', data.result.model.avatar)
      )

      $('input.input-birthday').datepicker
        format: "M, dd"

      $('input.input-birthday').datepicker('setDate', @date)

      timeout = null
      $(".typeahead").typeahead(
        {
          hint: true,
          highlight: true,
          minLength: 3
        },
        {
          displayKey: 'value',
          source: (query, callback) ->
            if (timeout)
              clearTimeout(timeout)
            
            timeout = setTimeout((->
              matches = []
              $.ajax
                url: "http://api.geonames.org/search?name_startsWith=#{encodeURIComponent(query)}&username=vacaybug&maxRows=10&featureClass=P&order=population&type=json"
                success: (resp) ->
                  matches = []
                  for location in resp.geonames
                    name = location.toponymName
                    name += ", #{location.adminName1}" if location.adminName1 != location.toponymName
                    name += ", #{location.countryName}"
                    matches.push({value: name, data: location})
                  callback(matches)
            ), 300)
        }
      ).bind('typeahead:selected', (obj, selected, name) =>
        $(".js-continue").removeAttr("disabled")
        @selected = selected
      )

      $(".typeahead").on('input', (event) =>
        $(".js-continue").attr("disabled", "disabled")
      )
      @

    follow: ->
      @model.follow()

    unfollow: ->
      @model.unfollow()

    edit: ->
      @editMode = true
      @render()

    save: ->
      return if @saving

      @saving = true
      $(".js-save").hide()
      $(".js-cancel").hide()
      $(".error-message").remove()
      $(".js-saving").toggleClass('hide')

      copy_model = new Vacaybug.UserModel(_.clone(@model.attributes))

      $('input.profile-field').each (index, elem) =>
        field = $(elem).attr('data-field')
        copy_model.set(field, $(elem).val())

      copy_model.set('birthday', copy_model.get('birth_year') + ' ' + copy_model.get('birth_date'))

      copy_model.save null,
        success: (model, resp) =>
          if resp.status
            Vacaybug.flash_message({text: 'Your profile has been successfully updated'})
            changed_attributes = {}
            $.each copy_model.attributes, (attribute, value) =>
              if value != @model.get(attribute)
                changed_attributes[attribute] = value

            @editMode = false
            @model.set(changed_attributes)
          else
            $('input.profile-field').each (index, elem) ->
              field = $(elem).attr('data-field')

              if resp.errors[field]
                $("<div class='col-sm-offset-4 col-sm-8 text-danger error-message'>#{resp.errors[field][0]}</div>").insertAfter($(elem).parent())

        error: (model, resp) =>
          Vacaybug.flash_message({text: 'There was an error while completing your request. Please try again', type: 'alert'})

        complete: =>
          $(".js-save").show()
          $(".js-cancel").show()

          @saving = false
          @editMode = false
          @render()


    cancel: ->
      return if @saving

      @editMode = false
      @render()

    clickTab: (e) ->
      currentTab = $(e.currentTarget).attr('data-tab')
      @activeTab = currentTab

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.ProfileView = ProfileView
