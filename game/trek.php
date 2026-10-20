<?php
declare(strict_types=1);
// v1.8.0 Treks: a party campaign. Tabs ?t=map|party|pack|log. Every POST runs through trek_tx() (transaction + gnome lock + run re-read).
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/trek.php';
require_once __DIR__ . '/includes/trek_art.php';   // v1.8.10: the map art
$u = require_login();
$uid = (int)$u['id'];
refresh_energy($u);
[$open, $closedWhy] = trek_gate($u);
trek_text_vars(['gnome' => gnome_name($u), 'calling' => (string)(CALLINGS[$u['calling'] ?? ''][0] ?? 'gnome'), 'currency' => setting('currency_name')]);
$tab = in_array($_GET['t'] ?? '', ['map', 'party', 'pack', 'log'], true) ? (string)$_GET['t'] : 'map';
trek_ch_ensure();   // v1.9.1: per-chapter runs: the users columns and the new unique index, if the upgrade has not made them yet (outside any transaction)
trek_ms_ensure();   // v1.8.9: the once-only milestone table (outside any transaction), in case the upgrade has not created it yet

/** Security pass (1.9.0): one POST field as a string; a field sent as an array (a[]=..) counts as empty instead of raising "Array to string conversion". */
function trek_post_str(string $k): string
{
    $v = $_POST[$k] ?? '';
    return is_scalar($v) ? (string)$v : '';
}

/** Security pass (1.9.0): one POST field as an int; a field sent as an array gives the default. */
function trek_post_int(string $k, int $default): int
{
    return is_scalar($_POST[$k] ?? null) ? (int)$_POST[$k] : $default;
}

/** The fight choices from the form: slot => [a, t, item]. Only known words and shapes get through. */
function trek_post_acts(): array
{
    $acts = [];
    foreach ((array)($_POST['a'] ?? []) as $slot => $a) {
        if ((int)$slot < 0 || (int)$slot > 3) continue;   // security pass: a party has 4 places; more keys would only bloat the saved plan
        if (!is_scalar($a) || !in_array((string)$a, ['attack', 'ability', 'snack', 'guard'], true)) continue;
        $t = is_array($_POST['t'] ?? null) && is_scalar($_POST['t'][$slot] ?? null) ? (string)$_POST['t'][$slot] : '';
        $acts[(int)$slot] = ['a' => (string)$a, 't' => preg_match('/^[fa]:\d+$/', $t) ? $t : '', 'item' => is_scalar($_POST['item'] ?? null) ? (int)$_POST['item'] : 0];
    }
    return $acts;
}

/** v1.8.4: one POST action, plus the fight plan memory: a manual round saves the picks (st.plan); it is dropped when the fight ends, and st.back marks the turn a fight just ended (so the map can fade in). */
function trek_dispatch(?array &$run, array $u, string $do): array
{
    $was = !empty($run['fi']);
    if ($run && !$was) unset($run['st']['flog_on']);   // v1.8.8: the last fight's log stops recording once a new action begins (it stays for the Log tab)
    if ($do === 'round' && $was) {
        $plan = ['m' => [], 'item' => 0];
        foreach (trek_post_acts() as $slot => $a) {
            $plan['m'][$slot] = ['a' => $a['a'], 't' => $a['t']];
            if ($a['item'] > 0 && !$plan['item']) $plan['item'] = $a['item'];
        }
        $run['st']['plan'] = $plan;
    }
    $res = trek_dispatch_do($run, $u, $do);
    if ($run) {
        if (!$run['fi']) {
            unset($run['st']['plan']);
            if ($was) $run['st']['back'] = (int)($run['st']['turn'] ?? 0);
        } elseif (!$was) {
            unset($run['st']['plan']);
        }
    }
    return $res;
}

/** v1.8.6: save one member's tactics (stored per run under st.tac[crew key]). The member must be in this player's party; every field is checked against the whitelist for their calling. */
function trek_act_tactics(array &$run, array $u): array
{
    $slot = trek_post_int('slot', -1);
    $stats = trek_party_stats($run, $u);
    if (!isset($stats[$slot])) return [false, 'Pick someone in your party.'];
    $m = $stats[$slot];
    $raw = [];
    foreach (['open', 'rule', 'pct', 'shield', 'target', 'snack'] as $k) if (isset($_POST[$k]) && is_scalar($_POST[$k])) $raw[$k] = (string)$_POST[$k];
    if (preg_match('/^friendlow(30|40|50|60)$/', $raw['rule'] ?? '', $mm)) { $raw['rule'] = 'friendlow'; $raw['pct'] = $mm[1]; }   // one select: "a friend is below 40%"
    $clean = trek_tac_clean((string)$m['calling'], $slot === 0, $raw);
    if ($clean === trek_tac_clean((string)$m['calling'], $slot === 0, [])) unset($run['st']['tac'][$m['key']]);
    else $run['st']['tac'][$m['key']] = $clean;
    if (empty($run['st']['tac'])) unset($run['st']['tac']);
    return [true, trek_first_name((string)$m['name']) . '’s tactics saved.'];
}

/** v1.9.1: the actions of the interlude (a finished chapter's rest stop). Anything else, walking and entering the old map included, is refused. */
function trek_dispatch_hub(array &$run, array $u, string $do): array
{
    if (trek_hub_pending($run)) trek_hub_arrive($run, $u);   // still carrying finds, or still marked inside: bank and close the run first
    switch ($do) {
        case 'dismiss': unset($run['st']['show_done']); return [true, ''];
        case 'rest': return trek_hub_rest($run, $u);
        case 'buy_kit': return trek_buy_kit($run, $u);
        case 'party': return trek_set_party($run, $u, [1 => trek_post_str('p1'), 2 => trek_post_str('p2'), 3 => trek_post_str('p3')]);
        case 'tactics': return trek_act_tactics($run, $u);
        case 'talk': return trek_hub_talk($run, $u, trek_post_str('who'));
        case 'godown': return trek_godown($run, $u);
    }
    return [false, 'That chapter is behind you. Rest here, then go down.'];
}

/** One POST action. Returns [ok, message] (message may be ''). */
function trek_dispatch_do(?array &$run, array $u, string $do): array
{
    if ($run && trek_run_done($run)) return trek_dispatch_hub($run, $u, $do);   // v1.9.1: a finished chapter is never walked again
    if ($do === 'begin' || $do === 'enter') return trek_enter($run, $u);
    if (!(int)$run['inside']) return [false, 'You’re not on the trek.'];
    switch ($do) {
        case 'leave': return trek_leave($run);
        case 'go':
            if (!preg_match('/^(\d{1,2}),(\d{1,2})$/', trek_post_str('go'), $m)) return [false, 'Pick a tile.'];
            return trek_walk($run, $u, (int)$m[1], (int)$m[2]);
        case 'mode':
            if ($run['fi']) return [false, 'Not during a fight.'];
            trek_set_sneak($run, trek_post_str('mode') === 'sneak');
            return [true, ''];
        case 'makecamp': return trek_make_camp($run, $u);
        case 'rest': return trek_camp_rest($run, $u);
        case 'buy_kit': return trek_buy_kit($run, $u);
        case 'party': return trek_set_party($run, $u, [1 => trek_post_str('p1'), 2 => trek_post_str('p2'), 3 => trek_post_str('p3')]);
        case 'recruit': return trek_act_recruit($run, $u);
        case 'fetch': return trek_act_fetch($run, $u);
        case 'chest': return trek_act_chest($run, $u);
        case 'riddle': return trek_act_riddle($run, $u, trek_post_int('ans', 0), trek_post_str('how'));
        case 'grotto': return trek_act_hidden($run, $u);
        case 'challenge': return trek_act_challenge($run, $u);
        case 'dismiss': unset($run['st']['show_done']); return [true, ''];
        case 'msdismiss': unset($run['st']['msc']); return [true, ''];   // v1.8.9: the milestone card
        case 'tactics': return trek_act_tactics($run, $u);
        case 'event': return trek_act_event($run, $u, trek_post_int('c', -1));          // v1.8.8: trail event choice (0 = walk on)
        case 'crew': return trek_act_crew($run, $u, trek_post_int('c', 1));            // v1.8.8: a trailmate's tiny task (0 = not now)
        case 'cart': return trek_act_cart($run, $u, trek_post_str('how'));
        case 'mush': return trek_act_mush($run, $u);
        case 'switch': return trek_act_switch($run, $u);   // v1.9.2: Chapter II-a
        case 'trade': return trek_act_trade($run, $u);
        case 'rest_spot': return trek_act_rest($run, $u);
        case 'rest_old': return trek_act_oldcamp($run, $u);                              // v2.0.1: old campsites
        case 'slide': return trek_act_slide($run, $u);                                   // v1.9.4: Chapter II-b
        case 'travel': return trek_act_travel($run, $u, trek_post_str('to'));
    }
    if (!$run['fi']) return [false, 'There’s no fight.'];
    switch ($do) {
        case 'round': trek_fight_round($run, $u, trek_post_acts()); return [true, ''];
        case 'auto': trek_fight_auto($run, $u, 40, true); return [true, ''];
        case 'auto1': trek_fight_auto($run, $u, 1); return [true, ''];
        case 'flee': trek_fight_flee($run, $u); return [true, ''];
    }
    return [false, 'Unknown action.'];
}

if (is_post()) {
    csrf_check();
    $do = trek_post_str('do');
    if (!$open) { flash($closedWhy, 'err'); redirect('trek.php'); }
    $res = trek_tx($uid, function (?array &$run, array $uu) use ($do) { return trek_dispatch($run, $uu, $do); }, $do !== 'begin' && $do !== 'enter');
    if (is_array($res) && $res[1] !== '') flash($res[1], $res[0] ? 'ok' : 'err');
    if ($res === null) flash('Begin the trek first.', 'err');
    $back = in_array(trek_post_str('t'), ['party', 'pack', 'log'], true) ? trek_post_str('t') : 'map';
    redirect('trek.php' . ($back !== 'map' ? '?t=' . $back : ''));
}

// ------------------------------------------------------------------ view helpers

/** v1.8.5: the one-shot replay of the last Auto (taken from the session) as a hidden stage for assets/trekfight.js, or ''. Fresh for 30 s, this run only. */
function trek_replay_stage(array $run, array $u): string
{
    $r = $_SESSION['trek_replay'] ?? null;
    unset($_SESSION['trek_replay']);
    if (!is_array($r) || (int)($r['run'] ?? 0) !== (int)$run['id'] || time() - (int)($r['t'] ?? 0) > 30 || empty($r['r'])) return '';
    return '<div class="trekreplay" hidden data-replay="' . e((string)json_encode(['s' => $r['s'], 'r' => $r['r']], JSON_UNESCAPED_UNICODE)) . '"><template class="meico-tpl">' . trek_me_ico($u) . '</template></div>';   // v1.9.0: the player's gnome, drawn by the server, for the replay's party row
}

