<?php
declare(strict_types=1);
/**
 * Puzzle combat v1, the PAGES (2.6.74 stage C, behind the admin setting pfight_v1; handover: claude/handover-v1-stageC.md).
 * The Puzzle box (puzzlebox.php), the starter pick, the pre-fight screen and the result card. The model is includes/pfdeck.php (stage B), the board rules includes/pfboard.php (stage A).
 * Ported from the approved mockups: claude/mockups/deckbuilder-ingame.html and tools/pfdemo_v1/ (app.js). CSS: assets/pfv1.css. Script: assets/pfv1box.js (pieces are drawn by assets/pfparts.js).
 * No inline styles or scripts (CSP): widths travel as data-w / data-f and the script sets them.
 */
require_once __DIR__ . '/pfight_game.php';
require_once __DIR__ . '/pfparts_url.php';   // 2.6.89: the jigsaw parts kit or the old one
require_once __DIR__ . '/pfdeck.php';

const PFV_TYPE = ['hurt' => 'Hurt', 'guard' => 'Guard', 'heal' => 'Heal', 'charm' => 'Charm', 'soothe' => 'Soothe', 'trick' => 'Trick', 'item' => 'Item'];
const PFV_CLASS_ICON = ['Critter' => '🐛', 'Bird' => '🐦', 'Beast' => '🐾', 'Reptile/Amphibian' => '🦎', 'Water' => '🐟', 'Plant/Fungus' => '🍄'];
const PFV_SRC_ICON = ['basic' => '🧩', 'knack' => '🧩', 'calling' => '🎩', 'crop' => '🌾', 'legend' => '👑', 'craft' => '🛠️', 'region' => '🗺️', 'tool' => '🔧', 'pal' => '🐾', 'wear' => '🧵'];
/** What a creature's tag does to you (the player's own tags read PF_TAGS). */
const PFV_FOE_TAG = ['quick' => 'Quick: it plays one more piece this turn', 'evade' => 'Evade: your next hit on it misses', 'bash' => 'Bash: adds its guard to its next hit', 'poison' => 'Poison: 2 ticks on your health',
    'trip' => 'Trip: you draw 1 fewer next round', 'heal' => 'Heal: empties some of its Yield bar', 'thorns' => 'Thorns: hitting its guard pricks you', 'hold' => 'Hold: this guard lasts a turn longer', 'pierce' => 'Pierce: ignores your guard'];

/** The v1 pages are on for this gnome. */
function pfv_on(array $u): bool
{
    return pfight_on($u) && pfight_v1_on($u) && !is_guest($u);
}

