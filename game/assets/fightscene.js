/* Fight on the stage: mounts FightEngine on #fightscene (data-fight from includes/fight_scene.php) and plays the events of the last action.
   Tap the stage to skip. Buttons stay server forms; they wait while the animation plays. No JS = the plain bars inside stay.
   Pages swap in place after a button (site.js, event gv:swapped), so the stage is (re)mounted on load and after every swap. */
(function () {
  var eng = null, cur = null;
  var reduced = window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;
  function lock(on) { document.querySelectorAll('.fightbtns, .fsdock').forEach(function (btns) { btns.classList.toggle('fs-wait', on); btns.querySelectorAll('button').forEach(function (b) { if (on) { b.setAttribute('data-wasdis', b.disabled ? '1' : ''); b.disabled = true; } else { b.disabled = b.getAttribute('data-wasdis') === '1'; } }); }); }
  function boot() {
    var host = document.getElementById('fightscene');
    if (host === cur) return;
    if (eng) { try { eng.destroy(); } catch (e) { } eng = null; }
    cur = host; document.body.classList.remove('fs-hold');
    if (!host || !window.FightEngine) return;
    var D; try { D = JSON.parse(host.getAttribute('data-fight')); } catch (e) { return; }
    try {
      eng = FightEngine.create(host, {
        speed: reduced ? 40 : 1, flat: !!D.over, scale: D.over ? .62 : 1, cols: D.over ? D.over.cols : undefined, rows: D.over ? D.over.rows : undefined,
        onHatTap: function () { var f = document.querySelector('form.hatform'); if (f) { if (f.requestSubmit) f.requestSubmit(); else f.submit(); } }   // the server heals once (do=hat)
      });
      var ver = D.v ? '?v=' + D.v : '';
      eng.add('me', { rig: 'gnome', sheet: D.sheet || D.base + '/rig-gnome.png' + ver, col: D.over ? D.over.mx : 2, row: D.over ? D.over.my : undefined, side: 'me', name: D.me.name, hp: D.me.hp, max: D.me.max });
      if (D.event) {   // an event / riddle / skill check: no fight, no health, the prop stands where the foe would
        eng.add('foe', { emoji: D.event, size: 2, col: D.over ? D.over.fx : 8, row: D.over ? D.over.my : undefined, flip: true });
      } else {
      var foe = { rig: D.slug, img: D.mini, col: D.over ? D.over.fx : 8, row: D.over ? D.over.my : undefined, flip: true, side: 'foe', name: D.foe.name, hp: D.foe.hp, max: D.foe.max };
      if (FightEngine.hasRig(D.slug)) foe.sheet = D.base + '/rig-' + D.slug + '.png' + ver;   // a rigged creature: one sheet of parts (assets/fightrigs.js); otherwise the still mini
      eng.add('foe', foe);
      }
      (D.pals || []).slice(0, 3).forEach(function (pl, i) {   // the Puzzle Pals taken along stand behind the gnome (no health bar, they only keep it company)
        var mx = D.over ? D.over.mx : 2, my = D.over ? D.over.my : 3, rws = D.over ? D.over.rows : 7;
        var row = Math.max(0, Math.min(rws - 1, my + [1, -1, 2][i])); if (row === my) row = my + 1;
        eng.add('pal' + i, { img: pl.img, size: 1.15, col: Math.max(0, mx - 1), row: row, name: pl.name });
      });
    } catch (e) { if (window.console) console.warn('fightscene: ' + (e && e.message)); if (eng) { eng.destroy(); eng = null; } host.removeAttribute('role'); return; }
    var mine = eng, list = D.events.length ? D.events : null;
    window.feScene = mine;   // the running engine (for the tests and for debugging in the console)
    host.classList.add('fs-live');   // the stage takes taps (skip) only while the script runs it
    if (D.finale) {   // the end scene: last blow, the foe falls, XP and loot drop and are drawn into the gnome; the map stays locked until then
      document.body.classList.add('fs-hold');
      if (list.length > 12) mine.setSpeed(Math.min(6, list.length / 6));
      host.addEventListener('click', function () { mine.setSpeed(2); });
      var done = function () {
        mine.setSpeed(reduced ? 40 : 1); host.classList.add('fs-done'); host.classList.remove('fs-live'); document.body.classList.remove('fs-hold');
        if (!D.reward && D.over) { try { if (!(window.gvRefresh && window.gvRefresh())) window.location.reload(); } catch (e) { } }   // the gnome ran off the map: look again so the map draws him back (the scene is spent)
      };
      if (D.reward) mine.holdCheer(true);
      mine.play(list).then(function () { return D.reward ? mine.reward(D.reward) : null; }).catch(function () { }).then(done);
      return;
    }
    lock(true);
    { var m0 = mine.acts.me; if (D.hat && m0 && m0.hp > 0 && m0.hat && m0.hat.mode === 'worn') mine.dropHat(m0, m0.dir); }   // v2.6.07: the hat is still on the ground from an earlier turn: it starts there instead of being worn through the attack and falling off again

    if (list && list.length > 12) mine.setSpeed(Math.min(6, list.length / 6));   // Fight on / Auto-win: about 7 s
    host.addEventListener('click', function () { mine.setSpeed(2); });   // tap to speed up (2x, not a jump to the end)
    (list ? mine.play(list) : mine.together([{ from: 'me', move: 'enter' }, { from: 'foe', move: 'enter' }]))
      .catch(function (e) { if (window.console) console.warn('fightscene play: ' + (e && e.message)); }).then(function () {
        var m = mine.acts.me;   // safety net: the hat should already be lying down (see below), but if the server flagged it during this turn, put it down
        if (D.hat && m && m.hp > 0 && m.hat && m.hat.mode === 'worn') mine.popHat(m, m.dir);
      }).then(function () { mine.setSpeed(reduced ? 40 : 1); if (eng === mine) lock(false); });
  }
  document.addEventListener('gv:swapped', boot);
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', boot); else boot();
})();

