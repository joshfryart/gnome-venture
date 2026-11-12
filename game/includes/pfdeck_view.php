<?php
declare(strict_types=1);
/**
 * Puzzle combat v1, the PAGES (2.6.74 stage C, behind the admin setting pfight_v1; handover: claude/handover-v1-stageC.md).
 * The Puzzle box (puzzlebox.php), the starter pick, the pre-fight screen and the result card. The model is includes/pfdeck.php (stage B), the board rules includes/pfboard.php (stage A).
 * Ported from the approved mockups: claude/mockups/deckbuilder-ingame.html and tools/pfdemo_v1/ (app.js). CSS: assets/pfv1.css. Script: assets/pfv1box.js (pieces are drawn by assets/pfparts.js).
 * No inline styles or scripts (CSP): widths travel as data-w / data-f and the script sets them.
 */
require_once __DIR__ . '/pfight_game.php';
require_once __DIR__ . '/pfdeck.php';

const PFV_TYPE = ['hurt' => 'Hurt', 'guard' => 'Guard', 'heal' => 'Heal', 'charm' => 'Charm', 'soothe' => 'Soothe', 'trick' => 'Trick', 'item' => 'Item'];
const PFV_CLASS_ICON = ['Critter' => '🐛', 'Bird' => '🐦', 'Beast' => '🐾', 'Reptile/Amphibian' => '🦎', 'Water' => '🐟', 'Plant/Fungus' => '🍄'];
const PFV_SRC_ICON = ['basic' => '🧩', 'knack' => '🧩', 'calling' => '🎩', 'crop' => '🌾', 'craft' => '🛠️', 'region' => '🗺️', 'tool' => '🔧', 'pal' => '🐾'];
/** What a creature's tag does to you (the player's own tags read PF_TAGS). */
const PFV_FOE_TAG = ['quick' => 'Quick: it plays one more piece this turn', 'evade' => 'Evade: your next hit on it misses', 'bash' => 'Bash: adds its guard to its next hit', 'poison' => 'Poison: 2 ticks on your health',
    'trip' => 'Trip: you draw 1 fewer next round', 'heal' => 'Recovers a little', 'thorns' => 'Thorns: hitting its guard pricks you', 'hold' => 'Hold: this guard lasts a turn longer', 'pierce' => 'Pierce: ignores your guard'];

/** The v1 pages are on for this gnome. */
function pfv_on(array $u): bool
{
    return pfight_on($u) && pfight_v1_on($u) && !is_guest($u);
}

/** The stylesheet, the data the piece renderer needs, and the scripts (once per page; data-rerun so they run again when the adventure page swaps its content in place). */
function pfv_assets(bool $withData = true): string
{
    $h = '<link rel="stylesheet" href="' . e(url('assets/pfight.css?v=' . APP_VERSION)) . '"><link rel="stylesheet" href="' . e(url('assets/pfv1.css?v=' . APP_VERSION)) . '">';
    if ($withData) $h .= '<i id="pfight" hidden></i><script type="application/json" id="pf-data">' . json_encode(['art' => url('assets/img/pfight/'), 'parts' => is_file(__DIR__ . '/../assets/img/pfight/parts/atlas.json') ? url('assets/img/pfight/parts/') : null, 'mods' => (object)[]], JSON_HEX_TAG | JSON_HEX_AMP) . '</script>'
        . '<script src="' . e(url('assets/pfparts.js?v=' . APP_VERSION)) . '" data-rerun defer></script>';
    return $h . '<script src="' . e(url('assets/pfv1box.js?v=' . APP_VERSION)) . '" data-rerun defer></script>';
}

/** The values the gnome's pieces play for: deck entries (pfd_build 'pieces') => the same entries with 'v' as in a fight and 'e' (the four edges). */
function pfv_entries(array $u, array $entries): array
{
    [$st, , $bonus] = pfight_calc($u);
    $src = ['calling' => (string)($u['calling'] ?? ''), 'ctier' => max(1, min(3, (int)calling_tier($u)))];
    foreach ($entries as $i => $en) {
        $t = pfd_tiles([$en], $st, $bonus, $src['calling'], $src['ctier'], true)[0] ?? null;
        $entries[$i]['v'] = (int)($t['v'] ?? $en['v']); $entries[$i]['e'] = pfd_edges($en);
    }
    return $entries;
}

/** The one-line description of a player piece (the detail line under a grid). */
function pfv_desc(array $p, string $extra = ''): string
{
    $tg = PF_TAGS[(string)($p['tag'] ?? '')] ?? null;
    return (PFV_TYPE[$p['t']] ?? ucfirst((string)$p['t'])) . ' ' . (int)$p['v'] . (!empty($p['rank']) ? ' · ' . PFD_RANK_NAME[(int)$p['rank']] : '') . ' · stays ' . (int)$p['life'] . ' rounds'
        . (in_array($p['src'] ?? '', PFB_TEAM_SRC, true) ? ' · Teamwork: ' . $p['src'] : '') . ($extra !== '' ? ' · ' . $extra : '')
        . ($tg ? '. ' . $tg[1] : '') . (($p['blurb'] ?? '') !== '' ? '. ' . rtrim((string)$p['blurb'], '.') : '') . '.';
}

