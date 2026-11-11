<?php
declare(strict_types=1);
/**
 * Puzzle Combat glue: flag, building a fight from the real gnome and creature, POST handling, the fight card.
 * The engine (pfight.php) is pure; this file is the only place it touches the database, the expedition and the old win/knock-out code.
 * Flag off = the old fight, untouched.
 */
require_once __DIR__ . '/pfight.php';

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
    $deck = pf_player_deck($st, $cal, max(1, min(3, (int)calling_tier($u))), $pals, [], $bonus, $canSnack, $box);
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
    if (empty($enc['pf'])) $enc['pf'] = pf_new(pfight_me($u, $exp, $enc), $c, random_int(1, 0x7FFFFFFE));
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
    } elseif ($do === 'pf_play') {
        $idx = array_map('intval', array_filter(explode(',', (string)($_POST['chain'] ?? '')), 'strlen'));
        $left = snacks_left($u, $enc);
        $have = array_sum(array_column(fight_snacks($u), 'qty'));
        $want = 0;
        $r = pf_play($s, $idx, (int)($_POST['turn'] ?? -1), function (array $t) use (&$want, $left, $have, $s) {
            if ($t['tag'] !== 'snack') return null;
            if ((int)$s['me']['hp'] >= (int)$s['me']['max']) return 'You’re not hurt. Save the snack.';
            if (++$want > min($left, $have)) return 'You have no snack to eat' . ($left <= 0 ? ' (snack limit reached this fight).' : '.');
            return null;
        });
        if ($r['err'] === 'stale') { flash('That turn has already passed.', 'err'); $exp['encounter'] = json_encode($enc); return false; }   // double tap or an old page: nothing happens
        if ($r['err']) { flash($r['err'], 'err'); return false; }
        $ate = 0;   // a snack is eaten only for a Snack tile that really resolved (the fight can end mid-chain), cheapest first
        foreach ($r['ev'] as $e) if ($e['by'] === 'me' && $e['tag'] === 'snack') $ate++;
        $snacks = fight_snacks($u);
        usort($snacks, fn($a, $b) => $a['heal'] <=> $b['heal']);
        foreach (array_slice($snacks, 0, 1) as $sn) for ($i = 0; $i < $ate; $i++) if (give_item((int)$u['id'], (int)$sn['id'], -1)) $enc['snacks'] = (int)($enc['snacks'] ?? 0) + 1;
        $won = in_array($s['over'], ['seen_off', 'charmed'], true);
        pfight_unlock((int)$u['id'], $r['ev'], $won);
        $enc['last'] = [];
        foreach ($r['ev'] as $e) { $ln = pfight_line($e, (string)$c['name']); exp_log($exp, $ln); $enc['last'][] = $ln; }
    } else return false;
    $exp['hp'] = (int)$s['me']['hp'];
    $enc['pf'] = $s;
    $exp['encounter'] = json_encode($enc);
    switch ($s['over']) {
        case 'seen_off': case 'charmed':
            $charm = $s['over'] === 'charmed';
            win_fight($u, $exp, $c, $charm, $charm);
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
    $tail = match ($e['t']) { 'hurt' => ($e['by'] === 'me' ? ' for ' . (int)($e['dmg'] ?? $e['v']) : ' for ' . (int)($e['dmg'] ?? $e['v']) . ' damage'), 'guard' => ' (+' . (int)$e['v'] . ' guard)', 'heal', 'item' => ' (+' . (int)$e['v'] . ' health)', 'charm' => ' (' . (int)$e['v'] . ')', default => '' };
    return ($e['by'] === 'me' ? '🧩 ' : '💥 ') . $who . ' ' . $e['n'] . $tail . ($bits ? ' · ' . implode(', ', $bits) : '') . '.';
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
    $v = pf_view($s);
    $h = '<div class="pfight" id="pfight" data-turn="' . (int)$v['turn'] . '" data-open="' . e((string)($v['open'] ?? '')) . '" data-opent="' . e((string)($v['open_t'] ?? '')) . '" data-openv="' . (int)$v['open_v'] . '" data-openby="' . e((string)($v['open_by'] ?? '')) . '" data-redraws="' . (int)$v['redraws'] . '">';
    $h .= '<div class="pf-foe"><b>' . e((string)$c['name']) . '</b> <small class="muted">' . e((string)$c['size']) . ' · lv ' . (int)$c['level'] . ' · ' . ($s['temper'] === 'gentle' ? 'gentle' : 'wary') . '</small>';
    $h .= '<div class="pf-bar" role="img" aria-label="Resolve ' . (int)$v['bar']['now'] . ' of ' . (int)$v['bar']['max'] . '"><progress max="' . (float)$v['bar']['max'] . '" value="' . (float)$v['bar']['now'] . '"></progress></div>';
    $h .= '<small>🃏 ' . (int)$v['foe']['hand'] . ' · likely next: <span class="pf-intent">' . e(pfight_icon((string)$v['foe']['intent'])) . ' ' . e((string)$v['foe']['intent']) . '</span>' . ($v['foe']['calm'] ? ' · 😌 calm ' . (int)$v['foe']['calm'] : '') . '</small></div>';
    $h .= '<div class="pf-strip" aria-live="polite" aria-label="The last tiles played">';
    foreach ($v['strip'] as $t) $h .= pfight_tile_html($t, true);
    if (!$v['strip']) $h .= '<small class="muted">Nothing played yet. You go first.</small>';
    $h .= '</div>';
    if (!empty($enc['last'])) { $h .= '<ol class="pf-last" aria-live="polite" aria-label="What just happened">'; foreach ($enc['last'] as $ln) $h .= '<li>' . e($ln) . '</li>'; $h .= '</ol>'; }
    $h .= '<div class="pf-me">❤️ <progress max="' . (int)$v['max'] . '" value="' . (int)$v['hp'] . '"></progress> ' . (int)$v['hp'] . '/' . (int)$v['max'] . ($v['block'] ? ' · 🛡️ ' . (int)$v['block'] : '') . '</div>';
    $h .= '<p class="pf-preview help" id="pf-preview" aria-live="polite">Tap tiles in the order you want them (1 to 4).</p>';
    $h .= '<div class="pf-hand" id="pf-hand">';
    foreach ($v['hand'] as $i => $t) $h .= pfight_tile_html($t, false, $i);
    $h .= '</div>';
    $seen = array_values(array_unique(array_filter(array_column($v['hand'], 'tag'), fn($x) => isset(PF_TAGS[$x]))));
    if ($seen) { $h .= '<ul class="pf-tags help">'; foreach ($seen as $x) $h .= '<li>' . PF_TAGS[$x][0] . ' ' . e(PF_TAGS[$x][1]) . '</li>'; $h .= '</ul>'; }
    $h .= '<form method="post" class="pf-form" id="pf-form">' . csrf_field() . '<input type="hidden" name="do" value="pf_play"><input type="hidden" name="nonce" value="' . e((string)$s['nonce']) . '"><input type="hidden" name="turn" value="' . (int)$v['turn'] . '"><input type="hidden" name="chain" id="pf-chain" value="">'
        . '<button class="btn primary" id="pf-go" disabled>Play chain</button> <button type="button" class="btn" id="pf-undo" disabled>Undo</button></form>';
    $h .= '<div class="pf-extra"><a class="pf-box" href="' . e(url('puzzlebox.php')) . '">🧩 Puzzle box</a> ';
    if ($v['can_run']) $h .= '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="pf_run"><input type="hidden" name="nonce" value="' . e((string)$s['nonce']) . '"><button class="btn">🏃 Run</button></form> ';
    $h .= '<form method="post" class="inline" id="pf-rform" hidden>' . csrf_field() . '<input type="hidden" name="do" value="pf_redraw"><input type="hidden" name="nonce" value="' . e((string)$s['nonce']) . '"><input type="hidden" name="turn" value="' . (int)$v['turn'] . '"><input type="hidden" name="card" id="pf-card" value=""></form>';
    if ($v['redraws'] > 0) $h .= '<small class="muted">🍀 ' . (int)$v['redraws'] . ' redraw' . ($v['redraws'] > 1 ? 's' : '') . '</small> <button type="button" class="btn" id="pf-redraw" hidden>Redraw a tile</button>';
    $h .= '</div>';
    $h .= '<script type="application/json" id="pf-data">' . json_encode(['combos' => $v['combos'], 'hole' => PF_HOLE], JSON_HEX_TAG | JSON_HEX_AMP) . '</script>';
    return $h . '</div><link rel="stylesheet" href="' . e(url('assets/pfight.css?v=' . APP_VERSION)) . '"><script src="' . e(url('assets/pfight.js?v=' . APP_VERSION)) . '" defer></script>';
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
    $label = $t['n'] . ', ' . ucfirst($t['t']) . ' ' . $t['v'] . ', starts ' . $hole . ', ends ' . ($knob !== '' ? $knob : 'flat') . ($tg ? ', ' . $tg[1] : '');
    $cls = 'pf-tile ' . ($strip ? 'pf-s ' : 'pf-h ') . 'pf-' . $t['t'] . (!empty($t['by']) ? ' by-' . $t['by'] : '');
    // sockets: shape by family (round / keyhole / triangle), a hole is drawn hollow and a knob solid, and the family letter stays as text: never colour alone
    $l = '<span class="pf-sock l hole f-' . ($hole ?: 'flat') . '" aria-hidden="true">' . ($fam[$hole] ?? '·') . '</span>';
    $r = '<span class="pf-sock r knob f-' . ($knob ?: 'flat') . '" aria-hidden="true">' . ($fam[$knob] ?? '·') . '</span>';
    $inner = $l . '<span class="pf-ico" aria-hidden="true">' . pfight_icon($t['t']) . '</span>' . ($strip ? '' : '<span class="pf-nm">' . e($t['n']) . ($tg ? ' <span class="pf-tg" aria-hidden="true">' . $tg[0] . '</span>' : '') . '</span>') . '<span class="pf-val">' . (int)$t['v'] . '</span>' . $r;
    if ($strip) return '<span class="' . $cls . '" role="img" aria-label="' . e($label) . '">' . $inner . '</span>';
    return '<button type="button" class="' . $cls . '" data-i="' . $i . '" data-hole="' . e($hole) . '" data-knob="' . e($knob) . '" data-t="' . e($t['t']) . '" data-tag="' . e($tag) . '" data-v="' . (int)$t['v'] . '" aria-label="' . e($label) . '" aria-pressed="false">' . $inner . '</button>';
}

