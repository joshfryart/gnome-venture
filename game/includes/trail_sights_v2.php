<?php
declare(strict_types=1);

/**
 * Sights v2 (2.8.99, claude/proposal-sights-rework.md "one tap, one gift, one stamp"), slices 1 to 3 of its section 5.1. Everything here is dark behind the
 * setting sights_v2_open (default 0): with it off nothing in this file is called and the Sights work exactly as before.
 *  - the card: name, one line, "Gives:" words, at most one errand line (your next step only), one villager line (only when one is there now), one Almanac line,
 *    one button with the verb and the noun. A resting Sight says "Resting. Back in N sleeps."; a Sight waiting for its time says when, with no button.
 *  - tap the picture on the map: the gnome walks there (trail_go) and the card opens.
 *  - no fail (trail_sight_do's v2 branch): a check never blocks or costs; a miss pays the row at half (sights_v2_half_tok + half Petals / XP) and shows the old
 *    miss line; every pick pays (the right one is the lucky one); a missing tool pays half with a tip; no cap of Sights per walk.
 *  - the result card: the story line, up to 3 gift chips, the lucky line, the Almanac line, the resting line, one "Lovely" button.
 * The balance simulation is tests/sights_v2_sim.php.
 */

/** Is Sights v2 on (setting sights_v2_open)? */
function sights_v2_on(): bool
{
    return setting('sights_v2_open') === '1';
}

/** The seven words a "Gives:" line may use, in the order they are shown (things you can hold first). */
const SIGHTS_V2_GIVE_WORDS = ['food', 'seeds', 'things', 'Petals', 'a boost', 'know-how', 'a tip'];

/** The Gives word of one reward token ('' = none: tallies, streaks, costs, time). Pure. */
function sights_v2_give_word(string $tok): string
{
    [$k, $v] = array_pad(explode('=', $tok, 2), 2, '');
    $slug = explode(':', $v)[0];
    switch ($k) {
        case 'c': return 'Petals';
        case 'xp': return 'know-how';
        case 'crop': case 'fish': return 'food';
        case 'seed': return 'seeds';
        case 'item': return preg_match('/-seeds?$/', $slug) ? 'seeds' : 'things';
        case 'find': case 'gather': case 'repay': return 'things';
        case 'buff': case 'buff2': case 'en': case 'disc': return 'a boost';
        case 'hint': case 'reveal': case 'page': case 'unlock': case 'nxt': case 'nextkind': case 'sec': case 'fpto': case 'fpall': case 'fp': case 'title': return 'a tip';
    }
    return '';
}

/** The "Gives:" words of a Sight row: 1 to 3 words of SIGHTS_V2_GIVE_WORDS, from its own reward tokens (a choose= counts each option). Never chances, never conditions. Pure. */
function sights_v2_gives(array $row): array
{
    $have = [];
    foreach (trail_sight_tokens((string)$row['rewards']) as $t) {
        if (!empty($t['lose'])) continue;
        $toks = str_starts_with($t['tok'], 'choose=') ? array_filter(array_map('trim', explode(';', substr($t['tok'], 7)))) : [$t['tok']];
        foreach ($toks as $tk) { $w = sights_v2_give_word((string)preg_replace('/@[\d\/]+$/', '', $tk)); if ($w !== '') $have[$w] = true; }
    }
    $out = array_values(array_filter(SIGHTS_V2_GIVE_WORDS, fn($w) => isset($have[$w])));
    return $out ? array_slice($out, 0, 3) : ['a tip'];
}

/** The button text: the verb and the noun ("Blow the dandelion clocks"). A verb of two or more words already has its noun ("Pick berries"). */
function sights_v2_button_label(array $row, string $name): string
{
    $verb = trim((string)$row['verb']);
    if (str_contains($verb, ' ') || $name === '') return $verb;
    return $verb . ' ' . (preg_match('/^(The|A|An) /', $name) ? lcfirst($name) : $name);
}

