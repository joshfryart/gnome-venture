<?php
declare(strict_types=1);
/**
 * The Puzzle box (puzzle combat): the tiles a gnome brings to a fight. It only holds so many (pf_box_capacity: 8 at level 1, +1 per 3 levels, 14 at most),
 * so the gnome chooses from everything they own (the base six, their calling tile and the unlocks). Logic: includes/pfight.php (pf_box*), storage: includes/pfight_game.php (pbox_*).
 * Behind pfight_open. Plain form, works without JS; assets/pbox.js only keeps the count. No inline script or style (CSP).
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/adventure.php';
require_once __DIR__ . '/includes/pfight_game.php';
$u = require_login();
if (!pfight_on($u) || is_guest($u)) { flash('The Puzzle box is not open yet.', 'err'); redirect('gnome.php'); }
$uid = (int)$u['id'];
$lvl = (int)$u['level']; $cal = (string)($u['calling'] ?? '');
$cap = pf_box_capacity($lvl);

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    if (str_starts_with($do, 'pfd_') && pfight_v1_on($u)) {   // 2.6.74, v1 deck model (admin setting pfight_v1): starter, switch a piece, belt, auto-use, fix a tool (includes/pfdeck.php, pfd_post). The page for them is the UI stage
        require_once __DIR__ . '/includes/pfdeck.php';
        [$ok, $msg] = pfd_post($u, $do, $_POST);
        flash($msg, $ok ? 'ok' : 'err');
        redirect('puzzlebox.php');
    }
    if ($do === 'pick') {   // choose one of the three from an offer
        $why = pfight_offer_pick($u, (int)($_POST['offer'] ?? 0), (int)($_POST['choice'] ?? -1));
        flash($why ?? 'Upgrade added to your tile.', $why ? 'err' : 'ok');
    } elseif ($do === 'unupgrade') { pfight_mod_remove($u, (string)($_POST['tile'] ?? '')); flash('Upgrade removed from that tile.', 'ok'); }
    elseif ($do === 'reset') { pbox_save($u, null); flash('Back to the default box.', 'ok'); }
    elseif ($do === 'save') {
        $why = pbox_save($u, array_map('strval', (array)($_POST['tile'] ?? [])));
        flash($why ?? 'Box packed.', $why ? 'err' : 'ok');
    }
    redirect('puzzlebox.php');
}

if (($_GET['pfd'] ?? '') === 'json' && pfight_v1_on($u)) {   // 2.6.74 debug helper (v1 deck model, admins while pfight_v1 = admin): the whole deck as JSON, for the UI stage and the tests
    require_once __DIR__ . '/includes/pfdeck.php';
    header('Content-Type: application/json'); header('Cache-Control: no-store');
    echo json_encode(pfd_deck($u) + ['wear' => pfd_wear($u)], JSON_UNESCAPED_UNICODE);
    exit;
}
[$st, , $bonus] = pfight_calc($u);
$mods = pfight_mods($uid); $offers = pfight_offers($uid); [$today, $dayCap] = pfight_offer_today($uid);
$own = pf_collection($lvl, $cal);
$box = pf_box($lvl, $cal, pbox_load($uid));
page_header('Puzzle box');
?>
<link rel="stylesheet" href="<?= e(url('assets/pfight.css?v=' . APP_VERSION)) ?>">
<div class="box pbox" id="pbox" data-cap="<?= $cap ?>" data-min="<?= PF_BOX_MIN ?>">
  <h2>🧩 Puzzle box</h2>
  <p class="help">Your box holds <b><?= $cap ?></b> tiles (it grows as you level). Pack the ones you want in a fight: <?= PF_BOX_MIN ?> at least, and at least one ⚔️ Hurt tile. You own <?= count($own) ?>.</p>
  <p class="help pbox-up">🧩 Puzzle upgrades: finishing a puzzle (any game, any mode) can earn one; a bigger puzzle gives rarer ones. You have earned <b><?= $today ?> of <?= $dayCap ?></b> today (a new day starts at midnight, server time). <?= count($offers) ?> of <?= PF_OFFER_BANK ?> offers waiting.</p>
  <?php foreach (array_slice($offers, 0, 1) as $o): ?>   <?php /* one offer at a time; the next opens after you choose */ ?>
  <dialog class="pbox-offer" id="offer<?= (int)$o['id'] ?>" open aria-label="Choose a Puzzle upgrade">
    <?php if ($hi = pfight_art('popover-header.png')): ?><div class="pbox-head"><img src="<?= e($hi) ?>" alt=""><h3>Choose an upgrade</h3></div><?php else: ?><h3>🧩 Choose an upgrade</h3><?php endif; ?>
    <p class="help">One of these three goes on the tile shown. It stays until you remove it. From <?= ['a small', 'a medium', 'a big'][(int)$o['rarity']] ?? 'a' ?> puzzle.</p>
    <ul class="pbox-list">
    <?php foreach ($o['choices'] as $ci => [$tk, $mk]): $def = pf_tiles()[$tk] ?? null; $md = PF_MODS[$mk] ?? null; if (!$def || !$md) continue; ?>
      <li><form method="post" class="pbox-pick"><?= csrf_field() ?><input type="hidden" name="do" value="pick"><input type="hidden" name="offer" value="<?= (int)$o['id'] ?>"><input type="hidden" name="choice" value="<?= (int)$ci ?>">
        <button class="btn"><?= e($def['n']) ?> + <?= $md[1] ?> <b><?= e($md[0]) ?></b><br><small><?= e($md[2]) ?><?= isset($mods[$tk]) ? ' (replaces ' . e(PF_MODS[$mods[$tk]][0]) . ')' : '' ?> · <?= ['common', 'uncommon', 'rare'][$md[3]] ?></small></button></form></li>
    <?php endforeach; ?>
    </ul>
  </dialog>
  <?php endforeach; ?>
  <form method="post" class="pbox-form">
    <?= csrf_field() ?><input type="hidden" name="do" value="save">
    <p class="pbox-count" aria-live="polite"><span id="pbox-n"><?= count($box) ?></span> of <?= $cap ?> packed</p>
    <ul class="pbox-list">
    <?php foreach ($own as $k):
        $def = pf_tiles()[$k]; $tile = pf_make_tile($k, $st, ($bonus[$def['t']] ?? 0) + ($cal === 'bloomcaller' && in_array($def['t'], ['charm', 'soothe'], true) ? 2 : 0));
        $tg = PF_TAGS[$def['tag'] ?? ''] ?? null; $on = in_array($k, $box, true);
        $view = ['n' => $tile['n'], 't' => $tile['t'], 'v' => $tile['v'], 'r' => $tile['r'], 'hole' => PF_HOLE[$tile['t']], 'tag' => $def['tag'] ?? '']; ?>
      <li><label class="pbox-item"><input type="checkbox" name="tile[]" value="<?= e($k) ?>"<?= $on ? ' checked' : '' ?>>
        <span class="pfight"><?= pfight_tile_html($view, true) ?></span>
        <span class="pbox-txt"><b><?= e($tile['n']) ?></b> · <?= e(ucfirst($tile['t'])) ?> <?= (int)$tile['v'] ?><?= $tg ? '<br><small>' . $tg[0] . ' ' . e($tg[1]) . '</small>' : '' ?><?php if (isset($mods[$k]) && ($md = PF_MODS[$mods[$k]] ?? null) && pfight_mod_fits($mods[$k], $def['t'])): ?><br><small>⬆️ <?= $md[1] ?> <b><?= e($md[0]) ?></b>: <?= e($md[2]) ?> <button class="btn small ghost" form="unup-<?= e($k) ?>" aria-label="Remove the <?= e($md[0]) ?> upgrade from <?= e($tile['n']) ?>">Remove</button></small><?php endif; ?></span></label></li>
    <?php endforeach; ?>
    </ul>
    <p><button class="btn primary">Pack the box</button></p>
  </form>
  <?php foreach ($mods as $tk => $mk): ?><form method="post" id="unup-<?= e($tk) ?>" class="inline" hidden><?= csrf_field() ?><input type="hidden" name="do" value="unupgrade"><input type="hidden" name="tile" value="<?= e($tk) ?>"></form><?php endforeach; ?>
  <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="reset"><button class="btn">Use the default box</button></form>
  <p class="help">A pal swaps in for one of these tiles in a fight. A change applies from your next fight.</p>
</div>
<script src="<?= e(url('assets/pbox.js?v=' . APP_VERSION)) ?>" defer></script>
<?php page_footer();
