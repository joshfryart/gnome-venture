/* v2.0.38: the stage. A 480x270 backdrop with sprites standing on it: party left, foes right.
   <div class="gvs" data-stage='{"bg":"...","units":[{"id","side":"p|f","name","src","mini","hp","max","ko"}]}'></div>
   window.GVStage: init(el), set(el, data), act(el, id, 'lunge'|'hit'|'ko'|'heal'|'cheer'), float(el, id, text, cls). Art is optional: no bg = CSS colours, no src = a blob. */
(function () {
  'use strict';
  var W = 480, H = 270;
  var store = {};   // stage id => {unit id: hp} from its last draw

  function mk(tag, cls, parent) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (parent) parent.appendChild(n);
    return n;
  }

  function fit(el) {
    var box = el.firstChild;
    if (!box) return;
    var w = el.clientWidth || W;
    var s = w >= W ? Math.floor(w / W) : w / W;   // whole-number zoom keeps pixels crisp; below 1x scale smoothly
    box.style.transform = 'scale(' + s + ')';
    el.style.height = Math.round(H * s) + 'px';
  }

  function render(el, data) {
    el.textContent = '';
    var box = mk('div', 'gvs-box', el);
    if (data.bg) {
      var bg = mk('img', 'gvs-bg pix', box);
      bg.src = data.bg; bg.alt = ''; bg.width = W; bg.height = H;
    }
    var slots = { p: 0, f: 0 };
    (data.units || []).forEach(function (u) {
      var side = u.side === 'f' ? 'f' : 'p';
      var n = slots[side]++;
      var d = mk('div', 'gvs-u gvs-' + side + n + (u.ko ? ' ko' : ''), box);
      d.setAttribute('data-id', u.id);
      mk('span', 'gvs-base' + (u.mini ? ' none' : ''), d);
      if (u.html) {
        var hw = mk('span', 'gvs-html', d);
        hw.innerHTML = u.html;   // markup the server built itself (the gnome drawing, an emoji icon); never player text
      } else if (u.src) {
        var im = mk('img', 'gvs-sp pix', d);
        im.src = u.src; im.alt = u.name || '';
      } else {
        mk('span', 'gvs-blob', d);
      }
      if (u.max > 0) {
        var bar = mk('span', 'gvs-hp', d);
        var fill = mk('i', '', bar);
        fill.style.width = Math.max(0, Math.min(100, Math.round(100 * u.hp / u.max))) + '%';
      }
    });
    fit(el);
    // a re-drawn stage (after a round): show what changed since the last draw of the same stage
    var key = el.id || '', prev = key ? (store[key] || null) : null, now = {};
    (data.units || []).forEach(function (u) { now[u.id] = u.hp; });
    if (key) store[key] = now;
    if (prev) (data.units || []).forEach(function (u) {
      if (prev[u.id] === undefined || u.max <= 0) return;
      var dlt = u.hp - prev[u.id];
      if (dlt < 0) { api.act(el, u.id, 'hit'); api.float(el, u.id, String(dlt), 'dmg'); }
      else if (dlt > 0) { api.act(el, u.id, 'heal'); api.float(el, u.id, '+' + dlt, 'heal'); }
    });
  }

  function unit(el, id) {
    var list = el.querySelectorAll('.gvs-u');
    for (var i = 0; i < list.length; i++) if (list[i].getAttribute('data-id') === id) return list[i];
    return null;
  }

  var api = {
    init: function (el) {
      if (el.getAttribute('data-ready')) return;
      el.setAttribute('data-ready', '1');
      var data = {};
      try { data = JSON.parse(el.getAttribute('data-stage') || '{}'); } catch (e) { data = {}; }
      render(el, data);
      if (window.ResizeObserver) new ResizeObserver(function () { fit(el); }).observe(el);
      else window.addEventListener('resize', function () { fit(el); });
    },
    set: function (el, data) { render(el, data); },
    act: function (el, id, what) {
      var u = unit(el, id);
      if (!u) return;
      if (what === 'ko') { u.classList.add('ko'); return; }
      var c = 'a-' + what;
      u.classList.remove(c);
      void u.offsetWidth;   // restart the animation
      u.classList.add(c);
      setTimeout(function () { u.classList.remove(c); }, 700);
    },
    float: function (el, id, text, cls) {
      var u = unit(el, id);
      if (!u) return;
      var f = mk('span', 'gvs-fl ' + (cls || ''), u);
      f.textContent = text;
      setTimeout(function () { if (f.parentNode) f.parentNode.removeChild(f); }, 1000);
    }
  };
  window.GVStage = api;

  function boot() {
    var list = document.querySelectorAll('.gvs[data-stage]:not([data-ready])');
    for (var i = 0; i < list.length; i++) api.init(list[i]);
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', boot); else boot();
  // site.js swaps <main> in place after a click: draw any new stage that shows up
  if (window.MutationObserver) new MutationObserver(boot).observe(document.querySelector('main') || document.body, { childList: true, subtree: true });
})();
