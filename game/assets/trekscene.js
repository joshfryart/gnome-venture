/* v2.0.8: Treks talk pop-over. PHP leaves a hidden <div class="trekscene" data-scene='JSON'> on the Map tab; this turns it into a <dialog class="tkscene">:
   two portraits (speaker left at full strength, listener right and faded, they slide across when the speaker changes) and one text box.
   Text goes in with textContent; only `ico` (server-built art) is inserted as HTML. Without script nothing happens: the same lines are in the log. */
(function () {
  var cur = null, uid = 0;
  var reduce = function () { return !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches); };
  function el(tag, cls, text) { var n = document.createElement(tag); if (cls) n.className = cls; if (text != null) n.textContent = text; return n; }

  function Scene(data) {
    var self = this, who = data.who, keys = Object.keys(who);
    this.who = who;
    this.beats = data.beats;
    this.i = 0;
    this.last = this.beats.length - 1;
    this.left = null;
    this.right = null;
    this.timer = 0;
    this.stamp = 0;
    this.over = false;
    this.opener = document.activeElement;
    var id = 'tksname' + (++uid);

    var dlg = this.dlg = el('dialog', 'tkscene');
    dlg.setAttribute('aria-labelledby', id);
    var card = this.card = el('div', 'tkscard');
    card.tabIndex = 0;

    var stage = el('div', 'tksstage');
    this.chars = {};
    keys.forEach(function (k) {
      var c = el('div', 'tkschar off l');
      c.setAttribute('aria-hidden', 'true');
      var av = el('div', 'tksav');
      if (who[k].ico) av.innerHTML = who[k].ico;   /* trusted server-built art */
      c.appendChild(av);
      c.appendChild(el('span', 'tksnm', who[k].name || ''));
      stage.appendChild(c);
      self.chars[k] = c;
    });

    var box = el('div', 'tkstext');
    this.nameEl = el('b', 'tksspk', '');
    this.nameEl.id = id;
    this.line = el('p', 'tksline', '');
    this.line.setAttribute('aria-live', 'polite');
    this.line.setAttribute('aria-atomic', 'true');
    box.appendChild(this.nameEl);
    box.appendChild(this.line);
    this.joinEl = el('div', 'tksjoin');
    this.joinEl.hidden = true;
    box.appendChild(this.joinEl);

    var foot = el('div', 'tksfoot');
    this.dots = el('div', 'tksdots');
    this.dots.setAttribute('aria-hidden', 'true');
    this.beats.forEach(function () { self.dots.appendChild(el('i', 'tksdot')); });
    this.btn = el('button', 'btn alt tksbtn', 'Skip');
    this.btn.type = 'button';
    this.btn.addEventListener('click', function (ev) { ev.stopPropagation(); self.btnClick(); });
    foot.appendChild(this.dots);
    foot.appendChild(this.btn);

    if (!keys.length) stage.hidden = true;   /* narration only: no portraits */
    card.appendChild(stage); card.appendChild(box); card.appendChild(foot);
    dlg.appendChild(card);

    card.addEventListener('click', function () { self.next(); });
    this.onKey = function (ev) {
      if (ev.key === 'ArrowRight') { ev.preventDefault(); self.next(); }
      else if ((ev.key === 'Enter' || ev.key === ' ') && ev.target === card) { ev.preventDefault(); self.next(); }
    };
    dlg.addEventListener('keydown', this.onKey);
    dlg.addEventListener('click', function (ev) { if (ev.target === dlg) self.next(); });   /* the dimmed backdrop counts as a tap too */
    dlg.addEventListener('close', function () { self.end(); });
    document.body.appendChild(dlg);

    this.show(0, false);
    gvOpenDlg(dlg);
    try { card.focus({ preventScroll: true }); } catch (e) { /* old browser */ }
  }

  /* who stands where: the speaker goes left, the previous different speaker goes right; narration leaves them where they are, both faded */
  Scene.prototype.place = function (w) {
    var keys = Object.keys(this.who);
    if (w !== 'nar' && !this.who[w]) w = 'nar';
    if (this.left === null) {
      var first = w === 'nar' ? keys[0] : w;
      this.left = first;
      this.right = null;
      for (var j = 0; j < keys.length; j++) if (keys[j] !== first) { this.right = keys[j]; break; }
    }
    if (w === 'nar') return;
    if (w === this.left) return;
    if (w === this.right) { this.right = this.left; this.left = w; return; }
    this.right = this.left;   /* a new voice: the old speaker steps across */
    this.left = w;
  };

  Scene.prototype.paint = function (w) {
    var keys = Object.keys(this.who), nar = w === 'nar' || !this.who[w];
    for (var j = 0; j < keys.length; j++) {
      var k = keys[j], c = this.chars[k];
      var onL = k === this.left, onR = k === this.right;
      c.classList.toggle('off', !onL && !onR);
      c.classList.toggle('l', !onR);
      c.classList.toggle('r', onR);
      c.classList.toggle('spk', !nar && k === w);
    }
  };

  Scene.prototype.show = function (i, animate) {
    var self = this, b = this.beats[i], w = b.w;
    this.i = i;
    this.place(w);
    this.paint(w);
    var nar = w === 'nar' || !this.who[w];
    this.card.classList.toggle('nar', nar);
    var label = nar ? 'Story' : this.who[w].name;
    var dots = this.dots.children;
    for (var j = 0; j < dots.length; j++) { dots[j].classList.toggle('on', j === i); dots[j].classList.toggle('past', j < i); }
    this.btn.textContent = i >= this.last ? 'Done' : 'Skip';
    clearTimeout(this.timer);
    this.line.classList.remove('out');
    var set = function () {
      self.timer = 0;
      self.card.classList.toggle('join', !!b.j);
      self.joinEl.hidden = !b.j;
      self.line.hidden = !!b.j;
      if (b.j) { self.nameEl.textContent = b.j.placed ? '🎉 Party member joined!' : '🎒 Joined the Trailmates (bench)'; self.fillJoin(b.j); }
      else { self.nameEl.textContent = label; self.line.textContent = b.t; }
      self.line.classList.remove('out');
    };
    if (animate && !reduce()) {
      this.line.classList.add('out');
      this.timer = setTimeout(set, 120);
    } else set();
  };

  /* the "party member joined!" card: name, line under it, three numbers, role, a bit about them (all textContent) */
  Scene.prototype.fillJoin = function (j) {
    var d = this.joinEl;
    while (d.firstChild) d.removeChild(d.firstChild);
    d.appendChild(el('b', 'tksjn', j.full || j.name || ''));
    d.appendChild(el('span', 'tksjs', j.sub || ''));
    var row = el('div', 'tksjst');
    Object.keys(j.stats || {}).forEach(function (k) {
      var c = el('span', 'tksjc'); c.appendChild(el('i', null, k)); c.appendChild(el('b', null, String(j.stats[k]))); row.appendChild(c);
    });
    d.appendChild(row);
    if (j.role) d.appendChild(el('span', 'tksjr', j.role));
    if (j.bio) d.appendChild(el('p', 'tksjb', j.bio));
    if (!j.placed) d.appendChild(el('span', 'tksjr', 'Your party is full. Swap them in at a camp (Party tab).'));
  };

  Scene.prototype.next = function () {
    var now = Date.now();
    if (now - this.stamp < 150) return;   /* a double-tap is one tap */
    this.stamp = now;
    if (this.i >= this.last) { this.close(); return; }
    this.show(this.i + 1, true);
  };

  Scene.prototype.btnClick = function () {
    if (this.i >= this.last) { this.close(); return; }
    this.stamp = Date.now();
    this.show(this.last, true);
  };

  Scene.prototype.close = function () { gvCloseDlg(this.dlg); this.end(); };

  Scene.prototype.end = function () {
    if (this.over) return;
    this.over = true;
    clearTimeout(this.timer);
    if (this.dlg.parentNode) this.dlg.parentNode.removeChild(this.dlg);
    if (cur === this) cur = null;
    var o = this.opener;
    if (o && o.focus && document.contains(o)) { try { o.focus({ preventScroll: true }); } catch (e) { /* gone */ } }
  };

  var waiting = false;
  function muted() { try { return localStorage.getItem('gvSceneOff') === '1'; } catch (e) { return false; } }
  function muteBtn() {
    var b = document.querySelector('[data-tksmute]');
    if (!b) return;
    b.hidden = false;
    b.textContent = '🗨 Story pop-ups';
    var paint = function () { var m = muted(); b.setAttribute('aria-pressed', m ? 'false' : 'true'); };
    paint();
    b.addEventListener('click', function () { try { localStorage.setItem('gvSceneOff', muted() ? '0' : '1'); } catch (e) { /* storage blocked: stays on */ } paint(); });
  }
  function scan() {
    var s = document.querySelector('.trekscene:not([data-seen])');
    if (!s) return;
    /* an Auto replay is open: wait for it to close so the scene does not spoil the result */
    if (document.querySelector('dialog.tkr[open]')) {
      if (!waiting) {
        waiting = true;
        var t = setInterval(function () {
          if (!document.querySelector('dialog.tkr[open]')) { clearInterval(t); waiting = false; scan(); }
        }, 300);
      }
      return;
    }
    s.setAttribute('data-seen', '1');
    if (muted()) { if (s.parentNode) s.parentNode.removeChild(s); return; }
    var data = null;
    try { data = JSON.parse(s.getAttribute('data-scene') || ''); } catch (e) { data = null; }
    if (s.parentNode) s.parentNode.removeChild(s);
    if (!data || !data.beats || !data.beats.length || typeof gvOpenDlg !== 'function') return;
    if (cur) cur.end();
    cur = new Scene(data);
  }
  muteBtn();
  scan();
  if (window.MutationObserver) new MutationObserver(function () { if (document.querySelector('.trekscene:not([data-seen])')) scan(); }).observe(document.querySelector('main') || document.body, { childList: true, subtree: true });
})();