/** The gate line of a Sight that is waiting for its time, season or weather ("Comes out at dusk."). */
function sights_v2_gate_line(array $row): string
{
    $tx = trail_sight_cond_text((string)$row['when']);
    return $tx !== '' ? 'Comes out ' . $tx . '.' : 'Not just now.';
}

/** Whole sleeps (game days; real days with the sleep-days clock off) until this resting Sight is ready again. 0 = ready (or uses left in its window). */
function sights_v2_rest_sleeps(array $u, array $sc, array $row): int
{
    [$left] = trail_sight_state((int)$u['id'], $sc, $row);
    if ($left > 0) return 0;
    $route = (int)substr((string)$sc['row']['map_key'], 6);
    $sec = trail_phys_sec($route, (int)$sc['st']['sec'], $sc['st']);
    try { $r = q_one('SELECT * FROM trail_sight_uses WHERE user_id = ? AND route_id = ? AND sec = ? AND slug = ?', [(int)$u['id'], $route, $sec, $row['slug']]); } catch (Throwable $e) { return 0; }
    if (!$r) return 0;
    $uu = q_one('SELECT * FROM users WHERE id = ?', [(int)$u['id']]);
    if ($uu && gclock_on() && $r['got_tick'] !== null) {
        $rest = (int)round($row['cd'] * 144) - (gclock_state($uu)['tick'] - (int)$r['got_tick']);
        return $rest > 0 ? (int)ceil($rest / 1440) : 0;
    }
    $rest = (int)round($row['cd'] * 8640) - (time() - (int)$r['got_at']);
    return $rest > 0 ? (int)ceil($rest / 86400) : 0;
}

/** "Resting. Back in 6 sleeps." */
function sights_v2_rest_line(int $n, string $lead = 'Resting.'): string
{
    return $lead . ' Back in ' . max(1, $n) . ' sleep' . (max(1, $n) === 1 ? '' : 's') . '.';
}

/** The tip for a tool Sight used without the tool (or with too worn a one): 'A tide bucket would get more here.' '' = the tool is fine, or the Sight needs none. */
function sights_v2_tool_hint(int $uid, array $row): string
{
    if (($row['tool'] ?? '-') === '-') return '';
    require_once __DIR__ . '/gathering.php'; require_once __DIR__ . '/tools.php';
    [$tt, $tier] = array_pad(explode(':', (string)$row['tool']), 2, '1');
    if (tool_tier($uid, $tt) >= (int)$tier) return '';
    $noun = GATHER_TOOL_NOUN[$tt] ?? 'tool';
    $what = (int)$tier > 1 ? (TOOL_TIERS[(int)$tier] ?? '') . ' ' . $noun : $noun;
    return (preg_match('/^[aeiou]/i', $what) ? 'An ' : 'A ') . $what . ' would get more here.';
}

/**
 * One reward token paid at half (a miss, or no tool): a thing comes at half the chance (item=x:2 -> item=x:2@50, @30 -> @15), energy back is halved, friendship is
 * halved (at least 1); an odd @chance rounds up or down at random ($up fixes it). Petals and XP stay as written here: stop_rewards() halves those through its scale. Anything else is unchanged. Pure: the balance sim uses it too.
 */
function sights_v2_half_tok(string $tok, ?bool $up = null): string
{
    [$k] = explode('=', $tok, 2);
    if (in_array($k, ['item', 'crop', 'find', 'fish', 'seed', 'buff', 'buff2'], true)) {
        if (preg_match('/^(.*)@(\d+)$/', $tok, $m)) { $c = (int)$m[2]; $h = intdiv($c, 2) + ($c % 2 && ($up ?? random_int(0, 1) === 1) ? 1 : 0); return $h > 0 ? $m[1] . '@' . $h : ''; }   // an odd chance: half a point up or down, at random ($up: the sim asks for each), so the average is exactly half
        return $tok . '@50';
    }
    if ($k === 'en') { $n = intdiv((int)substr($tok, 3), 2); return $n > 0 ? 'en=' . $n : ''; }
    if ($k === 'fp') return 'fp=' . max(1, (int)ceil((int)substr($tok, 3) / 2));
    return $tok;
}

