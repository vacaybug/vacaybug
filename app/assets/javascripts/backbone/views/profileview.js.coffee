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
      @listenTo @model, 'sync', @render
      @listenTo @model, 'change', @render
      @activeTab = 'passport'
      @editMode = false

    render: ->
      if @model.sync_status
        @birth_year = null
        @birth_date = null
        if @model.get('birthday')
          date = new Date(@model.get('birthday') + " 00:00:00")
          @birth_year = $.format.date(date, "yyyy")
          @birth_date = $.format.date(date, "MMM, dd")

        $(@el).html @template
          model: @model.toJSON()
          activeTab: @activeTab
          editMode: @editMode
          birth_year: @birth_year
          birth_date: @birth_date

        $('input.input-birthday').datepicker
          format: "M, dd"
      @

    follow: ->
      @model.follow()

    unfollow: ->
      @model.unfollow()

    edit: ->
      @editMode = true
      @render()

    save: ->
      $('input.profile-field').each (index, elem) =>
        field = $(elem).attr('data-field')
        @model.set(field, $(elem).val())

      @model.set('birthday', @model.get('birth_year') + ' ' + @model.get('birth_date'))

      @model.save null,
        success: (model) =>
          Vacaybug.flash_message({text: 'Your profile has been successfully updated'})
        error: (model, resp) =>
          Vacaybug.flash_message({text: 'There was an error while completing your request. Please try again', type: 'alert'})

      @editMode = false
      @render()

    cancel: ->
      @editMode = false
      @render()

    clickTab: (e) ->
      currentTab = $(e.currentTarget).attr('data-tab')
      @activeTab = currentTab

  Vacaybug = window.Vacaybug ? {}
  Vacaybug.ProfileView = ProfileView
