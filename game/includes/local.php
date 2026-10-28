<?php
declare(strict_types=1);
require_once __DIR__ . '/place_ui.php';
/**
 * Local life in the small places. v1.0.0 wave 1 rebuilt this: a village is a rest stop with a TYPE (stops.php), named villagers
 * and errands (stop_folk.php), a stamp for your passport (stop_pass.php) and an adopter (stop_adopt.php). This file is the page
 * the Town tab shows for a village, and the one POST entry point (town.php?do=local).
 */

require_once __DIR__ . '/stops.php';
require_once __DIR__ . '/stop_folk.php';
require_once __DIR__ . '/stop_pass.php';
require_once __DIR__ . '/stop_adopt.php';

/** The place's level, for reward scaling (kept for older callers). */
function local_level(array $loc): int
{
    return stop_level($loc);
}

function local_visit_key(array $u): string
{
    return stop_visit_key($u);
}

/** Everything the POST can do at a stop. $kind is an activity slug, or _chat _errand _deliver _drop _adopt _give _perk _release. */
function local_do(array $u, array $loc, string $kind, array $in): array
{
    if (($loc['kind'] ?? '') !== 'village') return [false, 'There’s nothing like that here.'];
    switch ($kind) {
        case '_chat': return stop_chat($u, $loc, (int)($in['folk'] ?? 0));
        case '_errand': return stop_errand_accept($u, $loc, (int)($in['folk'] ?? 0));
        case '_deliver': return stop_errand_deliver($u, $loc, (int)($in['errand'] ?? 0));
        case '_drop': return stop_errand_drop($u, (int)($in['errand'] ?? 0));
        case '_adopt': return stop_adopt($u, $loc);
        case '_release': return stop_release($u, $loc);
        case '_give': return stop_contribute($u, $loc, (string)($in['need'] ?? ''), (int)($in['qty'] ?? 0));
        case '_perk': return stop_adopter_perk($u, $loc);
    }
    return stop_do($u, $loc, $kind, $in);
}

/** For the Today card: [headline, button text]. */
function local_card(array $u, array $loc): array
{
    $types = stop_types();
    $t = $types[stop_type_of($loc)] ?? null;
    [$done, $here, $all] = stop_state((int)$u['id'], (int)$loc['id'], stop_visit_key($u));
    $slots = stop_slots($loc);
    $left = max(0, $slots - count($done));
    $capped = $here >= max(1, (int)setting('stop_daily_cap'));   // v1.4.9: only the per-stop limit stops you
    if ($capped) return [($t['icon'] ?? '🪧') . ' ' . ($t['name'] ?? 'Rest stop') . ': that’s enough here for today. Walk on and see what’s happening elsewhere!', 'See the stop →'];
    if ($left === 0) return [($t['icon'] ?? '🪧') . ' ' . ($t['name'] ?? 'Rest stop') . ': you’ve done all ' . $slots . ' things this visit. Walk on and come back for more!', 'See the stop →'];
    return [($t['icon'] ?? '🪧') . ' ' . ($t['name'] ?? 'Rest stop') . ': ' . $left . ' of ' . $slots . ' things left this visit, and ' . count(stop_folk_of($loc)) . ' villagers to meet.', 'Stay a while →'];
}

// ---------------------------------------------------------------- the page

/** A form that posts to town.php (do=local). */
function local_form(string $kind, string $inner, string $class = 'inline'): string
{
    $t = $GLOBALS['st_tab'] ?? 'do';   // v1.3.0: come back to the same tab
    return '<form method="post" class="' . $class . '">' . csrf_field() . ($t !== 'do' ? '<input type="hidden" name="t" value="' . e($t) . '">' : '') . '<input type="hidden" name="do" value="local"><input type="hidden" name="kind" value="' . e($kind) . '">' . $inner . '</form>';
}

