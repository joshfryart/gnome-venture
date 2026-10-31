// Delve mockup 3: demo only. Theme, mood and visit switches, room peek dialog, walking to the next room.
(function () {
  'use strict';
  const root = document.documentElement;
  const body = document.body;
  const q = new URLSearchParams(location.search);   // ?theme=dark&mode=pal&mood=mine for screenshots
  root.dataset.theme = q.get('theme') || (matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
  body.dataset.mode = q.get('mode') || 'first';
  if (q.get('mood')) body.dataset.mood = q.get('mood');

  document.getElementById('themeBtn').addEventListener('click', () => {
    root.dataset.theme = root.dataset.theme === 'dark' ? 'light' : 'dark';
  });

  function press(attr, val) {
    document.querySelectorAll('[' + attr + ']').forEach(b => b.setAttribute('aria-pressed', String(b.getAttribute(attr) === val)));
  }
  press('data-set-mood', body.dataset.mood);
  press('data-set-mode', body.dataset.mode);
  document.querySelector('.demo').addEventListener('click', e => {
    const b = e.target.closest('button');
    if (!b) return;
    if (b.dataset.setMood) { body.dataset.mood = b.dataset.setMood; press('data-set-mood', b.dataset.setMood); }
    if (b.dataset.setMode) { body.dataset.mode = b.dataset.setMode; press('data-set-mode', b.dataset.setMode); }
  });

  // peek at a room
  const dlg = document.getElementById('peek');
  const riskWords = ['Safe', 'Mild', 'Tricky', 'Fierce'];
  let picked = null;
  document.getElementById('route').addEventListener('click', e => {
    const n = e.target.closest('.node');
    if (!n) return;
    const fog = n.dataset.state === 'fog' && body.dataset.mode !== 'replay';
    picked = n;
    document.getElementById('peekIco').replaceChildren(fog ? document.createTextNode('?') : n.querySelector('img').cloneNode());
    document.getElementById('peekName').textContent = fog ? 'Too dark to see' : n.dataset.name;
    document.getElementById('peekLine').textContent = fog ? 'Light a glowcap, or get closer.' : n.dataset.line;
    const r = fog ? 0 : Number(n.dataset.risk || 0);
    document.getElementById('peekRisk').dataset.r = String(r);
    document.getElementById('peekRiskTxt').textContent = fog ? '?' : riskWords[r];
    document.getElementById('peekReward').textContent = fog ? '?' : (n.dataset.reward || 'Nothing left');
    const go = document.getElementById('peekGo');
    go.disabled = n.dataset.state !== 'next';
    go.textContent = n.dataset.state === 'next' ? 'Go this way' : (n.dataset.state === 'here' ? 'You are here' : 'Not reachable yet');
    dlg.showModal();
  });

  // walk there: the room card swaps to that room
  dlg.addEventListener('close', () => {
    if (dlg.returnValue !== 'go' || !picked || picked.dataset.state !== 'next') return;
    const here = document.querySelector('.node[data-state="here"]');
    const pin = here.querySelector('.youpin');
    here.dataset.state = 'done';
    document.querySelectorAll('.node[data-state="next"]').forEach(n => { if (n !== picked) n.dataset.state = 'far'; });
    picked.dataset.state = 'here';
    picked.appendChild(pin);
    document.querySelectorAll('.e.open').forEach(p => p.setAttribute('class', 'e far'));
    const t = document.getElementById('room-' + picked.dataset.room);
    if (t) document.getElementById('room').replaceChildren(t.content.cloneNode(true));
  });
})();