/** A small POST form with one button. $extra = [name => value] hidden fields. $formAttrs = raw, already escaped attributes for the form (v1.9.0: trek_leave_confirm()). */
/** v1.9.0: the data-confirm attribute for both Leave buttons (map and exit spot). */
function trek_leave_confirm(): string
{
    return ' data-confirm="' . e('Leave the trek? Your spot, pack and banked items stay. Going back in costs ' . (int)setting('trek_entry_energy') . ' ⚡.') . '"';
}

function trek_form(string $do, string $label, array $extra = [], string $class = 'btn', string $formAttrs = ''): string
{
    $h = '';
    foreach ($extra as $k => $v) $h .= '<input type="hidden" name="' . e($k) . '" value="' . e((string)$v) . '">';
    return '<form method="post" class="inline"' . $formAttrs . '>' . csrf_field() . '<input type="hidden" name="do" value="' . e($do) . '">' . $h . '<button class="' . e($class) . '">' . e($label) . '</button></form> ';
}

/** A choice row as a submit button of the surrounding form. */
function trek_choice(string $do, string $icon, string $title, string $sub = '', $badge = '', string $cls = '', array $attrs = []): string
{
    $a = 'type="submit" name="do" value="' . e($do) . '"';
    foreach ($attrs as $k => $v) $a .= ' ' . e($k) . '="' . e((string)$v) . '"';
    return choice_row($icon, $title, $sub, $badge, $cls, $a);
}

function trek_bar(int $v, int $max, string $cls = ''): string
{
    return '<progress class="' . e($cls) . '" max="' . max(1, $max) . '" value="' . max(0, min($max, $v)) . '"></progress>';
}

/** The map window: one SVG of art (assets: includes/trek_art.php) with the tile buttons as a transparent grid on top. 15x11 for desktop, 9x9 for phones;
 * CSS picks (classes tx/ty = desktop cell, ta/tb = phone cell, o9 = outside the phone window; wx/wy shift the art for the phone window). $walk = the walk just taken, or null. */
function trek_map_html(array &$run, array $u, ?array $walk = null): string
{
    $m = trek_map((int)$run['chapter']);
    $px = (int)$run['x'];
    $py = (int)$run['y'];
    $win = function (int $cols, int $rows) use ($m, $px, $py) {
        return [max(0, min($m['w'] - $cols, $px - intdiv($cols, 2))), max(0, min($m['h'] - $rows, $py - intdiv($rows, 2)))];
    };
    [$x0, $y0] = $win(15, 11);
    [$a0, $b0] = $win(9, 9);
    $obj = trek_objective($run);
    $icons = TREK_SPOT_ICONS;
    $tokens = [];
    $btn = '';
    for ($y = $y0; $y < $y0 + 11; $y++) {
        for ($x = $x0; $x < $x0 + 15; $x++) {
            $c = trek_tile((int)$run['chapter'], $x, $y);
            $seen = trek_seen_get($run, $x, $y);
            $cls = 'tile tx' . ($x - $x0 + 1) . ' ty' . ($y - $y0 + 1);
            $inPhone = $x >= $a0 && $x < $a0 + 9 && $y >= $b0 && $y < $b0 + 9;
            $cls .= $inPhone ? ' ta' . ($x - $a0 + 1) . ' tb' . ($y - $b0 + 1) : ' o9';
            $label = '';
            $inner = '';
            $spot = (ctype_upper($c) || ctype_digit($c)) ? trek_spot_at((int)$run['chapter'], $x, $y) : null;
            if ($spot && $spot['type'] === 'hidden' && !trek_spot_visible($run, $u, $spot)) $spot = null;
            if (!$seen) {
                $cls .= ' fog';
            } elseif ($spot) {
                $locked = $spot['type'] === 'gate' && !trek_gate_open($run, $spot);
                $done = $spot['type'] !== 'gate' && !in_array($spot['type'], ['start', 'exit', 'camp', 'npc', 'sign', 'oldcamp'], true) && trek_spot_done($run, $spot);
                $ico = !empty($spot['data']['icon']) ? (string)$spot['data']['icon'] : ($spot['type'] === 'gate' ? ($locked ? '🚧' : '') : ($icons[$spot['type']] ?? '•'));   // v1.9.4: a spot may carry its own icon (data icon=)
                $cls .= ' spot' . ($done ? ' done' : '') . ($locked ? ' locked' : '');
                $label = $spot['name'];
                if ($ico !== '' && !($x === $px && $y === $py)) $tokens[] = [$x, $y, $ico, in_array($spot['type'], ['duel', 'miniboss', 'boss'], true) ? 'ember' : 'gold', $done];
                if ($obj && $obj['code'] === $spot['code']) { $cls .= ' obj'; $inner = '<i class="objmark" aria-hidden="true">!</i>'; $label .= ' (next)'; }
            }
            if ($x === $px && $y === $py) { $cls .= ' here'; $inner = ''; $label = 'You are here'; }
            $walkable = $seen && !in_array($c, ['#', '^', ' ', '*'], true) && !($x === $px && $y === $py);
            $btn .= '<button class="' . $cls . '" name="go" value="' . $x . ',' . $y . '"' . ($walkable ? '' : ' disabled') . ($label !== '' ? ' aria-label="' . e($label) . '"' : ' tabindex="-1"') . '>' . $inner . '</button>';
        }
    }
    $data = '';
    if ($walk) $data = ' data-x0="' . $x0 . '" data-y0="' . $y0 . '" data-walk="' . e(implode(';', array_map(fn($p) => $p[0] . ',' . $p[1], $walk['p']))) . '"';
    $h = '<div class="trekmap tkart wx' . ($a0 - $x0) . ' wy' . ($b0 - $y0) . '" role="group" aria-label="Map"' . $data . '>'
        . trek_art_svg((int)$run['chapter'], $run, $x0, $y0, 15, 11, $tokens, $walk, trek_art_me($u))
        . '<span class="tkchip" hidden></span>';
    return $h . $btn . '</div>';
}

/** v1.9.2: the key to the new tile signs (never colour alone), shown under the map of a chapter that has them. */
function trek_legend_html(array $run): string
{
    $m = trek_map((int)$run['chapter']);
    $all = implode('', $m['t']);
    $items = [];
    if (str_contains($all, 'w')) $items[] = '<li><b class="lg">≈</b> High water. A sluice wheel drains it.</li>';
    if (str_contains($all, ':')) $items[] = '<li><b class="lg">⁚</b> Wet clay. Slow going, like mud.</li>';
    if (str_contains($all, '*')) $items[] = '<li><b class="lg">◆</b> Glow crystal. It lights the fog around it.</li>';
    if (str_contains($all, '+')) $items[] = '<li><b class="lg">✚</b> Loose clay. A Wayfinder in the party can push through to the nook behind it.</li>';
    foreach (trek_spots((int)$run['chapter']) as $sp) if ($sp['type'] === 'oldcamp') { $items[] = '<li><b class="lg">⛺</b> Old campsite. Rest here for free, no kit. A small risk of an ambush.</li>'; break; }   // v2.0.1
    return $items ? '<details class="tklegend"><summary>🗝️ Map key</summary><ul>' . implode('', $items) . '</ul></details>' : '';
}

