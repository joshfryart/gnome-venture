<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/items.php';
require_once __DIR__ . '/includes/adventure.php';
require_once __DIR__ . '/includes/puzzle_pals.php';   // v2.0.89: pals along
require_once __DIR__ . '/includes/friends.php';
$u = require_login();

/* v2.0.89: My Gnome is a rail of tabs (Overview, Pals, Stats, Calling, Foods, Villagers, Gardens). Every tab is a plain link (?tab=), so it works without script. */
$palsOn = ppal_open() && !is_guest($u);
$TABS = ['overview' => ['🧙', 'Overview'], 'pals' => ['🐾', 'Pals'], 'stats' => ['💪', 'Stats'], 'calling' => ['🎩', 'Calling'],
         'foods' => ['🍴', 'Foods eaten'], 'folk' => ['💛', 'Villagers'], 'gardens' => ['🏡', 'Gardens']];
if (!$palsOn) unset($TABS['pals']);
$tab = (string)($_GET['tab'] ?? 'overview');
if (!isset($TABS[$tab])) $tab = 'overview';
$gurl = fn(string $t, array $x = [], string $frag = ''): string => url('gnome.php?' . http_build_query(['tab' => $t] + $x)) . $frag;

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    $back = (string)($_POST['back'] ?? 'overview');
    if (!isset($TABS[$back])) $back = 'overview';
    if ($do === 'stat') {
        $sk = (string)($_POST['stat'] ?? '');
        [$ok, $msg] = spend_stat_point($u, $sk);
        flash($msg, $ok ? 'ok' : 'err');
        redirect('gnome.php?' . http_build_query(['tab' => 'stats', 's' => $sk]));
    } elseif ($do === 'calling') {
        [$ok, $msg] = choose_calling($u, (string)($_POST['calling'] ?? ''));
        flash($msg, $ok ? 'ok' : 'err');
        redirect('gnome.php?tab=calling');
    } elseif ($do === 'dye') {   // v0.9.7: wear the dyes you own
        $bad = 0;
        foreach (['hat', 'beard'] as $part) {
            if (!isset($_POST[$part])) continue;
            [$ok, $msg] = dye_use($u, $part, (string)$_POST[$part]);
            if (!$ok) { flash($msg, 'err'); $bad++; }
        }
        if (!$bad) flash('🎨 Your gnome looks splendid.');
        redirect('gnome.php?dye=1#dyes');
    } elseif (in_array($do, ['take', 'home'], true) && $palsOn) {   // v2.0.89: pals along. take = into the picked slot (the pal there goes home first)
        $key = (string)($_POST['pal'] ?? '');
        if ($do === 'take' && ($out = (string)($_POST['out'] ?? '')) !== '') ppal_set_active($u, $out, false);
        [$ok, $msg] = ppal_set_active($u, $key, $do === 'take');
        flash($msg, $ok ? 'ok' : 'err');
        redirect($gurl($back));
    }
    redirect('gnome.php');
}

refresh_energy($u);
$GLOBALS['CURRENT_USER'] = $u;
$uid = (int)$u['id'];
$buff = active_buff($u);
$food = food_bonus($uid);
$cap = (int)setting('food_perm_cap');
$gardens = user_gardens($uid);
$home = home_region($u);
$callingLevel = (int)setting('calling_level');
$pts = (int)$u['stat_points'];

// pals along: the strip under the header, the picker, the perk lines
$canParty = $palsOn && ppal_can_party($u);
$eq = $canParty ? ppal_equipped($u) : [];
$palShort = function (array $p): string {
    $v = $p['perk'] === 'shine' ? 0 : ($p['perk'] === 'road' ? (PPAL_ROAD_UNITS[$p['rarity']] ?? 1) : (PPAL_PERK_RATE[$p['perk']] ?? 0) * (PPAL_UNITS[$p['rarity']] ?? 8));
    $perk = match ($p['perk']) { 'gather' => "+$v% rare finds", 'road' => "+$v in road fights", 'finder' => "+$v% extra pal chance", 'tinker' => "+$v% game XP", 'bloom' => "+$v% harvest extras", default => 'a sparkle' };
    $sk = ppal_skill_short($p);
    return $sk !== '' ? $perk . ' · ⚔️ ' . $sk : $perk;
};
$palImg = fn(string $key, int $px): string => ppal_sticker_html($key, $px);
$pick = $canParty && isset($_GET['pick']) ? max(0, min(ppal_party_max() - 1, (int)$_GET['pick'])) : null;
$palBook = $palsOn ? ppal_book($uid) : null;
[$palF, $palT] = $palsOn ? ppal_counts($uid) : [0, 0];

