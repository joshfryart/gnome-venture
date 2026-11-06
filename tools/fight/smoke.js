// Fight engine smoke test. Usage: node tools/fight/smoke.js   (needs playwright + chromium; exits 1 on any failure)
// Checks: data lint, every creature plays every scenario with no page errors, no NaN transforms, hat ends worn with no ghost frame, reduced-motion path finishes.
const { chromium } = require('playwright'), path = require('path');
const URL = 'file://' + path.resolve(__dirname, '../../game/fight_demo.html');
const CREATURES = ['wild-boar', 'bramble-wolf', 'black-bear', 'bullfrog', 'cliff-ram', 'dune-scorpion', 'shore-crab'];
// hat = what the gnome's hat should be at the end (worn, or free = on the ground)
const SCEN = {
  'pluck+hit': { hat: 'worn', list: [{ from: 'me', to: 'foe', move: 'pluck', dmg: 3 }, { from: 'foe', to: 'me', dmg: 2 }] },
  'crit alone keeps the hat': { hat: 'worn', list: [{ from: 'foe', to: 'me', dmg: 6, crit: true }] },
  'below 25%: hat down, stays down': { hat: 'free', tap: true, list: [{ from: 'foe', to: 'me', dmg: 16 }] },
  'server pop flag': { hat: 'free', tap: true, list: [{ from: 'foe', to: 'me', dmg: 1, pop: true }] },
  'plain attack': { hat: 'worn', list: [{ from: 'me', to: 'foe', move: 'attack', dmg: 4 }, { from: 'foe', to: 'me', dmg: 1 }] },
  'event types: snack, hurt, stumble, charm, dazed, note, end': { hat: 'worn', list: [{ from: 'me', move: 'snack', heal: 3 }, { from: 'foe', move: 'hurt', dmg: 1 }, { from: 'me', move: 'stumble' }, { from: 'me', move: 'charm', ok: true }, { from: 'foe', move: 'dazed' }, { from: 'me', move: 'note' }, { end: 'peace' }] },
  'miss both ways': { hat: 'worn', list: [{ from: 'me', to: 'foe', move: 'pluck', miss: true }, { from: 'foe', to: 'me', miss: true }] },
  'guard': { hat: 'worn', list: [{ from: 'me', move: 'guard' }, { from: 'foe', to: 'me', dmg: 2 }] },
  'flee': { hat: 'worn', list: [{ from: 'me', move: 'flee' }] },
  'win + cheer (hat refit)': { hat: 'worn', list: [{ from: 'me', to: 'foe', move: 'pluck', dmg: 99 }] },
  'win while hat down: refit, no heal': { hat: 'worn', list: [{ from: 'foe', to: 'me', dmg: 16 }, { from: 'me', to: 'foe', move: 'pluck', dmg: 99 }] },
  'gnome KO (hat stays down, no tap)': { hat: 'free', list: [{ from: 'foe', to: 'me', dmg: 99 }] },
};
let fails = 0; const fail = m => { fails++; console.log('FAIL', m); };
(async () => {
  const b = await chromium.launch();
  async function open(opts) {
    const ctx = await b.newContext(Object.assign({ viewport: { width: 412, height: 400 } }, opts)), p = await ctx.newPage();
    p.on('pageerror', e => fail('pageerror: ' + e.message)); p.on('console', m => { if (m.type() === 'error') fail('console: ' + m.text()); });
    await p.addInitScript(() => { Math.random = () => 0.9; }); await p.goto(URL); await p.waitForTimeout(1800); return p;
  }
  const p = await open();
  const lint = await p.evaluate(() => FightEngine.validate()); lint.forEach(m => fail('lint: ' + m));
  for (const slug of CREATURES) {
    await p.selectOption('#cr', slug); await p.waitForTimeout(1800);
    for (const [name, sc] of Object.entries(SCEN)) {
      await p.evaluate(() => { const e = feDemo(); e.setSpeed(8); });
      const r = await p.evaluate(async (l) => {
        const e = feDemo(), t0 = performance.now(); await e.play(l);
        const nan = [...document.querySelectorAll('.fe-act *')].some(n => /NaN/.test(n.style.transform + n.style.cssText));
        const me = e.acts.me, h = me.hat;
        return { ms: Math.round(performance.now() - t0), nan, hat: h && h.mode, ghost: !!me.ghost, hp: me.hp };
      }, sc.list);
      const tag = slug + ' / ' + name;
      if (r.nan) fail(tag + ': NaN in a transform');
      if (r.hat !== sc.hat) fail(tag + ': hat is ' + r.hat + ', want ' + sc.hat);
      if (r.hat === 'worn' && r.ghost) fail(tag + ': ghost frame left behind');
      if (r.ms > 12000) fail(tag + ': took ' + r.ms + ' ms');
      if (sc.tap) {   // tap the fallen hat: it goes back on, +5 hp (capped), tap target gone
        await p.waitForSelector('.fe-hattap', { state: 'visible', timeout: 4000 }).catch(() => fail(tag + ': no tap target'));
        const before = r.hp; await p.click('.fe-hattap', { force: true, timeout: 3000 })   // force: the target pulses forever, so Playwright never sees it as stable.catch(e => fail(tag + ': tap failed ' + e.message.split('\n')[0]));
        await p.waitForFunction(() => { const m = feDemo().acts.me; return m.hat.mode === 'worn'; }, null, { timeout: 8000 }).catch(() => fail(tag + ': hat not back on after tap'));
        await p.waitForTimeout(400);
        const after = await p.evaluate(() => ({ hp: feDemo().acts.me.hp, tap: !!document.querySelector('.fe-hattap'), ghost: !!feDemo().acts.me.ghost }));
        if (after.hp !== Math.min(20, before + 5)) fail(tag + ': hp ' + before + ' -> ' + after.hp + ', want ' + Math.min(20, before + 5));
        if (after.tap || after.ghost) fail(tag + ': tap target or ghost left after pickup');
      } else if (await p.evaluate(() => !!document.querySelector('.fe-hattap')) ) fail(tag + ': tap target should not exist');
      await p.selectOption('#cr', slug); await p.waitForTimeout(1500);   // remount = fresh fight (also exercises destroy())
    }
    console.log('ok', slug);
  }
  await p.context().close();
  const q = await open({ reducedMotion: 'reduce' });
  const t = await q.evaluate(async () => { const t0 = performance.now(); await feDemo().play([{ from: 'me', to: 'foe', move: 'pluck', dmg: 99 }]); return performance.now() - t0; });
  if (t > 1500) fail('reduced motion still slow: ' + Math.round(t) + ' ms'); else console.log('ok reduced-motion', Math.round(t) + ' ms');
  await b.close(); console.log(fails ? fails + ' failure(s)' : 'all good'); process.exit(fails ? 1 : 0);
})();
