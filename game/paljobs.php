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
require_once __DIR__ . '/includes/crafting.php';   // v2.4.61: station shifts (craft_stations, craft_recipes)
require_once __DIR__ . '/includes/craft_map.php';
require_once __DIR__ . '/includes/pal_jobs_view.php';   // the page parts (also used by the Pal Yard picture)
$u = require_login();
if (!ppal_open() || is_guest($u)) { flash('Puzzle Pals are coming soon.', 'err'); redirect('games.php'); }
$uid = (int)$u['id'];
if (!pj_open($u)) { flash('Pal jobs open at gnome level ' . pj_min_level() . '.', 'err'); redirect('puzzlepals.php'); }

$backTo = (($_POST['back'] ?? '') === 'palyard' && gnav_page_open('gnav_tree')) ? 'palyard.php' : 'paljobs.php';   // the yard picture's forms come back to the picture
if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    $pal = (string)($_POST['pal'] ?? '');
    $pots = (int)($_POST['potions'] ?? 0);
    $unq = !empty($_POST['unequip']);   // v2.3.2: the player agreed to take an equipped pal off the party
    $jobPal = $do === 'collect' ? (string)q_val('SELECT pal_uid FROM ppal_jobs WHERE id = ? AND user_id = ?', [(int)($_POST['job'] ?? 0), $uid]) : '';
    // v2.3.94: several pals at once. Ticked pals (pals[]) get the same job; each send still checks its own rules (slots, runs per day, one gardener per garden, one re-run per delve per day).
    $picked = array_values(array_unique(array_filter(array_map('strval', array_merge((array)($_POST['pals'] ?? []), $pal !== '' ? [$pal] : [])), fn($x) => $x !== '')));
    if (in_array($do, ['send_garden', 'send_trip', 'send_delve', 'send_station'], true) && count($picked) > 0) {
        $sent = 0; $why = [];
        $ov = (array)($_POST['over'] ?? []);   // over[<pal>][plot|land|tool|delve]: this pal's own pick; empty = the job's default
        $pick = fn(string $pu, string $k, $dflt) => (is_array($ov[$pu] ?? null) && is_string($ov[$pu][$k] ?? null) && $ov[$pu][$k] !== '') ? $ov[$pu][$k] : $dflt;
        foreach ($picked as $pu) {
            $one = match ($do) {
                'send_garden' => pj_garden_send($u, $pu, (int)$pick($pu, 'plot', $_POST['plot'] ?? 0), (int)($_POST['days'] ?? 0), $unq),
                'send_trip' => pj_trip_send($u, $pu, (string)$pick($pu, 'land', $_POST['land'] ?? ''), (string)$pick($pu, 'tool', $_POST['tool'] ?? ''), (int)($_POST['hours'] ?? 0), $pots, $unq, !empty($_POST['luck'])),
                'send_station' => (function () use ($u, $pu, $unq, $pick): array { [$ar, $ob] = array_pad(explode(':', (string)$pick($pu, 'station', $_POST['station'] ?? ''), 2), 2, ''); return pj_station_send($u, $pu, $ar, $ob, (string)($_POST['mode'] ?? 'all'), (array)($_POST['recipes'] ?? []), (int)($_POST['hours'] ?? 0), $unq); })(),
                default => pj_delve_send($u, $pu, (int)$pick($pu, 'delve', $_POST['delve'] ?? 0), $pots, $unq),
            };
            $pn = (string)(pj_pal($uid, $pu)['name'] ?? 'A pal');
            if (count($picked) === 1) { flash((string)$one[1], $one[0] ? 'ok' : 'err'); $sent = -1; continue; }
            if ($one[0]) { $sent++; flash($pn . ': ' . (string)$one[1], 'ok'); }
            else $why[] = $pn . ': ' . (string)$one[1];
        }
        if ($sent >= 0) {
            foreach ($why as $w) flash($w, 'err');
            flash($sent . ' of ' . count($picked) . ' pals sent.', $sent ? 'ok' : 'err');
        }
        redirect($backTo);
    }
    if ($do === 'collect_all') {
        // v2.5: one chest and a few chips instead of a long list of lines
        $n = 0; $sum = ['coins' => 0, 'items' => [], 'axp' => 0, 'cxp' => 0, 'used' => 0, 'back' => 0, 'served' => 0, 'fainted' => 0];
        foreach (pj_jobs($uid) as $jr) {
            if ($jr['state'] !== 'ready') continue;
            $one = pj_collect($u, (int)$jr['id']);
            if (!$one[0]) continue;
            $n++;
            $t = (array)($one[3] ?? []);
            foreach (['coins', 'axp', 'cxp', 'used', 'back', 'served'] as $k) $sum[$k] += (int)($t[$k] ?? 0);
            foreach ((array)($t['items'] ?? []) as $iid => $qty) $sum['items'][$iid] = ($sum['items'][$iid] ?? 0) + (int)$qty;
            if (str_contains((string)($one[2] ?? ''), 'came home early')) $sum['fainted']++;
        }
        if ($n) {
            $chips = [];
            if ($sum['coins']) $chips[] = '💰 ' . money($sum['coins']);
            if ($sum['items']) $chips[] = '🎁 ' . array_sum($sum['items']) . ' find' . (array_sum($sum['items']) === 1 ? '' : 's');
            if ($sum['axp']) $chips[] = '⭐ +' . $sum['axp'] . ' Adventuring XP';
            if ($sum['cxp']) $chips[] = '⭐ +' . $sum['cxp'] . ' Crafting XP';
            if ($sum['served']) $chips[] = '🍲 ' . $sum['served'] . ' dish' . ($sum['served'] === 1 ? '' : 'es') . ' served';
            if ($sum['used'] || $sum['back']) $chips[] = '🧪 ' . $sum['used'] . ' drunk, ' . $sum['back'] . ' back';
            if ($sum['fainted']) $chips[] = '😵 ' . $sum['fainted'] . ' came home early';
            flash($n . ' job' . ($n > 1 ? 's' : '') . ' home' . ($chips ? ': ' . implode(' · ', $chips) : '') . '.', 'ok');
            $_SESSION['pj_receipt'] = ['pal' => '', 'head' => 'Collected ' . $n . ' job' . ($n > 1 ? 's' : '') . '.', 'lines' => [], 'chips' => $chips];
            if ($sum['coins'] || $sum['items']) {
                require_once __DIR__ . '/includes/chest.php';
                $its = [];
                foreach ($sum['items'] as $iid => $qty) $its[] = [(int)$iid, (int)$qty, 'common'];
                chest_note($sum['coins'], $sum['axp'] + $sum['cxp'], $its, ['title' => 'Your pals are home!', 'done' => 'Your pals brought back…']);
            }
        } else flash('Nothing to collect.', 'err');
        redirect($backTo);
    }
    $res = match ($do) {
        'send_garden' => pj_garden_send($u, $pal !== '' ? $pal : ($picked[0] ?? ''), (int)($_POST['plot'] ?? 0), (int)($_POST['days'] ?? 0), $unq),
        'send_trip' => pj_trip_send($u, $pal !== '' ? $pal : ($picked[0] ?? ''), (string)($_POST['land'] ?? ''), (string)($_POST['tool'] ?? ''), (int)($_POST['hours'] ?? 0), $pots, $unq, !empty($_POST['luck'])),
        'send_delve' => pj_delve_send($u, $pal !== '' ? $pal : ($picked[0] ?? ''), (int)($_POST['delve'] ?? 0), $pots, $unq),
        'recall' => pj_recall($u, (int)($_POST['job'] ?? 0)),
        'heal' => pj_heal($u, $pal, (string)($_POST['potion'] ?? PJ_POTION)),
        'collect' => pj_collect($u, (int)($_POST['job'] ?? 0)),
        default => [false, 'Nothing to do.'],
    };
    if ($do === 'collect') {
        if (!empty($res[2])) flash((string)$res[2], 'ok');   // v2.3.3: the receipt title leads the message log too
        foreach ((array)$res[1] as $l) flash((string)$l, $res[0] ? 'ok' : 'err');
        if ($res[0]) $_SESSION['pj_receipt'] = ['pal' => $jobPal, 'head' => (string)($res[2] ?? ''), 'lines' => array_map('strval', (array)$res[1])];   // shown once, at the top of the ledger
    } else flash((string)$res[1], $res[0] ? 'ok' : 'err');
    redirect($backTo);
}

