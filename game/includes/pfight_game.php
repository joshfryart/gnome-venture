<?php
declare(strict_types=1);
/**
 * Puzzle Combat glue: flag, building a fight from the real gnome and creature, POST handling, the fight card.
 * The engine (pfight.php) is pure; this file is the only place it touches the database, the expedition and the old win/knock-out code.
 * Flag off = the old fight, untouched.
 */
require_once __DIR__ . '/pfight.php';
require_once __DIR__ . '/pfboard.php';

/** Setting pfight_open: 0 off, admin = admins only, 1 = everyone. Fights in road, lair and delve (Treks are not covered yet). */
function pfight_on(array $u): bool
{
    $v = setting('pfight_open');
    if ($v === '1') return true;
    return $v === 'admin' && ($u['role'] ?? '') === 'admin';
}

/** The gnome's tile numbers: stat modifiers (with the pal road perk and the old calling numbers remapped) and the per-type bonuses. Used by the fight and the Puzzle box page. */
function pfight_calc(array $u): array
{
    $st = ['level' => (int)$u['level']];
    foreach (['grit', 'nimble', 'hardiness', 'charm', 'lore', 'luck'] as $k) $st[$k] = eff_mod($u, $k);
    $pals = [];
    if (setting('ppal_party') === '1') {
        require_once __DIR__ . '/puzzle_pals.php';
        if ((int)$u['level'] >= PPAL_PARTY_LEVEL) {
            $road = (int)ppal_perks($u)['road'];   // the road perk (+N Grit, Nimble, Hardiness) is a passive and stays, as in gnome_combat()
            foreach (['grit', 'nimble', 'hardiness'] as $k) $st[$k] += $road;
            $pals = pfight_pal_tiles($u);
        }
    }
    // the old calling numbers, remapped (no d20 any more): extra damage, defence and the Wayfinder's Nimble attack become tile values; a keen crit range becomes +1 Hurt
    $hurtB = calling_perk($u, 'dmg_bonus') + (calling_perk($u, 'atk_bonus') >= 2 ? 1 : 0) + (calling_perk($u, 'crit_from', 20) <= 19 ? 1 : 0);
    if (calling_perk($u, 'atk_nimble') > 0) $st['grit'] = max($st['grit'], $st['nimble'] + calling_perk($u, 'atk_nimble'));
    return [$st, $pals, ['hurt' => $hurtB, 'guard' => calling_perk($u, 'def_bonus')]];
}

/** The player side of a fight: stats modifiers, the Puzzle box they packed (plus pals swapping in), HP carried in the expedition. */
function pfight_me(array $u, array $exp, array $enc = []): array
{
    [$st, $pals, $bonus] = pfight_calc($u);
    $cal = (string)($u['calling'] ?? '');
    $box = pf_box((int)$u['level'], $cal, pbox_load((int)$u['id']));
    $canSnack = snacks_left($u, $enc) > 0 && fight_snacks($u) !== [];   // no snack to eat = a weak Breather instead of a dead Snack tile
    $deck = pfight_apply_mods(pf_player_deck($st, $cal, max(1, min(3, (int)calling_tier($u))), $pals, [], $bonus, $canSnack, $box), pfight_mods((int)$u['id']));
    return ['hp' => max(1, (int)$exp['hp']), 'max_hp' => (int)$exp['max_hp'], 'stats' => $st, 'deck' => $deck, 'luck' => max(0, $st['luck'])];
}

/** The Puzzle box a gnome packed: a list of tile keys, or null (use the default). One row per gnome; the table is made on first use. */
function pbox_ensure(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    try { q('SELECT 1 FROM user_pbox LIMIT 1'); return $ok = true; } catch (Throwable $e) {}
    try { db()->exec('CREATE TABLE IF NOT EXISTS user_pbox (user_id INTEGER NOT NULL PRIMARY KEY, tiles TEXT NOT NULL)'); return $ok = true; }
    catch (Throwable $e) { error_log('pbox_ensure: ' . $e->getMessage()); return $ok = false; }
}

function pbox_load(int $uid): ?array
{
    if (!pbox_ensure()) return null;
    $j = q_val('SELECT tiles FROM user_pbox WHERE user_id = ?', [$uid]);
    $a = $j ? json_decode((string)$j, true) : null;
    return is_array($a) ? array_values(array_filter($a, 'is_string')) : null;
}

/** Save (or with null, reset to the default). Returns an error message or null. */
function pbox_save(array $u, ?array $keys): ?string
{
    if (!pbox_ensure()) return 'The box is not ready yet. Try again in a moment.';
    $uid = (int)$u['id'];
    if ($keys === null) { q('DELETE FROM user_pbox WHERE user_id = ?', [$uid]); return null; }
    $own = pf_collection((int)$u['level'], (string)($u['calling'] ?? ''));
    $keys = array_values(array_unique(array_filter($keys, fn($k) => is_string($k) && in_array($k, $own, true))));
    if ($why = pf_box_check($keys, pf_box_capacity((int)$u['level']))) return $why;
    q('DELETE FROM user_pbox WHERE user_id = ?', [$uid]);
    q('INSERT INTO user_pbox (user_id, tiles) VALUES (?, ?)', [$uid, json_encode($keys)]);
    return null;
}

/**
 * Pal tiles: each equipped pal (2 at most) swaps in for one gnome tile. The in-fight skills and the active Boon of that pal CONVERT into its tile (no double dip:
 * pfight_me() never applies ppal_skills). The skill kind decides the tile type; its numbers plus rarity decide the value. Passive out-of-fight perks are untouched.
 */
function pfight_pal_tiles(array $u): array
{
    $kindType = ['ward' => 'guard', 'foot' => 'guard', 'guard' => 'guard', 'bulwark' => 'guard', 'slip' => 'guard', 'edge' => 'hurt', 'first' => 'hurt',
        'mend' => 'heal', 'sip' => 'heal', 'feast' => 'heal', 'rally' => 'heal', 'petal' => 'charm', 'kindle' => 'trick', 'tonic' => 'trick'];   // bulwark, spoils and lesson still work the old way (max health, drops, XP) so they are not also tiles
    $activeType = ['strike' => 'hurt', 'sap' => 'hurt', 'shield' => 'guard', 'patch' => 'heal', 'snare' => 'trick', 'daze' => 'trick', 'rouse' => 'trick', 'gust' => 'trick'];
    $swapFor = ['hurt' => 'swing', 'guard' => 'dodge', 'heal' => 'rest', 'charm' => 'charm', 'trick' => 'hide'];
    $knob = ['hurt' => 'mind', 'guard' => 'craft', 'heal' => 'body', 'charm' => 'body', 'trick' => 'mind'];
    $out = []; $used = [];
    foreach (array_slice((array)ppal_equipped($u), 0, 2) as $e) {
        $pal = $e['pal'];
        $score = ['hurt' => 0, 'guard' => 0, 'heal' => 0, 'charm' => 0, 'trick' => 0];
        foreach (ppal_pal_skills($pal) as $k => $v) if (isset($kindType[$k])) $score[$kindType[$k]] += (int)$v;
        if (($b = ppal_boon($pal)) && ($b['active'] ?? '') !== '') $score[$activeType[$b['active']] ?? 'trick'] += 3;
        arsort($score);
        $t = (string)array_key_first($score);
        $rar = ['common' => 0, 'uncommon' => 1, 'rare' => 2][$pal['rarity'] ?? 'common'] ?? 0;
        $swap = $swapFor[$t];
        if (isset($used[$swap])) foreach (['hide', 'rest', 'dodge'] as $alt) if (!isset($used[$alt])) { $swap = $alt; break; }   // two pals of one kind replace two different tiles
        if (isset($used[$swap])) continue;   // nothing left to swap: this pal stays home
        $used[$swap] = true;
        $out[] = ['swap' => $swap, 'n' => (string)($pal['name'] ?? 'Pal'), 't' => $t, 'v' => 4 + min(4, (int)round($score[$t] / 2)) + 2 * $rar, 'r' => $knob[$t]];
    }
    return $out;
}

