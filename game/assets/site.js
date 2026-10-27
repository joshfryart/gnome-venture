/* v1.8.2: native <dialog> helpers. showModal() gives a focus trap, Esc, the top layer, an inert page and Android back-to-close. */
function gvOpenDlg(d) {
  if (!d || d.open) return;
  if (d.showModal) d.showModal(); else d.setAttribute('open', '');
}
function gvCloseDlg(d) {
  if (!d || !d.open) return;
  if (d.close) d.close(); else d.removeAttribute('open');
}
/* v2.0.24: own icons in JS. gvIco() = <img> markup (no user text inside), gvIcoLine() = icon then plain text (safe: text goes in as a text node). Other files call them if present; no icon = they keep the emoji. */
var gvIcoBase = (function () { var s = document.currentScript; return s && s.src ? s.src.replace(/[^\/]*$/, '') + 'img/ico/' : 'assets/img/ico/'; })();
function gvIco(slug, alt) { return '<img class="ico pix" src="' + gvIcoBase + slug + '.png" alt="' + (alt || '') + '" width="16" height="16">'; }
function gvIcoNode(slug, alt) {
  var im = document.createElement('img');
  im.className = 'ico pix'; im.onerror = function () { im.onerror = null; im.src = gvIcoBase + slug + '.svg'; }; im.src = gvIcoBase + slug + '.png'; im.alt = alt || ''; im.width = 16; im.height = 16;
  return im;
}
/* True when the node's text starts with this emoji, or with its icon image (PHP swaps emoji to <img alt="">, so textContent has lost the emoji). */
function gvLeads(n, emoji, slug) {
  if (n.textContent.trim().indexOf(emoji) === 0) return true;
  var f = n.firstChild;
  if (f && f.nodeType === 3 && !f.nodeValue.trim()) f = f.nextSibling;
  return !!(f && f.nodeType === 1 && f.tagName === 'IMG' && (f.getAttribute('src') || '').indexOf('/' + slug + '.') > -1);
}
function gvIcoLine(el, slug, rest, alt) {
  if (!el) return;
  var im = document.createElement('img');
  im.className = 'ico pix'; im.onerror = function () { im.onerror = null; im.src = gvIcoBase + slug + '.svg'; }; im.src = gvIcoBase + slug + '.png'; im.alt = alt || ''; im.width = 16; im.height = 16;
  el.textContent = ''; el.appendChild(im); el.appendChild(document.createTextNode(rest));
}
/* v1.8.2: one reusable in-page dialog instead of confirm()/alert(). Text goes in with textContent, never innerHTML. */
var gvAskState = null;
function gvAskBox(msg, withCancel, onYes) {
  var st = gvAskState;
  if (!st) {
    var d = document.createElement('dialog');
    d.className = 'gvask';
    d.setAttribute('aria-label', 'Please confirm');
    var p = document.createElement('p'); p.className = 'gvmsg';
    var row = document.createElement('div'); row.className = 'gvbtns';
    var no = document.createElement('button'); no.type = 'button'; no.className = 'btn alt'; no.textContent = 'Cancel';
    var ok = document.createElement('button'); ok.type = 'button'; ok.className = 'btn'; ok.textContent = 'OK';
    row.appendChild(no); row.appendChild(ok); d.appendChild(p); d.appendChild(row);
    st = gvAskState = { d: d, p: p, no: no, ok: ok, cb: null };
    ok.addEventListener('click', function () { var cb = st.cb; st.cb = null; gvCloseDlg(d); if (cb) cb(); });
    no.addEventListener('click', function () { st.cb = null; gvCloseDlg(d); });
    d.addEventListener('close', function () { st.cb = null; });   // Esc / Android back = cancel
    document.body.appendChild(d);
  }
  st.cb = onYes || null;
  st.p.textContent = String(msg);
  st.no.hidden = !withCancel;
  gvOpenDlg(st.d);
  st.ok.focus();
}
function gvAsk(msg, onYes) { gvAskBox(msg, true, onYes); }
function gvSay(msg) { gvAskBox(msg, false, null); }

// Ask before submitting any form marked data-confirm (e.g. delete buttons). A button can carry data-confirm too.
/* v1.8.2: an in-page dialog instead of confirm(). Cancel stops here; OK re-submits the same form (same button, other submit listeners run) with a one-shot flag. */
document.addEventListener('submit', function (ev) {
  var f = ev.target;
  if (f.dataset && f.dataset.gvOk) { delete f.dataset.gvOk; return; }
  var sb = ev.submitter;
  var msg = f.getAttribute('data-confirm') || (sb && sb.getAttribute('data-confirm'));
  if (!msg) return;
  ev.preventDefault(); ev.stopImmediatePropagation();
  gvAsk(msg, function () {
    f.dataset.gvOk = '1';
    if (f.requestSubmit) { try { f.requestSubmit(sb || undefined); } catch (e) { f.requestSubmit(); } } else f.submit();
    setTimeout(function () { if (f.dataset) delete f.dataset.gvOk; }, 0);
  });
});

