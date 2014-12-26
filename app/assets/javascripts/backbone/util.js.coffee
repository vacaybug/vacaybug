jQuery ->
  Vacaybug = window.Vacaybug || {}

  $.fn.flash_message = (options) ->
    options = $.extend(
      text: ""
      time: 5000
      how: "before"
      class_name: ""
      type: "notice"
    , options)
    $(this).each ->
      return if $(this).parent().find(".flash-message").get(0)
      message = $("<div class='flash-message flash-#{options.type} #{options.class_name}'>#{options.text}</div>").hide().fadeIn("fast")
      $(this)[options.how] message
      message.delay(options.time).fadeOut "normal", ->
        $(this).remove()

  flash_message = (options) ->
    options = $.extend(
      how: "append"
    , options)

    $("#notification").flash_message options

  Vacaybug.flash_message = flash_message
  window.Vacaybug ||= Vacaybug