/**
 * One piece cell (the mockup's .pc): art (drawn by the script from data-p), value, tag icon, name, expiry pips; border = rank, dashed = gear.
 * $o: cls, a (action for the script: tog | info | spick), arg, owner (me | foe), name (false = none), d (detail text), x (extra attributes, already escaped).
 */
function pfv_pc(array $p, array $o = []): string
{
    $life = max(1, (int)($p['life'] ?? 3)); $px = str_repeat('<i></i>', $life);
    $tg = PF_TAGS[(string)($p['tag'] ?? '')] ?? null; $own = (string)($o['owner'] ?? 'me');
    $art = json_encode(['t' => $p['t'], 'e' => $p['e'], 'tag' => $tg ? (string)$p['tag'] : '', 'o' => $own], JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT);
    $label = $p['n'] . ', ' . (PFV_TYPE[$p['t']] ?? $p['t']) . ' ' . (int)$p['v'] . (($p['tag'] ?? '') !== '' && ($p['tag'] ?? '') !== 'pal' ? ', ' . $p['tag'] : '') . (!empty($p['rank']) ? ', ' . PFD_RANK_NAME[(int)$p['rank']] : '') . ', stays ' . $life . ' rounds';
    return '<li' . (isset($o['g']) ? ' data-g="' . e((string)$o['g']) . '"' : '') . '><button type="button" class="pc' . (!empty($p['rank']) ? ' r' . (int)$p['rank'] : '') . (!empty($p['gear']) ? ' gear' : '') . (($o['cls'] ?? '') !== '' ? ' ' . e((string)$o['cls']) : '') . '"'
        . (isset($o['a']) ? ' data-a="' . e((string)$o['a']) . '" data-arg="' . e((string)($o['arg'] ?? $p['key'] ?? '')) . '"' : '') . ' data-n="' . e((string)$p['n']) . '" data-d="' . e((string)($o['d'] ?? '')) . '" data-t="' . e((string)$p['t']) . '"' . ($o['x'] ?? '')
        . ' aria-label="' . e($label) . '"><i class="cvh" data-p="' . e($art) . '"></i><span class="pc-v" aria-hidden="true">' . (int)$p['v'] . '</span>'
        . ($tg ? '<span class="pc-t" aria-hidden="true">' . $tg[0] . '</span>' : (isset(PFV_SRC_ICON[$p['src'] ?? '']) && in_array($p['src'], ['pal', 'tool', 'crop'], true) ? '<span class="pc-t" aria-hidden="true">' . PFV_SRC_ICON[$p['src']] . '</span>' : ''))
        . (($o['name'] ?? true) === false ? '' : '<span class="pc-n">' . e((string)$p['n']) . '</span>') . '<span class="pc-x' . ($life < 3 ? ' few' : '') . '" aria-hidden="true">' . $px . '</span></button></li>';
}

function pfv_slot(string $txt): string { return '<li><div class="slot">' . $txt . '</div></li>'; }

function pfv_cap_pips(int $n, int $max, string $cls, string $lab): string
{
    $h = ''; for ($i = 0; $i < $max; $i++) $h .= '<i' . ($i < $n ? ' class="on"' : '') . '></i>';
    return '<span class="capp ' . $cls . '" role="img" aria-label="' . $lab . ' ' . $n . ' of ' . $max . '" title="' . $lab . ' ' . $n . ' of ' . $max . '">' . $h . '</span>';
}

function pfv_durbar(int $left, int $max): string
{
    $f = $max > 0 ? $left / $max : 0;
    return '<span class="dur' . ($left <= 0 ? ' zero' : ($f <= .25 ? ' crit' : ($f <= .5 ? ' low' : ''))) . '" role="img" aria-label="Durability ' . $left . ' of ' . $max . '"><i data-w="' . (int)round($f * 100) . '"></i></span>';
}

/** The deck bar: size with stacked sources, the Teamwork sources, and the harmony meter (link rate, hand links, the knob families). */
function pfv_deckbar(array $d, bool $slim = false): string
{
    $c = $d['counts']; $kit = (int)$c['kit'];
    $h = '<div class="meter" role="img" aria-label="Deck ' . (int)$c['n'] . ': kit ' . $kit . ', belt ' . (int)$c['belt'] . ', pals ' . (int)$c['pals'] . '"><b>' . (int)$c['n'] . '</b><span class="stack"><span class="k" data-f="' . max(1, $kit) . '">🧩 ' . $kit . '</span>'
        . ($c['belt'] ? '<span class="b" data-f="' . (int)$c['belt'] . '">🔧 ' . (int)$c['belt'] . '</span>' : '') . ($c['pals'] ? '<span class="p" data-f="' . (int)$c['pals'] . '">🐾 ' . (int)$c['pals'] . '</span>' : '') . '</span></div>';
    $h .= '<div class="teamrow"><b>Teamwork</b>';
    foreach (['pal' => '🐾', 'tool' => '🔧', 'crop' => '🌾'] as $k => $ic) $h .= '<span class="chip' . ($c['src'][$k] ? '' : ' off') . '">' . $ic . ' ' . $k . ' ' . (int)$c['src'][$k] . '</span>';
    $h .= '<span>' . ($c['team'] >= 3 ? '2 in a chain +30%, all 3 +60%' : ($c['team'] === 2 ? 'both in one chain: +30%' : 'needs 2 of 3 sources')) . '</span></div>';
    if ($slim) return $h;
    $hm = $d['harmony'] ?? pfd_harmony($d['deck']); $f = $hm['fam']; $tot = max(1, array_sum($f)); $top = max($f) / $tot; $lk = (int)round($hm['link'] * 100); $hd = (int)round($hm['hand'] * 100);
    $seg = ''; foreach (PFD_FAM as $k) if ($f[$k]) $seg .= '<span class="' . $k . '" data-f="' . (int)$f[$k] . '">' . $k . ' ' . (int)round(100 * $f[$k] / $tot) . '%</span>';
    $h .= '<div class="harm" role="img" aria-label="Deck harmony: link rate ' . $lk . ' percent, a hand links ' . $hd . ' percent of the time"><b>Link rate</b><span class="hmeter' . ($lk >= 30 ? ' good' : ($lk >= 22 ? '' : ' low')) . '"><i data-w="' . min(100, $lk * 2) . '"></i><span>' . $lk . '%</span></span><span class="chip" title="Chance that a hand of 5 has a piece that links">hand links ' . $hd . '%</span></div>'
        . '<div class="harm"><b>Knobs</b><span class="stack fam">' . $seg . '</span></div>'
        . '<p class="hint harmhint">' . ($top >= 0.5 ? 'One family leads: easy chains, less Teamwork.' : 'Mixed families: more Teamwork, fewer links.') . ' Pals are body, tools craft, crops mind.</p>';
    return $h;
}

