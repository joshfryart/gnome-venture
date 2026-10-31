/* Delve mockup 4: demo logic only. No inline styles (CSP style-src 'self'): state lives in data-* attributes, CSS does the rest. */
(function () {
  'use strict';
  var root = document.documentElement;
  var qs = new URLSearchParams(location.search);
  var theme = qs.get('theme') || (matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
  root.dataset.theme = theme;

  document.addEventListener('DOMContentLoaded', function () {
    var $ = function (id) { return document.getElementById(id); };
    var dv = $('delve'), tray = $('tray');
    var S = { oil: 6, stir: 3, sel: 'moss', secret: 0, used: {}, mode: 'explore', foe: 12, you: 14, glim: 9, lark: 8, glimmer: false, blind: false };

    // what each hotspot offers: a wise (quiet) verb first, a greedy (loud) one second
    var HS = {
      moss: { ico: '🍄', name: 'Glowing moss', kind: 'quiet', line: 'Soft blue light. Are those letters?', acts: [
        { ico: '📖', b: 'Read it', s: 'Lore', odds: 70, quiet: true, ok: 'The moss spells WIND. A draught behind the crack!', secret: true },
        { ico: '🧺', b: 'Scrape some', s: '+2 moss · wakes 1', odds: 100, loud: 1, ok: '+2 Glowcap moss. Scritch scritch.', pop: '+2 🍄' }] },
      crack: { ico: '🪨', name: 'The crack', kind: 'quiet', line: 'Cold air hums through it.', acts: [
        { ico: '👂', b: 'Listen', s: 'Sense', odds: 65, quiet: true, ok: 'Water, deep down. And snoring: the beetle sleeps hard.', stirUp: true },
        { ico: '⛏️', b: 'Chip it wider', s: 'Grit · wakes 2', odds: 55, loud: 2, ok: 'Chunks fall. A Cave pearl rolls out!', pop: '+1 ⚪' }] },
      chest: { ico: '🧰', name: 'Old chest', kind: 'loud', line: 'Rusty lock. Something rattles inside.', acts: [
        { ico: '🤏', b: 'Ease it open', s: 'Nimble · quiet', odds: 50, quiet: true, ok: 'Click. 38 Petals and a Silk thread.', pop: '+38 🌸', fail: 'Creak! The lid sticks. (wakes 1)', failLoud: 1 },
        { ico: '💪', b: 'Pry it', s: 'Sure · wakes 2', odds: 100, loud: 2, ok: 'CRACK! 38 Petals and a Silk thread.', pop: '+38 🌸' }] },
      beetle: { ico: '🪲', name: 'Sleeping beetle', kind: 'loud', line: 'A Bellcap Beetle, curled on the path.', acts: [
        { ico: '🤸', b: 'Sneak past', s: 'Nimble', odds: 60, quiet: true, ok: 'Tiptoe tiptoe. You are past it.', fail: 'A pebble skitters… (wakes 2)', failLoud: 2, path: true },
        { ico: '⚔️', b: 'Bonk it first', s: 'Free hit · starts a fight', odds: 100, fight: true }] },
      exit: { ico: '🕳️', name: 'Tunnel down', kind: 'path', line: 'Chamber 3 is below. The beetle lies in the way.', acts: [
        { ico: '⬇️', b: 'Go deeper', s: 'Next chamber', odds: 100, next: true }] },
      nook: { ico: '✨', name: 'Hidden nook', kind: 'secret', line: 'A Glowing bead and a little oil jar.', acts: [
        { ico: '🫙', b: 'Take them', s: '+3 oil · quiet', odds: 100, quiet: true, ok: 'Found: Glowing bead, +3 oil!', oilUp: 3, pop: '+3 oil', costFree: true }] }
    };

    function el(tag, cls, txt) { var e = document.createElement(tag); if (cls) e.className = cls; if (txt != null) e.textContent = txt; return e; }
    function oilIco() { return el('span', 'oilico'); }

    function log(ico, txt) {
      var li = el('li', 'new'); li.appendChild(el('span', '', ico)); li.appendChild(document.createTextNode(txt));
      var l = $('j-list'); l.insertBefore(li, l.firstChild);
      while (l.children.length > 4) { var last = l.lastElementChild; document.querySelector('.j-list.old').prepend(last); last.className = ''; }
    }
    function pop(txt, bad) { var p = $('pop'); p.textContent = txt; p.className = 'pop' + (bad ? ' bad' : ''); void p.offsetWidth; p.classList.add('go'); }

    function paint() {
      dv.dataset.oil = S.oil; dv.dataset.stir = S.stir; dv.dataset.secret = S.secret; dv.dataset.mode = S.mode;
      document.querySelectorAll('.oil-cells li').forEach(function (li, i) { li.classList.toggle('on', i < S.oil); });
      $('oil-n').textContent = S.oil;
      document.querySelectorAll('.hs').forEach(function (b) {
        b.setAttribute('aria-pressed', String(b.dataset.hs === S.sel && S.mode === 'explore'));
        b.classList.toggle('used', !!S.used[b.dataset.hs]);
      });
      bars(); renderTray();
    }
    function bars() {
      [['you', 18], ['glim', 10], ['lark', 8]].forEach(function (m) {
        var p = $('hp-' + m[0]); p.value = Math.max(0, S[m[0]]); p.classList.toggle('low', S[m[0]] / m[1] < .4);
        $('hpn-' + m[0]).textContent = Math.max(0, S[m[0]]) + '/' + m[1];
      });
      $('foe-bar').value = S.foe; $('you-bar').value = Math.max(0, S.you);
    }

    function actBtn(a, primary, onClick) {
      var b = el('button', 'act' + (primary ? ' primary' : '') + (a.red ? ' red' : '')); b.type = 'button';
      b.appendChild(el('span', 'a-ico', a.ico));
      var t = el('span', 'a-txt'); t.appendChild(el('b', '', a.b));
      var s = el('small', '', a.s + (a.costFree || a.noOil ? '' : ' · ')); if (!a.costFree && !a.noOil) { s.appendChild(oilIco()); s.appendChild(document.createTextNode('1')); }
      t.appendChild(s); b.appendChild(t);
      var oddsCls = a.odds >= 100 ? 'sure' : a.odds >= 65 ? 'hi' : a.odds >= 45 ? '' : 'lo';
      b.appendChild(el('span', 'odds ' + oddsCls, a.odds >= 100 ? 'sure' : a.odds + '%'));
      if (a.disabled) b.disabled = true;
      b.addEventListener('click', onClick);
      return b;
    }

    function head(ico, title, kind, keyTxt) {
      var h = el('div', 'tc-head'); h.appendChild(el('span', 'tc-ico', ico)); var h2 = el('h2', '', title); h2.id = 'tc-title'; h.appendChild(h2);
      if (keyTxt) h.appendChild(el('span', 'key ' + kind, keyTxt));
      return h;
    }

    function renderTray() {
      tray.textContent = '';
      var acts = el('div', 'tc-acts');
      if (S.mode === 'fight') {
        tray.dataset.kind = 'foe';
        tray.appendChild(head('🪲', 'Bellcap Beetle', 'foe', 'Lv 6'));
        tray.appendChild(el('p', 'tc-line', S.turn === 'foe' ? 'The beetle rears up…' : 'It clacks its shell. Your move.'));
        var dis = S.turn === 'foe';
        acts.appendChild(actBtn({ ico: '⚔️', b: 'Bonk', s: 'd6+2 · Grit', odds: 75, noOil: true, disabled: dis }, true, function () { fight('bonk'); }));
        acts.appendChild(actBtn({ ico: '✨', b: 'Glim: Glimmer', s: S.glimmer ? 'Used this fight' : 'Dazzles it: next hit misses', odds: 100, noOil: true, disabled: dis || S.glimmer }, false, function () { fight('glim'); }));
        acts.appendChild(actBtn({ ico: '🏃', b: 'Scurry', s: 'Back to the stairs · Nimble', odds: 55, noOil: true, disabled: dis }, false, function () { fight('run'); }));
        tray.appendChild(acts);
        return;
      }
      if (S.mode === 'dark') {
        tray.dataset.kind = 'loud';
        tray.appendChild(head('🌑', 'The lantern gutters', 'loud', 'No oil'));
        tray.appendChild(el('p', 'tc-line', 'Pitch black. You can still feel your way.'));
        acts.appendChild(actBtn({ ico: '🪜', b: 'Climb out', s: 'Keep what you found', odds: 100, noOil: true }, true, function () { $('dlg-out').showModal(); }));
        acts.appendChild(actBtn({ ico: '🖐️', b: 'Feel your way on', s: 'Every roll −20%', odds: 35, noOil: true }, false, function () { $('dlg-next').showModal(); }));
        tray.appendChild(acts);
        return;
      }
      if (S.mode === 'won') {
        tray.dataset.kind = 'path';
        tray.appendChild(head('🏅', 'Path clear', 'path', '+14 XP'));
        tray.appendChild(el('p', 'tc-line', 'The beetle scuttles off. It dropped a Bellcap shell.'));
        acts.appendChild(actBtn({ ico: '⬇️', b: 'Go deeper', s: 'Chamber 3', odds: 100 }, true, function () { spend(); $('dlg-next').showModal(); }));
        acts.appendChild(actBtn({ ico: '🔎', b: 'Look around more', s: 'Chest and moss still here', odds: 100, noOil: true }, false, function () { S.mode = 'explore'; S.sel = 'chest'; paint(); }));
        tray.appendChild(acts);
        return;
      }
      var h = HS[S.sel];
      if (!h) {
        tray.dataset.kind = 'path';
        tray.appendChild(head('👀', 'Look around', 'path', ''));
        tray.appendChild(el('p', 'tc-line', 'Tap a glint in the chamber.'));
        return;
      }
      tray.dataset.kind = h.kind;
      tray.appendChild(head(h.ico, h.name, h.kind, { quiet: 'Quiet', loud: 'Loud', path: 'Way on', secret: 'Secret' }[h.kind]));
      tray.appendChild(el('p', 'tc-line', S.used[S.sel] ? 'Done here.' : h.line));
      h.acts.forEach(function (a, i) {
        var aa = Object.assign({}, a); if (S.used[S.sel] && !a.next) aa.disabled = true;
        if (a.next && S.stir > 0 && !S.passed) { aa.s = 'Sneak by the beetle first'; aa.disabled = true; }
        acts.appendChild(actBtn(aa, i === 0, function () { act(S.sel, a); }));
      });
      tray.appendChild(acts);
    }

    function spend() {
      if (S.oil <= 0) return;
      var cells = document.querySelectorAll('.oil-cells li'); var c = cells[S.oil - 1];
      if (c) { c.classList.add('burn'); setTimeout(function () { c.classList.remove('burn'); }, 700); }
      S.oil -= 1;
    }
    function stir(n) {
      if (!n) return;
      S.stir = Math.max(0, S.stir - n);
      log('💤', S.stir ? 'The beetle stirs (' + S.stir + ' z left).' : 'The beetle wakes!');
      if (S.stir === 0) startFight(false);
    }

    function act(id, a) {
      if (a.next) { spend(); paint(); $('dlg-next').showModal(); return; }
      if (a.fight) { spend(); log('⚔️', 'You bonk the beetle awake: 3 damage!'); S.foe -= 3; startFight(true); return; }
      if (!a.costFree) spend();
      if (a.oilUp) S.oil = Math.min(8, S.oil + a.oilUp);
      var roll = Math.random() * 100 < a.odds;
      if (id === 'moss' && a.secret) roll = true;   // demo: the wise path always pays once
      if (roll) {
        log(a.ico, a.ok);
        if (a.pop) pop(a.pop);
        if (a.secret && !S.secret) { S.secret = 1; S.sel = 'nook'; }
        if (id === 'nook') S.secret = 2;
        if (a.path) { S.passed = true; S.sel = 'exit'; }
        S.used[id] = true;
        if (id === 'nook') S.sel = 'exit';
        stir(a.loud);
      } else {
        log('🎲', a.fail || 'No luck this time.');
        pop('miss', true);
        stir(a.failLoud);
      }
      if (S.oil === 0 && S.mode === 'explore') { S.mode = 'dark'; log('🌑', 'The lantern gutters out.'); }
      paint();
    }

    function startFight(first) {
      S.mode = 'fight'; S.turn = 'you'; S.stir = 0;
      $('banner').textContent = first ? 'Your turn' : 'It wakes! Your turn';
      paint();
    }
    function hit(sel) { var e = document.querySelector(sel); e.classList.remove('hit'); void e.offsetWidth; e.classList.add('hit'); }
    function foeTurn() {
      S.turn = 'foe'; dv.dataset.turn = 'foe'; $('banner').textContent = 'Beetle’s turn'; renderTray();
      setTimeout(function () {
        if (S.blind) { S.blind = false; log('✨', 'Dazzled, the beetle snaps at nothing.'); }
        else { var who = Math.random() < .7 ? 'you' : 'lark'; var d = 2 + Math.floor(Math.random() * 2); S[who] -= d; hit(who === 'you' ? '.gnome' : '.pal2');
          log('🪲', 'It snaps at ' + (who === 'you' ? 'you' : 'Lark') + ': −' + d + ' HP.'); pop('−' + d, true); }
        S.turn = 'you'; dv.dataset.turn = 'you'; $('banner').textContent = 'Your turn'; paint();
      }, 1100);
    }
    function fight(v) {
      if (S.turn === 'foe') return;
      if (v === 'bonk') {
        if (Math.random() < .75) { var d = 3 + Math.floor(Math.random() * 4); S.foe -= d; hit('.beetle'); pop('−' + d); log('⚔️', 'Bonk! −' + d + ' to the beetle.'); }
        else { log('🎲', 'You swing and miss.'); pop('miss', true); }
      } else if (v === 'glim') { S.glimmer = true; S.blind = true; log('✨', 'Glim glimmers. The beetle blinks, dazzled.'); pop('✨ dazzled'); }
      else if (v === 'run') {
        if (Math.random() < .55) { log('🏃', 'You scurry back to the stairs. Safe.'); S.mode = 'explore'; S.stir = 1; S.sel = 'exit'; paint(); return; }
        log('🎲', 'You trip on a root!');
      }
      if (S.foe <= 0) { S.foe = 0; S.mode = 'won'; S.passed = true; delete dv.dataset.turn; log('🏅', 'The beetle scuttles off. +14 XP, Bellcap shell.'); paint(); return; }
      paint(); foeTurn();
    }

    document.querySelectorAll('.hs').forEach(function (b) {
      b.addEventListener('click', function () { if (S.mode !== 'explore') return; S.sel = b.dataset.hs; paint(); });
    });
    document.querySelectorAll('[data-open]').forEach(function (b) { b.addEventListener('click', function () { $(b.dataset.open).showModal(); }); });
    $('dlg-next').addEventListener('close', function () { location.href = location.pathname + (qs.get('theme') ? '?theme=' + qs.get('theme') : ''); });
    $('theme').addEventListener('click', function () { root.dataset.theme = root.dataset.theme === 'dark' ? 'light' : 'dark'; });

    // preset states for screenshots
    var st = qs.get('state');
    if (st === 'fight') { S.oil = 4; S.stir = 0; S.foe = 7; S.you = 11; S.lark = 6; S.mode = 'fight'; S.turn = 'you'; S.used.chest = true;
      log('💪', 'CRACK! 38 Petals and a Silk thread.'); log('💤', 'The beetle wakes!'); log('⚔️', 'Bonk! −5 to the beetle.'); $('banner').textContent = 'Your turn'; }
    if (st === 'dark') { S.oil = 0; S.mode = 'dark'; S.stir = 1; S.used.crack = true; S.used.chest = true; log('🌑', 'The lantern gutters out.'); }
    if (st === 'secret') { S.oil = 5; S.secret = 1; S.sel = 'nook'; S.used.moss = true; log('📖', 'The moss spells WIND. A draught behind the crack!'); }
    paint();
  });
})();