/** The stylesheet, the data the piece renderer needs, and the scripts (once per page; data-rerun so they run again when the adventure page swaps its content in place). */
function pfv_assets(bool $withData = true): string
{
    $h = '<link rel="stylesheet" href="' . e(url('assets/pfight.css?v=' . APP_VERSION)) . '"><link rel="stylesheet" href="' . e(url('assets/pfv1.css?v=' . APP_VERSION)) . '">';
    if ($withData) $h .= '<i id="pfight" hidden></i><script type="application/json" id="pf-data">' . json_encode(['art' => url('assets/img/pfight/'), 'parts' => pfight_parts_url(), 'mods' => (object)[]], JSON_HEX_TAG | JSON_HEX_AMP) . '</script>'
        . '<script src="' . e(url('assets/pfparts47.js?v=' . APP_VERSION)) . '" data-rerun defer></script>';
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
function pfv_last_extra(?string $x = null): string { static $last = ''; if ($x !== null) $last = $x; return $last; }

function pfv_desc(array $p, string $extra = ''): string
{
    pfv_last_extra($extra);   // the detail sheet shows it as its own note line
    $tg = pfv_tag_text($p);
    return (PFV_TYPE[$p['t']] ?? ucfirst((string)$p['t'])) . ' ' . (int)$p['v'] . ': ' . pf_type_text((string)$p['t'], (int)$p['v']) . (!empty($p['rank']) ? ' · ' . PFD_RANK_NAME[(int)$p['rank']] : '')
        . ($extra !== '' ? ' · ' . $extra : '')   // 2.6.96: no "stays N rounds" (every piece stays 3 rounds in a new fight) and no Teamwork (off in a new fight)
        . ($tg ? '. ' . $tg[1] : '') . (($p['blurb'] ?? '') !== '' ? '. ' . rtrim((string)$p['blurb'], '.') : '') . '.';
}

/** The tag of a piece as [icon, words]: PF_TAGS_V1, else a special with no icon of its own (PF_SPECIAL: snack, pal), else null. */
function pfv_tag_text(array $p): ?array
{
    $k = (string)($p['tag'] ?? '');
    return PF_TAGS_V1[$k] ?? (isset(PF_SPECIAL[$k]) ? ['', PF_SPECIAL[$k]] : null);
}

/**
 * One piece cell (the mockup's .pc): art (drawn by the script from data-p), value, tag icon, name, expiry pips; border = rank, dashed = gear.
 * $o: cls, a (action for the script: tog | info | spick), arg, owner (me | foe), name (false = none), d (detail text), x (extra attributes, already escaped).
 */
function pfv_pc(array $p, array $o = []): string
{
    $life = PFB_LIFE;   // 2.6.96: every piece stays 3 rounds in a new fight (per-piece life is off), so the box shows 3, not the old Quick 2 / Hold 4
    $px = str_repeat('<i></i>', $life);
    $tg = PF_TAGS[(string)($p['tag'] ?? '')] ?? null; $tx = pfv_tag_text($p); $own = (string)($o['owner'] ?? 'me');
    $art = json_encode(['t' => $p['t'], 'e' => $p['e'], 'tag' => $tg ? (string)$p['tag'] : '', 'o' => $own] + (!empty($p['ik']) ? ['ik' => (string)$p['ik']] : []), JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT);
    $label = $p['n'] . ', ' . (PFV_TYPE[$p['t']] ?? $p['t']) . ' ' . (int)$p['v'] . (($p['tag'] ?? '') !== '' && ($p['tag'] ?? '') !== 'pal' ? ', ' . $p['tag'] : '') . (!empty($p['rank']) ? ', ' . PFD_RANK_NAME[(int)$p['rank']] : '') . ', stays ' . $life . ' rounds';
    // 2.6.76: everything the detail sheet shows for this piece (assets/pfv1box.js, PFSheet); the tag's words come from PF_TAGS, the one table
    $pcd = ['ik' => (string)($p['ik'] ?? ''), 'n' => (string)$p['n'], 't' => (string)$p['t'], 'ty' => PFV_TYPE[$p['t']] ?? ucfirst((string)$p['t']), 'v' => (int)$p['v'], 'rk' => (int)($p['rank'] ?? 0), 'rn' => !empty($p['rank']) ? PFD_RANK_NAME[(int)$p['rank']] : '', 'src' => (string)($p['src'] ?? ''), 'life' => $life,
        'tag' => $tg ? (string)$p['tag'] : '', 'ti' => $tx ? $tx[0] : '', 'tt' => $tx ? $tx[1] : '', 'tx' => pf_type_text((string)$p['t'], (int)$p['v']), 'e' => $p['e'], 'bl' => (string)($p['blurb'] ?? ''), 'note' => isset($o['d']) ? pfv_last_extra() : '', 'own' => $own]
        + (isset($o['dur']) ? ['dur' => $o['dur']] : []) + (array)($o['pcx'] ?? []);   // pcx: what the Puzzle box sheet adds (source, where from, limit, why it is blocked)
    return '<li' . (isset($o['g']) ? ' data-g="' . e((string)$o['g']) . '"' : '') . '><button type="button" class="pc' . (!empty($p['rank']) ? ' r' . (int)$p['rank'] : '') . (!empty($p['gear']) ? ' gear' : '') . (($o['cls'] ?? '') !== '' ? ' ' . e((string)$o['cls']) : '') . '"'
        . (isset($o['a']) ? ' data-a="' . e((string)$o['a']) . '" data-arg="' . e((string)($o['arg'] ?? $p['key'] ?? '')) . '"' : '') . ' data-n="' . e((string)$p['n']) . '" data-d="' . e((string)($o['d'] ?? '')) . '" data-t="' . e((string)$p['t']) . '" data-pc="' . e(json_encode($pcd, JSON_UNESCAPED_UNICODE)) . '"' . ($o['x'] ?? '')
        . ' aria-label="' . e($label . ($o['al'] ?? '')) . '"><i class="cvh" data-p="' . e($art) . '"></i><span class="pc-v" aria-hidden="true">' . (int)$p['v'] . '</span>' . ($o['in'] ?? '')   // in: extra marks (the Puzzle box: source badge, rank mark, pal perch), already HTML
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
    return '<span class="dur' . ($left <= 0 ? ' zero' : ($f <= .25 ? ' crit' : ($f <= .5 ? ' low' : ''))) . '" role="img" aria-label="Durability ' . $left . ' of ' . $max . '"><i data-w="' . (int)pf_round($f * 100) . '"></i></span>';
}

/** The deck bar: size with stacked sources and one line with the Hurt count (a hint when under 3 in 10). */
function pfv_deckbar(array $d, bool $slim = false): string
{
    $c = $d['counts']; $kit = (int)$c['kit'];
    $h = '<div class="meter" role="img" aria-label="Deck ' . (int)$c['n'] . ': kit ' . $kit . ', belt ' . (int)$c['belt'] . ', pals ' . (int)$c['pals'] . '"><b>' . (int)$c['n'] . '</b><span class="stack"><span class="k" data-f="' . max(1, $kit) . '">🧩 ' . $kit . '</span>'
        . ($c['belt'] ? '<span class="b" data-f="' . (int)$c['belt'] . '">🔧 ' . (int)$c['belt'] . '</span>' : '') . ($c['pals'] ? '<span class="p" data-f="' . (int)$c['pals'] . '">🐾 ' . (int)$c['pals'] . '</span>' : '') . '</span></div>';
    $n = (int)$c['n']; $hu = (int)$c['hurt'];
    $h .= '<div class="teamrow hurtrow"><b>Hurt pieces: ' . $hu . ' of ' . $n . '</b></div>';
    if ($n > 0 && $hu * 10 < 3 * $n) $h .= '<p class="hint">Few Hurt pieces: fights will be long</p>';
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

/** Fallback only (2.7.05): the pick screen is no longer the normal way in (pfd_ensure_starter packs the fixed box); it shows when that packing fails. First-time flow: 4 core pieces + pick 6 of the 12 offered, or a one-tap kit. Posts do=pfd_starter (pick[] x6, or kit=NAME without script) to the page it is on. */
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
        . '<div class="hrow"><h2>🧩 Pack your box</h2><span class="chip warn" id="pfv-hurt" title="Hurt pieces (at least 3)">⚔️ <b>1</b></span><span class="chip"><b id="pfv-n">4</b>/10</span></div>'
        . ($inFight ? '<p class="note">A creature is waiting. Pack your first Puzzle box, then you meet it.</p>' : '')
        . '<form method="post" id="pfv-sform">' . csrf_field() . '<input type="hidden" name="do" value="pfd_starter">'
        . '<ul class="pcg c5" id="pfv-tray" aria-label="Your box: 10 slots">' . $tray . '</ul>'
        . '<div class="kits" role="group" aria-label="Quick kits">' . $kits . '</div>'
        . '<div class="sl">Pick 6 <span class="pips" id="pfv-pips" role="img" aria-label="0 of 6">' . $pp . '</span></div><ul class="pcg" id="pfv-offer">' . $grid . '</ul>'
        . '<div class="pinfo" id="pfv-info" aria-live="polite"><span>Tap a piece to pick it, or take a kit.</span></div>'
        . '<span id="pfv-picks"></span><div class="actrow"><button class="btn primary grow" id="pfv-sgo" disabled>🧩 Pack the box</button></div></form></div>';
}

// ================================================================= 2. the Puzzle box page
// R3 (approved mockup, round 3): a wooden box with a lid of limit gauges and three felt trays (Kit, Belt, Pals), a compact ready strip with fix buttons above it,
// the spares shelf under it (search, source filter with counts and a legend), and a bottom sheet per piece (assets/pfv1box.js). The tabs choose the shelf: Kit = spare pieces, Belt = the tools, Pals = the Pal Book.

/** Where a piece comes from, for the filter and the badges: [label, icon (assets/img/...), what it means]. knack and calling count as basic, the Keepsake sources as wear. */
const PFV_SRC_META = [
    'basic' => ['Basic', 'ico/ico-gnome-hat.png', 'Starter pieces, knacks and your calling'],
    'crop' => ['Crop', 'ico/ico-sprout.png', 'Grown in your garden. Uses a Larder spot'],
    'legend' => ['Legend', 'ico/ico-crown.png', 'Earned by ' . PFD_LEGEND_HARVESTS . ' harvests of a legendary crop. Uses a Larder spot'],
    'craft' => ['Craft', 'ico/ico-hammer.png', 'Made at a crafting bench'],
    'region' => ['Region', 'ico/ico-world-map.png', 'Found on the roads of a region'],
    'wear' => ['Wear', 'ico/ico-gloves.png', 'Clothes you wear (My Gnome). Uses a Keepsake spot'],
    'tool' => ['Tool', 'ico/ico-shears.png', 'A tool on your fight belt. Wears out as you play it'],
    'pal' => ['Pal', 'ico/ico-paw.png', 'A pal in your party adds its piece'],
];
const PFV_TYPE_ORDER = ['hurt', 'guard', 'heal', 'charm', 'soothe', 'trick', 'item'];

function pfv_src_group(string $src): string
{
    if (in_array($src, ['basic', 'knack', 'calling'], true)) return 'basic';
    if (in_array($src, PFD_KEEP_SRC, true)) return 'wear';
    return isset(PFV_SRC_META[$src]) ? $src : 'basic';
}

/** An <img> of the game's own art (assets/img/...), decorative unless $alt is given. */
function pfv_img(string $rel, int $px, string $alt = '', string $cls = ''): string
{
    return '<img' . ($cls !== '' ? ' class="' . e($cls) . '"' : '') . ' src="' . e(url('assets/img/' . $rel)) . '" width="' . $px . '" height="' . $px . '" alt="' . e($alt) . '" decoding="async">';
}

/** The source badge on a piece (icon on its source colour). */
function pfv_srcb(string $g, string $cls = 'pc-s'): string
{
    return '<span class="' . $cls . ' s-' . e($g) . '" aria-hidden="true">' . pfv_img(PFV_SRC_META[$g][1], 32) . '</span>';
}

/** One line on where a piece comes from (the sheet). */
function pfv_from(array $u, array $p): string
{
    $ref = (string)($p['ref'] ?? ''); $nice = ucwords(str_replace(['-', '_'], ' ', $ref));
    switch ((string)$p['src']) {
        case 'basic': return 'Every gnome starts with it';
        case 'knack': return 'Knack, learned at level ' . (int)$ref . (($cc = pfd_counter_of($p)) !== null ? '; good against ' . PFD_COUNTER_CLASSES[$cc] : '');   // 2.7.08 counter pieces
        case 'calling': return 'Your ' . ucfirst((string)($u['calling'] ?? '')) . ' calling';
        case 'crop': return 'Grown in your garden' . ($nice !== '' ? ' (' . $nice . ')' : '');
        case 'legend': return 'Yours after ' . PFD_LEGEND_HARVESTS . ' harvests of ' . ($nice !== '' ? $nice : 'a legendary crop');
        case 'craft': return 'Crafting' . ($nice !== '' ? ': ' . $nice : '');
        case 'region': $rn = $ref !== '' ? (string)(q_val('SELECT gnomish_name FROM regions WHERE code = ?', [$ref]) ?: $ref) : ''; return 'Found on the roads' . ($rn !== '' ? ' of ' . $rn : '');
        case 'tool': return (TOOL_TYPES[(string)($p['tool'] ?? '')][0] ?? 'A tool') . ' on your fight belt';
        case 'pal': return (string)$p['n'] . ', in your party';
        case 'wear': return 'Worn: ' . (string)(function_exists('wear_items') ? (wear_items()[$ref]['name'] ?? 'something you wear') : 'something you wear');   // 2.7.14: ref = the worn item
    }
    return in_array($p['src'], PFD_KEEP_SRC, true) ? 'Something you wear' : '';
}

/** The limit a piece counts toward: larder | keeps | rare | mw | ''. */
function pfv_limit(array $p): string
{
    if (in_array($p['src'], PFD_LARDER_SRC, true)) return 'larder';
    if (in_array($p['src'], PFD_KEEP_SRC, true)) return 'keeps';
    return (int)$p['rank'] === 3 ? 'rare' : ((int)$p['rank'] === 4 ? 'mw' : '');
}

/** Why a spare piece cannot be packed as the deck is now (a full limit), or ''. */
function pfv_blocked(array $p, array $c): string
{
    if (in_array($p['src'], PFD_LARDER_SRC, true) && (int)$c['larder'] >= (int)$c['larder_max']) return 'Larder full';
    if (in_array($p['src'], PFD_KEEP_SRC, true) && (int)$c['keeps'] >= (int)$c['keeps_max']) return 'Keepsakes full';
    if ((int)$p['rank'] === 3 && (int)$c['rare'] >= PFD_RARE_CAP) return 'Rare limit reached';
    if ((int)$p['rank'] === 4 && (int)$c['mw'] >= PFD_MW_CAP) return 'Masterwork spot taken';
    return '';
}

/** A piece in the box or on the shelf: pfv_pc with the source badge, the rank mark, the pal perch and what the sheet needs. */
function pfv_box_pc(array $u, array $p, array $c, array $o): string
{
    $g = pfv_src_group((string)$p['src']); $rk = (int)($p['rank'] ?? 0);
    $in = pfv_srcb($g);
    if ($rk === 3) $in .= pfv_img('items/gem-r.png', 28, '', 'pc-r');
    elseif ($rk === 4) $in .= pfv_img('ico/ico-medal-gold.png', 32, '', 'pc-r');
    if ($p['src'] === 'pal' && ($ref = (string)($p['ref'] ?? '')) !== '' && preg_match('/^[a-z0-9-]+$/', $ref) && is_file(__DIR__ . '/../assets/img/pals/perch/' . $ref . '.png')) $in .= pfv_img('pals/perch/' . $ref . '.png', 36, '', 'pc-perch');
    $why = !$p['on'] && !$p['gear'] ? pfv_blocked($p, $c) : '';
    $o['in'] = $in . ($o['in'] ?? '') . ($why !== '' ? '<small class="pc-why">' . e($why) . '</small>' : '');
    $o['al'] = ', ' . PFV_SRC_META[$g][0] . ($why !== '' ? ', ' . $why : '');
    $o['pcx'] = ['g' => $g, 'sn' => PFV_SRC_META[$g][0], 'fr' => pfv_from($u, $p), 'lg' => pfv_limit($p), 'why' => $why, 'in' => $p['on'] ? 1 : 0, 'key' => (string)$p['key']];
    if ($why !== '') $o['cls'] = trim(($o['cls'] ?? '') . ' blk');
    $li = pfv_pc($p, $o);
    if (($o['a'] ?? '') === 'tog' && empty($p['gear']) && $why === '') {   // 2.7.05: without script a piece can still be packed or taken out (its own small form)
        $on = !empty($p['on']);
        $li = substr($li, 0, -5) . '<noscript><form method="post" class="pfv-ns">' . csrf_field() . '<input type="hidden" name="do" value="pfd_toggle"><input type="hidden" name="key" value="' . e((string)$p['key']) . '"><input type="hidden" name="on" value="' . ($on ? '0' : '1') . '"><input type="hidden" name="t" value="kit"><button class="btn small ghost">' . ($on ? 'Take out' : 'Pack') . '</button></form></noscript></li>';
    }
    return $li;
}

/** One cell of the ready strip: icon with a check or warning mark, a word and a number, a small meter. */
function pfv_stc(bool $ok, string $icon, string $big, string $small, int $pct, string $label): string
{
    return '<div class="stc' . ($ok ? '' : ' bad') . '" role="img" aria-label="' . e($label) . '"><span class="ic">' . $icon . '<i>' . pfv_img($ok ? 'ico/ico-check.png' : 'ico/ico-warning.png', 64) . '</i></span>'
        . '<b>' . $big . '</b><small>' . $small . '</small><span class="meter' . ($ok ? '' : ' low') . '"><i data-w="' . max(0, min(100, $pct)) . '"></i></span></div>';
}

/** The upgrade offer card for the v1 box: the first waiting offer's three choices (post `pick`, handled in puzzlebox.php), and how many are waiting / earned today. '' when none. */
function pfv_offer_html(array $u, array $mods, string $back = ''): string
{
    $uid = (int)$u['id']; $offers = pfight_offers($uid);
    if (!$offers) return '';
    [$today, $dayCap] = pfight_offer_today($uid);
    $o = $offers[0]; $own = pf_collection((int)$u['level'], (string)($u['calling'] ?? ''));
    $h = '<section class="pbx-offer" aria-label="Choose a Puzzle upgrade"><h3>' . pfv_img('ico/ico-sparkle.png', 64) . 'Choose an upgrade<span>' . count($offers) . ' waiting · ' . $today . ' of ' . $dayCap . ' earned today</span></h3>'
        . '<p class="hint">One of these three goes on the piece shown and stays until you remove it. From ' . (['a small', 'a medium', 'a big'][(int)$o['rarity']] ?? 'a') . ' puzzle.</p><ul class="pbx-offers">';
    foreach ($o['choices'] as $ci => [$tk, $mk]) {
        $def = pf_tiles()[$tk] ?? null; $md = PF_MODS[$mk] ?? null;
        if (!$def || !$md || !in_array($tk, $own, true)) continue;
        $h .= '<li><form method="post" class="pbx-pick" data-noajax="1">' . csrf_field() . '<input type="hidden" name="do" value="pick"><input type="hidden" name="offer" value="' . (int)$o['id'] . '"><input type="hidden" name="choice" value="' . (int)$ci . '">' . $back
            . '<button class="btn">' . e($def['n']) . ' + ' . $md[1] . ' <b>' . e($md[0]) . '</b><small>' . e($md[2]) . (isset($mods[$tk]) ? ' (replaces ' . e(PF_MODS[$mods[$tk]][0]) . ')' : '') . ' · ' . ['common', 'uncommon', 'rare'][$md[3]] . '</small></button></form></li>';
    }
    return $h . '</ul></section>';
}

/** The whole Puzzle box page body (puzzlebox.php, v1 on). $tab: kit | belt | pals. */
function pfv_box_html(array $u, string $tab = 'kit'): string
{
    $d = pfd_deck($u); $uid = (int)$u['id'];
    if (!$d['starter'] && pfd_ensure_starter($u)) $d = pfd_deck($u);   // 2.7.01: the same starter box for everyone, packed on the first visit
    if (!$d['starter']) return pfv_starter_html($u, $d) . pfv_assets();
    if (!in_array($tab, ['kit', 'belt', 'pals'], true)) $tab = 'kit';
    $c = $d['counts']; $locked = !empty($d['locked']); $P = pfv_entries($u, $d['pieces']); $mods = pfight_mods($uid);
    $back = '<input type="hidden" name="t" value="' . $tab . '">';
    $kitUrl = url('puzzlebox.php'); $beltUrl = url('puzzlebox.php?t=belt');
    $n = (int)$c['n']; $hu = (int)$c['hurt']; $kit = (int)$c['kit']; $aim = max(1, (int)ceil(0.3 * $n));
    $kitOk = $kit >= PFD_KIT_MIN; $hurtOk = $hu >= $aim; $limOk = (int)$c['rare'] <= PFD_RARE_CAP && (int)$c['mw'] <= PFD_MW_CAP && (int)$c['larder'] <= (int)$c['larder_max'] && (int)$c['keeps'] <= (int)$c['keeps_max'];
    $ready = $d['err'] === null && $hurtOk;
    $caps = ['rare' => [(int)$c['rare'], PFD_RARE_CAP], 'mw' => [(int)$c['mw'], PFD_MW_CAP], 'larder' => [(int)$c['larder'], (int)$c['larder_max']], 'keeps' => [(int)$c['keeps'], (int)$c['keeps_max']]];

    // ---- the top: chest, title, ready pill; the tabs
    $pill = $locked ? '<span class="pill lock">' . pfv_img('ico/ico-lock.png', 64) . 'Locked</span>'
        : ($ready ? '<span class="pill ok">' . pfv_img('ico/ico-check.png', 64) . 'Ready</span>'
        : '<a class="pill bad" href="' . e($kitUrl . (!$hurtOk && $d['err'] === null ? '?show=hurt' : '')) . '#pbx-shelf" data-fix="' . (!$hurtOk && $d['err'] === null ? 'hurt' : 'add') . '">' . pfv_img('ico/ico-warning.png', 64) . ($d['err'] === null ? 'Weak' : 'Not ready') . '</a>');
    $h = '<div class="box pbox pfv pbx" id="pfv-box" data-tab="' . $tab . '" data-caps="' . e(json_encode($caps)) . '"' . ($locked ? ' data-locked="1"' : '') . '>'
        . '<div class="hrow pbx-top"><span class="pbx-chest" aria-hidden="true">' . pfv_img('chest-body.png', 64, '', 'cb') . pfv_img('chest-lid.png', 64, '', 'cl') . '</span><h2>Puzzle box</h2>' . $pill . '</div>';
    $h .= '<nav class="tabs" aria-label="Puzzle box">';
    foreach (['kit' => 'Kit', 'belt' => 'Belt', 'pals' => 'Pals'] as $k => $l) $h .= '<a href="' . e(url('puzzlebox.php' . ($k === 'kit' ? '' : '?t=' . $k))) . '"' . ($k === $tab ? ' class="on" aria-current="page"' : '') . '>' . $l . '</a>';
    $h .= '</nav>';
    require_once __DIR__ . '/wearables.php';
    if (wear_live($u)) { require_once __DIR__ . '/wear_view.php'; $h .= wear_strip_html($u); }   // 2.7.14: what the gnome wears (read-only; changed on My Gnome). Only worn items offer their piece

    // ---- locked banner, or the ready strip and what to fix
    if ($locked) {
        $who = '';
        try { if (function_exists('active_expedition') && ($ex = active_expedition($uid)) && ($en = json_decode((string)($ex['encounter'] ?? ''), true)) && function_exists('encounter_creature') && ($cr = encounter_creature($en))) $who = (string)($cr['name'] ?? ''); } catch (Throwable $e) { $who = ''; }
        $h .= '<div class="pbx-banner" role="status">' . pfv_img('ico/ico-lock.png', 64) . '<span><b>' . ($who !== '' ? 'You are fighting ' . e(preg_match('/^[AEIOU]/i', $who) ? 'an ' : 'a ') . e($who) : 'You are in a fight') . '</b><small>Your deck is locked until the fight is over. Tap a piece to read it.</small></span>'
            . '<a class="btn" href="' . e(url('adventure.php')) . '">Back to the fight</a></div>';
    } else {
        $h .= '<section class="pbx-status" aria-label="Is my deck ready?">'
            . pfv_stc($kitOk, pfv_img('ico/ico-jigsaw-box.png', 64), 'Kit ' . $kit, 'need ' . PFD_KIT_MIN, (int)round(100 * $kit / PFD_KIT_MIN), 'Kit pieces: ' . $kit . ', ' . PFD_KIT_MIN . ' needed')
            . pfv_stc($hurtOk, pfv_img('pfight/ico-hurt.png', 32), 'Hurt ' . $hu, 'aim ' . $aim . '+', (int)round(100 * $hu / $aim), 'Hurt pieces: ' . $hu . ' of ' . $n . ', aim for ' . $aim . ' or more')
            . pfv_stc($limOk, pfv_img('items/gem-r.png', 28), 'Limits', $limOk ? 'all OK' : 'over', 100, $limOk ? 'Limits all OK' : 'Over a limit')
            . '</section>';
        if ($d['err'] !== null) $h .= '<div class="pbx-fix"><span><b>' . e((string)$d['err']) . '</b><small>Until then a fight uses the standard kit.</small></span>'
            . ($kit < PFD_KIT_MIN ? '<a class="btn gold" href="' . e($kitUrl) . '#pbx-shelf" data-fix="add">Add</a>' : '') . '</div>';
        if (!$hurtOk) $h .= '<div class="pbx-fix"><span><b>Only ' . $hu . ' of ' . $n . ' pieces hit</b><small>Fights will drag on. Add ' . ($aim - $hu) . ' more Hurt piece' . ($aim - $hu === 1 ? '' : 's') . '.</small></span><a class="btn gold" href="' . e($kitUrl) . '?show=hurt#pbx-shelf" data-fix="hurt">Show Hurt</a></div>';
    }

    // ---- 2.7.05: a waiting Puzzle upgrade offer (earned by finishing a puzzle): choose one of three, one offer at a time
    $h .= pfv_offer_html($u, $mods, $back);

    // ---- the box: the lid (limits), then the Kit, Belt and Pals trays
    $lim = function (string $cls, string $icon, string $name, int $have, int $max): string {
        $full = $have >= $max;
        return '<div class="capp lim ' . $cls . ($full ? ' full' : '') . ($have > $max ? ' over' : '') . '" role="img" aria-label="' . $name . ' ' . $have . ' of ' . $max . ($full ? ', full' : '') . '">' . $icon . '<em>' . $have . ' of ' . $max . '</em><span>' . $name . '</span></div>';
    };
    $h .= '<section class="pbx-box" aria-label="Your Puzzle box"><div class="pbx-lid">'
        . $lim('rare', pfv_img('items/gem-r.png', 28), 'Rare', (int)$c['rare'], PFD_RARE_CAP) . $lim('mw', pfv_img('ico/ico-medal-gold.png', 64), 'Masterwork', (int)$c['mw'], PFD_MW_CAP)
        . $lim('lard', pfv_img('ico/ico-jar.png', 64), 'Larder', (int)$c['larder'], (int)$c['larder_max']) . $lim('keep', pfv_img('ico/ico-ribbon.png', 64), 'Keepsakes', (int)$c['keeps'], (int)$c['keeps_max']) . '</div>';
    // Kit
    $kitP = array_values(array_filter($P, fn($p) => $p['on'] && !$p['gear']));
    usort($kitP, fn($a, $b) => (array_search($a['t'], PFV_TYPE_ORDER, true) <=> array_search($b['t'], PFV_TYPE_ORDER, true)));
    $tally = '';
    foreach (PFV_TYPE_ORDER as $t) { $k = count(array_filter($kitP, fn($p) => $p['t'] === $t)); if ($k) $tally .= '<i title="' . PFV_TYPE[$t] . ' ' . $k . '">' . pfv_img('pfight/ico-' . $t . '-s.png', 20, PFV_TYPE[$t]) . $k . '</i>'; }
    $kitHead = pfv_img('pfight/parts/deck-book.png', 32) . '<b>Kit</b><span class="tally">' . $tally . '<em>' . $kit . '</em></span>';
    if ($tab === 'kit') {
        $in = '';
        foreach ($kitP as $p) {
            $md = isset($mods[$p['k']]) ? (PF_MODS[$mods[$p['k']]] ?? null) : null; $x = ($md ? 'upgrade ' . $md[0] : '');
            $in .= pfv_box_pc($u, $p, $c, ['cls' => 'sel' . ($p['out'] !== '' ? ' out' : ''), 'a' => $locked ? 'info' : 'tog', 'd' => pfv_desc($p, trim(($p['out'] === 'slots' ? 'left out: your ' . (in_array($p['src'], PFD_KEEP_SRC, true) ? 'Keepsake slots are' : 'Larder is') . ' full' : ($p['out'] !== '' ? 'left out: over the rarity cap' : ($p['core'] ? 'core' : ''))) . ($x !== '' ? ' · ' . $x : ''), ' ·')), 'x' => ' data-on="1"']);
        }
        if (!$locked) $in .= '<li class="pbx-add"><a class="slot" href="#pbx-shelf" data-fix="add">' . pfv_img('ico/ico-plus.png', 64) . 'Add</a></li>';
        $h .= '<div class="comp pbx-kit"><div class="ch">' . $kitHead . '</div><ul class="pcg pfv-g tray">' . ($in ?: pfv_slot('none')) . '</ul></div>';
    } else {
        $h .= '<div class="comp pbx-kit shut"><a class="ch" href="' . e($kitUrl) . '">' . $kitHead . '<span class="more">Open</span></a></div>';
    }
    // Belt
    $tier = (int)($d['belt_tier'] ?? 1); $slots = (int)$d['slots']; $onBelt = []; $wear = pfd_wear($u);
    $rk = item_id_by_slug(PFD_REPAIR); $kits = $rk ? (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $rk]) : 0;
    $bs = '';
    foreach ($d['belt'] as $i => $b) { if ($i >= 4) break;
        $onBelt[$b['type']] = $b['state'];
        $p = null; foreach ($P as $q) if ($q['tool'] === $b['type']) $p = $q;
        if ($p && $b['state'] === 'ok') {
            $w = $wear[$b['type']] ?? ['wear' => 0, 'broken' => false];
            $acts = [];   // the sheet's buttons for a tool in the tray (fix = Fix, fix0 = Fix with no kit, off = Take off): pfv1box.js
            if (!$locked && (int)($w['wear'] ?? 0) > 0) $acts[] = $kits < 1 ? 'fix0' : 'fix';
            if (!$locked) $acts[] = 'off';
            $bs .= str_replace(['<li>', '</li>'], ['<li class="bslot">', '<span class="durr">' . pfv_durbar((int)$b['left'], (int)$b['max']) . '<small>' . (int)$b['left'] . '/' . (int)$b['max'] . '</small></span></li>'],
                pfv_box_pc($u, $p, $c, ['a' => 'info', 'dur' => [(int)$b['left'], (int)$b['max']], 'd' => pfv_desc($p, 'durability ' . (int)$b['left'] . '/' . (int)$b['max'] . ', −' . PFB_TOOL_WEAR . ' a play'), 'x' => ' data-tool="' . e($b['type']) . '" data-bacts="' . e(implode(',', $acts)) . '"']));
        } elseif (in_array($b['state'], ['broken', 'none'], true) && !$locked) $bs .= pfv_slot('<span class="pfv-bn">' . e((TOOL_TYPES[$b['type']][0] ?? ucfirst($b['type']))) . '<br>' . ($b['state'] === 'broken' ? 'broken' : 'gone') . '</span>'
            . '<form method="post" class="pfv-rm">' . csrf_field() . '<input type="hidden" name="do" value="pfd_remove"><input type="hidden" name="tool" value="' . e($b['type']) . '">' . $back . '<button class="btn small ghost" aria-label="Remove the ' . e((TOOL_TYPES[$b['type']][0] ?? $b['type'])) . ' from the belt">Remove</button></form>');
        else $bs .= pfv_slot($b['state'] === 'broken' ? 'broken' : ($b['state'] === 'over' ? 'no slot' : 'gone'));
    }
    if (!$locked) for ($i = count($d['belt']); $i < $slots; $i++) $bs .= '<li class="pbx-add"><a class="slot" href="' . e($beltUrl) . '#pbx-shelf">' . pfv_img('ico/ico-plus.png', 64) . 'Add</a></li>';
    $next = $tier < 3 ? PFD_BELTS[$tier + 1] : null;
    $h .= '<div class="comp pbx-belt"><div class="ch">' . pfv_img('ico/ico-toolbox.png', 64) . '<b>Belt ' . ['', 'I', 'II', 'III'][$tier] . '</b><span>' . (int)$c['belt'] . ' of ' . $slots . ' loop' . ($slots === 1 ? '' : 's') . '</span></div>'
        . '<ul class="pcg tray">' . ($bs ?: pfv_slot('no tools')) . '</ul>'
        . '<p class="beltnote">' . ($next ? pfv_img('ico/ico-lock.png', 64) . '<span>Belt ' . ['', 'I', 'II', 'III'][$tier + 1] . ': ' . $next[0] . ' loops, from level ' . $next[2] . '. Tools lose ' . PFB_TOOL_WEAR . ' each play.</span>' : '<span>Tools lose ' . PFB_TOOL_WEAR . ' durability each play.</span>') . '</p></div>';
    // Pals
    $pl = '';
    foreach ($P as $p) if ($p['src'] === 'pal') $pl .= pfv_box_pc($u, $p, $c, ['cls' => 'sel' . ($p['out'] !== '' ? ' out' : ''), 'a' => 'info', 'd' => pfv_desc($p, 'in your party')]);
    $h .= '<div class="comp pbx-pals"><div class="ch">' . pfv_img('ico/ico-paw.png', 64) . '<b>Pals</b><span>' . (int)$c['pals'] . ' in your party</span></div>'
        . ($pl !== '' ? '<ul class="pcg tray pals">' . $pl . '</ul>' : '<p class="beltnote"><span>No pals along. Each pal in your party adds one piece.</span></p>') . '</div></section>';

    // ---- under the box: the shelf of the tab
    $hint = 'Tap a piece to read it.';
    if ($tab === 'kit') {
        if (!$locked) {
        $spare = array_values(array_filter($P, fn($p) => !$p['on'] && !$p['gear']));
        $cnt = []; foreach ($spare as $p) { $g = pfv_src_group((string)$p['src']); $cnt[$g] = ($cnt[$g] ?? 0) + 1; }
        $col = '';
        foreach ($spare as $p) {
            $md = isset($mods[$p['k']]) ? (PF_MODS[$mods[$p['k']]] ?? null) : null; $x = ($md ? 'upgrade ' . $md[0] : '');
            $col .= pfv_box_pc($u, $p, $c, ['cls' => !empty($p['new']) ? 'isnew' : '', 'a' => $locked ? 'info' : 'tog', 'g' => pfv_src_group((string)$p['src']), 'd' => pfv_desc($p, trim((!empty($p['new']) ? 'new: switched off until you pack it' : '') . ($x !== '' ? ' · ' . $x : ''), ' ·')), 'x' => ' data-on="0"']);
        }
        $fb = '';
        foreach (['basic', 'crop', 'legend', 'craft', 'region', 'wear'] as $g) $fb .= '<button type="button" class="s-' . $g . '" data-g="' . $g . '" aria-pressed="false" aria-label="' . PFV_SRC_META[$g][0] . ' pieces: ' . (int)($cnt[$g] ?? 0) . '"' . (empty($cnt[$g]) ? ' disabled' : '') . '>' . pfv_img(PFV_SRC_META[$g][1], 64) . '<span>' . PFV_SRC_META[$g][0] . '</span><em>' . (int)($cnt[$g] ?? 0) . '</em></button>';
        $leg = '';
        foreach (PFV_SRC_META as $g => [$lbl, , $what]) $leg .= '<li>' . pfv_srcb($g, 'srcb') . '<span><b>' . $lbl . '</b>' . e($what) . '</span></li>';
        $h .= '<section class="pbx-shelf" id="pbx-shelf" aria-label="Spare pieces"><h3>' . pfv_img('ico/ico-satchel.png', 64) . 'On the shelf<span>' . count($spare) . ' spare</span></h3>'
            . '<div class="srow"><label class="search">' . pfv_img('ico/ico-search.png', 64) . '<input type="search" id="pbx-q" placeholder="Search spare pieces" aria-label="Search spare pieces" autocomplete="off"></label><button type="button" class="btn ghost" id="pbx-all" hidden>All</button></div>'
            . '<nav class="pbx-fbar" id="pfv-filt" aria-label="Filter by source">' . $fb . '</nav>'
            . '<p class="pbx-kind" id="pbx-kind" hidden></p>'
            . '<details class="pbx-legend"><summary>' . pfv_img('ico/ico-info.png', 64) . 'What the source icons mean</summary><ul>' . $leg . '</ul></details>'
            . '<ul class="pcg pfv-g shelfg">' . ($col ?: pfv_slot('none')) . '</ul><p class="pbx-empty" id="pbx-empty" hidden>No spare pieces match.</p></section>';
        }
        $hint = $locked ? 'Tap a piece to read it.' : 'Tap a piece, then pack it or take it out.';
    } elseif ($tab === 'belt') {
        $h .= '<section class="pbx-shelf" id="pbx-shelf" aria-label="Your tools"><h3>' . pfv_img('ico/ico-toolbox.png', 64) . 'Tools<span>repair kits: ' . $kits . '</span></h3>';
        $h .= '<div class="chips seg pfv-tier" role="img" aria-label="Fight belt tier ' . $tier . ': ' . $slots . ' tool slots">';
        foreach (PFD_BELTS as $t => [$nn]) $h .= '<span' . ($t === $tier ? ' class="on"' : '') . '>Belt ' . ['', 'I', 'II', 'III'][$t] . ' · ' . $nn . '</span>';
        $h .= '</div><ul class="toolg" id="pfv-tools">';
        $full = count(array_filter($onBelt, fn($s) => $s === 'ok')) >= $slots; $any = false;
        foreach ($wear as $type => $w) {
            if ((int)$w['tier'] < 1 || !isset(pfd_catalog()['t:' . $type])) continue; $any = true;
            $pn = (string)pfd_catalog()['t:' . $type]['n']; $tt = TOOL_TYPES[$type] ?? [ucfirst($type), '🔧']; $on = ($onBelt[$type] ?? '') === 'ok'; $bk = !empty($w['broken']);
            $acts = [];   // what the sheet offers: do|label|class|disabled
            if (!$locked && ($bk || (int)$w['wear'] > 0)) $acts[] = 'pfd_fix|Fix (1 kit)|gold|' . ($kits < 1 ? '1' : '0');
            if (!$locked && $bk && ($onBelt[$type] ?? '') === 'broken') $acts[] = 'pfd_remove|Remove|ghost|0';
            if (!$locked && !$bk) $acts[] = $on ? 'pfd_unequip|Take off|ghost|0' : 'pfd_equip|' . ($full ? 'Belt full' : 'Put on belt') . '|primary|' . ($full ? '1' : '0');
            $td = $tt[0] . ' tool · ' . PFD_RANK_NAME[(int)$w['tier']] . ' · durability ' . (int)$w['left'] . '/' . (int)$w['max'] . ($bk ? ' · worn out: fix it with a Tool Repair Kit' . ($kits < 1 ? ' (you have none)' : '') : ($on ? ' · on the belt' : '')) . '.';
            $h .= '<li><button type="button" class="tb t' . (int)$w['tier'] . ($bk ? ' broken' : '') . ($on ? ' on' : '') . '" data-a="tool" data-arg="' . e($type) . '" data-n="' . e($pn) . '" data-d="' . e($td) . '" data-acts="' . e(implode(';', $acts)) . '" data-dur="' . (int)$w['left'] . '/' . (int)$w['max'] . '" data-rk="' . (int)$w['tier'] . '" data-ico="' . e($tt[1]) . '" aria-pressed="' . ($on ? 'true' : 'false') . '" aria-label="' . e($pn . ', ' . $td) . '">'
                . '<span class="ti" aria-hidden="true">' . $tt[1] . '</span><span class="tn">' . e($pn) . '</span>' . pfv_durbar((int)$w['left'], (int)$w['max']) . '</button></li>';
        }
        $h .= ($any ? '' : '<li class="hint">No tools yet. A garden or gathering tool in your satchel can go on the belt.</li>') . '</ul>';
        $h .= '<p class="hint">' . ($tier < 3 ? 'A bigger belt holds more tools: <a href="' . e((($twg = (int)q_val("SELECT id FROM shops WHERE slug = 'twigg-s-seed-emporium'")) > 0 ? url('shop.php?id=' . $twg) : url('world.php?tab=markets'))) . '">buy one at Twigg’s</a> (Belt II from level ' . PFD_BELTS[2][2] . ', Belt III from level ' . PFD_BELTS[3][2] . ').' : 'Your belt holds the most tools a belt can.')
            . ' A worn-out tool leaves the deck until you fix it with a Tool Repair Kit (crafted: flint, pine resin, coir fibre). Remove takes a broken tool off the belt: keep it to repair later.</p></section>';
        $hint = $locked ? 'Tap a tool to read it.' : 'Tap a tool, then put it on, take it off or fix it.';
    } else {
        require_once __DIR__ . '/puzzle_pals.php';
        $h .= '<section class="pbx-shelf" id="pbx-shelf" aria-label="Puzzle Pals"><h3>' . pfv_img('ico/ico-paw.png', 64) . 'Puzzle Pals<span>' . (int)$c['pals'] . ' along · 1 piece each</span></h3>'
            . '<p class="hint">' . (ppal_open() ? 'The pals you take along each add one piece. <a href="' . e(url('puzzlepals.php#party')) . '">Change your party in the Pal Book</a>' . ($locked ? ' (after the fight).' : '.') : 'Puzzle Pals are not open yet.') . '</p></section>';
        $hint = 'Tap a pal piece to read it.';
    }
    $h .= '<div class="pinfo" id="pfv-info" aria-live="polite" data-hint="' . e($hint) . '"><span>' . e($hint) . '</span></div>';
    if (!$locked) {
        $on = !empty($d['auto']);
        $h .= '<form method="post" class="pfv-autof pbx-auto">' . csrf_field() . '<input type="hidden" name="do" value="pfd_auto"><input type="hidden" name="on" value="' . ($on ? '0' : '1') . '">' . $back
            . '<label class="sw"><span><b>Use this deck in every fight</b><small>' . ($on ? 'Auto deck is on: this deck goes into every fight as it is. You still see the creature first.' : 'Off: before each fight you can swap pieces.') . '</small></span><input type="checkbox" id="pfv-auto"' . ($on ? ' checked' : '') . '></label>'
            . '<noscript><button class="btn small">' . ($on ? 'Turn off' : 'Turn on') . '</button></noscript></form>';
    }
    $h .= '<p class="pbx-toast" id="pbx-toast" role="status" hidden></p>';
    return $h . pfv_form($back) . '</div>' . pfv_assets();
}

