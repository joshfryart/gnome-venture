# Pal Jobs: integrating the final design

Example: `claude/paljobs-final.html` is a snapshot of the proposed `paljobs.php` rendered by the real site (a test install, real `layout.php` shell, community area). It inlines `style.css` and `puzzles.css` with the new block, plus `early.js`, `site.js` and `paljobs.js`. The theme switch is the real `early.js` one. Only `#pjdemo` and the "DEMO ONLY" script are not part of the site. Copy-ready sources sit inside it between markers: `pj BEGIN`/`pj END` (CSS) and `pj JS BEGIN`/`pj JS END`.
Verified with Playwright at 375 and 1000 px in both themes: no horizontal overflow, the phone bottom bar is cleared, no console errors.

## 1. paljobs.php (full file in the appendix)
- **POST handler: unchanged.** It still has the same `match` and the same actions and field names: `do` = send_garden | send_trip | send_delve | recall | heal | collect, plus `pal`, `plot`, `days`, `land`, `tool`, `hours`, `potions`, `delve` and `job`. There is one addition for `collect`: before the call it reads the job's `pal_uid`, and on success it stores `$_SESSION['pj_receipt']`. The next GET shows that receipt once at the top of the ledger (the flashes still go to the message log).
- **Reads added. These are all read-only and pal_jobs.php does not change.** Lookup maps of plot names and delve names. A `SELECT target … kind='delve' AND day=landmark_day()` that greys out delves already re-run today. `$now`, written as `data-pj-now` so the JS can correct for clock skew.
- **Markup:**
```
div#pz.pjpage[data-pj-now]
  h1 🧩 Pal Jobs · ul.chips.pjcounts > li.chip ×3 (runs left, potions, Pal Book link)
  [no pals] section.box.pjempty (h2, p, a.btn → world.php)
  div.pjgrid
    section.box.pjpanel.pjledger  header.pjpanelhd(h2#pjouth, .pjslots dots)  [div.flash.pjreceipt > b + ul > li.pjlN]
      ul.pjrows > li.pjrow.pj-{kind}[.is-ready][data-pj-start][data-pj-end]
          img.ppalimg.pjimg · .pjwho(b, small) · .pjact(.pjeta[data-pj-eta], small[data-pj-hide-at-zero],
          form(job) button[name=do value=collect|recall]  (hidden data-pj-show-at-zero for the due-later Collect)) · progress.pjbar
        li.pjrow.pjfree (free slots → #pjboard)        p.pjfoot (next back)
    section.box.pjpanel.pjathome  ul.pjrows > li.pjrow.pjpal.ppr-{rarity}
          img · .pjwho(.pjnmrow b + span.ppalrar · .pjstats .pjsk×2 + .pjhp meter|.pjrest) · form.pjheal(do=heal, pal) button.btn.small.ghost
  section#pjboard.pjboard  .pjboardhd  div.pjposts > article.box.pjpost.pjpost-{kind} ×3
      .pjposthd(.pjico, h3, p.pjlen) p.pjdesc p.pjpays  then p.pjblocked  OR
      form.pjform[data-pj-kind] (csrf, hidden do=send_{kind})
        fieldset.pjpick > legend + ul.pjfaces > li > label.pjface > input[type=radio name=pal value=16hex required (disabled if 0 HP)] img .pjnm meter.pjfhp .pjlv
        div.pjopts  garden: select[name=plot] + fieldset.pjseg radios[name=days]
                    trip:   select[name=land] select[name=tool] fieldset.pjseg radios[name=hours] + .pjstep input[type=number name=potions data-pj-step]
                    delve:  select[name=delve] (ran-today options disabled) + potions
                    p.pjhint p.pjback[data-pj-back] button.btn.pjsend[data-pj-send]
```
- **Without JS:** pick a radio, then the options appear (CSS `:has`; browsers without `:has` show them all the time). Fill them in and Send. `required` blocks a send with no pal.
- **Reused from the site:** `.box`, `.btn` (+`.small`/`.ghost`), `.chips/.chip`, `.flash`, `.ppalimg`, `.ppalrar` + `.ppr-*`, `.vh`, `.muted`, the `--frame`/`--frame-lite`/`--st-h` tokens, `--area`, the emoji→icon swap (🪴 🧺 🕳️ 🧭 🧪 ⚠️ 📖 🗺️) and the global `progress` style.

