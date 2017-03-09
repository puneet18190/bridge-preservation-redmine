!function($) {
  "use strict"; // jshint ;_;

  var rum_mention = function (element, options) {
    this.$element = $(element);

    this.options = $.extend({}, $.fn.rum_mention.defaults, options);
    this.matcher = this.options.matcher || this.matcher;
    this.sorter = this.options.sorter || this.sorter;
    this.highlighter = this.options.highlighter || this.highlighter;
    this.select_formatter = this.options.select_formatter || this.select_formatter;
    this.source = this.options.source;

    this.$popup = $(this.options.popup);
    this.shown = false;
    this.listen();

    this.start_index = 0;
    this.end_index = Infinity;
  }

  rum_mention.prototype = {

    constructor: rum_mention,
    listen: function( ) {
      this.$element
          .on('click',    $.proxy(this.click, this))
          .on('focus',    $.proxy(this.focus, this))
          .on('blur',     $.proxy(this.blur, this))
          .on('keypress', $.proxy(this.keypress, this))
          .on('keyup',    $.proxy(this.keyup, this))

      if (this.event_supported('keydown')) {
        this.$element.on('keydown', $.proxy(this.keydown, this))
      }
      this.$popup
          .on('click', 'li', $.proxy(this.popover_click, this))
          .on('mouseenter', 'li', $.proxy(this.popover_mouseenter, this))
          .on('mouseleave', 'li', $.proxy(this.popover_mouseleave, this))
    },
    click: function( ) { this.hide( ); },
    focus: function( ) { this.focused = true; },
    blur: function( ) {
      this.focused = false;
      if (!this.mouse_in_list && this.shown) { this.hide( ); }
    },
    keydown: function(e) {
      if (!this.shown) { return; }
      switch(e.keyCode) {
        case 9: // tab
        case 13: // enter
        case 27: // escape
        case 38: // up arrow
        case 40: // down arrow
          e.preventDefault( );
          break;
      }

      e.stopPropagation( );

      if (this.shown && this.check_start_index( )) {
        var value_new = this.$element.val( );
        if ((this.before_key_down || this.before_key_down == '') && this.before_key_down.length != value_new.length) {
          this.end_index += value_new.length - this.before_key_down.length;
          this.lookup( );
        }
        this.before_key_down = value_new;
      }
      else { this.before_key_down = undefined; }
    },
    keypress: function(e) {
      if (this.shown && (e.keyCode == 13 || e.keyCode == 9)) { e.preventDefault( ); }

      var keyChar = String.fromCharCode(e.which || e.keyCode);
      if (keyChar == this.options.delimiter && !this.shown) {
        this.start_index = this.selection_start( );
        this.end_index = this.start_index;
        this.lookup( );
        this.before_key_down = this.$element.val( );
        return;
      }
      if (!this.event_supported('keydown')) {
        if (this.shown && this.check_start_index( )) {
          var value_new = this.$element.val( );
          if ((this.before_key_down || this.before_key_down == '') && this.before_key_down.length != value_new.length) {
            this.end_index += value_new.length - this.before_key_down.length;
            this.lookup( );
          }
          this.before_key_down = value_new;
        }
        else { this.before_key_down = undefined; }
      }
    },
    keyup: function(e) {
      this.move(e);
      var value_old = this.before_key_down;
      var value_new = this.$element.val( );
      this.before_key_down = value_new;

      if (this.shown && ((!value_old && value_old != '') || (value_old.length == value_new.length && !this.check_query( )) || !this.check_start_index( ))) {
        this.hide( );
        return;
      }
      if (!this.shown) { return; }
      this.end_index += value_new.length - value_old.length;
      if (value_new.length != value_old.length) { this.lookup( ); }
    },
    check_query: function( ) {
      var value = this.$element.val( );
      var start = this.selection_start( );
      var end = this.selection_end( );
      return (value && value.length > 0 && start > 0 && end > 0 && start <= end && end <= value.length && start > this.start_index && end <= this.end_index);
    },
    check_start_index: function(value) {
      var value = this.$element.val( );
      var start = this.selection_start( );
      return (value && value.length > 0 && start > 0 && start <= value.length && start > this.start_index);
    },

    extract_query: function( ) {
      var value = this.$element.val();
      if (!value || this.start_index == this.end_index) { return ''; }
      return value.substring(this.start_index + 1, this.end_index);
    },


    lookup: function ( ) {
      this.shown = true;
      var items;
      this.query = this.extract_query();
      if (!this.query || (this.query.length < this.options.minLength && this.query != this.options.me)) {
        this.$popup.hide( );
        return;
      }


      items = $.isFunction(this.source) ? this.source(this.query, $.proxy(this.process, this)) : this.source;

      return items ? this.process(items) : this;
    },
    process: function(items) {
      var that = this;

      items = $.grep(items, function (item) {
        return that.matcher(item)
      });

      items = this.sorter(items);

      if (!items.length) {
        if (this.shown) { this.$popup.hide( ); }
        return;
      }

      return this.render(items.slice(0, this.options.items)).show( );
    },
    matcher: function (item) { return ~item.toLowerCase().indexOf(this.query.toLowerCase()); },
    sorter: function (items) {
      var beginswith = []
        , caseSensitive = []
        , caseInsensitive = []
        , item

      while (item = items.shift()) {
        if (!item.toLowerCase().indexOf(this.query.toLowerCase())) beginswith.push(item)
        else if (~item.indexOf(this.query)) caseSensitive.push(item)
        else caseInsensitive.push(item)
      }

      return beginswith.concat(caseSensitive, caseInsensitive)
    },
    highlighter: function (item) {
      var query = this.query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&')
      return item.replace(new RegExp('(' + query + ')', 'ig'), function ($1, match) {
        return '<strong>' + match + '</strong>'
      });
    },
    render: function(items) {
      var that = this;

      items = $(items).map(function (i, item) {
        if (typeof(item) == 'object') { i = $(that.options.item).attr('data-object', JSON.stringify(item)); }
        else { i = $(that.options.item).attr('data-value', item); }
        i.html(that.highlighter(item));
        return i[0]
      });
      this.$popup.html(items);
      return this;
    },
    select_formatter: function(item) { return this.options.delimiter + item; },


    show: function( ) {
      this.shown = true;
      this.focused = true;

      this.mention_locate( );
      this.$popup.show( );
      return this;
    },
    hide: function( ) {
      this.$popup.hide( );
      this.shown = false;
      this.start_index = 0;
      this.end_index = Infinity;
      this.mouse_in_list = false;
      return this;
    },
    move: function(e) {
      if (!this.shown) { return; }

      switch(e.keyCode) {
        case 9: // tab
        case 13: // enter
          e.preventDefault( );
          this.popover_select( );
        case 27: // escape
          e.preventDefault( );
          this.hide( );
          break;

        case 38: // up arrow
          e.preventDefault( );
          this.popover_prev_item( );
          break

        case 40: // down arrow
          e.preventDefault( );
          this.popover_next_item( );
          break;
      }

      e.stopPropagation( );
    },

    popover_select: function( ) {
      var selected = this.$popup.find('.active');
      var val = selected.attr('data-value') || JSON.parse(selected.attr('data-object'));
      var value = this.$element.val( );
      var s = value.substring(0, this.start_index);
      var m = this.select_formatter(val);
      this.$element.val(s + m + value.substring(this.end_index)).change( );
      this.$element[0].selectionStart = s.length + m.length;
      this.$element[0].selectionEnd = s.length + m.length;
      return this.hide( );
    },
    popover_click: function(e) {
      e.stopPropagation( );
      e.preventDefault( );
      this.popover_select( );
      this.$element.focus( ).trigger('focus');
      return false;
    },
    popover_mouseenter: function(e) {
      this.mouse_in_list = true;
      this.$popup.find('.active').removeClass('active');
      $(e.currentTarget).addClass('active');
    },
    popover_mouseleave: function(e) {
      this.mouse_in_list = false;
      if (!this.focused && this.shown) { this.hide( ); }
    },
    popover_next_item: function( ) {
      var active = this.$popup.find('.active').removeClass('active');
      var next = active.next( );

      if (!next.length) {
        next = this.$popup.find('li:first');
      }

      next.addClass('active');
    },
    popover_prev_item: function( ) {
      var active = this.$popup.find('.active').removeClass('active');
      var prev = active.prev();

      if (!prev.length) {
        prev = this.$popup.find('li:last');
      }

      prev.addClass('active');
    },


    selection_start: function( ) {
      var input = this.$element.get(0);
      var pos = input.value.length;
      if (typeof(input.selectionStart) != "undefined") {
        pos = input.selectionStart;
      }
      return pos;
    },
    selection_end: function( ) {
      var input = this.$element.get(0);
      var pos = input.value.length;
      if (typeof(input.selectionEnd) != "undefined") {
        pos = input.selectionEnd;
      }
      return pos;
    },
    event_supported: function(eventName) {
      var isSupported = eventName in this.$element;
      if (!isSupported) {
        this.$element.setAttribute(eventName, 'return;')
        isSupported = typeof this.$element[eventName] === 'function'
      }
      return isSupported
    },

    mention_locate: function( ) {
      var offset = this.$element.offset( );
      var height = this.$element.outerHeight( );
      if (this.$popup.parent().length == 0) { $(document.body).prepend(this.$popup); }
      this.$popup.css({ left: offset.left, top: offset.top + height });
    }
  }

  var old = $.fn.rum_mention

  $.fn.rum_mention = function(option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('rum_mention')
        , options = typeof option == 'object' && option
      if (!data) { $this.data('rum_mention', (data = new rum_mention(this, options))); }
      if (typeof option == 'string') { data[option]( ); }
    })
  }

  $.fn.rum_mention.defaults = {
    source: [],
    items: 8,
    popup: '<ul class="rum-mention"></ul>',
    item: '<li></li>',
    minLength: 1,
    delimiter: '@',
    me: 'I'
  };

  $.fn.rum_mention.Constructor = rum_mention;

} (window.jQuery);