/** The fight state inside the encounter ($enc['pf']); created on first sight. Returns the state (also stored in $enc). */
function pfight_state(array $u, array $exp, array &$enc, array $c): array
{
    if (empty($enc['pf'])) {   // a new fight starts in the mode the setting says; a fight already under way keeps its own
        $new = setting('pfight_mode') === 'board' ? 'pfb_new' : 'pf_new';
        $enc['pf'] = $new(pfight_me($u, $exp, $enc), $c, random_int(1, 0x7FFFFFFE), ['can_pluck' => (int)q_val('SELECT COUNT(*) FROM creature_drops WHERE creature_id = ? AND item_id IS NOT NULL', [$c['id']]) > 0]);
    }
    return $enc['pf'];
}

/** One POST: 'pf_play' (chain = "2,0,3", turn), 'pf_run', 'pf_redraw' (card = index). The caller holds the transaction and has locked the gnome. Returns true when the fight ended. */
function pfight_do(array $u, array &$exp, string $do): bool
{
    $enc = json_decode((string)$exp['encounter'], true);
    $c = encounter_creature($enc);
    if (!$c) return false;
    $s = pfight_state($u, $exp, $enc, $c);
    if (!hash_equals((string)$s['nonce'], (string)($_POST['nonce'] ?? ''))) { flash('That page is from another fight. Here is the current one.', 'err'); $exp['encounter'] = json_encode($enc); return false; }   // a stale page can never play into a different fight
    $s['me']['hp'] = min((int)$s['me']['max'], max(1, (int)$exp['hp']));   // the expedition's health is the truth (the flag may have been flipped mid-fight)
    $won = false;
    if ($do === 'pf_run') {
        if (!pf_run($s)) { flash('You cannot run from this one.', 'err'); return false; }
    } elseif ($do === 'pf_redraw') {
        if (!pf_redraw($s, (int)($_POST['card'] ?? -1), (int)($_POST['turn'] ?? -1))) { $exp['encounter'] = json_encode($enc); return false; }   // no redraws left, or a stale page: nothing happens
    } elseif (in_array($do, ['pf_play', 'pfb_play', 'pfb_pass'], true)) {
        $board = ($s['mode'] ?? '') === 'board';
        if ($board !== ($do !== 'pf_play')) { flash('That page is from another fight. Here is the current one.', 'err'); $exp['encounter'] = json_encode($enc); return false; }
        $idx = array_map('intval', array_filter(explode(',', (string)($_POST['chain'] ?? '')), 'strlen'));
        $left = snacks_left($u, $enc);
        $have = array_sum(array_column(fight_snacks($u), 'qty'));
        $want = 0;
        $guard = function (array $t) use (&$want, $left, $have, $s) {
            if ($t['tag'] !== 'snack') return null;
            if ((int)$s['me']['hp'] >= (int)$s['me']['max']) return 'You’re not hurt. Save the snack.';
            if (++$want > min($left, $have)) return 'You have no snack to eat' . ($left <= 0 ? ' (snack limit reached this fight).' : '.');
            return null;
        };
        if ($do === 'pfb_pass') $r = pfb_pass($s, (int)($_POST['turn'] ?? -1));
        elseif ($board) {   // moves arrive as "handIndex,x,y;handIndex,x,y"
            $moves = [];
            foreach (array_filter(explode(';', (string)($_POST['moves'] ?? '')), 'strlen') as $m) { $p = explode(',', $m); $moves[] = count($p) === 3 && ctype_digit($p[0]) && ctype_digit($p[1]) && ctype_digit($p[2]) ? [(int)$p[0], (int)$p[1], (int)$p[2]] : null; }
            $r = in_array(null, $moves, true) ? ['ev' => [], 'err' => 'Those moves are not valid.'] : pfb_play($s, $moves, (int)($_POST['turn'] ?? -1), $guard);
        } else $r = pf_play($s, $idx, (int)($_POST['turn'] ?? -1), $guard);
        if ($r['err'] === 'stale') { flash('That turn has already passed.', 'err'); $exp['encounter'] = json_encode($enc); return false; }   // double tap or an old page: nothing happens
        if ($r['err']) { flash($r['err'], 'err'); return false; }
        $ate = 0;   // a snack is eaten only for a Snack tile that really resolved (the fight can end mid-chain), cheapest first
        foreach ($r['ev'] as $e) if ($e['by'] === 'me' && $e['tag'] === 'snack' && ($e['root'] ?? true)) $ate++;
        $snacks = fight_snacks($u);
        usort($snacks, fn($a, $b) => $a['heal'] <=> $b['heal']);
        foreach (array_slice($snacks, 0, 1) as $sn) for ($i = 0; $i < $ate; $i++) if (give_item((int)$u['id'], (int)$sn['id'], -1)) $enc['snacks'] = (int)($enc['snacks'] ?? 0) + 1;
        $won = in_array($s['over'], ['seen_off', 'charmed'], true);
        pfight_unlock((int)$u['id'], $r['ev'], $won);
        $enc['last'] = [];
        foreach ($board ? pfight_chips_board($r['ev']) : array_filter([pfight_chip($r['ev'], 'me'), pfight_chip($r['ev'], 'foe')]) as $chip) $enc['hist'][] = $chip;
        $enc['hist'] = array_slice((array)($enc['hist'] ?? []), -14);
        foreach ($r['ev'] as $e) {
            $ln = pfight_line($e, (string)$c['name']);
            if (($e['pluck'] ?? '') === 'got') {   // Pluck worked: lift one item this creature could drop (weighted by its drop chances)
                $rows = q('SELECT cd.item_id, cd.chance, i.name FROM creature_drops cd JOIN items i ON i.id = cd.item_id WHERE cd.creature_id = ? AND cd.item_id IS NOT NULL', [$c['id']])->fetchAll();
                if ($rows) {
                    $tot = array_sum(array_map(fn($x) => max(1, (int)$x['chance']), $rows)); $roll = random_int(1, $tot); $pick = $rows[0];
                    foreach ($rows as $x) { $roll -= max(1, (int)$x['chance']); if ($roll <= 0) { $pick = $x; break; } }
                    give_item((int)$u['id'], (int)$pick['item_id'], 1);
                    $ln = '🤏 You lift ' . $pick['name'] . ' from the ' . $c['name'] . '!';
                    $enc['stolen'][] = ['name' => (string)$pick['name'], 'qty' => 1, 'img' => (string)(item_art_map()['id'][(int)$pick['item_id']] ?? '')];   // shown on the win screen too
                }
            }
            exp_log($exp, $ln); $enc['last'][] = $ln;
        }
    } else return false;
    $exp['hp'] = (int)$s['me']['hp'];
    $enc['pf'] = $s;
    $exp['encounter'] = json_encode($enc);
    switch ($s['over']) {
        case 'seen_off': case 'charmed':
            $charm = $s['over'] === 'charmed';
            win_fight($u, $exp, $c, $charm, $charm, (array)($enc['stolen'] ?? []));
            return true;
        case 'defeat':
            knock_out($u, $exp, $c);
            return true;
        case 'run': case 'stall':
            exp_log($exp, $s['over'] === 'run' ? '🏃 You slip away from the ' . $c['name'] . '.' : '🍂 The ' . $c['name'] . ' loses interest and wanders off.');
            $exp['encounter'] = null;
            if (($exp['kind'] ?? 'walk') === 'delve' && (int)$exp['depth'] >= ((int)($exp['steps_total'] ?? 0) ?: DELVE_ROOMS)) {
                $exp['status'] = 'done';
                exp_log($exp, '🪜 You climb back out. The chest stays guarded.');
            }
            return true;
    }
    return false;
}