/** What the party can do on the spot it stands on (or next to a locked gate): story text and buttons. */
function trek_spot_panel(array &$run, array $u): string
{
    $ch = (int)$run['chapter'];
    $spot = trek_here($run, $u);
    $k = fn(string $code, string $part) => 'ch' . $ch . '.spot.' . $code . '.' . $part;
    if (!$spot) {   // next to a locked gate: say why it is shut
        foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) {
            $s = trek_spot_at($ch, (int)$run['x'] + $dx, (int)$run['y'] + $dy);
            if ($s && $s['type'] === 'gate' && !trek_gate_open($run, $s)) return '<div class="box trekspot"><h3>🚧 ' . e($s['name']) . '</h3><div class="trektext">' . trek_text($k($s['code'], 'locked')) . '</div></div>';
        }
        return '';
    }
    $code = $spot['code'];
    $done = trek_spot_done($run, $spot);
    $h = '<div class="box trekspot"><h3>' . e($spot['data']['icon'] ?? TREK_SPOT_ICONS[$spot['type']] ?? '') . ' ' . e($spot['name']) . '</h3>';
    switch ($spot['type']) {
        case 'start':
            $h .= '<div class="trektext">' . trek_text($k($code, 'arrive')) . '</div>';
            break;
        case 'exit':
            $h .= '<div class="trektext">' . trek_text($k($code, 'arrive')) . '</div>' . trek_form('leave', '🪜 Climb out', ['t' => 'map'], 'btn', trek_leave_confirm());
            break;
        case 'camp':
            $price = (int)setting('trek_campkit_price');
            $h .= '<div class="trektext">' . trek_text($k($code, 'arrive')) . '</div><div class="trektext">' . trek_text(trek_camp_key($ch, $spot, 'greet')) . '</div>';
            $crew = array_values(array_filter(array_map(fn($p) => $p['crew_key'], $run['party']), fn($c2) => $c2 !== 'gnome'));
            if ($crew) {
                $pick = $crew[(int)($run['st']['turn'] ?? 0) % count($crew)];
                $h .= '<div class="trektext banter">' . trek_text('ch' . $ch . '.banter.' . $pick . '.' . (1 + intdiv((int)($run['st']['turn'] ?? 0), max(1, count($crew))) % 2), ['trailmate' => trek_crew_npc($pick)['name']]) . '</div>';
            }
            $h .= '<div class="trekbtns">' . trek_form('rest', '🛌 Rest and bank', ['t' => 'map'])
                . trek_form('buy_kit', '🏕️ Camp Kit (' . $price . ' ' . setting('currency_name') . ')', ['t' => 'map'], 'btn ghost') . '</div>'
                . '<p class="help">You carry ' . (int)$run['campkits'] . '/' . (int)setting('trek_campkit_max') . ' Camp Kits.</p>'
                . '<div class="trektext small">' . trek_text(trek_camp_key($ch, $spot, 'shop')) . '</div>';
            $others = array_diff_key(trek_travel_camps($run), [$code => 1]);   // v1.9.4: camp-to-camp travel (the Tin Lamp and the Brewhouse)
            if ($others) {
                $h .= '<div class="trekbtns trektravel">';
                foreach ($others as $oc => $os) $h .= trek_form('travel', '🚶 Travel to ' . $os['name'], ['t' => 'map', 'to' => $oc], 'btn ghost', ' data-confirm="' . e('Take the old tunnel to ' . $os['name'] . '? It is a long way and tires the party a little (fatigue +12).') . '"');
                $h .= '</div><p class="help">Camp to camp through the old tunnels: a long walk, not a rest.</p>';
            }
            break;
        case 'recruit':
            if (!$done && !empty($spot['data']['needs']) && !trek_flag($run, (string)$spot['data']['needs'])) $h .= '<div class="trektext">' . trek_text($k($code, 'locked'), ['trailmate' => trek_crew_npc((string)$spot['data']['crew'])['name']]) . '</div>';   // v1.9.4
            elseif (!$done) $h .= '<div class="trektext">' . trek_text($k($code, 'before'), ['trailmate' => trek_crew_npc((string)$spot['data']['crew'])['name']]) . '</div>'
                . trek_form('recruit', '🤝 Help ' . trek_crew_npc((string)$spot['data']['crew'])['name'], ['t' => 'map']);
            else $h .= '<p class="help">' . e(trek_crew_npc((string)$spot['data']['crew'])['name']) . ' is with you.</p>';
            break;
        case 'fetch':
            [$slug, $qty] = array_pad(explode(':', (string)$spot['data']['need'], 2), 2, '1');
            $have = trek_pack_qty((int)$run['id'], trek_item_id($slug));
            if (!$done) $h .= '<div class="trektext">' . trek_text($k($code, 'before'), ['trailmate' => trek_crew_npc((string)$spot['data']['crew'])['name']]) . '</div>'
                . '<p class="help">💧 ' . e(trek_item_name(trek_item_id($slug))) . ': ' . $have . '/' . (int)$qty . '</p>' . trek_form('fetch', '💧 Hand over', ['t' => 'map']);
            else $h .= '<p class="help">' . e(trek_crew_npc((string)$spot['data']['crew'])['name']) . ' is with you.</p>';
            break;
        case 'chest':
            $h .= '<div class="trektext">' . trek_text($k($code, $done ? 'after' : 'locked')) . '</div>';
            if (!$done) $h .= trek_form('chest', '🧰 Open the chest', ['t' => 'map']) . '<p class="help">Needs the ' . e(trek_item_name(trek_item_id((string)$spot['data']['needs']))) . '.</p>';
            break;
        case 'npc':
            $h .= '<div class="trektext">' . trek_text($k($code, 'talk')) . '</div>';
            break;
        case 'sign':
            $h .= '<div class="trektext">' . trek_text($k($code, 'arrive')) . '</div>';
            break;
        case 'riddle':
            $tries = (int)($run['st']['tries_' . $code] ?? 0);
            $max = (int)($spot['data']['tries'] ?? 2);
            if ($done) { $h .= isset(trek_text_rows()[$k($code, 'after')]) ? '<div class="trektext">' . trek_text($k($code, 'after')) . '</div>' : '<p class="help">' . ($ch === 1 ? 'The choir hums happily.' : 'Solved.') . '</p>'; break; }
            if ($tries >= $max) {   // v2.0.4: once the clay has given way (failopen) the card says "after", not the "out" scene again
                $opened = !empty($spot['data']['failopen']) && trek_flag($run, (string)$spot['data']['flag']) && isset(trek_text_rows()[$k($code, 'after')]);
                $h .= '<div class="trektext">' . trek_text($k($code, $opened ? 'after' : 'out')) . '</div>';
                break;
            }
            $h .= '<div class="trektext">' . trek_text($k($code, 'question')) . '</div><form method="post" class="choiceform">' . csrf_field() . '<input type="hidden" name="do" value="riddle"><input type="hidden" name="t" value="map"><div class="choicelist">';
            foreach ([1, 2, 3] as $n) $h .= choice_row('🎶', trek_plain($k($code, 'a' . $n), 'Answer ' . $n), '', '', '', 'type="submit" name="ans" value="' . $n . '"');
            if (!empty($spot['data']['seedkeeper']) && trek_has_calling($run, $u, 'seedkeeper')) $h .= choice_row('🍄', 'Read it the Seedkeeper’s way', 'a Seedkeeper in the party can open this', '', '', 'type="submit" name="how" value="seed"');   // v1.9.2
            $h .= '</div></form><p class="help">Tries left: ' . ($max - $tries) . '.' . (!empty($spot['data']['failopen']) ? ' (After the last one, the way opens anyway.)' : '') . '</p>';
            break;
        case 'cart':
            if ($done) { $h .= '<div class="trektext">' . trek_text($k($code, 'after')) . '</div>'; break; }
            $h .= '<div class="trektext">' . trek_text($k($code, 'before')) . '</div><form method="post" class="choiceform">' . csrf_field() . '<input type="hidden" name="do" value="cart"><input type="hidden" name="t" value="map"><div class="choicelist">'
                . choice_row('💪', 'Heave it free', 'Grit ' . trek_signed(trek_best_mod($run, $u, 'grit')) . ' · may take a few tries', '', '', 'type="submit" name="how" value="heave"')
                . choice_row('⛏️', 'Dig it out slowly', 'tiring (+8) · always works', '', '', 'type="submit" name="how" value="work"') . '</div></form>';
            break;
        case 'mush':
            [$slug, $qty] = array_pad(explode(':', (string)$spot['data']['need'], 2), 2, '1');
            if ($done) { $h .= '<div class="trektext">' . trek_text($k($code, 'after')) . '</div>'; break; }
            $have = trek_pack_qty((int)$run['id'], trek_item_id($slug));
            $h .= '<div class="trektext">' . trek_text($k($code, 'before')) . '</div><p class="help">🍄 ' . e(trek_item_name(trek_item_id($slug))) . ': ' . $have . '/' . (int)$qty . ' (carried)</p>'
                . trek_form('mush', '🍄 Hand them over', ['t' => 'map']);
            break;
        case 'hidden':
            $h .= '<div class="trektext">' . trek_text($k($code, 'arrive')) . '</div>';
            if (!$done) $h .= trek_form('grotto', '✨ Take the rare find', ['t' => 'map']);
            break;
        case 'find':   // v1.9.2: an item lying about (the Overdue Book)
            $h .= '<div class="trektext">' . trek_text($k($code, $done ? 'find' : 'arrive')) . '</div>';
            if (!$done) $h .= trek_form('grotto', '📕 Pick it up', ['t' => 'map']);
            break;
        case 'slide':   // v1.9.4: a one-way chute to another spot
            $h .= '<div class="trektext">' . trek_text($k($code, 'before')) . '</div>'
                . trek_form('slide', '🛝 Take the slide', ['t' => 'map'], 'btn', ' data-confirm="' . e('Take the slide? It only goes one way: down.') . '"')
                . '<p class="help">A shortcut down to ' . e((trek_spots($ch)[(string)($spot['data']['to'] ?? '')]['name'] ?? 'the next stretch')) . '. You cannot slide back up.</p>';
            break;
        case 'switch':
            $h .= '<div class="trektext">' . trek_text($k($code, $done ? 'after' : 'before')) . '</div>';
            if (!$done) $h .= trek_form('switch', '⚙️ Turn the wheel', ['t' => 'map']);
            break;
        case 'oldcamp':   // v2.0.1
            $h .= trek_oldcamp_panel($run, $spot, $k($code, 'find'));
            break;
        case 'rest':
            $h .= '<div class="trektext">' . trek_text($k($code, $done ? 'after' : 'before')) . '</div>';
            if (!$done) $h .= trek_form('rest_spot', '🛋️ Sit a while (free rest)', ['t' => 'map']);
            break;
        case 'trade':
            [$slug, $qty] = array_pad(explode(':', (string)$spot['data']['need'], 2), 2, '1');
            if ($done) { $h .= '<div class="trektext">' . trek_text($k($code, 'after')) . '</div>'; break; }
            $have = trek_pack_qty((int)$run['id'], trek_item_id($slug));
            $h .= '<div class="trektext">' . trek_text($k($code, 'before')) . '</div><p class="help">🏺 ' . e(trek_item_name(trek_item_id($slug))) . ': ' . $have . '/' . (int)$qty . ' (carried)</p>'
                . trek_form('trade', '🏺 Hand it over', ['t' => 'map']);
            break;
        case 'duel':
        case 'miniboss':
        case 'boss':
            if ($done) { $h .= '<p class="help">Done.</p>'; break; }
            $part = $spot['type'] === 'duel' ? 'before' : 'intro';
            $h .= '<div class="trektext">' . trek_text($k($code, $part), ['trailmate' => trek_crew_npc((string)($spot['data']['crew'] ?? 'bracken'))['name']]) . '</div>'
                . trek_form('challenge', $spot['type'] === 'duel' ? '⚔️ Accept the duel' : '⚔️ Face ' . $spot['name'], ['t' => 'map'], 'btn red');
            break;
    }
    return $h . '</div>';
}

/** v1.8.8: the pending trail event as a small choice card (same look as a spot panel), or ''. */
function trek_event_html(array &$run, array $u): string
{
    $ev = $run['st']['ev'] ?? null;
    if (!is_array($ev) || $run['fi'] || !isset(TREK_EVENTS[(string)($ev['id'] ?? '')])) return '';
    $id = (string)$ev['id'];
    $ch = (int)$run['chapter'];
    $h = '<div class="box trekspot trekev"><h3>' . e(TREK_EVENTS[$id][0]) . ' ' . e(TREK_EVENTS[$id][1]) . '</h3><div class="trektext">' . trek_text('ch' . $ch . '.ev.' . $id . '.text') . '</div>'
        . '<form method="post" class="choiceform">' . csrf_field() . '<input type="hidden" name="do" value="event"><input type="hidden" name="t" value="map"><div class="choicelist">';
    foreach (trek_ev_choices($run, $u, $id) as $n => [$ico, $title, $sub, $off]) {
        $h .= choice_row($ico, $title, $sub, '', $off ? 'is-disabled' : '', 'type="submit" name="c" value="' . (int)$n . '"' . ($off ? ' aria-disabled="true"' : ''));
    }
    return $h . choice_row('🥾', 'Walk on', '', '', 'ghost', 'type="submit" name="c" value="0"') . '</div></form></div>';
}

/** v1.8.8: the pending crew moment (a trailmate in the party with a tiny task), or ''. */
function trek_crew_html(array &$run, array $u): string
{
    $k = (string)($run['st']['cm'] ?? '');
    if ($k === '' || $run['fi'] || !isset(TREK_CREW_BEATS[$k]) || !trek_in_party($run, $k)) return '';
    $name = trek_first_name_of((string)trek_crew_npc($k)['name']);
    return '<div class="box trekspot trekev trekcrew"><h3>' . e(TREK_CREW_BEATS[$k][0]) . ' ' . e($name) . '</h3><div class="trektext banter">' . trek_text('ch' . (int)$run['chapter'] . '.crew.' . $k . '.talk', ['trailmate' => $name]) . '</div>'
        . '<form method="post" class="choiceform">' . csrf_field() . '<input type="hidden" name="do" value="crew"><input type="hidden" name="t" value="map"><div class="choicelist">'
        . choice_row(TREK_CREW_BEATS[$k][0], TREK_CREW_BEATS[$k][1], '', '', '', 'type="submit" name="c" value="1"')
        . choice_row('🥾', 'Not now', '', '', 'ghost', 'type="submit" name="c" value="0"') . '</div></form></div>';
}

