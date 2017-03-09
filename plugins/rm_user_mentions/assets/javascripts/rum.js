RMPlus.RUM = (function (my) {
  var my = my || {};
  var ajax_query = false;
  var timer = undefined;

  my.empty_sorter = function(items) { return items; };
  my.empty_matcher = function(item) { return true; }
  my.custom_select_formatter = function(item) { return '{{rum(' + item.id + ', ' + item.name + ')}}'; };
  my.custom_highlighter = function(item) {
    var query = this.query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&');
    var value = item.name + ' (' + item.login + ')';
    value = value.replace(new RegExp('(' + query + ')', 'ig'), function ($1, match) {
      return '<strong>' + match + '</strong>';
    });
    return item.avatar + ' ' + value;
  }
  my.custom_source = function(query, callback) {
    if (RMPlus.RUM.ajax_query) {
      if (RMPlus.RUM.timer) { clearTimeout(RMPlus.RUM.timer); }
      RMPlus.RUM.timer = setTimeout(function( ) { RMPlus.RUM.custom_source(query, callback); }, 300);
      return;
    }
    RMPlus.RUM.ajax_query = true;
    $.ajax({
      type: 'GET',
      url: '/rum/user_autocomplete',
      data: { value: query }
    }).done(function(data) {
      callback(data.users);
    }).always(function() { RMPlus.RUM.ajax_query = false; });
    return undefined;
  };

  my.initialize_mentions = function(elements) {
    (elements || $((RMPlus.RUM.fields_with_mentions && RMPlus.RUM.fields_with_mentions.length > 0 ? (RMPlus.RUM.fields_with_mentions + ', ') : '') + '.rum-autocomplete')).rum_mention({
      matcher: RMPlus.RUM.empty_matcher,
      sorter: RMPlus.RUM.empty_sorter,
      select_formatter: RMPlus.RUM.custom_select_formatter,
      highlighter: RMPlus.RUM.custom_highlighter,
      source: RMPlus.RUM.custom_source,
      items: Infinity,
      minLength: RMPlus.RUM.min_chars_for_mentions,
      delimiter: RMPlus.RUM.mentions_magic_char,
      me: RMPlus.RUM.myself_link
    });
  };

  return my;
})(RMPlus.RUM || {});

$(document).ready(function( ) {
  RMPlus.RUM.initialize_mentions();
  $(document.body).on('click focus keypress', ((RMPlus.RUM.fields_with_mentions && RMPlus.RUM.fields_with_mentions.length > 0 ? (RMPlus.RUM.fields_with_mentions + ', ') : '') + '.rum-autocomplete'), function(){
    RMPlus.RUM.initialize_mentions($(this));
  });
});

