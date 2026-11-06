/* Fight on the stage: mounts FightEngine on #fightscene (data-fight from includes/fight_scene.php) and plays the events of the last action.
   Tap the stage to skip. Buttons stay server forms; they wait while the animation plays. No JS = the plain bars inside stay.
   Pages swap in place after a button (site.js, event gv:swapped), so the stage is (re)mounted on load and after every swap. */
(function () {
  var eng = null, cur = null;
  var reduced = window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;
  function lock(on) { var btns = document.querySelector('.fightbtns'); if (!btns) return; btns.classList.toggle('fs-wait', on); btns.querySelectorAll('button').forEach(function (b) { b.disabled = on; }); }
  function boot() {
    var host = document.getElementById('fightscene');
    if (host === cur) return;
    if (eng) { try { eng.destroy(); } catch (e) { } eng = null; }
    cur = host;
    if (!host || !window.FightEngine) return;
    var D; try { D = JSON.parse(host.getAttribute('data-fight')); } catch (e) { return; }
    try {
      eng = FightEngine.create(host, {
        speed: reduced ? 40 : 1, flat: !!D.over, cols: D.over ? D.over.cols : undefined, rows: D.over ? D.over.rows : undefined,
        onHatTap: function () { var f = document.querySelector('form.hatform'); if (f) { if (f.requestSubmit) f.requestSubmit(); else f.submit(); } }   // the server heals once (do=hat)
      });
      eng.add('me', { rig: 'gnome', parts: D.parts, col: D.over ? D.over.mx : 2, row: D.over ? D.over.my : undefined, side: 'me', name: D.me.name, hp: D.me.hp, max: D.me.max });
      var foe = { rig: D.slug, img: D.mini, col: D.over ? D.over.fx : 8, row: D.over ? D.over.my : undefined, flip: true, side: 'foe', name: D.foe.name, hp: D.foe.hp, max: D.foe.max };
      var rig = FightEngine.CRIT && FightEngine.CRIT[D.slug];
      if (rig) { foe.parts = {}; rig.parts.forEach(function (p) { foe.parts[p.img] = D.base + '/rig-' + D.slug + '-' + p.img + '.png'; }); }
      eng.add('foe', foe);
    } catch (e) { if (window.console) console.warn('fightscene: ' + (e && e.message)); if (eng) { eng.destroy(); eng = null; } host.removeAttribute('role'); return; }
    var mine = eng, list = D.events.length ? D.events : null;
    lock(true);
    if (list && list.length > 12) mine.setSpeed(Math.min(6, list.length / 6));   // Fight on / Auto-win: about 7 s
    host.addEventListener('click', function () { mine.setSpeed(40); });   // tap to skip
    (list ? mine.play(list) : mine.together([{ from: 'me', move: 'enter' }, { from: 'foe', move: 'enter' }]))
      .catch(function () { }).then(function () {
        var m = mine.acts.me;   // hat still on the ground from an earlier turn (a reload, or the flag set by the server): put it down
        if (D.hat && m && m.hp > 0 && m.hat && m.hat.mode === 'worn') mine.popHat(m, m.dir);
      }).then(function () { mine.setSpeed(reduced ? 40 : 1); if (eng === mine) lock(false); });
  }
  document.addEventListener('gv:swapped', boot);
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', boot); else boot();
})();