/** v1.8.8: the whole log of the latest fight in a scrollable box (newest at the bottom; assets/trekfight.js scrolls it down when it is opened). */
function trek_flog_box(array $lines): string
{
    return '<div class="tkall" tabindex="0" role="log" aria-label="Whole fight log"><ul class="trekrounds">' . implode('', array_map(fn($l) => '<li>' . $l . '</li>', $lines)) . '</ul></div>';
}

/** The text of a slot as plain text for a button label (the written body, else a placeholder; never the admin to-write box). */
function trek_plain(string $key, string $fallback): string
{
    $b = trim((string)(trek_text_rows()[$key]['body'] ?? ''));
    return $b !== '' ? $b : $fallback;
}

/** v1.8.4: the icon of each calling's ability, and a few words on what it does (the long text stays in TREK_ABILITIES). */
const TREK_ABILITY_ICONS = ['rootwarden' => '🌳', 'bloomcaller' => '🌸', 'thornblade' => '🗡️', 'seedkeeper' => '🍄', 'wayfinder' => '🏹', 'brewroot' => '🧪', '' => '✨'];
const TREK_ABILITY_SHORT = ['rootwarden' => '½ damage, 3 rounds', 'bloomcaller' => 'heals about ¼', 'thornblade' => 'heavy hit', 'seedkeeper' => 'every foe, ½ damage, mends friends', 'wayfinder' => '+5 to hit, +5 damage', 'brewroot' => 'then burns 3 rounds', '' => '+3 to hit, +3 damage'];

/** The first word of a name (trailmates and gnomes have long ones). */
function trek_first_name(string $n): string
{
    return trek_short_name($n);
}

/**
 * v1.8.4: what each living member will do this round: the plan saved from the last manual round if it still fits, else the default
 * (attack the weakest foe; an ally move aims at the weakest friend). Returns [slot => [a, t, need, ok], 'item' => id, 'same' => bool].
 */
function trek_fight_plan(array $run, array $u, array $stats): array
{
    $fi = $run['fi'];
    $foes = trek_targetable_foes($fi);
    $weak = $foes ? trek_foe_target($fi, '') : null;
    $lowAlly = null;
    foreach ($stats as $s => $m) {
        $hp = (int)$run['party'][$s]['hp'];
        if ($hp > 0 && ($lowAlly === null || $hp < (int)$run['party'][$lowAlly]['hp'])) $lowAlly = $s;
    }
    $ai = trek_fight_ai($run, $u);   // v1.8.6: with no saved plan, the preselected move is what Auto would do (tactics included)
    $snacks = fight_snacks($u);
    $snackOk = $snacks && (int)$fi['snacks'] < snack_limit($u) && (int)$run['party'][0]['hp'] > 0 && (int)$run['party'][0]['hp'] < $stats[0]['max'];
    $saved = (array)($run['st']['plan'] ?? []);
    $item = (int)($snacks[0]['id'] ?? 0);
    foreach ($snacks as $s) if ($s['id'] === (int)($saved['item'] ?? 0)) $item = $s['id'];
    $out = [];
    $same = !empty($saved['m']);
    foreach ($stats as $slot => $m) {
        if ((int)$run['party'][$slot]['hp'] <= 0) continue;
        $ab = TREK_ABILITIES[$m['calling']] ?? TREK_ABILITIES[''];
        $cd = (int)($fi['mem'][$slot]['cd'] ?? 0);
        $needOf = fn(string $a) => $a === 'attack' ? 'f' : ($a === 'ability' ? ($ab[2] === 'foe' ? 'f' : ($ab[2] === 'ally' ? 'a' : 'n')) : 'n');
        $defT = fn(string $need) => $need === 'a' ? ($lowAlly !== null ? 'a:' . $lowAlly : '') : ($weak !== null ? 'f:' . $weak : ($lowAlly !== null ? 'a:' . $lowAlly : ''));
        $sv = $saved['m'][$slot] ?? null;
        $a = (string)($ai[$slot]['a'] ?? ($weak !== null ? 'attack' : 'guard'));
        $t = $needOf($a) === 'n' ? $defT('n') : (string)($ai[$slot]['t'] ?? $defT($needOf($a)));
        $ok = false;
        if (is_array($sv)) {
            $sa = (string)($sv['a'] ?? '');
            $st = (string)($sv['t'] ?? '');
            $valid = match ($sa) {
                'attack' => $weak !== null,
                'ability' => $cd === 0 && ($needOf('ability') !== 'f' || $weak !== null),
                'snack' => $slot === 0 && $snackOk,
                'guard' => true,
                default => false,
            };
            $need = $needOf($sa);
            $tOk = preg_match('/^([fa]):(\d+)$/', $st, $mm) && (($mm[1] === 'f' && in_array((int)$mm[2], $foes, true)) || ($mm[1] === 'a' && isset($run['party'][(int)$mm[2]]) && (int)$run['party'][(int)$mm[2]]['hp'] > 0));
            if ($tOk && $need === 'f' && $mm[1] !== 'f') $tOk = false;
            if ($tOk && $need === 'a' && $mm[1] !== 'a') $tOk = false;
            if ($valid && ($need === 'n' || $tOk)) {
                $a = $sa;
                $t = $tOk ? $st : $defT($need);
                $ok = true;
            }
        }
        if (!$ok) $same = false;
        $out[$slot] = ['a' => $a, 't' => $t, 'need' => $needOf($a), 'ok' => $ok];
    }
    return $out + ['item' => $item, 'same' => $same && $out !== [], 'snackOk' => (bool)$snackOk, 'weak' => $weak, 'lowAlly' => $lowAlly, 'foes' => $foes];
}