/** The hidden form the script fills in and sends (switch a piece, a tool, auto-use). $back: extra hidden fields. */
function pfv_form(string $back = ''): string
{
    return '<form method="post" id="pfv-f" hidden>' . csrf_field() . '<input type="hidden" name="do" value=""><input type="hidden" name="key" value=""><input type="hidden" name="on" value=""><input type="hidden" name="tool" value="">' . $back . '</form>';
}

/** The "Auto-use my current deck" switch (a form of its own: it works without script through its button). */
function pfv_auto_html(bool $on, string $back = ''): string
{
    return '<form method="post" class="pfv-autof">' . csrf_field() . '<input type="hidden" name="do" value="pfd_auto"><input type="hidden" name="on" value="' . ($on ? '0' : '1') . '">' . $back
        . '<label class="sw"><input type="checkbox" id="pfv-auto"' . ($on ? ' checked' : '') . '>Auto-use my current deck<span class="chip">' . ($on ? 'on' : 'off') . '</span></label><noscript><button class="btn small">' . ($on ? 'Turn off' : 'Turn on') . '</button></noscript></form>';
}

// ================================================================= 1. the starter pick

/** First-time flow: 4 core pieces + pick 6 of the 12 offered, or a one-tap kit. Posts do=pfd_starter (pick[] x6, or kit=NAME without script) to the page it is on. */
function pfv_starter_html(array $u, array $d, bool $inFight = false): string
{
    $src = pfd_sources($u); $offer = $d['offer']; $old = pbox_load((int)$u['id']) ?? [];
    $mk = function (string $key) use ($src): ?array {
        $p = pfd_piece($key); if (!$p) return null;
        $rank = $p['rar'] === 'src' ? 1 : (int)$p['rar'];
        return ['key' => $key, 'k' => $p['k'], 'n' => $p['n'], 't' => $p['t'], 'v' => (int)$p['v'], 'r' => $p['r'], 'tag' => (string)$p['tag'], 'src' => $p['src'], 'ref' => (string)($p['ref'] ?? ''), 'rank' => $rank,
            'life' => (int)($p['life'] ?? 0) ?: ($p['tag'] === 'quick' ? 2 : ($p['tag'] === 'hold' ? 4 : PFB_LIFE)), 'blurb' => (string)($p['blurb'] ?? ''), 'gear' => false, 'tool' => ''] + (isset($p['col']) ? ['col' => $p['col']] : []) + (isset($p['up']) ? ['up' => $p['up']] : []);
    };
    $core = pfv_entries($u, array_values(array_filter(array_map($mk, PFD_CORE)))); $off = pfv_entries($u, array_values(array_filter(array_map($mk, $offer))));
    $pre = array_values(array_filter($offer, fn($k) => in_array(explode('#', $k)[0], $old, true) && $k !== 'swing#2'));   // an old Puzzle box (before 2.6.74): its pieces that are on offer start picked
    $pre = array_slice($pre, 0, PFD_PICKS);
    $tray = '';
    foreach ($core as $p) $tray .= pfv_pc($p, ['cls' => 'lock', 'name' => false, 'a' => 'info', 'd' => pfv_desc($p, 'core, always in')]);
    for ($i = 0; $i < PFD_PICKS; $i++) $tray .= '<li class="pfv-ps" data-i="' . $i . '"><div class="slot">' . ($i + 5) . '</div></li>';
    $grid = '';
    foreach ($off as $p) $grid .= pfv_pc($p, ['a' => 'spick', 'd' => pfv_desc($p), 'cls' => in_array($p['key'], $pre, true) ? 'sel' : '']);
    $kits = '';
    foreach (['bold' => '⚔️ Bold', 'steady' => '🛡️ Steady', 'kind' => '💗 Kind'] as $k => $lbl) $kits .= '<button class="btn" name="kit" value="' . $k . '" data-kit="' . e(implode(',', $d['kits'][$k])) . '">' . $lbl . '</button>';
    $pp = str_repeat('<i></i>', PFD_PICKS);
    return '<div class="box pbox pfv" id="pfv-starter" data-picks="' . PFD_PICKS . '">'
        . '<div class="hrow"><h2>🧩 Pack your box</h2><span class="chip warn" id="pfv-hurt" title="Hurt pieces (at least 2)">⚔️ <b>1</b></span><span class="chip"><b id="pfv-n">4</b>/10</span></div>'
        . ($inFight ? '<p class="note">A creature is waiting. Pack your first Puzzle box, then you meet it.</p>' : '')
        . '<form method="post" id="pfv-sform">' . csrf_field() . '<input type="hidden" name="do" value="pfd_starter">'
        . '<ul class="pcg c5" id="pfv-tray" aria-label="Your box: 10 slots">' . $tray . '</ul>'
        . '<div class="kits" role="group" aria-label="Quick kits">' . $kits . '</div>'
        . '<div class="sl">Pick 6 <span class="pips" id="pfv-pips" role="img" aria-label="0 of 6">' . $pp . '</span></div><ul class="pcg" id="pfv-offer">' . $grid . '</ul>'
        . '<div class="pinfo" id="pfv-info" aria-live="polite"><span>Tap a piece to pick it, or take a kit.</span></div>'
        . '<span id="pfv-picks"></span><div class="actrow"><button class="btn primary grow" id="pfv-sgo" disabled>🧩 Pack the box</button></div></form></div>';
}

