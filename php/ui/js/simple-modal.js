/*
---
description: SIMPLE MODAL for jQuery is a small plugin based on original SimpleModal for Mootools. It can be used to generate alert or confirm messages with few lines of code. Confirm configuration involves the use of callbacks to be applied to affirmative action;i t can work in asynchronous mode and retrieve content from external pages or getting the inline content. SIMPLE MODAL is not a lightbox although the possibility to hide parts of its layout may partially make it similar.

license: MIT-style

authors:
- Micha� Buczko
- Marco Dell'Anna

requires:
- jQuery 1.6+

provides:
- SimpleModal
...

* Simple Modal for jQuery
* Version 1.0
*
* Copyright (c) 2011 Micha� Buczko
* Original Simple Modal copyrighted 2011 Marco Dell'Anna - http://www.plasm.it
*
* Requires:
* jQuery http://jquery.com
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use,
* copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following
* conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
*
* Log:
* 1.0 - Initial version [Tested on: ie8/ie9/Chrome/Firefox7/Safari]
*/

(function($) {

    var self = null;

    //Attach this new method to jQuery
    $.fn.extend({
        buttons: null,
        options: null,

        defaults: {
            onAppend:      null,
            offsetTop:     null,
            overlayOpacity:.3,
            overlayColor:  "#000000",
            width:         400,
            draggable:     true,
            keyEsc:        true,
            overlayClick:  true,
            closeButton:   true, // X close button
            hideHeader:    false,
            hideFooter:    false,
            btn_ok:        "确定", // Label
            btn_cancel:    "取消", // Label
            template:"<div class=\"simple-modal-header\"> \
                <h1>{_TITLE_}</h1> \
            </div> \
                <div class=\"simple-modal-body\"> \
                <div class=\"contents\">{_CONTENTS_}</div> \
            </div> \
                <div class=\"simple-modal-footer\"></div>"
        },

        SimpleModal: function(options) {
            self = this;

            this.buttons = [];
            this.options = $.extend({}, self.defaults, options);

            return this;
        },

        /**
         * public method showModal
         * Open Modal
         * @options: param to rewrite
         * @return node HTML
         */
        showModal: function() {
            var node = null;

            // Inserisce Overlay
            this._overlay("show");

            // Switch different modal
            switch(this.options.model) {
            case "modal-ajax":
				        node = this._drawWindow(this.options);
                this._loadContents({
                    "url": self.options.param.url || "",
                    "onRequestComplete": this.options.param.onRequestComplete
                });
                break;
            case "confirm":
                // Add button confirm
                this.addButton(this.options.btn_ok, "btn primary btn-margin", function() {
                    // in oppose to original version, i'm not catching exceptions
                    // i want to know what's eventually goes wrong
                    if(self.options.callback()){
                        self.hideModal();
                    }
                });
                // Add button cancel
                this.addButton(this.options.btn_cancel, "btn");
                		node = this._drawWindow(this.options);
                break;
            case "modal":
				        node = this._drawWindow(this.options);
                break;
            default:
				// Alert
                this.addButton(this.options.btn_ok, "btn primary");
				        node = this._drawWindow(this.options);
            }
			if (node) {
                // Custom size Modal
                node.css('width', this.options.width);

                // Hide Header &&/|| Footer
                if (this.options.hideHeader) node.addClass("hide-header");
                if (this.options.hideFooter) node.addClass("hide-footer");

                // Add Button X
                if (this.options.closeButton) this._addCloseButton();

                // Enabled Drag Window
                if (this.options.draggable) {
                    var headDrag = node.find('.simple-modal-header'), clicked = false, dx=0, dy=0;
                    var updatePos = function(pos) {
                        node.css({left: pos.x-dx, top: pos.y-dy});
                    };
                    var getMousePos = function(e) {
                        return { 'x': e.pageX, 'y': e.pageY };
	                };
                    headDrag.bind({
                        mousedown: function(e) {
                            var mpos = getMousePos(e), cpos = node.position();

                            e.stopPropagation();
                            e.preventDefault();

                            dx = mpos.x - cpos.left;
                            dy = mpos.y - cpos.top;

                            clicked = true;
                        },
                        mouseup: function(e) {
                            e.stopPropagation();
                            e.preventDefault();
                            clicked = false;
                        }
                    });
                    $(document).mousemove(function(e) {
                        e.stopPropagation();
                        e.preventDefault();
		                if (clicked)
			                updatePos(getMousePos(e));
	                });

                    // Set handle cursor
                    headDrag.css("cursor", "move");
                    node.addClass("draggable");
                }
                // Resize Stage
                this._display();
            }
        },

        /**
         * public method hideModal
         * Close model window
         * return
         */
        hideModal: function() {
		    self._overlay('hide');
        },

        /**
         * private method _drawWindow
         * Rendering window
         * return node SM
         */
		_drawWindow:function(options) {
			// Add Node in DOM
            var node = $("<div>").addClass('simple-modal').attr('id', 'simple-modal');

			// Set Contents
		    node.html(this._template(self.options.template, {"_TITLE_":options.title || "Untitled", "_CONTENTS_":options.contents || ""}));

            $('body').append(node);

			// Add all buttons
		    this._injectAllButtons();

		    // Callback append
            if (this.options.onAppend) {
		        this.options.onAppend.call(this);
            }
			return node;
		},

        /**
         * public method addButton
         * Add button to Modal button array
         * require @label:string, @classe:string, @clickEvent:event
         * @return node HTML
         */
        addButton: function(label, classe, clickEvent) {
            var bt = $('<a>').attr({
                "title" : label,
                "class" : classe
            }).click(clickEvent ? function(e) { clickEvent.call(self, e); } : self.hideModal).text(label);

            this.buttons.push(bt);
 		    return this;
        },

        /**
         * private method _injectAllButtons
         * Inject all buttons in simple-modal-footer
         * @return
         */
        _injectAllButtons: function() {
            var footer = $("#simple-modal").find(".simple-modal-footer");

           $.each(self.buttons, function(i, e) {
               footer.append(e);
            });
        },

        /**
         * private method _addCloseButton
         * Inject Close botton (X button)
         * @return node HTML
         */
        _addCloseButton: function() {
            var b = $("<a>").addClass('close').attr({"href": "#"}).text('x').click(function(e) {
                self.hideModal();
                e.preventDefault();
            });
            $("#simple-modal").append(b);
            return b;
        },

        /**
         * private method _overlay
         * Create/Destroy overlay and Modal
         * @return
         */
        _overlay: function(status) {
            switch(status) {
            case 'show':
                var overlay = $("<div>")
                        .attr("id", "simple-modal-overlay")
                        .css({"background-color": this.options.overlayColor, "opacity": 0});

                $('body').append(overlay);

                overlay.animate({opacity: this.options.overlayOpacity});

                // Behaviour
                if (this.options.overlayClick) {
                    overlay.click(function(e) { self.hideModal(); });
                }

                // Add Control Resize
                $(window).resize(self._display);
                $(document).keyup(self._escape);
                break;

            case 'hide':
                // Remove Overlay
                $('#simple-modal-overlay').remove();
                $('#simple-modal').remove();

                $(window).unbind('resize', self._display);
                $(document).unbind('keyup', self._escape);
            }
        },

        _escape: function(e) {
            if (e.keyCode == 27) self.hideModal();
        },

        /**
         * private method _loadContents
         * Async request for modal ajax
         * @return
         */
        _loadContents: function(param) {
			// Set Loading
			$('#simple-modal').addClass("loading");
			// Match image file
			var re = new RegExp( /([^\/\\]+)\.(jpg|png|gif)$/i ), container = $('#simple-modal');
			if (param.url.match(re)) {
				// Hide Header/Footer
	            container.addClass("hide-footer");
				// Remove All Event on Overlay
				$("#simple-modal-overlay").unbind(); // Prevent Abort
				// Immagine
                var image = $('<img>').attr('src', param.url)
                        .load(function() {
							var content = container.removeClass("loading").find(".contents").empty().append($(this).css('opacity', 0));
                            var dw = container.width() - content.width(), dh = container.height() - content.height();
							var width = $(this).width()+dw, height  = $(this).height()+dh;

                            //self._display();
                            container.animate({
                                width: width,
                                height: height,
                                left: ($(window).width() - width)/2,
                                top: ($(window).height() - height)/2
                            }, 200, function() {
                                image.animate({opacity: 1});
                            });
                        });
			} else {
                $('#simple-modal .contents').load(param.url, function(responseText, textStatus, XMLHttpRequest) {
                    var container = $(this).parent().parent().removeClass("loading");
                    if (textStatus !== 'success') {
	                    container.find(".contents").html("loading failed");

                        if (param.onRequestFailure) {
                            param.onRequestFailure();
                        }
                    }
                    else
                    {
                        if (param.onRequestComplete) {
                            param.onRequestComplete();
                        }
	                    self._display();
                    }
                });
			}
        },

        /**
         * private method _display
         * Move interface
         * @return
         */
        _display: function() {
            // Update overlay
            $("#simple-modal-overlay").css({width: $(window).width(), height: $(window).height()});

            // Update position popup
            var modal = $("#simple-modal"), top = self.options.offsetTop || ($(window).height() - modal.height())/2;
            modal.css({
                top: top,
                left: (($(window).width() - modal.width())/2)
            });
        },

        /**
         * private method _template
         * simple template by Thomas Fuchs
         * @return
         */
        _template:function(s,d) {
            for(var p in d) {
                s=s.replace(new RegExp('{'+p+'}','g'), d[p]);
            }
            return s;
        }
    });

})(jQuery);
