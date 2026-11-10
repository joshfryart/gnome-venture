/* Demo / showcase for the fight engine (fight_demo.html). Tools drive it through feDemo() (tools/fight/). ?sheet=<url> previews another gnome colour sheet (php tools/gnome_rig_parts.php out=file). */
(function () {
  var IMG = window.FE_IMG || {};   // tools/fight/build_demo.py inlines every picture here for the one-file version
  function pic(p) { return IMG[p] || p; }
  var GNOME = (/[?&]sheet=([\w\/.-]+)/.exec(location.search) || [])[1] || 'assets/img/fight/rig-gnome.png';
  var $ = function (id) { return document.getElementById(id); };
  if (/[?&]wide=1/.test(location.search)) document.querySelector('main').style.maxWidth = 'none';   // tools: a big stage to look at closely
  var eng, busy = false, slug = (/[?&]foe=([\w-]+)/.exec(location.search) || [])[1] || (FightEngine.DATA.rigs['wild-boar'] ? 'wild-boar' : Object.keys(FightEngine.DATA.rigs)[0]);
  var rigs = FightEngine.DATA.rigs, sel = $('cr'), groups = {};
  Object.keys(rigs).sort().forEach(function (s) { var a = rigs[s][0]; (groups[a] = groups[a] || []).push(s); });
  Object.keys(groups).sort().forEach(function (a) {
    var g = document.createElement('optgroup'); g.label = a + ' (' + groups[a].length + ')';
    groups[a].forEach(function (s) { var o = document.createElement('option'); o.textContent = s; g.appendChild(o); });
    sel.appendChild(g);
  });
  sel.value = slug;
  function foeOf(s) { return { rig: s, sheet: pic('assets/img/fight/rig-' + s + '.png'), img: pic('assets/img/mini/mini-' + s + '.png'), col: 8, flip: true, side: 'foe', name: s.replace(/^c25-/, '').replace(/-/g, ' '), hp: 12 }; }
  function mount() {
    if (eng) eng.destroy();
    eng = FightEngine.create($('stage'), { speed: $('slow').checked ? .3 : 1, onHatTap: function (id) { go([{ from: id, move: 'fixhat', heal: 5 }]); } });
    eng.add('me', { rig: 'gnome', sheet: pic(GNOME), col: 2, side: 'me', name: 'You', hp: 20 });
    eng.add('foe', foeOf(slug));
    busy = true; eng.together([{ from: 'me', move: 'enter' }, { from: 'foe', move: 'enter' }]).then(function () { busy = false; });
  }
  function go(list) { if (busy) return; busy = true; eng.play(list).then(function () { busy = false; }); }
  function rnd(a, b) { return a + Math.floor(Math.random() * (b - a + 1)); }
  function over() { var f = eng.acts.foe, m = eng.acts.me; if (f.hp <= 0 || m.hp <= 0 || f.gone || m.gone) { mount(); return true; } return false; }
  var ACT = {
    pluck: function () { var d = rnd(3, 6), l = [{ from: 'me', to: 'foe', move: 'pluck', dmg: d, crit: d >= 6, miss: Math.random() < .15 }]; if (eng.acts.foe.hp - d > 0) l.push({ from: 'foe', to: 'me', dmg: rnd(2, 5), miss: Math.random() < .2 }); return l; },
    attack: function () { return [{ from: 'me', to: 'foe', move: 'attack', dmg: rnd(2, 4) }]; },
    guard: function () { return [{ from: 'me', move: 'guard' }, { from: 'foe', to: 'me', dmg: 2 }]; },
    snack: function () { return [{ from: 'me', move: 'snack', heal: 4 }]; },
    foe: function () { return [{ from: 'foe', to: 'me', dmg: rnd(2, 5) }]; },
    miss: function () { return [{ from: 'foe', to: 'me', miss: true }]; },
    hat: function () { return [{ from: 'foe', to: 'me', dmg: 1, pop: true }]; },
    win: function () { return [{ from: 'me', to: 'foe', move: 'pluck', dmg: 99, crit: true }]; },
    lose: function () { return [{ from: 'foe', to: 'me', dmg: 99 }]; },
    flee: function () { return [{ from: 'me', move: 'flee' }]; }
  };
  document.addEventListener('click', function (e) {
    var b = e.target.closest && e.target.closest('[data-act]'); if (b && !over()) go(ACT[b.getAttribute('data-act')]());
    var f = e.target.closest && e.target.closest('[data-fid]'); if (f && !busy) eng.fidget('me', f.getAttribute('data-fid'));
    var t = e.target.closest && e.target.closest('[data-foe]'); if (t) { slug = t.getAttribute('data-foe'); sel.value = slug; mount(); $('stage').scrollIntoView({ block: 'nearest', behavior: 'smooth' }); }
  });
  sel.onchange = function () { slug = this.value; mount(); };
  $('slow').onchange = mount;
  window.feDemo = function () { return eng; };
  window.feFoe = foeOf;
  mount();
  if (window.feGallery) window.feGallery(groups, foeOf, pic(GNOME));
})();