/** The buttons for one activity tile. */
function local_act_buttons(array $u, array $loc, array $a, bool $locked): string
{
    $kind = (string)$a['kind'];
    $spec = (string)$a['spec'];
    $slug = (string)$a['slug'];
    $f = fn(string $inner) => local_form($slug, $inner);
    $cost = (int)$a['energy'] > 0 ? ' <span class="cost">⚡' . (int)$a['energy'] . '</span>' : '';
    $dis = $locked ? ' disabled' : '';
    $folk = stop_folk_of($loc)[0] ?? null;
    switch ($kind) {
        case 'check':   // v1.6.3: each approach is a .choice row (chance on the right); the % chance sits in the badge, the easy/fair/hard word is its tooltip
            $h = '';
            $en = (int)$a['energy'] > 0 ? ' · ⚡' . (int)$a['energy'] : '';
            foreach (explode(';', $spec) as $i => $o) {
                $pp = array_map('trim', explode(':', $o, 3));
                if (count($pp) !== 3 || !isset(GNOME_STATS[$pp[0]])) continue;
                [$stat, $dc, $label] = [$pp[0], (int)$pp[1], stop_say($pp[2], $loc, $folk)];
                $chance = $dc <= 0 ? 100 : max(5, min(95, (21 - ($dc - eff_mod($u, $stat))) * 5));
                $h .= choice_row(GNOME_STATS[$stat][1], $label, $dc > 0 ? GNOME_STATS[$stat][0] . ' check · ' . stop_chance_word($chance) . $en : ltrim($en, ' ·'), $dc > 0 ? [$chance . '%', choice_odds_class($chance)] : '', '', 'name="opt" value="' . $i . '"' . $dis);
            }
            return local_form($slug, $h, 'choiceform');
        case 'pick':
            $p = stop_spec_params($spec);
            $n = max(2, min(6, (int)($p['n'] ?? 3)));
            $h = '<span class="st-picks">';
            for ($i = 1; $i <= $n; $i++) $h .= '<button class="btn small alt" name="pick" value="' . $i . '"' . $dis . '>' . e($p['ico'] ?? '🎲') . ' ' . $i . '</button> ';
            return $f($h . '</span>');
        case 'power':
            $p = stop_spec_params($spec);
            $n = max(3, min(7, (int)($p['n'] ?? 5)));
            $peg = stop_peg((int)$loc['id'], $slug, $n);
            $h = '<p class="help">The mark looks ' . ($peg <= intdiv($n, 2) ? 'close by' : 'farther off') . '.</p>';
            for ($i = 1; $i <= $n; $i++) $h .= '<button class="btn small alt" name="power" value="' . $i . '"' . $dis . '>' . '💪' . $i . '</button> ';   // v1.3.0: one 💪 and a number, so the row stays short
            return $f($h);
        case 'rest':
            $p = stop_spec_params($spec);
            $c = (int)($p['cost'] ?? 0);
            return local_form($slug, choice_row('🛏️', 'Rest', 'Sit a while and get your breath back', $c ? [money_txt($c), 'cost'] : ['free', 'free'], '', ltrim($dis)), 'choiceform');   // v1.6.3
        case 'buy':
            [$bs, $bq, $bp] = array_pad(explode(':', $spec), 3, '');
            $name = (string)q_val('SELECT name FROM items WHERE slug = ?', [$bs]);
            return local_form($slug, choice_row('🛒', 'Buy ' . (int)$bq . ' × ' . $name, 'You have ' . (int)q_val('SELECT ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = ?', [(int)$u['id'], $bs]), [money_txt((int)$bp), 'cost'], '', ltrim($dis)), 'choiceform');   // v1.6.3
        case 'swap':
            [$g, $r] = array_pad(explode('>', $spec), 2, '');
            [$gs, $gq] = array_pad(explode(':', $g), 2, '1');
            [$rs, $rq] = array_pad(explode(':', $r), 2, '1');
            $gn = (string)q_val('SELECT name FROM items WHERE slug = ?', [$gs]);
            $rn = (string)q_val('SELECT name FROM items WHERE slug = ?', [$rs]);
            $have = (int)q_val('SELECT qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = ?', [(int)$u['id'], $gs]);
            return local_form($slug, choice_row('🔁', 'Swap ' . (int)$gq . ' × ' . $gn, 'for ' . (int)$rq . ' × ' . $rn . ($have < (int)$gq ? ' · you have ' . $have : ''), '', '', ltrim($dis ?: ($have < (int)$gq ? ' disabled' : ''))), 'choiceform');   // v1.6.3
        case 'snack':
            $sn = stop_snack($loc);
            return $sn ? local_form($slug, choice_row('🥪', 'Buy 2 × ' . $sn[0]['name'], 'Fresh from today’s bake', [money_txt($sn[1]), 'cost'], '', ltrim($dis)), 'choiceform') : '<p class="muted">Sold out today.</p>';   // v1.6.3
        case 'seedswap':
            $seeds = q("SELECT i.id, i.name, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND i.category = 'seed' ORDER BY i.name", [(int)$u['id']])->fetchAll();
            if (!$seeds) return '<p class="muted">You have no seeds to swap.</p>';
            $opt = '';
            foreach ($seeds as $s) $opt .= '<option value="' . (int)$s['id'] . '">' . e($s['name']) . ' (' . (int)$s['qty'] . ')</option>';
            return $f('<select name="item_id" aria-label="Seed to swap">' . $opt . '</select> <button class="btn small"' . $dis . '>Swap</button>');
        case 'craft':   // v2.0.78
            [$ins, [$os, $oq]] = stop_craft_parts($spec);
            $uid = (int)$u['id'];
            $lack = false; $bits = [];
            foreach ($ins as [$is, $iq]) {
                $have = (int)q_val('SELECT COALESCE(SUM(ui.qty), 0) FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = ?', [$uid, $is]);
                if ($have < $iq) $lack = true;
                $bits[] = $iq . ' × ' . (string)(q_val('SELECT name FROM items WHERE slug = ?', [$is]) ?: $is) . ' (you have ' . $have . ')';
            }
            $on = (string)(q_val('SELECT name FROM items WHERE slug = ?', [$os]) ?: $os);
            return local_form($slug, choice_row('🛠️', 'Make ' . (int)$oq . ' × ' . $on, 'Uses ' . implode(', ', $bits), '', '', ltrim($dis ?: ($lack ? ' disabled' : ''))), 'choiceform');
        case 'collect':   // v2.0.78
            [$set, $label, $entries, $n] = stop_collect_parts($spec);
            [, $data] = stop_prog_get((int)$u['id'], 0, 'set:' . $set);
            $found = count(array_intersect((array)($data['found'] ?? []), $entries));
            $p = stop_spec_params($spec);
            $h = '<span class="st-picks">';
            for ($i = 1; $i <= $n; $i++) $h .= '<button class="btn small alt" name="pick" value="' . $i . '"' . $dis . '>' . e($p['ico'] ?? '🔍') . ' ' . $i . '</button> ';
            return $f($h . '</span>') . '<span class="help">' . $found . ' of ' . count($entries) . ' ' . e($label) . ' in your journal. Look in one place.</span>';
        case 'tend':   // v2.0.78
            $p = stop_spec_params($spec);
            $steps = max(2, min(6, (int)($p['steps'] ?? 3)));
            [$have] = stop_prog_get((int)$u['id'], (int)$loc['id'], 'tend:' . $slug);
            return local_form($slug, choice_row('🧑‍🌾', (string)($p['label'] ?? 'Lend a hand'), 'Step ' . ($have + 1) . ' of ' . $steps . ($have ? ' · you did ' . $have . ' on earlier visits' : ''), '', '', ltrim($dis)), 'choiceform');
        case 'contest':   // v2.0.78
            $p = stop_spec_params($spec);
            $moves = array_values(array_filter(array_map('trim', explode('/', (string)($p['moves'] ?? 'Quick/Steady/Clever')))));
            if (count($moves) !== 3) $moves = ['Quick', 'Steady', 'Clever'];
            $h = '<span class="st-picks">';
            foreach ($moves as $i => $mv) $h .= '<button class="btn small alt" name="move" value="' . $i . '"' . $dis . '>' . e($mv) . '</button> ';
            return $f($h . '</span>') . '<span class="help">Each move beats one of the others and loses to the third.</span>';
        case 'gossip':
            return $f('<button class="btn small"' . $dis . '>Sit and listen</button>') . '<span class="help">you might hear of a hidden place</span>';
        case 'lore':
            return $f('<button class="btn small"' . $dis . '>Listen</button>');
    }
    return '';
}