/** Where to walk to reach a Sight: its own tile if the gnome can stand there, else the nearest standable tile beside it. null = already beside it, or no way. */
function sights_v2_walk_target(array $sc, int $lx, int $ly): ?array
{
    if (max(abs($lx - (int)$sc['x']), abs($ly - (int)$sc['y'])) <= 1) return null;
    $best = null; $bd = PHP_INT_MAX;
    foreach ([[0, 0], [0, 1], [1, 0], [-1, 0], [0, -1], [1, 1], [-1, 1], [1, -1], [-1, -1]] as [$dx, $dy]) {
        $tx = $lx + $dx; $ty = $ly + $dy;
        $t = tm_tile($sc['map'], $tx, $ty);
        if ($t === '#' || $t === ' ' || $t === '') continue;
        $d = abs($tx - (int)$sc['x']) + abs($ty - (int)$sc['y']) + ($dx === 0 && $dy === 0 ? 0 : 1);
        if ($d < $bd) { $bd = $d; $best = [$tx, $ty]; }
    }
    return $best;
}

/** Tap a Sight's picture: walk next to it (the usual trail_go walk; a fight on the way stops it as always). [ok, message]. Already beside it = ok, no walk. */
function sights_v2_go(array $u, array &$exp, string $slug): array
{
    $sc = trail_scene($exp);
    if (!$sc || ($sc['st']['phase'] ?? '') !== 'section') return [false, 'Not now.'];
    foreach (trail_sights_marks($u, $sc) as $m) {
        if ($m['slug'] !== $slug) continue;
        $to = sights_v2_walk_target($sc, $m['x'], $m['y']);
        if ($to === null) return [true, ''];
        $res = trail_go($u, $exp, $to[0], $to[1]);
        if (!$res[0] && max(abs($m['x'] - $to[0]), abs($m['y'] - $to[1])) > 0) $res = trail_go($u, $exp, $m['x'], $m['y']);   // the side tile has no way in: try the Sight's own tile
        return $res;
    }
    return [false, 'There is nothing to do here.'];
}

/** The map tiles a tap on a Sight's picture covers: ['x,y' => slug] (the landmark's own tile and the tiles under its sprite). */
function sights_v2_map_taps(array $sc, array $marks): array
{
    $out = []; $want = [];
    foreach ($marks as $m) $want[$m['x'] . ',' . $m['y']] = $m['slug'];
    foreach ((array)($sc['map']['art']['objs'] ?? []) as $ob) {
        $key = (string)($ob[2] ?? ''); $ax = (int)$ob[0]; $ay = (int)$ob[1];
        if (strncmp($key, 'lm-', 3) !== 0 || ($want[$ax . ',' . $ay] ?? '') !== substr($key, 3)) continue;
        $slug = substr($key, 3);
        $out[$ax . ',' . $ay] = $slug;
        if (!function_exists('trail_art_obj_size')) continue;
        [$bw, $bh] = trail_art_obj_size($key);
        $x0 = $ax * 64 + 32 - intdiv($bw, 2) + (int)($ob[3] ?? 0); $x1 = $x0 + $bw; $y1 = $ay * 64 + 62 + (int)($ob[4] ?? 0); $y0 = $y1 - $bh;
        for ($ty = intdiv(max(0, $y0), 64); $ty <= $ay; $ty++) for ($tx = intdiv(max(0, $x0), 64); $tx * 64 < $x1; $tx++) {
            $cx = $tx * 64 + 32; $cy = $ty * 64 + 32;
            if ($cx >= $x0 && $cx < $x1 && $cy >= $y0 && $cy < $y1) $out[$tx . ',' . $ty] ??= $slug;
        }
    }
    return $out;
}