function pfight_line(array $e, string $foe): string
{
    if (!empty($e['tick'])) return '🧪 The poison works on the ' . $foe . ' (+' . (int)$e['v'] . ').';
    $who = $e['by'] === 'me' ? 'You play' : 'The ' . $foe . ' plays';
    $bits = [];
    if (!empty($e['combo'])) $bits[] = '✨ ' . $e['combo'];
    if (!empty($e['fit'])) $bits[] = 'snug fit';
    if (($e['pluck'] ?? '') === 'missed') return '🤏 You try to pluck something from the ' . $foe . ', but it notices.';
    if (($e['pluck'] ?? '') === 'none') return '🤏 You reach for the ' . $foe . ', but it has nothing to lift (or you already took something).';
    $tail = match ($e['t']) { 'hurt' => ($e['by'] === 'me' ? ' for ' . (int)($e['dmg'] ?? $e['v']) : ' for ' . (int)($e['dmg'] ?? $e['v']) . ' damage'), 'guard' => ' (+' . (int)$e['v'] . ' guard)', 'heal', 'item' => ' (+' . (int)$e['v'] . ' health)', 'charm' => ' (' . (int)$e['v'] . ')', default => '' };
    return ($e['by'] === 'me' ? '🧩 ' : '💥 ') . $who . ' ' . $e['n'] . $tail . ($bits ? ' · ' . implode(', ', $bits) : '') . '.';
}

/** URL of a delivered pfight art file, or null (a missing file always falls back to the emoji and CSS look). Checked once per file per request. */
/** A file of the parts kit (assets/img/pfight/parts/), or null. */
function pfight_part(string $file): ?string
{
    static $c = [];
    if (!array_key_exists($file, $c)) $c[$file] = is_file(__DIR__ . '/../assets/img/pfight/parts/' . $file) ? url('assets/img/pfight/parts/' . $file) : null;
    return $c[$file];
}

/** The resolve bar: the art frame with Hurt filling from the left and Charm from the right (widths set by assets/pfx.js from data-w, no inline styles), or a plain progress bar. */
function pfight_bar_html(array $v): string
{
    $b = $v['bar']; $max = max(0.1, (float)$b['max']); $now = (float)$b['now']; $hu = (float)($b['hurt'] ?? 0); $ch = (float)($b['charm'] ?? 0);
    $label = 'Resolve ' . (int)$b['now'] . ' of ' . (int)$b['max'] . ($hu + $ch > 0 ? ' (hurt ' . (int)round($hu) . ', charm ' . (int)round($ch) . ')' : '');
    if (!pfight_part('resolve-frame.png')) return '<div class="pf-bar" role="img" aria-label="' . e($label) . '"><progress max="' . $max . '" value="' . $now . '"></progress></div>';
    $tot = max(0.001, $hu + $ch); $f = min(1.0, $now / $max);
    $hw = $hu + $ch > 0 ? $f * $hu / $tot : $f; $cw = $hu + $ch > 0 ? $f * $ch / $tot : 0.0;
    return '<div class="pf-bar pfx-bar" role="img" aria-label="' . e($label) . '"><span class="pfx-fill hurt" data-w="' . round($hw * 100, 1) . '"></span><span class="pfx-fill charm" data-w="' . round($cw * 100, 1) . '"></span><img class="pfx-frame" src="' . e((string)pfight_part('resolve-frame.png')) . '" alt=""></div>';
}

function pfight_art(string $file): ?string
{
    static $c = [];
    if (!array_key_exists($file, $c)) $c[$file] = is_file(__DIR__ . '/../assets/img/pfight/' . $file) ? url('assets/img/pfight/' . $file) : null;
    return $c[$file];
}

/** The three art layers of one piece (piece body with real notch and knob, type icon, owner edge) at 'hand' or 'strip' size, or null if any is missing. */
function pfight_piece_art(array $t, string $size, string $owner): ?array
{
    $hf = (string)(PF_HOLE[$t['t']] ?? 'flat'); $kf = (string)($t['r'] ?? '') !== '' ? (string)$t['r'] : 'flat';
    $suf = $size === 'strip' ? '-s' : '';
    $body = pfight_art("piece-$size-{$t['t']}-$hf-$kf.png"); $ico = pfight_art("ico-{$t['t']}$suf.png"); $edge = pfight_art("edge-$size-$owner-$hf-$kf.png");
    return $body && $ico && $edge ? ['body' => $body, 'ico' => $ico, 'edge' => $edge] : null;
}

/** One chip for the history bar from the events of one side's chain: who, the type icons, a short result. */
function pfight_chip(array $events, string $by): ?array
{
    $mine = array_values(array_filter($events, fn($e) => ($e['by'] ?? '') === $by && empty($e['tick'])));
    if (!$mine) return null;
    $bar = 0.0; $guard = 0; $heal = 0; $dmg = 0; $types = [];
    foreach ($mine as $e) {
        $types[] = (string)$e['t'];
        if ($by === 'me') { $bar += (float)($e['bar'] ?? 0); if ($e['t'] === 'guard') $guard += (int)$e['v']; if (in_array($e['t'], ['heal', 'item'], true)) $heal += (int)$e['v']; }
        else { $dmg += (int)($e['dmg'] ?? 0); if ($e['t'] === 'guard') $guard += (int)$e['v']; if ($e['t'] === 'heal') $heal += (int)$e['v']; }
    }
    $parts = [];
    if ($by === 'me') { if ($bar > 0) $parts[] = '+' . (int)round($bar) . ' bar'; if ($guard) $parts[] = '+' . $guard . ' guard'; if ($heal) $parts[] = '+' . $heal . ' hp'; }
    else { if ($dmg) $parts[] = '-' . $dmg . ' hp'; if ($guard) $parts[] = '+' . $guard . ' guard'; if ($heal) $parts[] = 'heals'; }
    return ['by' => $by, 'types' => $types, 'txt' => ($parts ? implode(' · ', $parts) : 'setup'), 'chain' => count($mine) > 1];
}

/** Board mode: one chip per piece placed (its whole chain), who placed it, the types that fired and what came of it. */
function pfight_chips_board(array $events): array
{
    $groups = []; $g = null;
    foreach ($events as $e) {
        if (!empty($e['tick'])) continue;
        if (!empty($e['root'])) { if ($g) $groups[] = $g; $g = [$e]; } elseif ($g) $g[] = $e;
    }
    if ($g) $groups[] = $g;
    $chips = [];
    foreach ($groups as $g) {
        $by = (string)$g[0]['by']; $bar = 0.0; $guard = 0; $heal = 0; $dmg = 0; $types = [];
        foreach ($g as $e) {
            $types[] = (string)$e['t'];
            if ($e['by'] === 'me') { $bar += (float)($e['bar'] ?? 0); if ($e['t'] === 'guard') $guard += (int)$e['v']; if (in_array($e['t'], ['heal', 'item'], true)) $heal += (int)$e['v']; }
            else { $dmg += (int)($e['dmg'] ?? 0); }
        }
        $parts = [];
        if ($bar > 0) $parts[] = '+' . (int)round($bar) . ' bar'; if ($guard) $parts[] = '+' . $guard . ' guard'; if ($heal) $parts[] = '+' . $heal . ' hp'; if ($dmg) $parts[] = '-' . $dmg . ' hp';
        $chips[] = ['by' => $by, 'types' => $types, 'txt' => $parts ? implode(' · ', $parts) : 'setup', 'chain' => count($g) > 1];
    }
    return $chips;
}