/* The fight menu on the map (includes/fight_scene.php fight_dock_html): Fight / Item open a list, tap an option once to read it, again to do it.
   After an action the menu closes at once (and the page comes back with it closed), so the fight plays in full view. Delegated, so it works after in-place page swaps. */
(function () {
  document.documentElement.classList.add('fsd-js');
  function closeAll(dock) {
    dock.querySelectorAll('.fsc-sub').forEach(function (s) { s.classList.remove('open'); var i = s.querySelector('.fsc-info'); if (i) i.textContent = ''; });
    dock.querySelectorAll('.fsc-top').forEach(function (b) { b.classList.remove('on'); });
    dock.querySelectorAll('.fsc-opt').forEach(function (b) { disarm(b); });
  }
  function disarm(b) { b.classList.remove('armed'); var t = b.querySelector('.o-t'); if (t && b.hasAttribute('data-was')) { t.textContent = b.getAttribute('data-was'); b.removeAttribute('data-was'); } }
  document.addEventListener('click', function (e) {
    var dock = e.target.closest && e.target.closest('.fsc'); if (!dock) return;
    var top = e.target.closest('.fsc-top');
    if (top) {
      e.preventDefault(); if (top.disabled) return;
      var sub = dock.querySelector('.fsc-sub[data-for="' + top.getAttribute('data-open') + '"]'), was = sub && sub.classList.contains('open');
      closeAll(dock);
      if (sub && !was) { sub.classList.add('open'); top.classList.add('on'); sub.querySelector('.fsc-info').textContent = sub.getAttribute('data-hint') || ''; }
      return;
    }
    var opt = e.target.closest('.fsc-opt'); if (!opt || opt.disabled) return;
    if (opt.classList.contains('fsc-hatbtn')) return;   // the Hat button is one tap: the form goes at once
    if (!opt.classList.contains('armed')) {   // first tap: read it
      e.preventDefault();
      dock.querySelectorAll('.fsc-opt').forEach(function (b) { if (b !== opt) disarm(b); });
      opt.classList.add('armed');
      var sub2 = opt.closest('.fsc-sub'), say = opt.getAttribute('data-desc') || '';
      if (sub2) sub2.querySelector('.fsc-info').textContent = say + ' Tap again.';
      else { var t = opt.querySelector('.o-t'); if (t && opt.getAttribute('data-armtext')) { opt.setAttribute('data-was', t.textContent); t.textContent = opt.getAttribute('data-armtext'); } closeSubs(dock); }
      return;
    }
    setTimeout(function () { closeAll(dock); }, 0);   // second tap: the form goes, the menu goes back to its start state
  });
  function closeSubs(dock) { dock.querySelectorAll('.fsc-sub').forEach(function (s) { s.classList.remove('open'); }); dock.querySelectorAll('.fsc-top').forEach(function (b) { b.classList.remove('on'); }); }
})();