/** v2.0.17: a stall activity (buy / snack) as a picture tile + sheet. Same POST as before (do=local, kind=slug); nothing about price or limits changes. */
function local_buy_tile(array $u, array $loc, array $a, bool $isDone, bool $locked): string
{
    require_once __DIR__ . '/shop_tiles.php';
    require_once __DIR__ . '/landmarks.php';   // shop_oneform()
    $spec = (string)$a['spec'];
    if ((string)$a['kind'] === 'snack') {
        $sn = stop_snack($loc);
        if (!$sn) return '<p class="muted">Sold out today.</p>';
        $item = q_one('SELECT * FROM items WHERE id = ?', [(int)$sn[0]['id']]);
        [$qty, $price] = [2, (int)$sn[1]];
        $blurb = 'Fresh from today’s bake';
    } else {
        [$bs, $bq, $bp] = array_pad(explode(':', $spec), 3, '');
        $item = q_one('SELECT * FROM items WHERE slug = ?', [$bs]);
        [$qty, $price] = [max(1, (int)$bq), max(0, (int)$bp)];
        $blurb = (string)$a['name'];
    }
    if (!$item) return '';
    $have = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [(int)$u['id'], (int)$item['id']]);
    $off = $isDone || $locked;
    $t = $GLOBALS['st_tab'] ?? 'do';
    $fields = ($t !== 'do' ? ['t' => $t] : []) + ['do' => 'local', 'kind' => (string)$a['slug']];
    $info = '<p class="help">Buy ' . $qty . ' × ' . e((string)$item['name']) . '. You have ' . $have . '.</p>'
        . ($isDone ? '<p class="help">✔ Done this visit.</p>' : ($locked ? '<p class="help">Come back later.</p>' : shop_oneform('', $fields, money($price) . ' for ' . $qty, 'Buy')));
    return shop_tile(['id' => (int)$a['id'], 'item' => $item, 'price' => $price, 'max' => 1, 'priceHtml' => money($price), 'mini' => '×' . $qty,
        'dim' => $off, 'offNote' => $isDone ? 'Done' : ($locked ? 'Later' : ''), 'badge' => $isDone ? '✔' : ($have > 0 ? (string)$have : ''), 'badgeTitle' => $isDone ? 'Done this visit' : 'You have', 'info' => $info]);
}

