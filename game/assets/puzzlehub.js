/* v2.0.69: Puzzles hub. Old jigsaw share links were puzzles.php#slug-n (the browser never sends the hash to the server): send them on to GIFsaw. */
(function(){
  var h=location.hash||'';
  if(/^#[A-Za-z0-9_-]{1,64}$/.test(h)) location.replace('gifsaw.php'+location.search+h);
})();