## 2. puzzles.css
Replace **lines 318–332** (the `/* v2.3.0: pal jobs */` comment through `.pjheal{margin-top:6px}`) with the `pj BEGIN…END` block (~165 lines). Everything is scoped to `.pj*` and uses only tokens, so the dark theme needs no rules of its own. `.pjpage` is a size container: the panels go to 2 columns at ≥680 px of page column and the board to 3 posts at ≥900 px, with the side menu and the rail already taken into account. Inside a post, the pal list and options go to 2 columns at ≥520 px. There is no `position:fixed`, so `body.game`'s bottom-bar padding is enough. The one authored motion is the receipt unrolling, and the existing reduced-motion rule turns it off.

## 3. New assets/paljobs.js (~140 lines, no inline style, only classes, attributes and text)
1. Ledger tick (1 s): bar value, "1 h 14 min" (same wording as `pj_ago`), and at zero `.is-ready` + Ready + reveal the row's Collect (`pj_collect` settles it on the server).
2. Posts: one draft at a time (picking a pal clears the other posts). "Send ‹name›", a Cancel link, and Esc to cancel.
3. Show the top 5 pals, then "Show all N pals" (only when there are more than 6).
4. A −/+ stepper around the potion input, clamped to its min and max.
5. The "Back at 15:40 / Back on 3 Nov, 14:05" line, plus the Send button disables after submit.

## 4. layout.php
- Required: load the script after the puzzles.css line (line 64):
  `<?php if (!$admin && $page === 'paljobs.php'): ?><script src="<?= e(url('assets/paljobs.js?v=' . APP_VERSION)) ?>" defer></script><?php endif; ?>`
- Recommended: in `page_area()`, add `puzzlepals paljobs` to `community`, beside `puzzles gifsaw jigsaw`. Both currently fall through to `garden`. The example is rendered as community.

## 5. Untouched
`includes/pal_jobs.php` (all logic, constants, settle/claim/collect), the POST field names, `puzzlepals.php`, `style.css`, the theme code, the CSP. Every pal id in the forms is still the 16-hex hash, and there are no `style=` attributes.

## 6. tests/paljobs.sh
I ran it against a temp copy with these changes. Result: the logic tests pass, and one page check fails because it greps for `class="box pjpal` (pals are now rows, not boxes). Change line 42 to `grep -c 'class="pjrow pjpal'` and the whole script passes. The send_trip, no-`style=`, 16-hex `name="pal"` (radio order is `type, name, value`), send_garden and csrf checks pass as they are.

## 7. Risks
- A `:has()` fallback shows all the options at once: more to read, but still correct.
- The JS times are in device local time; the PHP times use `hollow_tz` via `puzzle_local`. They can differ when the two zones differ.
- When a gnome has many pals, the board repeats the list three times (each truncated to 5 with JS). Without JS the lists are long.
- A pal whose job is ready is already `home` (pj_settle), so it shows in At home too, with the note "Just back: collect above".
- Field `id`s (`pjplot`, `pjland`, `pjtool`, `pjdelve`, `pjpot-*`) assume one copy of the page per document.

