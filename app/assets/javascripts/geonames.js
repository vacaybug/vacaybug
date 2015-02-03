(function(window, $) {
    'use strict';

    // Builds a 4 characters unique id
    var uniqId = function(prefix) {
        prefix = prefix || '';

        return prefix + ("0000" + (Math.random() * Math.pow(36, 4) << 0).toString(36)).substr(-4);
    };

    // Builds query parameters from a geoname object
    var RequestDataBuilder = function(geo, datas) {
        this.datas = datas || {};

        if (!geo instanceof GeotoCompleter) {
           throw 'You must provide an instance of GeotoCompleter';
        }

        if (geo.getOption('sort')) {
            this.datas.sort = geo.getOption('sort');
        }
        if (geo.getOption('client-ip')) {
            this.datas.sortParams = geo.getOption('sortParams');
        }
        if (geo.getOption('country')) {
            this.datas.country = geo.getOption('country');
        }
        if (geo.getOption('name')) {
            this.datas.name = geo.getOption('name');
        }
        if (geo.getOption('limit')) {
            this.datas.limit = geo.getOption('limit');
        }
    };

    RequestDataBuilder.prototype.getRequestDatas = function() {
        return this.datas;
    };

    // Handles request to the remote Geonames Server
    var RequestManager = function(server) {
        var _request = false;
        var _endpoint = server;

        this.search = function(resource, datas, errorCallback, parseresults) {
            _request = $.ajax({
                type: "GET",
                dataType: "jsonp",
                jsonpCallback: "parseresults",
                url: _endpoint + resource,
                beforeSend: function() {
                    if (_request && typeof _request.abort === 'function') {
                        _request.abort();
                    }
                },
                error: errorCallback,
                data: datas
            })
            .done(parseresults)
            .always(function() {
                _request = false;
            });
        };
    };

    var GeotoCompleter = function(el, serverEndpoint, options) {
        if (typeof $.ui === 'undefined') {
            throw 'jQuery UI must be loaded';
        }

        if($(el).data('geocompleter')) {
            return $(el).data('geocompleter');
        }

        var _serverEndpoint = serverEndpoint.substr(serverEndpoint.length - 1) === '/' ? serverEndpoint : serverEndpoint + '/';

        this._requestManager = new RequestManager(_serverEndpoint);

        this.$el = $(el);

        this._opts = $.extend({
            "name": null,
            "sort": null,
            "client-ip": null,
            "country": null,
            "limit": null,
            "init-input": true
        }, options);

        this.$input = null;

        this.$el.data('geocompleter', this);
    };

    GeotoCompleter.prototype.getOption = function(name) {
        if (!(name in this._opts)) {
            return null;
        }

        return this._opts[name];
    };

    GeotoCompleter.prototype.setOption = function(name, value) {
        if (!(name in this._opts)) {
            return this;
        }

        this._opts[name] = value;

        return this;
    };

    GeotoCompleter.prototype.getAutocompleter = function() {
        return this.$input;
    };

    GeotoCompleter.prototype.destroy = function() {
        if (this.$input) {
            this.$input.remove();
            this.$el.show();
            this.$el.val('');
            this.$el.data('geocompleter', null);
        }
    };

    GeotoCompleter.prototype.init = function() {
        if (null !== this.$input) {
            return;
        }

        var self = this;

        var updateGeonameField = function(value) {
            self.$el.val(value);
        };

        var updateCityField = function(value) {
            self.$input.val(value);
        };

        var resetGeonameField = function() {
            self.$el.val('');
        };

        var resetCityField = function() {
            self.$input.val('');
        };

        var isGeonameFieldSetted = function() {
            return self.$el.val() !== '';
        };

        var highlight = function (s, t) {
            var matcher = new RegExp("("+$.ui.autocomplete.escapeRegex(t)+")", "ig" );
            return s.replace(matcher, "<span class='ui-state-highlight'>$1</span>");
        };

        // Creates city input
        this.$input = $('<input />')
                .attr('name', uniqId(this.$el.attr('name')))
                .attr('id', uniqId(this.$el.attr('id')))
                .attr('type', 'text')
                .attr('class', this.$el.attr('class'))
                .addClass("geocompleter-input");

        // Prevents form submission when pressing ENTER
        this.$input.keypress(function(event) {
            var code = (event.keyCode ? event.keyCode : event.which);
            if(code === $.ui.keyCode.ENTER ) {
                event.preventDefault();
                return false;
            }
        });

        // On any keyup except (esc, up, down, enter) fields are desynchronised, reset geonames field
        this.$input.keyup(function(event) {
            var code = (event.keyCode ? event.keyCode : event.which);
            var unBindKeys = [
                $.ui.keyCode.ESCAPE,
                $.ui.keyCode.UP,
                $.ui.keyCode.DOWN,
                $.ui.keyCode.LEFT,
                $.ui.keyCode.RIGHT,
                $.ui.keyCode.ENTER
            ];

            if (-1 === $.inArray(code, unBindKeys)){
                resetGeonameField();
            }
        });

        this.$el.hide();
        this.$el.after(this.$input);

        // Overrides prototype to render values without autoescape, useful to highlight values
        $.ui.autocomplete.prototype._renderItem = function( ul, item) {
            return $( "<li></li>" )
              .data( "item.autocomplete", item )
              .append( $( "<a></a>" ).html( item.label ) )
              .appendTo( ul );
        };

        // Saves response content
        var responseContent;

        // Builds a jquery autocompleter
        this.$input.autocomplete({
            create: function(event) {
                if(self.$el.val !== "" && self.getOption("init-input")) {
                    self._requestManager.search(
                        "city/" + parseInt(self.$el.val(), 10),
                        {},
                        function(jqXhr, status, error) {
                            return;
                        }, function (data) {
                            var country = data.country.name || "";
                            self.$input.val(data.name + ("" !== country ? "," + country : ""));
                        }
                    );
                }
            },
            source: function(request, response) {
                var name, country, terms = '';

                terms = request.term.split(',');

                if (terms.length === 2) {
                    country = terms.pop();
                }

                name = terms.pop();

                self.setOption('name', $.trim(name));
                self.setOption('country', $.trim(country));

                var requestDataBuilder = new RequestDataBuilder(self);

                self._requestManager.search(
                    "city",
                    requestDataBuilder.getRequestDatas(),
                    function(jqXhr, status, error) {
                        if (jqXhr.status !== 0 && jqXhr.statusText !== 'abort') {
                            response([]);
                            self.$input.trigger('geotocompleter.request.error', [jqXhr, status, error]);
                        }
                    }, function(data) {
                        response($.map(data || [], function(item) {
                            var country = country ? country : name;
                            var labelName = highlight(item.name, name);
                            var labelCountry = highlight((item.country ? item.country.name || '' : ''), country);
                            var labelRegion = highlight((item.region ? item.region.name || '' : ''), name);

                            return {
                                label:  labelName + ("" !== labelCountry ? ", " + labelCountry : "") + ("" !== labelRegion ? " <span class='region'>" + labelRegion + "</span>" : ""),
                                value: item.name + (item.country ? ", " + item.country.name : ''),
                                geonameid: item.geonameid
                            };
                        }));
                    }
                );
            },
            messages: {
                noResults: '',
                results: function() {}
            },
            response: function (event, ui) {
                responseContent = [];
                if (ui.content) {
                    responseContent = ui.content;
                    // Sets geoname id if values are re synchronized
                    if (ui.content.length > 0) {
                        var items = $.grep(ui.content, function(item) {
                            return item.value === self.$input.val() ? item : null;
                        });

                        if (items.length > 0) {
                            updateGeonameField(items[0].geonameid);
                        }
                    }
                }
            },
            select: function(event, ui) {
                if (ui.item) {
                    updateGeonameField(ui.item.geonameid);
                }
            },
            focus: function (event, ui) {
                var code = (event.keyCode ? event.keyCode : event.which);
                // Updates geoname ID only if key up and key down are pressed
                if (ui.item && -1 !== $.inArray(code, [$.ui.keyCode.DOWN, $.ui.keyCode.UP])) {
                    updateGeonameField(ui.item.geonameid);
                }
            },
            close : function (event, ui) {
                var ev = event.originalEvent;

                if ("undefined" === typeof ev) {
                    return false;
                }

                var code = (ev.keyCode ? ev.keyCode : ev.which);
                // If esc key is pressed or user leaves the input
                if ((ev.type === "keydown" && code === $.ui.keyCode.ESCAPE) || ev.type === "blur") {
                    if (isGeonameFieldSetted() && responseContent.length > 0) {
                        var geonameId = self.$el.val();
                        // Update city input according to the setted geonameId
                        var responseValues = $.grep(responseContent, function(item) {
                            return item.geonameid === geonameId ? item : null;
                        });

                        if (responseValues.length > 0) {
                            self.$input.val(responseValues[0].value);
                        }

                        return false;
                    }

                    // Resets both field as nothing is no more sychronized
                    resetGeonameField();
                    resetCityField();
                }
            }
        }).autocomplete("widget").addClass("geocompleter-menu");

        var onInit = self.getOption('onInit');

        // On Initialization callback
        if (onInit !== null && typeof onInit === 'function') {
            onInit(this.$el, this.$input);
        }
    };

    var methods = {
        init: function(options) {
            var settings = $.extend({
                server: ''
            }, options);

            if ('' === settings.server) {
                throw '"server" must be set';
            }

            return this.each(function() {
                var geocompleter = new GeotoCompleter(this, settings.server, settings);
                geocompleter.init();
            });
        },
        destroy: function() {
            return this.each(function() {
                var geocompleter = $(this).data('geocompleter');
                if (geocompleter) {
                    geocompleter.destroy();
                }
            });
        },
        autocompleter: function() {
            var args = arguments;
            return this.each(function() {
                var geocompleter = $(this).data('geocompleter');
                if (args[0] === "on" && typeof args[1] === "string" && typeof args[2] === "function") {
                    // Bind addition events
                    geocompleter.getAutocompleter().on(args[1], args[2]);
                } else {
                    $.fn.autocomplete.apply(geocompleter.getAutocompleter(),args);
                }
            });
        }
    };

    $.fn.geocompleter = function(method) {
        if (methods[method]) {
            return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
        } else if (typeof method === 'object' || !method) {
            return methods.init.apply(this, arguments);
        } else {
            $.error('Method ' + method + ' does not exist on jQuery.geocompleter');
        }
    };
})(window, jQuery);