// ================================================================= 2. the Puzzle box page

/** The whole Puzzle box page body (puzzlebox.php, v1 on). $tab: kit | belt | pals. */
function pfv_box_html(array $u, string $tab = 'kit'): string
{
    $d = pfd_deck($u); $uid = (int)$u['id'];
    if (!$d['starter']) return pfv_starter_html($u, $d) . pfv_assets();
    if (!in_array($tab, ['kit', 'belt', 'pals'], true)) $tab = 'kit';
    $c = $d['counts']; $locked = !empty($d['locked']); $P = pfv_entries($u, $d['pieces']); $mods = pfight_mods($uid);
    $back = '<input type="hidden" name="t" value="' . $tab . '">';
    $h = '<div class="box pbox pfv" id="pfv-box"' . ($locked ? ' data-locked="1"' : '') . '><div class="hrow"><h2>🧩 Puzzle box</h2>' . pfv_cap_pips((int)$c['rare'], PFD_RARE_CAP, '', 'Rare') . pfv_cap_pips((int)$c['mw'], PFD_MW_CAP, 'mw', 'Masterwork') . '</div>';
    $h .= '<nav class="tabs" aria-label="Puzzle box">';
    foreach (['kit' => 'Kit', 'belt' => 'Belt', 'pals' => 'Pals'] as $k => $l) $h .= '<a href="' . e(url('puzzlebox.php' . ($k === 'kit' ? '' : '?t=' . $k))) . '"' . ($k === $tab ? ' class="on" aria-current="page"' : '') . '>' . $l . '</a>';
    $h .= '</nav>' . pfv_deckbar($d);
    if ($locked) $h .= '<p class="note">🔒 You are in a fight. The deck is locked until it is over. <a href="' . e(url('adventure.php')) . '">Back to the fight</a></p>';
    $hint = 'Tap a piece to read it.';
    if ($tab === 'kit') {
        $grp = fn(array $p): string => in_array($p['src'], ['knack', 'calling'], true) ? 'basic' : (string)$p['src'];
        $h .= '<nav class="chips fbar" id="pfv-filt" aria-label="Filter by source">';
        foreach (['all' => 'All', 'basic' => '🧩', 'crop' => '🌾', 'craft' => '🛠️', 'region' => '🗺️'] as $k => $l) $h .= '<button type="button" data-g="' . $k . '"' . ($k === 'all' ? ' class="on"' : '') . ' aria-label="' . ($k === 'all' ? 'All pieces' : ucfirst($k) . ' pieces') . '" aria-pressed="' . ($k === 'all' ? 'true' : 'false') . '">' . $l . '</button>';
        $h .= '</nav>';
        $in = ''; $col = '';
        foreach ($P as $p) {
            if ($p['gear']) continue;
            $md = isset($mods[$p['k']]) ? (PF_MODS[$mods[$p['k']]] ?? null) : null;
            $x = ($md ? 'upgrade ' . $md[0] : '');
            if ($p['on']) $in .= pfv_pc($p, ['cls' => 'sel' . ($p['out'] !== '' ? ' out' : ''), 'a' => $locked ? 'info' : 'tog', 'g' => $grp($p), 'd' => pfv_desc($p, trim(($p['out'] !== '' ? 'left out: over the rarity cap' : ($p['core'] ? 'core' : '')) . ($x !== '' ? ' · ' . $x : ''), ' ·')), 'x' => ' data-on="1"']);
            else $col .= pfv_pc($p, ['a' => $locked ? 'info' : 'tog', 'g' => $grp($p), 'd' => pfv_desc($p, $x), 'x' => ' data-on="0"']);
        }
        $h .= '<div class="sl">In the kit <span>' . ((int)$c['kit'] < PFD_KIT_MIN ? (int)$c['kit'] . ' · need ' . PFD_KIT_MIN : (int)$c['kit'] . ' · no maximum') . '</span></div><ul class="pcg pfv-g">' . ($in ?: pfv_slot('none')) . '</ul>'
            . '<div class="sl">Collection <span>' . ($locked ? 'locked' : 'tap to pack') . '</span></div><ul class="pcg pfv-g">' . ($col ?: pfv_slot('none')) . '</ul>';
        $hint = $locked ? 'Tap a piece to read it.' : 'Tap a piece, then pack it or take it out.';
    } elseif ($tab === 'belt') {
        $wear = pfd_wear($u); $tier = (int)($d['belt_tier'] ?? 1); $slots = (int)$d['slots']; $onBelt = [];
        $kit = item_id_by_slug(PFD_REPAIR); $kits = $kit ? (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $kit]) : 0;
        $h .= '<div class="chips seg pfv-tier" role="img" aria-label="Fight belt tier ' . $tier . ': ' . $slots . ' tool slots">';
        foreach (PFD_BELTS as $t => [$n]) $h .= '<span' . ($t === $tier ? ' class="on"' : '') . '>Belt ' . ['', 'I', 'II', 'III'][$t] . ' · ' . $n . '</span>';
        $h .= '</div>';
        $bs = '';
        foreach ($d['belt'] as $i => $b) { if ($i >= 4) break;
            $onBelt[$b['type']] = $b['state'];
            $p = null; foreach ($P as $q) if ($q['tool'] === $b['type']) $p = $q;
            if ($p && $b['state'] === 'ok') $bs .= str_replace(['<li>', '</li>'], ['<li class="bslot">', pfv_durbar((int)$b['left'], (int)$b['max']) . '<small>' . (int)$b['left'] . '/' . (int)$b['max'] . '</small></li>'], pfv_pc($p, ['a' => 'info', 'd' => pfv_desc($p, 'durability ' . (int)$b['left'] . '/' . (int)$b['max'] . ', −' . PFB_TOOL_WEAR . ' a play')]));
            else $bs .= pfv_slot($b['state'] === 'broken' ? 'broken' : ($b['state'] === 'over' ? 'no slot' : 'gone'));
        }
        for ($i = count($d['belt']); $i < 4; $i++) $bs .= pfv_slot($i >= $slots ? 'locked<br>Belt ' . ($i === 2 ? 'II' : 'III') : '＋');
        $h .= '<div class="sl">On the belt <span>each adds its piece · −' . PFB_TOOL_WEAR . ' durability a play</span></div><ul class="pcg">' . $bs . '</ul>';
        $h .= '<div class="sl">Tools <span>🧰 repair kits: ' . $kits . '</span></div><ul class="tools">';
        $full = count(array_filter($onBelt, fn($s) => $s === 'ok')) >= $slots; $any = false;
        foreach ($wear as $type => $w) {
            if ((int)$w['tier'] < 1 || !isset(pfd_catalog()['t:' . $type])) continue; $any = true;
            $pn = (string)pfd_catalog()['t:' . $type]['n']; $tt = TOOL_TYPES[$type] ?? [ucfirst($type), '🔧']; $on = ($onBelt[$type] ?? '') === 'ok'; $bk = !empty($w['broken']);
            $f = fn(string $do, string $lbl, string $cls, string $aria, bool $dis = false) => '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="' . $do . '"><input type="hidden" name="tool" value="' . e($type) . '">' . $back . '<button class="btn' . $cls . '" aria-label="' . e($aria) . '"' . ($dis ? ' disabled' : '') . '>' . $lbl . '</button></form>';
            $h .= '<li class="toolrow t' . (int)$w['tier'] . ($bk ? ' broken' : '') . '"><span class="ti" aria-hidden="true">' . $tt[1] . '</span><span class="tx"><b>' . e($pn) . ' <small>' . (int)$w['left'] . '/' . (int)$w['max'] . '</small></b><small class="tsub">' . e($tt[0]) . ' tool · ' . PFD_RANK_NAME[(int)$w['tier']] . '</small>' . pfv_durbar((int)$w['left'], (int)$w['max']) . '</span>'
                . ($bk || (int)$w['wear'] > 0 && !$on ? $f('pfd_fix', '🔧 Fix', ' gold', 'Fix ' . $pn . ' with a Tool Repair Kit', $kits < 1) : '')
                . ($bk ? '' : ($on ? ((int)$w['wear'] > 0 ? $f('pfd_fix', '🔧 Fix', ' gold', 'Fix ' . $pn . ' with a Tool Repair Kit', $kits < 1) : '') . $f('pfd_unequip', 'Take off', ' ghost', 'Take ' . $pn . ' off the belt', $locked) : $f('pfd_equip', $full ? 'Belt full' : 'Put on', '', 'Put ' . $pn . ' on the belt', $locked || $full))) . '</li>';
        }
        $h .= ($any ? '' : '<li class="hint">No tools yet. A garden or gathering tool in your satchel can go on the belt.</li>') . '</ul>';
        $h .= '<p class="hint">' . ($tier < 3 ? 'A bigger belt holds more tools: <a href="' . e(url('shop.php')) . '">buy one at Twigg’s</a> (Belt II from level ' . PFD_BELTS[2][2] . ', Belt III from level ' . PFD_BELTS[3][2] . ').' : 'Your belt holds the most tools a belt can.')
            . ' A worn-out tool leaves the deck until you fix it with a Tool Repair Kit (crafted: flint, pine resin, coir fibre).</p>';
        $hint = 'Tap a belt piece to read it.';
    } else {
        $pl = '';
        foreach ($P as $p) if ($p['src'] === 'pal') $pl .= pfv_pc($p, ['cls' => 'sel' . ($p['out'] !== '' ? ' out' : ''), 'a' => 'info', 'd' => pfv_desc($p, 'in your party')]);
        $h .= '<div class="sl">Puzzle Pals <span>your party: ' . (int)$c['pals'] . ' · 1 piece each</span></div><ul class="pcg">' . ($pl ?: pfv_slot('none')) . '</ul>';
        require_once __DIR__ . '/puzzle_pals.php';
        $h .= '<p class="hint">' . (ppal_open() ? 'The pals you take along each add one piece. <a href="' . e(url('puzzlepals.php')) . '">Change your party in the Pal Book</a>' . ($locked ? ' (after the fight).' : '.') : 'Puzzle Pals are not open yet.') . '</p>';
        $hint = 'Tap a pal piece to read it.';
    }
    $h .= '<div class="pinfo" id="pfv-info" aria-live="polite" data-hint="' . e($hint) . '">' . ($d['err'] !== null ? '<span><b>' . e((string)$d['err']) . '</b> Until then a fight uses the standard kit.</span>' : '<span>' . e($hint) . '</span>') . '</div>';
    $h .= pfv_auto_html(!empty($d['auto']), $back) . '<p class="hint">' . (!empty($d['auto']) ? 'Auto deck is on: this deck goes into every fight as it is. You still see the creature first.' : 'Before each fight you can swap pieces. Nothing changes once the fight starts.') . '</p>';
    return $h . pfv_form($back) . '</div>' . pfv_assets();
}