/** v2.0.67: the short meta chunks under a Do card's sign (escaped HTML each). Never cut: the row wraps between chunks. */
function local_act_meta(array $u, array $loc, array $a, ?array $folk): array
{
    $kind = (string)$a['kind'];
    $spec = (string)$a['spec'];
    $m = (int)$a['energy'] > 0 ? ['⚡' . (int)$a['energy']] : [];
    switch ($kind) {
        case 'check':
            $best = null; $ways = 0; $stat = '';
            foreach (explode(';', $spec) as $o) {
                $pp = array_map('trim', explode(':', $o, 3));
                if (count($pp) !== 3 || !isset(GNOME_STATS[$pp[0]])) continue;
                $ways++;
                $dc = (int)$pp[1];
                $ch = $dc <= 0 ? 100 : max(5, min(95, (21 - ($dc - eff_mod($u, $pp[0]))) * 5));
                if ($best === null || $ch > $best) { $best = $ch; $stat = $dc > 0 ? (string)GNOME_STATS[$pp[0]][0] : ''; }
            }
            if ($best !== null && $best < 100) $m[] = '<span class="gcard__odds">' . $best . '% · ' . stop_chance_word($best) . '</span>';
            $m[] = $ways > 1 ? $ways . ' ways' : ($stat !== '' ? e($stat) . ' check' : 'Always works');
            break;
        case 'rest':
            $c = (int)(stop_spec_params($spec)['cost'] ?? 0);
            $m[] = '🛏️ Rest';
            $m[] = $c ? e(money_txt($c)) : 'free';
            break;
        case 'pick':
            $m[] = 'Pick 1 of ' . max(2, min(6, (int)(stop_spec_params($spec)['n'] ?? 3)));
            break;
        case 'power':
            $m[] = 'How hard? 1 to ' . max(3, min(7, (int)(stop_spec_params($spec)['n'] ?? 5)));
            break;
        case 'swap':
            [$g, $r] = array_pad(explode('>', $spec), 2, '');
            [$gs, $gq] = array_pad(explode(':', $g), 2, '1');
            [, $rq] = array_pad(explode(':', $r), 2, '1');
            $have = (int)q_val('SELECT qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = ?', [(int)$u['id'], $gs]);
            $m[] = 'Give ' . (int)$gq . ' · get ' . (int)$rq;
            if ($have < (int)$gq) $m[] = 'you have ' . $have;
            break;
        case 'seedswap':
            $m[] = (int)q_val("SELECT COUNT(*) FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND i.category = 'seed'", [(int)$u['id']]) ? 'A seed for a seed' : 'No seeds to swap';
            break;
        case 'craft':   // v2.0.78
            [$ins, [$os, $oq]] = stop_craft_parts($spec);
            $m[] = 'Make ' . (int)$oq . ' × ' . e((string)(q_val('SELECT name FROM items WHERE slug = ?', [$os]) ?: $os));
            foreach ($ins as [$is, $iq]) if ((int)q_val('SELECT COALESCE(SUM(ui.qty), 0) FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = ?', [(int)$u['id'], $is]) < $iq) { $m[] = 'need more'; break; }
            break;
        case 'collect':
            [$set, $label, $entries, $n] = stop_collect_parts($spec);
            [, $data] = stop_prog_get((int)$u['id'], 0, 'set:' . $set);
            $m[] = count(array_intersect((array)($data['found'] ?? []), $entries)) . '/' . count($entries) . ' ' . e($label);
            break;
        case 'tend':
            $steps = max(2, min(6, (int)(stop_spec_params($spec)['steps'] ?? 3)));
            [$have] = stop_prog_get((int)$u['id'], (int)$loc['id'], 'tend:' . (string)$a['slug']);
            $m[] = 'Step ' . ($have + 1) . ' of ' . $steps;
            break;
        case 'contest':
            $m[] = 'Pick your move';
            break;
        case 'gossip':
            $m[] = 'Sit and listen';
            break;
        case 'lore':
            $m[] = 'Listen to a tale';
            break;
    }
    return $m;
}

/**
 * v2.0.67: one felt Do card (mockup2): picture, the name on a hanging sign, short meta. Tapping it opens a sheet with the blurb and the
 * same forms as before (local_act_buttons: do=local, kind=slug, CSRF, the seed select). States: idle; picked = its sheet is open (CSS);
 * done = disabled with a tick; locked = aria-disabled (still focusable, says why). $why = the locked reason ('' = not locked).
 */
function local_act_card(array $u, array $loc, array $a, bool $isDone, string $why, ?array $folk): string
{
    $slug = (string)$a['slug'];
    $art = stop_act_art((string)$a['kind'], $slug);
    $img = $art !== '' ? '<img class="pix" src="' . e(url($art)) . '" width="144" height="108" alt="" loading="lazy" decoding="async">' : '';
    $anim = $art !== '' ? stop_act_anim((string)$a['kind'], $slug) : '';   // v2.0.82: popover only; the card keeps $img
    $pimg = $art !== '' ? '<img class="pix doart-img" src="' . e(url($art)) . '" width="144" height="108" alt="" decoding="async"' . ($anim !== '' ? anim_strip_attrs($anim, 144) : '') . '>' : '';
    $name = e((string)$a['name']);
    $flag = !empty($a['now']) ? '<span class="gcard__flag">Right now</span>' : ((int)$a['tier'] > 0 && ($isDone || $why === '') ? '<span class="gcard__flag">Built here</span>' : '');
    $id = 'dowhy-' . preg_replace('/[^a-z0-9_-]/i', '', $slug);
    if ($isDone) {
        $meta = ['✔ Done this visit'];
        $attr = ' disabled';
    } elseif ($why !== '') {
        $meta = ['<span id="' . $id . '">' . e($why) . '</span>'];
        $attr = ' aria-disabled="true" aria-describedby="' . $id . '"';
    } else {
        $meta = local_act_meta($u, $loc, $a, $folk);
        $attr = ' data-sheet aria-haspopup="dialog"';
    }
    $h = '<div class="gcell"><button type="button" class="gcard docard"' . $attr . '>' . $flag
        . '<span class="gcard__art">' . $img . '</span>'
        . '<span class="gcard__ribbon"><span class="gcard__label">' . $name . '</span></span>'
        . '<span class="gcard__meta">' . implode('', array_map(fn($c) => str_starts_with($c, '<span') ? $c : '<span>' . $c . '</span>', $meta)) . '</span></button>';
    if (!$isDone && $why === '') {
        $blurb = stop_say((string)$a['blurb'], $loc, $folk);
        $h .= '<dialog class="isheet dosheet" aria-label="' . $name . '"><button type="button" class="sheetx" data-sheetx aria-label="Close">✕</button>'
            . '<div class="shead"><span class="sico doart" aria-hidden="true">' . $pimg . '</span><b class="sname">' . e((string)$a['icon']) . ' ' . $name . '</b></div>'
            . ($blurb !== '' ? '<p class="st-blurb">' . e($blurb) . '</p>' : '')
            . '<div class="doacts">' . local_act_buttons($u, $loc, $a, false) . '</div></dialog>';
    }
    return $h . '</div>';
}

