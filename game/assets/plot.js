/* Gnome Venture v2.0.31: Garden Plot Logic. Vanilla JS, no libraries.
   Without this file the bed works with a plain select in every open square. With it, the selects hide and you pick a plant
   in the palette, then tap squares. The server still decides everything: every button sends the whole grid, so Save, Ask Old Moss
   and Check all keep your progress. The solution is never in the page. Arrow keys move between the open squares.
   The hints here (wilt, "not yet") read only what is on screen. */
(function () {
  'use strict';
  var N = 5;

  function init(form) {
    form.classList.add('on');
    var pal = form.querySelector('.plotpal');
    var palBtns = pal ? Array.prototype.slice.call(pal.querySelectorAll('.plotp')) : [];
    var cells = Array.prototype.slice.call(form.querySelectorAll('.plotcell'));
    var check = form.querySelector('[data-check]');
    var rules = Array.prototype.slice.call(form.querySelectorAll('.plotrule'));
    var sel = palBtns.length ? palBtns[0].getAttribute('data-v') : '';
    if (pal) pal.hidden = false;

    function plantImg(v) {
      for (var i = 0; i < palBtns.length; i++) {
        if (palBtns[i].getAttribute('data-v') === String(v)) { var im = palBtns[i].querySelector('img'); return im ? im.cloneNode(true) : null; }
      }
      return null;
    }
    function plantName(v) {
      for (var i = 0; i < palBtns.length; i++) if (palBtns[i].getAttribute('data-v') === String(v)) return palBtns[i].getAttribute('data-name');
      return 'Empty';
    }
    function plantTag(v) {
      for (var i = 0; i < palBtns.length; i++) if (palBtns[i].getAttribute('data-v') === String(v)) return palBtns[i].getAttribute('data-tag') || '';
      return '';
    }
    function valueOf(cell) {
      if (cell.classList.contains('lock')) return cell.getAttribute('data-p');
      var s = cell.querySelector('select');
      return s ? s.value : '';
    }
    function paint(cell) {
      var s = cell.querySelector('select'), btn = cell.querySelector('.plotbtn'), pic = cell.querySelector('.plotpic');
      if (!s || !btn) return;
      while (btn.firstChild) btn.removeChild(btn.firstChild);
      if (s.value !== '') {
        var im = plantImg(s.value), tag = document.createElement('span');
        if (im) btn.appendChild(im);
        tag.className = 'plottag';
        tag.setAttribute('aria-hidden', 'true');
        tag.textContent = plantTag(s.value);
        btn.appendChild(tag);
      }
      btn.setAttribute('aria-label', cell.getAttribute('data-rc') + ', ' + (s.value === '' ? 'empty' : plantName(s.value)));
      if (pic) pic.textContent = '';
    }
    function refresh() {
      var grid = [], full = true, i, j;
      cells.forEach(function (c) { var v = valueOf(c); grid.push(v); if (v === '') full = false; });
      var bad = {};
      for (i = 0; i < N; i++) {
        for (j = 0; j < N; j++) for (var k = j + 1; k < N; k++) {
          var a = i * N + j, b = i * N + k;   // row i
          if (grid[a] !== '' && grid[a] === grid[b]) { bad[a] = 1; bad[b] = 1; }
          a = j * N + i; b = k * N + i;       // column i
          if (grid[a] !== '' && grid[a] === grid[b]) { bad[a] = 1; bad[b] = 1; }
        }
      }
      cells.forEach(function (c, n) {
        var w = !!bad[n];
        c.classList.toggle('wilt', w);
        var t = c.querySelector('.plotbtn') || (c.classList.contains('lock') ? c : null);
        if (t) { if (w) t.setAttribute('aria-invalid', 'true'); else t.removeAttribute('aria-invalid'); }
      });
      // "not yet": a crop whose four sides are all planted and none of them is its helper
      rules.forEach(function (li) {
        var h = li.getAttribute('data-h'), cr = li.getAttribute('data-c'), miss = false;
        for (var n = 0; n < grid.length && !miss; n++) {
          if (grid[n] !== cr) continue;
          var x = n % N, y = (n - x) / N, nb = [], ok = false, open = false;
          if (y > 0) nb.push(n - N);
          if (y < N - 1) nb.push(n + N);
          if (x > 0) nb.push(n - 1);
          if (x < N - 1) nb.push(n + 1);
          nb.forEach(function (m) { if (grid[m] === h) ok = true; else if (grid[m] === '') open = true; });
          if (!ok && !open) miss = true;
        }
        li.classList.toggle('yet', miss);
        var tag = li.querySelector('.plotyet');
        if (tag) tag.hidden = !miss;
      });
      if (check) check.disabled = !full;
    }
    function setCell(cell, v) {
      var s = cell.querySelector('select');
      if (!s) return;
      s.value = v === '-1' ? '' : v;
      paint(cell);
      refresh();
    }

    palBtns.forEach(function (b) {
      b.setAttribute('aria-pressed', b.getAttribute('data-v') === sel ? 'true' : 'false');
      b.addEventListener('click', function () {
        sel = b.getAttribute('data-v');
        palBtns.forEach(function (o) { o.setAttribute('aria-pressed', o === b ? 'true' : 'false'); });
      });
    });
    cells.forEach(function (cell) {
      if (cell.classList.contains('lock')) return;
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'plotbtn';
      cell.appendChild(btn);
      paint(cell);
      btn.addEventListener('click', function () {
        var s = cell.querySelector('select');
        if (sel === '-1' || s.value === sel) setCell(cell, '-1');
        else setCell(cell, sel);
      });
    });
    // arrow keys: move to the nearest open square in that direction
    var bed = form.querySelector('.plotbed');
    if (bed) bed.addEventListener('keydown', function (ev) {
      var d = { ArrowLeft: [-1, 0], ArrowRight: [1, 0], ArrowUp: [0, -1], ArrowDown: [0, 1] }[ev.key];
      if (!d || !ev.target.classList.contains('plotbtn')) return;
      var at = cells.indexOf(ev.target.parentNode);
      if (at < 0) return;
      var x = at % N, y = (at - x) / N;
      for (x += d[0], y += d[1]; x >= 0 && x < N && y >= 0 && y < N; x += d[0], y += d[1]) {
        var b = cells[y * N + x].querySelector('.plotbtn');
        if (b) { b.focus(); break; }
      }
      ev.preventDefault();
    });
    refresh();
  }

  function scan() {
    document.querySelectorAll('.plotform:not(.on)').forEach(init);
  }
  scan();
  if (window.MutationObserver) new MutationObserver(scan).observe(document.body, { childList: true, subtree: true });
})();