/** The fight screen (v1.8.4): what happened, health, the plan line, one big Fight button, and the plan sheet. */
function trek_fight_html(array &$run, array $u): string
{
    $fi = $run['fi'];
    $stats = trek_party_stats($run, $u);
    $boss = trek_boss_moves($fi);
    $ch = (int)$run['chapter'];
    $duel = !empty($fi['meta']['duel']);
    $round = (int)$fi['round'];
    $plan = trek_fight_plan($run, $u, $stats);
    $fname = [];   // v1.8.6: foes of one kind share a row, so no numbers
    foreach ($fi['foes'] as $i => $f) $fname[$i] = (string)$f['name'];
    $groups = trek_foe_groups($fi);
    $h = '<div class="trekfight' . ($round === 1 ? ' fresh' : '') . '"><h3>⚔️ Round ' . $round . ($duel ? ' · duel' : '') . '</h3>';
    // what happened: the last lines, one a row
    $lines = array_slice(trek_latest_html($run), -5);
    $all = trek_flog_html($run);   // v1.8.8: "Show all (N)" opens the whole fight so far in a scrollable box
    if ($lines) $h .= '<div class="box trekwhat"><b class="tklabel">What happened</b><ul class="trekrounds" aria-live="polite">' . implode('', array_map(fn($l) => '<li>' . $l . '</li>', $lines)) . '</ul>'
        . (count($all) > count($lines) ? '<details class="trekall"><summary>Show all (' . count($all) . ')</summary>' . trek_flog_box($all) . '</details>' : '') . '</div>';
    // health: foes, a divider, the party
    $h .= '<div class="box trekhealth"><ul class="hprows">';
    foreach ($groups as $g) {
        $f = $fi['foes'][$g['show']];
        $n = count($g['idx']);
        $anyPz = false;
        foreach ($g['idx'] as $i) if ((int)$fi['foes'][$i]['pz'] > 0) $anyPz = true;
        $ref = $g['weak'] ?? $g['show'];
        $h .= '<li class="hprow foe' . ($g['own'] && !empty($f['under']) ? ' under' : '') . ($n > 1 ? ' grp' : '') . '" data-ref="f:' . $ref . '" data-g="' . $g['gid'] . '" data-n="' . $n . '" data-tgt="' . ($g['weak'] !== null ? 1 : 0) . '" data-name="' . e($g['name']) . '" data-hp="' . (int)$f['hp'] . '" data-max="' . (int)$f['max'] . '">'
            . '<span class="hpico">' . e($g['icon']) . '</span><span class="hpname">' . e($g['name']) . ($n > 1 ? ' <b class="hpx">×' . $n . '</b>' : '')
            . ($g['own'] && !empty($f['under']) ? ' <span class="hpmk" role="img" aria-label="underground">🕳️</span>' : '')
            . ($g['own'] && !empty($f['dm']) ? ' <span class="hpmk" role="img" aria-label="' . ((int)$f['dm'] < 100 ? 'hardened, takes half damage' : 'cracked, takes more damage') . '">' . ((int)$f['dm'] < 100 ? '🛡️' : '💥') . '</span>' : '')   // v1.9.4: Old Thrum
            . ($g['own'] && !empty($fi['meta']['stun']) && $g['gid'] === 0 ? ' <span class="hpmk" role="img" aria-label="stunned">💫</span>' : '') . ($anyPz ? ' <span class="hpmk" role="img" aria-label="poisoned">🧪</span>' : '') . '</span>'
            . trek_bar((int)$f['hp'], (int)$f['max'], 'foebar') . '<span class="hpnum">' . (int)$f['hp'] . '/' . (int)$f['max'] . '</span></li>';
    }
    $h .= '</ul><div class="hpvs" aria-hidden="true">vs</div><ul class="hprows">';
    foreach ($stats as $slot => $m) {
        $hp = (int)$run['party'][$slot]['hp'];
        $bark = (int)($fi['mem'][$slot]['bark'] ?? 0);
        $h .= '<li class="hprow you' . ($hp <= 0 ? ' down' : '') . '" data-ref="a:' . $slot . '" data-name="' . e(trek_first_name((string)$m['name'])) . '" data-hp="' . $hp . '" data-max="' . (int)$m['max'] . '">'
            . '<span class="hpico">' . $m['ico'] . '</span><span class="hpname">' . e(trek_first_name((string)$m['name'])) . ($bark > 0 ? ' <span class="hpmk" role="img" aria-label="bark skin">🌳' . $bark . '</span>' : '')
            . (isset($fi['meta']['held']) && (int)$fi['meta']['held'] === (int)$slot ? ' <span class="hpmk" role="img" aria-label="held">🦀</span>' : '') . '</span>'   // v1.9.4: Old Pinch's grab
            . trek_bar($hp, (int)$m['max']) . '<span class="hpnum">' . $hp . '/' . (int)$m['max'] . '</span></li>';
    }
    $h .= '</ul></div>';
    if ($boss) {
        $code = trek_script_code((string)($fi['meta']['script'] ?? ''));   // v1.9.2: any scripted boss (was Gloomtooth only)
        $h .= '<div class="trekboss"><b>Next: ' . e(TREK_MOVE_NAMES[$boss[0]] ?? ucfirst($boss[0])) . '</b> <span class="muted">then ' . e(TREK_MOVE_NAMES[$boss[1]] ?? ucfirst($boss[1])) . '</span><div class="trektext small">' . trek_text('ch' . $ch . '.spot.' . $code . '.' . $boss[0]) . '</div></div>';
    }
    // the plan line
    $short = function (string $t) use ($fname, $stats): string {
        if (!preg_match('/^([fa]):(\d+)$/', $t, $mm)) return '';
        return $mm[1] === 'f' ? (string)($fname[(int)$mm[2]] ?? '') : trek_first_name((string)($stats[(int)$mm[2]]['name'] ?? ''));
    };
    $ico = function (int $slot, string $a) use ($stats): string {
        return match ($a) { 'attack' => '⚔️', 'guard' => '🛡️', 'snack' => '🎒', default => TREK_ABILITY_ICONS[$stats[$slot]['calling']] ?? '✨' };
    };
    $bits = [];
    foreach ($plan as $slot => $p) {
        if (!is_int($slot)) continue;
        $bits[] = e($ico($slot, $p['a'])) . ($p['need'] !== 'n' && $p['t'] !== '' ? '→' . e($short($p['t'])) : '');
    }
    if (count($bits) > 1 && count(array_unique($bits)) === 1) $bits = ['all ' . $bits[0]];   // v1.8.4: everyone doing the same thing reads as one item
    $h .= '<form method="post" class="trekactform">' . csrf_field() . '<input type="hidden" name="t" value="map">'
        . '<div class="trekplanrow"><span class="planmsg">✅ <b class="planlabel">' . ($plan['same'] ? 'Same plan:' : 'Plan:') . '</b> <span class="planlist">' . implode(' · ', $bits) . '</span></span>'
        . '<button type="button" class="planchg">Change ›</button></div>'
        . '<button type="submit" class="btn trekgo" name="do" value="round">⚔️ Fight round ' . $round . '</button>'
        . '<div class="trekmini"><button type="submit" class="btn alt" name="do" value="auto1">🔁 Auto 1</button><button type="submit" class="btn alt" name="do" value="auto">⏩ Auto</button>'
        . (!$duel ? '<button type="submit" class="btn alt" name="do" value="flee">🏃 Run</button>' : '') . '</div>'
        . '<p class="help trekhelp">Auto 1: the party plays one round. Auto: plays on until it ends or goes badly.' . (!$duel ? ' Run: slip away, no reward.' : '') . '</p>';
    // the plan sheet: a dialog inside the form, so its radios post with the round
    $living = [];
    foreach ($stats as $slot => $m) if ((int)$run['party'][$slot]['hp'] > 0) $living[$slot] = $m;
    $h .= '<dialog class="trekplan" aria-label="Plan the round"><div class="planbar" aria-hidden="true"></div><div class="plantabs" role="group" aria-label="Who">';
    foreach ($living as $slot => $m) $h .= '<button type="button" class="plantab" data-slot="' . $slot . '" aria-pressed="false">' . $m['ico'] . ' ' . e(trek_first_name((string)$m['name'])) . '</button>';
    $h .= '</div>';
    $foeTiles = function (int $slot, string $cur) use ($fi, $plan, $groups): string {
        $ok = array_values(array_filter($groups, fn($g) => $g['weak'] !== null));
        $hps = array_map(fn($g) => (int)$fi['foes'][$g['weak']]['hp'], $ok);
        $weakTag = count($hps) > 1 && min($hps) < max($hps);
        $curI = preg_match('/^f:(\d+)$/', $cur, $mm) ? (int)$mm[1] : -1;
        $t = '';
        foreach ($ok as $g) {   // one tile for each kind of foe, aimed at its weakest (or at the one the plan already picked)
            $i = in_array($curI, $g['ok'], true) ? $curI : $g['weak'];
            $f = $fi['foes'][$i];
            $v = 'f:' . $i;
            $n = count($g['idx']);
            $t .= '<label class="ptile"><input type="radio" name="t[' . $slot . ']" value="' . $v . '"' . ($cur === $v ? ' checked' : '') . (in_array($plan['weak'], $g['ok'], true) ? ' data-def="1"' : '') . ' data-g="' . $g['gid'] . '" data-short="' . e($g['name']) . '">'
                . '<span class="pt-ico">' . e($g['icon']) . '</span><b>' . e($g['name']) . ($n > 1 ? ' ×' . $n : '') . '</b><small>' . (int)$f['hp'] . '/' . (int)$f['max'] . ($plan['weak'] === $i && $weakTag ? ' · weakest' : '') . '</small></label>';
        }
        return $t;
    };
    $allyTiles = function (int $slot, string $cur) use ($living, $run, $plan): string {
        $t = '';
        foreach ($living as $s2 => $m2) {
            $v = 'a:' . $s2;
            $t .= '<label class="ptile"><input type="radio" name="t[' . $slot . ']" value="' . $v . '"' . ($cur === $v ? ' checked' : '') . ($plan['lowAlly'] === $s2 ? ' data-def="1"' : '') . ' data-short="' . e(trek_first_name((string)$m2['name'])) . '">'
                . '<span class="pt-ico">' . $m2['ico'] . '</span><b>' . e(trek_first_name((string)$m2['name'])) . ($s2 === $slot ? ' (self)' : '') . '</b><small>' . (int)$run['party'][$s2]['hp'] . '/' . (int)$m2['max'] . '</small></label>';
        }
        return $t;
    };
    foreach ($living as $slot => $m) {
        $p = $plan[$slot];
        $ab = TREK_ABILITIES[$m['calling']] ?? TREK_ABILITIES[''];
        $cd = (int)($fi['mem'][$slot]['cd'] ?? 0);
        $aico = TREK_ABILITY_ICONS[$m['calling']] ?? '✨';
        $abNeed = $ab[2] === 'foe' ? 'f' : ($ab[2] === 'ally' ? 'a' : 'n');
        $move = function (string $v, string $icon, string $title, string $sub, string $need, bool $off = false) use ($slot, $p): string {
            return '<label class="ptile' . ($off ? ' off' : '') . '"><input type="radio" name="a[' . $slot . ']" value="' . e($v) . '"' . ($p['a'] === $v ? ' checked' : '') . ($off ? ' disabled' : '')
                . ' data-ico="' . e($icon) . '" data-need="' . $need . '" data-title="' . e($title) . '" data-sub="' . e($sub) . '"><span class="pt-ico">' . e($icon) . '</span><b>' . e($title) . '</b><small>' . e($sub) . '</small></label>';
        };
        $h .= '<fieldset class="planmem" data-slot="' . $slot . '" data-name="' . e(trek_first_name((string)$m['name'])) . '"><legend>' . $m['ico'] . ' ' . e(trek_first_name((string)$m['name'])) . '</legend>'
            . '<div class="plansec">Move</div><div class="tilegrid">'
            . $move('attack', '⚔️', 'Attack', 'plain hit', 'f')
            . $move('ability', $aico, $ab[0], $cd > 0 ? 'ready in ' . $cd . ($cd === 1 ? ' round' : ' rounds') : TREK_ABILITY_SHORT[$m['calling']] ?? '', $abNeed, $cd > 0)
            . ($slot === 0 && $plan['snackOk'] ? $move('snack', '🎒', 'Snack', 'heal yourself', 'n') : '')
            . $move('guard', '🛡️', 'Guard', '½ damage taken', 'n')
            . '</div><div class="plansec plantgt">Target</div>';
        $groups = [['f', 'tg-foes', $foeTiles($slot, $p['t'])], ['a', 'tg-allies', $allyTiles($slot, $p['t'])]];
        if ($ab[2] === 'ally') $groups = array_reverse($groups);
        foreach ($groups as [$g, $gc, $tiles]) $h .= '<div class="tilegrid tg ' . $gc . '" data-grp="' . $g . '">' . $tiles . '</div>';
        if ($slot === 0 && $plan['snackOk']) {
            $h .= '<div class="plansec plansnack">Snack</div><div class="tilegrid snacks">';
            foreach (fight_snacks($u) as $s) {
                $h .= '<label class="ptile"><input type="radio" name="item" value="' . (int)$s['id'] . '"' . ($plan['item'] === $s['id'] ? ' checked' : '') . ' data-short="' . e($s['name']) . '"><span class="pt-ico">🍲</span><b>' . e($s['name']) . '</b><small>+' . (int)$s['heal'] . '❤️ · ×' . (int)$s['qty'] . '</small></label>';
            }
            $h .= '</div>';
        }
        $h .= '</fieldset>';
    }
    $h .= '<div class="plantail"><button type="button" class="btn plandone">Done</button></div></dialog></form></div>';
    return $h;
}

/** v1.8.6: the tactics fields that apply to a calling: [[name, label, [value => text], current], ...]. At most open, one rule, a shield, a target and (gnome) a snack line. */
function trek_tac_fields(string $calling, bool $gnome, array $tac): array
{
    $ab = TREK_ABILITIES[$calling] ?? null;
    $f = [['open', 'Round 1', ['auto' => 'Auto', 'ability' => 'Ability', 'attack' => 'Attack', 'guard' => 'Guard'], $tac['open']]];
    if ($calling === 'bloomcaller') {
        $f[] = ['pct', 'Heal a friend under', [30 => '30%', 40 => '40%', 50 => '50%', 60 => '60%'], $tac['pct']];
    } elseif ($calling === 'rootwarden') {
        $f[] = ['rule', 'Bark Skin when', ['auto' => 'Big hit or 2+ foes', 'big' => 'Boss big move', 'foes2' => '2+ foes', 'ready' => 'Ready', 'friendlow30' => 'Friend under 30%', 'friendlow40' => 'Friend under 40%', 'friendlow50' => 'Friend under 50%', 'friendlow60' => 'Friend under 60%'],
            $tac['rule'] === 'friendlow' ? 'friendlow' . $tac['pct'] : $tac['rule']];
        $f[] = ['shield', 'Shield', ['lowest' => 'Most hurt', 'self' => 'Self', 'gnome' => 'The gnome'], $tac['shield']];
    } elseif ($calling === 'seedkeeper') {
        $f[] = ['rule', $ab[0] . ' when', ['foes2' => '2+ foes', 'foes3' => '3+ foes'], $tac['rule']];
    } elseif ($ab) {
        $f[] = ['rule', $ab[0] . ' when', ['ready' => 'Ready', 'healthy' => 'Foe over half', 'boss' => 'Boss fights'], $tac['rule']];
    }
    $f[] = ['target', 'Hit', ['weak' => 'Weakest', 'strong' => 'Strongest', 'focus' => 'The gnome’s foe'], $tac['target']];
    if ($gnome) $f[] = ['snack', 'Snack under', [30 => '30%', 40 => '40%', 50 => '50%'], $tac['snack']];
    return $f;
}