$radarSvg = function (string $selK = '') use ($u, $gurl): string {   // the stat web: Overview (no selection) and Stats tab
    $keys = array_keys(GNOME_STATS);
    $n = count($keys); $cx = 130; $cy = 128; $R = 92;
    $ptAt = function (int $i, float $f) use ($n, $cx, $cy, $R): array { $a = -M_PI / 2 + 2 * M_PI * $i / $n; return [round($cx + cos($a) * $R * $f, 1), round($cy + sin($a) * $R * $f, 1)]; };
    $ring = function (float $f) use ($n, $ptAt): string { $o = []; for ($i = 0; $i < $n; $i++) { [$x, $y] = $ptAt($i, $f); $o[] = "$x,$y"; } return implode(' ', $o); };
    $now = []; $axes = '';
    foreach ($keys as $i => $k) { [$x, $y] = $ptAt($i, min(1, eff_stat($u, $k) / 20)); $now[] = "$x,$y"; [$ax, $ay] = $ptAt($i, 1); $axes .= "M$cx $cy L$ax $ay "; }
    $o = '<svg class="radar" viewBox="0 0 260 256" role="img" aria-label="Your stats as a chart: ' . e(implode(', ', array_map(fn($k) => GNOME_STATS[$k][0] . ' ' . eff_stat($u, $k), $keys))) . '">'
       . '<polygon points="' . $ring(1) . '" class="r20"/><polygon points="' . $ring(.75) . '" class="r15"/><path d="' . $axes . '" class="rax"/>'
       . '<polygon points="' . $ring(.5) . '" class="r10"/><polygon points="' . implode(' ', $now) . '" class="rnow"/>';
    foreach ($keys as $i => $k) { [$lx, $ly] = $ptAt($i, 1.16);
        $o .= '<a href="' . e($gurl('stats', ['s' => $k])) . '"><text x="' . $lx . '" y="' . $ly . '" text-anchor="middle" class="rlab' . ($k === $selK ? ' on' : '') . '">' . GNOME_STATS[$k][1] . ' ' . e(GNOME_STATS[$k][0]) . '</text></a>'; }
    return $o . '</svg>';
};

page_header('My Gnome');
?>
<div class="gvpage">
<div class="gnomehead box">
  <?= gnome_avatar_pals($u, 90) ?>
  <div>
    <h1><?= e(gnome_name($u)) ?><?= $u['title'] ? ' <small class="title">“' . e($u['title']) . '”</small>' : '' ?></h1>
    <p class="help"><a href="<?= e(url('profile.php')) ?>">👤 See your profile as others do</a></p>
    <p><?= $u['calling'] ? e(CALLINGS[$u['calling']][0]) . ' · ' : '' ?>Garden gnome<?= $home ? ' of ' . e($home['gnomish_name']) : '' ?></p>
    <p class="status">
      🧑‍🌾 Gnome level <b><?= (int)$u['level'] ?></b> (<?= (int)$u['xp'] ?>/<?= xp_for_level((int)$u['level'] + 1) ?> XP)
      · 🏡 <?= count($gardens) ?>/<?= max_gardens($u) ?> garden<?= max_gardens($u) === 1 ? '' : 's' ?>
      · ⚡ <?= (int)$u['energy'] ?>/<?= max_energy($u) ?> energy
    </p>
  </div>
</div>