/** Almanac pages for puzzle fights, added once per world by title (like ensure_almanac_new_pages_2644): one overview and one per combo, each unlocking on first use. */
const PF_PAGES = [
    'Puzzle fights' => ['pfight', 'Win a fight to learn how tiles work.',
        "Fights are played with [b]tiles[/b]. You start with 5 in hand and draw 3 each turn (never above 5). Tap up to 4 tiles in the order you want them, then play the chain. The creature answers with a chain of its own, and a full chain of four gives it one more move.\n\n[b]Types:[/b] ⚔️ Hurt, 🛡️ Guard, 💚 Heal, 🌸 Charm, 😌 Soothe, 🎭 Trick, 🎒 Item. Numbers grow with your stats and level.\n\n[b]Sockets:[/b] each tile has a hole on the left and a knob on the right in one of three families (B Body, M Mind, C Craft). A knob that matches the next tile's hole is a [b]snug fit[/b]: a little extra value. A poor fit still works; it only skips the bonus.\n\n[b]The bar:[/b] every creature has one resolve bar. Hurt and Charm both fill it, gentle creatures like Charm best and wary ones like Hurt. Whichever you used more decides whether you see it off or win it over. A charmed creature leaves a gift.\n\n[b]Run[/b] always works except against the great ones, and costs nothing.\n\n[b]The Puzzle box:[/b] you do not bring every tile you own. Your box holds a limited number (8 at the start, one more every 3 levels, 14 at most), so choose. Open it from the fight card or the My Gnome page. A change applies from your next fight."],
    'Hurt tiles' => ['pfight:tiles', 'Play a Hurt tile with a tactic.',
        "Hurt tiles differ by [b]how[/b] they hit, not only how hard.\n\n⚡ [b]Jab[/b] (Quick): draws you a tile when played.\n📌 [b]Pierce[/b]: ignores the creature's guard.\n🧪 [b]Sting[/b] (Poison): keeps working for 2 more turns.\n🪢 [b]Trip[/b]: the creature plays one tile fewer next turn.\n🛡️ [b]Shield Bash[/b]: adds the guard you built earlier in the chain to the hit.\n🪨 [b]Smash[/b] (Heavy): a big blow that has to go last in a chain.\n\nThey unlock as your gnome grows: Jab at level 5, Pierce 8, Trip 11, Sting 13, Bash 14, Smash 16. Gentle creatures take Hurt at half strength; Charm suits them better."],
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
    foreach ($events as $e) if (($e['by'] ?? '') === 'me' && isset(PF_TAGS[(string)($e['tag'] ?? '')])) { unlock_entries($uid, 'pfight:tiles'); break; }
    foreach ($events as $e) if (($e['by'] ?? '') === 'me' && !empty($e['combo']) && isset($byName[$e['combo']])) unlock_entries($uid, 'pfight:combo:' . $byName[$e['combo']]);
}