## Appendix: proposed game/paljobs.php
```php
<?php
declare(strict_types=1);
/**
 * v2.3.0: Pal Jobs. Send a found Puzzle Pal to tend a garden, on a gathering trip, or to re-run a delve you have already cleared. Logic: includes/pal_jobs.php.
 * Behind ppal_open() and pj_open() (gnome level 10 by default). Posts: send_garden, send_trip, send_delve, collect, recall, heal. No inline script or style (CSP).
 * v2.3.1: one screen in three parts: the ledger (pals out, with progress) beside the pals at home, then the job board (pick a job, pick a pal, set it, send).
 * Each job is one plain form (a radio list of pals + its options), so it all works without JS; assets/paljobs.js adds the countdown, one open job at a time,
 * a potion stepper and the "back at" line. Styles: assets/puzzles.css (.pj*).
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/puzzles.php';
require_once __DIR__ . '/includes/puzzle_games.php';
require_once __DIR__ . '/includes/jigsaw.php';
require_once __DIR__ . '/includes/pal_jobs.php';
$u = require_login();
if (!ppal_open() || is_guest($u)) { flash('Puzzle Pals are coming soon.', 'err'); redirect('games.php'); }
$uid = (int)$u['id'];
if (!pj_open($u)) { flash('Pal jobs open at gnome level ' . pj_min_level() . '.', 'err'); redirect('puzzlepals.php'); }

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    $pal = (string)($_POST['pal'] ?? '');
    $pots = (int)($_POST['potions'] ?? 0);
    $jobPal = $do === 'collect' ? (string)q_val('SELECT pal_uid FROM ppal_jobs WHERE id = ? AND user_id = ?', [(int)($_POST['job'] ?? 0), $uid]) : '';
    $res = match ($do) {
        'send_garden' => pj_garden_send($u, $pal, (int)($_POST['plot'] ?? 0), (int)($_POST['days'] ?? 0)),
        'send_trip' => pj_trip_send($u, $pal, (string)($_POST['land'] ?? ''), (string)($_POST['tool'] ?? ''), (int)($_POST['hours'] ?? 0), $pots),
        'send_delve' => pj_delve_send($u, $pal, (int)($_POST['delve'] ?? 0), $pots),
        'recall' => pj_recall($u, (int)($_POST['job'] ?? 0)),
        'heal' => pj_heal($u, $pal),
        'collect' => pj_collect($u, (int)($_POST['job'] ?? 0)),
        default => [false, 'Nothing to do.'],
    };
    if ($do === 'collect') {
        foreach ((array)$res[1] as $l) flash((string)$l, $res[0] ? 'ok' : 'err');
        if ($res[0]) $_SESSION['pj_receipt'] = ['pal' => $jobPal, 'lines' => array_map('strval', (array)$res[1])];   // shown once, at the top of the ledger
    } else flash((string)$res[1], $res[0] ? 'ok' : 'err');
    redirect('paljobs.php');
}

pj_settle($uid);
$now = time();
$pals = pj_pals($uid);
$jobs = pj_jobs($uid);
$plots = q('SELECT id, garden_name FROM plots WHERE user_id = ? ORDER BY id', [$uid])->fetchAll();
$delves = pj_cleared_delves($uid);
$ranToday = array_map('intval', q("SELECT target FROM ppal_jobs WHERE user_id = ? AND kind = 'delve' AND day = ?", [$uid, landmark_day()])->fetchAll(PDO::FETCH_COLUMN));
$tools = pj_tools($uid);
$potions = pj_potion_count($uid);
$maxAway = pj_max_away();
$left = $maxAway - count($jobs);
$runsLeft = max(0, pj_runs_per_day() - pj_runs_today($uid));
$potMax = min(5, $potions);
$receipt = $_SESSION['pj_receipt'] ?? null;
unset($_SESSION['pj_receipt']);

$plotName = [];
foreach ($plots as $pl) $plotName[(int)$pl['id']] = (string)($pl['garden_name'] ?: 'Garden ' . $pl['id']);
$delveName = [];
foreach ($delves as $d) $delveName[(int)$d['id']] = $d['name'] . ' (L' . (int)$d['level'] . ')';
$byUid = [];
foreach ($jobs as $j) $byUid[$j['pal_uid']] = $j;
$home = array_filter($pals, fn($p) => $p['status'] === 'home');

// the ledger: ready first, then soonest back; garden stays last (they end on a date, not a countdown)
usort($jobs, fn($a, $b) => [$a['state'] !== 'ready', $a['kind'] === 'garden', ts($a['ends_at'])] <=> [$b['state'] !== 'ready', $b['kind'] === 'garden', ts($b['ends_at'])]);
$kindTxt = ['garden' => '🪴 Garden', 'trip' => '🧺 Gathering', 'delve' => '🕳️ Delve'];
$jobLine = fn(array $j): string => match ($j['kind']) {
    'garden' => $plotName[(int)$j['plot_id']] ?? 'a garden',
    'trip' => (LANDSCAPES[$j['target']][1] ?? $j['target']) . ' · ' . (TOOL_TYPES[$j['tool']][0] ?? $j['tool']) . ' · ' . pj_ago(ts($j['ends_at']) - ts($j['started_at'])),
    'delve' => ($delveName[(int)$j['target']] ?? 'a delve') . ((int)$j['potions'] ? ' · ' . (int)$j['potions'] . ' potion' . ((int)$j['potions'] > 1 ? 's' : '') : ''),
    default => '',
};
$nextBack = null;
foreach ($jobs as $j) if ($j['state'] === 'active' && $j['kind'] !== 'garden' && (!$nextBack || ts($j['ends_at']) < ts($nextBack['ends_at']))) $nextBack = $j;
$anyReady = (bool)array_filter($jobs, fn($j) => $j['state'] === 'ready');

// the board: [icon, title, length, what it does, what it pays, skill key, skill label, the small print]
$posts = [
    'garden' => ['🪴', 'Tend a garden', '1, 3 or 7 days', 'Waters, weeds and harvests while you are away. Works beside your hired helpers.', 'Pays Gardening XP', 'g', '🪴 Gardening', 'Waters at Gardening 1, weeds from 3, harvests at 9.'],
    'trip' => ['🧺', 'Gathering trip', '1, 3 or 8 hours', 'Pick a land and a tool. The pal brings back what it finds.', 'Pays finds and Adventuring XP', 'a', '🧭 Adventuring', 'Rare finds need Adventuring 5. Unused potions come back.'],
    'delve' => ['🕳️', 'Re-run a cleared delve', 'Once a day per delve', 'Five rooms against the delve’s level. The chest pays about 60% of a real clear.', 'No first-clear bonus', 'a', '🧭 Adventuring', 'Unused potions come back.'],
];
$blocked = function (string $kind) use ($left, $maxAway, $runsLeft, $tools, $delves, $ranToday, $plots, $home): string {
    if ($left < 1) return 'All ' . $maxAway . ' jobs are taken. Collect one first.';
    if ($kind !== 'garden' && $runsLeft < 1) return 'Your pals have done enough trips and delves for today (' . pj_runs_per_day() . ').';
    if ($kind === 'garden' && !$plots) return 'Pals tend your gardens. Start one first.';
    if ($kind === 'trip' && !$tools) return 'Trips need a gathering tool in your satchel.';
    if ($kind === 'delve' && !$delves) return 'Clear a delve yourself first, then a pal can re-run it.';
    if ($kind === 'delve' && !array_diff(array_map(fn($d) => (int)$d['id'], $delves), $ranToday)) return 'Every delve you have cleared needs a day to settle.';
    if (!$home) return 'Everyone is out on a job.';
    return '';
};
$potionField = fn(string $kind): string => '<div class="pjfield"><label for="pjpot-' . $kind . '">Potions to pack</label>'
    . '<div class="pjstep"><input type="number" id="pjpot-' . $kind . '" name="potions" value="' . min(2, $potMax) . '" min="0" max="' . $potMax . '" inputmode="numeric" data-pj-step>'
    . '<small class="muted">' . ($potions ? 'of ' . $potions . ' · up to 5' : 'You have none') . '</small></div></div>';
$seg = function (string $name, string $legend, array $vals, int $on, callable $fmt): string {
    $h = '<fieldset class="pjfield pjseg"><legend>' . e($legend) . '</legend><div class="pjsegs">';
    foreach ($vals as $v) $h .= '<label><input type="radio" name="' . $name . '" value="' . (int)$v . '"' . ($v === $on ? ' checked' : '') . '><span>' . e($fmt($v)) . '</span></label>';
    return $h . '</div></fieldset>';
};

page_header('Pal Jobs');
?>
<div id="pz" class="pjpage" data-pj-now="<?= $now ?>">
  <div class="pjtop">
    <h1>🧩 Pal Jobs</h1>
    <ul class="chips pjcounts" aria-label="Today">
      <li class="chip<?= $runsLeft < 1 ? ' pjnone-left' : '' ?>"><b><?= $runsLeft ?></b> runs left</li>
      <li class="chip"><a href="<?= e(url('inventory.php?tab=craft&c=potions')) ?>" title="Craft Healing Potions at the Alchemy Table">🧪 <b><?= $potions ?></b> Potion<?= $potions === 1 ? '' : 's' ?></a></li>
      <li class="chip"><a href="<?= e(url('puzzlepals.php')) ?>">📖 Pal Book</a></li>
    </ul>
  </div>

  <?php if (!$pals): ?>
  <section class="box pjempty">
    <h2>No pals yet</h2>
    <p>Pals turn up at places on the map once you solve one of their pictures at Advanced. Find one and it can work for you here.</p>
    <a class="btn" href="<?= e(url('world.php')) ?>">🗺️ Open the map</a>
  </section>
  <?php else: ?>
  <div class="pjgrid">
    <section class="box pjpanel pjledger" aria-labelledby="pjouth">
      <header class="pjpanelhd">
        <h2 id="pjouth" tabindex="-1">Out and about</h2>
        <span class="pjslots"><span><b><?= count($jobs) ?></b> of <?= $maxAway ?> out</span>
          <span class="pjdots" aria-hidden="true"><?php for ($i = 0; $i < $maxAway; $i++): ?><i<?= $i < count($jobs) ? ' class="on"' : '' ?>></i><?php endfor; ?></span></span>
      </header>
      <?php if ($receipt && $receipt['lines']): $rp = $pals[$receipt['pal']] ?? null; ?>
      <div class="flash pjreceipt" role="status">
        <b><?= $rp ? e($rp['name']) . ' is home.' : 'Collected.' ?></b>
        <ul><?php foreach ($receipt['lines'] as $i => $l): ?><li class="pjl<?= min($i, 7) ?>"><?= e($l) ?></li><?php endforeach; ?></ul>
      </div>
      <?php endif; ?>
      <ul class="pjrows">
        <?php foreach ($jobs as $j): $p = $pals[$j['pal_uid']] ?? null; if (!$p) continue;
          $r = json_decode((string)$j['result'], true) ?: [];
          $t0 = ts($j['started_at']); $t1 = ts($j['ends_at']);
          $ready = $j['state'] === 'ready';
          $pct = $ready ? 100 : max(2, min(100, (int)round(100 * ($now - $t0) / max(1, $t1 - $t0)))); ?>
        <li class="pjrow pj-<?= e($j['kind']) ?><?= $ready ? ' is-ready' : '' ?>"<?= !$ready && $j['kind'] !== 'garden' ? ' data-pj-start="' . $t0 . '" data-pj-end="' . $t1 . '"' : '' ?>>
          <?= ppal_img($p['key'], '', 'ppalimg pjimg', 44) ?>
          <div class="pjwho"><b><?= e($p['name']) ?></b>
            <small><?= $kindTxt[$j['kind']] ?? '' ?> · <?= $ready ? 'back home' . (!empty($r['fainted']) ? ' (ran out of HP)' : '') : e($jobLine($j)) ?></small></div>
          <div class="pjact">
            <?php if ($ready): ?>
            <span class="pjeta">Ready</span>
            <form method="post" action="<?= e(url('paljobs.php')) ?>"><?= csrf_field() ?><input type="hidden" name="job" value="<?= (int)$j['id'] ?>"><button class="btn small" name="do" value="collect">Collect</button></form>
            <?php elseif ($j['kind'] === 'garden'): ?>
            <span class="pjeta pjeta-date">until <?= e(puzzle_local((string)$j['ends_at'], 'j M, H:i')) ?></span>
            <form method="post" action="<?= e(url('paljobs.php')) ?>"><?= csrf_field() ?><input type="hidden" name="job" value="<?= (int)$j['id'] ?>"><button class="btn small ghost" name="do" value="recall">Call home</button></form>
            <?php else: ?>
            <span class="pjeta" data-pj-eta><?= e(pj_ago($t1 - $now)) ?></span>
            <small class="muted" data-pj-hide-at-zero>back at <?= e(puzzle_local((string)$j['ends_at'], 'H:i')) ?></small>
            <form method="post" action="<?= e(url('paljobs.php')) ?>" hidden data-pj-show-at-zero><?= csrf_field() ?><input type="hidden" name="job" value="<?= (int)$j['id'] ?>"><button class="btn small" name="do" value="collect">Collect</button></form>
            <?php endif; ?>
          </div>
          <progress class="pjbar" max="100" value="<?= $pct ?>" aria-label="<?= e($p['name']) ?>: <?= $pct ?>% of the way"></progress>
        </li>
        <?php endforeach; ?>
        <?php for ($i = count($jobs); $i < $maxAway; $i++): ?>
        <li class="pjrow pjfree"><span class="pjph" aria-hidden="true"></span><span>Free slot. <a href="#pjboard">Pick a job</a></span></li>
        <?php endfor; ?>
      </ul>
      <p class="pjfoot"><?php if ($nextBack && ($nb = $pals[$nextBack['pal_uid']] ?? null)): ?>Next back: <?= e($nb['name']) ?> at <?= e(puzzle_local((string)$nextBack['ends_at'], 'H:i')) ?>.<?php elseif ($anyReady): ?>Collect to free the slot.<?php else: ?>Gardeners stay until their days are up, or until you call them home.<?php endif; ?></p>
    </section>

    <section class="box pjpanel pjathome" aria-labelledby="pjhomeh">
      <header class="pjpanelhd"><h2 id="pjhomeh">At home</h2><small class="muted">HP grows back at home</small></header>
      <?php if (!$home): ?><p class="muted pjnone">Everyone is out on a job.</p><?php endif; ?>
      <ul class="pjrows">
        <?php foreach ($home as $p): $back = ($byUid[$p['uid']]['state'] ?? '') === 'ready'; ?>
        <li class="pjrow pjpal ppr-<?= e($p['pal']['rarity']) ?>">
          <?= ppal_img($p['key'], '', 'ppalimg pjimg', 44) ?>
          <div class="pjwho">
            <span class="pjnmrow"><b><?= e($p['name']) ?></b> <span class="ppalrar"><?= e(ucfirst($p['pal']['rarity'])) ?></span></span>
            <span class="pjstats">
              <span class="pjsk" title="Gardening">🪴<span class="vh">Gardening</span> <?= (int)$p['g'] ?></span>
              <span class="pjsk" title="Adventuring">🧭<span class="vh">Adventuring</span> <?= (int)$p['a'] ?></span>
              <?php if ($p['hp'] < 1): ?><span class="pjrest">Resting · 0/<?= (int)$p['max'] ?><span class="vh"> HP</span></span>
              <?php else: ?><span class="pjhp"><meter min="0" max="<?= (int)$p['max'] ?>" low="<?= (int)ceil($p['max'] * 0.4) ?>" high="<?= (int)ceil($p['max'] * 0.4) ?>" optimum="<?= (int)$p['max'] ?>" value="<?= (int)$p['hp'] ?>" aria-hidden="true"></meter><?= (int)$p['hp'] ?>/<?= (int)$p['max'] ?><span class="vh"> HP</span></span><?php endif; ?>
            </span>
            <?php if ($back || $p['active']): ?><small class="muted"><?= $back ? 'Just back: collect above' : 'Taken along: earns a little XP' ?></small><?php endif; ?>
          </div>
          <?php if ($p['hp'] < $p['max']): ?>
          <form method="post" action="<?= e(url('paljobs.php')) ?>" class="pjheal"><?= csrf_field() ?><input type="hidden" name="do" value="heal"><input type="hidden" name="pal" value="<?= e($p['uid']) ?>">
            <button class="btn small ghost"<?= $potions < 1 ? ' disabled title="You have no Healing Potion."' : '' ?> aria-label="Give <?= e($p['name']) ?> a potion, plus <?= PJ_POTION_HEAL ?> HP">🧪 +<?= PJ_POTION_HEAL ?> HP</button></form>
          <?php endif; ?>
        </li>
        <?php endforeach; ?>
      </ul>
      <p class="pjfoot">A pal at 0 HP heads home. Healing Potions: craft them (Crafting → Potions) or buy them at Twigg’s Seed Emporium.</p>
    </section>
  </div>

  <section id="pjboard" class="pjboard" aria-labelledby="pjboardh">
    <div class="pjboardhd"><h2 id="pjboardh">Jobs</h2><p class="muted">Pick a job, then a pal.</p></div>
    <div class="pjposts">
      <?php foreach ($posts as $kind => [$ico, $title, $len, $desc, $pays, $sk, $skTxt, $why]):
        $stop = $blocked($kind);
        $ranked = $home;
        uasort($ranked, fn($a, $b) => [$b['hp'] > 0, $b[$sk], $b['hp']] <=> [$a['hp'] > 0, $a[$sk], $a['hp']]); ?>
      <article class="box pjpost pjpost-<?= $kind ?>" aria-labelledby="pjt-<?= $kind ?>">
        <div class="pjposthd"><span class="pjico" aria-hidden="true"><?= $ico ?></span><div><h3 id="pjt-<?= $kind ?>"><?= e($title) ?></h3><p class="pjlen"><?= e($len) ?></p></div></div>
        <p class="pjdesc"><?= e($desc) ?></p>
        <p class="pjpays muted"><?= e($pays) ?></p>
        <?php if ($stop !== ''): ?>
        <p class="pjblocked">⚠️ <?= e($stop) ?></p>
        <?php else: ?>
        <form method="post" action="<?= e(url('paljobs.php')) ?>" class="pjform" data-pj-kind="<?= $kind ?>"><?= csrf_field() ?><input type="hidden" name="do" value="send_<?= $kind ?>">
          <fieldset class="pjpick">
            <legend><span>Send who?</span> <small class="muted"><?= $skTxt ?></small></legend>
            <ul class="pjfaces">
              <?php foreach ($ranked as $p): $rest = $p['hp'] < 1; ?>
              <li><label class="pjface<?= $rest ? ' is-resting' : '' ?>">
                <input type="radio" name="pal" value="<?= e($p['uid']) ?>" required<?= $rest ? ' disabled' : '' ?>>
                <?= ppal_img($p['key'], '', 'ppalimg pjimg', 32) ?>
                <span class="pjnm"><?= e($p['name']) ?></span>
                <?php if ($rest): ?><span class="pjlv pjlv-rest">Resting</span>
                <?php else: ?><meter class="pjfhp" min="0" max="<?= (int)$p['max'] ?>" low="<?= (int)ceil($p['max'] * 0.4) ?>" high="<?= (int)ceil($p['max'] * 0.4) ?>" optimum="<?= (int)$p['max'] ?>" value="<?= (int)$p['hp'] ?>" aria-hidden="true"></meter>
                <span class="pjlv"><span class="vh"><?= $sk === 'g' ? 'Gardening' : 'Adventuring' ?> </span><?= (int)$p[$sk] ?><span class="vh">, HP <?= (int)$p['hp'] ?> of <?= (int)$p['max'] ?></span></span><?php endif; ?>
              </label></li>
              <?php endforeach; ?>
            </ul>
          </fieldset>
          <div class="pjopts">
            <?php if ($kind === 'garden'): ?>
            <div class="pjfield"><label for="pjplot">Garden</label><select id="pjplot" name="plot"><?php foreach ($plotName as $id => $nm): ?><option value="<?= $id ?>"><?= e($nm) ?></option><?php endforeach; ?></select></div>
            <?= $seg('days', 'For', PJ_GARDEN_DAYS, 3, fn($d) => $d . ' day' . ($d > 1 ? 's' : '')) ?>
            <?php elseif ($kind === 'trip'): ?>
            <div class="pjfield"><label for="pjland">Where</label><select id="pjland" name="land"><?php foreach (LANDSCAPES as $k => $L): ?><option value="<?= e($k) ?>"><?= e($L[1]) ?></option><?php endforeach; ?></select></div>
            <div class="pjfield"><label for="pjtool">Tool</label><select id="pjtool" name="tool"><?php foreach ($tools as $t => $tier): ?><option value="<?= e($t) ?>"><?= e(TOOL_TYPES[$t][0] ?? $t) ?> (tier <?= (int)$tier ?>)</option><?php endforeach; ?></select></div>
            <?= $seg('hours', 'Hours', PJ_TRIP_HOURS, 3, fn($h) => $h . ' h') ?>
            <?= $potionField('trip') ?>
            <?php else: ?>
            <div class="pjfield"><label for="pjdelve">Delve</label><select id="pjdelve" name="delve"><?php foreach ($delves as $d): $ran = in_array((int)$d['id'], $ranToday, true); ?><option value="<?= (int)$d['id'] ?>"<?= $ran ? ' disabled' : '' ?>><?= e($delveName[(int)$d['id']]) ?><?= $ran ? ' · re-run today' : '' ?></option><?php endforeach; ?></select></div>
            <?= $potionField('delve') ?>
            <?php endif; ?>
            <p class="pjhint muted"><?= e($why) ?></p>
            <p class="pjback" data-pj-back aria-live="polite"><?= $kind === 'garden' ? 'Back when the days are up.' : ($kind === 'trip' ? 'Back when the hours are up, sooner if HP runs out.' : 'Back in about an hour.') ?></p>
            <button class="btn pjsend" data-pj-send>Send</button>
          </div>
        </form>
        <?php endif; ?>
      </article>
      <?php endforeach; ?>
    </div>
  </section>
  <?php endif; ?>
</div>
<?php page_footer();
```


## Update: counts row is one line
Chips: `N runs left` (title: trips and delves left today), `N Potions` (links to Crafting, Potions tab), `Pal Book`. CSS: `.pjcounts{display:flex; flex-wrap:nowrap; gap:6px}`, chips `white-space:nowrap; padding:2px 8px`. Check 320px.
At max-width 340px: chip padding 2px 5px, font 13px, gap 4px (fits 320px).

## Update: tabs (Out · At home · Jobs)
- Row 1: h1 + chips. Row 2: `.pjtabs` (role=tablist), built by `assets/paljobs.js` from the existing `.pjledger`, `.pjathome`, `#pjboard` sections. **No PHP markup change.** Without JS all three stack as before.
- Tabs show counts (`Out 3`, `At home 9`); the Out count turns gold when a pal is ready to collect. Default tab: Out, or Jobs if nobody is out or the URL is `#pjboard`. Free-slot "Pick a job" links switch to Jobs.
- Keys: Left/Right/Home/End. `aria-selected`, `aria-controls`, `role=tabpanel` set by JS.
- CSS: `.pjtabs`, `.pjtab`, `.pjtabn`, `.pj-tabbed .pjgrid{display:block}` (the 2-column desktop grid is not used in tabbed mode). Tab height 44px.