/** v2.0.77: the errand parts for one villager (parcels to hand over, a favour on offer). $form(kind, inner) builds a form: the page's own or the overlay's. */
function local_folk_errands(array $u, array $loc, array $folk, array $deliver, callable $form): string
{
    $uid = (int)$u['id'];
    $h = '';
    foreach ($deliver as $e) {
        if ((int)$e['target_folk_id'] === (int)$folk['id']) {
            $h .= $form('_deliver', '<input type="hidden" name="errand" value="' . (int)$e['id'] . '"><button class="btn small">' . ($e['kind'] === 'escort' ? '🐾 Hand over your charge' : '📦 Deliver the parcel') . ' from ' . e($e['giver']) . '</button>');
        }
    }
    $o = stop_errand_offer($u, $loc, $folk);
    if ($o && isset($o['taken'])) {
        $h .= '<p class="help">✔ You helped ' . e($folk['name']) . ' today.</p>';
    } elseif ($o) {
        if ($o['kind'] === 'fetch') {
            $have = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, (int)$o['item']['id']]);
            $h .= '<p class="st-errand">📌 “Could you bring me ' . (int)$o['qty'] . ' × ' . e($o['item']['name']) . '?” <small class="muted">+' . (int)$o['coins'] . ' ' . e(setting('currency_name')) . ' · you have ' . $have . '</small></p>'
                . $form('_errand', '<input type="hidden" name="folk" value="' . (int)$folk['id'] . '"><button class="btn small"' . ($have < (int)$o['qty'] ? ' disabled' : '') . '>Hand over</button>');
        } else {
            $h .= '<p class="st-errand">📌 “' . ($o['kind'] === 'escort' ? 'Would you walk ' . e($o['thing']) . ' to ' : 'Could you carry ' . e($o['thing']) . ' to ') . '<b>' . e($o['target']['name']) . '</b> at ' . e($o['target_place']) . '?” <small class="muted">+' . (int)$o['coins'] . ' ' . e(setting('currency_name')) . '</small></p>'
                . $form('_errand', '<input type="hidden" name="folk" value="' . (int)$folk['id'] . '"><button class="btn small">' . ($o['kind'] === 'escort' ? 'Take them along' : 'Take it') . '</button>');
        }
    }
    return $h;
}

/** One villager card with friendship, chat and the errand. */
function local_folk_card(array $u, array $loc, array $folk, array $deliver): string
{
    $uid = (int)$u['id'];
    $pts = stop_friend_points($uid, (int)$folk['id']);
    $lvl = stop_friend_level($pts);
    $talked = (string)q_val('SELECT last_talk FROM stop_friend WHERE user_id = ? AND folk_id = ?', [$uid, (int)$folk['id']]) === hollow_date('Y-m-d');
    $hearts = str_repeat('💛', $lvl['index']) . str_repeat('🤍', 3 - $lvl['index']);
    // v2.0.77: the button opens the overlay (chat, gift, errand without a reload); without JavaScript it is still the old chat form
    $act = local_form('_chat', '<input type="hidden" name="folk" value="' . (int)$folk['id'] . '"><button class="fbtn" data-folk-stop="' . (int)$folk['id'] . '">💬 ' . ($talked ? 'Chat again' : 'Say hello') . '</button>');
    $h = local_folk_errands($u, $loc, $folk, $deliver, fn(string $k, string $inner) => local_form($k, $inner));   // errand parts: folded under the shared villager row (v2.0.65)
    return villager_row_html(npc_icon($folk['species']), e($folk['name']),
        [e($folk['role']) . ' · ' . e($folk['species']) . ' · ' . e($folk['personality']),
         '<span title="' . e($lvl['name']) . '">' . $hearts . ' ' . e($lvl['name']) . ($lvl['next'] !== null ? ' <span class="muted">(' . $pts . '/' . $lvl['next'] . ')</span>' : '') . '</span>'],
        $act, $h, '📜 Errand', $h !== '');
}

/**
 * v2.0.77: the picture of a rest-stop villager by species: our own pixel icon where one is drawn (assets/img/ico), else a PLACEHOLDER square
 * (assets/img/folk/<species>.png, red border: real art in claude/todo-art-variety.md), else the species emoji.
 */
