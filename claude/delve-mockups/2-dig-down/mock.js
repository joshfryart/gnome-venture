// Delve mockup 2 "Dig down": demo state only, nothing is saved. ?theme=dark|light, ?depth=1..5 for screenshots.
(function () {
  'use strict';
  var IMG = '../../../game/assets/img/';
  var $ = function (s) { return document.querySelector(s); };
  var q = new URLSearchParams(location.search);

  // theme: the game follows the device; the button is only for the demo
  var root = document.documentElement;
  root.dataset.theme = q.get('theme') || (matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
  $('#themebtn').addEventListener('click', function () { root.dataset.theme = root.dataset.theme === 'dark' ? 'light' : 'dark'; });

  var FIND = { 1: ['ph/acorn-cap.png', 'Acorn cap'], 2: ['ph/quartz-shell.png', 'Quartz shell'], 3: ['ph/geode.png', 'Geode'], 4: ['ph/pale-scale.png', 'Pale scale'], 5: ['ph/borer-plate.png', 'Borer plate'] };
  var FOE = { 1: ['ph/creature-root-weevil.png', 'Root weevil'], 2: ['ph/creature-clay-crawler.png', 'Clay crawler'], 3: ['ph/creature-crystal-weaver.png', 'Crystal weaver'],
    4: ['ph/creature-basalt-borer.png', 'Basalt borer'], 5: ['ph/creature-ember-beetle.png', 'Ember beetle'] };
  var PETAL = 'items/petal.png';
  var MULT = { 1: 1, 2: 1.5, 3: 2, 4: 2.5, 5: 4 };

  var S = {
    depth: 2, light: 5, max: 8, hp: 31, p1: 14, p2: 5, anchor: 1,
    safe: [{ k: 'ph/acorn-cap.png', n: 2 }, { k: PETAL, n: 18 }],
    risk: [{ k: 'ph/quartz-shell.png', n: 1 }, { k: PETAL, n: 12 }],
    used: { 2: { west: true } },
    log: ['🌰 West tunnel: a Quartz shell and 12 Petals.', '⛏️ You dig into the red clay. It sticks to your boots.', '📌 You hammer an anchor into the roots.'],
    boss: false
  };
  var d0 = parseInt(q.get('depth') || '', 10);
  if (d0 >= 1 && d0 <= 5) S.depth = d0;

  var layers = Array.prototype.slice.call(document.querySelectorAll('.st'));
  layers.forEach(function (li) {
    if (li.dataset.layer === '0') return;
    var s = document.createElement('span'); s.className = 'q'; s.textContent = '?'; s.setAttribute('aria-hidden', 'true');
    li.querySelector('.band').appendChild(s);
  });

  function add(list, k, n) {
    for (var i = 0; i < list.length; i++) if (list[i].k === k) { list[i].n += n; list[i].fresh = true; return; }
    list.push({ k: k, n: n, fresh: true });
  }
  function lootHtml(ul, list, empty) {
    ul.textContent = '';
    if (!list.length) { var e = document.createElement('li'); e.className = 'empty'; e.textContent = empty; ul.appendChild(e); return; }
    list.forEach(function (it) {
      var li = document.createElement('li'); if (it.fresh) li.className = 'new';
      var im = document.createElement('img'); im.src = IMG + it.k; im.alt = ''; im.width = 28; im.height = 28;
      li.appendChild(im);
      if (it.n > 1) { var b = document.createElement('b'); b.textContent = it.n; li.appendChild(b); }
      ul.appendChild(li);
    });
  }
  function say(t) { S.log.unshift(t); S.log = S.log.slice(0, 4); }
  function used(a) { return !!(S.used[S.depth] && S.used[S.depth][a]); }
  function use(a) { (S.used[S.depth] = S.used[S.depth] || {})[a] = true; }
  function reach() { return (S.light > 0 ? 1 : 0) + (S.p2 > 0 ? 1 : 0); }
  function stacks(l) { return l.length; }

  function render() {
    var here = $('#here');
    layers.forEach(function (li) {
      var n = +li.dataset.layer;
      li.classList.remove('done', 'here', 'below', 'dark', 'anchored');
      if (n === 0) return;
      if (n < S.depth) li.classList.add('done');
      else if (n === S.depth) { li.classList.add('here'); li.querySelector('.band').appendChild(here); }
      else { li.classList.add('below'); if (n - S.depth > reach()) li.classList.add('dark'); }
      if (n === S.anchor && n <= S.depth) li.classList.add('anchored');
    });

    // readout
    $('#ro-depth').textContent = S.depth;
    var pips = $('#pips').children;
    for (var i = 0; i < pips.length; i++) pips[i].className = i < S.light ? 'on' : '';
    $('#pips').setAttribute('aria-label', 'Light ' + S.light + ' of ' + S.max);
    $('#ro-hp').value = S.hp; $('#ro-hpn').textContent = S.hp;
    document.body.classList.toggle('lightlow', S.light <= 2);

    // party
    [['you', S.hp, 40], ['p1', S.p1, 18], ['p2', S.p2, 16]].forEach(function (m) {
      var p = $('#hp-' + m[0]); p.value = Math.max(0, m[1]); p.classList.toggle('low', m[1] / m[2] < 0.35);
      $('#hpn-' + m[0]).textContent = Math.max(0, m[1]) + '/' + m[2];
    });
    $('.pal.p1').classList.toggle('out', S.p1 <= 0);
    $('.pal.p2').classList.toggle('out', S.p2 <= 0);

    // the strip
    var foe = FOE[S.depth];
    $('#east-img').src = IMG + foe[0];
    var w = $('.tun.west'), e = $('.tun.east');
    w.disabled = used('west'); $('#west-s').textContent = used('west') ? 'Searched' : 'Poke about';
    e.disabled = used('east');
    $('#east-s').textContent = used('east') ? 'Quiet now' : (S.depth === 5 ? 'The guardian' : 'Something stirs');
    var dig = $('#digbtn'), rope = $('#ropebtn');
    if (S.depth === 5) {
      dig.hidden = false; rope.hidden = true;
      dig.className = 'btn dig boss'; dig.dataset.act = S.boss ? 'chest' : 'boss';
      dig.innerHTML = S.boss ? '💰 Open the chest' : '⚔️ Face the guardian';
      dig.disabled = S.boss === 'open';
      if (S.boss === 'open') dig.innerHTML = '💰 Chest emptied';
    } else {
      rope.hidden = false; dig.className = 'btn dig'; dig.dataset.act = 'dig';
      dig.innerHTML = '⛏️ Dig down <span class="cost lt">1</span>';
      dig.disabled = S.light < 1; rope.disabled = S.light < 2;
      if (S.light < 1) dig.innerHTML = '🕯️ Out of light';
    }

    // decision card
    S.safe.forEach(function (x) { x.fresh = x.fresh && false; });
    lootHtml($('#loot-safe'), S.safe, 'Nothing yet');
    lootHtml($('#loot-risk'), S.risk, 'All safe');
    S.safe.concat(S.risk).forEach(function (x) { x.fresh = false; });
    var nx = layers[S.depth + 1];
    $('#next').innerHTML = nx ? '<span>Next:</span> <b>' + nx.dataset.name + '</b> · danger ' + nx.dataset.danger + ' · loot ' + nx.dataset.mult : '<span>The bottom.</span> <b>Nothing deeper.</b>';
    $('#climb-n').textContent = 'keep ' + (stacks(S.safe) + stacks(S.risk));
    $('#anchorbtn').disabled = S.light < 1 || !S.risk.length;

    // journal
    var log = $('#log'); log.textContent = '';
    S.log.forEach(function (t) { var li = document.createElement('li'); li.textContent = t; log.appendChild(li); });
  }

  function spend(n) {
    var pips = $('#pips').children;
    for (var i = S.light - n; i < S.light; i++) if (pips[i]) pips[i].className = 'spend';
    S.light -= n;
  }
  function event(title, img, text, bad) {
    var d = $('#dlg-event');
    d.classList.toggle('bad', !!bad);
    $('#dlg-event-h').textContent = title;
    $('#ev-text').textContent = text;
    var a = $('#ev-art'); a.textContent = '';
    var im = document.createElement('img'); im.src = IMG + img; im.alt = ''; im.width = 64; im.height = 64; a.appendChild(im);
    d.showModal();
  }
  function rnd(a, b) { return a + Math.floor(Math.random() * (b - a + 1)); }
  function hurt(min, max) {
    S.hp -= rnd(min, max);
    if (S.p1 > 0) S.p1 -= rnd(1, 4);
    if (S.p2 > 0) S.p2 -= rnd(1, 3);
    if (S.hp <= 0) { knocked(); return true; }
    return false;
  }
  function knocked() {
    var lost = stacks(S.risk);
    S.risk = []; S.hp = 0;
    say('💫 Knocked out! You wake at the top. ' + lost + ' things stay down there.');
    render();
    event('Knocked out!', 'fx/fx-ko.png', 'You keep what was safe above the anchor. The rest stays in the dark.', true);
  }
  function crewDig() { var c = $('.crew'); c.classList.remove('dig'); void c.offsetWidth; c.classList.add('dig'); }

  var ACT = {
    west: function () {
      var f = FIND[S.depth], n = Math.round(rnd(1, 2) * MULT[S.depth]), p = Math.round(rnd(6, 12) * MULT[S.depth]);
      use('west'); add(S.risk, f[0], n); add(S.risk, PETAL, p);
      say('🔦 West tunnel: ' + n + ' ' + f[1] + (n > 1 ? 's' : '') + ' and ' + p + ' Petals.');
      render(); event('West tunnel', f[0], n + ' ' + f[1] + (n > 1 ? 's' : '') + ' and ' + p + ' Petals. Into the sack (at risk).');
    },
    east: function () {
      var foe = FOE[S.depth]; use('east');
      if (hurt(3, 6 + S.depth * 2)) return;
      var f = FIND[S.depth], n = Math.round(2 * MULT[S.depth]);
      add(S.risk, f[0], n);
      say('⚔️ You and your pals see off a ' + foe[1] + '. +' + n + ' ' + f[1] + 's.');
      render(); event(foe[1] + '!', foe[0], 'Seen off, with your pals’ help. It dropped ' + n + ' ' + f[1] + 's.');
    },
    dig: function () {
      if (S.light < 1) return;
      spend(1); S.depth++; crewDig();
      var trap = Math.random() < 0.35;
      say('⛏️ You dig down into the ' + layers[S.depth].dataset.name.toLowerCase() + '.' + (trap ? ' Loose rocks!' : ''));
      if (trap && hurt(2, 4)) return;
      setTimeout(render, 220);
      setTimeout(function () { var li = layers[S.depth]; li.scrollIntoView({ block: 'center', behavior: 'smooth' }); }, 260);
    },
    rope: function () {
      if (S.light < 2) return;
      spend(2); S.depth++;
      say('🪢 You rope down, quiet as a mouse, into the ' + layers[S.depth].dataset.name.toLowerCase() + '.');
      setTimeout(render, 220);
    },
    anchor: function () {
      if (S.light < 1 || !S.risk.length) return;
      spend(1); S.risk.forEach(function (x) { add(S.safe, x.k, x.n); }); S.risk = []; S.anchor = S.depth;
      say('📌 You hammer an anchor in. Everything so far is safe.');
      setTimeout(render, 220);
    },
    boss: function () {
      if (hurt(6, 14)) return;
      S.boss = true; say('🛡️ The Ember beetle backs off into the glow.');
      render(); event('Ember beetle!', FOE[5][0], 'The guardian backs away. The chest is yours to open.');
    },
    chest: function () {
      S.boss = 'open'; add(S.risk, 'ph/borer-plate.png', 2); add(S.risk, 'ph/geode.png', 3); add(S.risk, PETAL, 160);
      say('💰 The chest creaks open: 160 Petals, 3 Geodes, 2 Borer plates!');
      render(); event('The chest!', 'chest.png', '160 Petals, 3 Geodes and 2 Borer plates. Now get it all up top.');
    },
    climb: function () {
      var all = []; S.safe.concat(S.risk).forEach(function (x) { add(all, x.k, x.n); });
      lootHtml($('#dlg-loot'), all, 'Empty pockets');
      var nx = layers[S.depth + 1];
      $('#dlg-deeper').textContent = nx ? 'Next down: ' + nx.dataset.name + ', loot ' + nx.dataset.mult + '.' : 'You reached the bottom.';
      $('#dlg-climb').showModal();
    },
    'climb-go': function () { location.search = q.get('theme') ? '?theme=' + q.get('theme') : ''; }
  };

  document.addEventListener('click', function (ev) {
    var b = ev.target.closest('[data-act]');
    if (b && !b.disabled && ACT[b.dataset.act]) { ACT[b.dataset.act](); return; }
    var c = ev.target.closest('[data-close]');
    if (c) c.closest('dialog').close();
  });

  render();
})();