/** The fight card. No inline styles (CSP). assets/pfight.js reads data-* and builds the chain; the form posts once per chain. */
function pfight_html(array $u, array $exp, array &$enc, array $c): string
{
    $fresh = empty($enc['pf']);
    $s = pfight_state($u, $exp, $enc, $c);
    if ($fresh) {   // the hand you see must be the hand the server plays: write it only if the row is still exactly what this page read (compare-and-swap)
        $n = q("UPDATE expeditions SET encounter = ? WHERE id = ? AND status = 'active' AND encounter = ?", [json_encode($enc), $exp['id'], (string)$exp['encounter']])->rowCount();
        if ($n !== 1) {   // another request got there first: show what it stored (or nothing if the fight is already over)
            $row = q_one("SELECT encounter FROM expeditions WHERE id = ? AND status = 'active'", [$exp['id']]);
            $e2 = $row && $row['encounter'] ? json_decode((string)$row['encounter'], true) : null;
            if (!$e2 || empty($e2['pf'])) return '<p class="help">The fight has moved on. <a href="' . e(url('adventure.php')) . '">Reload</a>.</p>';
            $enc = $e2; $s = $e2['pf'];
        }
    }
    require_once __DIR__ . '/items.php';
    if (($s['mode'] ?? '') === 'board') return pfight_board_html($u, $enc, $c, $s);
    $v = pf_view($s);
    $nonce = e((string)$s['nonce']);
    $sm = fn(string $t) => ($i = pfight_art('ico-' . $t . '-s.png')) ? '<img class="pfh-ico" src="' . e($i) . '" alt="">' : '<span class="pfh-emo" aria-hidden="true">' . e(pfight_icon($t)) . '</span>';   // small type icon, or the emoji
    $h = '<div class="pfight pf-screen' . (pfight_part('resolve-frame.png') ? ' pfx-art' : '') . '" id="pfight" data-turn="' . (int)$v['turn'] . '" data-open="' . e((string)($v['open'] ?? '')) . '" data-opent="' . e((string)($v['open_t'] ?? '')) . '" data-openv="' . (int)$v['open_v'] . '" data-openby="' . e((string)($v['open_by'] ?? '')) . '" data-redraws="' . (int)$v['redraws'] . '">';

    // 5. history bar: one chip per chain that fired, newest at the right (YOU solid, FOE dashed)
    $h .= '<ol class="pf-hist" aria-label="What has been played" aria-live="polite">';
    foreach ((array)($enc['hist'] ?? []) as $chip) {
        $h .= '<li class="pf-chip ' . ($chip['by'] === 'me' ? 'you' : 'foe') . '"><b class="pfh-who">' . ($chip['by'] === 'me' ? 'YOU' : 'FOE') . '</b> ';
        foreach ((array)$chip['types'] as $t) $h .= $sm((string)$t);
        $h .= ' <span class="pfh-txt">' . ($chip['chain'] ? 'chain ' : '') . e((string)$chip['txt']) . '</span></li>';
    }
    if (empty($enc['hist'])) $h .= '<li class="pf-chip empty">Nothing played yet. You go first.</li>';
    $h .= '</ol>';

    // 2 / 3 / 4: the player, the creature, and the board between them
    $foeImg = '';
    $cim = creature_image((string)($c['slug'] ?? ''), true);
    $foeImg = $cim !== '' ? art_img($cim, 'lg', (string)$c['name']) : creature_icon((string)$c['name'], (string)$c['size']);
    $h .= '<div class="pf-stage">';
    $h .= '<div class="pf-side pf-me"><div class="pf-sprite">' . gnome_avatar_pals($u, 88) . '</div><b class="pf-nameplate">' . e(gnome_name($u)) . '</b>'
        . '<div class="pf-hp" role="img" aria-label="Your health ' . (int)$v['hp'] . ' of ' . (int)$v['max'] . '">❤️ <progress max="' . (int)$v['max'] . '" value="' . (int)$v['hp'] . '"></progress> ' . (int)$v['hp'] . '/' . (int)$v['max'] . ($v['block'] ? ' · 🛡️ ' . (int)$v['block'] : '') . '</div></div>';
    $h .= '<div class="pf-side pf-foe"><div class="pf-sprite">' . $foeImg . '<span class="pf-intent-bubble" title="Likely next move" aria-label="Likely next move: ' . e((string)$v['foe']['intent']) . '">' . $sm((string)$v['foe']['intent']) . '</span></div><b class="pf-nameplate">' . e((string)$c['name']) . '</b>'
        . '<small class="muted">' . e((string)$c['size']) . ' · lv ' . (int)$c['level'] . ' · ' . ($s['temper'] === 'gentle' ? 'gentle' : 'wary') . ' · 🃏 ' . (int)$v['foe']['hand'] . ($v['foe']['calm'] ? ' · 😌 ' . (int)$v['foe']['calm'] : '') . '</small></div>';
    $h .= '<div class="pf-center">';
    $h .= pfight_bar_html($v);
    $h .= '<div class="pf-strip pf-board" aria-label="The last pieces played">';
    foreach ($v['strip'] as $t) $h .= pfight_tile_html($t, true);
    $h .= '</div>';
    if (!empty($enc['last'])) { $h .= '<ol class="pf-last" aria-live="polite" aria-label="What just happened">'; foreach ($enc['last'] as $ln) $h .= '<li>' . e($ln) . '</li>'; $h .= '</ol>'; }
    $h .= '<p class="pf-preview help" id="pf-preview" aria-live="polite">Tap pieces in the order you want them (1 to 4).</p>';
    $h .= '</div></div>';   // pf-center, pf-stage

    // buttons (they belong to the play form through the form attribute, so they can sit where the layout wants them)
    $h .= '<form method="post" class="pf-form" id="pf-form">' . csrf_field() . '<input type="hidden" name="do" value="pf_play"><input type="hidden" name="nonce" value="' . $nonce . '"><input type="hidden" name="turn" value="' . (int)$v['turn'] . '"><input type="hidden" name="chain" id="pf-chain" value=""></form>';
    $h .= '<div class="pf-buttons"><button type="button" class="btn" id="pf-undo" disabled>Undo</button><button class="btn primary" id="pf-go" form="pf-form" disabled>End turn</button></div>';

    // 6 hand (swipe), 7 discard, 8 puzzle book (deck)
    $pile = fn(string $cls, string $name, string $icon, int $n) => '<div class="pf-pile ' . $cls . '" role="img" aria-label="' . $name . ': ' . $n . ' pieces">' . (($i = pfight_part($cls === 'deck' ? 'deck-book.png' : 'discard-bin.png') ?: pfight_art($icon)) ? '<img src="' . e($i) . '" alt="">' : '<span class="pf-pile-emo" aria-hidden="true">' . ($cls === 'deck' ? '📖' : '🗑️') . '</span>') . '<b>' . $n . '</b><small>' . $name . '</small></div>';
    $h .= '<div class="pf-tray">' . $pile('deck', 'Puzzle book', 'ico-deck.png', (int)$v['piles']['draw']) . '<div class="pf-hand" id="pf-hand" role="group" aria-label="Your hand (swipe sideways)">';
    foreach ($v['hand'] as $i => $t) $h .= pfight_tile_html($t, false, $i);
    $h .= '</div>' . $pile('disc', 'Discard', 'ico-discard.png', (int)$v['piles']['discard']) . '</div>';
    // tap a piece: the inspect card shows it at hand size with its name and what it does
    $h .= '<div class="pf-inspect" id="pf-inspect" aria-live="polite" hidden><span class="pf-ipiece"><img class="pfa-body" id="pfi-body" alt=""><img class="pfa-ico" id="pfi-ico" alt=""><img class="pfa-edge" id="pfi-edge" alt=""></span><span class="pf-itext"><b id="pfi-name"></b><br><span id="pfi-desc"></span></span></div>';
    $seen = array_values(array_unique(array_filter(array_column($v['hand'], 'tag'), fn($x) => isset(PF_TAGS[$x]))));
    if ($seen) { $h .= '<ul class="pf-tags help">'; foreach ($seen as $x) $h .= '<li>' . PF_TAGS[$x][0] . ' ' . e(PF_TAGS[$x][1]) . '</li>'; $h .= '</ul>'; }
    $h .= '<div class="pf-extra"><a class="pf-box" href="' . e(url('puzzlebox.php')) . '">🧩 Puzzle box</a> ';
    if ($v['can_run']) $h .= '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="pf_run"><input type="hidden" name="nonce" value="' . $nonce . '"><button class="btn">🏃 Run</button></form> ';
    $h .= '<form method="post" class="inline" id="pf-rform" hidden>' . csrf_field() . '<input type="hidden" name="do" value="pf_redraw"><input type="hidden" name="nonce" value="' . $nonce . '"><input type="hidden" name="turn" value="' . (int)$v['turn'] . '"><input type="hidden" name="card" id="pf-card" value=""></form>';
    if ($v['redraws'] > 0) $h .= '<small class="muted">🍀 ' . (int)$v['redraws'] . ' redraw' . ($v['redraws'] > 1 ? 's' : '') . '</small> <button type="button" class="btn" id="pf-redraw" hidden>Redraw a piece</button>';
    $h .= '</div>';
    $h .= '<script type="application/json" id="pf-data">' . json_encode(['combos' => $v['combos'], 'hole' => PF_HOLE], JSON_HEX_TAG | JSON_HEX_AMP) . '</script>';
    return $h . '</div><link rel="stylesheet" href="' . e(url('assets/pfight.css?v=' . APP_VERSION)) . '"><script src="' . e(url('assets/pfight.js?v=' . APP_VERSION)) . '" defer></script>';
}

