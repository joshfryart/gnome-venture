(function () {
  var eng, busy = false, slug = 'wild-boar';
  function mount() {
    document.getElementById('stage').innerHTML = '';
    eng = FightEngine.create(document.getElementById('stage'), { speed: document.getElementById('slow').checked ? .3 : 1 });
    eng.add('me', { rig: 'gnome', img: 'assets/img/fight/demo-gnome-side.png', col: 2, side: 'me', name: 'You', hp: 20 });
    eng.add('foe', { rig: slug, img: 'assets/img/mini/mini-' + slug + '.png', col: 8, flip: true, side: 'foe', name: slug.replace(/-/g, ' '), hp: 12 });
  }
  function go(list) { if (busy) return; busy = true; eng.play(list).then(function () { busy = false; }); }
  function rnd(a, b) { return a + Math.floor(Math.random() * (b - a + 1)); }
  document.getElementById('pl').onclick = function () {
    var f = eng.acts.foe, m = eng.acts.me; if (f.hp <= 0 || m.hp <= 0) { mount(); return; }
    var d = rnd(3, 6), list = [{ from: 'me', to: 'foe', move: 'pluck', dmg: d, crit: d >= 6, miss: Math.random() < .15 }];
    if (f.hp - d > 0) list.push({ from: 'foe', to: 'me', dmg: rnd(2, 5), miss: Math.random() < .2 });
    go(list);
  };
  document.getElementById('gd').onclick = function () { go([{ from: 'me', move: 'guard' }, { from: 'foe', to: 'me', dmg: 2 }]); };
  document.getElementById('fl').onclick = function () { go([{ from: 'me', move: 'flee' }]); };
  document.getElementById('cr').onchange = function () { slug = this.value; mount(); };
  document.getElementById('slow').onchange = mount;
  mount();
})();
