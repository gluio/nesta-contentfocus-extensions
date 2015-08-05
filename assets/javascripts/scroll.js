jQuery(window).load(function() {
  var nav = jQuery('header.navigation');
  if (location.hash && nav.length > 0) {
    setTimeout(function() {
      var el = jQuery(location.hash);
      if (el.length > 0) {
        var scrollTo = el.position().top - nav.height() - 33;
        jQuery('html, body').animate({ scrollTop: scrollTo }, 1000);
      }
    }, 1000);
  }
});