/**
 * The board screen (mode 'board'). The server draws the board and the hand; assets/pfboard.js lets the player plan up to 4 placements (click a piece, click a cell,
 * or drag), shows where a piece fits, and posts them all once on End turn. Pieces are drawn with CSS until the four-sided piece art lands (parts atlas).
 */
function pfight_board_html(array $u, array &$enc, array $c, array $s): string
{
    $v = pfb_view($s);
    $nonce = e((string)$s['nonce']);
    $sm = fn(string $t) => ($i = pfight_art('ico-' . $t . '-s.png')) ? '<img class="pfh-ico" src="' . e($i) . '" alt="">' : '<span class="pfh-emo" aria-hidden="true">' . e(pfight_icon($t)) . '</span>';
    $h = '<div class="pfight pf-screen pf-boardmode' . (pfight_part('resolve-frame.png') ? ' pfx-art' : '') . '" id="pfight" data-turn="' . (int)$v['turn'] . '" data-mode="board" data-redraws="' . (int)$v['redraws'] . '">';
    $h .= '@@TOP@@<ol class="pf-hist" aria-label="What has been played" aria-live="polite">';
    foreach ((array)($enc['hist'] ?? []) as $chip) {
        $h .= '<li class="pf-chip ' . ($chip['by'] === 'me' ? 'you' : 'foe') . '"><b class="pfh-who">' . ($chip['by'] === 'me' ? 'YOU' : 'FOE') . '</b> ';
        foreach ((array)$chip['types'] as $t) $h .= $sm((string)$t);
        $h .= ' <span class="pfh-txt">' . ($chip['chain'] ? 'chain ' : '') . e((string)$chip['txt']) . '</span></li>';
    }
    if (empty($enc['hist'])) $h .= '<li class="pf-chip empty">Pieces are on the board. Place one next to them.</li>';
    $h .= '</ol>';
    $cim = creature_image((string)($c['slug'] ?? ''), true);
    $foeImg = $cim !== '' ? art_img($cim, 'lg', (string)$c['name']) : creature_icon((string)$c['name'], (string)$c['size']);
    $top = '<div class="pfc-top"><div class="pfc-me"><span class="pfc-av">' . gnome_avatar_pals($u, 60) . '</span><span class="pf-hp" role="img" aria-label="Your health ' . (int)$v['hp'] . ' of ' . (int)$v['max'] . ($v['block'] ? ', guard ' . (int)$v['block'] : '') . '">❤️ <progress max="' . (int)$v['max'] . '" value="' . (int)$v['hp'] . '"></progress> ' . (int)$v['hp'] . ($v['block'] ? ' · 🛡️ ' . (int)$v['block'] : '') . '</span></div>'
        . pfight_bar_html($v)
        . '<div class="pfc-foe"><span class="pfc-fname"><b>' . e((string)$c['name']) . '</b><small>lv ' . (int)$c['level'] . ' · ' . ($s['temper'] === 'gentle' ? 'gentle' : 'wary') . ' · 🃏 ' . (int)$v['foe']['hand'] . ($v['foe']['calm'] ? ' · 😌 ' . (int)$v['foe']['calm'] : '') . '</small></span><span class="pfc-av">' . $foeImg . '<span class="pf-intent-bubble" title="Likely next move" aria-label="Likely next move: ' . e((string)$v['foe']['intent']) . '">' . $sm((string)$v['foe']['intent']) . '</span></span></div></div>';
    $h = str_replace('@@TOP@@', $top, $h);
    $h .= '<div class="pfb-board" id="pfb-board" role="group" aria-label="The play area: pick a piece from your hand, then a lit spot. Scroll, pinch or use the zoom buttons to zoom"></div>';   // JS draws the pieces from #pf-data
    $h .= '<p class="pf-preview help" id="pf-preview" aria-live="polite">Pick a piece, then a lit spot. Up to 4 a turn; the newest plays first.</p>';
    $h .= '<form method="post" class="pf-form" id="pf-form">' . csrf_field() . '<input type="hidden" name="do" value="pfb_play"><input type="hidden" name="nonce" value="' . $nonce . '"><input type="hidden" name="turn" value="' . (int)$v['turn'] . '"><input type="hidden" name="moves" id="pf-moves" value=""></form>';
    $h .= '<div class="pf-buttons"><a class="btn pf-box" href="' . e(url('puzzlebox.php')) . '" title="Your puzzle box" aria-label="Puzzle box">🧩</a><button type="button" class="btn" id="pf-undo" disabled>Undo</button><button class="btn primary" id="pf-go" form="pf-form" disabled>End turn</button>'
        . ($v['can_run'] ? '<form method="post" class="inline pf-runf">' . csrf_field() . '<input type="hidden" name="do" value="pf_run"><input type="hidden" name="nonce" value="' . $nonce . '"><button class="btn" title="Run away" aria-label="Run away">🏃</button></form>' : '') . '</div>';
    $pile = fn(string $cls, string $name, int $n) => '<div class="pf-pile ' . $cls . '" role="img" aria-label="' . $name . ': ' . $n . ' pieces">' . (($pi = pfight_part($cls === 'deck' ? 'deck-book.png' : 'discard-bin.png')) ? '<img src="' . e($pi) . '" alt="">' : '<span class="pf-pile-emo" aria-hidden="true">' . ($cls === 'deck' ? '📖' : '🗑️') . '</span>') . '<b>' . $n . '</b><small>' . $name . '</small></div>';
    $h .= '<div class="pf-tray">' . $pile('deck', 'Puzzle book', (int)$v['piles']['draw']) . '<div class="pf-hand" id="pf-hand" role="group" aria-label="Your hand (swipe sideways)">';
    foreach ($v['hand'] as $i => $t) $h .= pfight_board_piece_html($t, $i);
    $h .= '</div>' . $pile('disc', 'Discard', (int)$v['piles']['discard']) . '</div>';
    $h .= '<div class="pf-inspect" id="pf-inspect" aria-live="polite" hidden><span class="pf-itext"><b id="pfi-name"></b><br><span id="pfi-desc"></span></span></div>';
    $seen = array_values(array_unique(array_filter(array_column($v['hand'], 'tag'), fn($x) => isset(PF_TAGS[$x]))));
    if ($seen) { $h .= '<ul class="pf-tags help">'; foreach ($seen as $x) $h .= '<li>' . PF_TAGS[$x][0] . ' ' . e(PF_TAGS[$x][1]) . '</li>'; $h .= '</ul>'; }
    $h .= '<div class="pf-extra">';
    $h .= '<form method="post" class="inline" id="pf-pform" hidden>' . csrf_field() . '<input type="hidden" name="do" value="pfb_pass"><input type="hidden" name="nonce" value="' . $nonce . '"><input type="hidden" name="turn" value="' . (int)$v['turn'] . '"><button class="btn" id="pf-pass">Pass (nothing fits)</button></form>';
    $h .= '<form method="post" class="inline" id="pf-rform" hidden>' . csrf_field() . '<input type="hidden" name="do" value="pf_redraw"><input type="hidden" name="nonce" value="' . $nonce . '"><input type="hidden" name="turn" value="' . (int)$v['turn'] . '"><input type="hidden" name="card" id="pf-card" value=""></form>';
    if ($v['redraws'] > 0) $h .= '<small class="muted">🍀 ' . (int)$v['redraws'] . ' redraw' . ($v['redraws'] > 1 ? 's' : '') . '</small> <button type="button" class="btn" id="pf-redraw" hidden>Redraw a piece</button>';
    $h .= '</div>';
    if (!empty($enc['last'])) { $h .= '<details class="pfc-log"><summary>What just happened</summary><ol class="pf-last" aria-live="polite">'; foreach ($enc['last'] as $ln) $h .= '<li>' . e($ln) . '</li>'; $h .= '</ol></details>'; }
    // the board and the hand's edges for the script (public information: the board is out in the open)
    $data = ['fx' => $v['fx'] ?? [], 'tint' => (int)(crc32((string)($c['slug'] ?? $c['name'] ?? '')) % 360), 'parts' => is_file(__DIR__ . '/../assets/img/pfight/parts/atlas.json') ? url('assets/img/pfight/parts/') : null, 'w' => $v['w'], 'h' => $v['h'], 'pcs' => $v['pcs'], 'hand' => array_map(fn($t) => ['e' => $t['e'], 't' => $t['t'], 'tag' => $t['tag'], 'm' => $t['m']], $v['hand']), 'combos' => $v['combos'], 'icons' => ['hurt' => '⚔️', 'guard' => '🛡️', 'heal' => '💚', 'charm' => '🌸', 'soothe' => '😌', 'trick' => '🎭', 'item' => '🎒']];
    $h .= '<script type="application/json" id="pf-data">' . json_encode($data, JSON_HEX_TAG | JSON_HEX_AMP) . '</script>';
    return $h . '</div><link rel="stylesheet" href="' . e(url('assets/pfight.css?v=' . APP_VERSION)) . '"><script src="' . e(url('assets/pfx.js?v=' . APP_VERSION)) . '" defer></script><script src="' . e(url('assets/pfparts.js?v=' . APP_VERSION)) . '" defer></script><script src="' . e(url('assets/pfboard.js?v=' . APP_VERSION)) . '" defer></script>';
}

