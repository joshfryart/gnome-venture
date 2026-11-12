/* Puzzle combat v1 (2.6.74 stage C): the Puzzle box, the starter pick, the pre-fight screen and the result card (includes/pfdeck_view.php, assets/pfv1.css).
   Draws the piece art (assets/pfparts.js), sets the meter widths (no inline styles in the markup: CSP), shows the detail line for a tapped piece,
   and sends the one hidden form (#pfv-f) when a piece is packed or taken out. The server checks everything again. Runs again when the page content is swapped in place. */
(function () {
  function all(sel, root) { return Array.prototype.slice.call((root || document).querySelectorAll(sel)); }
  function sizes() {
    all('.pfv [data-w], .pfv-sheet [data-w]').forEach(function (el) { el.style.width = el.getAttribute('data-w') + '%'; });
    all('.pfv [data-f]').forEach(function (el) { el.style.flex = el.getAttribute('data-f') + ' 1 0'; });
  }
  function mount() {   // every placeholder becomes the piece as the board draws it
    var P = window.PFParts; if (!P || !P.ok) return;
    all('.pfv i.cvh').forEach(function (h) {
      var o = null; try { o = JSON.parse(h.getAttribute('data-p')); } catch (e) { return; }
      var c = P.piece({ size: 'strip', owner: o.o === 'foe' ? 'foe' : 'me', type: o.t, edges: o.e, tag: o.tag || '', num: '' });
      c.className = 'pfb-cv'; c.setAttribute('aria-hidden', 'true'); h.parentNode.replaceChild(c, h);
    });
  }
  function send(form) { if (typeof form.requestSubmit === 'function') form.requestSubmit(); else form.submit(); }
  function esc(x) { return String(x).replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); }

  function init() {
    sizes(); mount();
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
          hurtEl.classList.toggle('good', hurt >= 2); hurtEl.classList.toggle('warn', hurt < 2);
          go.disabled = !(picked.length === N && hurt >= 2);
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

      // ---- the box and the pre-fight screen: tap a piece for its detail line; "tog" pieces get a button that packs it or takes it out
      root.addEventListener('click', function (ev) {
        var f = ev.target.closest('#pfv-filt button');
        if (f) {   // the source filter
          var g = f.getAttribute('data-g');
          all('#pfv-filt button', root).forEach(function (x) { x.classList.toggle('on', x === f); x.setAttribute('aria-pressed', x === f ? 'true' : 'false'); });
          all('.pfv-g > li[data-g]', root).forEach(function (li) { li.hidden = g !== 'all' && li.getAttribute('data-g') !== g; });
          return;
        }
        var act = ev.target.closest('[data-pfv-act]');
        if (act && form) {
          form.querySelector('[name=do]').value = 'pfd_toggle'; form.querySelector('[name=key]').value = act.getAttribute('data-key'); form.querySelector('[name=on]').value = act.getAttribute('data-on');
          act.disabled = true; send(form); return;
        }
        var b = ev.target.closest('.pc'); if (!b) return;
        var target = root.querySelector('#' + (b.getAttribute('data-info') || 'pfv-info')) || info, a = b.getAttribute('data-a'), on = b.getAttribute('data-on') === '1';
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
  window.pfvSizes = sizes;
  init();
})();
