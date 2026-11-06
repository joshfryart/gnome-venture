// Fight engine smoke test. Usage: node tools/fight/smoke.js   (needs playwright + chromium; exits 1 on any failure)
// Checks: data lint, every creature plays every scenario with no page errors, no NaN transforms, hat ends worn with no ghost frame, reduced-motion path finishes.
const { chromium } = require('playwright'), path = require('path');
const URL = 'file://' + path.resolve(__dirname, '../../game/fight_demo.html');
const CREATURES = ['wild-boar', 'bramble-wolf', 'black-bear', 'bullfrog', 'cliff-ram', 'dune-scorpion'];
const SCEN = {
  'pluck+hit': [{ from: 'me', to: 'foe', move: 'pluck', dmg: 3 }, { from: 'foe', to: 'me', dmg: 2 }],
  'crit pops hat, refit': [{ from: 'foe', to: 'me', dmg: 6, crit: true }],
  'miss both ways': [{ from: 'me', to: 'foe', move: 'pluck', miss: true }, { from: 'foe', to: 'me', miss: true }],
  'guard': [{ from: 'me', move: 'guard' }, { from: 'foe', to: 'me', dmg: 2 }],
  'flee': [{ from: 'me', move: 'flee' }],
  'win + cheer': [{ from: 'me', to: 'foe', move: 'pluck', dmg: 99 }],
  'gnome KO (hat stays down)': [{ from: 'foe', to: 'me', dmg: 99 }],
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
    for (const [name, list] of Object.entries(SCEN)) {
      await p.evaluate(() => { const e = feDemo(); e.setSpeed(8); });
      const r = await p.evaluate(async (l) => {
        const e = feDemo(), t0 = performance.now(); await e.play(l);
        const nan = [...document.querySelectorAll('.fe-act *')].some(n => /NaN/.test(n.style.transform + n.style.cssText));
        const me = e.acts.me, h = me.hat;
        return { ms: Math.round(performance.now() - t0), nan, hat: h && h.mode, ghost: !!me.ghost, hp: me.hp };
      }, list);
      const alive = r.hp > 0, tag = slug + ' / ' + name;
      if (r.nan) fail(tag + ': NaN in a transform');
      if (alive && r.hat !== 'worn') fail(tag + ': hat not worn at the end (' + r.hat + ')');
      if (alive && r.ghost) fail(tag + ': ghost frame left behind');
      if (!alive && r.hat !== 'free') fail(tag + ': KO gnome should leave the hat on the ground (' + r.hat + ')');
      if (r.ms > 12000) fail(tag + ': took ' + r.ms + ' ms');
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