// ================================================================= 3. the pre-fight screen

/** What a creature piece plays for on the board (the board's per-size factors: pfb_new). */
function pfv_foe_v(array $c, int $v): int
{
    $size = (string)($c['size'] ?? 'small');
    return max(1, (int)pf_round($v * (PFB_V1_FOE_MULT[$size] ?? 1.0) * ($size === 'boss' ? PFB_BOSS_MULT : 1.0) * (PFB_FOE_FIRES > 0 ? PFB_FOE_FIRE_MULT : 1.0)));
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
        $q = ['n' => $p['n'], 't' => $p['t'], 'v' => $v, 'tag' => $p['tag'], 'life' => $p['life'], 'src' => 'creature', 'ik' => (string)($p['ik'] ?? ''), 'e' => pfb_author_edges(['t' => $p['t'], 'r' => $p['r']], (string)$p['col'])];
        $d = (PFV_TYPE[$p['t']] ?? $p['t']) . ' ' . $v . ' · ' . PFD_LAYERS[$p['layer']] . ' · stays ' . PFB_LIFE . ' rounds · plays ×' . PFB_FOE_FIRES . (isset(PFV_FOE_TAG[$p['tag']]) ? '. ' . PFV_FOE_TAG[$p['tag']] : '') . '.';
        $cells .= pfv_pc($q, ['owner' => 'foe', 'cls' => 'L-' . $p['layer'], 'a' => 'info', 'd' => $d, 'x' => ' data-info="pfv-cinfo"']);
    }
    $tally = '';
    foreach (PFD_LAYERS as $L => $name) if (!empty($by[$L])) $tally .= '<span class="L-' . $L . '" data-f="' . $by[$L] . '" title="' . e($name) . ' ' . $by[$L] . '">' . ($by[$L] < 2 ? '+' . $by[$L] : e(explode(' ', $name)[0]) . ' ' . $by[$L]) . '</span>';
    $charm = $size === 'boss' ? 'cannot be charmed' : (pf_temper($c) === 'gentle' ? 'gentle' : 'wary');
    return '<div class="foecard"><div class="pic">' . $img . '</div><div class="fx"><h3>' . e((string)$c['name']) . ' <small>lv ' . (int)$c['level'] . '</small></h3>'
        . '<div class="chips small"><span class="chip">' . (PFV_CLASS_ICON[$cl] ?? '🐾') . ' ' . e($cl) . '</span>' . ($rn !== '' ? '<span class="chip">' . e($rn) . '</span>' : '') . '<span class="chip"><i class="szd ' . e($size) . '"></i>' . e($size) . ' · ' . $dims[0] . '×' . $dims[1] . '</span><span class="chip">' . $charm . '</span><span class="chip">leans ' . e($lean) . '</span></div></div></div>'
        . (($kr = PFB_KIND_TEXT[pfb_kind_of(['class' => $cl], $size)] ?? null) && !empty(pfb_v1_cfg($size, [], max(1, (int)($c['level'] ?? 1)))['kinds']) ? '<p class="foerule"><b>' . e($kr[0]) . ':</b> ' . e($kr[1]) . '</p>' : '')   // 2.6.98: the class rule, when the fight will use it
        . '<div class="tally" role="img" aria-label="' . array_sum($by) . ' pieces in layers">' . $tally . '</div><ul class="pcg c5" data-pico="' . e(url('assets/img/pfight/pieces/')) . '">' . $cells . '</ul>'
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
    $h = '<div class="box pfv" id="pfv-pre"><div class="pfv-scroll">' . pfv_foe_card($c, $region);
    $go = '<div class="actrow pfv-act"><a class="btn ghost" href="' . e(url('puzzlebox.php')) . '">🧩 Box</a><form method="post" class="grow pfv-gof">' . csrf_field() . '<input type="hidden" name="do" value="pfv_go"><button class="btn primary" id="pfv-go">⚔️ Let’s fight</button></form></div>';
    if ($auto) {   // 2.6.75: Auto deck on: the creature, one strip, Let's fight; the read-only deck waits in a fold under the button
        $h .= '<div class="pinfo pfv-autostrip" id="pfv-info" aria-live="polite" data-hint="Auto deck is active."><span><b>Auto deck is active:</b> ' . $n . ' pieces · ❤️ ' . max(1, (int)$exp['hp']) . '/' . (int)$exp['max_hp'] . '</span>'
            . '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="pfd_auto"><input type="hidden" name="on" value="0"><button class="btn ghost">Turn off and edit</button></form></div>'
            . '</div>' . $go
            . '<details class="pfv-deckfold" id="pfv-deckfold"><summary>Show deck <span>' . $n . ' pieces, read-only</span></summary>' . pfv_deckbar($d, true) . '<ul class="pcg c5">' . $deck . '</ul></details>';
    } else {
        $h .= '<div class="sl">Your deck <span>' . $n . ' pieces · ❤️ ' . max(1, (int)$exp['hp']) . '/' . (int)$exp['max_hp'] . '</span></div>' . pfv_deckbar($d, true) . '<ul class="pcg c5">' . $deck . '</ul>'
            . '<div class="sl">Bench <span>tap to add</span></div><ul class="pcg c5">' . ($bench ?: pfv_slot('none')) . '</ul>'
            . '<div class="pinfo" id="pfv-info" aria-live="polite" data-hint="Tap a deck piece to take it out, a bench piece to add it.">' . ($d['err'] !== null ? '<span><b>' . e((string)$d['err']) . '</b> Until then the standard kit plays.</span>' : '<span>Tap a deck piece to take it out, a bench piece to add it. Nothing changes once the fight starts.</span>') . '</div>'
            . pfv_auto_html(false) . '</div>' . $go;
    }
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
        $n = pfd_carry_old_box($u);
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
    if ($r['how'] === 'defeat' && !empty($r['learn'])) $T[2] = 'The ' . $name . ' wins this one, then wanders off. No harm done: in your first fights you keep walking, at full health.';   // 2.7.01 learner fights: no knock-out
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
        . '<div class="rows"><div class="row"><b>You</b><span class="gvbar"><i data-w="' . (int)pf_round(100 * $hp / $max) . '"></i><span>' . $hp . '/' . $max . '</span></span></div>'
        . '<div class="row"><b>Fight</b><span>' . (int)$r['turns'] . ' turn' . ((int)$r['turns'] === 1 ? '' : 's') . '</span></div></div>'
        . (!empty($r['recap']) ? '<p class="hint pfv-recap" id="pfv-recap">' . e((string)$r['recap']) . '</p>' : '')   // 2.7.01 defeat recap: where your health went
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
