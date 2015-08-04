jQuery('h1[id], h2[id], h3[id], section[id] > h1, section[id] > h2, section[id] > h3').each(function() {
  var ref;
  var el = jQuery(this);
  if (el.attr('id')) {
    ref = el.attr('id');
  } else {
    ref = el.parent().attr('id');
  }
  var link = jQuery('<a href="#'+ref+'" class="icon-link"></a>');
  el.prepend(link);
});
