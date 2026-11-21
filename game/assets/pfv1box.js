/* Puzzle combat v1 (2.6.74 stage C): the Puzzle box, the starter pick, the pre-fight screen and the result card (includes/pfdeck_view.php, assets/pfv1.css).
   Draws the piece art (assets/pfparts.js), sets the meter widths (no inline styles in the markup: CSP), shows the detail line for a tapped piece,
   and sends the one hidden form (#pfv-f) when a piece is packed or taken out. The server checks everything again. Runs again when the page content is swapped in place. */
(function () {
  function all(sel, root) { return Array.prototype.slice.call((root || document).querySelectorAll(sel)); }
  function sizes() {
    all(".pfv [data-w], .pfv-sheet [data-w], .pfv-dsheet [data-w]").forEach(function (el) { el.style.width = el.getAttribute('data-w') + '%'; });
    all('.pfv [data-f]').forEach(function (el) { el.style.flex = el.getAttribute('data-f') + ' 1 0'; });
  }
  function mount() {   // every placeholder becomes the piece as the board draws it
    var P = window.PFParts; if (!P || !P.ok) return;
    var drawn = [], iks = [];
    all('.pfv i.cvh').forEach(function (h) {
      var o = null; try { o = JSON.parse(h.getAttribute('data-p')); } catch (e) { return; }
      var host = h.closest('[data-pico]'); if (host && !P.picoBase) P.picoBase = host.getAttribute('data-pico');
      var opts = { size: 'strip', owner: o.o === 'foe' ? 'foe' : 'me', ik: o.ik || '', type: o.t, edges: o.e, tag: o.tag || '', num: '' };
      var c = P.piece(opts);
      c.className = 'pfb-cv'; c.setAttribute('aria-hidden', 'true'); h.parentNode.replaceChild(c, h);
      if (opts.ik) { drawn.push([c, opts]); iks.push(opts.ik); }
    });
    if (iks.length && P.picoBase && P.cicoLoad) ['strip', 'hand'].forEach(function (z) {   // 2.7.45: a creature's own piece icons; redraw the pieces once they have arrived
      P.cicoLoad(P.picoBase, iks, z, function () { drawn.forEach(function (d) { if (!d[0].parentNode) return; var n = P.piece(d[1]); n.className = d[0].className; n.setAttribute('aria-hidden', 'true'); d[0].parentNode.replaceChild(n, d[0]); d[0] = n; }); });
    });
  }
  /** 2.6.75: a screen that fits the window (the fight, the pre-fight screen): fixed between the site's header and its bottom bar (measured here), or the whole window inside the Trail's popover. */
  function frame() {
    var el = document.querySelector('#pfight.pf-v1') || document.getElementById('pfv-pre'); if (!el) return;
    var top = 0, bot = 0, st = document.documentElement.style;
    var dlg = el.closest('dialog'), modal = false; try { modal = !!(dlg && dlg.matches(':modal')); } catch (e) {}
    // a modal popover (the Trail's) on a phone is the whole window; anything else (and the Trail's on a wide window, 2.6.96) leaves the header and the bottom bar in sight
    if (!modal || window.innerWidth >= 700) {
      if (!modal && !el.classList.contains('pfv-fit')) { try { window.scrollTo(0, 0); } catch (e) {} }   // the page behind a modal keeps its scroll (the Trail map stays where it is)
      var hd = document.querySelector('.bannerin'), bb = document.querySelector('.bottombar');
      if (hd) top = Math.max(0, Math.round(hd.getBoundingClientRect().bottom));
      if (bb && getComputedStyle(bb).display !== 'none' && getComputedStyle(bb).position === 'fixed') bot = Math.max(0, Math.round(window.innerHeight - bb.getBoundingClientRect().top));
      if (top > window.innerHeight * 0.4) top = 0;
    }
    st.setProperty('--pfv-top', top + 'px'); st.setProperty('--pfv-bot', bot + 'px');
    el.classList.add('pfv-fit');
  }
  function send(form) { if (typeof form.requestSubmit === 'function') form.requestSubmit(); else form.submit(); }
  function esc(x) { return String(x).replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); }


  /* ---------- 2.6.76: the piece detail sheet. A tap on a piece opens it at once, in view (a bottom sheet above the bottom bar, a side panel on a wide screen), wherever the piece was tapped.
     PFSheet.card(pc) is the shared content (also used by the fight's piece card): art, name, chips, life pips, the tag in words, the four edges and what they link with, the flavour line. */
  var FAMTY = { body: 'Hurt or Guard', mind: 'Heal, Charm or Soothe', craft: 'Trick or Item' };
  var SRCN = { knack: 'Starter', basic: 'Starter', calling: 'Calling', crop: 'Crop', craft: 'Craft', region: 'Region', tool: 'Tool', pal: 'Pal', env: 'Environment' };
  var SRCI = { knack: '🧩', basic: '🧩', calling: '🎩', crop: '🌾', craft: '🛠️', region: '🗺️', tool: '🔧', pal: '🐾', env: '🌿' };
  var TYI = { hurt: '⚔️', guard: '🛡️', heal: '💚', charm: '🌼', soothe: '🎵', trick: '✨', item: '🎒' };
  function edgeDiagram(e) {
    if (!e) return '';
    function d(side) { var x = e[side]; return x ? '<i class="ed ' + (x[0] === 'knob' ? 'kn' : x[0] === 'hole' ? 'ho' : 'wi') + ' f-' + esc(x[1] || 'wild') + '" title="' + side + ': ' + esc(x[0]) + (x[1] ? ' (' + esc(x[1]) + ')' : '') + '"></i>' : '<i class="ed"></i>'; }
    return '<span class="edg" role="img" aria-label="Edges: left ' + esc((e.L || [])[0]) + ', right ' + esc((e.R || [])[0]) + ', top ' + esc((e.T || [])[0]) + ', bottom ' + esc((e.B || [])[0]) + '"><span></span>' + d('T') + '<span></span>' + d('L') + '<b></b>' + d('R') + '<span></span>' + d('B') + '<span></span></span>';
  }
  function linkHint(pc) {
    var e = pc.e || {}, bits = [];
    if (e.R && e.R[0] === 'knob') bits.push('a ' + e.R[1] + ' piece on its right (' + FAMTY[e.R[1]] + ')');
    if (e.B && e.B[0] === 'knob') bits.push('a ' + e.B[1] + ' piece below it');
    if (e.T && e.T[0] === 'knob') bits.push('a ' + e.T[1] + ' piece above it');
    if (e.L && e.L[0] === 'hole') bits.push('a piece with a ' + e.L[1] + ' knob on its left');
    return bits.length ? 'Links best with ' + bits.slice(0, 2).join(' and ') + '.' : '';
  }
  /* the words for each piece type (mirror of PF_TYPE_TEXT in includes/pfight.php; # is the piece's number; tests/pf_piece_text.php checks they match) */
  var TYTX = { hurt: 'Deals # damage, filling its Yield bar', guard: 'Blocks # damage until your next turn', heal: 'Heals you #', charm: 'Fills its Yield bar with # charm', soothe: 'Cuts up to # damage from the creature next turn, then wears off', trick: 'Boosts a Hurt or Guard fired right after it by +#', item: 'Heals you #' };
  function typeText(t, v) { return TYTX[t] ? TYTX[t].replace('#', v === '' || v === undefined || v === null ? 'its number' : String(v)) : ''; }
  function pips(n) { var h = ''; for (var i = 0; i < n; i++) h += '<i></i>'; return '<span class="lp" role="img" aria-label="stays ' + n + ' rounds">' + h + '</span>'; }
  function chips(pc) {
    var h = '<span class="ch ty">' + (TYI[pc.t] || '') + ' ' + esc(pc.ty || pc.t) + ' <b>' + esc(pc.v) + '</b></span>';
    if (pc.rn) h += '<span class="ch rk r' + (pc.rk || 1) + '">' + esc(pc.rn) + '</span>';
    if (pc.src) h += '<span class="ch src">' + (SRCI[pc.src] || '') + ' ' + esc(SRCN[pc.src] || pc.src) + '</span>';
    return h;
  }
  /** The shared card content (no actions): chips, life, tag in words, edges with the link hint, the flavour line. */
  function card(pc, o) {
    o = o || {};
    var h = '<div class="dtop"><span class="dart" data-art="1"></span><div class="dmain"><b class="dn">' + esc(pc.n) + '</b><div class="dch">' + chips(pc) + '</div>'
      + (pc.life ? '<div class="dlife">' + pips(pc.life) + ' stays ' + esc(pc.life) + ' round' + (pc.life === 1 ? '' : 's') + '</div>' : '') + '</div></div>';
    var tx = pc.tx || typeText(pc.t, pc.v); if (tx) h += '<p class="dnote dtype">' + esc(tx) + '</p>';
    if (pc.tt) h += '<p class="dtag"><span aria-hidden="true">' + esc(pc.ti) + '</span> ' + esc(pc.tt) + '</p>';
    if (pc.dur) h += '<p class="ddur"><span class="dur"><i data-w="' + Math.round(100 * pc.dur[0] / Math.max(1, pc.dur[1])) + '"></i></span> durability ' + esc(pc.dur[0]) + '/' + esc(pc.dur[1]) + '</p>';
    if (!o.slim) {
      h += '<div class="dedge">' + edgeDiagram(pc.e) + '<span>' + esc(linkHint(pc)) + '</span></div>';
      if (pc.bl) h += '<p class="dfl">“' + esc(String(pc.bl).replace(/\.$/, '')) + '.”</p>';
      if (pc.note) h += '<p class="dnote">' + esc(pc.note) + '</p>';
    }
    return h;
  }
  function artInto(host, pc) {
    var P = window.PFParts; if (!host) return; host.textContent = '';
    if (P && P.ok && pc.e) { try { var opts = { size: 'hand', owner: pc.own === 'foe' ? 'foe' : 'me', ik: pc.ik || '', type: pc.t, tag: pc.tag || '', edges: pc.e, num: String(pc.v) }; var c = P.piece(opts); c.className = 'pfi-cv'; host.appendChild(c);
      if (opts.ik && P.picoBase && P.cicoLoad) P.cicoLoad(P.picoBase, [opts.ik], 'hand', function () { if (!c.parentNode) return; var n = P.piece(opts); n.className = c.className; c.parentNode.replaceChild(n, c); c = n; });   // 2.7.45: the creature's own icon, once it has arrived
    } catch (e) {} }
  }
  window.PFSheet = { typeText: typeText, card: card, chips: chips, art: artInto, edges: edgeDiagram, esc: esc };

  /* ---------- the Puzzle box (R3): the sheet is the piece big with its number, one row per fact (what it does, its tag, its rank and the limit it uses, where it is from,
     its durability, its edges), swaps of the same kind, then the actions. Paths of the game's own art come from the page's data (pf-data: assets/img/pfight/). */
  var SRCICO = { basic: 'ico/ico-gnome-hat.png', crop: 'ico/ico-sprout.png', legend: 'ico/ico-crown.png', craft: 'ico/ico-hammer.png', region: 'ico/ico-world-map.png', wear: 'ico/ico-gloves.png', tool: 'ico/ico-shears.png', pal: 'ico/ico-paw.png' };
  var RANKN = ['', 'Common', 'Uncommon', 'Rare', 'Masterwork'], RANKI = ['', 'items/gem-c.png', 'items/gem-u.png', 'items/gem-r.png', 'ico/ico-medal-gold.png'];
  function imgBase() { var d = null; try { d = JSON.parse(document.getElementById('pf-data').textContent); } catch (e) {} return d && d.art ? String(d.art).replace(/pfight\/?$/, '') : '/assets/img/'; }
  function im(rel, alt) { return '<img src="' + esc(imgBase() + rel) + '" alt="' + esc(alt || '') + '" width="32" height="32">'; }
  function fact(icon, b, s) { return '<li><span class="fi">' + icon + '</span><span><b>' + b + '</b>' + (s ? '<small>' + s + '</small>' : '') + '</span></li>'; }
  function pcOf(btn) { try { return JSON.parse(btn.getAttribute('data-pc')); } catch (e) { return null; } }
  function boxBody(root, pc, b) {
    var caps = {}; try { caps = JSON.parse(root.getAttribute('data-caps') || '{}'); } catch (e) {}
    var locked = root.getAttribute('data-locked') === '1', tool = !!pc.tool, gear = pc.src === 'tool' || pc.src === 'pal';
    var where = tool ? (b.classList.contains('on') ? 'On your belt' : 'In your satchel') : pc.src === 'pal' ? 'In your party' : pc.src === 'tool' ? 'On your belt' : pc['in'] ? (locked ? 'In this fight' : 'In your deck') : 'On the shelf';
    var h = '<div class="dhero">' + (tool ? '<span class="dart tool" aria-hidden="true">' + esc(pc.ico) + '</span>' : '<span class="dart" data-art="1"></span>') + '<div class="dmain"><b class="dn">' + esc(pc.n) + '</b><span class="dwhere">' + where + '</span></div></div><ul class="dfacts">';
    if (!tool) h += fact(im('pfight/ico-' + pc.t + '.png'), esc(pc.ty || pc.t) + ' ' + esc(pc.v), esc(pc.tx || typeText(pc.t, pc.v)));
    if (pc.tt) { var q = String(pc.tt).split(': '); var tq = q.slice(1).join(': '); h += fact('<span aria-hidden="true">' + esc(pc.ti || '') + '</span>', esc(q[0]), esc(tq.charAt(0).toUpperCase() + tq.slice(1))); }
    var rk = +pc.rk || 0;
    if (rk) h += fact(im(RANKI[rk]), RANKN[rk], rk === 3 && caps.rare ? 'Uses a Rare spot · ' + caps.rare[0] + ' of ' + caps.rare[1] + ' used' : rk === 4 && caps.mw ? 'Uses the Masterwork spot · ' + caps.mw[0] + ' of ' + caps.mw[1] + ' used' : 'No limit on this rank');
    if (pc.g) h += fact('<span class="srcb s-' + esc(pc.g) + '">' + im(SRCICO[pc.g] || SRCICO.basic) + '</span>', esc(pc.sn || pc.g), esc(pc.fr || ''));
    if (pc.lg === 'larder' && caps.larder) h += fact(im('ico/ico-jar.png'), 'Uses a Larder spot', caps.larder[0] + ' of ' + caps.larder[1] + ' used' + (caps.larder[0] >= caps.larder[1] ? ' · full' : ''));
    if (pc.lg === 'keeps' && caps.keeps) h += fact(im('ico/ico-ribbon.png'), 'Uses a Keepsake spot', caps.keeps[0] + ' of ' + caps.keeps[1] + ' used' + (caps.keeps[0] >= caps.keeps[1] ? ' · full' : ''));
    if (pc.dur) h += fact(im('ico/ico-toolbox.png'), esc(pc.dur[0]) + ' of ' + esc(pc.dur[1]) + ' durability', 'Each play costs 2 · about ' + Math.floor(pc.dur[0] / 2) + ' plays left');
    if (tool && pc.d) h += fact(im('ico/ico-info.png'), 'Tool', esc(pc.d));
    h += '</ul>';
    if (!tool) h += '<div class="dedge">' + edgeDiagram(pc.e) + '<span>' + esc(linkHint(pc)) + '</span></div>';
    if (pc.bl) h += '<p class="dfl">“' + esc(String(pc.bl).replace(/\.$/, '')) + '.”</p>';
    if (pc.note) h += '<p class="dnote">' + esc(pc.note) + '</p>';
    if (locked || tool || gear || b.getAttribute('data-a') !== 'tog') return h;
    var cand = function (btn, right) { var q = pcOf(btn); return '<li><span class="thumb" data-thumb="' + esc(q.key) + '"></span><span class="b"><b>' + esc(q.n) + '</b><small>' + esc(q.ty) + ' ' + esc(q.v) + (+q.rk >= 3 ? ' · ' + RANKN[+q.rk] : '') + ' · ' + esc(q.sn || '') + '</small></span>' + right + '</li>'; };
    if (pc['in']) {   // in the deck: spare pieces of the same kind, each with Swap (or why it cannot go in)
      var same = all('.shelfg .pc', root).filter(function (x) { var q = pcOf(x); return q && q.t === pc.t; }).slice(0, 4);
      if (same.length) h += '<h4 class="dsw">Swap ' + esc(pc.n) + ' for</h4><ul class="dcands">' + same.map(function (x) { var q = pcOf(x);
        var other = q.why && !(q.lg && q.lg === pc.lg);   // blocked by a limit this piece does not free
        return cand(x, other ? '<span class="why">' + esc(q.why) + '</span>' : '<button type="button" class="btn" data-pbx-swap="' + esc(pc.key + '|' + q.key + '|' + (q.why ? 1 : 0)) + '">Swap</button>'); }).join('') + '</ul>';
    } else if (pc.why) {   // on the shelf but its limit is full: the pieces in the deck that use the same limit, each with Swap
      var out = pc.lg ? all('.pbx-kit .pc', root).filter(function (x) { var q = pcOf(x); return q && q.lg === pc.lg; }) : [];
      h += '<p class="dblocked">' + im('ico/ico-warning.png') + '<span><b>' + esc(pc.why) + '.</b>' + (out.length ? ' Swap it for one of these:' : ' Take a piece out first.') + '</span></p>';
      if (out.length) h += '<ul class="dcands">' + out.map(function (x) { var q = pcOf(x); return cand(x, '<button type="button" class="btn" data-pbx-swap="' + esc(q.key + '|' + pc.key + '|1') + '">Swap</button>'); }).join('') + '</ul>';
    }
    return h;
  }
  function thumbs(sheetEl, root) {
    all('[data-thumb]', sheetEl).forEach(function (t) {
      var src = null; all('.pc', root).forEach(function (x) { var q = pcOf(x); if (q && q.key === t.getAttribute('data-thumb')) src = x.querySelector('canvas'); });
      if (!src) return; var c = document.createElement('canvas'); c.width = src.width; c.height = src.height; c.setAttribute('aria-hidden', 'true'); try { c.getContext('2d').drawImage(src, 0, 0); } catch (e) {} t.appendChild(c);
    });
  }
  /* what to say after the page comes back (a toggle reloads it in place): kept for one load, shown only when it came true */
  function remember(o) { try { sessionStorage.setItem('pbx-after', JSON.stringify(o)); } catch (e) {} }
  function pbxSwap(form, out, inn, outFirst, root) {
    var nameOf = function (k) { var n = k; all('.pc', root).forEach(function (x) { var q = pcOf(x); if (q && q.key === k) n = q.n; }); return n; };
    remember({ key: inn, where: 'kit', msg: nameOf(inn) + ' is in, ' + nameOf(out) + ' is on the shelf' });
    /* 2.7.05: ONE post (do=pfd_swap): the server tries the order that keeps the deck legal and puts everything back if it cannot */
    form.querySelector('[name=do]').value = 'pfd_swap';
    ['out', 'in'].forEach(function (n) { var f = form.querySelector('[name=' + n + ']'); if (!f) { f = document.createElement('input'); f.type = 'hidden'; f.name = n; form.appendChild(f); } f.value = n === 'out' ? out : inn; });
    send(form);
  }

  var sheet = null, sheetRoot = null, sheetBtn = null, sheetList = [], sx = 0, sy = 0;
  function btnData(b) {
    if (b.getAttribute('data-pc')) { try { return JSON.parse(b.getAttribute('data-pc')); } catch (e) { return null; } }
    if (b.classList.contains('tb')) { var dm = (b.getAttribute('data-dur') || '').split('/'); return { n: b.getAttribute('data-n'), t: 'tool', ty: 'Tool', v: '', rk: +b.getAttribute('data-rk') || 0, rn: ['', 'Common', 'Uncommon', 'Rare', 'Masterwork'][+b.getAttribute('data-rk') || 0], src: 'tool', life: 0, tt: '', e: null, bl: '', note: '', own: 'me', dur: [+dm[0] || 0, +dm[1] || 1], ico: b.getAttribute('data-ico') || '🔧', tool: 1, d: b.getAttribute('data-d') || '' }; }
    return null;
  }
  function actionsFor(b) {
    var h = '';
    var box = !!b.closest('.pbx');
    if (b.classList.contains('tb')) {
      (b.getAttribute('data-acts') || '').split(';').filter(Boolean).forEach(function (a) { var q = a.split('|'); h += '<button type="button" class="btn big ' + esc(q[2]) + '" data-pfv-tool="' + esc(b.getAttribute('data-arg')) + '" data-do="' + esc(q[0]) + '"' + (q[3] === '1' ? ' disabled' : '') + '>' + esc(q[1]) + '</button>'; });
    } else if (b.getAttribute('data-bacts') !== null) {   // a tool piece in the box's belt tray: Fix, Take off
      (b.getAttribute('data-bacts') || '').split(',').filter(Boolean).forEach(function (a) {
        var q = { fix: ['pfd_fix', 'Fix (1 kit)', 'gold', 0], fix0: ['pfd_fix', 'Fix (no kit)', 'gold', 1], off: ['pfd_unequip', 'Take off', 'ghost', 0] }[a]; if (!q) return;
        h += '<button type="button" class="btn big ' + q[2] + '" data-pfv-tool="' + esc(b.getAttribute('data-tool')) + '" data-do="' + q[0] + '"' + (q[3] ? ' disabled' : '') + '>' + q[1] + '</button>';
      });
    } else if (b.getAttribute('data-a') === 'tog') {
      var on = b.getAttribute('data-on') === '1', pq = box ? pcOf(b) : null;
      if (on || !(pq && pq.why)) h += '<button type="button" class="btn big' + (on ? ' ghost' : ' primary') + '" data-pfv-act="1" data-key="' + esc(b.getAttribute('data-arg')) + '" data-on="' + (on ? '0' : '1') + '">' + (box ? (on ? 'Take out' : 'Pack it') : (on ? 'Take out of deck' : 'Pack in deck')) + '</button>';
    }
    return h;
  }
  function closeSheet(keepScroll) {
    if (!sheet) return;
    document.removeEventListener('keydown', sheetKey, true);
    if (sheet.parentNode) sheet.parentNode.removeChild(sheet);
    if (sheetBtn) sheetBtn.classList.remove('pick');
    document.documentElement.classList.remove('pfv-dopen');
    sheet = null; sheetBtn = null;
  }
  function sheetKey(ev) {
    if (!sheet) return;
    if (ev.key === 'Escape') { ev.preventDefault(); ev.stopPropagation(); closeSheet(); }
    else if (ev.key === 'ArrowLeft') { ev.preventDefault(); step(-1); }
    else if (ev.key === 'ArrowRight') { ev.preventDefault(); step(1); }
  }
  function neighbours(root, b) {
    var grid = b.closest('ul'); var sel = b.classList.contains('tb') ? '.tb' : '.pc';
    return all(sel, root).filter(function (x) { var li = x.closest('li'); return !x.getAttribute('data-info') && !(li && li.hidden) && x.getAttribute('data-a') !== 'spick' && x.getAttribute('data-a') !== 'sdrop' && (x.getAttribute('data-pc') || x.classList.contains('tb')); });
  }
  function step(d) {
    if (!sheet) return; var i = sheetList.indexOf(sheetBtn), n = sheetList[i + d]; if (n) { openSheet(sheetRoot, n, true); }
  }
  function ensureVisible(b) {   // the tapped piece stays in view above the sheet; the page only moves when the sheet would hide it
    if (!sheet || !b) return;
    var wide = window.innerWidth >= 900, sr = { top: window.innerHeight - (parseInt(sheet.style.getPropertyValue('--dbot'), 10) || 0) - sheet.offsetHeight }, r = b.getBoundingClientRect();   // the sheet's final place (it may still be sliding up)
    var hd = document.querySelector('.bannerin'), top = hd ? Math.max(0, hd.getBoundingClientRect().bottom) : 0, lim = wide ? window.innerHeight : sr.top;
    var dy = r.bottom > lim - 6 ? Math.round(r.bottom - lim + 12) : r.top < top + 4 ? Math.round(r.top - top - 12) : 0;
    if (dy) { try { window.scrollBy({ top: dy, left: 0, behavior: 'instant' }); } catch (e) { window.scrollBy(0, dy); } }
  }
  function openSheet(root, b, keep) {
    var pc = btnData(b); if (!pc) return false;
    var first = !sheet;
    if (sheetBtn && sheetBtn !== b) sheetBtn.classList.remove('pick');
    all('.tb.pick, .pc.pick', root).forEach(function (x) { x.classList.remove('pick'); }); b.classList.add('pick');
    sheetBtn = b; sheetRoot = root; sheetList = neighbours(root, b);
    var isBox = root.classList.contains('pbx');
    var i = sheetList.indexOf(b), body = isBox ? boxBody(root, pc, b) : pc.tool ? '<div class="dtop"><span class="dart tool" aria-hidden="true">' + esc(pc.ico) + '</span><div class="dmain"><b class="dn">' + esc(pc.n) + '</b><div class="dch">' + chips(pc) + '</div></div></div><p class="ddur"><span class="dur"><i data-w="' + Math.round(100 * pc.dur[0] / Math.max(1, pc.dur[1])) + '"></i></span> durability ' + esc(pc.dur[0]) + '/' + esc(pc.dur[1]) + '</p><p class="dnote">' + esc(pc.d) + '</p>' : card(pc);
    var acts = actionsFor(b);
    var html = '<div class="dgrab" aria-hidden="true"></div><div class="dbar"><button type="button" class="dnav" data-dn="-1" aria-label="Previous piece"' + (i <= 0 ? ' disabled' : '') + '>‹</button><span class="dpos">' + (i + 1) + ' of ' + sheetList.length + '</span><button type="button" class="dnav" data-dn="1" aria-label="Next piece"' + (i >= sheetList.length - 1 ? ' disabled' : '') + '>›</button><button type="button" class="dx" aria-label="Close">✕</button></div>'
      + '<div class="dbody">' + body + '</div>' + (acts ? '<div class="dacts">' + acts + '</div>' : '');
    if (!sheet) {
      sheet = document.createElement('div'); sheet.className = 'pfv-dsheet'; sheet.setAttribute('role', 'dialog'); sheet.setAttribute('aria-label', 'Piece details'); sheet.tabIndex = -1;
      var bb = document.querySelector('.bottombar'), bh = 0; if (bb && getComputedStyle(bb).position === 'fixed' && getComputedStyle(bb).display !== 'none') bh = Math.max(0, Math.round(window.innerHeight - bb.getBoundingClientRect().top));
      sheet.style.setProperty('--dbot', bh + 'px');
      document.body.appendChild(sheet); document.addEventListener('keydown', sheetKey, true); document.documentElement.classList.add('pfv-dopen');
      sheet.addEventListener('click', function (ev) {
        var n = ev.target.closest('[data-dn]'); if (n) { step(+n.getAttribute('data-dn')); return; }
        if (ev.target.closest('.dx')) { closeSheet(); return; }
        var tdo = ev.target.closest('[data-pfv-tool]'), act = ev.target.closest('[data-pfv-act]'), form = sheetRoot && sheetRoot.querySelector('#pfv-f');
        if (tdo && form) { form.querySelector('[name=do]').value = tdo.getAttribute('data-do'); form.querySelector('[name=tool]').value = tdo.getAttribute('data-pfv-tool'); tdo.disabled = true; send(form); return; }
        var sw = ev.target.closest('[data-pbx-swap]');
        if (sw && form) { var s3 = sw.getAttribute('data-pbx-swap').split('|'); sw.disabled = true; pbxSwap(form, s3[0], s3[1], s3[2] === '1', sheetRoot); return; }
        if (act && form && sheetRoot.classList.contains('pbx') && sheetBtn) { var nm = sheetBtn.getAttribute('data-n'), inn = act.getAttribute('data-on') === '1'; remember({ key: act.getAttribute('data-key'), where: inn ? 'kit' : 'shelf', msg: inn ? nm + ' is in your deck' : nm + ' is on the shelf' }); }
        if (act && form) { form.querySelector('[name=do]').value = 'pfd_toggle'; form.querySelector('[name=key]').value = act.getAttribute('data-key'); form.querySelector('[name=on]').value = act.getAttribute('data-on'); act.disabled = true; send(form); }
      });
      sheet.addEventListener('touchstart', function (ev) { var t = ev.touches[0]; sx = t.clientX; sy = t.clientY; }, { passive: true });
      sheet.addEventListener('touchend', function (ev) { var t = ev.changedTouches[0], dx = t.clientX - sx, dy = t.clientY - sy; if (Math.abs(dy) > 60 && Math.abs(dy) > Math.abs(dx) && dy > 0) closeSheet(); else if (Math.abs(dx) > 60 && Math.abs(dx) > Math.abs(dy)) step(dx < 0 ? 1 : -1); }, { passive: true });
    }
    sheet.classList.toggle('pbx-sheet', isBox);
    sheet.innerHTML = html; sizes(); artInto(sheet.querySelector('[data-art]'), pc); if (isBox) thumbs(sheet, root);
    if (first && !(window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches)) sheet.classList.add('slide');
    ensureVisible(b);
    return true;
  }
  function outTap(ev) {   // a tap outside the sheet closes it (a tap on another piece opens that piece)
    if (!sheet || sheet.contains(ev.target)) return;
    if (ev.target.closest && ev.target.closest('.pfv .pc, .pfv .tb')) return;
    closeSheet();
  }
  document.addEventListener('pointerdown', outTap, true);

  function init() {
    closeSheet(); sizes(); mount();
    var roots = all('.pfv');
    roots.forEach(function (root) {
      if (root.getAttribute('data-pfv') === '1') return; root.setAttribute('data-pfv', '1');
      var info = root.querySelector('#pfv-info'), form = root.querySelector('#pfv-f'), starter = root.id === 'pfv-starter';
      function say(el, html) { if (el) el.innerHTML = html; }
      function pick(b) { all('.pc.pick', root).forEach(function (x) { x.classList.remove('pick'); }); if (b) b.classList.add('pick'); }
      function line(b) { return '<span><b>' + esc(b.getAttribute('data-n')) + '</b> ' + esc(b.getAttribute('data-d') || '') + '</span>'; }

      // ---- the starter pick: 4 core + 6 of the 12 offered (or a kit in one tap)
      if (starter) {
        var N = +root.getAttribute('data-picks') || 6, picked = [], offer = all('#pfv-offer .pc', root), slots = all('.pfv-ps', root), go = root.querySelector('#pfv-sgo');
        var holder = root.querySelector('#pfv-picks'), pips = root.querySelector('#pfv-pips'), nEl = root.querySelector('#pfv-n'), hurtEl = root.querySelector('#pfv-hurt');
        offer.forEach(function (b) { if (b.classList.contains('sel')) picked.push(b.getAttribute('data-arg')); });
        var byKey = function (k) { for (var i = 0; i < offer.length; i++) if (offer[i].getAttribute('data-arg') === k) return offer[i]; return null; };
        var draw = function () {
          var hurt = 1; holder.textContent = '';
          offer.forEach(function (b) { var on = picked.indexOf(b.getAttribute('data-arg')) >= 0; b.classList.toggle('sel', on); b.classList.toggle('off', !on && picked.length >= N); b.setAttribute('aria-pressed', on ? 'true' : 'false'); });
          slots.forEach(function (li, i) {
            var b = picked[i] ? byKey(picked[i]) : null; li.textContent = '';
            if (b) { if (b.getAttribute('data-t') === 'hurt') hurt++; var c = b.cloneNode(true); c.className = c.className.replace(/\b(sel|off|pick)\b/g, ''); c.removeAttribute('data-a'); c.setAttribute('data-a', 'sdrop'); var nm = c.querySelector('.pc-n'); if (nm) nm.parentNode.removeChild(nm);
              var src = b.querySelector('canvas'), dst = c.querySelector('canvas'); if (src && dst) dst.getContext('2d').drawImage(src, 0, 0); li.appendChild(c);
              var inp = document.createElement('input'); inp.type = 'hidden'; inp.name = 'pick[]'; inp.value = picked[i]; holder.appendChild(inp);
            } else { var d = document.createElement('div'); d.className = 'slot'; d.textContent = String(i + 5); li.appendChild(d); }
          });
          all('i', pips).forEach(function (p, i) { p.classList.toggle('on', i < picked.length); }); pips.setAttribute('aria-label', picked.length + ' of ' + N);
          nEl.textContent = String(4 + picked.length); hurtEl.querySelector('b').textContent = String(hurt);
          hurtEl.classList.toggle('good', hurt >= 3); hurtEl.classList.toggle('warn', hurt < 3);
          go.disabled = !(picked.length === N && hurt >= 3);
        };
        root.addEventListener('click', function (ev) {
          var kit = ev.target.closest('[data-kit]');
          if (kit) { ev.preventDefault(); picked = kit.getAttribute('data-kit').split(',').filter(function (k) { return !!byKey(k); }).slice(0, N); draw(); say(info, '<span><b>' + esc(kit.textContent.trim()) + ' kit</b> packed. Tap pieces to change it, then pack the box.</span>'); return; }
          var b = ev.target.closest('.pc'); if (!b) return;
          var a = b.getAttribute('data-a'), k = b.getAttribute('data-arg'), i = picked.indexOf(k);
          if (a === 'spick') { if (i >= 0) picked.splice(i, 1); else if (picked.length < N) picked.push(k); draw(); }
          else if (a === 'sdrop') { if (i >= 0) picked.splice(i, 1); draw(); }
          say(info, a === 'spick' && picked.length >= N && picked.indexOf(k) < 0 ? '<span><b>The box is full.</b> Tap a picked piece to take it out.</span>' : line(b));
        });
        draw();
        return;
      }

      // ---- the Puzzle box (R3): the shelf filter (source, search, kind), the fix buttons, and what happened on the last change
      var pbx = root.classList.contains('pbx') ? (function () {
        var st = { g: 'all', q: '', t: '' }, qi = root.querySelector('#pbx-q'), allB = root.querySelector('#pbx-all'), kindP = root.querySelector('#pbx-kind'), empty = root.querySelector('#pbx-empty'), shelf = root.querySelector('#pbx-shelf');
        var TY = { hurt: 'Hurt', guard: 'Guard', heal: 'Heal', charm: 'Charm', soothe: 'Soothe', trick: 'Trick', item: 'Item' };
        function apply() {
          var q = st.q.toLowerCase().trim(), n = 0;
          all('.shelfg > li[data-g]', root).forEach(function (li) { var b = li.querySelector('.pc'), t = b ? b.getAttribute('data-t') : '', nm = b ? (b.getAttribute('data-n') || '').toLowerCase() : '';
            var ok = (st.g === 'all' || li.getAttribute('data-g') === st.g) && (!st.t || t === st.t) && (!q || nm.indexOf(q) >= 0 || (TY[t] || '').toLowerCase().indexOf(q) >= 0); li.hidden = !ok; if (ok) n++; });
          all('#pfv-filt button', root).forEach(function (x) { var on = x.getAttribute('data-g') === st.g; x.classList.toggle('on', on); x.setAttribute('aria-pressed', on ? 'true' : 'false'); });
          if (allB) allB.hidden = st.g === 'all' && !st.q && !st.t;
          if (kindP) { kindP.hidden = !st.t; kindP.innerHTML = st.t ? '<span>Showing ' + esc(TY[st.t] || st.t) + ' pieces only.</span><button type="button" class="btn ghost" data-pbx-kind="">Show all kinds</button>' : ''; }
          if (empty) empty.hidden = n > 0 || !root.querySelector('.shelfg > li[data-g]');
        }
        function toShelf() { if (shelf) { try { shelf.scrollIntoView({ block: 'start', behavior: matchMedia('(prefers-reduced-motion: reduce)').matches ? 'auto' : 'smooth' }); } catch (e) { shelf.scrollIntoView(); } } }
        if (qi) qi.addEventListener('input', function () { st.q = qi.value; apply(); });
        if (/[?&]show=hurt\b/.test(location.search) && shelf) { st.t = 'hurt'; apply(); setTimeout(toShelf, 60); }
        // after a change: the piece that went in settles into the tray, one line says what happened (only when it came true)
        var after = null; try { after = JSON.parse(sessionStorage.getItem('pbx-after') || 'null'); sessionStorage.removeItem('pbx-after'); } catch (e) {}
        if (after && after.key) {
          var hit = all(after.where === 'kit' ? '.pbx-kit .pc' : '.shelfg .pc', root).filter(function (x) { var q = pcOf(x); return q && q.key === after.key; })[0];
          var toast = root.querySelector('#pbx-toast');
          if (hit) { if (after.where === 'kit') hit.classList.add('snap'); if (toast) { toast.textContent = after.msg; toast.hidden = false; setTimeout(function () { toast.hidden = true; }, 3200); } }
        }
        var chest = root.querySelector('.pbx-chest'); try { if (chest && !sessionStorage.getItem('pbx-lid')) { chest.classList.add('open'); sessionStorage.setItem('pbx-lid', '1'); } } catch (e) {}
        return function (ev) {   // true when the tap was the box's own
          var f = ev.target.closest('#pfv-filt button, #pbx-all, [data-pbx-kind]');
          if (f) { if (f.id === 'pbx-all') { st = { g: 'all', q: '', t: '' }; if (qi) qi.value = ''; } else if (f.hasAttribute('data-pbx-kind')) st.t = ''; else { var g = f.getAttribute('data-g'); st.g = st.g === g ? 'all' : g; } apply(); return true; }
          var fx = ev.target.closest('[data-fix]');
          if (fx && shelf && root.getAttribute('data-tab') === 'kit') { ev.preventDefault(); if (fx.getAttribute('data-fix') === 'hurt') { st = { g: 'all', q: '', t: 'hurt' }; if (qi) qi.value = ''; apply(); } toShelf(); return true; }
          return false;
        };
      })() : null;

      // ---- the box and the pre-fight screen: tap a piece for its detail line; "tog" pieces get a button that packs it or takes it out
      root.addEventListener('click', function (ev) {
        if (pbx && pbx(ev)) return;
        var f = ev.target.closest('#pfv-filt button');
        if (f) {   // the source filter
          var g = f.getAttribute('data-g');
          all('#pfv-filt button', root).forEach(function (x) { x.classList.toggle('on', x === f); x.setAttribute('aria-pressed', x === f ? 'true' : 'false'); });
          all('.pfv-g > li[data-g]', root).forEach(function (li) { li.hidden = g !== 'all' && li.getAttribute('data-g') !== g; });
          return;
        }
        var tdo = ev.target.closest('[data-pfv-tool]');
        if (tdo && form) {   // a tool button's action: put on, take off, fix
          form.querySelector('[name=do]').value = tdo.getAttribute('data-do'); form.querySelector('[name=tool]').value = tdo.getAttribute('data-pfv-tool');
          tdo.disabled = true; send(form); return;
        }
        var tb = ev.target.closest('.tb[data-a=tool]');
        if (tb) {
          if (openSheet(root, tb)) { say(info, line(tb)); return; }
          all('.tb.pick, .pc.pick', root).forEach(function (x) { x.classList.remove('pick'); }); tb.classList.add('pick');
          var acts = (tb.getAttribute('data-acts') || '').split(';').filter(Boolean).map(function (a) { var q = a.split('|'); return '<button type="button" class="btn ' + esc(q[2]) + '" data-pfv-tool="' + esc(tb.getAttribute('data-arg')) + '" data-do="' + esc(q[0]) + '"' + (q[3] === '1' ? ' disabled' : '') + '>' + esc(q[1]) + '</button>'; }).join('');
          say(info, line(tb) + acts); return;
        }
        var act = ev.target.closest('[data-pfv-act]');
        if (act && form) {
          form.querySelector('[name=do]').value = 'pfd_toggle'; form.querySelector('[name=key]').value = act.getAttribute('data-key'); form.querySelector('[name=on]').value = act.getAttribute('data-on');
          act.disabled = true; send(form); return;
        }
        var b = ev.target.closest('.pc'); if (!b) return;
        var target = root.querySelector('#' + (b.getAttribute('data-info') || 'pfv-info')) || info, a = b.getAttribute('data-a'), on = b.getAttribute('data-on') === '1';
        if (!b.getAttribute('data-info') && openSheet(root, b)) { say(target, line(b)); return; }
        pick(b);
        say(target, line(b) + (a === 'tog' ? '<button type="button" class="btn' + (on ? ' ghost' : ' primary') + '" data-pfv-act="1" data-key="' + esc(b.getAttribute('data-arg')) + '" data-on="' + (on ? '0' : '1') + '">' + (on ? 'Take out' : 'Pack') + '</button>' : ''));
      });
      var auto = root.querySelector('#pfv-auto');
      if (auto) auto.addEventListener('change', function () { var fm = auto.closest('form'); if (fm) send(fm); });
    });
  }
  if (window.__pfvOff) window.__pfvOff();
  document.addEventListener('pfparts-ready', mount);
  window.__pfvOff = function () { document.removeEventListener('pfparts-ready', mount); };
  window.pfvSizes = sizes; window.pfvFrame = frame;
  window.addEventListener('resize', frame);
  var off0 = window.__pfvOff; window.__pfvOff = function () { off0(); window.removeEventListener('resize', frame); document.removeEventListener('pointerdown', outTap, true); closeSheet(); };
  init(); frame();
})();