/** v1.8.6: one short muted line on what differs from the defaults, or '' when nothing does. */
function trek_tac_summary(string $calling, bool $gnome, array $tac): string
{
    $d = trek_tac_clean($calling, $gnome, []);
    $bits = [];
    if ($tac['open'] !== 'auto') $bits[] = 'Opens: ' . $tac['open'];
    if ($tac['pct'] !== $d['pct'] || ($calling === 'rootwarden' && $tac['rule'] === 'friendlow')) {
        $bits[] = ($calling === 'bloomcaller' ? 'Heals' : 'Bark') . ' <' . $tac['pct'] . '%';
    }
    if ($tac['rule'] !== $d['rule'] && $tac['rule'] !== 'friendlow') {
        $bits[] = ['big' => 'Bark on big hits', 'foes2' => $calling === 'seedkeeper' ? 'Burst on 2+ foes' : 'Bark on 2+ foes', 'foes3' => 'Burst on 3+ foes', 'ready' => 'Bark when ready', 'healthy' => 'Ability on healthy foes', 'boss' => 'Ability on bosses'][$tac['rule']] ?? '';
    }
    if ($tac['shield'] !== 'lowest') $bits[] = $tac['shield'] === 'self' ? 'Shields self' : 'Shields the gnome';
    if ($tac['target'] !== 'weak') $bits[] = $tac['target'] === 'strong' ? 'hits strongest' : 'follows the gnome';
    if ($tac['snack'] !== 40) $bits[] = 'Snack <' . $tac['snack'] . '%';
    return implode(' · ', array_filter($bits));
}

/** v1.8.6: ⚔️ 🛡️ 🎲 and the ability, for a member or a trailmate waiting in camp. $gc is gnome_combat(). */
function trek_member_facts(array $gc, string $calling): string
{
    $ab = TREK_ABILITIES[$calling] ?? TREK_ABILITIES[''];
    return '<p class="pstats"><span>⚔️ +' . (int)$gc['atk'] . '</span><span>🛡️ ' . (int)$gc['ac'] . '</span><span>🎲 d' . (int)$gc['dmg_die'] . '+' . (int)$gc['dmg_bonus'] . '</span></p>'
        . '<p class="pabil"><b>' . e(TREK_ABILITY_ICONS[$calling] ?? '✨') . ' ' . e($ab[0]) . '</b> ' . e($ab[1]) . ' <span class="muted">' . ($ab[3] <= 1 ? 'Every round.' : 'Every ' . (int)$ab[3] . ' rounds.') . '</span></p>';
}

/** v1.8.9: a thin trek XP bar for one member ($lv, $xp), or '' at the top level. */
function trek_xp_bar(int $lv, int $xp): string
{
    return $lv >= TREK_TL_MAX ? '' : '<progress class="txp" max="' . trek_tl_need($lv) . '" value="' . max(0, min(trek_tl_need($lv), $xp)) . '" aria-label="Trek XP"></progress>';
}

/** v1.8.9: what a trek level gives, for the opened party card: progress to the next level and the bonuses now. */
function trek_tl_facts(int $lv, int $xp, int $baseHp): string
{
    $b = trek_tl_bonus($lv, $baseHp);
    $now = $lv > 1 ? '+' . $b['hp'] . ' health' . ($b['atk'] > 0 ? ', +' . $b['atk'] . ' to hit' : '') . ($b['dmg'] > 0 ? ', +' . $b['dmg'] . ' damage' : '') : 'none yet';
    $next = $lv >= TREK_TL_MAX ? 'Top trek level.' : 'Next level: ' . $xp . '/' . trek_tl_need($lv) . ' XP.';
    return '<p class="ptlfacts"><b>Trek Lv ' . $lv . '</b> · ' . e($next) . '<br><span class="muted">Bonuses now: ' . e($now) . '.</span></p>';
}

/** v1.8.9: the one-shot milestone card(s) on the map tab, or ''. */
function trek_ms_card_html(array $run): string
{
    $h = '';
    foreach ((array)($run['st']['msc'] ?? []) as $name) {
        $m = $run['st']['ms'][$name] ?? null;
        if (!is_array($m) || !isset(trek_milestones((int)$run['chapter'])[$name]) || !empty($m['old'])) continue;
        $h .= '<div class="trektext small">' . trek_text('ch' . (int)$run['chapter'] . '.ms.' . $name) . '</div><p class="msline"><b>🏅 ' . e(trek_milestones((int)$run['chapter'])[$name][2]) . ': ' . (int)$m['done'] . '/' . (int)$m['total'] . ' checks → ' . (int)$m['xp'] . ' XP</b>'
            . (!empty($m['miss']) ? '<br><span class="muted">Missed: ' . e(implode(', ', (array)$m['miss'])) . '</span>' : '<br><span class="muted">Every check done.</span>') . '</p>';
    }
    if ($h === '') return '';
    return '<div class="box trekspot trekev trekms"><h3>🏅 Milestone</h3>' . $h
        . '<form method="post" class="choiceform">' . csrf_field() . '<input type="hidden" name="do" value="msdismiss"><input type="hidden" name="t" value="map"><div class="choicelist">'
        . choice_row('✔️', 'Got it', '', '', 'ghost', 'type="submit"') . '</div></form></div>';
}

/** v1.8.9: every milestone with its XP and checks, for the Log tab. */
function trek_ms_list_html(array $run, string $title = 'Milestones'): string
{
    $n = 0;
    $h = '';
    $ms = trek_milestones((int)$run['chapter']);
    foreach ($ms as $name => [$label]) {
        $m = $run['st']['ms'][$name] ?? null;
        if (is_array($m)) $n++;
        if (!is_array($m)) $line = '<span class="muted">not yet</span>';
        elseif (!empty($m['old']) && (int)$m['total'] === 0) $line = '<span class="muted">earned before trek levels</span>';
        elseif (!empty($m['old'])) $line = '<span class="muted">paid in an earlier trek · ' . (int)$m['done'] . '/' . (int)$m['total'] . ' checks</span>';
        else $line = '<b>' . (int)$m['xp'] . ' XP</b> · ' . (int)$m['done'] . '/' . (int)$m['total'] . ' checks' . (!empty($m['miss']) ? ' <span class="muted">(missed: ' . e(implode(', ', (array)$m['miss'])) . ')</span>' : '');
        $h .= '<li>' . (is_array($m) ? '🏅' : '⚪') . ' ' . e($label) . ' — ' . $line . '</li>';
    }
    return '<details class="helpfold trekmsfold"><summary>🏅 ' . e($title) . ' (' . $n . '/' . count($ms) . ')</summary><ul class="tkms">' . $h . '</ul>'
        . '<p class="help">Gnome XP comes from milestones. Each pays once, and more when you did the side stops, events, riddles and crew moments, and were never knocked out.</p></details>';
}

/** v1.9.1: the interlude between chapters: one screen, no map. The finished chapter's card, a rest, the Camp Kit shop, the party, a word with each trailmate, and the way down. */
function trek_hub_html(array &$run, array $u, array $party): string
{
    $ch = (int)$run['chapter'];
    $next = trek_next_chapter($ch);
    $cost = (int)setting('trek_entry_energy');
    $h = '<div class="box trekhub"><h3>🏕️ The Shard Hollow</h3>';
    if (!empty($run['st']['show_done'])) {
        $rw = $run['st']['rewards'] ?? ['petals' => 0, 'items' => []];
        $h .= '<div class="trekdone"><b>🎉 ' . e(trek_chapter($ch)['finish']['title'] ?? 'Chapter ' . $ch) . ' complete</b><div class="trektext">' . trek_text('ch' . $ch . '.outro') . '</div>'
            . '<p>🪙 ' . (int)$rw['petals'] . ' ' . e(setting('currency_name')) . ' · 🎁 ' . e(implode(', ', (array)$rw['items'])) . ' · 📖 new Almanac pages</p>' . trek_item_notes((array)($rw['slugs'] ?? [])) . '<div class="trektext">' . trek_text('ch' . $ch . '.hook') . '</div>'
            . trek_form('dismiss', 'Got it', ['t' => 'map'], 'btn small') . '</div>';
    }
    $h .= '<div class="trektext">' . trek_text('interlude.' . $ch . '.intro') . '</div><div class="hudparty">';
    foreach ($party as $slot => $m) {
        $hp = (int)$run['party'][$slot]['hp'];
        $h .= '<div class="hm' . ($hp <= 0 ? ' down' : '') . '"><span class="hn">' . $m['ico'] . ' <b>' . e(trek_first_name((string)$m['name'])) . '</b> <small class="tlv">Lv ' . (int)$m['tl'] . '</small></span>'
            . trek_bar($hp, (int)$m['max']) . '<small>' . $hp . '/' . (int)$m['max'] . '</small></div>';
    }
    $h .= '</div><div class="hudchips"><span class="chip">🏕️ ' . (int)$run['campkits'] . '/' . (int)setting('trek_campkit_max') . ' kits</span><span class="chip">⚡ ' . (int)$u['energy'] . '</span></div>';
    $h .= '<div class="trekbtns">' . trek_form('rest', '🛌 Rest and bank', ['t' => 'map'])
        . trek_form('buy_kit', '🏕️ Camp Kit (' . (int)setting('trek_campkit_price') . ' ' . setting('currency_name') . ')', ['t' => 'map'], 'btn ghost')
        . '<a class="btn ghost" href="' . e(url('trek.php?t=party')) . '">🧑‍🤝‍🧑 Party and tactics</a></div></div>';
    // talk to the party
    $recruits = trek_recruits((int)$run['id']);
    if ($recruits) {
        $h .= '<div class="box trekhub"><h3>💬 Talk to your party</h3><form method="post" class="choiceform">' . csrf_field() . '<input type="hidden" name="do" value="talk"><input type="hidden" name="t" value="map"><div class="choicelist">';
        foreach ($recruits as $rk) {
            $npc = trek_crew_npc($rk);
            $h .= choice_row(TREK_CREW_ICONS[trek_crew()[$rk]['calling'] ?? ''] ?? '🧑', trek_first_name((string)$npc['name']), '', '', trek_flag($run, 'itlk_' . $rk) ? 'ghost' : '', 'type="submit" name="who" value="' . e($rk) . '"');
        }
        $h .= '</div></form>';
        $who = (string)($run['st']['talk'] ?? '');
        if ($who !== '' && in_array($who, $recruits, true)) {
            $line = trek_text('interlude.' . $ch . '.' . $who, ['trailmate' => trek_crew_npc($who)['name']]);
            if ($line !== '') $h .= '<div class="trektext banter"><b>' . e(trek_first_name((string)trek_crew_npc($who)['name'])) . '</b><br>' . $line . '</div>';
        }
        $h .= '</div>';
    }
    // the way down
    $h .= '<div class="box trekhub"><h3>⬇️ ' . ($next ? 'Go down to Chapter ' . e(trek_chapter($next)['roman']) : 'The way down') . '</h3>';
    if ($next) {
        $h .= '<p class="help">Your trailmates, trek levels, tactics and Camp Kits come with you. Going down costs ' . $cost . ' ⚡ and you cannot come back up to ' . e(trek_chapter($ch)['finish']['title'] ?? 'this chapter') . '.</p>'
            . trek_form('godown', '⬇️ Go down to Chapter ' . e(trek_chapter($next)['roman']) . ' (' . $cost . ' ⚡)', ['t' => 'map'], 'btn gold', ' data-confirm="' . e('Go down to the next chapter? There is no coming back up.') . '"');
    } else {
        $rn = e(trek_chapter($ch + 1)['roman']);
        $h .= '<p class="help">Chapter ' . $rn . ' is coming soon.</p><p><button class="btn gold" disabled>⬇️ Chapter ' . $rn . ' is coming soon</button></p>';
    }
    return $h . '</div>';
}

