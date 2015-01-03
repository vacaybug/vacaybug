jQuery ->
  class ProfileView extends window.Vacaybug.GenericView
    template: JST["backbone/templates/profile"]

    events:
      'click .js-follow': 'follow'
      'click .js-unfollow': 'unfollow'
      'click .js-edit': 'edit'
      'click .js-cancel': 'cancel'
      'click .js-save': 'save'
      'click .js-tab': 'clickTab'

    initialize: (options) ->
      @listenTo @model, 'change', @render
      @listenTo @model, 'sync', @render
      @activeTab = 'passport'
      @editMode = false

    render: ->
      if @model.sync_status
        @birth_year = null
        @birth_date = null
        if @model.get('birthday')
          @date = new Date(@model.get('birthday') + " 00:00:00")
          @birth_year = $.format.date(@date, "yyyy")
          @birth_date = $.format.date(@date, "MMM, dd")

        $(@el).html @template
          model: @model.toJSON()
          activeTab: @activeTab
          editMode: @editMode
          birth_year: @birth_year
          birth_date: @birth_date

        $('input.input-birthday').datepicker
          format: "M, dd"

        $('input.input-birthday').datepicker('setDate', @date)
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
                console.log($(elem).parent())
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
