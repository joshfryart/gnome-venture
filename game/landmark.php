<?php
declare(strict_types=1);
/** Actions at a landmark (v0.7.26): havens, wonders, delves and lairs. POST only; the panel is on the World page. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/adventure.php';
$u = require_login();
if (!is_post()) redirect('world.php');
csrf_check();
refresh_energy($u);
$lm = (int)($_POST['lm'] ?? 0);
$do = (string)($_POST['do'] ?? '');
if (!str_starts_with($do, 'repair_') && active_expedition((int)$u['id'])) {   // v0.9.6: say why, like the shop page does
    flash('You’re on the road; places wait until you arrive.', 'err');
    redirect('adventure.php');
}
require_once __DIR__ . '/includes/journey.php';   // v0.7.66: places closed until a Journey chapter is finished
$lmSlug = (string)q_val('SELECT l.slug FROM landmarks m JOIN locations l ON l.id = m.location_id WHERE m.id = ?', [$lm]);
if ($lmSlug !== '' && ($jc = journey_lock((int)$u['id'], 'place', $lmSlug))) {
    flash('🚧 This place is closed for repairs. Help rebuild it in Wren’s Journey (' . $jc['region'] . ': ' . $jc['title'] . ').', 'err');
    redirect('world.php');
}
require_once __DIR__ . '/includes/rebuild.php';   // v0.7.77 repairs
// v0.7.87: a place in ruins can only be repaired, not used. v0.7.88: ruins are per gnome, so this is for the gnome who hasn't made it safe yet
if (!str_starts_with($do, 'repair_') && ($lmRow = q_one('SELECT * FROM landmarks WHERE id = ?', [$lm])) && landmark_in_ruins($lmRow, (int)$u['id'])) {
    flash('🏚️ ' . $lmRow['name'] . ' is in ruins. Make it safe first (take on the repair).', 'err');
    redirect('world.php');
}
$repair = (int)($_POST['repair'] ?? 0);
[$ok, $msg] = match ($do) {
    'rest', 'stay' => haven_act($u, $lm, $do),
    'buy' => haven_act($u, $lm, 'buy', (int)($_POST['item_id'] ?? 0)),
    'wonder' => wonder_try($u, $lm, (string)($_POST['stat'] ?? '')),
    'delve' => delve_start($u, $lm),
    'lair' => lair_start($u, $lm),
    'repair_start' => repair_start($u, $lm),       // v0.7.77
    'repair_hand' => repair_hand($u, $repair),
    'repair_drop' => repair_drop($u, $repair),
    default => [false, 'Unknown action.'],
};
flash($msg, $ok ? 'ok' : 'err');
// v0.7.77: repairs go back to wherever the gnome was (town square, quests tab or the world map), only to our own pages
$back = (string)($_POST['back'] ?? '');
$safe = preg_match('#^(town|world|index|jobs)\.php(\?[^\s]*)?$#', $back) && !str_contains($back, '//') ? $back : 'world.php';
redirect(match (true) {
    str_starts_with($do, 'repair_') => $safe,
    $ok && in_array($do, ['delve', 'lair'], true) => 'adventure.php',
    default => 'world.php',
});