<?php if (ppal_party_on() && !is_guest($u)): ?>
<section class="palstrip" aria-label="Pals along">
  <div class="palhead"><b>🐾 Pals along · <?= count($eq) ?> of <?= ppal_party_max() ?></b>
    <a href="<?= e(url('puzzlepals.php')) ?>">📘 Pal Book<?= $palT > 0 ? ' (' . $palF . '/' . $palT . ')' : '' ?> →</a></div>
  <?php if (!$canParty): ?>
    <p class="help">Pals cannot come along just yet.</p>
  <?php else: ?>
    <div class="palslots">
      <?php for ($i = 0; $i < ppal_party_max(); $i++): $e = $eq[$i] ?? null; ?>
        <a class="palslot<?= $pick === $i ? ' on' : '' ?>" href="<?= e($gurl($tab, ['pick' => $i], '#picker')) ?>">
          <?php if ($e): ?><?= $palImg($e['pal']['key'], 44) ?><span><b><?= e($e['pal']['name']) ?></b> <small class="rar r-<?= e($e['pal']['rarity']) ?>"><?= e($e['pal']['rarity']) ?></small><br><small><?= e($palShort($e['pal'])) ?></small></span>
          <?php else: ?><span class="palstk palstk-ph" aria-hidden="true">+</span><span><b>Choose a pal</b><br><small>Pal <?= $i + 1 ?></small></span><?php endif; ?>
        </a>
      <?php endfor; ?>
    </div>
    <?php if ((int)$palBook['found'] === 0 && $pick === null) echo ppal_howto_html(); ?>
  <?php endif; ?>
</section>
<?php if ($pick !== null): $cur = $eq[$pick] ?? null; $eqKeys = array_map(fn($x) => $x['pal']['key'], $eq); ?>
<section class="box palpick" id="picker" aria-label="Choose a pal">
  <div class="palhead"><h2>🐾 <?= $cur ? 'Change Pal ' . ($pick + 1) : 'Choose Pal ' . ($pick + 1) ?></h2><a class="btn small ghost" href="<?= e($gurl($tab)) ?>">Done</a></div>
  <?php if ($cur): ?>
    <form method="post" class="palnow"><?= csrf_field() ?><input type="hidden" name="do" value="home"><input type="hidden" name="back" value="<?= e($tab) ?>"><input type="hidden" name="pal" value="<?= e($cur['pal']['key']) ?>">
      <?= $palImg($cur['pal']['key'], 44) ?><span><b><?= e($cur['pal']['name']) ?></b> is in this slot.</span> <button class="btn small ghost">Send home</button></form>
  <?php endif; ?>
  <?php $any = false; foreach ($palBook['released'] as $sec): foreach ($sec['roster'] as $p): if (!$p['got']) continue; $any = true; $here = $cur && $cur['pal']['key'] === $p['key']; $along = in_array($p['key'], $eqKeys, true); ?>
    <div class="palrow"><?= $palImg($p['key'], 44) ?>
      <span class="grow"><b><?= e($p['name']) ?></b> <small class="rar r-<?= e($p['rarity']) ?>"><?= e($p['rarity']) ?></small><br><small><?= e($palShort($p)) ?></small></span>
      <?php if ($here): ?><small class="good">Here now</small>
      <?php elseif ($along): ?><small class="muted">In the other slot</small>
      <?php else: ?><form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="take"><input type="hidden" name="back" value="<?= e($tab) ?>"><input type="hidden" name="pal" value="<?= e($p['key']) ?>"><?php if ($cur): ?><input type="hidden" name="out" value="<?= e($cur['pal']['key']) ?>"><?php endif; ?><button class="btn small">Take along</button></form><?php endif; ?>
    </div>
  <?php endforeach; endforeach; if (!$any) echo ppal_howto_html(); ?>
</section>
<?php endif; endif; ?>

<div class="gvrow">
  <nav class="gvtabs" aria-label="My Gnome sections">
    <?php foreach ($TABS as $tk => [$ti, $tl]): ?><a href="<?= e($gurl($tk)) ?>"<?= $tk === $tab ? ' class="on" aria-current="page"' : '' ?>><span aria-hidden="true"><?= $ti ?></span> <?= e($tl) ?><?= $tk === 'stats' && $pts > 0 ? ' <b class="gvbadge">' . $pts . '</b>' : '' ?></a><?php endforeach; ?>
  </nav>
  <div class="gvmain">