// ================================================================= 3. the pre-fight screen

/** What a creature piece plays for on the board (the board's per-size factors: pfb_new). */
function pfv_foe_v(array $c, int $v): int
{
    $size = (string)($c['size'] ?? 'small');
    return max(1, (int)round($v * (PFB_V1_FOE_MULT[$size] ?? 1.0) * ($size === 'boss' ? PFB_BOSS_MULT : 1.0) * (PFB_FOE_FIRES > 0 ? PFB_FOE_FIRE_MULT : 1.0)));
}

/** The creature card: picture, class, region, size and board, temper; its pieces by layer (4 base / region / size or boss / 3 unique). */
function pfv_foe_card(array $c, string $region): string
{
    require_once __DIR__ . '/items.php';
    $row = pfd_foe_row($c, $region); $size = (string)($c['size'] ?? 'small'); $dims = PFB_SIZE[$size] ?? [5, 5]; $cl = (string)$row['class'];
    $cim = creature_image((string)($c['slug'] ?? ''), true);
    $img = $cim !== '' ? art_img($cim, 'lg', (string)$c['name']) : creature_icon((string)$c['name'], $size);
    $rn = $region !== '' ? (string)(q_val('SELECT gnomish_name FROM regions WHERE code = ?', [$region]) ?: $region) : '';
    $by = []; $cells = ''; $lean = (string)$row['lean'];
    foreach (pfd_foe_pieces($c, $region) as $p) {   // in layer order (a boss plays them in its own order)
        $by[$p['layer']] = ($by[$p['layer']] ?? 0) + 1; $v = pfv_foe_v($c, (int)$p['v']);
        $q = ['n' => $p['n'], 't' => $p['t'], 'v' => $v, 'tag' => $p['tag'], 'life' => $p['life'], 'src' => 'creature', 'e' => pfb_author_edges(['t' => $p['t'], 'r' => $p['r']], (string)$p['col'])];
        $d = (PFV_TYPE[$p['t']] ?? $p['t']) . ' ' . $v . ' · ' . PFD_LAYERS[$p['layer']] . ' · stays ' . (int)$p['life'] . ' rounds · plays ×' . PFB_FOE_FIRES . (isset(PFV_FOE_TAG[$p['tag']]) ? '. ' . PFV_FOE_TAG[$p['tag']] : '') . '.';
        $cells .= pfv_pc($q, ['owner' => 'foe', 'cls' => 'L-' . $p['layer'], 'a' => 'info', 'd' => $d, 'x' => ' data-info="pfv-cinfo"']);
    }
    $tally = '';
    foreach (PFD_LAYERS as $L => $name) if (!empty($by[$L])) $tally .= '<span class="L-' . $L . '" data-f="' . $by[$L] . '" title="' . e($name) . ' ' . $by[$L] . '">' . ($by[$L] < 2 ? '+' . $by[$L] : e(explode(' ', $name)[0]) . ' ' . $by[$L]) . '</span>';
    $charm = $size === 'boss' ? 'cannot be charmed' : (pf_temper($c) === 'gentle' ? 'gentle' : 'wary');
    return '<div class="foecard"><div class="pic">' . $img . '</div><div class="fx"><h3>' . e((string)$c['name']) . ' <small>lv ' . (int)$c['level'] . '</small></h3>'
        . '<div class="chips small"><span class="chip">' . (PFV_CLASS_ICON[$cl] ?? '🐾') . ' ' . e($cl) . '</span>' . ($rn !== '' ? '<span class="chip">' . e($rn) . '</span>' : '') . '<span class="chip"><i class="szd ' . e($size) . '"></i>' . e($size) . ' · ' . $dims[0] . '×' . $dims[1] . '</span><span class="chip">' . $charm . '</span><span class="chip">leans ' . e($lean) . '</span></div></div></div>'
        . '<div class="tally" role="img" aria-label="' . array_sum($by) . ' pieces in layers">' . $tally . '</div><ul class="pcg c5">' . $cells . '</ul>'
        . '<div class="pinfo" id="pfv-cinfo" aria-live="polite"><span>Tap one of its pieces. Each plays up to ' . PFB_FOE_FIRES . ' times.</span></div>';
}

