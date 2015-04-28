jQuery ->
  class ProfileView extends window.Vacaybug.GenericView
    showSpinner: true

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
      'click .trip-type-choice': '_tripTypeClick'

    initialize: (options) ->
      @listenTo @model, 'change', @render
      @listenTo @model, 'sync', @render
      @activeTab = 'passport'
      @editMode = false

      super()

    renderPassport: ->
      if !@passportView
        @passportCollection = new Vacaybug.GuideCollection
          username: @model.get('username')
          type: 'passport'
        @passportCollection.fetch()

        @listenTo @passportCollection, 'remove', @renderMap
        @listenTo @passportCollection, 'add', @renderMap

      @passportView ||= new Vacaybug.GuidesView
        profileView: @
        collection: @passportCollection
        where: 'profile'
      @passportView.setElement($(".passport")[0]).render()

    renderWishlist: ->
      if !@wishlistView
        @wishlistCollection = new Vacaybug.GuideCollection
          username: @model.get('username')
          type: 'wishlist'
        @wishlistCollection.fetch()

      @wishlistView ||= new Vacaybug.GuidesView
        profileView: @
        collection: @wishlistCollection
        where: 'profile'
      @wishlistView.setElement($(".wishlist")[0]).render()

    renderMap: ->
      return if $('.map-container').length == 0

      mapOptions = {zoom: 5}
      map = new google.maps.Map($('.map-container')[0], mapOptions)
      window.map = map

      if @passportCollection && @passportCollection.sync_status
        if @passportCollection.models.length > 1
          bounds = new google.maps.LatLngBounds()
          for guide in @passportCollection.models
            position = new google.maps.LatLng(parseFloat(guide.get('gn_data')['lat']), parseFloat(guide.get('gn_data')['lng']))
            bounds.extend(position)

            marker = new google.maps.Marker
              position: position
              map: map
              icon: "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=|33CCFF|000000"

          map.fitBounds(bounds)
        else
          if @passportCollection.models.length == 1
            guide = @passportCollection.first()
            centerAddress = guide.get('city') + " " + guide.get('region') + " " + guide.get('country')
            position = new google.maps.LatLng(parseFloat(guide.get('gn_data')['lat']), parseFloat(guide.get('gn_data')['lng']))
            marker = new google.maps.Marker
              position: position
              map: map
              icon: "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=|33CCFF|000000"
          else
            centerAddress = 'California, United States'

          geocoder = new google.maps.Geocoder()
          geocoder.geocode { 'address': centerAddress }, (results, status) ->
            if status == google.maps.GeocoderStatus.OK
              if status != google.maps.GeocoderStatus.ZERO_RESULTS
                map.setCenter results[0].geometry.location

    _openModal: (e) ->
      guide_id = $(e.currentTarget).attr('data-id')
      modal = new Vacaybug.GuideModalView
        guide: (@passportCollection.where({id: parseInt(guide_id)})[0] || @wishlistCollection.where({id: parseInt(guide_id)})[0])
      modal.render()

    deleteGuide: (e) ->
      if (confirm('Are you sure you want to delete this guide?'))
        guide_id = $(e.currentTarget).attr('data-id')
        model = (@passportCollection.where({id: parseInt(guide_id)})[0] || @wishlistGuides.where({id: parseInt(guide_id)})[0])
        model.destroy()

    createGuide: (event) ->
      guide = new Vacaybug.GuideModel
        description: $(".trip-description").val()
        country:     @selected.data.countryName
        region:      if @selected.data.name != @selected.data.adminName1 then @selected.data.adminName1 else ''
        city:        @selected.data.name
        geonames_id: @selected.data.geonameId
        gn_data:     @selected.data
        guide_type:  @getTripType()

      elem = $(event.currentTarget)
      elem.attr("disabled", "disabled")
      elem.html("Saving&hellip;")

      guide.save null,
        success: (model, resp) =>
          $('body').removeClass('modal-open')
          Vacaybug.router.navigate(guide.pageURL(), {trigger: true})
        error: ->
          elem.removeAttr("disabled")
          elem.html("Continue")

    render: ->
      return @ unless @model.sync_status
      @isPrivate = Vacaybug.current_user && @model.get('id') == Vacaybug.current_user.get('id')

      @template = JST["backbone/templates/profile"]

      @birthday = null
      if @model.get('birthday')
        @date = new Date(@model.get('birthday') + " 00:00:00")
        @birthday = $.format.date(@date, "MMM dd, yyyy")

      $(@el).html @template
        model: @model.toJSON()
        guides: @guides
        activeTab: @activeTab
        editMode: @editMode
        isPrivate: @isPrivate
        birthday: @birthday
        errors: @errors

      @renderMap()

      $('input.input-birthday').datepicker
        format: "MMM dd, YYYY"
        changeMonth: true
        changeYear: true
        yearRange: "-100:+0"

      $('input.input-birthday').datepicker('setDate', @date)

      timeout = null
      $(".typeahead").typeahead(
        {
          hint: false,
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
                  $(".typeahead-spinner").addClass("hidden")
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

      $(".typeahead").on 'input', (event) =>
        $(".js-continue").attr("disabled", "disabled")
        $(".typeahead-spinner").removeClass("hidden")

      @renderPassport()
      @renderWishlist()
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

      copy_model.set('birthday', $.format.date(new Date(copy_model.get('birthday') + " 00:00:00"), "yyyy-MM-dd"))

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
            @_complete()
          else
            @_complete()
            $('span.profile-label').each (index, elem) ->
              field = $(elem).attr('data-field')

              if resp.errors[field]
                $(elem).parent().parent().append($("<div class='col-sm-offset-4 col-sm-8 text-danger error-message'>#{resp.errors[field][0]}</div>"))

        error: (model, resp) =>
          Vacaybug.flash_message({text: 'There was an error while completing your request. Please try again', type: 'alert'})

    _complete: ->
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

    getTripType: ->
      if @$(".trip-type-choice.active").length > 0
        @$(".trip-type-choice.active").attr("value")
      else
        null

    _moveTo: (guideModel, from, to) ->
      guideModel.set('guide_type', 3 - guideModel.get('guide_type'), {silent: true})
      guideModel.save null,
        success: =>
          to.add(guideModel)
          from.remove(guideModel)

    moveToPassport: (guideModel) ->
      @_moveTo(guideModel, @wishlistCollection, @passportCollection)

    moveToWishlist: (guideModel) ->
      @_moveTo(guideModel, @passportCollection, @wishlistCollection)

    _tripTypeClick: (e) ->
      e.preventDefault()
      e.stopPropagation()
      @$(".trip-type-choice").removeClass("active")
      $(e.currentTarget).addClass("active")

    changePhoto: ->
      uploader = new Vacaybug.ImageUploaderModalView()
      uploader.render()
      uploader.on 'done', (obj) =>
        @imageObject = obj.data
        $('img.nav-avatar').attr('src', obj.data.image.thumb)
        @model.set('image_id', obj.data.id)
        @model.save()

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.ProfileView = ProfileView