<?php if ($tab === 'overview'):
    $tastedN = (int)q_val('SELECT COUNT(*) FROM user_tasted WHERE user_id = ?', [$uid]);
    $edibleTotal = (int)q_val('SELECT COUNT(*) FROM items WHERE edible = 1');
    $lc = q_one("SELECT SUM(CASE WHEN lm.kind = 'lair' THEN 1 ELSE 0 END) AS lairs, SUM(CASE WHEN lm.kind = 'delve' THEN 1 ELSE 0 END) AS delves
                 FROM landmark_clears c JOIN landmarks lm ON lm.id = c.landmark_id WHERE c.user_id = ?", [$uid]);
    $knownN = (int)q_val('SELECT COUNT(*) FROM npc_friends WHERE user_id = ? AND points > 0', [$uid]); ?>
    <?php if ($pts > 0): ?><div class="flash ok">✨ You have <b><?= $pts ?></b> stat point<?= $pts === 1 ? '' : 's' ?> to spend. <a href="<?= e($gurl('stats')) ?>">Spend them →</a></div><?php endif; ?>
    <div class="factrow">
      <a class="fact" href="<?= e($gurl('foods')) ?>"><span>🍴</span><b><?= $tastedN ?></b><small>foods tasted<?= $edibleTotal ? ' of ' . $edibleTotal : '' ?></small></a>
      <a class="fact" href="<?= e($gurl('calling')) ?>"><span><?= ph_or_emoji('hat-' . (string)$u['calling'], '🎩', 24) ?></span><b><?= $u['calling'] ? e(CALLINGS[$u['calling']][0]) : ((int)$u['level'] >= $callingLevel ? 'Choose!' : 'Lv ' . $callingLevel) ?></b><small>calling</small></a>
      <?php if ($palsOn): ?><a class="fact" href="<?= e($gurl('pals')) ?>"><span>🐾</span><b><?= $palT > 0 ? $palF . '/' . $palT : 'Pals' ?></b><small><?= count($eq) ?> along · puzzle pals</small></a><?php endif; ?>
      <a class="fact" href="<?= e($gurl('folk')) ?>"><span>💛</span><b><?= $knownN ?></b><small>villagers who know you</small></a>
      <a class="fact" href="<?= e($gurl('gardens')) ?>"><span>🏡</span><b><?= count($gardens) ?>/<?= max_gardens($u) ?></b><small>gardens</small></a>
      <?php if ((int)($u['ribbons'] ?? 0)): ?><span class="fact"><span>🎀</span><b><?= (int)$u['ribbons'] ?></b><small>ribbons</small></span><?php endif; ?>
      <?php if ((int)($u['community_rep'] ?? 0)): ?><span class="fact"><span>💚</span><b><?= (int)$u['community_rep'] ?></b><small>community help</small></span><?php endif; ?>
      <?php if ((int)($lc['lairs'] ?? 0)): ?><span class="fact"><span>🐉</span><b><?= (int)$lc['lairs'] ?></b><small>lairs conquered</small></span><?php endif; ?>
      <?php if ((int)($lc['delves'] ?? 0)): ?><span class="fact"><span>🕳️</span><b><?= (int)$lc['delves'] ?></b><small>delves cleared</small></span><?php endif; ?>
    </div>
    <div class="box"><h3>💪 Stats</h3><?= $radarSvg() ?><p class="help"><a href="<?= e($gurl('stats')) ?>">Open stats →</a></p></div>
    <?= dye_editor_html($u) ?>

<?php elseif ($tab === 'pals'):
    $perks = $canParty ? ppal_perks($u) : ['lines' => []]; ?>
    <section class="box">
      <h2>🐾 Pals along <small class="muted"><?= count($eq) ?> of <?= ppal_party_max() ?></small></h2>
      <?php if ($canParty): ?><p class="help">Pick a slot in the strip above to take a pal along or send it home.</p><?php endif; ?>
      <div class="perkbox"><b>What your pals do now</b>
        <?php foreach ($canParty ? ppal_skill_lines($u) : [] as $ln): ?><div>⚔️ <?= e($ln) ?></div><?php endforeach; ?>
        <?php if ($perks['lines']): foreach ($perks['lines'] as $ln): ?><div>✔ <?= e($ln) ?></div><?php endforeach; else: ?><div>Nothing yet. Take a pal along for a small boost.</div><?php endif; ?></div>
      <?php if ((int)$palBook['found'] === 0) echo ppal_howto_html(); ?>
      <h3>Your found pals · <?= $palF ?> of <?= $palT ?></h3>
      <table class="grid"><tr><th>Pal</th><th>Rarity</th><th>Where</th></tr>
      <?php $eqKeys = array_map(fn($x) => $x['pal']['key'], $eq); foreach ($palBook['released'] as $sec): foreach ($sec['roster'] as $p): if (!$p['got']) continue; ?>
        <tr><td><?= $palImg($p['key'], 32) ?> <b><?= e($p['name']) ?></b><br><small class="muted"><?= e($palShort($p)) ?></small></td>
          <td><small class="rar r-<?= e($p['rarity']) ?>"><?= e($p['rarity']) ?></small></td><td><?= in_array($p['key'], $eqKeys, true) ? 'Along' : 'At home' ?></td></tr>
      <?php endforeach; endforeach; ?></table>
      <p><a href="<?= e(url('puzzlepals.php')) ?>">📘 Open the Pal Book<?= $palT > 0 ? ' (' . $palF . '/' . $palT . ')' : '' ?> →</a></p>
    </section>

<?php elseif ($tab === 'stats'):   // S2: a chart beside a list, click a stat to see it, +1 to spend
    $keys = array_keys(GNOME_STATS);
    $selK = (string)($_GET['s'] ?? $keys[0]);
    if (!isset(GNOME_STATS[$selK])) $selK = $keys[0];
    $stMax = (int)setting('stat_max'); ?>
    <section class="box">
      <div class="palhead"><h2>💪 Stats</h2><?php if ($pts > 0): ?><span class="gvbadge big">✨ <?= $pts ?> point<?= $pts === 1 ? '' : 's' ?> to spend</span><?php endif; ?></div>
      <p class="help"><?= $pts > 0 ? 'Press + next to a stat to spend a point.' : '10 is an average gnome. Every 2 points above 10 gives a +1 modifier. You earn ' . (int)setting('stat_points_per_level') . ' stat point per gnome level.' ?></p>
      <div class="statsplit">
        <?= $radarSvg($selK) ?>
        <ul class="statlist">
          <?php foreach (GNOME_STATS as $k => [$nm, $ic]):
              $base = (int)$u['stat_' . $k]; $tot = eff_stat($u, $k); $mod = stat_mod($tot); ?>
            <li class="<?= $k === $selK ? 'on' : '' ?>">
              <a href="<?= e($gurl('stats', ['s' => $k])) ?>" data-inplace><span class="sn"><span aria-hidden="true"><?= $ic ?></span> <b><?= e($nm) ?></b></span> <span class="sc"><?= $tot ?></span> <span class="statmod"><?= $k === 'luck' ? rtrim(rtrim(number_format(luck_percent($u), 3), '0'), '.') . '%' : ($mod >= 0 ? '+' : '') . $mod ?></span></a>
              <?php if ($pts > 0 && $base < $stMax): ?><form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="stat"><input type="hidden" name="stat" value="<?= e($k) ?>"><button class="btn small" aria-label="Add one point to <?= e($nm) ?>">+1</button></form><?php endif; ?>
            </li>
          <?php endforeach; ?>
        </ul>
      </div>
      <?php [$sn, $si, $sdesc, $sgar, $sadv] = GNOME_STATS[$selK]; $sb = eff_stat($u, $selK) - (int)$u['stat_' . $selK]; ?>
      <div class="statsel"><b><?= $si ?> <?= e($sn) ?></b> · <?= e($sdesc) ?>
        <div>🌱 <?= e($sgar) ?></div><div>⚔️ <?= e($sadv) ?></div>
        <div class="muted">🍴 food bonus <?= (int)($food[$selK] ?? 0) ?>/<?= $cap ?><?= $sb ? ' · <span class="good">+' . $sb . ' from a boost</span>' : '' ?></div></div>
      <h3 id="effects">✨ Active effects</h3>
      <?php $fx = active_effects($u); if ($fx): ?>
        <ul class="effects"><?php foreach ($fx as [$ic, $nm, $what, $sec]): ?>
          <li><span class="efi"><?= $ic ?></span> <b><?= e($nm) ?>:</b> <?= e($what) ?> <span class="muted">· <?= e(effect_time($sec)) ?> left</span></li>
        <?php endforeach; ?></ul>
        <p class="help">A new meal replaces the old meal’s boost. Town outings and lucky moments each have their own slot, so they add up.</p>
      <?php else: ?><p class="help">No boosts right now. Eat something from your <a href="<?= e(url('inventory.php')) ?>">satchel</a> or cook something at your <a href="<?= e(url('inventory.php?tab=craft')) ?>">workbench</a>.</p><?php endif; ?>
    </section>

<?php elseif ($tab === 'foods'):   // F1: one menu card with courses
    $showUn = !empty($_GET['un']);
    $tasted = [];
    foreach (q('SELECT item_id FROM user_tasted WHERE user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN) as $iid) $tasted[(int)$iid] = 1;
    $courses = [];
    foreach (q('SELECT id, name, category FROM items WHERE edible = 1 ORDER BY category, name')->fetchAll() as $it) $courses[(string)$it['category']][] = $it;
    $edibleTotal = array_sum(array_map('count', $courses)); ?>
    <section class="box">
      <div class="palhead"><h2>🍴 Foods you’ve tasted</h2><span class="muted"><b><?= count($tasted) ?></b> of <?= $edibleTotal ?></span></div>
      <p><a class="btn small<?= $showUn ? '' : ' ghost' ?>" href="<?= e($gurl('foods', $showUn ? [] : ['un' => 1])) ?>" aria-pressed="<?= $showUn ? 'true' : 'false' ?>">Show not tasted yet</a></p>
      <div class="menucard">
        <p class="mtitle">The Wandering Gnome</p>
        <p class="msub"><?= e(gnome_name($u)) ?>’s tasting menu</p>
        <div class="orn" aria-hidden="true">· · ✦ · ·</div>
        <?php foreach ($courses as $cat => $dishes):
            $have = count(array_filter($dishes, fn($d) => isset($tasted[(int)$d['id']])));
            if (!$have && !$showUn) continue; ?>
          <div class="course"><?= e(ucfirst(str_replace('_', ' ', $cat))) ?> <small><?= $have ?>/<?= count($dishes) ?></small></div>
          <?php foreach ($dishes as $d): $got = isset($tasted[(int)$d['id']]); if (!$got && !$showUn) continue; ?>
            <div class="dish<?= $got ? '' : ' un' ?>"><span class="chk" aria-hidden="true"><?= $got ? '✔' : '·' ?></span> <span><?= e($d['name']) ?></span><span class="lead" aria-hidden="true"></span><small><?= $got ? 'tasted' : 'not tasted yet' ?></small></div>
          <?php endforeach; ?>
        <?php endforeach; ?>
        <?php if (!$tasted && !$showUn): ?><p class="muted">Nothing tasted yet. Eat or drink something from your <a href="<?= e(url('inventory.php?cat=food')) ?>">satchel</a>.</p><?php endif; ?>
        <div class="orn" aria-hidden="true">· · ✦ · ·</div>
        <p class="mfoot">The first taste of a rare crop can raise a stat for good (up to <?= $cap ?> per stat).</p>
      </div>
    </section>

<?php elseif ($tab === 'folk'):   // V2: the polaroid wall
    $selN = (int)($_GET['n'] ?? 0);
    $fr = [];
    foreach (q('SELECT * FROM npc_friends WHERE user_id = ?', [$uid])->fetchAll() as $r) $fr[(int)$r['npc_id']] = $r;
    $met = [];
    foreach (q('SELECT npc_id FROM user_npc_met WHERE user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN) as $nid) $met[(int)$nid] = 1;
    $npcs = q('SELECT * FROM npcs WHERE active = 1 ORDER BY name')->fetchAll();
    $isMet = fn(array $n): bool => isset($met[(int)$n['id']]) || isset($fr[(int)$n['id']]);
    $metN = count(array_filter($npcs, $isMet));
    $hearts = function (int $pts): string { $idx = 0; foreach (FRIEND_LEVELS as $i => $lv) if ($pts >= $lv[0]) $idx = $i; return str_repeat('♥', $idx) . str_repeat('♡', count(FRIEND_LEVELS) - 1 - $idx); };
    $selNpc = null; foreach ($npcs as $n) if ((int)$n['id'] === $selN) $selNpc = $n; ?>
    <section class="box" id="folkcard">
      <div class="palhead"><h2>💛 Villagers you know</h2><span class="muted"><b><?= $metN ?></b> met of <?= count($npcs) ?></span></div>
      <p class="help">Open a snapshot to see everything you know about them.</p>
      <?php if ($selNpc && $isMet($selNpc)): $f = $fr[(int)$selNpc['id']] ?? ['points' => 0, 'known' => '[]']; $lv = friend_level((int)$f['points']); $tastes = known_tastes($f, $selNpc); ?>
        <div class="folkcard" aria-live="polite">
          <div class="polaroid big"><?= npc_portrait($selNpc, 'small') ?></div>
          <div class="grow"><h3><?= e($selNpc['name']) ?></h3><p class="muted"><?= e((string)$selNpc['species']) ?></p>
            <p><span class="hearts" aria-hidden="true"><?= $hearts((int)$f['points']) ?></span> <?= e($lv['name']) ?><?= $lv['discount'] ? ' · ' . (int)$lv['discount'] . '% off' : '' ?></p>
            <p><b>You know:</b> <?= e($tastes ? implode(' · ', $tastes) : 'Nothing yet. Talk to them or bring a gift.') ?></p>
            <p><a class="btn small" href="<?= e(url('folk.php?id=' . (int)$selNpc['id'])) ?>">Go and visit</a> <a class="btn small ghost" href="<?= e($gurl('folk')) ?>">Close</a></p></div>
        </div>
      <?php elseif ($selNpc): ?><div class="folkcard"><div class="polaroid big qp" aria-hidden="true">?</div><div class="grow"><b>Not met yet.</b><br>Look for them in the villages and towns you visit.<p><a class="btn small ghost" href="<?= e($gurl('folk')) ?>">Close</a></p></div></div><?php endif; ?>
      <div class="wall">
        <?php foreach ($npcs as $i => $n): $m = $isMet($n); $pts_ = (int)($fr[(int)$n['id']]['points'] ?? 0); ?>
          <a class="polaroid r<?= $i % 5 ?><?= $m ? '' : ' unmet' ?><?= (int)$n['id'] === $selN ? ' on' : '' ?>" href="<?= e($gurl('folk', ['n' => (int)$n['id']], '#folkcard')) ?>"><span class="tape" aria-hidden="true"></span>
            <?php if ($m): ?><?= npc_portrait($n, 'small') ?><span class="hand"><?= e($n['name']) ?></span><small class="muted"><span class="hearts" aria-hidden="true"><?= $hearts($pts_) ?></span> <?= e(friend_level($pts_)['name']) ?></small>
            <?php else: ?><span class="qp" aria-hidden="true">?</span><span class="hand muted">Not met yet</span><?php endif; ?></a>
        <?php endforeach; ?>
      </div>
      <p class="help">Friend 5% off · Good friend 8% · Best friend 12% in the shop where they work. <a href="<?= e(url('town.php?view=villagers')) ?>">Where everyone is now →</a></p>
    </section>

<?php elseif ($tab === 'gardens'): ?>
    <section class="box">
      <h2>🏡 Your gardens <small class="muted"><?= count($gardens) ?> of <?= max_gardens($u) ?></small></h2>
      <div class="gardgrid">
        <?php foreach ($gardens as $g): ?>
          <div class="gardcard<?= (int)$g['id'] === active_plot_id($uid) ? ' on' : '' ?>"><b><?= e($g['garden_name'] ?: 'Garden') ?></b> <small class="muted"><?= e((string)($g['region'] ?? '')) ?></small><br>
            <small>Garden level <?= (int)$g['garden_level'] ?> · <?= (int)$g['width'] ?>×<?= (int)$g['height'] ?></small><br>
            <?php if ((int)$g['id'] === active_plot_id($uid)): ?><small class="good">Tending now</small> · <?php endif; ?><a href="<?= e(url('garden.php')) ?>">Open garden →</a></div>
        <?php endforeach; ?>
        <?php if (count($gardens) < max_gardens($u)): ?><div class="gardcard empty"><b>Room for another garden</b><br><small class="muted">Start one in a village you have visited.</small></div><?php endif; ?>
      </div>
    </section>

<?php elseif ($tab === 'calling'): ?>
<?php if ((int)$u['level'] < $callingLevel): ?>
<div class="box callinglock" id="calling"><p>🎩 Your <b>calling</b> unlocks at gnome level <?= $callingLevel ?>: your gnome’s path in life, with its own hat and perks.</p></div>
<?php else: ?>
<?php $myTier = calling_tier($u); $t2 = (int)setting('calling_tier2_level'); $t3 = (int)setting('calling_tier3_level');
      $canChange = calling_can_change($u); $changeCost = calling_change_cost($u);   // v0.9.1a ?>
<details class="fold box" id="calling" open><summary>🎩 Calling<?= $u['calling'] ? ': ' . e(trim(calling_tier_name($myTier) . ' ' . CALLINGS[$u['calling']][0])) : ' (ready to choose!)' ?></summary>
  <?php if (!$u['calling']): ?>
    <div class="flash ok">🎩 You’re ready to choose your calling! Choose well: changing it later costs Petals (<?= (int)setting('calling_change_cost') ?> the first time, doubling each time).</div>
  <?php else: ?>
    <p>You are a <b><?= e(calling_tier_name($myTier)) ?> <?= e(CALLINGS[$u['calling']][0]) ?></b>.
      <?= $myTier < 3 ? 'Your calling grows stronger at gnome level ' . ($myTier < 2 ? $t2 : $t3) . ' once you finish ' . ($myTier < 2 ? 'its Journeyman' : 'its Master') . ' chapter with your calling’s mentor.' : 'You’ve mastered your calling.' ?>
      <?= $changeCost > 0 ? 'Changing your calling costs ' . $changeCost . ' Petals.' : 'You have one free change.' ?></p>
    <?php require_once __DIR__ . '/includes/calling_view.php'; echo calling_gnome_line($u);   // v0.9.4: mentor and chapter ?>
  <?php endif; ?>
  <p class="help">Each calling has three tiers: 🎩 Apprentice (level <?= $callingLevel ?>), 🎗️ Journeyman (level <?= $t2 ?> and a chapter) and ⭐ Master (level <?= $t3 ?> and a chapter). Each chapter is a set of tasks for your calling’s mentor. Each tier keeps what the one before gave.</p>
  <div class="callings">
    <?php $foldOpen = false; $list = CALLINGS;
    if ($u['calling'] && isset($list[$u['calling']])) $list = [$u['calling'] => $list[$u['calling']]] + $list;   // v0.9.1a: yours first
    foreach ($list as $key => [$name, $hat, $color, $tag, $garden, $adventure]):
        $mine = $u['calling'] === $key;
        if ($u['calling'] && !$mine && !$foldOpen) { $foldOpen = true; echo '</div><details class="fold"><summary>Other callings</summary><div class="callings">'; }   // v0.9.1a: only your own card up front
        $tiers = array_map('trim', explode('·', preg_replace('/^\s*I:\s*/', '', $garden)));   // "I: … · II: … · III: …" ?>
      <div class="calling box<?= $mine ? ' mine' : '' ?>">
        <?= gnome_hat(['calling' => $key]) ?>
        <h3><?= e($name) ?> <small class="muted"><?= e($hat) ?> hat</small></h3>
        <p><i><?= e($tag) ?></i></p>
        <ol class="ctiers">
          <?php foreach ($tiers as $n => $txt): $tn = $n + 1; $txt = preg_replace('/^I{1,3}:\s*/', '', $txt); ?>
            <li class="<?= $mine && $myTier >= $tn ? 'got' : '' ?>"><b><?= ['', '🎩 Apprentice', '🎗️ Journeyman', '⭐ Master'][$tn] ?? '' ?></b> <small class="muted">(level <?= [1 => $callingLevel, 2 => $t2, 3 => $t3][$tn] ?? '' ?><?= $tn > 1 ? ' + chapter' : '' ?>)</small>: <?= e(rtrim($txt, '.')) ?>.</li>
          <?php endforeach; ?>
        </ol>
        <p>⚔️ <b>Adventure:</b> <?= e($adventure) ?></p>
        <?php if (!$mine && (!$u['calling'] || $canChange)): ?>
          <form method="post" data-confirm="Become a <?= e($name) ?>?<?= $u['calling'] ? ($changeCost > 0 ? ' This costs ' . $changeCost . ' Petals.' : ' This uses your one free change.') : ' Changing it later costs Petals.' ?>">
            <?= csrf_field() ?><input type="hidden" name="do" value="calling"><input type="hidden" name="calling" value="<?= e($key) ?>">
            <button class="btn small"><?= $u['calling'] ? ($changeCost > 0 ? 'Switch (' . $changeCost . ' Petals)' : 'Switch (free, once)') : 'Choose' ?></button></form>
        <?php elseif ($mine): ?><p class="good">✔ Your calling<?= $myTier ? ' · ' . e(calling_tier_name($myTier)) : '' ?></p><?php endif; ?>
      </div>
    <?php endforeach; ?>
    <?= $foldOpen ? '</div></details><div>' : '' ?>
  </div>
</details>
<?php endif; ?>
<?php endif; ?>
  </div>
</div>
</div>
<?php page_footer();