$c = pjv_ctx($u);
extract($c);
page_header('Pal Jobs');
?>
<div id="pz" class="pjpage" data-pj-now="<?= $now ?>">
  <div class="pjtop">
    <h1>🧩 Pal Jobs</h1>
    <?= ppal_hub_tabs_html('jobs') ?>
    <ul class="chips pjcounts" aria-label="Today">
      <li class="chip<?= $runsLeft < 1 ? ' pjnone-left' : '' ?>"><b><?= $runsLeft ?></b> runs left</li>
      <li class="chip"><a href="<?= e(url('inventory.php?tab=craft&c=potions')) ?>" title="Craft Healing Potions at the Alchemy Table">🧪 <b><?= $potions ?></b> Potion<?= $potions === 1 ? '' : 's' ?></a></li>
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
    <?= pjv_ledger($c) ?>

    <?= pjv_home($c) ?>
  </div>

  <section id="pjboard" class="pjboard" aria-labelledby="pjboardh">
    <div class="pjboardhd"><h2 id="pjboardh">Jobs</h2><p class="muted">Pick a job, then a pal.</p></div>
    <div class="pjposts">
      <?php foreach (array_keys($posts) as $kind): ?>
      <?= pjv_post($c, $kind) ?>
      <?php endforeach; ?>
    </div>
  </section>
  <?php endif; ?>
</div>
<?php page_footer();