page_header('Treks');
?>
<h1>🥾 Treks</h1>
<?php if (!$open): ?>
  <div class="box"><p>🔒 <?= e($closedWhy) ?></p></div>
<?php
page_footer();
exit;
endif;
$row = trek_run_row($uid);
$run = $row ? trek_load($row) : null;
if ($run && !isset($run['st']['tl'])) {   // v1.8.9: a run from before trek levels: give it its level once (trek_tx migrates), then read it again
    trek_tx($uid, fn(&$r, $uu) => [true, '']);
    $row = trek_run_row($uid);
    $run = $row ? trek_load($row) : null;
}
if ($run && trek_hub_pending($run)) {   // v1.9.1: a finished chapter: bring the gnome to the interlude (bank, rest, close the run)
    trek_tx($uid, function (&$r, $uu) { if (trek_hub_pending($r)) trek_hub_arrive($r, $uu); return [true, '']; });
    $row = trek_run_row($uid);
    $run = $row ? trek_load($row) : null;
}
if ($run && trek_riddle_stuck($run)) {   // v2.0.1: riddles went from 3 tries to 2: a door with 2 misses on a run from before must open now
    trek_tx($uid, function (&$r, $uu) { trek_riddle_heal($r); return [true, '']; });
    $row = trek_run_row($uid);
    $run = $row ? trek_load($row) : null;
}
$hub = $run && trek_run_done($run);
if (!$run || (!(int)$run['inside'] && !$hub)):
    $ach = $run ? (int)$run['chapter'] : trek_active_ch($uid);
    $cost = (int)setting('trek_entry_energy');
    $maxE = max_energy($u); ?>
  <div class="box trekintro">
    <?php if (!$run): ?>
      <h3>The Withering · Chapter <?= e(trek_chapter($ach)['roman']) ?></h3>
      <div class="trektext"><?= trek_text('ch' . $ach . '.intro') ?></div>
      <?= trek_form('begin', 'Begin the trek (' . $cost . ' ⚡)', ['t' => 'map']) ?>
    <?php else: ?>
      <h3>You are above ground</h3>
      <p>You stopped at <?= e((trek_zone_info((int)$run['chapter'], trek_zone_at((int)$run['chapter'], (int)$run['x'], (int)$run['y'])) ?? ['the trek'])[0]) ?>. Fatigue <?= (int)$run['fatigue'] ?>/100.</p>
      <?= trek_form('enter', 'Go back in (' . $cost . ' ⚡)', ['t' => 'map']) ?>
    <?php endif; ?>
    <p class="help">⚡ <?= (int)$u['energy'] ?>/<?= $maxE ?> energy. Going in costs <?= $cost ?>; everything inside is free.</p>
    <details class="helpfold"><summary>How treks work</summary>
      <p>Tap a lit tile to walk. A trek has a party: you and up to three trailmates. Fights have a move for each of you. Walking and fighting tire the party (fatigue). Rest at a camp (free, banks your finds) or make camp anywhere (a Camp Kit, or free with a risk). If all of you fall, you wake at your last camp and lose part of what you carried but did not bank.</p>
      <p>Fights make each of you stronger on the trek (trek level). Your gnome’s own XP comes from milestones: finding your trailmates and bringing down the big foes.</p>
    </details>
  </div>
<?php page_footer(); exit; endif; ?>
<?php
$walkPath = trek_walk_take($run);
if ($run['fi'] || $tab !== 'map') $walkPath = null;   // v1.8.10: the path of the last walk (one-shot; dropped when a fight starts)
$replayHtml = trek_replay_stage($run, $u);   // v1.8.5: taken (and cleared) on every render, shown only on the Map tab
$tabLink = fn(string $t) => e(url('trek.php' . ($t === 'map' ? '' : '?t=' . $t)));
$party = trek_party_stats($run, $u);
$fat = (int)$run['fatigue'];
?>
<nav class="tabs">
  <a class="<?= $tab === 'map' ? 'on' : '' ?>" href="<?= $tabLink('map') ?>"><?= $hub ? '🏕️ Rest stop' : '🗺️ Map' ?></a>
  <a class="<?= $tab === 'party' ? 'on' : '' ?>" href="<?= $tabLink('party') ?>">🧑‍🤝‍🧑 Party</a>
  <a class="<?= $tab === 'pack' ? 'on' : '' ?>" href="<?= $tabLink('pack') ?>">🎒 Pack</a>
  <a class="<?= $tab === 'log' ? 'on' : '' ?>" href="<?= $tabLink('log') ?>">📜 Log</a>
</nav>
<?php if ($tab === 'map' && $hub): ?>
  <?= trek_hub_html($run, $u, $party) ?>
<?php elseif ($tab === 'map'): ?>
  <?= $replayHtml ?>
  <?php
  // v1.8.3: one compact hud card (party, chips, where) instead of loose rows
  $obj = $run['fi'] ? null : trek_objective($run);
  $zone = trek_zone_at((int)$run['chapter'], (int)$run['x'], (int)$run['y']);
  $hud = '<div class="box trekhud">' . ($run['fi'] ? '' : '<div class="hudparty">');   // in a fight the party HP is on the member cards
  foreach ($run['fi'] ? [] : $party as $slot => $m) {
      $hp = (int)$run['party'][$slot]['hp'];
      $hud .= '<div class="hm' . ($hp <= 0 ? ' down' : '') . '"><span class="hn">' . $m['ico'] . ' <b>' . e(trek_short_name((string)$m['name'])) . '</b> <small class="tlv">Lv ' . (int)$m['tl'] . '</small></span>'
          . trek_bar($hp, $m['max']) . '<small>' . $hp . '/' . (int)$m['max'] . '</small></div>';
  }
  $hud .= ($run['fi'] ? '' : '</div>') . '<div class="hudchips"><span class="chip fat ' . ($fat >= 85 ? 'worn' : ($fat >= 60 ? 'tired' : '')) . '">😮‍💨 ' . ($fat >= 85 ? 'Worn out' : 'Tired') . ' ' . $fat . '/100</span>'
      . '<span class="chip">🏕️ ' . (int)$run['campkits'] . ' kits</span>'
      . (empty($run['st']['bless']) ? '' : '<span class="chip">🙏 Blessed</span>')
      . '<span class="chip">🎒 ' . (int)$run['petals_found'] . ' 🪙 carried</span>'
      . '<span class="chip">⚡ ' . (int)$u['energy'] . '</span></div>';
  if (!$run['fi']) $hud .= '<p class="trekwhere">' . e((trek_zone_info((int)$run['chapter'], $zone) ?? ['', ''])[1]) . ' <b>' . e((trek_zone_info((int)$run['chapter'], $zone) ?? ['Somewhere'])[0]) . '</b>' . ($obj ? ' · ❗ ' . e($obj['name']) . ' ' . e(trek_compass($run, $obj)) : '') . '</p>';
  $hud .= '</div>';
  ?>
  <?php if ($run['fi']): ?>
    <div class="trekfightcol">
    <?= $hud ?>
    <?= trek_fight_html($run, $u) ?>
    </div>
  <?php else:
    $latest = trek_latest_html($run); ?>
    <div class="trekplay">
    <?= $hud ?>
    <?php if ((int)($run['st']['turn'] ?? 0) <= 2): ?><div class="trektext small trektut"><?= trek_text('ch' . (int)$run['chapter'] . '.tut.walk') ?></div><?php endif; ?>
    <form method="post" class="trekmapform trekmapcol<?= (int)($run['st']['back'] ?? -1) === (int)($run['st']['turn'] ?? 0) && (int)($run['st']['turn'] ?? 0) > 0 ? ' back' : '' ?>"><?= csrf_field() ?><input type="hidden" name="do" value="go"><input type="hidden" name="t" value="map">
      <?= trek_map_html($run, $u, $walkPath) ?>
    </form>
    <?= trek_legend_html($run) ?>
    <?php /* v2.0.8: the latest log lines sit right under the map, the Sneak / Camp / Leave buttons after them */ ?>
    <?php if ($latest): ?><ul class="trekrounds trekLatest" aria-live="polite"><?php foreach (array_slice($latest, -3) as $l): ?><li><?= $l ?></li><?php endforeach; ?></ul>
      <?php if (!empty($run['st']['flog']) && (int)($run['st']['back'] ?? -1) === (int)($run['st']['turn'] ?? 0)): ?><p class="tkfull"><a href="<?= $tabLink('log') ?>">Full log ›</a></p><?php endif; ?><?php endif; ?>
    <div class="trekacts">
      <div class="trekbtns">
        <?= trek_form('mode', $run['sneak'] ? '🥾 Hunt' : '🤫 Sneak', ['mode' => $run['sneak'] ? 'hunt' : 'sneak', 't' => 'map'], 'btn ghost small') ?>
        <?= trek_form('makecamp', '🏕️ Camp', ['t' => 'map'], $fat >= 100 ? 'btn gold small' : 'btn ghost small') ?>
        <?= trek_form('leave', '🪜 Leave', ['t' => 'map'], 'btn ghost small', trek_leave_confirm()) /* v1.9.0: ask first */ ?>
      </div>
      <p class="help"><?= $run['sneak'] ? 'Sneaking: fewer fights' : 'Hunting: fights find you' ?> · Camp: <?= (int)$run['campkits'] > 0 ? 'uses a kit' : 'free, may be ambushed' ?></p>
    </div>
    <?= trek_event_html($run, $u) ?>
    <?= trek_crew_html($run, $u) ?>
    <?= trek_ms_card_html($run) ?>
    <?= trek_spot_panel($run, $u) ?>
    </div>
  <?php endif; ?>