/** The foot-row button: one Sights button. Beside a ready Sight it is that Sight's button (verb and noun); it opens the card. '' when the stretch has no Sights. */
function sights_v2_foot_html(array $u, array $sc, array $marks): string
{
    if (!$marks) return '';
    foreach (trail_sights_here($u, $sc) as [$row, $left]) {
        if ($left < 1) continue;
        $nm = trail_sight_label($row['slug'])[0];
        return '<a class="btn trailsight trailsights" data-pop="hubpop-tsights" href="' . e(url('adventure.php?sg=1&sgs=' . $row['slug'])) . '">' . e($row['icon']) . ' ' . e(sights_v2_button_label($row, $nm)) . ' <small>' . ((int)$row['energy'] > 0 ? '⚡' . (int)$row['energy'] : 'free') . '</small></a>';
    }
    return '<a class="btn alt trailsights" data-pop="hubpop-tsights" href="' . e(url('adventure.php?sg=1')) . '">🔎 Sights <small>' . count($marks) . '</small></a>';
}

/** The cards of the Sights panel under v2: the one asked for ($focus, from a tap on its picture), else every Sight of the stretch with the ones beside the gnome first. */
function sights_v2_cards_html(array $u, array $sc, array $marks, ?array $exp = null, string $focus = ''): string
{
    $near = fn(array $m) => max(abs($m['x'] - (int)$sc['x']), abs($m['y'] - (int)$sc['y'])) <= 1;
    if ($focus !== '' && ($one = array_values(array_filter($marks, fn($m) => $m['slug'] === $focus)))) $marks = $one;
    else usort($marks, fn($a, $b) => (int)$near($b) <=> (int)$near($a));
    $loc = $exp ? (q_one('SELECT * FROM locations WHERE id = ?', [(int)$exp['from_id']]) ?: []) : [];
    $h = '';
    foreach ($marks as $m) $h .= sights_v2_card_html($u, $sc, $m, $loc, $near($m), $exp);
    return $h !== '' ? $h : '<p class="muted">Nothing to do at the Sights of this stretch.</p>';
}