/** A hand piece in board mode: a button with its four edges drawn as marks. */
function pfight_board_piece_html(array $t, int $i): string
{
    $tg = PF_TAGS[(string)($t['tag'] ?? '')] ?? null; $md = PF_MODS[(string)($t['m'] ?? '')] ?? null;
    $ed = ''; foreach (['L', 'R', 'T', 'B'] as $side) $ed .= pfight_edge_span($t['e'][$side], $side);
    $label = $t['n'] . ', ' . ucfirst($t['t']) . ' ' . $t['v'] . '; edges: ' . implode(', ', array_map(fn($sd) => $sd . ' ' . ($t['e'][$sd][0] === 'flat' ? 'flat' : $t['e'][$sd][0] . ' ' . $t['e'][$sd][1]), ['L', 'R', 'T', 'B'])) . ($tg ? '; ' . $tg[1] : '') . ($md ? '; upgrade ' . $md[0] . ': ' . $md[2] : '');
    $desc = ucfirst($t['t']) . ' ' . (int)$t['v'] . ($tg ? '. ' . $tg[1] : '') . ($md ? '. Upgrade ' . $md[0] . ': ' . $md[2] : '');
    return '<button type="button" class="pf-tile pf-h pf-bp pf-' . e($t['t']) . '" data-i="' . $i . '" data-t="' . e($t['t']) . '" data-tag="' . e((string)$t['tag']) . '" data-mod="' . e((string)$t['m']) . '" data-v="' . (int)$t['v'] . '" data-name="' . e($t['n']) . '" data-desc="' . e($desc) . '" aria-label="' . e($label) . '" aria-pressed="false" draggable="true">'
        . $ed . '<span class="pf-ico" aria-hidden="true">' . pfight_icon($t['t']) . '</span><span class="pf-nm">' . e($t['n']) . ($tg ? ' <span class="pf-tg" aria-hidden="true">' . $tg[0] . '</span>' : '') . ($md ? ' <span class="pf-tg" aria-hidden="true">' . $md[1] . '</span>' : '') . '</span><span class="pf-val">' . (int)$t['v'] . '</span></button>';
}

/** One edge mark: knob = solid shape, hole = hollow shape; body round, mind keyhole, craft triangle, flat = a bar; the family letter stays as text. */
function pfight_edge_span(array $edge, string $side): string
{
    $fam = ['body' => 'B', 'mind' => 'M', 'craft' => 'C'];
    return '<span class="pfe s' . $side . ' ' . ($edge[0] === 'flat' ? 'flat f-flat' : $edge[0] . ' f-' . $edge[1]) . '" aria-hidden="true">' . ($fam[(string)$edge[1]] ?? '·') . '</span>';
}

function pfight_icon(string $t): string
{
    return ['hurt' => '⚔️', 'guard' => '🛡️', 'heal' => '💚', 'charm' => '🌸', 'soothe' => '😌', 'trick' => '🎭', 'item' => '🎒'][$t] ?? '❔';
}

function pfight_tile_html(array $t, bool $strip, int $i = -1): string
{
    $fam = ['body' => 'B', 'mind' => 'M', 'craft' => 'C'];
    $hole = (string)($t['hole'] ?? PF_HOLE[$t['t']] ?? '');
    $knob = (string)($t['r'] ?? '');
    $tag = (string)($t['tag'] ?? ''); $tg = PF_TAGS[$tag] ?? null;
    $md = PF_MODS[(string)($t['m'] ?? '')] ?? null;
    $label = $t['n'] . ', ' . ucfirst($t['t']) . ' ' . $t['v'] . ', starts ' . $hole . ', ends ' . ($knob !== '' ? $knob : 'flat') . ($tg ? ', ' . $tg[1] : '') . ($md ? ', upgrade ' . $md[0] . ': ' . $md[2] : '');
    $owner = !empty($t['by']) ? (string)$t['by'] : 'me';
    $art = pfight_piece_art($t, 'strip', $owner);   // the real jigsaw piece art (hand cards use the strip size at 2x; the big hand-size art is for the inspect card)
    $cls = 'pf-tile ' . ($strip ? 'pf-s ' : 'pf-h ') . 'pf-' . $t['t'] . (!empty($t['by']) ? ' by-' . $t['by'] : '') . ($art ? ' pf-art' : '');
    if ($art) {
        $inner = '<img class="pfa-body" src="' . e($art['body']) . '" alt=""><img class="pfa-ico" src="' . e($art['ico']) . '" alt=""><img class="pfa-edge" src="' . e($art['edge']) . '" alt=""><span class="pfa-n" aria-hidden="true">' . (int)$t['v'] . '</span>'
            . ($tg || $md ? '<span class="pfa-tg" aria-hidden="true">' . ($tg ? $tg[0] : '') . ($md ? $md[1] : '') . '</span>' : '');
    } else {
        // sockets: shape by family (round / keyhole / triangle), a hole is drawn hollow and a knob solid, and the family letter stays as text: never colour alone
        $l = '<span class="pf-sock l hole f-' . ($hole ?: 'flat') . '" aria-hidden="true">' . ($fam[$hole] ?? '·') . '</span>';
        $r = '<span class="pf-sock r knob f-' . ($knob ?: 'flat') . '" aria-hidden="true">' . ($fam[$knob] ?? '·') . '</span>';
        $inner = $l . '<span class="pf-ico" aria-hidden="true">' . pfight_icon($t['t']) . '</span>' . ($strip ? '' : '<span class="pf-nm">' . e($t['n']) . ($tg ? ' <span class="pf-tg" aria-hidden="true">' . $tg[0] . '</span>' : '') . ($md ? ' <span class="pf-tg" aria-hidden="true">' . $md[1] . '</span>' : '') . '</span>') . '<span class="pf-val">' . (int)$t['v'] . '</span>' . $r;
    }
    if ($strip) return '<span class="' . $cls . '" role="img" aria-label="' . e($label) . '">' . $inner . '</span>';
    $hand = pfight_piece_art($t, 'hand', 'me');   // for the inspect card (JS fills three images from these)
    $desc = ucfirst($t['t']) . ' ' . (int)$t['v'] . ($tg ? '. ' . $tg[1] : '') . ($md ? '. Upgrade ' . $md[0] . ': ' . $md[2] : '');
    return '<button type="button" class="' . $cls . '" data-i="' . $i . '" data-hole="' . e($hole) . '" data-knob="' . e($knob) . '" data-t="' . e($t['t']) . '" data-tag="' . e($tag) . '" data-mod="' . e((string)($t['m'] ?? '')) . '" data-v="' . (int)$t['v'] . '" data-name="' . e($t['n']) . '" data-desc="' . e($desc) . '"'
        . ($hand ? ' data-hbody="' . e($hand['body']) . '" data-hico="' . e($hand['ico']) . '" data-hedge="' . e($hand['edge']) . '"' : '')
        . ' aria-label="' . e($label) . '" aria-pressed="false">' . $inner . '</button>';
}