<?php elseif ($tab === 'party'): ?>
  <div class="box partybox"><h3>Your party</h3>
  <?php foreach ($party as $slot => $m): $hp = (int)$run['party'][$slot]['hp']; $tac = trek_tac_for($run, $m); $sum = trek_tac_summary($m['calling'], $slot === 0, $tac); ?>
    <details class="pmem<?= $hp <= 0 ? ' down' : '' ?>">
      <summary><span class="pico"><?= $m['ico'] ?></span><span class="pwho"><b><?= e(trek_first_name((string)$m['name'])) ?></b><small><?= e(($m['calling'] !== '' ? (CALLINGS[$m['calling']][0] ?? '') : 'Gnome')) ?></small></span>
        <span class="php"><?= trek_bar($hp, $m['max']) ?><small><?= $hp ?>/<?= (int)$m['max'] ?></small></span>
        <span class="ptl"><b>Trek Lv <?= (int)$m['tl'] ?></b><?= trek_xp_bar((int)$m['tl'], (int)$m['txp']) ?></span>
        <?php if ($sum !== ''): ?><small class="ptac"><?= e($sum) ?></small><?php endif; ?></summary>
      <div class="pbody">
        <?= trek_tl_facts((int)$m['tl'], (int)$m['txp'], (int)$m['max'] - (int)$m['tb']['hp']) ?>
        <?= trek_member_facts($m['gc'], $m['calling']) ?>
        <form method="post" class="ptacform"><?= csrf_field() ?><input type="hidden" name="do" value="tactics"><input type="hidden" name="t" value="party"><input type="hidden" name="slot" value="<?= (int)$slot ?>">
          <b class="ptachead">Tactics</b>
          <div class="ptacgrid">
          <?php foreach (trek_tac_fields($m['calling'], $slot === 0, $tac) as [$fname, $flabel, $opts, $cur]): ?>
            <label><span><?= e($flabel) ?></span><select name="<?= e($fname) ?>"><?php foreach ($opts as $ov => $ot): ?><option value="<?= e((string)$ov) ?>"<?= (string)$ov === (string)$cur ? ' selected' : '' ?>><?= e((string)$ot) ?></option><?php endforeach; ?></select></label>
          <?php endforeach; ?>
          </div>
          <button class="btn small">Save</button>
        </form>
      </div>
    </details>
  <?php endforeach; ?>
  </div>
  <?php
  $recruits = trek_recruits((int)$run['id']);
  $inParty = array_map(fn($p) => $p['crew_key'], $run['party']);
  $waiting = array_values(array_filter($recruits, fn($rk) => !in_array($rk, $inParty, true)));
  $atCamp = trek_at_camp($run) && !$run['fi'];
  ?>
  <div class="box partybox"><h3>Trailmates</h3>
  <?php if (!$recruits): ?><p class="help">None yet. You will meet some on the way.</p><?php endif; ?>
  <?php foreach ($waiting as $rk): $cu = trek_crew_user($rk, $u); $cg = gnome_combat($cu); $cc = (string)$cu['calling']; ?>
    <details class="pmem wait">
      <?php [$wl, $wx] = trek_tl_get($run, $rk); $wb = trek_tl_bonus($wl, (int)$cg['max_hp']); ?>
      <summary><span class="pico"><?= TREK_CREW_ICONS[$cc] ?? '🧑' ?></span><span class="pwho"><b><?= e(trek_first_name((string)trek_crew_npc($rk)['name'])) ?></b><small><?= e((CALLINGS[$cc][0] ?? '')) ?></small></span>
        <span class="ptl"><b>Trek Lv <?= $wl ?></b><?= trek_xp_bar($wl, $wx) ?></span></summary>
      <div class="pbody"><?= trek_tl_facts($wl, $wx, (int)$cg['max_hp']) ?><?= trek_member_facts($cg, $cc) ?></div>
    </details>
  <?php endforeach; ?>
  <?php if ($recruits && $atCamp): ?>
    <details class="helpfold"><summary>Change the party</summary>
    <form method="post" class="form"><?= csrf_field() ?><input type="hidden" name="do" value="party"><input type="hidden" name="t" value="party">
      <?php foreach ([1, 2, 3] as $slot): $cur = (string)($run['party'][$slot]['crew_key'] ?? ''); ?>
        <label>Place <?= $slot ?><select name="p<?= $slot ?>"><option value="">(empty)</option>
          <?php foreach ($recruits as $rk): ?><option value="<?= e($rk) ?>"<?= $rk === $cur ? ' selected' : '' ?>><?= e(trek_crew_npc($rk)['name']) ?> (<?= e(CALLINGS[trek_crew()[$rk]['calling'] ?? ''][0] ?? '') ?>)</option><?php endforeach; ?>
        </select></label>
      <?php endforeach; ?>
      <button class="btn small">Set the party</button></form>
    </details>
  <?php elseif ($recruits): ?><p class="help">Swap trailmates at a camp.</p><?php endif; ?>
  </div>
<?php elseif ($tab === 'pack'): ?>
  <?php
  $rows = trek_pack_rows((int)$run['id']);
  $carried = array_values(array_filter($rows, fn($r) => !(int)$r['banked']));
  $banked = array_values(array_filter($rows, fn($r) => (int)$r['banked']));
  $pb = (int)($run['st']['petals_banked'] ?? 0);
  $nBank = count($banked) + ($pb ? 1 : 0);
  $cur = e(setting('currency_name'));
  ?>
  <div class="trekpackview">
    <div class="packchips"><span class="chip">🎒 <?= (int)$run['petals_found'] ?> 🪙 carried</span><span class="chip">🏕️ <?= (int)$run['campkits'] ?>/<?= (int)setting('trek_campkit_max') ?> kits</span><span class="chip">✅ <?= $pb ? $pb . ' 🪙' : $nBank . ' items' ?> banked</span></div>
    <details class="helpfold packhelp"><summary>ℹ️ Bank at camp</summary><p class="help">Rest at a camp to bank: items go straight to your Satchel and Petals to your purse. Carried finds can be lost if the party is knocked out. Quest items are safe.</p></details>
    <?php if (!$carried && !(int)$run['petals_found'] && (int)$run['campkits'] < 1): ?><p class="muted packnone">Nothing yet.</p><?php else: ?>
    <div class="satchel packgrid">
      <?php if ((int)$run['petals_found']): ?>
        <details class="itile"><summary><span class="iicon">🪙</span><span class="iname"><?= $cur ?></span><b class="iqty"><?= (int)$run['petals_found'] ?></b></summary>
          <div class="ipop"><button type="button" class="ipclose" aria-label="Close">✕</button><b><?= $cur ?></b><p>Found on the trek. Bank it at a camp.</p></div></details>
      <?php endif; ?>
      <?php if ((int)$run['campkits'] > 0): ?>
        <details class="itile"><summary><span class="iicon">🏕️</span><span class="iname">Camp Kit</span><b class="iqty"><?= (int)$run['campkits'] ?></b></summary>
          <div class="ipop"><button type="button" class="ipclose" aria-label="Close">✕</button><b>Camp Kit</b><div class="trektext small"><?= trek_text('item.camp-kit') ?></div></div></details>
      <?php endif; ?>
      <?php foreach ($carried as $r): $quest = trek_is_quest_item((int)$r['item_id']); $note = isset(trek_text_rows()['item.' . $r['slug']]) ? trek_text('item.' . $r['slug']) : ''; ?>
        <details class="itile"><summary><span class="iicon"><?= item_icon($r) ?></span><span class="iname"><?= e($r['name']) ?></span><b class="iqty"><?= (int)$r['qty'] ?></b></summary>
          <div class="ipop"><button type="button" class="ipclose" aria-label="Close">✕</button><b><?= e($r['name']) ?></b><?= $quest ? ' <span class="cat">quest item</span>' : '' ?>
            <?php if ($note !== ''): ?><div class="trektext small"><?= $note ?></div><?php elseif (trim((string)$r['description']) !== ''): ?><p><?= desc_html((string)$r['description']) ?></p><?php endif; ?></div></details>
      <?php endforeach; ?>
    </div>
    <?php endif; ?>
    <details class="helpfold packbank"><summary>✅ Banked so far (<?= $nBank ?>)</summary>
      <?php if (!$nBank): ?><p class="muted">Nothing banked yet.</p><?php else: ?>
      <div class="satchel packgrid"><?php /* v1.8.9: banked items as Satchel tiles, like the carried ones */ ?>
      <?php if ($pb): ?><details class="itile"><summary><span class="iicon">🪙</span><span class="iname"><?= $cur ?></span><b class="iqty"><?= $pb ?></b></summary>
        <div class="ipop"><button type="button" class="ipclose" aria-label="Close">✕</button><b><?= $cur ?></b><p>Already added to your Petals.</p></div></details><?php endif; ?>
      <?php foreach ($banked as $r): ?>
        <details class="itile"><summary><span class="iicon"><?= item_icon($r) ?></span><span class="iname"><?= e($r['name']) ?></span><b class="iqty"><?= (int)$r['qty'] ?></b></summary>
          <div class="ipop"><button type="button" class="ipclose" aria-label="Close">✕</button><b><?= e($r['name']) ?></b> <span class="cat">in your Satchel</span><?php if (isset(trek_text_rows()['item.' . $r['slug']])): ?><div class="trektext small"><?= trek_text('item.' . $r['slug']) ?></div><?php elseif (trim((string)($r['description'] ?? '')) !== ''): ?><p><?= desc_html((string)$r['description']) ?></p><?php endif; ?></div></details>
      <?php endforeach; ?></div>
      <?php endif; ?>
    </details>
  </div>
<?php else: ?>
  <?php $lastFight = trek_flog_html($run); if ($lastFight): ?>
    <div class="box trekwhat tklastfight"><h3>⚔️ Last fight</h3><?= trek_flog_box($lastFight) ?></div>
  <?php endif; ?>
  <div class="box"><?= trek_ms_list_html($run) ?></div>
  <?php foreach (trek_runs_of($uid) as $orow): if ((int)$orow['id'] === (int)$run['id']) continue; $or = trek_load($orow); $on = trek_chapter((int)$or['chapter']); ?>
    <div class="box"><details class="helpfold"><summary>📜 Chapter <?= e($on['roman']) ?>: <?= e($on['title']) ?></summary>
      <?= trek_ms_list_html($or, 'Milestones') ?>
      <ul class="journal"><?php foreach (array_reverse($or['lg']) as $l): $lt = trek_line_html($l); if ($lt === '') continue; ?><li><?= $lt ?></li><?php endforeach; ?></ul>
    </details></div>
  <?php endforeach; ?>
  <div class="box"><h3>📜 Log</h3>
    <ul class="journal"><?php foreach (array_reverse($run['lg']) as $l): $lt = trek_line_html($l); if ($lt === '') continue; ?><li><?= $lt ?></li><?php endforeach; ?></ul>
    <?php if (!$run['lg']): ?><p>Nothing yet.</p><?php endif; ?></div>
<?php endif; ?>
<?php page_footer();