function stop_folk_img(array $folk): string
{
    $sp = strtolower((string)$folk['species']);
    foreach (['mouse', 'bee', 'hedgehog', 'snail', 'frog', 'beetle', 'butterfly', 'cricket', 'ladybird'] as $k) {
        if (str_contains($sp, $k) && pixel_has('assets/img/ico/ico-' . $k . '.png')) return '<img class="portrait folkimg pix" src="' . e(url('assets/img/ico/ico-' . $k . '.png')) . '" alt="' . e((string)$folk['species']) . '" width="72" height="72">';
    }
    foreach (['hare', 'wren', 'mole', 'tortoise', 'moth', 'shrew', 'gecko', 'dragonfly', 'toad', 'grasshopper', 'firefly'] as $k) {
        if (str_contains($sp, $k) && pixel_has('assets/img/folk/' . $k . '.png')) return '<img class="portrait folkimg pix" src="' . e(url('assets/img/folk/' . $k . '.png')) . '" alt="' . e((string)$folk['species']) . '" width="72" height="72">';
    }
    return '<div class="portrait folkimg">' . npc_icon((string)$folk['species']) . '</div>';
}

/**
 * v2.0.77: a villager of the stop you are standing in, as the overlay panel: face, hearts, bio, chat, a gift, and the errand.
 * Every form posts to stopfolk.php (data-sform) and gets the panel back. Returns '' if they are not here.
 */
function stop_folk_panel(array $u, array $loc, int $folkId, string $msg = '', bool $ok = true): string
{
    $uid = (int)$u['id'];
    $folk = q_one('SELECT * FROM stop_folk WHERE id = ? AND location_id = ? AND active = 1', [$folkId, (int)$loc['id']]);
    if (!$folk) return '';
    $pts = stop_friend_points($uid, $folkId);
    $lvl = stop_friend_level($pts);
    $today = hollow_date('Y-m-d');
    $row = q_one('SELECT last_talk, last_gift FROM stop_friend WHERE user_id = ? AND folk_id = ?', [$uid, $folkId]) ?: ['last_talk' => null, 'last_gift' => null];
    $hearts = str_repeat('💛', $lvl['index']) . str_repeat('🤍', 3 - $lvl['index']);
    $f = fn(string $k, string $inner) => '<form method="post" action="' . e(url('stopfolk.php')) . '" class="vact" data-sform="1">' . csrf_field() . '<input type="hidden" name="folk" value="' . $folkId . '"><input type="hidden" name="do" value="' . e($k) . '">' . $inner . '</form>';
    $h = '<div class="vpanel box" data-folk="' . $folkId . '">';
    if ($msg !== '') $h .= '<p class="vmsg ' . ($ok ? 'ok' : 'err') . '" role="status">' . e($msg) . '</p>';
    $h .= '<div class="npchead"><div class="npcpic">' . stop_folk_img($folk) . '</div><div class="npcid"><h2>' . e($folk['name']) . '</h2>'
        . '<p class="muted">' . e($folk['role']) . ' · ' . e($folk['species']) . ' · ' . e($folk['personality']) . '</p>'
        . '<p>' . $hearts . ' ' . e($lvl['name']) . ($lvl['next'] !== null ? ' <span class="muted">(' . $pts . '/' . $lvl['next'] . ')</span>' : '') . '</p>'
        . '<p>📍 ' . e($loc['name']) . '</p></div></div>';
    if (!empty($folk['bio'])) $h .= '<p>' . e((string)$folk['bio']) . '</p>';
    $h .= $f('chat', '<button class="btn"' . ($row['last_talk'] === $today ? ' disabled' : '') . '>💬 ' . ($row['last_talk'] === $today ? 'Chatted today' : 'Say hello') . '</button>');
    if ($row['last_gift'] === $today) {
        $h .= '<p class="help">🎁 Gift given today.</p>';
    } elseif (!($giftable = stop_giftable($uid))) {
        $h .= '<p class="help">🎁 Nothing in your Satchel to give.</p>';
    } else {
        require_once __DIR__ . '/friends.php';
        $fake = ['slug' => 'stop-' . $folkId, 'name' => $folk['name']];   // (no id: npc_tastes would try to store a favourite on the npcs table)
        $sel = '<select name="item_id" aria-label="Gift">';
        foreach ($giftable as $g) $sel .= '<option value="' . (int)$g['id'] . '">' . e($g['name']) . ' ×' . (int)$g['qty'] . '</option>';
        $sel .= '</select>';
        $h .= '<p class="vact"><button type="button" class="btn alt" data-giftopen="1">🎁 Give a gift</button></p><noscript>' . $f('gift', $sel . ' <button class="btn alt">🎁 Give</button>') . '</noscript>'
            . gift_picker_html($fake, [], $giftable, false, url('stopfolk.php'), '<input type="hidden" name="folk" value="' . $folkId . '">', ' data-sform="1"');
    }
    $deliver = array_filter(stop_errands_active($uid), fn($e) => (int)$e['target_loc'] === (int)$loc['id']);
    $h .= local_folk_errands($u, $loc, $folk, $deliver, $f);
    return $h . '</div>';
}

/** v2.0.77: the overlay's mount point and script, once per page (assets/folkoverlay.js). Buttons with data-folk-npc / data-folk-stop open it. */
function folk_overlay_html(): string
{
    static $done = false;
    if ($done) return '';
    $done = true;
    return '<div id="folkov" hidden data-csrf="' . e(csrf_token()) . '" data-npc="' . e(url('villagers.php')) . '" data-page="' . e(url('folk.php')) . '" data-stop="' . e(url('stopfolk.php')) . '"></div>'
        . '<script src="' . e(url('assets/folkoverlay.js?v=' . APP_VERSION)) . '" defer></script>';
}