/** The pre-fight screen (a creature is in front of you, the fight is not dealt yet): the creature card, your deck (read-only with Auto deck on, free swaps without), Let's fight. */
function pfv_prefight_html(array $u, array $exp, array $c): string
{
    $d = pfd_deck($u); $P = pfv_entries($u, $d['pieces']); $auto = !empty($d['auto']); $region = pfd_exp_region($exp);
    $deck = ''; $bench = ''; $n = 0;
    foreach ($P as $p) {
        if ($p['on'] && $p['out'] === '') { $n++; $deck .= pfv_pc($p, $auto ? ['cls' => 'fixed lock', 'a' => 'info', 'd' => pfv_desc($p, 'locked (Auto deck)')] : ['a' => $p['gear'] ? 'info' : 'tog', 'd' => pfv_desc($p, $p['gear'] ? 'gear: change it in the box' : ''), 'x' => ' data-on="1"']); }
        elseif (!$p['gear'] && !$auto) $bench .= pfv_pc($p, ['a' => 'tog', 'd' => pfv_desc($p, $p['out'] !== '' ? 'over the rarity cap' : ''), 'x' => ' data-on="' . ($p['on'] ? '1' : '0') . '"', 'cls' => $p['out'] !== '' ? 'out' : '']);
    }
    $h = '<div class="box pfv" id="pfv-pre">' . pfv_foe_card($c, $region);
    $h .= '<div class="sl">Your deck <span>' . $n . ' pieces · ❤️ ' . max(1, (int)$exp['hp']) . '/' . (int)$exp['max_hp'] . '</span></div>' . pfv_deckbar($d, true) . '<ul class="pcg c5">' . $deck . '</ul>';
    if (!$auto) $h .= '<div class="sl">Bench <span>tap to add</span></div><ul class="pcg c5">' . ($bench ?: pfv_slot('none')) . '</ul>';
    if ($auto) $h .= '<div class="pinfo" id="pfv-info" aria-live="polite" data-hint="Auto deck is active."><span><b>Auto deck is active.</b> Your saved deck goes in as it is.</span><form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="pfd_auto"><input type="hidden" name="on" value="0"><button class="btn ghost">Turn off and edit</button></form></div>';
    else $h .= '<div class="pinfo" id="pfv-info" aria-live="polite" data-hint="Tap a deck piece to take it out, a bench piece to add it.">' . ($d['err'] !== null ? '<span><b>' . e((string)$d['err']) . '</b> Until then the standard kit plays.</span>' : '<span>Tap a deck piece to take it out, a bench piece to add it. Nothing changes once the fight starts.</span>') . '</div>'
        . pfv_auto_html(false);
    $h .= '<div class="actrow"><a class="btn ghost" href="' . e(url('puzzlebox.php')) . '">🧩 Box</a><form method="post" class="grow pfv-gof">' . csrf_field() . '<input type="hidden" name="do" value="pfv_go"><button class="btn primary" id="pfv-go">⚔️ Let’s fight</button></form></div>';
    return $h . pfv_form() . '</div>' . pfv_assets();
}