/** One v2 card. $m = a trail_sights_marks() entry. At most 4 info lines (gives, errand, villager, Almanac), then the state line or the button. */
function sights_v2_card_html(array $u, array $sc, array $m, array $loc, bool $near, ?array $exp = null): string
{
    $row = $m['row']; $slug = $m['slug']; $uid = (int)$u['id'];
    [$name, $cap] = trail_sight_label($slug);
    $loc += ['landscape' => 'grassland']; $loc['name'] = $row['verb'];
    $now = trail_sight_now($loc, $sc, $u);
    $lines = ['<p class="sgv2l sggives"><b>Gives:</b> ' . e(implode(', ', sights_v2_gives($row))) . '</p>'];
    foreach (trail_sight_quest_notes($uid, $slug) as [$qt, , , $st]) if ($st === 'next') { $lines[] = '<p class="sgv2l sgq">📜 Errand: <b>' . e($qt) . '</b> (your next step)</p>'; break; }
    foreach (trail_sight_folk_here($slug, $now, $uid) as $fh) { $lines[] = sights_v2_folk_line($u, $sc, $m, $fh, $now, $near, $exp); break; }
    $seen = false; try { $seen = (bool)q_val('SELECT 1 FROM trail_sight_first WHERE user_id = ? AND slug = ?', [$uid, $slug]); } catch (Throwable $e) {}
    $lines[] = '<p class="sgv2l sgpage">📖 ' . ($seen ? 'Its page is in Wren\'s Almanac.' : 'First visit: a new page for Wren\'s Almanac.') . '</p>';
    $label = sights_v2_button_label($row, $name);
    if ($m['left'] < 1) $act = '<p class="sgrest">' . e(sights_v2_rest_line(sights_v2_rest_sleeps($u, $sc, $row))) . '</p>';
    elseif ($row['when'] !== '-' && !trail_sight_cond_ok((string)$row['when'], $now)) $act = '<p class="sgrest">' . e(sights_v2_gate_line($row)) . '</p>';
    elseif (!$near) $act = '<form method="post" class="inline sgv2do">' . csrf_field() . '<input type="hidden" name="do" value="trail_go"><button class="btn" name="gosg" value="' . e($slug) . '">' . e($row['icon']) . ' ' . e($label) . ' <small>walk there</small></button></form>';
    else {
        $pk = trail_sight_pick_info($row); $ch = trail_sight_choose_info($row);
        $cost = (int)$row['energy'] > 0 ? '⚡' . (int)$row['energy'] : 'free';
        $head = '<form method="post" class="inline sgv2do' . ($pk || $ch ? ' sgpick' : '') . '">' . csrf_field() . '<input type="hidden" name="do" value="sight"><input type="hidden" name="slug" value="' . e($slug) . '">';
        if ($ch) $act = $head . '<span class="muted">' . e($label) . ' (' . $cost . '). Choose one:</span>' . implode('', array_map(fn($i, $o) => '<button class="btn" name="reward" value="' . $i . '">' . e($row['icon']) . ' ' . e((trail_sight_free_pick($row) ? $pk[1][$i] . ': ' : '') . $o[1]) . '</button>', array_keys($ch), $ch)) . '</form>';
        elseif ($pk) $act = $head . '<span class="muted">' . e($label) . ' (' . $cost . '). Choose one:</span>' . implode('', array_map(fn($i, $lb) => '<button class="btn" name="pick" value="' . $i . '">' . e($row['icon']) . ' ' . e($lb) . '</button>', array_keys($pk[1]), $pk[1])) . '</form>';
        else $act = $head . '<button class="btn">' . e($row['icon']) . ' ' . e($label) . ' <small>' . $cost . '</small></button></form>';
    }
    return '<div class="sgcard sgv2" id="sgv2-' . e($slug) . '"><img class="sgpic" alt="" src="' . e(trail_art_url('obj/lm-' . $slug . '.png')) . '"><div class="sgbody"><h4>' . e($name) . '</h4>'
        . ($cap !== '' ? '<p class="help sgline">' . e($cap) . '</p>' : '') . implode('', $lines) . $act . '</div></div>';
}

/** The one villager line of a v2 card: "Basil is here." with what they ask for (the Give button, or their question), and Say hello when they stand on the map. */
function sights_v2_folk_line(array $u, array $sc, array $m, array $fh, array $now, bool $near, ?array $exp): string
{
    $nm = trail_sight_split_who($fh['who'])[0];
    $h = '<p class="sgv2l sgfolk">💬 <b>' . e($nm) . '</b> is here.';
    $gv = null; foreach (trail_sight_tokens($fh['rewards']) as $tk) if (str_starts_with($tk['tok'], 'give=')) $gv = explode(':', substr($tk['tok'], 5));
    if ($gv) {
        $anyG = preg_match(SIGHTS5_ANY_RE, $gv[0]) ? substr($gv[0], 4) : null;
        $gid = $anyG !== null ? 0 : (int)q_val('SELECT id FROM items WHERE slug = ?', [$gv[0]]); $gq = max(1, (int)($gv[1] ?? 1));
        $has = $anyG !== null ? sights5_any_have((int)$u['id'], $anyG)[1] >= $gq : ($gid && (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [(int)$u['id'], $gid]) >= $gq);
        $h .= ' They would like ' . $gq . ' × ' . e($anyG !== null ? sights5_any_label($anyG) : (string)q_val('SELECT name FROM items WHERE id = ?', [$gid])) . '.';
        if ($has && $near) $h .= ' <form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="sightgive"><input type="hidden" name="slug" value="' . e($m['slug']) . '"><input type="hidden" name="idx" value="' . (int)$fh['idx'] . '"><button class="btn small">🎁 Give</button></form>';
    } elseif (($vc = sights6a_folk_choose_html($u, $m['slug'], $fh, $near)) !== '') $h .= ' ' . $vc;
    if ($exp) foreach (trail_sights_folk_on_map($u, $exp, $sc, trail_sights_marks($u, $sc)) as $fi => $fe) if (($fe[8] ?? '') === $m['slug']) { $h .= ' <a class="btn small alt" data-pop="hubpop-tfolk-' . (int)$fi . '" href="' . e(url('adventure.php')) . '">Say hello</a>'; break; }
    return $h . '</p>';
}

