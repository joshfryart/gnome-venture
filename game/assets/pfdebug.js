/* DEBUG ONLY (2.6.81): finds out what "End turn reloads" really is on a phone. Loaded only after ?pfdebug=1 (a cookie keeps it on for a day); ?pfdebug=0 turns it off.
   Writes a log that SURVIVES a real reload (localStorage) and shows it in a small panel (tap the bug button). Changes no game behaviour.
   Reading the log: "LOAD nav=reload|navigate|back_forward" = a real page load happened (with what came just before it); "SWAP main replaced" = the in-place swap (no page load);
   "#pfight NEW node" = the fight was rebuilt; "dialog closed/opened" = the popover flickered. */
(function () {
  if (window.__pfdbg) return; window.__pfdbg = 1;
  var K = 'pfdbg_log', C = 'pfdbg_n', MAX = 250, ls = null;
  try { ls = window.localStorage; } catch (e) {}
  var m = /[?&]pfdebug=(\d)/.exec(location.search);
  if (m) document.cookie = 'pfdbg=' + m[1] + '; path=/; max-age=' + (m[1] === '1' ? 86400 : 0) + '; SameSite=Lax';
  if (m && m[1] === '0') { try { ls.removeItem(K); ls.removeItem(C); } catch (e) {} return; }

  var n = 0; try { n = (+ls.getItem(C) || 0) + 1; ls.setItem(C, String(n)); } catch (e) {}
  var t0 = Date.now(), buf = [];
  try { buf = JSON.parse(ls.getItem(K) || '[]'); } catch (e) {}
  function ts() { var d = new Date(); return ('0' + d.getMinutes()).slice(-2) + ':' + ('0' + d.getSeconds()).slice(-2) + '.' + ('00' + d.getMilliseconds()).slice(-3); }
  function log(s) {
    var line = ts() + ' p' + n + ' ' + s;
    buf.push(line); if (buf.length > MAX) buf = buf.slice(-MAX);
    try { ls.setItem(K, JSON.stringify(buf)); } catch (e) {}
    paint();
  }
  window.pfdbgLog = log;

  // ---- what kind of load is this
  var nav = ''; try { var e0 = performance.getEntriesByType('navigation')[0]; nav = e0 ? e0.type : ''; } catch (e) {}
  log('LOAD nav=' + nav + ' ' + location.pathname + location.search + ' ref=' + (document.referrer || '-').replace(/^https?:\/\/[^\/]+/, ''));

  // ---- leaving the page (the proof of a real reload / navigation)
  window.addEventListener('beforeunload', function () { log('BEFOREUNLOAD (page is being left)'); });
  window.addEventListener('pagehide', function (e) { log('PAGEHIDE persisted=' + e.persisted); });
  window.addEventListener('pageshow', function (e) { log('PAGESHOW persisted=' + e.persisted); });
  document.addEventListener('visibilitychange', function () { log('visibility=' + document.visibilityState); });
  window.addEventListener('error', function (e) { log('JS ERROR ' + (e.message || '') + ' @' + String(e.filename || '').replace(/^.*\//, '') + ':' + e.lineno); });
  window.addEventListener('unhandledrejection', function (e) { log('PROMISE REJECTED ' + (e.reason && e.reason.message || e.reason)); });
  window.addEventListener('popstate', function () { log('POPSTATE'); });

  // ---- every form that is sent, and whether the page stopped the plain (reloading) send
  document.addEventListener('submit', function (ev) {
    var f = ev.target, sub = ev.submitter, act = f.getAttribute && f.getAttribute('action'), doV = '';
    try { var d = f.querySelector('[name="do"]'); doV = d ? d.value : (sub && sub.name === 'do' ? sub.value : ''); } catch (e) {}
    var inFight = !!(f.closest && f.closest('#pfight')), t = Date.now();
    log('SUBMIT do=' + doV + (sub && sub.value ? ' btn=' + sub.value : '') + ' fight=' + inFight + ' action=' + (act || '-'));
    setTimeout(function () { log('  submit handled: defaultPrevented=' + ev.defaultPrevented + (ev.defaultPrevented ? ' (in place)' : ' (PLAIN POST: the page will load)')); }, 0);
  }, false);

  // ---- every fetch: where, how long, what came back (a redirect to another path, a non-200 and a failure all end in a reload in site.js)
  if (window.fetch) {
    var of = window.fetch;
    window.fetch = function (u, init) {
      var url = typeof u === 'string' ? u : (u && u.url) || '', meth = (init && init.method) || 'GET', hd = init && init.headers && (init.headers['X-Requested-With'] || ''), s = Date.now();
      var short = String(url).replace(/^https?:\/\/[^\/]+/, '').slice(0, 70);
      return of.apply(this, arguments).then(function (r) {
        log('FETCH ' + meth + ' ' + short + ' [' + hd + '] -> ' + r.status + (r.redirected ? ' REDIRECTED to ' + r.url.replace(/^https?:\/\/[^\/]+/, '').slice(0, 60) : '') + ' ' + (Date.now() - s) + 'ms');
        return r;
      }, function (err) { log('FETCH FAILED ' + meth + ' ' + short + ' ' + (err && err.message) + ' ' + (Date.now() - s) + 'ms'); throw err; });
    };
  }

  // ---- what the page does to itself: the swap of <main>, the fight and its dialog being replaced
  var lastFight = null, lastDlg = null, lastMain = null, swaps = 0;
  function watch() {
    var main = document.querySelector('main'), fi = document.getElementById('pfight'), dl = document.getElementById('trailpop');
    if (lastMain && main && main !== lastMain) log('MAIN element replaced');
    if (lastFight && fi !== lastFight) log('#pfight ' + (fi ? 'NEW node (fight rebuilt)' : 'GONE'));
    if (lastDlg && dl !== lastDlg) log('#trailpop ' + (dl ? 'NEW dialog node' : 'GONE'));
    if (!lastFight && fi) log('#pfight appeared');
    lastMain = main; lastFight = fi; lastDlg = dl;
  }
  function startObs() {
    var main = document.querySelector('main'); if (!main) return;
    watch();
    new MutationObserver(function (recs) {
      var ch = 0; recs.forEach(function (r) { ch += r.addedNodes.length + r.removedNodes.length; });
      if (ch > 3) { swaps++; log('SWAP main changed: ' + ch + ' nodes (#' + swaps + ')'); }
      watch();
    }).observe(main.parentNode || main, { childList: true, subtree: true });
    var dl = document.getElementById('trailpop');
    if (dl) log('trailpop open=' + dl.open + ' modal=' + (function () { try { return dl.matches(':modal'); } catch (e) { return '?'; } })());
  }
  document.addEventListener('close', function (ev) { if (ev.target && ev.target.id === 'trailpop') log('trailpop CLOSED'); }, true);
  document.addEventListener('gv:swapped', function () { log('gv:swapped (in-place swap finished)'); });
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', startObs); else startObs();

  // ---- the panel
  var box = null, btn = null, pre = null, open = false;
  function ui() {
    if (box || !document.body) return;
    Array.prototype.forEach.call(document.querySelectorAll('[data-pfdbg]'), function (x) { x.parentNode.removeChild(x); });   // never two panels
    btn = document.createElement('button'); btn.type = 'button'; btn.textContent = 'bug';
    var s = btn.style; s.position = 'fixed'; s.right = '6px'; s.bottom = '6px'; s.zIndex = '2147483647'; s.fontSize = '14px'; s.font = '12px/1 monospace'; s.padding = '6px 8px'; s.opacity = '.85'; s.background = '#222'; s.color = '#fff'; s.border = '1px solid #888'; s.borderRadius = '6px';
    box = document.createElement('div'); s = box.style; s.position = 'fixed'; s.left = '0'; s.right = '0'; s.bottom = '0'; s.height = '45%'; s.zIndex = '2147483646'; s.background = 'rgba(0,0,0,.92)'; s.color = '#9f9'; s.font = '10px/1.25 monospace'; s.display = 'none'; s.flexDirection = 'column';
    var bar = document.createElement('div'); bar.style.cssText = ''; bar.style.padding = '4px 50px 4px 4px'; bar.style.display = 'flex'; bar.style.gap = '6px';
    function b(label, fn) { var x = document.createElement('button'); x.type = 'button'; x.textContent = label; x.style.font = '11px monospace'; x.style.padding = '4px 8px'; x.addEventListener('click', fn); bar.appendChild(x); }
    b('Copy', function () { var t = buf.join('\n'); try { navigator.clipboard.writeText(t); log('copied'); } catch (e) { var r = document.createRange(); r.selectNodeContents(pre); var sl = getSelection(); sl.removeAllRanges(); sl.addRange(r); } });
    b('Clear', function () { buf = []; try { ls.setItem(K, '[]'); } catch (e) {} paint(); });
    b('Off', function () { document.cookie = 'pfdbg=0; path=/; max-age=0'; try { ls.removeItem(K); } catch (e) {} location.search = ''; });
    pre = document.createElement('pre'); pre.style.margin = '0'; pre.style.padding = '4px'; pre.style.overflow = 'auto'; pre.style.flex = '1'; pre.style.whiteSpace = 'pre-wrap'; pre.style.userSelect = 'text';
    box.appendChild(bar); box.appendChild(pre);
    btn.setAttribute('data-pfdbg', '1'); box.setAttribute('data-pfdbg', '1');
    btn.addEventListener('click', function () { open = !open; box.style.display = open ? 'flex' : 'none'; paint(); });
    host();
  }
  // a modal <dialog> (the Trail fight) is in the top layer above everything and makes the page inert: the panel must live inside it while it is open
  function host() {
    if (!box) return;
    var dl = null; try { dl = document.querySelector('dialog[open]:modal'); } catch (e) {}
    var h = dl || document.body; if (!h) return;
    if (box.parentNode !== h) { h.appendChild(box); h.appendChild(btn); }
  }
  function paint() {
    if (!box) { ui(); if (!box) return; }
    btn.textContent = 'bug ' + buf.length;
    if (open) { pre.textContent = buf.slice(-120).join('\n'); pre.scrollTop = pre.scrollHeight; }
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', paint); else paint();
  // the swap replaces <main> only, but keep the panel alive if something ever removes it
  setInterval(host, 500);
})();