/** The POST actions of the starter and pre-fight screens on the adventure page (do = pfd_* or pfv_go). The caller holds the transaction; $exp is saved by the caller. */
function pfv_adv_post(array $u, array &$exp, array $enc, string $do): void
{
    if (!empty($enc['pf'])) { if ($do !== 'pfd_auto') { flash('The fight has started. The deck is locked until it is over.', 'err'); return; } }
    if ($do === 'pfv_go') {
        if (!pfd_deck($u)['starter']) { flash('Pack your first Puzzle box before the fight.', 'err'); return; }
        $enc['pfgo'] = 1; $exp['encounter'] = json_encode($enc);
        return;
    }
    [$ok, $msg] = pfv_post($u, $do, $_POST);
    if (!$ok || $do === 'pfd_starter') flash($msg, $ok ? 'ok' : 'err');
}

/** pfd_post plus the one-time carry-over of an old Puzzle box (user_pbox, before 2.6.74): after the starter is packed, the pieces of the old box that are owned and not in it are switched on (as far as the caps allow). */
function pfv_post(array $u, string $do, array $in): array
{
    [$ok, $msg] = pfd_post($u, $do, $in);
    if ($ok && $do === 'pfd_starter') {
        $n = 0;
        foreach ((array)(pbox_load((int)$u['id']) ?? []) as $k) {
            foreach (pfd_deck($u)['pieces'] as $p) if ($p['key'] === (string)$k && !$p['on'] && !$p['gear'] && pfd_toggle($u, (string)$k, true) === null) $n++;
        }
        if ($n > 0) $msg .= ' ' . $n . ' more piece' . ($n === 1 ? '' : 's') . ' from your old box ' . ($n === 1 ? 'is' : 'are') . ' packed too.';
    }
    return [$ok, $msg];
}