/** Almanac pages for puzzle fights, added once per world by title (like ensure_almanac_new_pages_2644): one overview and one per combo, each unlocking on first use. */
const PF_PAGES = [
    'Puzzle fights' => ['pfight', 'Win a fight to learn how tiles work.',
        "Fights are played with [b]tiles[/b]. You start with 5 in hand and draw 3 each turn (never above 5). Tap up to 4 tiles in the order you want them, then play the chain. The creature answers with a chain of its own, and a full chain of four gives it one more move.\n\n[b]Types:[/b] ⚔️ Hurt, 🛡️ Guard, 💚 Heal, 🌸 Charm, 😌 Soothe, 🎭 Trick, 🎒 Item. Numbers grow with your stats and level.\n\n[b]Sockets:[/b] each tile has a hole on the left and a knob on the right in one of three families (B Body, M Mind, C Craft). A knob that matches the next tile's hole is a [b]snug fit[/b]: a little extra value. A poor fit still works; it only skips the bonus.\n\n[b]The bar:[/b] every creature has one resolve bar. Hurt and Charm both fill it, gentle creatures like Charm best and wary ones like Hurt. Whichever you used more decides whether you see it off or win it over. A charmed creature leaves a gift.\n\n[b]Run[/b] always works except against the great ones, and costs nothing.\n\n[b]The Puzzle box:[/b] you do not bring every tile you own. Your box holds a limited number (8 at the start, one more every 3 levels, 14 at most), so choose. Open it from the fight card or the My Gnome page. A change applies from your next fight."],
    'Hurt tiles' => ['pfight:tiles', 'Play a Hurt tile with a tactic.',
        "Hurt tiles differ by [b]how[/b] they hit, not only how hard.\n\n⚡ [b]Jab[/b] (Quick): draws you a tile when played.\n📌 [b]Pierce[/b]: ignores the creature's guard.\n🧪 [b]Sting[/b] (Poison): keeps working for 2 more turns.\n🪢 [b]Trip[/b]: the creature plays one tile fewer next turn.\n🛡️ [b]Shield Bash[/b]: adds the guard you built earlier in the chain to the hit.\n🪨 [b]Smash[/b] (Heavy): a big blow that has to go last in a chain.\n\nThey unlock as your gnome grows: Jab at level 5, Pierce 8, Trip 11, Sting 13, Bash 14, Smash 16. Gentle creatures take Hurt at half strength; Charm suits them better."],
    'Defence and Charm tiles' => ['pfight:tiles2', 'Play a guard or charm tile with a tactic.',
        "Guards and Charms differ by how they work too.\n\n[b]Guards:[/b] ⚓ [b]Brace[/b] lasts through your next turn. 💨 [b]Roll[/b] makes the creature's first Hurt next turn miss completely. 🌵 [b]Thorn Hide[/b] pricks the creature when it hits your guard. 🩹 [b]Mending[/b] heals you 2.\n\n[b]Charms:[/b] 🎵 [b]Hum[/b] also calms the creature. 🌙 [b]Lull[/b] makes it play a tile fewer. 🤝 [b]Bond[/b] warms it to Charm for the rest of the fight (up to three times).\n\n[b]Stealing:[/b] 🤏 [b]Pluck[/b] is a Trick with a small chance to lift an item the creature could drop. Luck raises the chance, a legendary creature is harder to rob, and you can lift one thing a fight."],
    'Puzzle upgrades' => ['pfight:mods', 'Finish a puzzle to earn an upgrade.',
        "Finishing a puzzle in [b]any game and any mode[/b] can earn a [b]Puzzle upgrade[/b]: a secondary effect for one of your tiles. Open your Puzzle box and choose one of three. A bigger puzzle gives rarer upgrades.\n\nYou can earn [b]3 a day[/b] (a new day starts at midnight, server time), and up to 3 can wait unopened. Each tile holds one upgrade; it stays until you remove it, or choose another for the same tile.\n\n🧲 Sticky, 🪶 Swift, 🧱 Hardy, 💗 Tender are common. 🩸 Leech, 🦔 Spiky, 🪽 Soft touch are uncommon. 🔥 Warm, 🎯 Finisher, 🍀 Lucky, ⚖️ Steady are rare."],
    'Ambush' => ['pfight:combo:trick>hurt', 'Play a Trick, then a Hurt.', "🎭 then ⚔️. The Hurt counts one and a half times, plus the Trick's own value. Set it up, then strike."],
    'Riposte' => ['pfight:combo:guard>hurt', 'Play a Guard, then a Hurt, or Guard right after a creature hits.', "🛡️ then ⚔️: the Hurt counts one and a half times. A Guard played straight after the creature's Hurt also turns half its value back on it."],
    'Double Swing' => ['pfight:combo:hurt>hurt', 'Play two Hurts in a row.', "⚔️ then ⚔️: the second gets +2."],
    'Calm Charm' => ['pfight:combo:soothe>charm', 'Play a Soothe, then a Charm.', "😌 then 🌸: the Charm counts one and a half times."],
    'Win Over' => ['pfight:combo:charm>item', 'Play a Charm, then an Item or Snack.', "🌸 then 🎒: the offering also fills part of the bar as Charm."],
    'Bait' => ['pfight:combo:trick>guard', 'Play a Trick, then a Guard.', "🎭 then 🛡️: the Guard gets the Trick's value added."],
];