// Gnome creator: recolour the preview gnome as hat/beard swatches are picked.
document.addEventListener('change', function (ev) {
  var input = ev.target;
  var form = input.closest ? input.closest('[data-gnome-preview]') : null;
  if (!form || !input.getAttribute('data-part')) return;
  var part = input.getAttribute('data-part');
  form.querySelectorAll('svg.gnomeart [data-part="' + part + '"]').forEach(function (el) {
    el.setAttribute('fill', input.value);
    /* v2.0.31: pixel gnome layers are <image>s tinted by an SVG filter (see pixel_tint_filter() in includes/pixel_art.php): point them at a tint-<hex> filter, adding it if new */
    var im = el.tagName.toLowerCase() === 'g' ? el.querySelector('image[filter]') : null, svg = el.ownerSVGElement;
    var h = String(input.value).replace(/^#/, '').toLowerCase();
    if (h.length === 3) h = h[0] + h[0] + h[1] + h[1] + h[2] + h[2];
    if (!im || !svg || !/^[0-9a-f]{6}$/.test(h)) return;
    var NS = 'http://www.w3.org/2000/svg', uid = svg.getAttribute('data-tint') || '', id = 'tint-' + h + uid;   /* v2.0.36: ids carry the avatar's own suffix so a hidden twin cannot capture them */
    if (!svg.querySelector('filter[id="' + id + '"]')) {
      var defs = svg.querySelector('defs') || svg.insertBefore(document.createElementNS(NS, 'defs'), svg.firstChild);
      var f = document.createElementNS(NS, 'filter'), m = document.createElementNS(NS, 'feColorMatrix');
      var c = [0, 2, 4].map(function (i) { return Math.round(parseInt(h.substr(i, 2), 16) / 255 * 1.25 * 10000) / 10000; });
      f.setAttribute('id', id); f.setAttribute('color-interpolation-filters', 'sRGB');
      m.setAttribute('type', 'matrix'); m.setAttribute('values', c[0] + ' 0 0 0 0  0 ' + c[1] + ' 0 0 0  0 0 ' + c[2] + ' 0 0  0 0 0 1 0');
      f.appendChild(m); defs.appendChild(f);
    }
    im.setAttribute('filter', 'url(#' + id + ')');
  });
});

// Adventure bar: count down to arrival, then show the Arrive button. (Run again after an in-place update.)
// v2.0.1: every [data-countdown] on the page ticks (the top bar AND the "in sight" card); at zero: [data-show-at-zero] appears, [data-hide-at-zero] goes.
function gvCountdown() {
  document.querySelectorAll('[data-countdown]').forEach(function (el) {
    if (el.getAttribute('data-ticking')) return;
    el.setAttribute('data-ticking', '1');
    var left = parseInt(el.getAttribute('data-countdown'), 10) || 0;
    var tick = function () {
      if (left <= 0) {
        el.textContent = 'now';
        document.querySelectorAll('[data-show-at-zero]').forEach(function (f) { f.hidden = false; });
        document.querySelectorAll('[data-hide-at-zero]').forEach(function (f) { f.hidden = true; });
        return;
      }
      var m = Math.floor(left / 60), s = left % 60;
      el.textContent = (m ? m + 'm ' : '') + (s < 10 && m ? '0' : '') + s + 's';
      left--;
      setTimeout(tick, 1000);
    };
    tick();
  });
}
gvCountdown();

/* v1.0.2: the walk bar folds to one line. A fight or a problem opens it; otherwise it keeps the way the player last left it
   (this tab only), and a wide screen starts it open. Clicks on the line's own buttons don't count as folding. */
function gvAdvFold() {
  var d = document.querySelector('.advfold');
  if (!d || d.getAttribute('data-wired')) return;
  d.setAttribute('data-wired', '1');
  var v = null;
  try { v = sessionStorage.getItem('gv-adv'); } catch (e) { /* storage may be off */ }
  // v1.4.6: a NEW fight/problem opens the bar once. Going to another page keeps it folded (the line still says ⚔️ Fight!),
  // but in-place updates on the same page (attack, solve…) keep it the way it was.
  var busy = d.getAttribute('data-busy'), last = window.gvAdvLast || null;   // gvAdvLast only survives in-place updates, not page changes
  if (busy && last) d.open = last.key !== busy ? true : last.open;
  else if (busy) d.open = false;
  else if (v !== null) d.open = v === '1';
  else d.open = !!(window.matchMedia && window.matchMedia('(min-width: 1200px)').matches);
  var sm = d.querySelector('summary');
  if (sm) sm.addEventListener('click', function (ev) {
    if (ev.target.closest('form, button, a')) return;
    try { sessionStorage.setItem('gv-adv', d.open ? '0' : '1'); } catch (e) { /* fine */ }
  });
  window.gvAdvLast = { open: d.open, key: busy };
  d.addEventListener('toggle', function () { window.gvAdvLast = { open: d.open, key: busy }; });
}
gvAdvFold();

// BBCode editor for news and pages (admin, v0.7.18): toolbar, image upload and a live preview.
(function () {
  document.querySelectorAll('textarea[data-bbcode]').forEach(function (ta) {
    var bar = document.createElement('div');
    bar.className = 'bbbar';
    var preview = document.createElement('div');
    preview.className = 'bbpreview';
    var file = document.createElement('input');
    file.type = 'file';
    file.accept = 'image/png,image/jpeg,image/gif,image/webp';
    file.hidden = true;
    ta.parentNode.insertBefore(bar, ta);
    ta.parentNode.insertBefore(preview, ta.nextSibling);
    ta.parentNode.insertBefore(file, preview);

    function wrap(open, close, placeholder) {
      var s = ta.selectionStart, e = ta.selectionEnd, sel = ta.value.slice(s, e) || placeholder || '';
      ta.value = ta.value.slice(0, s) + open + sel + close + ta.value.slice(e);
      ta.focus();
      ta.selectionStart = s + open.length;
      ta.selectionEnd = s + open.length + sel.length;
      refresh();
    }
    var buttons = [
      ['B', 'Bold', function () { wrap('[b]', '[/b]', 'bold'); }],
      ['I', 'Italic', function () { wrap('[i]', '[/i]', 'italic'); }],
      ['U', 'Underline', function () { wrap('[u]', '[/u]', 'underlined'); }],
      ['H', 'Heading', function () { wrap('[h]', '[/h]', 'Heading'); }],
      ['⇔', 'Centre', function () { wrap('[center]', '[/center]', 'centred text'); }],
      ['❝', 'Quote', function () { wrap('[quote]', '[/quote]', 'quote'); }],
      ['•', 'List', function () {
        var s = ta.selectionStart, e = ta.selectionEnd, lines = (ta.value.slice(s, e) || 'first\nsecond').split('\n');
        var txt = '[list]\n' + lines.map(function (l) { return '[*]' + l; }).join('\n') + '\n[/list]';
        ta.value = ta.value.slice(0, s) + txt + ta.value.slice(e);
        ta.focus();
        refresh();
      }],
      ['🔗', 'Link', 'ico-link', function () {
        var u = window.prompt('Link address (https://…)', 'https://');
        if (u && /^https?:\/\/\S+$/.test(u)) wrap('[url=' + u + ']', '[/url]', 'link text');
      }],
      ['🖼', 'Image', 'ico-palette', function () { file.click(); }]
    ];
    buttons.forEach(function (b) {
      var btn = document.createElement('button');
      btn.type = 'button';
      if (b.length > 3 && window.gvIcoNode) btn.appendChild(gvIcoNode(b[2]));   // v2.0.25: our own icon for the link and image buttons
      else btn.textContent = b[0];
      btn.title = b[1];
      btn.setAttribute('aria-label', b[1]);
      btn.addEventListener('click', b[b.length - 1]);
      bar.appendChild(btn);
    });
    var status = document.createElement('span');
    status.className = 'bbstatus';
    bar.appendChild(status);

    file.addEventListener('change', function () {
      if (!file.files.length) return;
      var fd = new FormData();
      fd.append('csrf', ta.dataset.csrf);
      fd.append('ajax', '1');
      fd.append('image', file.files[0]);
      status.textContent = 'Uploading…';
      fetch(ta.dataset.upload, { method: 'POST', body: fd, credentials: 'same-origin' })
        .then(function (r) { return r.json(); })
        .then(function (j) {
          status.textContent = j.ok ? 'Image added.' : (j.error || 'Upload failed.');
          if (j.ok) wrap(j.bbcode, '', '');
        })
        .catch(function () { status.textContent = 'Upload failed.'; });
      file.value = '';
    });

    var timer = null;
    function refresh() {
      clearTimeout(timer);
      timer = setTimeout(function () {
        var fd = new FormData();
        fd.append('csrf', ta.dataset.csrf);
        fd.append('text', ta.value);
        fetch(ta.dataset.preview, { method: 'POST', body: fd, credentials: 'same-origin' })
          .then(function (r) { return r.ok ? r.text() : ''; })
          .then(function (html) { preview.innerHTML = html; });   // the server has already made it safe
      }, 350);
    }
    ta.addEventListener('input', refresh);
    refresh();
  });
})();

// The yard designer (v0.7.33): drag and drop, or tap to pick and tap to place. Everything is checked
// again by the server when saved; this only keeps the picture honest while you arrange things.
(function () {
  var yard = document.querySelector('[data-yard-edit]');
  if (!yard) return;
  var W = +yard.getAttribute('data-w'), H = +yard.getAttribute('data-h');
  var tray = document.querySelector('[data-tray]');
  var tools = document.querySelector('[data-yard-tools]');
  var statusEl = document.querySelector('[data-yard-status]');
  var form = document.getElementById('yardsave');
  var pieces = {}, qty = {}, newN = 0, undoStack = [], sel = [], traySel = null, dirty = false, drag = null;
  function btn(a) { return tools.querySelector('[data-act="' + a + '"]'); }
  var multi = btn('multi');
  function say(t) { statusEl.textContent = t; }
  function setPos(el, p) {
    var keep = el.className.split(/\s+/).filter(function (c) { return c && !/^(g[xywh]\d+|r(90|180|270)|off)$/.test(c); });
    if (p.x < 0 || p.y < 0) keep.push('off');
    else keep.push('gx' + (p.x + 1), 'gy' + (p.y + 1), 'gw' + p.w, 'gh' + p.h);
    if (p.rot) keep.push('r' + p.rot);
    el.className = keep.join(' ');
  }
  function num(el, a) { return +(el.getAttribute(a) || 0); }
  yard.querySelectorAll('[data-k]').forEach(function (el) {
    var k = el.getAttribute('data-k');
    pieces[k] = { k: k, el: el, x: num(el, 'data-x'), y: num(el, 'data-y'), w: num(el, 'data-w') || 1, h: num(el, 'data-h') || 1,
      rot: num(el, 'data-rot'), move: el.getAttribute('data-move') === '1', kind: el.getAttribute('data-kind'), id: num(el, 'data-id'),
      item: num(el, 'data-item'), tx: num(el, 'data-tx'), ty: num(el, 'data-ty'), name: el.getAttribute('data-name') || 'That',
      fam: el.getAttribute('data-fam') || '', shape: el.getAttribute('data-shape') || '', img: el.getAttribute('data-img') || '', mask: -1 };
  });
  var snapBox = btn('snap'), gridBox = btn('grid');
  try { if (localStorage.getItem('gv-yard-grid') === '1') { gridBox.checked = true; yard.classList.add('showgrid'); } } catch (e) { /* storage may be off */ }
  gridBox.addEventListener('change', function () {
    yard.classList.toggle('showgrid', gridBox.checked);
    try { localStorage.setItem('gv-yard-grid', gridBox.checked ? '1' : '0'); } catch (e) { /* storage may be off */ }
  });

  // Fences, walls and hedges join their neighbours (v0.9.5). Same rules and drawing as includes/yard.php.
  var MASK = { end: 2, straight: 10, corner: 6, tee: 14, cross: 15 }, SHAPES = ['', 'end', 'straight', 'corner', 'tee', 'cross'];
  var SHAPE_NAME = { '': 'automatic', end: 'end', straight: 'straight', corner: 'corner', tee: 'T', cross: 'cross' };
  function turn(m, q) { for (var i = 0; i < q % 4; i++) m = ((m << 1) | (m >> 3)) & 15; return m; }
  function shapeOf(m) {
    var n = (m & 1) + ((m >> 1) & 1) + ((m >> 2) & 1) + ((m >> 3) & 1);
    return n <= 1 ? 'end' : n === 2 ? (m === 5 || m === 10 ? 'straight' : 'corner') : n === 3 ? 'tee' : 'cross';
  }
  function joinsWith(a, b) { return a === b || (a === 'gate' && (b === 'fence' || b === 'wall')) || (b === 'gate' && (a === 'fence' || a === 'wall')); }
  function joinSvg(fam, m) {
    var s = '<svg class="fz fz-' + fam + '" viewBox="0 0 100 100" aria-hidden="true" focusable="false">', arms = { 1: 'M50 50V0', 2: 'M50 50H100', 4: 'M50 50V100', 8: 'M50 50H0' };
    [1, 2, 4, 8].forEach(function (b) { if (m & b) s += '<path class="rl" d="' + arms[b] + '"/><path class="pk" d="' + arms[b] + '"/>'; });
    if (fam === 'gate') {
      s += (m & 5) && !(m & 10)
        ? '<rect class="gt" x="34" y="22" width="32" height="56" rx="3"/><path class="gb" d="M50 26V74M38 36H62M38 50H62M38 64H62"/><circle class="po" cx="50" cy="20" r="7"/><circle class="po" cx="50" cy="80" r="7"/>'
        : '<rect class="gt" x="22" y="34" width="56" height="32" rx="3"/><path class="gb" d="M26 50H74M36 38V62M50 38V62M64 38V62"/><circle class="po" cx="20" cy="50" r="7"/><circle class="po" cx="80" cy="50" r="7"/>';
    } else s += '<circle class="po" cx="50" cy="50" r="' + (fam === 'hedge' ? 20 : fam === 'wall' ? 18 : 11) + '"/>';
    return s + '</svg>';
  }
  function joinAll() {
    var cells = {}, k, p;
    for (k in pieces) { p = pieces[k]; if (p.fam && p.x >= 0) cells[p.x + ',' + p.y] = p.fam; }
    for (k in pieces) {
      p = pieces[k];
      if (!p.fam || p.x < 0) continue;
      var m = 0;
      if (MASK[p.shape]) m = turn(MASK[p.shape], p.rot / 90);
      else {
        [[1, 0, -1], [2, 1, 0], [4, 0, 1], [8, -1, 0]].forEach(function (a) { var n = cells[(p.x + a[1]) + ',' + (p.y + a[2])]; if (n && joinsWith(p.fam, n)) m |= a[0]; });
        if (!m) m = turn(10, p.rot / 90);
      }
      if (p.mask === m) continue;
      p.mask = m;
      var sh = p.fam === 'gate' ? 'gate' : shapeOf(m), q = 0, base = MASK[p.fam === 'gate' ? 'straight' : shapeOf(m)];
      while (q < 3 && turn(base, q) !== m) q++;
      p.el.classList.add('fj');
      if (p.img) {
        var im = p.el.querySelector('img.yimg');
        if (!im) { im = document.createElement('img'); im.className = 'yimg'; im.alt = ''; p.el.appendChild(im); }
        im.src = p.img.replace(/\{shape\}|%7Bshape%7D/i, sh);
        ['ra0', 'ra90', 'ra180', 'ra270'].forEach(function (c) { p.el.classList.remove(c); });
        p.el.classList.add('fi', 'ra' + q * 90);
      } else {
        var old = p.el.querySelector('svg.fz'), t = document.createElement('div');
        t.innerHTML = joinSvg(p.fam, m);
        if (old) p.el.replaceChild(t.firstChild, old); else p.el.appendChild(t.firstChild);
      }
    }
  }
  // Snap to beds: a decoration dropped one square away from a bed slides up against its edge (so its bonus reaches)
  function touchesBed(r) {
    for (var k in pieces) {
      var b = pieces[k];
      if (b.kind !== 'bed' || b.x < 0) continue;
      if ((r.x + r.w === b.x || b.x + 1 === r.x) && b.y >= r.y && b.y < r.y + r.h) return true;
      if ((r.y + r.h === b.y || b.y + 1 === r.y) && b.x >= r.x && b.x < r.x + r.w) return true;
    }
    return false;
  }
  function snapped(r, skip, cls) {
    if (!snapBox.checked || /(^|\s)t-(path|fence)(\s|$)/.test(cls) || touchesBed(r)) return r;
    var tries = [[0, -1], [0, 1], [-1, 0], [1, 0]];
    for (var i = 0; i < tries.length; i++) {
      var c = { x: r.x + tries[i][0], y: r.y + tries[i][1], w: r.w, h: r.h };
      if (fits(c, skip) && touchesBed(c)) return c;
    }
    return r;
  }
  tray.querySelectorAll('.trayitem[data-item]').forEach(function (b) { qty[b.getAttribute('data-item')] = num(b, 'data-qty'); });

  function overlaps(a, b) { return a.x < b.x + b.w && b.x < a.x + a.w && a.y < b.y + b.h && b.y < a.y + a.h; }
  function fits(r, skip) {
    if (r.x < 0 || r.y < 0 || r.x + r.w > W || r.y + r.h > H) return false;
    for (var k in pieces) {
      var p = pieces[k];
      if (p.x < 0 || skip.indexOf(k) >= 0) continue;
      if (overlaps(r, p)) return false;
    }
    return true;
  }
  function snap() { var s = {}; for (var k in pieces) { var p = pieces[k]; s[k] = [p.x, p.y, p.w, p.h, p.rot, p.shape]; } return s; }
  function remember() { undoStack.push(snap()); if (undoStack.length > 150) undoStack.shift(); btn('undo').disabled = false; dirty = true; }
  function restore(s) {
    for (var k in pieces) {
      var p = pieces[k], v = s[k] || [-1, -1, p.w, p.h, p.rot, p.shape];
      p.x = v[0]; p.y = v[1]; p.w = v[2]; p.h = v[3]; p.rot = v[4]; p.shape = v[5] || '';
      setPos(p.el, p);
    }
  }
  function spare(item) {   // how many of an item are still free to place: unplaced new ones, plus put-away placed ones
    var n = qty[item] || 0;
    for (var k in pieces) {
      var p = pieces[k];
      if (p.item != item || p.kind !== 'decor') continue;
      if (!p.id && p.x >= 0) n--;
      if (p.id && p.x < 0) n++;
    }
    return n;
  }
  function refreshTray() {
    tray.querySelectorAll('.trayitem[data-item]').forEach(function (b) {
      var n = spare(b.getAttribute('data-item'));
      b.querySelector('[data-left]').textContent = '×' + n;
      b.disabled = n <= 0;
      if (n <= 0 && traySel && traySel.btn === b) traySel = null;
    });
    tray.querySelectorAll('.trayitem[data-key]').forEach(function (b) {
      var p = pieces[b.getAttribute('data-key')];
      b.hidden = !p || p.x >= 0;
      if (b.hidden && traySel && traySel.btn === b) traySel = null;
    });
  }
  function paintSel() {
    for (var k in pieces) pieces[k].el.classList.toggle('picked', sel.indexOf(k) >= 0);
    tray.querySelectorAll('.trayitem').forEach(function (b) { b.classList.toggle('picked', !!traySel && traySel.btn === b); });
    var one = sel.length ? pieces[sel[0]] : null;
    btn('rotate').disabled = !(sel.length === 1 && one.kind !== 'bed');
    btn('shape').disabled = !(sel.length === 1 && one.fam);
    joinAll();
    btn('away').disabled = !sel.length || sel.some(function (k) { return pieces[k].kind !== 'decor'; });
    if (traySel) say('Tap a square in the yard to place ' + traySel.name + '. Tap it in the tray again to stop.');
    else if (sel.length === 1 && one.fam) say(one.name + ' picked (shape: ' + SHAPE_NAME[one.shape] + (one.shape ? '' : ', ' + shapeOf(one.mask)) + '). Shape picks a shape by hand; Rotate turns a lone piece or a chosen shape.');
    else if (sel.length === 1) say(one.name + ' picked. Drag it, or tap an empty square to move it there.');
    else if (sel.length > 1) say(sel.length + ' things picked. Drag one to move them all, or tap an empty square.');
    else say('Tap or drag something to start.');
  }
  function cellAt(ev) {
    var r = yard.getBoundingClientRect();
    return { x: Math.floor((ev.clientX - r.left) / r.width * W), y: Math.floor((ev.clientY - r.top) / r.height * H),
      inside: ev.clientX >= r.left && ev.clientX < r.right && ev.clientY >= r.top && ev.clientY < r.bottom };
  }
  function overTray(ev) {
    var r = tray.getBoundingClientRect();
    return ev.clientX >= r.left && ev.clientX <= r.right && ev.clientY >= r.top && ev.clientY <= r.bottom;
  }
  function groupFits(keys, dx, dy) {
    return keys.every(function (k) { var p = pieces[k]; return fits({ x: p.x + dx, y: p.y + dy, w: p.w, h: p.h }, keys); });
  }
  function shift(keys, dx, dy) {
    if (keys.length === 1 && pieces[keys[0]].kind === 'decor' && (dx || dy)) {
      var sp = pieces[keys[0]], sr = snapped({ x: sp.x + dx, y: sp.y + dy, w: sp.w, h: sp.h }, [sp.k], sp.el.className);
      dx = sr.x - sp.x; dy = sr.y - sp.y;
    }
    if (!groupFits(keys, dx, dy)) { say('That doesn’t fit there.'); return false; }
    if (!dx && !dy) return true;
    remember();
    keys.forEach(function (k) { var p = pieces[k]; p.x += dx; p.y += dy; setPos(p.el, p); });
    return true;
  }
  function putAway(keys) {
    if (keys.some(function (k) { return pieces[k].kind !== 'decor'; })) { say('Only decorations go back in the tray. Buildings and beds can only be moved.'); return; }
    remember();
    keys.forEach(function (k) { var p = pieces[k]; p.x = -1; p.y = -1; setPos(p.el, p); });
    sel = [];
    refreshTray();
    paintSel();
  }
  function trayPiece(b) {   // the piece a tray button would place (an existing one if possible)
    var key = b.getAttribute('data-key');
    if (key) return pieces[key];
    var item = b.getAttribute('data-item');
    for (var k in pieces) { var p = pieces[k]; if (p.kind === 'decor' && p.x < 0 && p.item == item) return p; }
    return null;
  }
  function placeFromTray(b, x, y) {
    var p = trayPiece(b);
    var w = p ? p.w : num(b, 'data-w') || 1, h = p ? p.h : num(b, 'data-h') || 1;
    if (fits({ x: x, y: y, w: w, h: h }, p ? [p.k] : [])) {
      var sr = snapped({ x: x, y: y, w: w, h: h }, p ? [p.k] : [], p ? p.el.className : 't-' + b.getAttribute('data-type'));
      x = sr.x; y = sr.y;
    }
    if (!fits({ x: x, y: y, w: w, h: h }, p ? [p.k] : [])) { say('That doesn’t fit there.'); return; }
    remember();
    if (!p) {
      var k = 'n' + (++newN), el = document.createElement('div');
      el.className = 'yo dec t-' + b.getAttribute('data-type') + ' d-' + b.getAttribute('data-look');
      el.title = b.getAttribute('data-name');
      el.setAttribute('data-k', k);
      if (b.getAttribute('data-icon')) { var s = document.createElement('span'); s.className = 'oi'; s.textContent = b.getAttribute('data-icon'); el.appendChild(s); }
      var bimg = b.getAttribute('data-img') || '', bfam = b.getAttribute('data-fam') || '';
      if (bimg && !bfam) { var im0 = document.createElement('img'); im0.className = 'yimg'; im0.alt = ''; im0.src = bimg.replace(/\{shape\}|%7Bshape%7D/i, 'straight'); el.appendChild(im0); el.className += ' fi'; }
      yard.appendChild(el);
      p = pieces[k] = { k: k, el: el, x: -1, y: -1, w: w, h: h, rot: 0, move: true, kind: 'decor', id: 0, item: num(b, 'data-item'), name: b.getAttribute('data-name'),
        fam: bfam, shape: '', img: bfam ? bimg : '', mask: -1 };
    }
    p.x = x; p.y = y;
    setPos(p.el, p);
    if (b.getAttribute('data-key')) { traySel = null; sel = [p.k]; }
    refreshTray();
    paintSel();
  }
  function tapPiece(k) {
    traySel = null;
    if (multi.checked) {
      var i = sel.indexOf(k);
      if (i >= 0) sel.splice(i, 1); else sel.push(k);
    } else {
      sel = sel.length === 1 && sel[0] === k ? [] : [k];
    }
    paintSel();
  }
  function tapTray(b) {
    sel = [];
    traySel = traySel && traySel.btn === b ? null : { btn: b, name: b.getAttribute('data-name') || (trayPiece(b) || {}).name || 'it' };
    paintSel();
  }

  yard.addEventListener('pointerdown', function (ev) {
    var el = ev.target.closest('[data-k]');
    if (!el || ev.button > 0) return;
    var p = pieces[el.getAttribute('data-k')];
    if (!p) return;
    if (!p.move) { say(p.name + ': something is growing here, so this bed stays put.'); return; }
    ev.preventDefault();
    var c = cellAt(ev);
    drag = { kind: 'piece', lead: p.k, keys: sel.length > 1 && sel.indexOf(p.k) >= 0 ? sel.slice() : [p.k],
      sx: ev.clientX, sy: ev.clientY, moved: false, gx: c.x - p.x, gy: c.y - p.y };
    try { el.setPointerCapture(ev.pointerId); } catch (e) { /* older browsers */ }
  });
  tray.addEventListener('pointerdown', function (ev) {
    var b = ev.target.closest('.trayitem');
    if (!b || b.disabled || ev.button > 0) return;
    ev.preventDefault();
    drag = { kind: 'tray', btn: b, sx: ev.clientX, sy: ev.clientY, moved: false, ghost: null };
    try { b.setPointerCapture(ev.pointerId); } catch (e) { /* older browsers */ }
  });
  document.addEventListener('pointermove', function (ev) {
    if (!drag) return;
    if (!drag.moved && Math.abs(ev.clientX - drag.sx) + Math.abs(ev.clientY - drag.sy) < 6) return;
    drag.moved = true;
    var c = cellAt(ev);
    if (drag.kind === 'piece') {
      var lead = pieces[drag.lead], dx = c.x - drag.gx - lead.x, dy = c.y - drag.gy - lead.y;
      var ok = c.inside && groupFits(drag.keys, dx, dy);
      drag.dx = dx; drag.dy = dy; drag.ok = ok; drag.tray = overTray(ev);
      drag.keys.forEach(function (k) {
        var p = pieces[k];
        setPos(p.el, { x: c.inside ? p.x + dx : p.x, y: c.inside ? p.y + dy : p.y, w: p.w, h: p.h, rot: p.rot });
        p.el.classList.add('dragging');
        p.el.classList.toggle('bad', !ok && !(drag.tray && p.kind === 'decor'));
      });
    } else {
      var b = drag.btn, tp = trayPiece(b);
      var w = tp ? tp.w : num(b, 'data-w') || 1, h = tp ? tp.h : num(b, 'data-h') || 1;
      if (!drag.ghost) {
        drag.ghost = document.createElement('div');
        drag.ghost.className = 'yo ghost';
        drag.ghost.textContent = b.getAttribute('data-icon') || (tp && tp.el.textContent) || '▢';
        yard.appendChild(drag.ghost);
      }
      drag.x = c.x; drag.y = c.y;
      drag.ok = c.inside && fits({ x: c.x, y: c.y, w: w, h: h }, tp ? [tp.k] : []);
      setPos(drag.ghost, { x: c.inside ? c.x : -1, y: c.y, w: w, h: h, rot: 0 });
      drag.ghost.classList.toggle('bad', !drag.ok);
    }
  });
  function endDrag(ev, cancelled) {
    if (!drag) return;
    var d = drag;
    drag = null;
    if (d.kind === 'piece') {
      d.keys.forEach(function (k) { var p = pieces[k]; p.el.classList.remove('dragging', 'bad'); setPos(p.el, p); });
      if (cancelled) return;
      if (!d.moved) { tapPiece(d.lead); return; }
      if (d.tray) { putAway(d.keys); return; }
      if (d.ok && shift(d.keys, d.dx, d.dy)) { sel = d.keys.length > 1 ? d.keys : [d.lead]; paintSel(); }
      else say('That doesn’t fit there.');
    } else {
      if (d.ghost) d.ghost.parentNode.removeChild(d.ghost);
      if (cancelled) return;
      if (!d.moved) { tapTray(d.btn); return; }
      if (d.ok) placeFromTray(d.btn, d.x, d.y);
      else if (cellAt(ev).inside) say('That doesn’t fit there.');
    }
  }
  document.addEventListener('pointerup', function (ev) { endDrag(ev, false); });
  document.addEventListener('pointercancel', function (ev) { endDrag(ev, true); });
  yard.addEventListener('click', function (ev) {
    if (ev.target.closest('[data-k]')) return;
    var c = cellAt(ev);
    if (!c.inside) return;
    if (traySel) { placeFromTray(traySel.btn, c.x, c.y); return; }
    if (sel.length) {
      var lead = pieces[sel[0]];
      if (shift(sel, c.x - lead.x, c.y - lead.y)) paintSel();
    }
  });
  tray.addEventListener('click', function (ev) { if (ev.target.closest('.trayitem')) ev.preventDefault(); });

  btn('rotate').addEventListener('click', rotate);
  function rotate() {
    if (sel.length !== 1) return;
    var p = pieces[sel[0]];
    if (p.kind === 'bed') return;
    if (!fits({ x: p.x, y: p.y, w: p.h, h: p.w }, [p.k])) { say('There’s no room to turn it here.'); return; }
    remember();
    var w = p.w; p.w = p.h; p.h = w;
    p.rot = (p.rot + 90) % 360;
    setPos(p.el, p);
    paintSel();
  }
  btn('shape').addEventListener('click', function () {
    if (sel.length !== 1 || !pieces[sel[0]].fam) return;
    var p = pieces[sel[0]];
    remember();
    p.shape = SHAPES[(SHAPES.indexOf(p.shape) + 1) % SHAPES.length];
    p.mask = -1;
    paintSel();
  });
  btn('away').addEventListener('click', function () { if (sel.length) putAway(sel.slice()); });
  btn('undo').addEventListener('click', undo);
  function undo() {
    var s = undoStack.pop();
    if (!s) return;
    restore(s);
    sel = []; traySel = null;
    btn('undo').disabled = !undoStack.length;
    dirty = undoStack.length > 0;
    refreshTray();
    paintSel();
    say('Undone.');
  }
  multi.addEventListener('change', function () { if (!multi.checked && sel.length > 1) sel = [sel[0]]; paintSel(); });
  btn('save').addEventListener('click', function () {
    var out = { o: [], n: [], t: [] };
    for (var k in pieces) {
      var p = pieces[k];
      if (p.kind === 'bed') out.t.push([p.tx, p.ty, p.x, p.y]);
      else if (p.x < 0) continue;
      else if (p.id) out.o.push([p.id, p.x, p.y, p.rot, p.shape || '']);
      else out.n.push([p.item, p.x, p.y, p.rot, p.shape || '']);
    }
    form.querySelector('[name="layout"]').value = JSON.stringify(out);
    dirty = false;
    form.submit();
  });
  document.addEventListener('keydown', function (ev) {
    if (/^(INPUT|SELECT|TEXTAREA)$/.test((ev.target.tagName || ''))) return;
    if ((ev.ctrlKey || ev.metaKey) && ev.key === 'z') { ev.preventDefault(); undo(); }
    else if (ev.key === 'r' || ev.key === 'R') rotate();
    else if (ev.key === 'Delete' || ev.key === 'Backspace') { if (sel.length) { ev.preventDefault(); putAway(sel.slice()); } }
    else if (ev.key === 'Escape') { sel = []; traySel = null; paintSel(); }
  });
  window.addEventListener('beforeunload', function (ev) { if (dirty) { ev.preventDefault(); ev.returnValue = ''; } });
  refreshTray();
  joinAll();
})();

// In-place updates (v0.7.39): on game and adventure pages, buttons send their form in the background and only the
// page's content is swapped, so you keep your place instead of reloading and scrolling. Anything unusual (another
// page, an error, an old browser) falls back to a normal page load.
// v0.7.46: links marked data-inplace (the squares of your garden) load the same way.
(function () {
  if (!document.body.hasAttribute('data-ajax') || !window.fetch || !window.DOMParser) return;
  var busy = false;
  function swap(doc, sel) {
    var a = document.querySelector(sel), b = doc.querySelector(sel);
    if (a && b) a.innerHTML = b.innerHTML;
    else if (a && !b) a.parentNode.removeChild(a);
  }
  function toast(nodes) {
    if (!nodes.length) return;
    gvShowToasts(nodes.map(function (n) { return n.cloneNode(true); }));
  }
  function foldKey(d) {
    if (d.id) return '#' + d.id;
    var sm = d.querySelector('summary');
    return d.className + '|' + (sm ? sm.textContent.trim().slice(0, 40) : '');
  }
  // Fetch a page of this same address, swap in its content, keep the scroll position.
  function load(url, init, after, fallback) {
    busy = true;
    var y = window.scrollY;
    init.credentials = 'same-origin';
    init.headers = { 'X-Requested-With': 'fetch' };
    fetch(url, init)
      .then(function (r) {
        if (!r.ok) { location.reload(); return null; }   // the server already did it: just show the page
        var to = new URL(r.url);
        if (to.pathname !== location.pathname) { location.href = r.url; return null; }
        return r.text().then(function (html) { return { html: html, url: r.url }; });
      })
      .then(function (res) {
        busy = false;
        if (!res) return;
        var doc = new DOMParser().parseFromString(res.html, 'text/html');
        if (!doc.querySelector('main')) { location.href = res.url; return; }
        // Keep folds the player had open (e.g. buildings, hired help) open after the swap
        var openKeys = Array.prototype.map.call(document.querySelectorAll('main details[open]'), foldKey);
        swap(doc, 'main');
        document.querySelectorAll('main details').forEach(function (d) { if (openKeys.indexOf(foldKey(d)) >= 0) d.open = true; });
        swap(doc, '.statusstrip');
        swap(doc, '.userbar');
        swap(doc, '.advbar');
        swap(doc, '.railsrv');   // v0.9.6: pots, boosts and chores in the right column
        if (doc.title) document.title = doc.title;
        if (res.url !== location.href) history.replaceState(history.state, '', res.url);
        shownAt = location.pathname + location.search;
        window.scrollTo(0, y);
        var main = document.querySelector('main');
        // Messages appear at the top of the page: if that's out of view, show them as a toast too
        var msgs = Array.prototype.slice.call(main.querySelectorAll('.flash, .prizebox, .newpages'));
        if (msgs.length && msgs[0].getBoundingClientRect().bottom < 0) toast(msgs);
        // v0.7.54: the message list lives outside the page content; toast new ones when the list is out of sight
        swap(doc, '.msglog.mlside');
        swap(doc, '.msglog.top');
        if (window.gvRailFit) window.gvRailFit();
        var fresh = gvVisibleLog().querySelectorAll('li.ml.new');
        if (fresh.length && !gvInView(fresh[0])) toast(Array.prototype.slice.call(fresh).map(gvToastNode));
        gvCountdown();
        gvAdvFold();   // v1.0.2
        gvMaps();
        gvRegionZoom();
        gvMycZoom();   // v1.6.4
        gvMycApply();   // v1.6.0: keep the map filter after an in-place load
        gvMycScroll();   // v1.6.1
        gvMetro();
        gvRouteFade();   // v2.0.57
        gvGarden();
        gvAlmTabs();
        gvGatherGames();
        if (after) after();
      })
      .catch(function () { busy = false; fallback(); });
  }
  document.addEventListener('submit', function (ev) {
    var form = ev.target;
    if (ev.defaultPrevented || busy || (form.method || '').toLowerCase() !== 'post' || form.hasAttribute('data-noajax')) return;
    if (form.enctype === 'multipart/form-data') return;
    var main = document.querySelector('main');
    if (!main || !main.contains(form) && !form.closest('.advbar')) return;
    var action = new URL(form.getAttribute('action') || location.href, location.href);
    if (action.origin !== location.origin) return;
    ev.preventDefault();
    var fd = new FormData(form);
    var sub = ev.submitter;
    if (sub && sub.name && !fd.has(sub.name)) fd.append(sub.name, sub.value);
    form.classList.add('sending');
    load(action.href, { method: 'POST', body: new URLSearchParams(fd) }, null, function () {
      form.classList.remove('sending'); form.setAttribute('data-noajax', '1');
      form.requestSubmit ? form.requestSubmit(sub || undefined) : form.submit();
    });
  });
  // v1.6.3: a dropdown row (form.pickform, GET) loads in place like a tab link does
  document.addEventListener('submit', function (ev) {
    var form = ev.target;
    if (ev.defaultPrevented || busy || !form.classList || !form.classList.contains('pickform') || (form.method || '').toLowerCase() !== 'get') return;
    var main = document.querySelector('main');
    if (!main || !main.contains(form)) return;
    var to = new URL(form.getAttribute('action') || location.href, location.href);
    if (to.origin !== location.origin || to.pathname !== location.pathname) return;
    ev.preventDefault();
    new FormData(form).forEach(function (v, k) { to.searchParams.set(k, v); });
    history.pushState({ gv: 1 }, '', to.href);
    form.classList.add('sending');
    load(to.href, { method: 'GET' }, null, function () { location.href = to.href; });
  });
  document.addEventListener('click', function (ev) {
    var a = ev.target.closest ? ev.target.closest('a[data-inplace], main nav.tabs a, main nav.chips a, main nav.ccfilter a') : null;
    if (!a || ev.defaultPrevented || ev.button !== 0 || ev.ctrlKey || ev.metaKey || ev.shiftKey || ev.altKey) return;
    var to = new URL(a.href, location.href);
    if (to.origin !== location.origin || to.pathname !== location.pathname) return;
    ev.preventDefault();
    if (busy) return;
    a.classList.add('sending');
    var isTab = !a.hasAttribute('data-inplace');
    if (isTab) history.pushState({ gv: 1 }, '', to.href);
    load(to.href, { method: 'GET' }, function () {
      // On a phone the square's panel sits under the yard: bring it into view if it's off the screen
      var panel = document.querySelector('[data-inplace-show]');
      // v1.6.2: scroll to it unless its top part (the actions) is already on screen above the bottom bars
      if (panel && a.hasAttribute('data-inplace') && panel.getBoundingClientRect().top > window.innerHeight * 0.55) panel.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }, function () { location.href = a.href; });
  });
  // Back/forward after an in-place tab change: load that address properly
  // (Jumping to a #link inside the page also fires popstate: only reload when the address itself changed.)
  var shownAt = location.pathname + location.search;
  window.addEventListener('popstate', function () { if (location.pathname + location.search !== shownAt) location.reload(); });
})();

// A link to "#something" inside a closed fold opens the fold first (e.g. World → Fast travel).
document.addEventListener('click', function (ev) {
  var a = ev.target.closest ? ev.target.closest('a[href^="#"]') : null;
  if (!a || a.getAttribute('href').length < 2) return;
  var t = document.getElementById(a.getAttribute('href').slice(1));
  if (!t) return;
  for (var d = t; d; d = d.parentElement) if (d.tagName === 'DETAILS') d.open = true;
});

// Inventory item tiles: only one open at a time, and keep popup inside the viewport.
document.addEventListener('toggle', function (ev) {
  var tile = ev.target;
  if (!tile.classList || !tile.classList.contains('itile')) return;
  if (!tile.open) return;
  // Close all other open itiles
  document.querySelectorAll('details.itile[open]').forEach(function (other) {
    if (other !== tile) other.open = false;
  });
  // Prevent the popup overflowing the left or right edge on narrow screens
  var pop = tile.querySelector('.ipop');
  if (!pop) return;
  pop.style.left = '';
  pop.style.right = '';
  pop.style.transform = '';
  if (window.matchMedia && window.matchMedia('(max-width: 720px)').matches) return;   // v0.9.0: phones show it as a panel above the bottom bar (CSS)
  var r = pop.getBoundingClientRect();
  if (r.left < 4) {
    pop.style.left = '0';
    pop.style.transform = 'none';
  } else if (r.right > window.innerWidth - 4) {
    pop.style.left = 'auto';
    pop.style.right = '0';
    pop.style.transform = 'none';
  }
}, true);

/* v0.7.53: the world map zooms (buttons, wheel, pinch, drag) and shows more as you get closer */
function gvMaps() {
  document.querySelectorAll('.mapzoom:not(.on)').forEach(function (box) {
    var svg = box.querySelector('svg.worldmap');
    if (!svg) return;
    box.classList.add('on');
    if (box.parentNode && box.parentNode.classList) box.parentNode.classList.add('zoomable');
    var ctl = box.querySelector('.mapctl'), card = box.querySelector('.mapcard'), goForm = box.querySelector('form.mapgo');
    ctl.hidden = false;
    var W = 1000, H = 560, v = null;
    function pxPer() { return (svg.getBoundingClientRect().width || Math.min(window.innerWidth - 32, 1000)) / W; }   // screen pixels per map unit
    function maxZ() { return Math.max(8, 4 / pxPer()); }
    var me = (box.getAttribute('data-me') || '500,280').split(',').map(Number);
    try { v = JSON.parse(sessionStorage.getItem('gvMapView') || 'null'); } catch (e) { v = null; }
    function zoom() { return W / v[2]; }
    function apply() {
      var z = Math.max(1, Math.min(maxZ(), W / v[2])), w = W / z, h = H / z;
      var cx = Math.max(w / 2, Math.min(W - w / 2, v[0] + v[2] / 2)), cy = Math.max(h / 2, Math.min(H - h / 2, v[1] + v[3] / 2));
      v = [cx - w / 2, cy - h / 2, w, h];
      svg.setAttribute('viewBox', v.map(function (n) { return n.toFixed(1); }).join(' '));
      var px = pxPer(), seen = z * px;   // how big the map really is on screen decides how much detail shows
      svg.style.setProperty('--zs', (Math.pow(z, -0.8) * Math.min(1.8, Math.max(1, 0.8 / px))).toFixed(3));   // small screens: bigger markers
      svg.classList.toggle('z2', seen >= 1.4);
      svg.classList.toggle('z3', seen >= 2.8);
      svg.classList.toggle('zoomed', z > 1.02);
      try { sessionStorage.setItem('gvMapView', JSON.stringify(v)); } catch (e) { /* private window: fine */ }
    }
    function zoomAt(f, px, py) { v = [px - (px - v[0]) / f, py - (py - v[1]) / f, v[2] / f, v[3] / f]; apply(); }
    function centre(x, y, z) { v = [x - W / z / 2, y - H / z / 2, W / z, H / z]; apply(); }
    function toMap(x, y) { var r = svg.getBoundingClientRect(); return [v[0] + (x - r.left) / r.width * v[2], v[1] + (y - r.top) / r.height * v[3]]; }
    if (v && v.length === 4) apply(); else centre(me[0], me[1], window.innerWidth < 720 ? Math.max(2, 1.5 / pxPer()) : 1);
    var fold = box.closest('details');
    if (fold) fold.addEventListener('toggle', function () { if (fold.open) apply(); });
    window.addEventListener('resize', apply);

    ctl.addEventListener('click', function (ev) {
      var b = ev.target.closest('[data-z]');
      if (!b) return;
      var k = b.getAttribute('data-z'), cx = v[0] + v[2] / 2, cy = v[1] + v[3] / 2;
      if (k === 'in') zoomAt(1.6, cx, cy);
      else if (k === 'out') zoomAt(1 / 1.6, cx, cy);
      else if (k === 'me') centre(me[0], me[1], Math.max(zoom(), 3 / pxPer()));
      else centre(500, 280, 1);
    });
    svg.addEventListener('wheel', function (ev) {
      if (ev.deltaY > 0 && zoom() <= 1.01) return;   // all the way out: let the page scroll
      ev.preventDefault();
      var p = toMap(ev.clientX, ev.clientY);
      zoomAt(ev.deltaY < 0 ? 1.25 : 0.8, p[0], p[1]);
    }, { passive: false });

    var pts = {}, moved = 0, pinch = null;
    svg.addEventListener('pointerdown', function (ev) { pts[ev.pointerId] = [ev.clientX, ev.clientY]; moved = 0; pinch = null; });
    svg.addEventListener('pointermove', function (ev) {
      if (!pts[ev.pointerId]) return;
      var ids = Object.keys(pts), old = pts[ev.pointerId], r = svg.getBoundingClientRect();
      pts[ev.pointerId] = [ev.clientX, ev.clientY];
      if (ids.length === 1) {
        var dx = ev.clientX - old[0], dy = ev.clientY - old[1];
        moved += Math.abs(dx) + Math.abs(dy);
        if (moved > 6 && zoom() > 1.01) {
          if (svg.setPointerCapture && !svg.hasPointerCapture(ev.pointerId)) svg.setPointerCapture(ev.pointerId);
          v[0] -= dx / r.width * v[2];
          v[1] -= dy / r.height * v[3];
          apply();
        }
      } else if (ids.length === 2) {
        var a = pts[ids[0]], b = pts[ids[1]], d = Math.hypot(a[0] - b[0], a[1] - b[1]);
        var mid = toMap((a[0] + b[0]) / 2, (a[1] + b[1]) / 2);
        if (pinch) zoomAt(d / pinch, mid[0], mid[1]);
        pinch = d;
        moved = 99;
      }
    });
    function up(ev) { delete pts[ev.pointerId]; pinch = null; }
    svg.addEventListener('pointerup', up);
    svg.addEventListener('pointercancel', up);

    // A drag isn't a tap; a tap on a place opens its card
    svg.addEventListener('click', function (ev) {
      if (moved > 6) { ev.preventDefault(); ev.stopPropagation(); moved = 0; return; }
      var m = ev.target.closest('.mk.place');
      if (!m) { card.hidden = true; return; }
      ev.preventDefault();
      card.textContent = '';
      var x = document.createElement('button');
      x.type = 'button'; x.className = 'mapcardx'; x.textContent = '✕'; x.setAttribute('aria-label', 'Close');
      x.addEventListener('click', function () { card.hidden = true; });
      var h = document.createElement('b'); h.textContent = m.getAttribute('data-name');
      var p = document.createElement('p'); p.className = 'help'; p.textContent = m.getAttribute('data-what');
      card.appendChild(x); card.appendChild(h); card.appendChild(p);
      var route = m.getAttribute('data-route'), q = document.createElement('p');
      if (m.getAttribute('data-here')) { if (window.gvIcoLine) gvIcoLine(q, 'ico-gnome-hat', ' You are here.'); else q.textContent = '🎩 You are here.'; }
      else if (route && goForm) {
        var go = document.createElement('button');
        go.type = 'button'; go.className = 'btn small';
        go.textContent = 'Go → (' + m.getAttribute('data-steps') + ' steps)';
        go.addEventListener('click', function () { goForm.querySelector('[name=route_id]').value = route; goForm.submit(); });
        q.appendChild(go);
      } else if (m.getAttribute('data-go')) {   // v0.7.98: directions there (the first walk only)
        var a = document.createElement('a');
        a.className = 'btn small alt'; a.href = m.getAttribute('data-go'); if (window.gvIcoLine) gvIcoLine(a, 'ico-compass', ' How do I get there?'); else a.textContent = '🧭 How do I get there?';
        q.appendChild(a);
      } else q.textContent = 'Not next to you: walk the roads to get here.';
      q.className = q.className || 'muted';
      card.appendChild(q);
      card.hidden = false;
    }, true);
  });
}
/* v1.6.0: mycelium maps: the All / Folk / Quests / Gathering chips show or hide the overlays (CSS keys off data-f on .mycbox).
   One delegated listener on the document, so it keeps working after site.js swaps <main> in place. */
function gvMycApply() {
  var f = 'all';
  try { f = sessionStorage.getItem('gvMycF') || 'all'; } catch (e) { f = 'all'; }
  document.querySelectorAll('.mycbox').forEach(function (box) {
    var has = box.querySelector('.mychip[data-f="' + f + '"]');
    var use = has ? f : 'all';
    box.setAttribute('data-f', use);
    box.querySelectorAll('.mychip[data-f]').forEach(function (b) { b.setAttribute('aria-pressed', b.getAttribute('data-f') === use ? 'true' : 'false'); });
    // v1.6.4: the 🏷️ Names chip (remembered on this device)
    var n = '0';
    try { n = localStorage.getItem('gvMycN') === '1' ? '1' : '0'; } catch (e) { n = box.getAttribute('data-n') || '0'; }
    box.setAttribute('data-n', n);
    box.querySelectorAll('.mychip[data-n]').forEach(function (b) { b.setAttribute('aria-pressed', n === '1' ? 'true' : 'false'); });
  });
}
if (!window.gvMycBound) {
  window.gvMycBound = true;
  document.addEventListener('click', function (ev) {
    var nb = ev.target.closest ? ev.target.closest('.mychip[data-n]') : null;   // v1.6.4: names on / off
    if (nb) {
      var on = nb.getAttribute('aria-pressed') !== 'true';
      try { localStorage.setItem('gvMycN', on ? '1' : '0'); } catch (e) { /* private window: the chip still works until the page reloads */ }
      document.querySelectorAll('.mycbox').forEach(function (bx) { bx.setAttribute('data-n', on ? '1' : '0'); bx.querySelectorAll('.mychip[data-n]').forEach(function (c) { c.setAttribute('aria-pressed', on ? 'true' : 'false'); }); });
      return;
    }
    var b = ev.target.closest ? ev.target.closest('.mychip[data-f]') : null;
    if (!b) return;
    try { sessionStorage.setItem('gvMycF', b.getAttribute('data-f')); } catch (e) { /* private window: the chip still works */ }
    gvMycApply();
  });
}
/* v1.6.1: on a map page, bring the "you are here" hat into view once per address (not when a filter chip is tapped or a form is
   sent in place), unless the gnome has already started scrolling, and without smooth scrolling when reduced motion is asked for. */
var gvMycSig = '', gvMycUser = false;
['touchstart', 'wheel', 'keydown', 'mousedown'].forEach(function (t) { window.addEventListener(t, function () { gvMycUser = true; }, { passive: true }); });
function gvMycScroll(opened) {
  // v1.6.2: only when the map is the point of the page: ?tab=map, #regionmap / #worldmap, or the fold was just opened. Never on the default World tab.
  if (!opened && !/[?&]tab=map(&|$)/.test(location.search) && !/^#(regionmap|worldmap)$/.test(location.hash)) return;
  var wf = document.getElementById('worldmap');   // v1.6.6: on #worldmap (or the fold just opened) aim at the world map's hat
  var mark = ((location.hash === '#worldmap' || opened) && wf && wf.open && wf.querySelector('.mme'))
    || document.querySelector('.mycbox:not(.mycworldbox) .mme') || document.querySelector('.mycbox .mme');
  if (!mark || !mark.getClientRects().length) return;   // no map, or its fold is closed (opening it tries again)
  var sig = location.pathname + location.search;
  if (sig === gvMycSig) return;
  gvMycSig = sig;
  gvMycUser = false;
  setTimeout(function () {
    if (gvMycUser) return;
    var r = mark.getBoundingClientRect();
    if (r.top > 80 && r.bottom < window.innerHeight - 80) return;   // already comfortably in view
    var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    window.scrollTo({ top: Math.max(0, window.scrollY + r.top - window.innerHeight * 0.4), behavior: reduce ? 'auto' : 'smooth' });
  }, 250);
}
document.addEventListener('toggle', function (ev) { if (ev.target && ev.target.id === 'worldmap' && ev.target.open) { gvMycSig = ''; gvMycScroll(true); } }, true);
/* v0.9.3: the region map zooms too (buttons, wheel, pinch, drag). Taps on places stay plain links. */
function gvRegionZoom() {
  document.querySelectorAll('.rzoom:not(.on)').forEach(function (box) {
    var svg = box.querySelector('svg.regionmap'), ctl = box.querySelector('.rzctl');
    if (!svg || !ctl) return;
    box.classList.add('on');
    ctl.hidden = false;
    var vb = (svg.getAttribute('viewBox') || '0 0 400 300').split(/\s+/).map(Number), W = vb[2], H = vb[3], v = [0, 0, W, H];
    function zoom() { return W / v[2]; }
    function apply() {
      var z = Math.max(1, Math.min(6, W / v[2])), w = W / z, h = H / z;
      var cx = Math.max(w / 2, Math.min(W - w / 2, v[0] + v[2] / 2)), cy = Math.max(h / 2, Math.min(H - h / 2, v[1] + v[3] / 2));
      v = [cx - w / 2, cy - h / 2, w, h];
      svg.setAttribute('viewBox', v.map(function (n) { return n.toFixed(1); }).join(' '));
      svg.classList.toggle('zoomed', z > 1.02);
    }
    function zoomAt(f, px, py) { v = [px - (px - v[0]) / f, py - (py - v[1]) / f, v[2] / f, v[3] / f]; apply(); }
    function toMap(x, y) { var r = svg.getBoundingClientRect(); return [v[0] + (x - r.left) / r.width * v[2], v[1] + (y - r.top) / r.height * v[3]]; }
    ctl.addEventListener('click', function (ev) {
      var b = ev.target.closest('[data-z]');
      if (!b) return;
      var k = b.getAttribute('data-z'), cx = v[0] + v[2] / 2, cy = v[1] + v[3] / 2;
      if (k === 'in') zoomAt(1.6, cx, cy); else if (k === 'out') zoomAt(1 / 1.6, cx, cy); else { v = [0, 0, W, H]; apply(); }
    });
    svg.addEventListener('wheel', function (ev) {
      if (ev.deltaY > 0 && zoom() <= 1.01) return;
      ev.preventDefault();
      var p = toMap(ev.clientX, ev.clientY);
      zoomAt(ev.deltaY < 0 ? 1.25 : 0.8, p[0], p[1]);
    }, { passive: false });
    var pts = {}, moved = 0, pinch = null;
    svg.addEventListener('pointerdown', function (ev) { pts[ev.pointerId] = [ev.clientX, ev.clientY]; moved = 0; pinch = null; });
    svg.addEventListener('pointermove', function (ev) {
      if (!pts[ev.pointerId]) return;
      var ids = Object.keys(pts), old = pts[ev.pointerId], r = svg.getBoundingClientRect();
      pts[ev.pointerId] = [ev.clientX, ev.clientY];
      if (ids.length === 1) {
        var dx = ev.clientX - old[0], dy = ev.clientY - old[1];
        moved += Math.abs(dx) + Math.abs(dy);
        if (moved > 6 && zoom() > 1.01) {
          if (svg.setPointerCapture && !svg.hasPointerCapture(ev.pointerId)) svg.setPointerCapture(ev.pointerId);
          v[0] -= dx / r.width * v[2]; v[1] -= dy / r.height * v[3]; apply();
        }
      } else if (ids.length === 2) {
        var a = pts[ids[0]], b = pts[ids[1]], d = Math.hypot(a[0] - b[0], a[1] - b[1]), mid = toMap((a[0] + b[0]) / 2, (a[1] + b[1]) / 2);
        if (pinch) zoomAt(d / pinch, mid[0], mid[1]);
        pinch = d; moved = 99;
      }
    });
    function up(ev) { delete pts[ev.pointerId]; pinch = null; }
    svg.addEventListener('pointerup', up);
    svg.addEventListener('pointercancel', up);
    svg.addEventListener('click', function (ev) { if (moved > 6) { ev.preventDefault(); ev.stopPropagation(); moved = 0; } }, true);
  });
}

/* v1.6.4: zoom for the mycelium region map: ＋ − ⤢, drag to pan, wheel, two-finger pinch. At 1.5x or more every place name shows.
   A tap is not a drag (moved < 6px), so places stay plain links. touch-action: pan-y keeps the page scrolling when not zoomed. */
function gvMycZoom() {
  document.querySelectorAll('.mzoom:not(.on)').forEach(function (box) {
    var svg = box.querySelector('svg.mycreg'), ctl = box.querySelector('.mzctl');
    if (!svg || !ctl) return;
    box.classList.add('on');
    ctl.hidden = false;
    var vb = (svg.getAttribute('viewBox') || '0 0 360 300').split(/\s+/).map(Number), W = vb[2], H = vb[3], v = [0, 0, W, H];
    function apply() {
      var z = Math.max(1, Math.min(5, W / v[2])), w = W / z, h = H / z;
      var cx = Math.max(w / 2, Math.min(W - w / 2, v[0] + v[2] / 2)), cy = Math.max(h / 2, Math.min(H - h / 2, v[1] + v[3] / 2));
      v = [cx - w / 2, cy - h / 2, w, h];
      svg.setAttribute('viewBox', v.map(function (n) { return n.toFixed(1); }).join(' '));
      svg.classList.toggle('zoomed', z > 1.02);
      svg.classList.toggle('zn', z >= 1.5);
    }
    function zoomAt(f, px, py) { v = [px - (px - v[0]) / f, py - (py - v[1]) / f, v[2] / f, v[3] / f]; apply(); }
    function toMap(x, y) { var r = svg.getBoundingClientRect(); return [v[0] + (x - r.left) / r.width * v[2], v[1] + (y - r.top) / r.height * v[3]]; }
    ctl.addEventListener('click', function (ev) {
      var b = ev.target.closest('[data-mz]');
      if (!b) return;
      var k = b.getAttribute('data-mz'), cx = v[0] + v[2] / 2, cy = v[1] + v[3] / 2;
      if (k === 'in') zoomAt(1.5, cx, cy); else if (k === 'out') zoomAt(1 / 1.5, cx, cy); else { v = [0, 0, W, H]; apply(); }
    });
    svg.addEventListener('wheel', function (ev) {
      if (!ev.ctrlKey && !ev.altKey) return;   // a plain wheel keeps scrolling the page; Ctrl / Alt + wheel zooms
      ev.preventDefault();
      var p = toMap(ev.clientX, ev.clientY);
      zoomAt(ev.deltaY < 0 ? 1.25 : 0.8, p[0], p[1]);
    }, { passive: false });
    var pts = {}, moved = 0, pinch = null;
    svg.addEventListener('pointerdown', function (ev) { pts[ev.pointerId] = [ev.clientX, ev.clientY]; if (Object.keys(pts).length === 1) moved = 0; pinch = null; });
    svg.addEventListener('pointermove', function (ev) {
      if (!pts[ev.pointerId]) return;
      var ids = Object.keys(pts), old = pts[ev.pointerId], r = svg.getBoundingClientRect();
      pts[ev.pointerId] = [ev.clientX, ev.clientY];
      if (ids.length === 1) {
        var dx = ev.clientX - old[0], dy = ev.clientY - old[1];
        moved += Math.abs(dx) + Math.abs(dy);
        if (moved > 6 && W / v[2] > 1.01) {
          if (svg.setPointerCapture && !svg.hasPointerCapture(ev.pointerId)) svg.setPointerCapture(ev.pointerId);
          v[0] -= dx / r.width * v[2]; v[1] -= dy / r.height * v[3]; apply();
        }
      } else if (ids.length === 2) {
        var a = pts[ids[0]], b = pts[ids[1]], d = Math.hypot(a[0] - b[0], a[1] - b[1]), mid = toMap((a[0] + b[0]) / 2, (a[1] + b[1]) / 2);
        if (pinch) zoomAt(d / pinch, mid[0], mid[1]);
        pinch = d; moved = 99;
      }
    });
    function up(ev) { delete pts[ev.pointerId]; pinch = null; }
    svg.addEventListener('pointerup', up);
    svg.addEventListener('pointercancel', up);
    svg.addEventListener('click', function (ev) { if (moved > 6) { ev.preventDefault(); ev.stopPropagation(); moved = 0; } }, true);
  });
}

gvMaps();
gvRegionZoom();
gvMycZoom();   // v1.6.4
gvMycApply();
gvMycScroll();   // v1.6.1

// v0.9.3: road "metro lines" scroll sideways on phones; bring the stop you're at into view (no page jump)
function gvMetro() {
  document.querySelectorAll('.metroline:not([data-sc])').forEach(function (ol) {
    ol.setAttribute('data-sc', '1');
    var here = ol.querySelector('.here');
    if (here && ol.scrollWidth > ol.clientWidth) ol.scrollLeft = Math.max(0, here.offsetLeft - (ol.clientWidth - here.offsetWidth) / 2);
    if (ol.parentNode && ol.parentNode.classList) ol.parentNode.classList.toggle('scrolls', ol.scrollWidth > ol.clientWidth + 2);   // v1.6.2: says "swipe" only when it does scroll
  });
  document.querySelectorAll('.regchips:not([data-sc])').forEach(function (nav) {
    nav.setAttribute('data-sc', '1');
    var on = nav.querySelector('.on');
    if (on && nav.scrollWidth > nav.clientWidth) nav.scrollLeft = Math.max(0, on.offsetLeft - (nav.clientWidth - on.offsetWidth) / 2);
  });
}
gvMetro();
document.addEventListener('toggle', function (ev) {   // lines inside a closed fold have no width until it opens
  if (ev.target && ev.target.open && ev.target.querySelector) { ev.target.querySelectorAll('.metroline').forEach(function (ol) { ol.removeAttribute('data-sc'); }); ev.target.querySelectorAll('.regchips').forEach(function (n) { n.removeAttribute('data-sc'); }); gvMetro(); }
}, true);

/* v0.7.54: the message list (left side on a computer, fold under the top bar on a phone) */
function gvVisibleLog() {
  var side = document.querySelector('.msglog.mlside'), top = document.querySelector('.msglog.top');
  return (side && side.offsetParent !== null) ? side : (top || side || document.createElement('div'));
}
function gvInView(el) {
  var r = el.getBoundingClientRect();
  return el.offsetParent !== null && r.bottom > 0 && r.top < window.innerHeight && !(el.closest('details') && !el.closest('details').open);
}
function gvToastNode(li) {
  var d = document.createElement('div');
  d.className = 'flash ' + (li.classList.contains('err') ? 'err' : 'ok') + (li.classList.contains('prize') ? ' toastprize' : '');
  d.textContent = li.textContent.replace(/\s*(just now|\d+\s*\w+ ago)\s*$/, '');
  // v1.6.2: a harvest says what you got ("🧺 +3 Radish")
  d.textContent = d.textContent.replace(/^You harvest (\d+) × (.+?)\.$/, '🧺 +$1 $2');
  // v0.8.6: a long list of new Almanac pages becomes one short line (the full list stays in Messages)
  var pages = d.textContent.match(/^\s*(?:📖)?\s*New Almanac pages:(.*)$/);
  if (pages && pages[1].split(' · ').length > 3) gvIcoLine(d, 'ico-book-open', ' ' + pages[1].split(' · ').length + ' new Almanac pages. See them in your Almanac.');
  return d;
}
(function () {
  var fresh = gvVisibleLog().querySelectorAll('li.ml.new');
  if (!fresh.length || gvInView(fresh[0])) return;
  gvShowToasts(Array.prototype.map.call(fresh, gvToastNode));
})();

/* v0.7.54: garden select mode, and Satchel-style pickers instead of dropdowns */
function gvGarden() {
  var bar = document.querySelector('.selbar');
  var yard = document.getElementById('yard');
  function picker(kind) { return document.querySelector('.picker[data-kind="' + kind + '"]'); }
  function closeAll() { document.querySelectorAll('.picker').forEach(gvCloseDlg); }
  function sendForm(f) { if (f.requestSubmit) f.requestSubmit(); else f.submit(); }

  // Pickers: close buttons and the backdrop
  document.querySelectorAll('.picker:not(.wired)').forEach(function (pk) {
    pk.classList.add('wired');
    pk.addEventListener('click', function (ev) { if (ev.target === pk || ev.target.closest('.pickx')) gvCloseDlg(pk); });
  });
  /* v1.8.2: Escape and Android back close a <dialog> natively, no keydown listener needed */

  // One square (the panel): the dropdown becomes a button that opens the picker
  document.querySelectorAll('select[data-pick]:not(.wired)').forEach(function (sel) {
    var pk = picker(sel.getAttribute('data-pick'));
    if (!pk) return;
    sel.classList.add('wired');
    sel.hidden = true;
    var b = document.createElement('button');
    b.type = 'button'; b.className = 'btn alt pickbtn';
    function label() { var o = sel.options[sel.selectedIndex]; b.textContent = (o ? o.textContent : 'Choose') + ' ▾'; }
    label();
    sel.parentNode.insertBefore(b, sel);
    b.addEventListener('click', function () {
      var ids = Array.prototype.map.call(sel.options, function (o) { return o.value; });
      pk.querySelectorAll('.pcard').forEach(function (c) {
        c.hidden = ids.indexOf(c.getAttribute('data-id')) < 0;
        c.classList.toggle('on', c.getAttribute('data-id') === sel.value);
        c.querySelector('.pccount').hidden = true;
        var btns = c.querySelector('.pcbtns'); if (btns) btns.hidden = true;
      });
      pk.querySelector('.pickhint').textContent = 'for this square';
      pk.querySelector('.picksum').textContent = '';
      pk.querySelector('[data-go]').hidden = true;
      pk.onpick = function (card) { sel.value = card.getAttribute('data-id'); label(); gvCloseDlg(pk); };
      gvOpenDlg(pk);
    });
  });
  document.querySelectorAll('.picker:not(.cardwired)').forEach(function (pk) {
    pk.classList.add('cardwired');
    pk.addEventListener('click', function (ev) {
      var card = ev.target.closest('.pcard');
      if (card && pk.onpick) { ev.preventDefault(); pk.onpick(card, ev.target.closest('[data-step]')); }
    });
    pk.querySelector('[data-go]') && pk.querySelector('[data-go]').addEventListener('click', function () { if (pk.ongo) pk.ongo(); });
  });

  if (!bar || !yard || bar.classList.contains('wired')) return;
  bar.classList.add('wired');
  bar.hidden = false;
  var form = document.querySelector('form.batchform');
  var flags = {}, costs = {}, picked = {}, pids = {}, pnames = {}, lastPid = 0;   // v0.9.1a: pids/pnames for "select all of this crop"
  bar.getAttribute('data-tiles').split(',').forEach(function (p) { var a = p.split(':'); flags[a[0]] = a[1] || ''; pids[a[0]] = +a[2] || 0; });
  bar.getAttribute('data-costs').split(',').forEach(function (p) { var a = p.split(':'); costs[a[0]] = +a[1]; });
  (bar.getAttribute('data-pnames') || '').split(',').forEach(function (p) { var i = p.indexOf(':'); if (i > 0) pnames[p.slice(0, i)] = p.slice(i + 1); });
  var cropRow = bar.querySelector('.selcrop'), cropBtn = bar.querySelector('[data-selcrop]');
  // v0.7.86: energy a harvest of each square takes (by crop tier), totalled for the squares picked
  var hcost = {}, hsum = bar.querySelector('.selhcost');
  (bar.getAttribute('data-hcosts') || '').split(',').forEach(function (p) { var a = p.split(':'); if (a[0]) hcost[a[0]] = +a[1]; });
  var on = false, onBox = bar.querySelector('.selon'), onBtn = bar.querySelector('[data-sel="on"]');
  function key(a) { var m = /sel=(\d+-\d+)/.exec(a.getAttribute('href') || ''); return m ? m[1] : null; }
  function tiles() { return yard.querySelectorAll('a.tile'); }
  function count() { return Object.keys(picked).length; }
  function paint() {
    tiles().forEach(function (a) { a.classList.toggle('picked', !!picked[key(a)]); });
    bar.querySelector('.selcount').textContent = count();
    if (hsum) {
      var hs = 0;
      for (var k in picked) hs += hcost[k] || 0;
      if (count() && hs) gvIcoLine(hsum, 'ico-lightning', ' up to ' + hs, 'Energy'); else hsum.textContent = '';
    }
    if (cropRow) {   // v0.9.1a: offer "select all" for the crop last picked (or any crop still picked)
      var pid = 0;
      if (lastPid) for (var k2 in picked) if (pids[k2] === lastPid) { pid = lastPid; break; }
      if (!pid) for (var k3 in picked) if (pids[k3] > 0) { pid = pids[k3]; break; }
      lastPid = pid;
      cropRow.hidden = !pid;
      if (pid) gvIcoLine(cropBtn, 'ico-check', ' Select all ' + (pnames[pid] || 'this crop'), 'Check');
    }
  }
  function setOn(v) {
    on = v; onBox.hidden = !v; onBtn.hidden = v;
    yard.classList.toggle('selecting', v);
    if (!v) { picked = {}; lastPid = 0; }
    paint();
  }
  onBtn.addEventListener('click', function () { setOn(true); });
  bar.querySelector('[data-sel="off"]').addEventListener('click', function () { setOn(false); });
  yard.addEventListener('click', function (ev) {
    if (!on) return;
    var a = ev.target.closest('a.tile');
    if (!a) return;
    ev.preventDefault();
    var k = key(a);
    if (!k) return;
    if (picked[k]) delete picked[k]; else { picked[k] = true; if (pids[k] > 0) lastPid = pids[k]; }
    paint();
  }, true);
  if (cropBtn) cropBtn.addEventListener('click', function () {
    if (!lastPid) return;
    for (var k in pids) if (pids[k] === lastPid) picked[k] = true;
    paint();
  });
  // v1.2.1: a quick pick highlights (and scrolls to) the action it goes with
  var QACT = { P: '[data-open="seed"]', A: '[data-open="soil"]', T: '.selacts [data-act="till"]', W: '.selacts [data-act="water"]', H: '.selacts [data-act="harvest"]' };
  function hint(q) {
    bar.querySelectorAll('.selacts .hint').forEach(function (x) { x.classList.remove('hint'); });
    var t = q && QACT[q] && count() ? bar.querySelector(QACT[q]) : null;
    if (!t) return;
    t.classList.add('hint');
    try { t.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' }); } catch (e) { t.scrollIntoView(false); }
    try { t.focus({ preventScroll: true }); } catch (e) {}
  }
  yard.addEventListener('click', function () { if (on) hint(null); });
  bar.querySelectorAll('[data-q]').forEach(function (b) {
    b.addEventListener('click', function () {
      var q = b.getAttribute('data-q');
      picked = {}; lastPid = 0;
      if (q !== 'none') for (var k in flags) if (flags[k].indexOf(q) >= 0) picked[k] = true;
      paint();
      hint(q);
    });
  });
  function submit(act, extra) {
    if (!count()) { gvSay('Pick some squares first: tap them on the garden, or use one of the quick picks.'); return; }
    form.querySelectorAll('.dyn').forEach(function (i) { i.parentNode.removeChild(i); });
    function add(n, v) { var i = document.createElement('input'); i.type = 'hidden'; i.className = 'dyn'; i.name = n; i.value = v; form.appendChild(i); }
    // Keep the yard's order (top-left first) so seeds fill the beds in a tidy way
    tiles().forEach(function (a) { var k = key(a); if (picked[k]) add('sq[]', k); });
    form.querySelector('[name=act]').value = act;
    form.querySelector('[name=item_id]').value = '';
    if (extra) extra(add, form);
    closeAll();
    sendForm(form);
  }
  bar.querySelectorAll('[data-act]').forEach(function (b) {
    b.addEventListener('click', function () {
      var ask = b.getAttribute('data-ask');   // v0.7.61: e.g. dig up asks first
      var askif = b.getAttribute('data-askif');   // v1.6.2: only when a picked square has this flag (till: a no-till bed)
      if (ask && askif) { var hit = false; for (var ak in picked) if ((flags[ak] || '').indexOf(askif) >= 0) hit = true; if (!hit) ask = null; }
      /* v1.8.2: the rest runs after OK in the in-page dialog */
      if (ask && count()) { gvAsk(ask.replace('N', count()), function () { submit(b.getAttribute('data-act')); }); return; }
      submit(b.getAttribute('data-act'));
    });
  });
  bar.querySelectorAll('[data-open]').forEach(function (b) {
    b.addEventListener('click', function () {
      var kind = b.getAttribute('data-open'), pk = picker(kind), n = count();
      if (!n) { gvSay('Pick some squares first: tap them on the garden, or use one of the quick picks.'); return; }
      if (!pk) return;
      var act = b.getAttribute('data-act') || (kind === 'seed' ? 'plant' : kind), counts = {}, order = [], choice = null;
      var sum = pk.querySelector('.picksum'), go = pk.querySelector('[data-go]');
      go.hidden = false;
      pk.querySelector('.pickhint').textContent = (act === 'sheet' ? 'to sheet mulch (with 1 cardboard each) ' : '') + 'for ' + n + ' square' + (n === 1 ? '' : 's');
      function total() { var t = 0; for (var k in counts) t += counts[k]; return t; }
      function show() {
        pk.querySelectorAll('.pcard').forEach(function (c) {
          var id = c.getAttribute('data-id'), cn = counts[id] || 0;
          c.hidden = false;
          c.classList.toggle('on', kind === 'seed' ? cn > 0 : choice === id);
          var badge = c.querySelector('.pccount');
          badge.hidden = !(kind === 'seed' && cn > 0); badge.textContent = cn;
          var btns = c.querySelector('.pcbtns'); if (btns) btns.hidden = !(cn > 0);
        });
        var t = kind === 'seed' ? Math.min(total(), n) : (choice ? n : 0);
        sum.textContent = kind === 'seed' ? (t + ' of ' + n + ' squares · ⚡ up to ' + t * (costs[act] || 1))
                                          : (choice ? n + ' squares · ⚡ up to ' + n * (costs[act] || 1) : 'Tap one to choose it');
        go.disabled = !t;
      }
      pk.onpick = function (card, step) {
        var id = card.getAttribute('data-id'), qty = +card.getAttribute('data-qty');
        if (kind !== 'seed') { choice = id; show(); return; }
        var cur = counts[id] || 0, room = n - total();
        var s = step ? step.getAttribute('data-step') : '+1';
        if (s === '-1') cur = Math.max(0, cur - 1);
        else if (s === 'max') cur = Math.min(qty, cur + room);
        else if (room > 0) cur = Math.min(qty, cur + (cur === 0 && !total() ? room : 1));   // v1.6.2: the first tap fills every picked square
        if (cur) { counts[id] = cur; if (order.indexOf(id) < 0) order.push(id); } else { delete counts[id]; order = order.filter(function (o) { return o !== id; }); }
        show();
      };
      pk.ongo = function () {
        submit(act, function (add, f) {
          if (kind === 'seed') order.forEach(function (id) { add('seed[' + id + ']', counts[id]); });
          else f.querySelector('[name=item_id]').value = choice;
        });
      };
      show();
      gvOpenDlg(pk);
    });
  });
}
gvGarden();

/* v0.7.58: at most 4 pop-up messages at once; the rest are waiting in 🔔 Messages */
function gvCapToasts(nodes) {
  // v0.8.6: no repeats, and prizes (like the end of Wren's tour) come first so they're never hidden
  var seen = {};
  nodes = nodes.filter(function (n) { var t = n.textContent.trim(); if (seen[t]) return false; seen[t] = 1; return true; });
  var isPrize = function (n) { return n.classList.contains('prizebox') || n.classList.contains('toastprize'); };
  nodes = nodes.filter(isPrize).concat(nodes.filter(function (n) { return !isPrize(n); }));
  var phone = window.innerWidth <= 720, max = phone ? 2 : 4;
  if (phone) {   // v1.6.2: one toast at a time on a phone: errors, then what you harvested, then prizes, then the rest. The others wait in 🔔.
    var rank = function (n) { return n.classList.contains('err') ? 0 : (isPrize(n) ? 1 : (/^(🧺|\+\d)/.test(n.textContent.trim()) || gvLeads(n, '🧺', 'ico-basket') ? 2 : (/^🐦/.test(n.textContent.trim()) || gvLeads(n, '🐦', 'ico-bird') ? 4 : 3))); };
    var idx = nodes.map(function (n, i) { return [rank(n), i, n]; });
    idx.sort(function (a, b) { return a[0] - b[0] || a[1] - b[1]; });
    var top = idx[0][2];
    if (idx.length > 1) { var more1 = document.createElement('a'); more1.href = '#'; more1.className = 'toastn'; more1.textContent = ' · +' + (idx.length - 1) + ' more in 🔔';
      more1.addEventListener('click', function (ev) {   // opens the message fold under the header
        ev.preventDefault();
        var log = document.querySelector('.msglog.top');
        if (log) { log.open = true; window.scrollTo(0, 0); var sm = log.querySelector('summary'); if (sm) sm.focus(); }
        var bx = more1.closest('.toasts'); if (bx) bx.remove();
      });
      top.appendChild(more1); }
    return [top];
  }
  if (nodes.length <= max) return nodes;
  var n = nodes.length - max, more;
  if (phone) {   // v0.9.6: a link that opens the message fold under the header
    more = document.createElement('a');
    more.href = '#';
    more.className = 'flash ok toastmore';
    gvIcoLine(more, 'ico-bell', ' +' + n + ' more', 'Bell');
    more.addEventListener('click', function (ev) {
      ev.preventDefault();
      var top = document.querySelector('.msglog.top');
      if (top) { top.open = true; window.scrollTo(0, 0); var sm = top.querySelector('summary'); if (sm) sm.focus(); }
      var box = more.closest('.toasts'); if (box && box.parentNode) box.parentNode.removeChild(box);
    });
  } else {
    more = document.createElement('div');
    more.className = 'flash ok toastmore';
    gvIcoLine(more, 'ico-bell', ' ' + n + ' more message' + (n === 1 ? '' : 's') + ': see Messages in the left-hand menu.', 'Bell');
  }
  return nodes.slice(0, max).concat([more]);
}
/* v0.9.6: show pop-up messages. Phones: top of the screen under the header (never over the bottom bar), ok ones go after 4s,
   errors stay until tapped (✕). Computers: as before. Always role status (ok) or alert (error). */
function gvShowToasts(nodes) {
  if (!nodes.length) return;
  var phone = window.innerWidth <= 720;
  if (phone) document.querySelectorAll('.toasts').forEach(function (old) { old.remove(); });   // v1.6.2: never stack two toast boxes
  var box = document.createElement('div');
  box.className = 'toasts' + (phone ? ' phone' : '');
  var keep = false;
  gvCapToasts(nodes).forEach(function (n) {
    var err = n.classList.contains('err');
    if (!n.getAttribute('role')) n.setAttribute('role', err ? 'alert' : 'status');
    if (phone && err) {
      keep = true;
      var x = document.createElement('button');
      x.type = 'button'; x.className = 'toastx'; x.setAttribute('aria-label', 'Close message'); x.textContent = '✕';
      x.addEventListener('click', function () { if (n.parentNode) n.parentNode.removeChild(n); if (!box.querySelector('.flash')) box.remove(); });
      n.appendChild(x);
    }
    box.appendChild(n);
  });
  document.body.appendChild(box);
  if (phone) {
    // v1.6.2: ~2.5s (prizes 6s); errors stay until tapped. Reduced motion: no fade, just gone.
    var calm = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    box.querySelectorAll('.flash:not(.err):not(.toastmore)').forEach(function (n) {
      var ms = n.classList.contains('toastprize') || n.classList.contains('prizebox') ? 6000 : 2500;
      var gone = function () { if (n.parentNode) n.parentNode.removeChild(n); if (!box.querySelector('.flash')) box.remove(); };
      setTimeout(function () { if (calm) gone(); else { n.classList.add('toastfade'); setTimeout(gone, 300); } }, ms);
    });
  } else {
    setTimeout(function () { box.classList.add('fade'); }, 3500);
    setTimeout(function () { if (box.parentNode) box.parentNode.removeChild(box); }, 4500);
  }
}

/* v1.9.8: shop tiles. Tap a tile: its sheet (<dialog>) opens with the details and the Buy/Sell form. Delegated, so it survives in-place loads. */
function gvSheetTotal(form) {
  var inp = form.querySelector('.qin'), max = +form.getAttribute('data-max') || 0, price = +form.getAttribute('data-price') || 0;
  var n = Math.max(0, Math.min(max, Math.floor(+inp.value || 0)));
  var buy = form.getAttribute('data-mode') === 'buy';
  var coinsEl = document.querySelector('.mycoins[data-coins]'), coins = coinsEl ? +coinsEl.getAttribute('data-coins') : -1;   // v2.0.5: no coin figure on the page = no 'too much' check
  var tot = form.querySelector('.stot'), bad = form.querySelector('.sbad'), go = form.querySelector('.sgo');
  tot.textContent = n > 0 ? tot.getAttribute('data-lbl') + ' ' + (n * price).toLocaleString() : '';
  var over = buy && coins >= 0 && n * price > coins;
  if (bad) { bad.hidden = !over; bad.textContent = over ? 'You have ' + coins.toLocaleString() + '. Too much.' : ''; }
  if (go) go.disabled = n < 1 || over;
}
document.addEventListener('click', function (ev) {
  var t = ev.target;
  if (!t.closest) return;
  var pick = t.closest('[data-sheet]');
  if (pick) {
    var dlg = pick.parentNode.querySelector('dialog.isheet');
    if (dlg) { var f = dlg.querySelector('.sheetform'); if (f) gvSheetTotal(f); gvOpenDlg(dlg); }
    return;
  }
  var x = t.closest('[data-sheetx]');
  if (x) { gvCloseDlg(x.closest('dialog')); return; }
  if (t.tagName === 'DIALOG' && t.classList.contains('isheet')) { gvCloseDlg(t); return; }   // tap on the dimmed backdrop
  var q = t.closest('.qbtn');
  if (q) {
    var form = q.closest('form'), inp = form.querySelector('.qin'), max = +form.getAttribute('data-max') || 1, d = q.getAttribute('data-q');
    var cur = Math.max(1, +inp.value || 1);
    inp.value = d === 'max' ? max : Math.max(1, Math.min(max, cur + (+d)));
    gvSheetTotal(form);
  }
});
document.addEventListener('input', function (ev) {
  if (ev.target.classList && ev.target.classList.contains('qin')) gvSheetTotal(ev.target.closest('form'));
});

/* v0.7.61: town actions that use "any seed" or "any food": choose which one first */
document.addEventListener('submit', function (ev) {
  var form = ev.target;
  if (!form.getAttribute || !form.getAttribute('data-needpick')) return;
  var inp = form.querySelector('[name=item_id]');
  if (inp && +inp.value > 0) return;
  ev.preventDefault(); ev.stopImmediatePropagation();
  var pk = document.querySelector('.picker.townpick[data-kind="' + form.getAttribute('data-needpick') + '"]');
  if (!pk) return;
  gvGarden();   // wires the close button and the cards
  pk.onpick = function (card) {
    inp.value = card.getAttribute('data-id');
    gvCloseDlg(pk);
    if (form.requestSubmit) form.requestSubmit(); else form.submit();
    setTimeout(function () { inp.value = 0; }, 50);
  };
  gvOpenDlg(pk);
}, true);
/* v0.7.61: a link to a fold (e.g. #tasted on My Gnome) opens it */
document.addEventListener('click', function (ev) {
  var a = ev.target.closest ? ev.target.closest('a[href^="#"]') : null;
  if (!a || a.getAttribute('href').length < 2) return;
  var d = document.getElementById(a.getAttribute('href').slice(1));
  if (d && d.tagName === 'DETAILS') d.open = true;
});

/* v0.7.72: on a phone the Almanac's section tabs are one swipeable row: keep the open one in view */
function gvAlmTabs() {
  var on = document.querySelector('.almtabs a.on');
  if (on && on.parentNode.scrollWidth > on.parentNode.clientWidth) on.parentNode.scrollLeft = Math.max(0, on.offsetLeft - 40);
}
gvAlmTabs();

/* v0.7.73: the gift picker on a townsfolk page: tap an item, then "Give it" */
document.addEventListener('click', function (ev) {
  var t = ev.target.closest ? ev.target : null;
  if (!t) return;
  var open = t.closest('[data-giftopen]');
  var pk = document.querySelector('.picker.giftpick');
  if (!pk) return;
  if (open) { ev.preventDefault(); gvGiftSort(pk, 'like'); gvOpenDlg(pk); return; }
  if (!pk.contains(t)) return;
  var chip = t.closest('[data-gsort]');
  if (chip) { ev.preventDefault(); gvGiftSort(pk, chip.getAttribute('data-gsort')); return; }
  var card = t.closest('.gcard');
  if (card) {
    ev.preventDefault();
    pk.querySelectorAll('.gcard.on').forEach(function (c) { c.classList.remove('on'); });
    card.classList.add('on');
    var go = pk.querySelector('.giftgo');
    go.querySelector('[name=item_id]').value = card.getAttribute('data-id');
    go.querySelector('.gname').textContent = 'Give ' + card.getAttribute('data-name') + '?';
    go.hidden = false;
    return;
  }
  if (t === pk || t.closest('.pickx')) gvCloseDlg(pk);
});
function gvGiftSort(pk, how) {
  var grid = pk.querySelector('.pickgrid');
  var cards = Array.prototype.slice.call(grid.querySelectorAll('.gcard'));
  cards.sort(function (a, b) {
    var na = a.getAttribute('data-name'), nb = b.getAttribute('data-name');
    if (how === 'like') { var d = +b.getAttribute('data-score') - +a.getAttribute('data-score'); if (d) return d; }
    if (how !== 'name') { var c = a.getAttribute('data-cat').localeCompare(b.getAttribute('data-cat')); if (c) return c; }
    return na.localeCompare(nb);
  });
  cards.forEach(function (c) { grid.appendChild(c); });
  pk.querySelectorAll('[data-gsort]').forEach(function (c) { c.classList.toggle('on', c.getAttribute('data-gsort') === how); });
}

// == 0.7.61 almanac + admin (agent) ==
// Admin error log: "📋 Copy all" copies the log text, then says "Copied ✔" for a moment.
document.addEventListener('click', function (ev) {
  var btn = ev.target.closest ? ev.target.closest('[data-copy-from]') : null;
  if (!btn) return;
  var src = document.getElementById(btn.getAttribute('data-copy-from'));
  if (!src) return;
  if (!btn.getAttribute('data-label')) btn.setAttribute('data-label', btn.textContent);
  var show = function (msg) {
    btn.textContent = msg;
    clearTimeout(btn.copyTimer);
    btn.copyTimer = setTimeout(function () { btn.textContent = btn.getAttribute('data-label'); }, 2000);
  };
  var selectAll = function () {   // fallback: select the text so Ctrl+C works
    var range = document.createRange();
    range.selectNodeContents(src);
    var sel = window.getSelection();
    sel.removeAllRanges();
    sel.addRange(range);
    var ok = false;
    try { ok = document.execCommand('copy'); } catch (e) { ok = false; }
    show(ok ? 'Copied ✔' : 'Selected: press Ctrl+C');
  };
  var text = src.textContent || '';
  if (navigator.clipboard && window.isSecureContext) {
    navigator.clipboard.writeText(text).then(function () { show('Copied ✔'); }, selectAll);
  } else {
    selectAll();
  }
});

// v0.7.83: shop shelves by type. The chips only hide and show tiles.
document.addEventListener('click', function (ev) {
  var c = ev.target.closest ? ev.target.closest('.shopcats [data-cat]') : null;
  if (!c) return;
  ev.preventDefault();
  var cat = c.getAttribute('data-cat'), form = c.closest('.shopwrap') || c.closest('form') || document;
  c.parentNode.querySelectorAll('[data-cat]').forEach(function (b) { b.classList.toggle('on', b === c); });
  form.querySelectorAll('.btile').forEach(function (t) { t.classList.toggle('catoff', cat !== 'all' && t.getAttribute('data-cat') !== cat); });
});


// v0.9.9: gathering mini-games live in assets/gather-games.js, loaded the first time a panel is on the page.
function gvGatherGames() {
  var fold = document.querySelector('.mgfold');   // v1.5.0: also the Practice tab's panel (a div)
  if (!fold) return;
  if (window.gvGather) { window.gvGather(); return; }
  if (document.getElementById('gvgathersrc')) return;
  var sc = document.createElement('script');
  sc.id = 'gvgathersrc'; sc.src = fold.getAttribute('data-js'); sc.async = true;
  document.head.appendChild(sc);
}
gvGatherGames();


// v0.8.3: swipe the menu sheet down to close it (phones)
(function () {
  var side = document.querySelector('nav.side'), box = document.getElementById('navtoggle'), y0 = null;
  if (!side || !box) return;
  side.addEventListener('touchstart', function (ev) { y0 = side.scrollTop <= 0 ? ev.touches[0].clientY : null; }, { passive: true });
  side.addEventListener('touchend', function (ev) {
    if (y0 !== null && ev.changedTouches[0].clientY - y0 > 70) { box.checked = false; box.dispatchEvent(new Event('change')); }
    y0 = null;
  }, { passive: true });
  side.addEventListener('click', function (ev) { if (ev.target.closest('a')) { box.checked = false; box.dispatchEvent(new Event('change')); } });   // a link closes the sheet (in-place loads)
})();

// v0.9.0: the ✕ on an item's panel closes it
document.addEventListener('click', function (ev) {
  var b = ev.target.closest ? ev.target.closest('.ipop .ipclose') : null;
  if (!b) return;
  var d = b.closest('details');
  if (d) d.open = false;
});

// v0.9.2: the menu buttons (header ☰, bottom-bar More, ✕) drive the #navtoggle checkbox and keep aria-expanded,
// focus and Escape honest. The checkbox still does the showing and hiding in CSS.
(function () {
  var box = document.getElementById('navtoggle'), nav = document.getElementById('sidenav');
  if (!box || !nav) return;
  var buttons = document.querySelectorAll('button.menubtn'), opener = null;
  function sync() {
    buttons.forEach(function (b) {
      b.setAttribute('aria-expanded', box.checked ? 'true' : 'false');
      if (b.hasAttribute('aria-label')) b.setAttribute('aria-label', box.checked ? 'Close menu' : 'Open menu');
    });
  }
  function setOpen(open, from) {
    if (box.checked === open) return;
    if (open) opener = from || null;
    box.checked = open;
    box.dispatchEvent(new Event('change'));
  }
  buttons.forEach(function (b) {
    b.addEventListener('click', function () { setOpen(!box.checked, b); });
  });
  box.addEventListener('change', function () {
    sync();
    if (box.checked) {
      var first = nav.querySelector('.navx') || nav.querySelector('a[href], button, summary, input, select, textarea');
      if (first) first.focus();
    } else if (opener) {
      var o = opener;
      opener = null;
      if (o.offsetParent !== null) o.focus();
    }
  });
  nav.addEventListener('click', function (ev) {
    if (ev.target.closest && ev.target.closest('.navx')) setOpen(false);
  });
  document.addEventListener('keydown', function (ev) {
    if (ev.key === 'Escape' && box.checked) setOpen(false);
  });
  nav.addEventListener('focusout', function () {   // Tab past the end of the sheet closes it (keeps focus on the page)
    setTimeout(function () { if (box.checked && !nav.contains(document.activeElement) && window.innerWidth <= 720) setOpen(false); }, 0);
  });
  sync();
})();

// Cooking pots (v0.9.4): count down each pot, then show its Collect button (the server checks the time again).
(function () {
  var els = document.querySelectorAll('[data-potleft]');
  if (!els.length) return;
  var left = [];
  els.forEach(function (el, i) { left[i] = parseInt(el.getAttribute('data-potleft'), 10) || 0; });
  var tick = function () {
    var again = false, ready = 0;
    els.forEach(function (el, i) {
      if (left[i] > 0) {
        left[i]--;
        var m = Math.floor(left[i] / 60), s = left[i] % 60;
        el.textContent = left[i] > 0 ? m + ':' + (s < 10 ? '0' : '') + s : 'Ready!';
        if (left[i] <= 0) {
          var pot = el.closest('.pot');
          if (pot) { pot.classList.remove('busy'); pot.classList.add('done'); var f = pot.querySelector('form'); if (f) f.hidden = false; }
        } else again = true;
      }
      if (left[i] <= 0) ready++;
    });
    var all = document.querySelector('[data-potall]');
    if (all && ready >= 2) all.hidden = false;
    if (again) setTimeout(tick, 1000);
  };
  setTimeout(tick, 1000);
})();

// Pantry jars (v0.9.8): real-day timers, so count down by the minute ("2.5 days", "5 h", "12 min") and show Collect when a jar is done.
(function () {
  var els = document.querySelectorAll('[data-jarleft]');
  if (!els.length) return;
  var left = [];
  els.forEach(function (el, i) { left[i] = parseInt(el.getAttribute('data-jarleft'), 10) || 0; });
  var txt = function (s) {
    if (s >= 86400) { var d = Math.round(s / 8640) / 10; return d + (d === 1 ? ' day' : ' days'); }
    if (s >= 3600) return Math.round(s / 3600) + ' h';
    return Math.max(1, Math.round(s / 60)) + ' min';
  };
  var tick = function () {
    var again = false, ready = 0;
    els.forEach(function (el, i) {
      if (left[i] > 0) {
        left[i] = Math.max(0, left[i] - 15);
        el.textContent = left[i] > 0 ? txt(left[i]) : 'Ready!';
        if (left[i] <= 0) {
          var jar = el.closest('.jar');
          if (jar) { jar.classList.remove('busy'); jar.classList.add('done'); var f = jar.querySelector('form'); if (f) f.hidden = false; }
        } else again = true;
      }
      if (left[i] <= 0) ready++;
    });
    var all = document.querySelector('[data-jarall]');
    if (all && ready >= 2) all.hidden = false;
    if (again) setTimeout(tick, 15000);
  };
  setTimeout(tick, 15000);
})();

/* v0.9.6: the wide-screen layout (1200px and up). The nav groups fold and the message list and walk bar move into the right column.
   One copy of each exists; on a small screen they go back where they were. Without script nothing moves and nothing folds. */
(function () {
  var mq = window.matchMedia ? window.matchMedia('(min-width: 1200px)') : null;
  var rail = document.querySelector('.rail');
  var groups = document.querySelectorAll('.navgroupt');   // player menu groups (.navfixed) never fold; the admin menu's still do
  if (!mq) return;
  var KEY = 'gv-navfold';
  var saved = {};
  try { saved = JSON.parse(localStorage.getItem(KEY) || '{}') || {}; } catch (e) { saved = {}; }
  function applyFold() {
    groups.forEach(function (d) {
      var name = d.getAttribute('data-g');
      d.open = (mq.matches && !d.classList.contains('navfixed')) ? (d.classList.contains('cur') || saved[name] === 1) : true;
    });
    document.documentElement.classList.add('navset');
  }
  groups.forEach(function (d) {
    var sm = d.querySelector('summary');
    if (sm) sm.addEventListener('click', function (ev) {   // a click or key press on the heading; our own opening and closing never comes through here
      if (!mq.matches || d.classList.contains('navfixed')) { ev.preventDefault(); return; }   // a phone's menu sheet and the player menu stay open
      saved[d.getAttribute('data-g')] = d.open ? 0 : 1;   // the click is about to flip it
      try { localStorage.setItem(KEY, JSON.stringify(saved)); } catch (e) { /* storage may be off */ }
    });
  });

  // Messages and the walk bar: remember where each came from, move them into the rail on a wide screen
  var marks = {};
  function mark(node, key) {
    if (!marks[key]) { marks[key] = document.createComment(key); node.parentNode.insertBefore(marks[key], node); }
  }
  function walkBox() {
    var box = rail.querySelector('.rwalk');
    if (!box) {
      box = document.createElement('section');
      box.className = 'rbox rwalk';
      box.setAttribute('aria-labelledby', 'rt-walk');
      box.innerHTML = '<h3 id="rt-walk">' + gvIco('ico-mushroom') + ' On the road</h3>';
      rail.insertBefore(box, rail.firstChild);   // v1.6.7: the walk/fight box sits above Messages
    }
    return box;
  }
  function place() {
    if (!rail) { document.documentElement.classList.add('railset'); return; }
    var log = document.querySelector('.msglog.mlside'), adv = document.querySelector('.advbar');
    if (mq.matches) {
      if (log && !rail.contains(log)) { mark(log, 'log'); var wb = rail.querySelector('.rwalk'); rail.insertBefore(log, wb ? wb.nextSibling : rail.firstChild); log.classList.add('inrail'); }
      if (adv && !rail.contains(adv)) { mark(adv, 'adv'); walkBox().appendChild(adv); adv.classList.add('inrail'); }
    } else {
      if (log && rail.contains(log) && marks.log && marks.log.parentNode) { marks.log.parentNode.insertBefore(log, marks.log.nextSibling); log.classList.remove('inrail'); }
      if (adv && rail.contains(adv) && marks.adv && marks.adv.parentNode) { marks.adv.parentNode.insertBefore(adv, marks.adv.nextSibling); adv.classList.remove('inrail'); }
    }
    document.documentElement.classList.add('railset');
    fit();
  }
  // Cap the message list to whole rows: find the last row that fits, size the list to it, offer "See all" if more is hidden
  var CAP = 200;
  function fit() {
    var log = document.querySelector('.msglog.mlside.inrail');
    if (!log) return;
    var list = log.querySelector('.mllist'), old = log.querySelector('.mlmore');
    if (old) old.parentNode.removeChild(old);
    if (!list) return;
    var open = log.classList.contains('open');
    list.style.maxHeight = '';
    log.classList.remove('capped');
    var rows = list.children, n = rows.length;
    if (!n) return;
    var h = 0, shown = 0, last = rows[n - 1];
    var total = last.offsetTop + last.offsetHeight - rows[0].offsetTop;
    if (total <= CAP && !open) return;
    var btn = document.createElement('button');
    btn.type = 'button'; btn.className = 'mlmore linkbtn';
    btn.setAttribute('aria-expanded', open ? 'true' : 'false');
    btn.textContent = open ? 'Show fewer' : 'See all ' + n;
    btn.addEventListener('click', function () { log.classList.toggle('open'); fit(); });
    list.parentNode.insertBefore(btn, list.nextSibling);
    if (open) return;
    for (var i = 0; i < n; i++) {
      var b = rows[i].offsetTop + rows[i].offsetHeight - rows[0].offsetTop;
      if (b <= CAP || i === 0) { h = b; shown = i + 1; } else break;
    }
    list.style.maxHeight = (h + 4) + 'px';
    log.classList.add('capped');
  }
  window.gvRailFit = function () { place(); };
  var mqh = function () { applyFold(); place(); };
  if (mq.addEventListener) mq.addEventListener('change', mqh); else if (mq.addListener) mq.addListener(mqh);
  mqh();
})();

/* v1.6.2: phones show the beds zoomed in; this button shows the whole yard (kept on <body>, so it survives in-place loads) */
try { if (localStorage.getItem('gv-yard-whole') === '1') document.body.classList.add('yardwhole'); } catch (e) { /* storage may be off */ }
document.addEventListener('click', function (ev) {
  var b = ev.target.closest ? ev.target.closest('[data-yardwhole]') : null;
  if (!b) return;
  var on = document.body.classList.toggle('yardwhole');
  try { localStorage.setItem('gv-yard-whole', on ? '1' : '0'); } catch (e) { /* storage may be off */ }
});

// v1.6.3: choosing from a dropdown in a form.pickform sends it (the Go button is only for when scripts are off). One delegated listener.
document.addEventListener('change', function (ev) {
  var sel = ev.target;
  if (!sel.matches || !sel.matches('select[data-autosubmit]') || !sel.form) return;
  if (sel.form.requestSubmit) sel.form.requestSubmit(); else sel.form.submit();
});
document.documentElement.classList.add('js');

/* v2.0.25: the style-src 'self' policy refuses style="" attributes, so rest-stop tints travel as data-sh="hue" and are set through the CSSOM (allowed), also on content swapped in later. */
(function () {
  function hues(root) {
    var list = root.querySelectorAll ? root.querySelectorAll('[data-sh]') : [];
    for (var i = 0; i < list.length; i++) list[i].style.setProperty('--sh', list[i].getAttribute('data-sh'));
    if (root.getAttribute && root.hasAttribute('data-sh')) root.style.setProperty('--sh', root.getAttribute('data-sh'));
  }
  hues(document);
  if (window.MutationObserver) new MutationObserver(function (ms) {
    ms.forEach(function (m) { m.addedNodes.forEach(function (n) { if (n.nodeType === 1) hues(n); }); });
  }).observe(document.documentElement, { childList: true, subtree: true });
})();

/* v2.0.57: on a phone the route info fades out when a fight starts and stays out until the fight ends; later rounds
   (reloads or in-place swaps) must not replay the fade, so the first fade is remembered for this tab */
function gvRouteFade() {
  var g = document.querySelector('.advgrid.fighting'), seen = false;
  try { seen = sessionStorage.getItem('gvRouteFaded') === '1'; if (!g) sessionStorage.removeItem('gvRouteFaded'); } catch (e) {}
  if (g && seen) g.classList.add('rf-done');
}
gvRouteFade();
document.addEventListener('animationend', function (ev) {
  if (ev.animationName !== 'routefade') return;
  try { sessionStorage.setItem('gvRouteFaded', '1'); } catch (e) {}
});