// ================================================================= 5. the result card

/** Tool wear of a finished fight: [['type', 'n' (piece name), 'plays', 'cost', 'left', 'max', 'broke'], ...] from the fight's $s['wear'] (points) after it was saved. */
function pfv_wear_rows(array $u, array $s): array
{
    $rows = []; $w = pfd_wear($u);
    foreach ((array)($s['wear'] ?? []) as $type => $pts) {
        $pts = (int)$pts; if ($pts <= 0 || !isset(pfd_catalog()['t:' . $type])) continue;
        $x = $w[$type] ?? ['max' => pfd_dur_max(1), 'left' => 0, 'broken' => true, 'tier' => 1];
        $rows[] = ['type' => (string)$type, 'n' => (string)pfd_catalog()['t:' . $type]['n'], 'plays' => intdiv($pts, max(1, PFB_TOOL_WEAR)), 'cost' => $pts, 'left' => (int)$x['left'], 'max' => (int)$x['max'], 'broke' => !empty($x['broken']), 'tier' => max(1, (int)$x['tier'])];
    }
    return $rows;
}

/**
 * The result card. $r: ['how' => seen_off | charmed | defeat | run | stall, 'name', 'slug', 'size', 'hp', 'max', 'turns', 'wear' => pfv_wear_rows()].
 * $actions: buttons for the bottom row (already HTML).
 */
function pfv_result_html(array $r, string $actions = ''): string
{
    require_once __DIR__ . '/items.php';
    $name = e((string)$r['name']);
    $T = ['seen_off' => ['win', 'You won', 'The ' . $name . ' backs off.'], 'charmed' => ['charm', 'Charmed', 'You won the ' . $name . ' over: a better reward.'], 'defeat' => ['lose', 'Worn out', 'The ' . $name . ' sends you home to rest.'],
        'stall' => ['lose', 'It slipped away', 'The fight ran out of turns.'], 'run' => ['lose', 'You walked away', 'No reward this time.']][(string)$r['how']] ?? ['lose', 'Over', ''];
    $cim = creature_image((string)($r['slug'] ?? ''), true);
    $img = $cim !== '' ? art_img($cim, 'lg', (string)$r['name']) : creature_icon((string)$r['name'], (string)($r['size'] ?? 'small'));
    $w = '';
    foreach ((array)$r['wear'] as $x) {
        $tt = TOOL_TYPES[$x['type']] ?? [ucfirst((string)$x['type']), '🔧'];
        $w .= '<li class="toolrow t' . (int)$x['tier'] . ($x['broke'] ? ' broken' : '') . '"><span class="ti" aria-hidden="true">' . $tt[1] . '</span><span class="tx"><b>' . e((string)$x['n']) . ' <small>' . min((int)$x['max'], (int)$x['left'] + (int)$x['cost']) . ' → ' . (int)$x['left'] . '/' . (int)$x['max'] . '</small></b>' . pfv_durbar((int)$x['left'], (int)$x['max'])
            . '</span><span class="chip' . ($x['broke'] ? ' warn' : '') . '">' . ($x['broke'] ? 'broke · off the belt' : (int)$x['plays'] . ' × −' . PFB_TOOL_WEAR) . '</span></li>';
    }
    $broke = (bool)array_filter((array)$r['wear'], fn($x) => $x['broke']);
    $hp = max(0, (int)$r['hp']); $max = max(1, (int)$r['max']);
    return '<div class="box res pfv" id="pfv-res"><span class="resbadge badge-' . $T[0] . '">' . ($T[0] === 'lose' ? 'lost' : $T[0]) . '</span><h2>' . $T[1] . '</h2><div class="pic">' . $img . '</div><p class="big">' . $T[2] . '</p>'
        . '<div class="rows"><div class="row"><b>You</b><span class="gvbar"><i data-w="' . (int)round(100 * $hp / $max) . '"></i><span>' . $hp . '/' . $max . '</span></span></div>'
        . '<div class="row"><b>Fight</b><span>' . (int)$r['turns'] . ' turn' . ((int)$r['turns'] === 1 ? '' : 's') . '</span></div></div>'
        . '<div class="sl">Tool wear <span>' . PFB_TOOL_WEAR . ' durability each time its piece is played</span></div>' . ($w !== '' ? '<ul class="tools">' . $w . '</ul>' : '<p class="hint">No tool piece was played.</p>')
        . '<div class="actrow"><a class="btn' . ($broke ? ' gold' : ' ghost') . '" href="' . e(url('puzzlebox.php?t=belt')) . '">' . ($broke ? '🔧 Fix in the box' : '🧩 Puzzle box') . '</a>' . $actions . '</div></div>';
}

/** The summary of a fight that just ended (kept in the session by pfight_do for a loss, a run or a stall: the encounter is gone by the next page). Shown once. */
function pfv_result_take(): string
{
    $r = $_SESSION['pfv_res'] ?? null; unset($_SESSION['pfv_res']);
    if (!is_array($r) || (int)($r['at'] ?? 0) < time() - 900) return '';
    return pfv_result_html($r) . pfv_assets(false);
}