/** Keep the result of a v2 Sight use for the result card (shown once, on the next Trail page). */
function sights_v2_result_set(array $r): void
{
    if (session_status() === PHP_SESSION_ACTIVE) $_SESSION['sight_v2_res'] = $r;
}

/**
 * The gift chips of a result: up to 3 of the lines that hand something over ("+5 Petals", "+1 × Clover"); the rest are counted.
 * [chips, how many more, the first other line worth saying (an errand step, a villager) or ''].
 */
function sights_v2_result_parts(array $lines): array
{
    $gift = []; $other = [];
    foreach ($lines as $l) {
        $l = trim((string)$l);
        if ($l === '') continue;
        if (preg_match('/^(\+|💛|🌱|🎣|📗|✨)/u', $l)) $gift[] = $l; else $other[] = $l;
    }
    $also = '';
    foreach ($other as $o) if (!preg_match('/^(🪨|⏱️|🎲|📖)/u', $o)) { $also = $o; break; }
    return [array_slice($gift, 0, 3), max(0, count($gift) - 3), $also];
}

/** The result card (a pop-up on a phone, under the buttons on a computer), shown once after a use. '' when there is none. */
function sights_v2_result_html(): string
{
    if (session_status() !== PHP_SESSION_ACTIVE || empty($_SESSION['sight_v2_res']) || !is_array($_SESSION['sight_v2_res'])) return '';
    $r = $_SESSION['sight_v2_res']; unset($_SESSION['sight_v2_res']);
    [$chips, $more, $also] = sights_v2_result_parts((array)($r['lines'] ?? []));
    $h = '<p class="sgstory">' . e((string)($r['text'] ?? '')) . '</p>';
    if ($chips) $h .= '<p class="sgchips">' . implode('', array_map(fn($c) => '<span class="sgchip">' . e($c) . '</span>', $chips)) . ($more ? '<span class="sgchip more">and ' . $more . ' more</span>' : '') . '</p>';
    if (($r['lucky'] ?? '') !== '') $h .= '<p class="sglucky">' . e((string)$r['lucky']) . '</p>';
    if (($r['hint'] ?? '') !== '') $h .= '<p class="sghint">' . e((string)$r['hint']) . '</p>';
    if (!empty($r['page'])) $h .= '<p class="sgpage">📖 New page for Wren\'s Almanac</p>';
    if ($also !== '') $h .= '<p class="sgalso">Also: ' . e($also) . '</p>';
    if (($r['rest'] ?? '') !== '') $h .= '<p class="sgrest">' . e((string)$r['rest']) . '</p>';
    $h .= '<p class="actrow"><a class="btn primary" href="' . e(url('adventure.php')) . '" data-pop-close>Lovely</a></p>';
    return '<dialog class="picker hubpop sginline sgpromote sgres" id="hubpop-tsightres" aria-labelledby="hubpop-tsightres-t" open><div class="pickbox">'
        . '<div class="pickhead"><h3 id="hubpop-tsightres-t">' . e((string)($r['icon'] ?? '🔎')) . ' ' . e((string)($r['title'] ?? 'A Sight')) . '</h3><a class="pickx" href="' . e(url('adventure.php')) . '" data-pop-close aria-label="Close">✕</a></div>'
        . '<div class="hubcard sgcards">' . $h . '</div></div></dialog>';
}