/** The local page for a village (shown on the Town tab when you're not in a town). */
function local_panel(array $u, array $loc): string
{
    $uid = (int)$u['id'];
    $types = stop_types();
    $type = stop_type_of($loc);
    $t = $types[$type] ?? ['icon' => '🪧', 'name' => 'Rest stop', 'hue' => 100, 'ambience' => '', 'intro' => ''];
    [$isNew, $stampMsgs] = stop_stamp($uid, $loc);
    $now = stop_now($loc);
    $rc = stop_region_code($loc);
    $wi = hollow_weather_info($now['we'], $now['dp']);
    $amb = array_map('trim', explode(';;', (string)$t['ambience']));
    $ambLine = $amb[array_search($now['dp'], ['dawn', 'day', 'dusk', 'night'], true)] ?? ($amb[0] ?? '');
    $visit = stop_visit_key($u);
    [$done, $here, $all, $rests] = stop_state($uid, (int)$loc['id'], $visit);
    $slots = stop_slots($loc);
    $left = max(0, $slots - count($done));
    $capHere = max(1, (int)setting('stop_daily_cap'));
    $capAll = max(1, (int)setting('stop_daily_total'));
    $capped = $here >= $capHere;   // v1.4.9: the daily total is a soft limit (rewards halve), never a stop
    $tired = $all >= $capAll;
    $pool = stop_pool($loc, $now);
    $adoption = stop_adoption((int)$loc['id']);
    $tier = $adoption ? (int)$adoption['tier'] : 0;

    $h = '<section class="st" data-sh="' . (int)$t['hue'] . '" data-stop-type="' . e($type) . '" data-dp="' . e($now['dp']) . '">';
    $h .= '<header class="st-head"><div class="st-art">' . stop_svg($type, 'icon', 'st-ico-lg') . '</div><div class="st-headtxt"><h2>' . e($t['name']) . '</h2><p class="st-amb">' . e($ambLine) . '</p>'
        . '<p class="st-chips"><span class="chip">' . HOLLOW_DAYPARTS[$now['dp']][0] . ' ' . HOLLOW_DAYPARTS[$now['dp']][1] . '</span><span class="chip">' . $wi['emoji'] . ' ' . e($wi['label']) . '</span><span class="chip">' . HOLLOW_SEASONS[$now['se']][0] . ' ' . HOLLOW_SEASONS[$now['se']][1] . '</span>'
        . ($tier ? '<span class="chip">★ Tier ' . $tier . '</span>' : '') . '</p></div></header>';
    if ($isNew || $stampMsgs) {
        $h .= '<div class="box notice st-newstamp"><div class="st-stamp has" data-sh="' . (int)$t['hue'] . '">' . stop_svg($type, 'stamp', 'st-stamp-art') . '<b>' . e($loc['name']) . '</b></div><div>';
        foreach ($stampMsgs as $m) $h .= '<p>' . e($m) . '</p>';
        $h .= '<p class="help"><a href="' . e(url('town.php?view=passport')) . '">Open your passport →</a></p></div></div>';
    }
    // slots
    $pips = '';
    for ($i = 0; $i < $slots; $i++) $pips .= '<span class="st-pip' . ($i < count($done) ? ' on' : '') . '"></span>';
    if ($capped) $banner = '<b>💤 That’s enough here for today</b><span class="muted">You’ve had your ' . $capHere . ' turns at this stop today. Walk on, other stops are still open!</span>';
    elseif ($left === 0) $banner = '<b>✔ You’ve done all ' . $slots . ' things this visit</b><span class="muted">Walk on and come back later for more (up to ' . $capHere . ' a day here).</span>';
    else $banner = '<b>Stay a while: ' . $left . ' of ' . $slots . ' things left this visit</b><span class="muted">Do up to ' . $slots . ' different things before you walk on. ' . $here . '/' . $capHere . ' today at this stop.</span>';
    $h .= '<div class="st-slots"><div class="st-pips" aria-hidden="true">' . $pips . '</div><div>' . $banner . '</div></div>';
    if ($tired) $h .= '<p class="help st-tired">😴 The villagers are tired after your busy day: Petals and XP from rest stops are halved until tomorrow (items as usual).</p>';   // v1.4.9
    // v1.3.0: tabs. Do (things to do), Folk (villagers and errands), Stop (plaque, passport, adopting)
    $tab = (string)($_GET['t'] ?? 'do');
    if (!in_array($tab, ['do', 'folk', 'stop'], true)) $tab = 'do';
    $GLOBALS['st_tab'] = $tab;
    $deliver = array_filter(stop_errands_active($uid), fn($e) => (int)$e['target_loc'] === (int)$loc['id']);
    $folk = stop_folk_of($loc);
    $ready = count($deliver);
    foreach ($folk as $f) {
        $o = stop_errand_offer($u, $loc, $f);
        if ($o && !isset($o['taken']) && $o['kind'] === 'fetch' && (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, (int)$o['item']['id']]) >= (int)$o['qty']) $ready++;
    }
    $tabs = ['do' => '🧭 Do', 'folk' => '👥 Villagers', 'stop' => '🏡 Stop'];
    $h .= '<nav class="tabs st-tabs" aria-label="Rest stop sections">';
    foreach ($tabs as $k => $lab) {
        $h .= '<a class="' . ($tab === $k ? 'on' : '') . '" href="' . e(url('town.php' . ($k === 'do' ? '' : '?t=' . $k))) . '">' . $lab . ($k === 'folk' && $ready ? ' <span class="st-tabbadge" title="Ready to hand in" aria-label="' . $ready . ' ready to hand in">' . $ready . '</span>' : '') . ($k === 'do' && $left > 0 && !$capped ? ' <span class="st-tabbadge soft">' . $left . '</span>' : '') . '</a>';
    }
    $h .= '</nav>';

    if ($tab === 'stop') {
        $h .= '<p class="st-intro muted">' . e((string)$t['intro']) . '</p>' . stop_plaque($loc);
        if ($pool['tiers'] && stop_adopt_limit() > 0) {
            $h .= '<details class="st-later"><summary>🏡 Unlocked by an adopter (' . count($pool['tiers']) . ')</summary><ul>';
            foreach ($pool['tiers'] as $a) $h .= '<li>' . e((string)$a['icon']) . ' <b>' . e((string)$a['name']) . '</b> <small class="muted">needs tier ' . (int)$a['tier'] . '</small></li>';
            $h .= '</ul></details>';
        }
        $h .= '<p class="help">📖 <a href="' . e(url('town.php?view=passport')) . '">Your stamp passport</a> · ' . count(stop_stamps_of($uid)) . ' stamps</p>';
        $h .= stop_adopt_panel($u, $loc, fn(string $k, string $inner) => local_form($k, $inner));
        $h .= season_fold_html($u) . land_card_html($u, $loc, !empty($loc['region_id']) ? q_one('SELECT * FROM regions WHERE id = ?', [$loc['region_id']]) : null);   // v2.0.61: Seasons and Land live on the Stop tab
        return $h . '</section>';
    }
    if ($tab === 'folk') {
        $act = stop_errands_active($uid);
        if ($act) {
            $h .= '<h3 class="st-h">📦 Errands you’re carrying</h3><ul class="st-errlist">';
            foreach ($act as $e) {
                $h .= '<li>' . ($e['kind'] === 'escort' ? '🐾' : '📦') . ' From <b>' . e($e['giver']) . '</b> (' . e($e['giver_place']) . ') to <b>' . e((string)$e['target']) . '</b> at ' . e((string)$e['target_place'])
                    . ' <small class="muted">by ' . e((string)$e['expires_day']) . ' · +' . (int)$e['coins'] . ' ' . e(setting('currency_name')) . '</small>'
                    . local_form('_drop', '<input type="hidden" name="errand" value="' . (int)$e['id'] . '"><button class="btn small alt" data-confirm="Hand this errand back?">Give up</button>') . '</li>';
            }
            $h .= '</ul>';
        }
        $h .= '<h3 class="st-h gx-h">👥 Who’s about</h3><ul class="vlcards st-folks">';   // v2.0.67: felt villager rows
        foreach ($folk as $f) $h .= local_folk_card($u, $loc, $f, $deliver);
        return $h . '</ul>' . folk_overlay_html() . '</section>';
    }

    // activities
    // v2.0.67: felt scene cards (mockup2); each opens a sheet with the blurb and the same forms as before
    $head = '<h3 class="st-h gx-h">🧭 Things to do <span class="gx-h__sub">' . ($capped ? 'enough here today' : $left . ' of ' . $slots . ' left this visit') . '</span></h3><div class="gcards docards">';
    $locked = $capped || $left === 0;
    $why = $capped ? 'Enough here today' : ($left === 0 ? 'Walk on for more' : '');
    $folk0 = $folk[0] ?? null;
    $shelf = '';
    $acts = '';   // v2.0.80: the stall goes above the activity cards, so the cards are collected first
    foreach ($pool['offer'] as $a) {
        $isDone = in_array($a['slug'], $done, true);
        if (in_array((string)$a['kind'], ['buy', 'snack'], true)) { $shelf .= local_buy_tile($u, $loc, $a, $isDone, $locked); continue; }   // v2.0.17: stalls are picture tiles
        $acts .= local_act_card($u, $loc, $a, $isDone, $why, $folk0);
    }
    if ($pool['tiers'] && stop_adopt_limit() > 0) {   // the next adopter tier's activities, locked, saying the tier they need (the Stop tab lists every tier)
        $nextTier = min(array_map(fn($a) => (int)$a['tier'], $pool['tiers']));
        foreach ($pool['tiers'] as $a) if ((int)$a['tier'] === $nextTier && !in_array((string)$a['kind'], ['buy', 'snack'], true)) $acts .= local_act_card($u, $loc, $a, false, 'Needs tier ' . $nextTier, $folk0);
    }
    $acts .= '</div>';
    if ($shelf !== '') $h .= '<div class="mkstall"><h3 class="st-h">🛒 For sale</h3><div class="shopwrap">' . item_grid($shelf) . '</div></div>';
    $h .= $head . $acts;
    if ($pool['later']) {
        $h .= '<details class="st-later"><summary>🕰️ Other times here (' . count($pool['later']) . ')</summary><ul>';
        foreach ($pool['later'] as $a) $h .= '<li>' . e((string)$a['icon']) . ' <b>' . e((string)$a['name']) . '</b> <small class="muted">' . e(stop_cond_text((string)$a['cond'])) . '</small></li>';
        $h .= '</ul></details>';
    }
    return $h . '</section>';
}