function pfight_pages(): void
{
    if (setting('almanac_pfight') === '1') return;
    $so = 80;
    foreach (PF_PAGES as $title => [$key, $hint, $body]) {
        if (q_val("SELECT 1 FROM encyclopedia_entries WHERE chapter = 'General' AND title = ?", [$title])) continue;
        try { db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Fighting', 'title' => $title, 'body' => $body, 'unlock_key' => $key, 'hint' => $hint, 'sort_order' => $so++]); } catch (PDOException $e) { return; }   // try again next time
    }
    set_setting('almanac_pfight', '1');
}

/** Unlock the overview, and a combo page the first time that combo fires. $events = the events of one chain. */
function pfight_unlock(int $uid, array $events, bool $won = false): void
{
    pfight_pages();
    if ($won) unlock_entries($uid, 'pfight');
    $byName = ['Ambush' => 'trick>hurt', 'Riposte' => 'guard>hurt', 'Double Swing' => 'hurt>hurt', 'Calm Charm' => 'soothe>charm', 'Win Over' => 'charm>item', 'Bait' => 'trick>guard'];
    foreach ($events as $e) if (($e['by'] ?? '') === 'me' && isset(PF_TAGS[(string)($e['tag'] ?? '')])) { unlock_entries($uid, in_array($e['t'], ['guard', 'charm', 'trick'], true) ? 'pfight:tiles2' : 'pfight:tiles'); }
    foreach ($events as $e) if (($e['by'] ?? '') === 'me' && !empty($e['combo']) && isset($byName[$e['combo']])) unlock_entries($uid, 'pfight:combo:' . $byName[$e['combo']]);
}


// ---------------------------------------------------------------- upgrades (secondary effects) earned by finishing puzzles

const PF_OFFER_DAILY = 3;   // offers a gnome can earn per real day (resets at midnight, server time)
const PF_OFFER_BANK = 3;    // offers that can wait unopened

/** The three tables behind upgrades: made on first use (no upgrade step needed). */
function pmod_ensure(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    try { q('SELECT 1 FROM user_pmod LIMIT 1'); q('SELECT 1 FROM user_poffer LIMIT 1'); q('SELECT 1 FROM user_pgrant LIMIT 1'); return $ok = true; } catch (Throwable $e) {}
    try {
        $sqlite = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite';
        $pk = $sqlite ? 'INTEGER PRIMARY KEY AUTOINCREMENT' : 'INT AUTO_INCREMENT PRIMARY KEY';
        db()->exec('CREATE TABLE IF NOT EXISTS user_pmod (user_id INTEGER NOT NULL, tile_key VARCHAR(40) NOT NULL, mod_key VARCHAR(24) NOT NULL, PRIMARY KEY (user_id, tile_key))');
        db()->exec("CREATE TABLE IF NOT EXISTS user_poffer (id $pk, user_id INTEGER NOT NULL, ref VARCHAR(48) NOT NULL, rarity INTEGER NOT NULL DEFAULT 0, choices TEXT NOT NULL, created_at VARCHAR(24) NOT NULL, UNIQUE (user_id, ref))");
        db()->exec('CREATE TABLE IF NOT EXISTS user_pgrant (user_id INTEGER NOT NULL, day VARCHAR(10) NOT NULL, n INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (user_id, day))');
        return $ok = true;
    } catch (Throwable $e) { error_log('pmod_ensure: ' . $e->getMessage()); return $ok = false; }
}

/** tile key => upgrade key, for one gnome. */
function pfight_mods(int $uid): array
{
    if (!pmod_ensure()) return [];
    $o = [];
    foreach (q('SELECT tile_key, mod_key FROM user_pmod WHERE user_id = ?', [$uid])->fetchAll() as $r) if (isset(PF_MODS[$r['mod_key']])) $o[$r['tile_key']] = $r['mod_key'];
    return $o;
}

function pfight_mod_fits(string $mod, string $tileType): bool
{
    return isset(PF_MODS[$mod]) && in_array($tileType, PF_MODS[$mod][4], true);
}

/** Today's offers earned so far: [n, cap]. The day is the real (server) day, not the game clock. */
function pfight_offer_today(int $uid): array
{
    if (!pmod_ensure()) return [0, PF_OFFER_DAILY];
    return [(int)q_val('SELECT n FROM user_pgrant WHERE user_id = ? AND day = ?', [$uid, date('Y-m-d')]), PF_OFFER_DAILY];
}

function pfight_offers(int $uid): array
{
    if (!pmod_ensure()) return [];
    $o = [];
    foreach (q('SELECT * FROM user_poffer WHERE user_id = ? ORDER BY id', [$uid])->fetchAll() as $r) { $r['choices'] = json_decode((string)$r['choices'], true) ?: []; $o[] = $r; }
    return $o;
}

/** Three (tile, upgrade) choices for a gnome. Rarity 0-2 (bigger puzzle = rarer): the mix of upgrade rarities leans up with it. */
function pfight_offer_choices(array $u, int $rarity): array
{
    $own = pf_collection((int)$u['level'], (string)($u['calling'] ?? ''));
    $weights = [[80, 20, 0], [40, 45, 15], [15, 45, 40]][max(0, min(2, $rarity))];
    $have = pfight_mods((int)$u['id']);
    $out = []; $seen = [];
    for ($try = 0; $try < 60 && count($out) < 3; $try++) {
        $roll = random_int(1, 100); $r = $roll <= $weights[0] ? 0 : ($roll <= $weights[0] + $weights[1] ? 1 : 2);
        $mods = array_keys(array_filter(PF_MODS, fn($m) => $m[3] === $r));
        $mod = $mods[random_int(0, count($mods) - 1)];
        $tiles = array_values(array_filter($own, fn($k) => pfight_mod_fits($mod, pf_tiles()[$k]['t']) && ($have[$k] ?? '') !== $mod && ($mod !== 'steady' || (pf_tiles()[$k]['tag'] ?? '') === 'heavy')));
        if (!$tiles) continue;
        $tile = $tiles[random_int(0, count($tiles) - 1)];
        if (isset($seen[$tile . '|' . $mod])) continue;
        $seen[$tile . '|' . $mod] = true;
        $out[] = [$tile, $mod];
    }
    return $out;
}

/**
 * A puzzle was finished (any game, any mode). Maybe bank an upgrade offer; returns a sentence for the player (or '').
 * $ref is unique per finished run, so a hand-in can never pay twice. $rarity: 0 small, 1 medium, 2 big puzzle.
 * Up to PF_OFFER_DAILY a real day, and PF_OFFER_BANK waiting at once; either way the player is told.
 */
/** Offer rarity for a puzzle of $pieces pieces: 0 small, 1 medium, 2 big. The two thresholds are admin settings. */
function pfight_rarity_for_pieces(int $pieces): int
{
    $mid = max(1, (int)setting('pfight_rarity_mid')); $big = max($mid + 1, (int)setting('pfight_rarity_big'));
    return $pieces >= $big ? 2 : ($pieces >= $mid ? 1 : 0);
}

function pfight_puzzle_reward(array $u, string $ref, int $rarity): string
{
    if (!pfight_on($u) || is_guest($u) || !pmod_ensure()) return '';
    $uid = (int)$u['id'];
    if (q_val('SELECT 1 FROM user_poffer WHERE user_id = ? AND ref = ?', [$uid, $ref])) return '';
    [$n, $cap] = pfight_offer_today($uid);
    if ($n >= $cap) return ' 🧩 No Puzzle upgrade this time: you have earned all ' . $cap . ' for today. They come back at midnight.';
    if (count(pfight_offers($uid)) >= PF_OFFER_BANK) return ' 🧩 You have ' . PF_OFFER_BANK . ' Puzzle upgrade offers waiting. Open your Puzzle box to choose one.';
    $choices = pfight_offer_choices($u, $rarity);
    if (count($choices) < 1) return '';
    try { q('INSERT INTO user_poffer (user_id, ref, rarity, choices, created_at) VALUES (?, ?, ?, ?, ?)', [$uid, $ref, $rarity, json_encode($choices), now()]); } catch (Throwable $e) { return ''; }
    $day = date('Y-m-d');
    if (!q('UPDATE user_pgrant SET n = n + 1 WHERE user_id = ? AND day = ?', [$uid, $day])->rowCount()) { try { q('INSERT INTO user_pgrant (user_id, day, n) VALUES (?, ?, 1)', [$uid, $day]); } catch (Throwable $e) {} }
    pfight_pages(); unlock_entries($uid, 'pfight:mods');
    return ' 🧩 You earned a Puzzle upgrade! (' . ($n + 1) . ' of ' . $cap . ' today) Open your Puzzle box to choose one of three.';
}

/** Choose one of an offer's three. Returns an error message or null. */
function pfight_offer_pick(array $u, int $offerId, int $choice): ?string
{
    $uid = (int)$u['id'];
    foreach (pfight_offers($uid) as $o) if ((int)$o['id'] === $offerId) {
        $c = $o['choices'][$choice] ?? null;
        if (!$c || !isset(pf_tiles()[$c[0]]) || !isset(PF_MODS[$c[1]])) return 'That choice is gone.';
        if (!in_array($c[0], pf_collection((int)$u['level'], (string)($u['calling'] ?? '')), true)) return 'You do not own that tile.';
        if (q('DELETE FROM user_poffer WHERE id = ? AND user_id = ?', [$offerId, $uid])->rowCount() !== 1) return 'That offer was already used.';
        q('DELETE FROM user_pmod WHERE user_id = ? AND tile_key = ?', [$uid, $c[0]]);
        q('INSERT INTO user_pmod (user_id, tile_key, mod_key) VALUES (?, ?, ?)', [$uid, $c[0], $c[1]]);
        return null;
    }
    return 'That offer was not found.';
}

function pfight_mod_remove(array $u, string $tile): void
{
    if (pmod_ensure()) q('DELETE FROM user_pmod WHERE user_id = ? AND tile_key = ?', [(int)$u['id'], $tile]);
}

/** Put the gnome's upgrades on the tiles of a built deck (pal tiles cannot be upgraded). */
function pfight_apply_mods(array $deck, array $mods): array
{
    foreach ($deck as $i => $t) if (isset($mods[$t['k']]) && pfight_mod_fits($mods[$t['k']], $t['t'])) $deck[$i]['m'] = $mods[$t['k']];
    return $deck;
}
