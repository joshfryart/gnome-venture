<?php
declare(strict_types=1);
/**
 * Puzzle Combat glue: flag, building a fight from the real gnome and creature, POST handling, the fight card.
 * The engine (pfight.php) is pure; this file is the only place it touches the database, the expedition and the old win/knock-out code.
 * Flag off = the old fight, untouched.
 */
require_once __DIR__ . '/pfight.php';
require_once __DIR__ . '/pfparts_url.php';   // 2.6.89: the jigsaw parts kit or the old one
require_once __DIR__ . '/pfboard.php';

/** Setting pfight_open: 0 off, admin = admins only, 1 = everyone. Fights in road, lair and delve (Treks are not covered yet). */
function pfight_on(array $u): bool
{
    $v = setting('pfight_open');
    if ($v === '1') return true;
    return $v === 'admin' && ($u['role'] ?? '') === 'admin';
}

/** Setting pfight_v1: 0 off, admin = a NEW fight of an admin uses the v1 board rules (pfboard.php, "v1 board rules"); 1 = everyone (the default since 2.7.57). Only inside pfight_on(). */
function pfight_v1_on(array $u): bool
{
    $v = setting('pfight_v1');
    return $v === '1' || ($v === 'admin' && ($u['role'] ?? '') === 'admin');
}

/**
 * 2.7.01 learner rules (claude/reviews-2026-11-13/learn.md): a gnome's first fights (setting pfight_learner_n, default 3; 0 = off) are gentler: creature pieces x0.8,
 * creature tags off, no Thornburst in the environment's deck. Careless play at level 1-2 goes from 76% to 98% wins with fights as long as before.
 */
function pf_learner_left(int $uid): bool
{
    $n = setting('pfight_learner_n'); $n = $n === '' ? 3 : (int)$n;
    if ($n <= 0) return false;
    try { return (int)q_val('SELECT fights FROM pf_learn WHERE user_id = ?', [$uid]) < $n; } catch (Throwable $e) { return false; }
}
/** Finished v1 fights so far (pf_learn; 0 before the table exists). */
function pf_learn_fights(int $uid): int
{
    try { return (int)q_val('SELECT fights FROM pf_learn WHERE user_id = ?', [$uid]); } catch (Throwable $e) { return 0; }
}
/** 2.7.01 costly cell: End turn asks once before a move that costs health while a free spot was open, in a gnome's first fights (setting pfight_costwarn_n, default 5; 0 = never). */
function pf_cost_warn(int $uid): bool
{
    $n = setting('pfight_costwarn_n'); $n = $n === '' ? 5 : (int)$n;
    return $n > 0 && pf_learn_fights($uid) < $n;
}
/**
 * 2.7.06 staged rules (learn.md item 8). 0 = the learner fights (stage A: creature tags off, pieces x0.8, no Thornburst), 1 = stage B (creature tags on at full strength, still no Thornburst),
 * 2 = stage C (everything: Thornburst joins at gnome level pfight_thorn_level, default 5). Wind, Mud and set aside are already out of the v1 rules (stage D has nothing left to hold back).
 * pfight_staged = 0 gives the old behaviour: full rules as soon as the learner fights are over.
 */
function pf_stage(array $u): int
{
    if (!pfight_v1_on($u) || pf_learner_left((int)$u['id'])) return 0;
    if (setting('pfight_staged') === '0') return 2;
    $lv = setting('pfight_thorn_level'); $lv = $lv === '' ? 5 : max(1, (int)$lv);
    return (int)$u['level'] >= $lv ? 2 : 1;
}
/** The v1 config keys of a stage (merged into the fight's v1 options). */
function pf_stage_cfg(int $stage): array
{
    return match ($stage) { 0 => ['foe_x' => 0.8, 'tags' => 0, 'nothorn' => 1], 1 => ['nothorn' => 1], default => [] };
}
/** The highest stage whose card this gnome has seen. */
function pf_stage_seen(int $uid): int
{
    try { return (int)q_val('SELECT stage FROM pf_learn WHERE user_id = ?', [$uid]); } catch (Throwable $e) { return 0; }
}
function pf_stage_mark(int $uid, int $stage): void
{
    try {
        if (q_val('SELECT 1 FROM pf_learn WHERE user_id = ?', [$uid])) q('UPDATE pf_learn SET stage = ? WHERE user_id = ? AND stage < ?', [$stage, $uid, $stage]);
        else db_insert('pf_learn', ['user_id' => $uid, 'fights' => 0, 'stage' => $stage]);
    } catch (Throwable $e) { /* table or column missing before the upgrade */ }
}
/** 2.7.01 "New today": the rules held back so far, said once at the start of the first fight that has them ([] for any other fight). $stage: the fight's stage (null = work it out from the gnome). */
function pf_new_today(int $uid, ?int $stage = null): array
{
    if ($stage === null) { $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]); $stage = $u ? pf_stage($u) : 0; }
    $seen = pf_stage_seen($uid); $out = [];
    if ($stage >= 1 && $seen < 1) { $out[] = 'Creature tags. Some creature pieces carry one (Quick, Poison, Evade ...): tap a creature piece to read it.'; $out[] = 'Creature pieces hit at full strength now.'; }
    if ($stage >= 2 && $seen < 2) $out[] = 'Thornburst. It hurts whoever fires it: keep it out of your own chains.';
    return $out;
}
/** The one-line card for those rules, on the fight's first turn only. */
function pf_new_today_html(array $s): string
{
    if (empty($s['newt']) || (int)$s['turn'] > 1) return '';
    return '<div class="pfv-new" id="pfv-new" role="status"><b>New today:</b> ' . implode(' ', array_map('e', (array)$s['newt'])) . '</div>';
}
/** 2.7.01 fixed first fight (learn.md item 12): the creature, the kit and the deal of a new gnome's first fight are always the same, so the coaching can point at real cells. */
const PF_FIRST_CREATURE = 'garden-snail';   // learn.md: Garden Snail and Aphid Swarm both 97% for a careless level 1 player; the Snail has no class rule (the Swarm grows)
/** Is the next fight of this gnome the fixed first fight? (setting pfight_first_fixed, v1 rules, no finished v1 fight yet, not a guest) */
function pf_first_due(array $u): bool
{
    return setting('pfight_first_fixed') !== '0' && pfight_on($u) && pfight_v1_on($u) && !is_guest($u) && pf_learn_fights((int)$u['id']) === 0;
}
/** Is this creature the gnome's fixed first fight? */
function pf_first_fight(array $u, array $c): bool
{
    return (string)($c['slug'] ?? '') === PF_FIRST_CREATURE && pf_first_due($u);
}
/** The deal of the fixed first fight (setting pfight_first_seed). */
function pf_first_seed(): int
{
    $v = (int)setting('pfight_first_seed');
    return $v > 0 ? $v : 4;
}
/**
 * 2.7.01: the creature a learner meets. A new gnome's first fight is the Garden Snail; in the other learner fights (pfight_learner_n) nothing above the gnome's own level
 * (learn.md: a level 1 gnome met a level 3 Sand Flea Pack, 27% wins). Called where a road, a wild step or a Trail tile picks a random creature; bosses and fixed spots are left alone.
 */
function pf_learner_creature(array $u, ?array $c, string $land, int $level, string $region = ''): ?array
{
    if (!$c || ($c['size'] ?? '') === 'boss' || !pfight_on($u) || !pfight_v1_on($u) || is_guest($u)) return $c;
    if (pf_first_due($u) && ($snail = q_one('SELECT * FROM creatures WHERE slug = ?', [PF_FIRST_CREATURE]))) return $snail;
    $cap = max(1, (int)$u['level']);
    if (pf_learner_left((int)$u['id']) && (int)$c['level'] > $cap) return pick_creature($land, $level, false, false, $cap, $region) ?? $c;
    return $c;
}

/** 2.7.01 guided first turns: one-line coaching in a gnome's first fights (setting pfight_guide_n, default 2), until the gnome switches it off (pf_learn.guide_off). */
function pf_guide_on(int $uid): bool
{
    $n = setting('pfight_guide_n'); $n = $n === '' ? 2 : (int)$n;
    if ($n <= 0) return false;
    try { $r = q_one('SELECT fights, guide_off FROM pf_learn WHERE user_id = ?', [$uid]); } catch (Throwable $e) { return pf_learn_fights($uid) < $n; }
    return !$r || ((int)$r['fights'] < $n && (int)$r['guide_off'] === 0);
}
/** The gnome tapped the coaching line's close button: no more coaching, in this fight or the next. */
function pf_guide_off(int $uid): void
{
    try {
        if (q_val('SELECT 1 FROM pf_learn WHERE user_id = ?', [$uid])) q('UPDATE pf_learn SET guide_off = 1 WHERE user_id = ?', [$uid]);
        else db_insert('pf_learn', ['user_id' => $uid, 'fights' => 0, 'guide_off' => 1]);
    } catch (Throwable $e) { /* the column arrives with the upgrade */ }
}

/** 2.7.01 hint button: free hints a fight (setting pfight_hint_n, default 3; 0 = no button). */
function pf_hint_n(): int
{
    $n = setting('pfight_hint_n');
    return $n === '' ? 3 : max(0, (int)$n);
}
/**
 * The hint for the turn: the placement the learner bot would pick (pfb_search for your side: your chain on a copy, scored by what it does to the bar, your health and guard,
 * plus the bramble under it and the announced environment), and why in one line. Public information only: the board, your hand, the creature's shown aim, the forecast.
 * The creature's real reply, its hand and both draw piles are never looked at (pfb_search for 'me' places your piece and fires your chain; nothing of the creature's turn runs).
 * Returns ['i' => hand index, 'x', 'y', 'why'] or null (the opening, a fight that is over, nothing fits).
 */
function pf_hint(array $s, string $foe): ?array
{
    if (!empty($s['over']) || !empty($s['start']) || empty($s['v1'])) return null;
    $pub = $s;   // the hint's copy: the creature's hand and the draw piles emptied, so nothing hidden can reach the choice
    $pub['foe']['hand'] = []; $pub['foe']['draw'] = []; $pub['me']['draw'] = [];
    $m = pfb_search($pub, 'me');
    if ($m === null) return null;
    [$i, $x, $y] = $m;
    $q = pfb_cell_preview($s, $i)["$x,$y"] ?? null;
    $nm = (string)($s['me']['hand'][$i]['n'] ?? 'this piece');
    $bits = [];
    if ($q) {
        if (!empty($q['end'])) $bits[] = 'it ends the fight';
        if ((int)$q['n'] >= 2) $bits[] = 'your chain fires ' . (int)$q['n'] . ' pieces';
        if ((int)$q['dmg'] > 0) $bits[] = 'it hurts the ' . $foe . ' ' . (int)$q['dmg'];
        if ((int)$q['ch'] > 0) $bits[] = 'it charms the ' . $foe . ' ' . (int)$q['ch'];
        $bits[] = (int)$q['hp'] > 0 ? 'it costs you ' . (int)$q['hp'] . ' health (every other spot is worse)' : 'it costs you no health';
    }
    $aim = $s['foe']['plan'] ?? null;
    if ($aim && (int)($aim['x'] ?? -1) === $x && (int)($aim['y'] ?? -1) === $y) $bits[] = 'it takes the red-marked spot the ' . $foe . ' wanted';
    return ['i' => (int)$i, 'x' => (int)$x, 'y' => (int)$y, 'why' => $nm . ' here: ' . ($bits ? implode(', ', $bits) : 'the best spot on the board') . '.'];
}
/** The hint, answered as JSON (assets/pfboardv1.js posts do=pfb_hint). Counts one of the fight's free hints the first time a turn asks; asking again in the same turn is free. Echoes JSON and exits. */
function pfight_hint_out(array $u, array $exp): void
{
    $out = function (array $o) { header('Content-Type: application/json'); header('Cache-Control: no-store'); echo json_encode($o); exit; };
    $bad = function (string $why) use ($out) { if (db()->inTransaction()) db()->rollBack(); $out(['ok' => false, 'err' => $why]); };
    $enc = json_decode((string)$exp['encounter'], true); $c = $enc ? encounter_creature($enc) : null; $s = $enc['pf'] ?? null;
    if (!$c || !is_array($s) || ($s['mode'] ?? '') !== 'board' || empty($s['v1'])) $bad('There is no fight to give a hint in.');
    if (!hash_equals((string)$s['nonce'], (string)($_POST['nonce'] ?? ''))) $bad('That page is from another fight. Reload it.');
    if ((int)($_POST['turn'] ?? -1) !== (int)$s['turn']) $bad('That turn has already passed. Reload the page.');
    $max = pf_hint_n(); $used = (int)($enc['hints'] ?? 0); $again = (int)($enc['hintturn'] ?? 0) === (int)$s['turn'];
    if ($max <= 0) $bad('Hints are switched off.');
    if (!$again && $used >= $max) $bad('No hints left in this fight.');
    $s['me']['hp'] = min((int)$s['me']['max'], max(1, (int)$exp['hp']));
    $h = pf_hint($s, (string)$c['name']);
    if (!$h) $bad(!empty($s['start']) ? 'Any side of the blank is fine to start with.' : 'Nothing fits this turn.');
    if (!$again) { $enc['hints'] = ++$used; $enc['hintturn'] = (int)$s['turn']; q("UPDATE expeditions SET encounter = ? WHERE id = ? AND status = 'active'", [json_encode($enc), $exp['id']]); }
    if (db()->inTransaction()) db()->commit();
    $out(['ok' => true, 'left' => max(0, $max - $used)] + $h);
}

/** 2.7.01 free retry: after a defeat in a gnome's first fights (setting pfight_retry_n, default 5) "Try again" deals the same creature again. pf_learn already counts the lost fight. */
function pf_retry_ok(int $uid): bool
{
    $n = setting('pfight_retry_n'); $n = $n === '' ? 5 : (int)$n;
    return $n > 0 && pf_learn_fights($uid) <= $n;   // the lost fight is already counted: the 5th fight lost reads 5
}

/** 2.7.01 defeat recap (learn.md item 11): where your health went, from the fight's events (hpnow before and after each one). Keys: chain (your own chains firing creature pieces or Thornburst), foe (its turn), poison, env. */
function pf_loss_add(array &$loss, array $events, int $hp0): void
{
    $hp = $hp0;
    foreach ($events as $e) {
        if (isset($e['env'])) {   // the environment's turn: each event says what it took from you (hpnow is the health after the whole turn)
            if ((int)($e['me'] ?? 0) > 0) { $k = $e['env'] === 'poison' ? 'poison' : 'env'; $loss[$k] = ($loss[$k] ?? 0) + (int)$e['me']; }
            if (isset($e['hpnow'])) $hp = (int)$e['hpnow'];
            continue;
        }
        if (!isset($e['hpnow'])) continue;
        $d = $hp - (int)$e['hpnow']; $hp = (int)$e['hpnow'];
        if ($d <= 0) continue;
        $k = ($e['ta'] ?? $e['by']) === 'me' ? 'chain' : 'foe';
        $loss[$k] = ($loss[$k] ?? 0) + $d;
    }
}
/** The recap line for the result card ('' when nothing was lost). */
function pf_loss_line(array $loss, string $foe): string
{
    $w = ['foe' => 'to the ' . $foe . '’s pieces', 'chain' => 'to your own chains (creature pieces or a Thornburst you linked)', 'poison' => 'to poison', 'env' => 'to the environment'];
    $bits = [];
    arsort($loss);
    foreach ($loss as $k => $n) if ((int)$n > 0 && isset($w[$k])) $bits[] = (int)$n . ($bits ? ' ' : ' health ') . $w[$k];
    if (!$bits) return '';
    $last = array_pop($bits);
    return 'You lost ' . ($bits ? implode(', ', $bits) . ' and ' . $last : $last) . '.' . (!empty($loss['chain']) ? ' A red-edged spot costs you health: pick another when you can.' : '');
}

/** One more finished fight for the gnome (called once per fight). */
function pf_learner_bump(int $uid): void
{
    try {
        if (q_val('SELECT 1 FROM pf_learn WHERE user_id = ?', [$uid])) q('UPDATE pf_learn SET fights = fights + 1 WHERE user_id = ?', [$uid]);
        else db_insert('pf_learn', ['user_id' => $uid, 'fights' => 1]);
    } catch (Throwable $e) { /* table missing before the upgrade: no learner rules */ }
}

/** The gnome's tile numbers: stat modifiers (with the pal road perk and the old calling numbers remapped) and the per-type bonuses. Used by the fight and the Puzzle box page. */
function pfight_calc(array $u): array
{
    $st = ['level' => (int)$u['level']];
    foreach (['grit', 'nimble', 'hardiness', 'charm', 'lore', 'luck', 'sense'] as $k) $st[$k] = eff_mod($u, $k);   // sense: only stat pieces count it (pf_make_tile's stat override)
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
function pfight_me(array $u, array $exp, array $enc = [], bool $first = false): array
{
    [$st, $pals, $bonus] = pfight_calc($u);
    $cal = (string)($u['calling'] ?? '');
    $box = pf_box((int)$u['level'], $cal, pbox_load((int)$u['id']));
    $canSnack = snacks_left($u, $enc) > 0 && fight_snacks($u) !== [];   // no snack to eat = a weak Breather instead of a dead Snack tile
    if (pfight_v1_on($u)) {   // 2.6.74, the v1 deck model: the deck the gnome built (starter kit + what they switched on + fight-belt tools + party pals); pals add a piece, they no longer swap one out
        require_once __DIR__ . '/pfdeck.php';
        if ($first) return ['hp' => max(1, (int)$exp['hp']), 'max_hp' => (int)$exp['max_hp'], 'stats' => $st, 'deck' => pfd_first_tiles($u, $st), 'luck' => max(0, $st['luck'])];   // 2.7.01 fixed first fight: the Bold kit only (no tools, pals, wearables, snacks or upgrades), so the deal is the same for every new gnome
        return ['hp' => max(1, (int)$exp['hp']), 'max_hp' => (int)$exp['max_hp'], 'stats' => $st, 'deck' => pfight_apply_mods(pfd_start_fight($u, $st, $bonus, $canSnack), pfight_mods((int)$u['id'])), 'luck' => max(0, $st['luck'])]
            + (pfd_statpieces_open($u) ? ['lpts' => eff_stat($u, 'luck')] : []);   // stat pieces: Luck POINTS for the shared Luck roll (pfb_wx_roll)
    }
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
        $out[] = ['swap' => $swap, 'n' => (string)($pal['name'] ?? 'Pal'), 't' => $t, 'v' => 4 + min(4, (int)pf_round($score[$t] / 2)) + 2 * $rar, 'r' => $knob[$t]];
    }
    return $out;
}

/** The fight state inside the encounter ($enc['pf']); created on first sight. Returns the state (also stored in $enc). */
function pfight_state(array $u, array &$exp, array &$enc, array $c): array
{
    if (empty($enc['pf'])) {   // a new fight starts in the mode the setting says; a fight already under way keeps its own
        $v1 = pfight_v1_on($u);   // the v1 board rules: always a board fight; the state carries $s['v1'], so a fight under way keeps the rules it started with
        $new = $v1 || setting('pfight_mode') === 'board' ? 'pfb_new' : 'pf_new';
        $learn = $v1 && pf_learner_left((int)$u['id']);
        $first = $v1 && pf_first_fight($u, $c);   // 2.7.01 fixed first fight: fixed kit, fixed deal
        $stage = $v1 ? pf_stage($u) : 2;   // 2.7.06 staged rules
        if ($learn) $exp['hp'] = (int)$exp['max_hp'];
        if ($v1 && $stage < 2) $v1 = pf_stage_cfg($stage);   // 2.7.01 learner rules: the first fights (and they start at full health; pfight_html saves it)
        if ($v1) { require_once __DIR__ . '/pfdeck.php'; $c = pfd_foe_row($c, $first ? '' : pfd_exp_region($exp)); }   // the creature's layered deck: 4 base (class) + region + size extras + 3 unique (the fixed first fight: no region piece)
        $enc['pf'] = $new(pfight_me($u, $exp, $enc, $first), $c, $first ? pf_first_seed() : random_int(1, 0x7FFFFFFE), ['v1' => $v1, 'blank' => $first || setting('pfight_blank') !== '0', 'can_pluck' => (int)q_val('SELECT COUNT(*) FROM creature_drops WHERE creature_id = ? AND item_id IS NOT NULL', [$c['id']]) > 0]);
        if ($learn) $enc['pf']['learn'] = 1;
        if ($first) $enc['pf']['first'] = 1;
        $enc['hp0'] = (int)$exp['hp'];   // 2.7.01: your health when the fight was dealt (a free retry starts there again)
        if ($v1 && ($nt = pf_new_today((int)$u['id'], $stage))) { $enc['pf']['newt'] = $nt; pf_stage_mark((int)$u['id'], $stage); }   // 2.7.01: the first fight after the learner fights says what is new
    }
    return $enc['pf'];
}

/** One POST: 'pf_play' (chain = "2,0,3", turn), 'pf_run', 'pf_redraw' (card = index). The caller holds the transaction and has locked the gnome. Returns true when the fight ended. */
/** The one action of a board turn from the posted "moves": "i,x,y" (place a hand piece), "c,x,y" (place the set-aside group), "j,a,b,SIDE" (set two hand pieces aside, joined), "h,b,anc,SIDE" (add a hand piece to the group). Null when malformed. */
function pfight_parse_moves(string $raw): ?array
{
    $parts = array_values(array_filter(explode(';', $raw), 'strlen'));
    if (count($parts) !== 1) return null;
    $p = explode(',', $parts[0]);
    $int = fn($v) => ctype_digit((string)$v);
    if (count($p) === 3 && $int($p[0]) && $int($p[1]) && $int($p[2])) return [[(int)$p[0], (int)$p[1], (int)$p[2]]];
    if (count($p) === 3 && $p[0] === 'c' && $int($p[1]) && $int($p[2])) return [['c', (int)$p[1], (int)$p[2]]];
    if (count($p) === 4 && $p[0] === 'j' && $int($p[1]) && $int($p[2]) && in_array($p[3], ['L', 'R', 'T', 'B'], true)) return [['j', (int)$p[1], (int)$p[2], $p[3]]];
    if (count($p) === 4 && $p[0] === 'h' && $int($p[1]) && $int($p[2]) && in_array($p[3], ['L', 'R', 'T', 'B'], true)) return [['h', (int)$p[1], (int)$p[2], $p[3]]];
    return null;
}

function pfight_do(array $u, array &$exp, string $do): bool
{
    $enc = json_decode((string)$exp['encounter'], true);
    $c = encounter_creature($enc);
    if (!$c) return false;
    $s = pfight_state($u, $exp, $enc, $c);
    if (!hash_equals((string)$s['nonce'], (string)($_POST['nonce'] ?? ''))) { flash('That page is from another fight. Here is the current one.', 'err'); $exp['encounter'] = json_encode($enc); return false; }   // a stale page can never play into a different fight
    $s['me']['hp'] = min((int)$s['me']['max'], max(1, (int)$exp['hp']));   // the expedition's health is the truth (the flag may have been flipped mid-fight)
    if ($do === 'pf_retry') {   // 2.7.01 free retry: a lost fight in the first fights is dealt again (same creature, a new deal, your health as it was when the last one was dealt)
        if (($s['mode'] ?? '') !== 'board' || empty($s['v1']) || ($enc['lost'] ?? '') !== 'defeat' || $s['over'] !== 'defeat' || !pf_retry_ok((int)$u['id'])) return false;
        $exp['hp'] = max(1, min((int)$exp['max_hp'], (int)($enc['hp0'] ?? $exp['max_hp'])));
        foreach (['pf', 'lost', 'won', 'replay', 'replay0', 'prev', 'hist', 'histnew', 'snaps', 'snapn', 'snaplast', 'last', 'note', 'loss', 'hints', 'hintturn', 'learnsaved', 'wearsaved', 'stolen', 'snacks'] as $k) unset($enc[$k]);
        $enc['pfgo'] = 1; $enc['retry'] = (int)($enc['retry'] ?? 0) + 1;
        exp_log($exp, '🔁 You dust yourself off and face the ' . $c['name'] . ' again.');
        $exp['encounter'] = json_encode($enc);
        return false;
    }
    if ($do === 'pf_finish' && ($s['mode'] ?? '') === 'board' && !empty($s['v1']) && !empty($enc['lost']) && in_array($s['over'], ['defeat', 'stall'], true)) {   // 2.6.78: a LOST fight waited for this button too (its last turn was replayed first): now it ends
        return pfight_lost_end($u, $exp, $c, $s, $enc);
    }
    if ($do === 'pf_finish') {   // the fight was won on an earlier turn and the page waited for this button: now the reward
        if (($s['mode'] ?? '') !== 'board' || !in_array($s['over'], ['seen_off', 'charmed'], true) || empty($enc['won'])) return false;
        $charm = $s['over'] === 'charmed';
        fight_ev(['end' => $charm ? 'peace' : 'win']);   // the end scene: the foe falls, the chest opens, the loot is drawn in
        win_fight($u, $exp, $c, $charm, $charm, (array)($enc['stolen'] ?? []));
        return true;
    }
    $one = !empty($s['v1']['onebar']);   // 2.6.95: one shared bar; the page's creature bar shows Hurt + Charm (its charm bar is not drawn)
    $rp0 = ['bar' => pf_round((float)$s['bar']['now'], 1), 'fh' => pf_round((float)$s['fh']['now'] + ($one ? (float)$s['bar']['now'] : 0.0), 1), 'hp' => (int)$s['me']['hp'], 'g' => (int)$s['me']['block'], 'fg' => (int)$s['foe']['block']];   // where the bar and your health stood before this turn (the board page plays the turn back from here)
    $won = false;
    $prev = !empty($s['v1']) ? ['ter' => (object)($s['ter'] ?? []), 'envs' => $s['envs'] ?? [], 'aim' => $s['foe']['plan'] ?? null] + (!empty($s['v1']['env']) ? ['env' => pfb_view($s)['env']] : []) + (!empty($s['aoed']) ? ['aoe' => pfb_view($s)['aoe']] : []) + (!empty($s['snr']) ? ['snares' => pfb_view($s)['snares'] ?? []] : []) : null;   // 2.7.55: the boss's marked AOE   // 2.6.75: plus the environment's face-up piece   // v1 (stage C): the ground, the forecast and the aim as they stood before this turn (the page plays the turn back from there)
    if ($do === 'pf_run') {
        if (!pf_run($s)) { flash('You cannot run from this one.', 'err'); return false; }
    } elseif ($do === 'pfb_flip') {   // v1: flip a hand piece (free, once a turn; POST hand = its index, turn). Nothing else changes: no creature turn, the replay of the last turn stays
        if (($s['mode'] ?? '') !== 'board') return false;
        $err = pfb_flip($s, (int)($_POST['hand'] ?? -1), (int)($_POST['turn'] ?? -1));
        if ($err) { if ($err !== 'stale') flash($err, 'err'); $exp['encounter'] = json_encode($enc); return false; }
    } elseif ($do === 'pf_redraw') {
        if (!pf_redraw($s, (int)($_POST['card'] ?? -1), (int)($_POST['turn'] ?? -1))) { $exp['encounter'] = json_encode($enc); return false; }   // no redraws left, or a stale page: nothing happens
    } elseif ($do === 'pfb_play' && !empty($s['start']) && ($s['mode'] ?? '') === 'board') {   // 2.6.66: the blank-centre opening: the page posts "hand,x,y" with x,y next to the blank; that is your start piece and its side (nothing fires)
        $moves = pfight_parse_moves((string)($_POST['moves'] ?? ''));
        $cx = (int)($s['pcs'][1]['x'] ?? intdiv(pfb_w($s), 2)); $cy = (int)($s['pcs'][1]['y'] ?? intdiv(pfb_h($s), 2)); $side = null;   // where the Blank is (it starts on a random inner cell since 2.6.981)
        if ($moves && is_int($moves[0][0])) $side = pfb_start_side($s, (int)$moves[0][1], (int)$moves[0][2]);
        if ($side === null) { flash('Pick a spot next to the blank.', 'err'); return false; }
        $mine = (string)($s['me']['hand'][$moves[0][0]]['n'] ?? '');
        $err = pfb_start($s, $moves[0][0], $side);
        if ($err) { flash($err, 'err'); return false; }
        $nm = ['L' => 'left', 'R' => 'right', 'T' => 'top', 'B' => 'bottom']; $sideOf = fn($p) => $p['x'] < $cx ? 'left' : ($p['x'] > $cx ? 'right' : ($p['y'] < $cy ? 'top' : 'bottom')); $foe = [];
        foreach ($s['pcs'] as $p) if ($p['by'] === 'foe') $foe[] = 'the ' . $c['name'] . ' put ' . $p['tile']['n'] . ' (' . $p['tile']['t'] . ' ' . (int)$p['tile']['v'] . ') on the ' . $sideOf($p);
        $enc['note'] = 'You put ' . $mine . ' on the ' . $nm[$side] . '; ' . implode(', ', $foe) . '. Turn 1: place a piece.';
        $enc['last'] = []; $enc['replay'] = []; $enc['histnew'] = 0;
        if (!empty($s['v1'])) { require_once __DIR__ . '/pfcodex.php'; pfcx_note($u, $c, $s); }   // 2.7.55 Creature Codex: met, and the pieces it opened with
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
            $moves = pfight_parse_moves((string)($_POST['moves'] ?? ''));
            $r = $moves === null ? ['ev' => [], 'err' => 'Those moves are not valid.'] : pfb_play($s, $moves, (int)($_POST['turn'] ?? -1), $guard);
        } else $r = pf_play($s, $idx, (int)($_POST['turn'] ?? -1), $guard);
        if ($r['err'] === 'stale') { flash('That turn has already passed.', 'err'); $exp['encounter'] = json_encode($enc); return false; }   // double tap or an old page: nothing happens
        if ($r['err']) { flash($r['err'], 'err'); return false; }
        $ate = 0;   // a snack is eaten only for a Snack tile that really resolved (the fight can end mid-chain), cheapest first
        foreach ($r['ev'] as $e) if ($e['by'] === 'me' && ($e['tag'] ?? '') === 'snack' && ($e['root'] ?? true)) $ate++;
        $snacks = fight_snacks($u);
        usort($snacks, fn($a, $b) => $a['heal'] <=> $b['heal']);
        foreach (array_slice($snacks, 0, 1) as $sn) for ($i = 0; $i < $ate; $i++) if (give_item((int)$u['id'], (int)$sn['id'], -1)) $enc['snacks'] = (int)($enc['snacks'] ?? 0) + 1;
        $won = in_array($s['over'], ['seen_off', 'charmed'], true);
        if (!empty($s['v1'])) { $loss = (array)($enc['loss'] ?? []); pf_loss_add($loss, $r['ev'], (int)$rp0['hp']); $enc['loss'] = $loss; }   // 2.7.01 defeat recap: where your health went
        pfight_unlock((int)$u['id'], array_values(array_filter($r['ev'], fn($e) => empty($e['connect']))), $won);
        if (!empty($s['v1']) && ($s['mode'] ?? '') === 'board') { require_once __DIR__ . '/pfcodex.php'; pfcx_note($u, $c, $s, $won); }   // 2.7.55 Creature Codex
        $enc['last'] = []; $enc['replay'] = []; $enc['replay0'] = $rp0;
        if ($prev) $enc['prev'] = $prev;
        if ($board) {
            $snaps = (array)($enc['snaps'] ?? []); $sn = (int)($enc['snapn'] ?? 0); $cur = isset($enc['snaplast']) ? (int)$enc['snaplast'] : null;
            foreach ($r['ev'] as $e) {
                if (isset($e['snap'])) { $snaps[++$sn] = $e['snap']; $cur = $sn; }   // each placement keeps the board as it was, so a history chip can rewind to it
                $enc['hist'][] = pfight_chip_event($e, $cur, $one);
            }
            ksort($snaps); $enc['snaps'] = array_slice($snaps, -14, null, true); $enc['snapn'] = $sn; $enc['snaplast'] = $cur; $enc['histnew'] = count($r['ev']);
        }   // one chip per scored piece; the board page plays them in one at a time
        else foreach (array_filter([pfight_chip($r['ev'], 'me'), pfight_chip($r['ev'], 'foe')]) as $chip) $enc['hist'][] = $chip;
        $enc['hist'] = array_slice((array)($enc['hist'] ?? []), -30);
        foreach ($r['ev'] as $e) {
            $ln = pfight_line($e, (string)$c['name']);
            if (($e['pluck'] ?? '') === 'got') {   // Pluck worked: lift one item this creature could drop (weighted by its drop chances)
                $rows = q('SELECT cd.item_id, cd.chance, cd.reg, cd.lvmin, cd.lvmax, i.name FROM creature_drops cd JOIN items i ON i.id = cd.item_id WHERE cd.creature_id = ? AND cd.item_id IS NOT NULL', [$c['id']])->fetchAll();
                $pReg = scene_region_code(exp_scene($exp));   // 2.7.06: Pluck honours the same region / level gates as the win drops
                $rows = array_values(array_filter($rows, fn($x) => creature_drop_open($x, $pReg, (int)$c['level'])));
                if ($rows) {
                    $tot = array_sum(array_map(fn($x) => max(1, (int)$x['chance']), $rows)); $roll = random_int(1, $tot); $pick = $rows[0];
                    foreach ($rows as $x) { $roll -= max(1, (int)$x['chance']); if ($roll <= 0) { $pick = $x; break; } }
                    give_item((int)$u['id'], (int)$pick['item_id'], 1);
                    $ln = '🤏 You lift ' . $pick['name'] . ' from the ' . $c['name'] . '!';
                    $enc['stolen'][] = ['name' => (string)$pick['name'], 'qty' => 1, 'img' => (string)(item_art_map()['id'][(int)$pick['item_id']] ?? '')];   // shown on the win screen too
                }
            }
            exp_log($exp, $ln); $enc['last'][] = $ln;
            if ($board) $enc['replay'][] = ['id' => isset($e['id']) ? (int)$e['id'] : null, 'by' => (string)$e['by'], 'ta' => (string)($e['ta'] ?? $e['by']), 'ln' => $ln, 'bar' => $e['barnow'] ?? null, 'fh' => pfight_fhnow($e, $one), 'hp' => $e['hpnow'] ?? null, 'g' => $e['gnow'] ?? null, 'fg' => $e['fgnow'] ?? null, 'n' => (string)($e['n'] ?? ''), 't' => (string)($e['t'] ?? '')]   // the board page plays these back one at a time
                + (isset($e['env']) ? ['env' => (string)$e['env'], 'x' => $e['x'] ?? null, 'y' => $e['y'] ?? null, 'dir' => $e['dir'] ?? null, 'moved' => $e['moved'] ?? null, 'ids' => $e['ids'] ?? null, 'me' => $e['me'] ?? 0, 'foe' => $e['foe'] ?? 0] + (isset($e['kind']) ? ['kind' => (string)$e['kind']] : []) + (isset($e['for']) ? ['for' => (string)$e['for']] : []) + (isset($e['guard']) ? ['guard' => (int)$e['guard']] : []) : [])   // v1 (stage C): a terrain event: where it landed and what it did
                + (isset($e['note']) ? ['note' => (string)$e['note']] + (isset($e['moved']) ? ['moved' => $e['moved']] : []) : []) + (!empty($e['strike']) ? ['strike' => 1, 'broke' => !empty($e['broke'])] : []) + (!empty($e['used']) ? ['used' => $e['used']] : []) + (!empty($e['cs']) ? ['cs' => 1, 'rid' => (int)($e['rid'] ?? 0)] : []) + (!empty($e['tw']) ? ['tw' => $e['tw']] : []) + (!empty($e['sun']) ? ['sun' => 1] : []) + (!empty($e['mud']) ? ['mud' => 1] : []) + (!empty($e['full']) ? ['full' => 1] : []);
        }
    } else return false;
    $exp['hp'] = (int)$s['me']['hp'];
    if ($s['over'] && !empty($s['v1']) && empty($enc['learnsaved'])) { $enc['learnsaved'] = 1; pf_learner_bump((int)$u['id']); }   // 2.7.01: one more fight finished (learner rules last for the first few)
    if ($s['over'] && !empty($s['wear']) && empty($enc['wearsaved'])) {   // v1 deck model: the fight is over (however it ended), so the wear of the fight tools whose pieces were played is saved, once
        require_once __DIR__ . '/pfdeck.php';
        $enc['wearsaved'] = 1;
        foreach (pfd_end_fight($u, $s) as $ln) exp_log($exp, $ln);
    }
    $enc['pf'] = $s;
    $exp['encounter'] = json_encode($enc);
    if (!empty($s['v1']) && ($s['mode'] ?? '') === 'board' && in_array($s['over'], ['defeat', 'stall'], true)) {   // 2.6.78: a fight that is lost (or runs out of turns) waits like a won one: the page replays its last turn, THEN shows the result card with a Continue button (pf_finish)
        $enc['lost'] = $s['over']; $exp['encounter'] = json_encode($enc); return true;
    }
    if (!empty($s['v1']) && in_array($s['over'], ['defeat', 'run', 'stall'], true)) {   // v1 (stage C): the result card of a fight that was lost or left is shown on the next page (the encounter is gone by then)
        require_once __DIR__ . '/pfdeck_view.php';
        $_SESSION['pfv_res'] = ['how' => (string)$s['over'], 'name' => (string)$c['name'], 'slug' => (string)($c['slug'] ?? ''), 'size' => (string)($c['size'] ?? 'small'), 'hp' => $s['over'] === 'defeat' ? 0 : (int)$s['me']['hp'], 'max' => (int)$s['me']['max'], 'turns' => (int)$s['turn'], 'wear' => pfv_wear_rows($u, $s), 'at' => time()];
    }
    switch ($s['over']) {
        case 'seen_off': case 'charmed':
            if (($s['mode'] ?? '') === 'board') { $enc['won'] = $s['over']; $exp['encounter'] = json_encode($enc); return true; }   // the board waits for the End fight button (after its replay)
            $charm = $s['over'] === 'charmed';
            fight_ev(['end' => $charm ? 'peace' : 'win']);
            win_fight($u, $exp, $c, $charm, $charm, (array)($enc['stolen'] ?? []));
            return true;
        case 'defeat': case 'run': case 'stall':
            return pfight_lost_end($u, $exp, $c, $s, $enc);
    }
    return false;
}

/** A fight that did not end in a win: you are knocked out, you slip away, or it loses interest. (2.6.78: a v1 board fight gets here from the Continue button, after its last turn has been replayed.) */
function pfight_lost_end(array $u, array &$exp, array $c, array $s, array $enc): bool
{
    if ($s['over'] === 'defeat' && !empty($s['learn'])) {   // 2.7.01: no knock-out in the learner fights (learn.md item 3): the creature wanders off, the walk goes on, your health is back to full
        exp_log($exp, '🍂 The ' . $c['name'] . ' has had its fun and wanders off. You sit down, catch your breath and feel yourself again.');
        $exp['hp'] = (int)$exp['max_hp'];
        $exp['encounter'] = null;
        unlock_entries((int)$u['id'], 'creature:' . $c['slug']);
        return true;
    }
    if ($s['over'] === 'defeat') {
        fight_ev(['end' => 'ko']);
        knock_out($u, $exp, $c);
        return true;
    }
    exp_log($exp, $s['over'] === 'run' ? '🏃 You slip away from the ' . $c['name'] . '.' : '🍂 The ' . $c['name'] . ' loses interest and wanders off.');
    $exp['encounter'] = null;
    if (($exp['kind'] ?? 'walk') === 'delve' && (int)$exp['depth'] >= ((int)($exp['steps_total'] ?? 0) ?: DELVE_ROOMS)) {
        $exp['status'] = 'done';
        exp_log($exp, '🪜 You climb back out. The chest stays guarded.');
    }
    return true;
}

/** A dry run of the planned placements (assets/pfboard.js asks after each change). Read only: nothing is saved, and only public things come back (what the pieces would do), never the draw pile or the creature's hand. Echoes JSON and exits. */
function pfight_preview_out(array $u, array $exp): void
{
    $out = function (array $o) { header('Content-Type: application/json'); header('Cache-Control: no-store'); echo json_encode($o); if (db()->inTransaction()) db()->rollBack(); exit; };
    $enc = json_decode((string)$exp['encounter'], true); $c = $enc ? encounter_creature($enc) : null; $s = $enc['pf'] ?? null;
    if (!$c || !is_array($s) || ($s['mode'] ?? '') !== 'board') $out(['ok' => false, 'err' => 'no fight']);
    if (!hash_equals((string)$s['nonce'], (string)($_POST['nonce'] ?? ''))) $out(['ok' => false, 'err' => 'stale']);
    $s['me']['hp'] = min((int)$s['me']['max'], max(1, (int)$exp['hp']));
    $moves = pfight_parse_moves((string)($_POST['moves'] ?? ''));
    if ($moves === null) $out(['ok' => false, 'err' => 'moves']);
    $before = (float)$s['bar']['now']; $one = !empty($s['v1']['onebar']); $fh0 = (float)$s['fh']['now'] + ($one ? $before : 0.0);   // 2.6.95: one shared bar: the creature bar is Hurt + Charm
    $r = pfb_play($s, $moves, (int)($_POST['turn'] ?? -1), null, true, true);   // 2.6.95: withAim: what its committed move would do after this placement
    if ($r['err']) $out(['ok' => false, 'err' => (string)$r['err']]);
    $lines = [];
    foreach ($r['ev'] as $e) $lines[] = isset($e['pluck']) ? '🤏 Pluck: a small chance to lift something.' : pfight_line($e, (string)$c['name']);
    $out(['ok' => true, 'lines' => $lines, 'bar' => [$before, $r['bar'], $r['max']], 'fh' => [$fh0, $r['fh'] + ($one ? $r['bar'] : 0.0), $r['fhmax']], 'over' => $r['over'] ?: null] + (array_key_exists('aim', $r) ? ['aim' => $r['aim']] : []));
}

/**
 * 2.6.75: flip a hand piece WITHOUT a page load (assets/pfboardv1.js posts do=pfb_flip with X-Requested-With: pfflip). The flip is saved here (the caller holds the transaction and has locked the gnome);
 * the answer is the hand as it now stands (edges, flipped, who may still flip) and whether the turn's flip is used. Echoes JSON and exits. The plain form post (pfight_do) still works without script.
 */
function pfight_flip_out(array $u, array $exp): void
{
    $out = function (array $o) { header('Content-Type: application/json'); header('Cache-Control: no-store'); echo json_encode($o); exit; };
    $bad = function (string $why) use ($out) { if (db()->inTransaction()) db()->rollBack(); $out(['ok' => false, 'err' => $why]); };
    $enc = json_decode((string)$exp['encounter'], true); $c = $enc ? encounter_creature($enc) : null; $s = $enc['pf'] ?? null;
    if (!$c || !is_array($s) || ($s['mode'] ?? '') !== 'board') $bad('There is no fight to flip a piece in.');
    if (!hash_equals((string)$s['nonce'], (string)($_POST['nonce'] ?? ''))) $bad('That page is from another fight. Reload it.');
    $err = pfb_flip($s, (int)($_POST['hand'] ?? -1), (int)($_POST['turn'] ?? -1));
    if ($err) $bad($err === 'stale' ? 'That turn has already passed. Reload the page.' : $err);
    $enc['pf'] = $s;
    q("UPDATE expeditions SET encounter = ? WHERE id = ? AND status = 'active'", [json_encode($enc), $exp['id']]);
    if (db()->inTransaction()) db()->commit();
    $v = pfb_view($s);
    $out(['ok' => true, 'hand' => array_map(fn($t) => ['e' => $t['e'], 'flip' => !empty($t['flip']), 'canflip' => !empty($t['canflip'])], $v['hand']), 'flip' => $v['flip'] ?? ['on' => false, 'used' => false]]);
}

/** 2.6.66: the numbers for each lit spot of one hand piece (i = hand index) or the set-aside group (i = c): see pfb_cell_preview. Read only; echoes JSON and exits. */
function pfight_cells_out(array $u, array $exp): void
{
    $out = function (array $o) { header('Content-Type: application/json'); header('Cache-Control: no-store'); echo json_encode($o); if (db()->inTransaction()) db()->rollBack(); exit; };
    $enc = json_decode((string)$exp['encounter'], true); $c = $enc ? encounter_creature($enc) : null; $s = $enc['pf'] ?? null;
    if (!$c || !is_array($s) || ($s['mode'] ?? '') !== 'board') $out(['ok' => false, 'err' => 'no fight']);
    if (!hash_equals((string)$s['nonce'], (string)($_POST['nonce'] ?? ''))) $out(['ok' => false, 'err' => 'stale']);
    if ((int)($_POST['turn'] ?? -1) !== (int)$s['turn']) $out(['ok' => false, 'err' => 'stale']);
    $s['me']['hp'] = min((int)$s['me']['max'], max(1, (int)$exp['hp']));
    $i = (string)($_POST['i'] ?? ''); if ($i !== 'c' && !ctype_digit($i)) $out(['ok' => false, 'err' => 'moves']);
    $o = ['ok' => true, 'cells' => (object)pfb_cell_preview($s, $i === 'c' ? 'c' : (int)$i)];
    if (!empty($s['v1']['flip']) && $i !== 'c') $o['flipped'] = (object)pfb_cell_preview($s, (int)$i, true);   // v1: the same numbers with the piece flipped (empty when it may not be flipped)
    $out($o);
}

function pfight_line(array $e, string $foe): string
{
    if (isset($e['env'])) return pfb_env_line($e, $foe);   // v1: a terrain event
    if (!empty($e['strike'])) return '💥 STRUCK: its ' . $e['n'] . ' hit your ' . ($e['mine'] ?? 'piece') . ' (' . (int)$e['hit'] . ')' . (!empty($e['broke']) ? ' and it breaks.' : ' but your guard ' . (int)$e['guard'] . ' holds.');   // 2.6.98 aimhit
    if (!empty($e['connect'])) return '🧩 You set ' . $e['n'] . ' aside, joined (' . (int)$e['size'] . ' pieces).';
    if (!empty($e['tick'])) return '🧪 The poison works on the ' . $foe . ' (+' . (int)$e['v'] . ').';
    if (isset($e['note'])) return match ($e['note']) { 'quick' => '⚡ ' . ($e['n'] !== '' ? $e['n'] . ': ' : '') . 'Quick. The ' . $foe . ' plays a second piece.', 'slow' => '⏳ The ' . $foe . ' loses its turn.', 'fade' => '🛡️ Your guard fades (-' . (int)$e['n'] . ') as your turn starts.', 'hold' => '🛡️ Hold: ' . (int)$e['n'] . ' guard stays up into your turn.', 'simmer' => '🍵 Simmer: you heal ' . (int)$e['n'] . ' as your turn starts.', 'current' => '🌊 The current pushes your ' . $e['n'] . ' one cell.', 'grows' => '🌿 The ' . $foe . ' grows a Bramble beside its piece.', 'venom' => '☠️ Venom: your ' . $e['n'] . ' poisons you (' . (int)($e['pv'] ?? 2) . ' a round, ' . (int)($e['pr'] ?? 2) . ' rounds).', 'drain' => '🩸 Drain: the ' . $foe . ' heals ' . (float)$e['n'] . ' from the hit.', 'stagger' => '💫 Stagger: the hit leaves you one piece short next round.', 'regrow' => '🌱 Regrow: the ' . $foe . ' heals ' . (float)$e['n'] . '.', 'plated' => '🛡️ Plated: the ' . $foe . ' starts its turn with ' . (int)$e['n'] . ' guard.', 'palaim' => '🐾 ' . (string)($e['pal'] ?? 'Your pal') . ' goes for the ' . $foe . '’s strongest piece: its ' . $e['n'] . ' is knocked off the board.', 'aoe' => pfb_aoe_line($e, $foe), default => '🦶 Tripped: you draw 1 fewer piece next turn.' };   // 2.6.76
    $who = $e['by'] === 'me' ? 'You play' : 'The ' . $foe . ' plays';
    if (!empty($e['ta']) && $e['ta'] !== $e['by'] && in_array($e['ta'], ['me', 'foe'], true) && in_array($e['by'], ['me', 'foe'], true)) $who = $e['ta'] === 'me' ? 'Your chain fires the ' . $foe . '’s' : 'The ' . $foe . '’s chain fires your';   // 2.6.76: a chain through the other side's piece
    elseif (($e['root'] ?? null) === false && in_array($e['by'], ['me', 'foe'], true)) $who = $e['by'] === 'me' ? 'Your chain fires your' : 'The ' . $foe . '’s chain fires its';   // after 2.6.96 (owner: "random plays"): a piece already on the board that fires in its own side's chain is not played again
    $bits = [];
    if (!empty($e['combo'])) $bits[] = '✨ ' . $e['combo'];
    if (!empty($e['fit'])) $bits[] = 'snug fit';
    if (!empty($e['cntr'])) $bits[] = '🎯 counter +' . PFB_COUNTER_ADD;   // 2.7.08 counter piece against its own class
    if (($e['pluck'] ?? '') === 'missed') return '🤏 You try to pluck something from the ' . $foe . ', but it notices.';
    if (($e['pluck'] ?? '') === 'none') return '🤏 You reach for the ' . $foe . ', but it has nothing to lift (or you already took something).';
    $tail = match ($e['t']) { 'hurt' => ($e['by'] === 'me' ? ' for ' . (int)($e['dmg'] ?? $e['v']) . ((int)($e['blocked'] ?? 0) > 0 ? ' (' . (int)$e['blocked'] . ' blocked by its guard)' : '') :' for ' . (int)($e['dmg'] ?? $e['v']) . ' damage'), 'guard' => ' (+' . (int)$e['v'] . ' guard)', 'heal', 'item' => (($e['by'] ?? '') === 'foe' && isset($e['healed']) ? ' (its yield bar back ' . (float)$e['healed'] . ')' : ' (+' . (int)$e['v'] . ' health)'), 'charm' => ' (' . (int)$e['v'] . ')', default => '' };
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

/** The creature's health (red, drains as Hurt lands) above the charm bar (the art frame, filled only by Charm); widths are set by assets/pfx.js from data-w (no inline styles). */
/** Your guard under your head: a blue bar with the number; the board page moves it as guard is built and attacks are blocked (assets/pfboard.js setGuard). */
function pfight_guard_html(int $g): string
{
    return '<span class="pf-guard' . ($g > 0 ? '' : ' pf-guard-0') . '" role="img" aria-label="Guard ' . $g . ': blocks the creature\'s hits until your next turn" title="Guard: blocks the creature\'s hits until your next turn"><span class="pfx-fill gfill" data-w="' . min(100, (int)pf_round($g * 100 / 16)) . '"></span><b>' . $g . '</b></span>';
}

/** The creature's guard beside its bars (v1 Josh 2.7.48: the player has one, the creature did not): same blue bar as yours; absorbs your Hurts and clears when its next turn begins. Dimmed at 0 like yours; the board page moves it with the replay (assets/pfboard.js setFoeGuard). */
function pfight_foeguard_html(int $g): string
{
    $lab = 'The creature\'s guard ' . $g . ': it soaks up your Hurt pieces first. It clears when its next turn starts.';
    return '<span class="pf-fguard' . ($g > 0 ? '' : ' pf-fguard-0') . '" role="img" aria-label="' . e($lab) . '" title="' . e($lab) . '"><span class="pfx-fill gfill" data-w="' . min(100, (int)pf_round($g * 100 / 16)) . '"></span><b>' . $g . '</b></span>';
}

function pfight_bar_html(array $v): string
{
    $b = $v['bar']; $max = max(0.1, (float)$b['max']); $now = (float)$b['now'];
    $fm = max(0.1, (float)$v['fh']['max']); $one = !empty($v['onebar']); $left = max(0.0, $fm - (float)$v['fh']['now'] - ($one ? (float)$v['bar']['now'] : 0.0)); $charmable = !empty($v['charmable']) && !$one;   // 2.6.95: one shared bar (above): there is no separate charm bar
    $hpLabel = 'Creature health: ' . (int)ceil($left) . ' of ' . (int)ceil($fm) . ' left. Hurt pieces take it down; at 0 it backs off.';
    if ($one) {   // T12 (2.6.95): one bar, a damage segment and a charm segment; the number is how full it is, the label says what each segment is
        $dm = max(0.0, (float)$v['fh']['now']); $ch = max(0.0, $now); $full = $dm + $ch; $okc = !empty($v['charmable']);
        $tot = (int)pf_round($full); $chn = (int)pf_round($ch); $dmn = max(0, $tot - $chn); $mx = (int)pf_round($fm);
        $head = PF_YIELD . ' ' . $tot . '/' . $mx . ': hurt ' . $dmn . ', charm ' . $chn;   // 'Yield 23/40' (the word is PF_YIELD, pfboard.php)
        $lab = PF_YIELD . ' ' . $tot . ' of ' . $mx . ': hurt ' . $dmn . ', charm ' . $chn . '. Hurt pieces and Charm pieces both fill the ' . PF_YIELD . ' bar. When it is full the creature yields' . ($okc ? ': more charm than hurt and you win it over, otherwise it backs off.' : ' and backs off (this one cannot be charmed).');
        return '<div class="pf-bars"><span class="pf-fhp pf-one" role="img" aria-label="' . e($lab) . '" title="' . e($head) . '"><span class="pfx-fill fhfill" data-w="' . pf_round(min(100.0, 100 * $dm / $fm), 1) . '"></span><span class="pfx-fill chfill" data-w="' . pf_round(min(100.0 - min(100.0, 100 * $dm / $fm), 100 * $ch / $fm), 1) . '"></span><b>' . $tot . '/' . $mx . '</b></span>' . pfight_foeguard_html((int)($v['foe']['block'] ?? 0)) . '</div>';
    }
    $h = '<div class="pf-bars">'
        . '<span class="pf-fhp" role="img" aria-label="' . e($hpLabel) . '" title="' . e('Creature health. Hurt pieces take it down; at 0 it backs off.') . '"><span class="pfx-fill fhfill" data-w="' . pf_round(100 * $left / $fm, 1) . '"></span><b>' . (int)ceil($left) . '</b></span>';
    if ($charmable) {
        $v1 = isset($v['v1']);   // 2.6.78: the v1 bar shows the engine's own number (one decimal) and is never drawn full before the fight is won (a bar a hair short of full looked full)
        $nowS = $v1 ? pf_round($now, 1) : $now; $pct = $v1 ? ($nowS >= $max ? 100.0 : min(96.0, floor(1000 * $nowS / $max) / 10)) : pf_round(100 * min(1.0, $now / $max), 1);
        $label = 'Charm bar: fill it to win the creature over for a better reward. Only Charm pieces fill it. ' . ($v1 ? $nowS . ' of ' . pf_round($max, 1) : (int)$now . ' of ' . (int)$max);
        if (!pfight_part('resolve-frame.png')) $h .= '<div class="pf-bar" role="img" aria-label="' . e($label) . '"><progress max="' . $max . '" value="' . $now . '"></progress></div>';
        else $h .= '<div class="pf-bar pfx-bar" role="img" aria-label="' . e($label) . '"><span class="pfx-fill charm" data-w="' . $pct . '"></span><img class="pfx-frame" src="' . e((string)pfight_part('resolve-frame.png')) . '" alt=""></div>';
    }
    return $h . pfight_foeguard_html((int)($v['foe']['block'] ?? 0)) . '</div>';
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
    $bar = 0.0; $fhs = 0.0; $guard = 0; $heal = 0; $dmg = 0; $types = [];
    foreach ($mine as $e) {
        $types[] = (string)$e['t'];
        if ($by === 'me') { $bar += (float)($e['bar'] ?? 0); $fhs += (float)($e['fh'] ?? 0); if ($e['t'] === 'guard') $guard += (int)$e['v']; if (in_array($e['t'], ['heal', 'item'], true)) $heal += (int)$e['v']; }
        else { $dmg += (int)($e['dmg'] ?? 0); if ($e['t'] === 'guard') $guard += (int)$e['v']; if ($e['t'] === 'heal') $heal += (int)$e['v']; }
    }
    $parts = [];
    if ($by === 'me') { if ($fhs > 0) $parts[] = '-' . (int)pf_round($fhs) . ' hp'; if ($bar > 0) $parts[] = '+' . (int)pf_round($bar) . ' charm'; if ($guard) $parts[] = '+' . $guard . ' guard'; if ($heal) $parts[] = '+' . $heal . ' hp'; }
    else { if ($dmg) $parts[] = '-' . $dmg . ' hp'; if ($guard) $parts[] = '+' . $guard . ' guard'; if ($heal) $parts[] = 'heals'; }
    return ['by' => $by, 'types' => $types, 'txt' => ($parts ? implode(' · ', $parts) : 'setup'), 'chain' => count($mine) > 1];
}

/** Board mode: one chip per piece placed (its whole chain), who placed it, the types that fired and what came of it. */
/** One history chip for one scored piece (board mode): who acted, what it did, how much, and who it landed on (tg: 'me' | 'foe' | null for setting aside); sn: the board snapshot for the rewind. Never null: the replay and the chips line up one to one. */
/** The creature bar as the page draws it after this event: health lost, plus (one shared bar, 2.6.95) the charm gained. */
function pfight_fhnow(array $e, bool $one)
{
    return !isset($e['fhnow']) ? null : ($one ? pf_round((float)$e['fhnow'] + (float)($e['barnow'] ?? 0), 1) : $e['fhnow']);
}

function pfight_chip_event(array $e, ?int $snap = null, bool $one = false): array
{
    $base = ['id' => isset($e['id']) ? (int)$e['id'] : null, 'sn' => $snap, 'bar' => $e['barnow'] ?? null, 'fh' => pfight_fhnow($e, $one), 'hp' => $e['hpnow'] ?? null, 'g' => $e['gnow'] ?? null, 'fg' => $e['fgnow'] ?? null, 'chain' => false];
    if (!empty($e['connect'])) return $base + ['by' => 'me', 'types' => $e['types'], 'tags' => [], 'txt' => 'joined ' . (int)$e['size'], 'tg' => null];
    if (isset($e['env'])) {   // v1: a terrain event (by 'env'): what it cost each side, or its name
        $parts = []; if (!empty($e['me'])) $parts[] = 'you -' . (int)$e['me'] . ' hp'; if (!empty($e['foe'])) $parts[] = $one ? PF_YIELD . ' +' . (int)pf_round((float)$e['foe']) : 'creature -' . (int)pf_round((float)$e['foe']) . ' hp';   // T12: one bar: it fills, nothing is 'health'
        return $base + ['by' => 'env', 'types' => ['env'], 'tags' => [(string)($e['kind'] ?? $e['env'])], 'txt' => (string)$e['n'] . ($parts ? ': ' . implode(' · ', $parts) : ''), 'tg' => !empty($e['me']) ? 'me' : (!empty($e['foe']) ? 'foe' : null)];
    }
    if (isset($e['note'])) return $base + ['by' => (string)$e['by'], 'types' => ['note'], 'tags' => [(string)$e['note']], 'txt' => match ($e['note']) { 'quick' => '⚡ Quick: plays 2', 'slow' => '⏳ loses its turn', 'fade' => '🛡️ guard fades -' . (int)$e['n'], 'hold' => '🛡️ Hold kept ' . (int)$e['n'], 'simmer' => '🍵 Simmer +' . (int)$e['n'], 'current' => '🌊 pushed ' . $e['n'], 'grows' => '🌿 grows a Bramble', 'venom' => '☠️ venom: poisoned', 'drain' => '🩸 drains ' . (float)$e['n'], 'stagger' => '💫 staggered: 1 fewer', 'regrow' => '🌱 regrows ' . (float)$e['n'], 'plated' => '🛡️ plated +' . (int)$e['n'], 'palaim' => '🐾 knocks off ' . $e['n'], 'aoe' => pfb_aoe_chip($e), default => '🦶 you draw 1 fewer' }, 'tg' => null];   // 2.6.76
    $parts = []; $tg = 'foe'; $by = (string)($e['by'] ?? 'me'); $t = (string)($e['t'] ?? 'hurt');
    if (!empty($e['tick'])) $parts[] = '-' . (int)$e['v'] . ' hp';
    elseif ($by === 'me') {
        $bar = (float)($e['bar'] ?? 0); $fh = (float)($e['fh'] ?? 0);
        if ($fh > 0) $parts[] = $one ? '+' . (int)pf_round($fh) . ' hurt' : '-' . (int)pf_round($fh) . ' hp';   // the creature's health (T12: one bar: damage that fills the bar)
        if ($bar > 0) $parts[] = '+' . (int)pf_round($bar) . ' charm';
        if ($t === 'hurt' && (int)($e['blocked'] ?? 0) > 0) $parts[] = (int)$e['blocked'] . ' blocked';   // 2.7.08: what its guard soaked
        if ($t === 'guard') { $parts[] = '+' . (int)$e['v'] . ' guard'; $tg = 'me'; }
        if (in_array($t, ['heal', 'item'], true)) { $parts[] = '+' . (int)$e['v'] . ' hp'; $tg = 'me'; }
    } else {
        $dmg = (int)($e['dmg'] ?? 0);
        if ($t === 'hurt') { $tg = 'me'; $parts[] = $dmg > 0 ? '-' . $dmg . ' hp' : (!empty($e['blocked']) ? 'blocked' : 'missed'); }
        elseif ($t === 'guard') $parts[] = '+' . (int)$e['v'] . ' guard';
        elseif (in_array($t, ['heal', 'item'], true)) $parts[] = '+' . (int)$e['v'] . ' hp';
    }
    if (!empty($e['combo'])) $parts[] = '✨' . $e['combo'];
    return $base + ['by' => $by, 'types' => [$t], 'tags' => [(string)($e['tag'] ?? '')], 'txt' => $parts ? implode(' · ', $parts) : (string)($e['n'] ?? 'piece'), 'tg' => $tg];
}

function pfight_chips_board(array $events): array
{
    $groups = []; $g = null;
    foreach ($events as $e) {
        if (!empty($e['tick']) || isset($e['env'])) continue;
        if (!empty($e['connect'])) { if ($g) $groups[] = $g; $g = null; $groups[] = [$e]; continue; }
        if (!empty($e['root'])) { if ($g) $groups[] = $g; $g = [$e]; } elseif ($g) $g[] = $e;
    }
    if ($g) $groups[] = $g;
    $chips = [];
    foreach ($groups as $g) {
        if (!empty($g[0]['connect'])) { $chips[] = ['by' => 'me', 'types' => $g[0]['types'], 'tags' => [], 'txt' => 'joined ' . (int)$g[0]['size'], 'chain' => false]; continue; }
        $by = (string)$g[0]['by']; $bar = 0.0; $fhs = 0.0; $guard = 0; $heal = 0; $dmg = 0; $types = []; $tags = [];
        foreach ($g as $e) {
            $types[] = (string)$e['t']; $tags[] = (string)($e['tag'] ?? '');
            if ($e['by'] === 'me') { $bar += (float)($e['bar'] ?? 0); $fhs += (float)($e['fh'] ?? 0); if ($e['t'] === 'guard') $guard += (int)$e['v']; if (in_array($e['t'], ['heal', 'item'], true)) $heal += (int)$e['v']; }
            else { $dmg += (int)($e['dmg'] ?? 0); }
        }
        $parts = [];
        if ($fhs > 0) $parts[] = '-' . (int)pf_round($fhs) . ' hp'; if ($bar > 0) $parts[] = '+' . (int)pf_round($bar) . ' charm'; if ($guard) $parts[] = '+' . $guard . ' guard'; if ($heal) $parts[] = '+' . $heal . ' hp'; if ($dmg) $parts[] = '-' . $dmg . ' hp';
        $chips[] = ['by' => $by, 'types' => $types, 'tags' => $tags, 'txt' => $parts ? implode(' · ', $parts) : 'setup', 'chain' => count($g) > 1];
    }
    return $chips;
}

/** The variant icon file name (without ico- and -s.png) of a tag, or null: a tagged piece shows it instead of its type icon. */
const PF_TAG_ICON = ['quick' => 'jab', 'heavy' => 'smash', 'pierce' => 'pierce', 'poison' => 'sting', 'trip' => 'trip', 'bash' => 'bash', 'hold' => 'brace', 'evade' => 'roll', 'thorns' => 'thornhide', 'mend' => 'mending', 'hum' => 'hum', 'lull' => 'lull', 'bond' => 'bond', 'pluck' => 'pluck'];

/** The fight card. No inline styles (CSP). assets/pfight.js reads data-* and builds the chain; the form posts once per chain. */
function pfight_html(array $u, array $exp, array &$enc, array $c): string
{
    $fresh = empty($enc['pf']);
    if ($fresh && pfight_v1_on($u) && !is_guest($u)) {   // 2.6.74 v1 (stage C): nothing is dealt until the gnome has packed a first box and pressed Let's fight on the pre-fight screen
        require_once __DIR__ . '/pfdeck_view.php';
        $first = pf_first_fight($u, $c) || !empty($enc['retry']);   // 2.7.01 fixed first fight: fight first, box later (no box, no pre-fight screen; the box is offered from the next fight); a free retry goes straight back in too
        if (!$first && !pfd_deck($u)['starter']) pfd_ensure_starter($u);   // 2.7.01: the same starter box for everyone, packed here when the gnome has none
        require_once __DIR__ . '/pfintro.php';   // 2.7.57: the 4-step intro, the first time (it does not hold the fight up)
        if (!$first && !pfd_deck($u)['starter']) return pfv_starter_html($u, pfd_deck($u), true) . pfv_assets() . pfi_card_html($u, 'adventure');
        if (!$first && empty($enc['pfgo'])) return pfv_prefight_html($u, $exp, $c) . pfi_card_html($u, 'adventure');
    }
    $s = pfight_state($u, $exp, $enc, $c);
    if ($fresh) {   // the hand you see must be the hand the server plays: write it only if the row is still exactly what this page read (compare-and-swap)
        $n = q("UPDATE expeditions SET encounter = ?, hp = ? WHERE id = ? AND status = 'active' AND encounter = ?", [json_encode($enc), (int)$exp['hp'], $exp['id'], (string)$exp['encounter']])->rowCount();   // hp: a learner fight starts at full health (pfight_state)
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
    return $h . '</div><link rel="stylesheet" href="' . e(url('assets/pfight.css?v=' . APP_VERSION)) . '"><script src="' . e(url('assets/pfight.js?v=' . APP_VERSION)) . '" data-rerun defer></script>';
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
    $h = '<div class="pfight pf-screen pf-boardmode' . (pfight_part('resolve-frame.png') ? ' pfx-art' : '') . (!empty($s['start']) ? ' pf-opening' : '') . (isset($v['v1']) ? ' pf-v1' : '') . (isset($v['v1']) && (!empty($enc['won']) || !empty($enc['lost'])) && !empty($enc['replay']) ? ' pfv-endwait' : '') . '" id="pfight" data-turn="' . (int)$v['turn'] . '" data-mode="board" data-redraws="' . (int)$v['redraws'] . '">';
    $mini = fn(string $cls, string $name, int $n) => '<span class="pfc-pile ' . $cls . '" role="img" aria-label="' . $name . ': ' . $n . ' pieces">' . (($pi = pfight_part($cls === 'deck' ? 'deck-book.png' : 'discard-bin.png')) ? '<img src="' . e($pi) . '" alt="">' : '<span aria-hidden="true">' . ($cls === 'deck' ? '📖' : '🗑️') . '</span>') . '<b>' . $n . '</b></span>';
    $h .= '@@TOP@@<div class="pfc-histrow"><ol class="pf-hist" aria-label="What has been played" aria-live="polite">';
    // the history bar IS the log: one chip per scored piece (actor, what it did, how much, who it landed on), the newest on the left, scrolling sideways; tap one to rewind the board to then.
    // this turn's chips are held back while the replay plays them in
    $g25 = function_exists('gnome25_url') ? gnome25_url($u, 'side') : ''; $cim0 = creature_image((string)($c['slug'] ?? ''), true); $foeSrc = ($cim0 !== '' && art_path($cim0) !== '') ? url($cim0) : null; $gnSrc = pfight_art('chip-gnome.png');
    $who = fn(string $by) => $by === 'env' ? '<span class="pfh-emo" aria-hidden="true">🌿</span>' : ($by === 'me' ? ($g25 !== '' ? '<span class="pfh-gn pfh-gn25" aria-hidden="true"><img src="' . e($g25) . '" alt=""></span>' : ($gnSrc ? '<img class="pfh-gn" src="' . e($gnSrc) . '" alt="">' : '<span class="pfh-emo" aria-hidden="true">🧙</span>')) : ($foeSrc ? '<img class="pfh-cr" src="' . e($foeSrc) . '" alt="">' : '<span class="pfh-emo" aria-hidden="true">👾</span>'));
    $hist = array_values((array)($enc['hist'] ?? [])); $nNew = (int)($enc['histnew'] ?? 0); $total = count($hist); $pending = !empty($enc['replay']); $snapsAll = (array)($enc['snaps'] ?? []); $usedSn = [];
    foreach (array_reverse(array_keys($hist)) as $hi) {
        $chip = $hist[$hi]; $evIdx = $hi - ($total - $nNew); $isNew = $nNew > 0 && $evIdx >= 0; $sn = isset($chip['sn']) && isset($snapsAll[(int)$chip['sn']]) ? (int)$chip['sn'] : null;
        if ($sn !== null) $usedSn[$sn] = $snapsAll[$sn];
        $nm = 'the ' . (string)$c['name']; $tgw = ($chip['tg'] ?? null) === 'me' ? 'you' : $nm;
        $label = (($chip['by'] ?? 'me') === 'me' ? 'You' : (($chip['by'] ?? '') === 'env' ? (!empty($v['v1']['env']) ? 'Environment' : 'Terrain') : ucfirst($nm))) . ': ' . implode(', ', array_map(fn($x) => (string)$x, (array)$chip['types'])) . ', ' . (string)$chip['txt'] . (($chip['tg'] ?? null) !== null ? ', on ' . $tgw : '') . ($sn !== null ? '. Press to see the board then.' : '');
        $h .= '<li class="pf-chip ' . ($chip['by'] === 'me' ? 'you' : ($chip['by'] === 'env' ? 'env' : 'foe')) . ($isNew ? ' pf-chip-new' : '') . ($sn !== null ? ' pf-chip-rw' : '') . '"' . ($isNew ? ' data-ev="' . $evIdx . '"' . ($pending ? ' hidden' : '') : '')
            . ($sn !== null ? ' data-sn="' . $sn . '" data-id="' . (int)($chip['id'] ?? 0) . '" data-bar="' . e((string)($chip['bar'] ?? '')) . '" data-fh="' . e((string)($chip['fh'] ?? '')) . '" data-g="' . e((string)($chip['g'] ?? '')) . '" data-fg="' . e((string)($chip['fg'] ?? '')) . '" data-hp="' . e((string)($chip['hp'] ?? '')) . '" role="button" tabindex="0"' : '') . ' aria-label="' . e($label) . '">'
            . $who((string)$chip['by']);
        foreach ((array)$chip['types'] as $ci => $t) {
            if (($chip['by'] ?? '') === 'env' || $t === 'note') continue;   // v1: a terrain chip has no piece type; nor has a notice (2.6.76)
            $tg = (string)($chip['tags'][$ci] ?? ''); $ti = isset(PF_TAG_ICON[$tg]) ? pfight_art('ico-' . PF_TAG_ICON[$tg] . '-s.png') : null;
            $h .= $ti ? '<img class="pfh-ico" src="' . e($ti) . '" alt="" title="' . e(ucfirst($tg)) . '">' : $sm((string)$t);
        }
        $h .= ' <span class="pfh-txt">' . e((string)$chip['txt']) . '</span>' . (($chip['tg'] ?? null) !== null ? $who((string)$chip['tg']) : '') . '</li>';
    }
    if (empty($enc['hist'])) $h .= '<li class="pf-chip empty">' . (!empty($s['start']) ? 'Opening: the blank ✦ is ' . (!empty($s['v1']) ? 'on the board' : 'in the middle') . '. The creature picks its side too, hidden.' : e((string)($enc['note'] ?? 'Pieces are on the board. Place one next to them.'))) . '</li>';
    $h .= '</ol><button type="button" class="btn" id="pf-skip" hidden>Skip</button><span class="pfc-piles">' . $mini('deck', 'Puzzle book', (int)$v['piles']['draw']) . $mini('disc', 'Discard', (int)$v['piles']['discard']) . '</span></div>';
    $cim = creature_image((string)($c['slug'] ?? ''), true);
    $foeImg = $cim !== '' ? art_img($cim, 'lg', (string)$c['name']) : creature_icon((string)$c['name'], (string)$c['size']);
    $vb = $v; $r0 = isset($v['v1']) && $pending && is_array($enc['replay0'] ?? null) ? $enc['replay0'] : null;   // a v1 turn that waits for its replay is drawn with the bars as they stood BEFORE it (the page script walks them to the new values step by step; it sets the new ones at once when it does not replay)
    if ($r0) { $vb['bar']['now'] = (float)$r0['bar']; $vb['fh']['now'] = (float)$r0['fh'] - (!empty($v['onebar']) ? (float)$r0['bar'] : 0.0); $vb['hp'] = (int)$r0['hp']; $vb['block'] = (int)$r0['g']; if (isset($r0['fg'])) $vb['foe']['block'] = (int)$r0['fg']; }
    $top = '<div class="pfc-top"><div class="pfc-me"><span class="pfc-meav"><span class="pfc-av' . ($g25 !== '' ? ' pfc-g25' : '') . '">' . ($g25 !== '' ? '<img src="' . e($g25) . '" alt="' . e(gnome_name($u)) . '">' : gnome_avatar_pals($u, 60)) . '</span>' . pfight_guard_html((int)$vb['block']) . '</span><span class="pf-hp" role="img" aria-label="Your health ' . (int)$vb['hp'] . ' of ' . (int)$v['max'] . '">❤️ <progress max="' . (int)$v['max'] . '" value="' . (int)$vb['hp'] . '"></progress> ' . (int)$vb['hp'] . '</span></div>'
        . pfight_bar_html($vb)
        . '<div class="pfc-foe"><span class="pfc-fname"><b>' . e((string)$c['name']) . '</b><small>lv ' . (int)$c['level'] . ' · ' . ($s['temper'] === 'gentle' ? 'gentle' : 'wary') . ' · 🃏 ' . (int)$v['foe']['hand'] . ($v['foe']['calm'] ? ' · 😌 ' . (int)$v['foe']['calm'] : '') . '</small></span><span class="pfc-av">' . $foeImg . '<span class="pf-intent-bubble" title="Likely next move" aria-label="Likely next move: ' . e((string)$v['foe']['intent']) . '">' . $sm((string)$v['foe']['intent']) . '</span></span></div></div>';
    $h = str_replace('@@TOP@@', $top, $h);
    $h .= '<div class="pf-rewind" id="pf-rewind" role="status" hidden><span id="pf-rw-t"></span><button type="button" class="btn" id="pf-rw-back">Back to now</button></div>';
    if (isset($v['v1'])) $h .= pf_new_today_html($s);   // 2.7.01: "New today" on the first turn of the first full-rules fight
    if (isset($v['v1'])) $h .= '<div class="pfv-row" id="pfv-row"></div>';   // v1 (stage C): turn order, chain dots, Teamwork, the aim, the forecast and what waits on each side (assets/pfboardv1.js fills it)
    $h .= '<div class="pfb-board" id="pfb-board" role="group" aria-label="The play area: pick a piece from your hand, then a lit spot. Scroll, pinch or use the zoom buttons to zoom"></div>';   // JS draws the pieces from #pf-data
    if (isset($v['v1'])) $h .= '<div class="pfv-legend" id="pfv-legend" role="group" aria-label="' . (!empty($v['v1']['env']) ? 'The environment: its next pieces' : 'Terrain legend') . '"></div>';
    $h .= '<div class="pf-opts" id="pf-opts" hidden></div>';
    $h .= '<p class="pf-preview help" id="pf-preview" aria-live="polite">Pick a piece, then a lit spot. Up to 4 a turn; the newest plays first.</p>';
    $h .= '<ol class="pf-plan" id="pf-plan" aria-live="polite" hidden></ol>';
    $h .= '<form method="post" class="pf-form" id="pf-form">' . csrf_field() . '<input type="hidden" name="do" value="pfb_play"><input type="hidden" name="nonce" value="' . $nonce . '"><input type="hidden" name="turn" value="' . (int)$v['turn'] . '"><input type="hidden" name="moves" id="pf-moves" value=""></form>';
    $won = !empty($enc['won']) && in_array($s['over'], ['seen_off', 'charmed'], true);
    $lost = isset($v['v1']) && !empty($enc['lost']) && in_array($s['over'], ['defeat', 'stall'], true);   // 2.6.78: a lost v1 fight waits for its Continue button, after the replay
    if ($lost) {
        require_once __DIR__ . '/pfdeck_view.php';
        $retry = $s['over'] === 'defeat' && pf_retry_ok((int)$u['id']);   // 2.7.01 free retry in the first fights
        $h .= pfv_result_html(['how' => (string)$s['over'], 'name' => (string)$c['name'], 'slug' => (string)($c['slug'] ?? ''), 'size' => (string)($c['size'] ?? 'small'), 'hp' => $s['over'] === 'defeat' ? 0 : (int)$v['hp'], 'max' => (int)$v['max'], 'turns' => (int)$v['turn'], 'wear' => pfv_wear_rows($u, $s), 'learn' => !empty($s['learn']), 'recap' => $s['over'] === 'defeat' ? pf_loss_line((array)($enc['loss'] ?? []), (string)$c['name']) : ''],
            ($retry ? '<form method="post" class="grow pf-endform">' . csrf_field() . '<input type="hidden" name="do" value="pf_retry"><input type="hidden" name="nonce" value="' . $nonce . '"><button class="btn primary" id="pf-retry">🔁 Try again</button></form>' : '')
            . '<form method="post" class="grow pf-endform">' . csrf_field() . '<input type="hidden" name="do" value="pf_finish"><input type="hidden" name="nonce" value="' . $nonce . '"><button class="btn' . ($retry ? '' : ' primary') . '" id="pf-end">' . ($s['over'] === 'defeat' && empty($s['learn']) ? '🏠 Go home to rest' : 'Continue') . '</button></form>');
        $h .= '<button type="button" class="btn" id="pf-undo" hidden></button><button class="btn" id="pf-go" form="pf-form" hidden></button>';
    } elseif ($won && isset($v['v1'])) {   // v1 (stage C): the result card (win or charm, tool wear, a link to the box) with the End fight button
        require_once __DIR__ . '/pfdeck_view.php';
        $h .= pfv_result_html(['how' => (string)$s['over'], 'name' => (string)$c['name'], 'slug' => (string)($c['slug'] ?? ''), 'size' => (string)($c['size'] ?? 'small'), 'hp' => (int)$v['hp'], 'max' => (int)$v['max'], 'turns' => (int)$v['turn'], 'wear' => pfv_wear_rows($u, $s)],
            '<form method="post" class="grow pf-endform">' . csrf_field() . '<input type="hidden" name="do" value="pf_finish"><input type="hidden" name="nonce" value="' . $nonce . '"><button class="btn primary" id="pf-end">🎁 Collect the reward</button></form>');
        $h .= '<button type="button" class="btn" id="pf-undo" hidden></button><button class="btn" id="pf-go" form="pf-form" hidden></button>';
    } elseif ($won) {
        $h .= '<div class="pf-won" role="status"><b>' . ($s['over'] === 'charmed' ? 'The ' . e((string)$c['name']) . ' is charmed!' : 'The ' . e((string)$c['name']) . ' has had enough.') . '</b> <form method="post" class="inline pf-endform">' . csrf_field() . '<input type="hidden" name="do" value="pf_finish"><input type="hidden" name="nonce" value="' . $nonce . '"><button class="btn primary" id="pf-end">End fight</button></form></div>';
        $h .= '<button type="button" class="btn" id="pf-undo" hidden></button><button class="btn" id="pf-go" form="pf-form" hidden></button>';
    } else {
        $h .= '<div class="pf-buttons"><a class="btn pf-box" href="' . e(url('puzzlebox.php')) . '" title="Your puzzle box" aria-label="Puzzle box">🧩</a><button type="button" class="btn" id="pf-undo" disabled>Undo</button><button class="btn primary" id="pf-go" form="pf-form" disabled>' . (!empty($s['start']) ? 'Confirm start' : 'End turn') . '</button>'
            . (isset($v['v1']) && empty($s['start']) && pf_hint_n() > 0 ? '<button type="button" class="btn pfv-hintb" id="pf-hint" title="A free hint: the spot a careful player would pick, from what you can see" aria-label="Hint: light the spot a careful player would pick (free; hints left in this fight shown)">💡<small>' . max(0, pf_hint_n() - (int)($enc['hints'] ?? 0)) . '</small></button>' : '')   // 2.7.01
            . (isset($v['v1']) && !empty($v['flip']['on']) ? '<button type="button" class="btn pfv-flipb" id="pf-flip" disabled aria-label="Flip: swap the top and bottom edges of the piece you picked (' . (!empty($v['v1']['flip1']) ? 'once a turn, free' : 'free, as often as you like') . ')">⇅ Flip</button>' : '')
            . ($v['can_run'] && !$s['over'] ? '<form method="post" class="inline pf-runf">' . csrf_field() . '<input type="hidden" name="do" value="pf_run"><input type="hidden" name="nonce" value="' . $nonce . '"><button class="btn" title="Run away" aria-label="Run away">🏃</button></form>' : '') . '</div>';
    }
    $h .= '<div class="pf-tray"><div class="pf-hand" id="pf-hand" role="group" aria-label="Your hand">';
    foreach ($v['hand'] as $i => $t) $h .= pfight_board_piece_html($t, $i, isset($v['v1']));
    $h .= '</div></div>';
    $h .= '<div class="pf-inspect" id="pf-inspect" aria-live="polite" hidden><span class="pfi-art" id="pfi-art" aria-hidden="true"></span><span class="pf-itext"><b id="pfi-name"></b><br><span id="pfi-desc"></span></span><button type="button" class="pfi-x" id="pfi-x" aria-label="Close">✕</button></div>';
    $seen = array_values(array_unique(array_filter(array_column($v['hand'], 'tag'), fn($x) => isset(PF_TAGS[$x]))));
    $more = '';
    if ($seen) { $more .= '<ul class="pf-tags help">'; foreach ($seen as $x) $more .= '<li>' . PF_TAGS[$x][0] . ' ' . e(PF_TAGS[$x][1]) . '</li>'; $more .= '</ul>'; }
    $h .= '<div class="pf-extra">';
    $h .= '<form method="post" class="inline" id="pf-pform" hidden>' . csrf_field() . '<input type="hidden" name="do" value="pfb_pass"><input type="hidden" name="nonce" value="' . $nonce . '"><input type="hidden" name="turn" value="' . (int)$v['turn'] . '">' . (!empty($v['v1']['freepass']) ? '' : '<button class="btn" id="pf-pass">Pass (nothing fits)</button>') . '</form>';   // T12: with a free pass the End turn button says Pass (nothing placed) and posts this form (assets/pfboardv1.js); no second button
    $h .= '<form method="post" class="inline" id="pf-rform" hidden>' . csrf_field() . '<input type="hidden" name="do" value="pf_redraw"><input type="hidden" name="nonce" value="' . $nonce . '"><input type="hidden" name="turn" value="' . (int)$v['turn'] . '"><input type="hidden" name="card" id="pf-card" value=""></form>';
    if ($v['redraws'] > 0) $h .= '<small class="muted">🍀 ' . (int)$v['redraws'] . ' redraw' . ($v['redraws'] > 1 ? 's' : '') . '</small> <button type="button" class="btn" id="pf-redraw" hidden>Redraw a piece</button>';
    if (isset($v['v1'])) $h .= '<form method="post" class="inline" id="pf-fform" hidden>' . csrf_field() . '<input type="hidden" name="do" value="pfb_flip"><input type="hidden" name="nonce" value="' . $nonce . '"><input type="hidden" name="turn" value="' . (int)$v['turn'] . '"><input type="hidden" name="hand" id="pf-fhand" value=""></form>';
    $h .= '</div>';
    if ($more !== '') $h .= '<details class="pfc-more"><summary>More: piece tips and the last turn</summary>' . $more . '</details>';
    // the board and the hand's edges for the script (public information: the board is out in the open)
    $data = ['start' => !empty($s['start']), 'foe' => (string)$c['name'], 'won' => ($won || $lost) ? (string)$s['over'] : null, 'life' => PFB_LIFE, 'tags' => isset($v['v1']) ? PF_TAGS_V1 : PF_TAGS, 'held' => $v['held'] ?? null, 'gone' => $v['gone'] ?? [], 'snaps' => (object)$usedSn, 'bar' => $v['bar']['now'], 'barmax' => $v['bar']['max'], 'fh' => pf_round($v['fh']['now'] + (!empty($v['onebar']) ? $v['bar']['now'] : 0), 1), 'fhmax' => $v['fh']['max'], 'charmable' => !empty($v['charmable']), 'hp' => $v['hp'], 'guard' => (int)$v['block'], 'fguard' => (int)($v['foe']['block'] ?? 0), 'replay' => $enc['replay'] ?? [], 'replay0' => $enc['replay0'] ?? null, 'mods' => array_map(fn($m) => [$m[1], $m[0], (int)$m[3], $m[2]], PF_MODS), 'art' => url('assets/img/pfight/'), 'fx' => $v['fx'] ?? [], 'tint' => (int)(crc32((string)($c['slug'] ?? $c['name'] ?? '')) % 360), 'parts' => isset($v['v1']) ? pfight_parts_url() : (is_file(__DIR__ . '/../assets/img/pfight/parts/atlas.json') ? url('assets/img/pfight/parts/') : null), 'w' => $v['w'], 'h' => $v['h'], 'pcs' => $v['pcs'], 'hand' => array_map(fn($t) => ['e' => $t['e'], 't' => $t['t'], 'tag' => $t['tag'], 'm' => $t['m']], $v['hand']), 'combos' => $v['combos'], 'pico' => url('assets/img/pfight/pieces/'), 'icons' => ['hurt' => '⚔️', 'guard' => '🛡️', 'heal' => '💚', 'charm' => '🌸', 'soothe' => '😌', 'trick' => '🎭', 'item' => '🎒']];
    if (isset($v['v1'])) {   // the v1 board rules: ground, forecast, the creature's aim, flip, piece life (pfb_view); the page script for them is stage C
        foreach (['v1', 'round', 'ter', 'envs', 'envlog', 'aim', 'reaim', 'flip'] as $k) $data[$k] = $v[$k];
        $data['cslug'] = (string)($c['slug'] ?? '');   // 2.7.55 piece effects (assets/pfanim.js): the creature's themed look in assets/pfanim-data.json is keyed by its slug (page data only)
        $data['yieldw'] = PF_YIELD;   // the word for the creature's bar in a new-rule fight, read by the board script (assets/pfboardv1.js); a flag-off page does not carry it
        foreach (['kind', 'grudge', 'ven', 'aoe'] as $k) if (isset($v[$k])) $data[$k] = $v[$k];   // 2.6.98 class rules: the rule chip, the Beast's stacks, the venom cells
        foreach (['status', 'wear', 'env'] as $k) if (isset($v[$k])) $data[$k] = $v[$k];   // 2.6.74 deck model: what waits on each side (creature tags), tool wear so far
        foreach ($v['hand'] as $i => $t) $data['hand'][$i] += ['life' => $t['life'], 'src' => $t['src'], 'flip' => $t['flip'], 'canflip' => $t['canflip']];
        // stage C (the v1 page script, assets/pfboardv1.js): the state before the last turn for the replay, the fight tools (durability left before this fight), whose piece is a tool piece, the box link
        foreach ($v['hand'] as $i => $t) $data['hand'][$i] += ['tool' => (string)($t['tool'] ?? ''), 'rank' => (int)($t['rank'] ?? 0)];
        $data['prev'] = !empty($enc['replay']) ? ($enc['prev'] ?? null) : null;
        $data['tripped'] = (int)($s['me']['tripped'] ?? 0);   // 2.6.76: you drew one fewer this turn
        if ((int)$s['turn'] === 1 && empty($s['start'])) $data['opened'] = count(array_filter($s['pcs'], fn($p) => $p['by'] === 'foe'));   // the creature's opening pieces
        $data['costwarn'] = pf_cost_warn((int)$u['id']);   // 2.7.01: End turn asks once before a move that costs health (first fights)
        $data['guide'] = pf_guide_on((int)$u['id']);   // 2.7.01 guided first turns (the script shows them on the opening and turns 1-2)
        $data['hints'] = max(0, pf_hint_n() - (int)($enc['hints'] ?? 0)); $data['hintmax'] = pf_hint_n();   // 2.7.01 the Hint button: free hints left in this fight
        $st = setting('pfight_stall_turn'); $data['stall'] = $st === '' ? 8 : max(0, (int)$st);   // 2.7.01 the stall nudge: from this turn while the bar is under half (0 = never)
        $data['box'] = url('puzzlebox.php'); $data['turncap'] = PF_TURN_CAP; $data['toolwear'] = PFB_TOOL_WEAR; $data['fires'] = PFB_FOE_FIRES;
        $data['tools'] = (object)[];
        if (!empty((array)$v['wear']) || array_filter(array_column($data['hand'], 'tool'))) {
            require_once __DIR__ . '/pfdeck.php'; $tw = [];
            foreach (pfd_wear($u) as $type => $w) if ((int)$w['tier'] > 0 && isset(pfd_catalog()['t:' . $type])) $tw[$type] = ['n' => (string)pfd_catalog()['t:' . $type]['n'], 'left' => (int)$w['left'] + (!empty($enc['wearsaved']) ? (int)(((array)$v['wear'])[$type] ?? 0) : 0), 'max' => (int)$w['max']];
            $data['tools'] = (object)$tw;
        }
    }
    $h .= '<script type="application/json" id="pf-data">' . json_encode($data, JSON_HEX_TAG | JSON_HEX_AMP) . '</script>';
    if (isset($v['v1'])) { require_once __DIR__ . '/pfintro.php'; $h .= pfi_card_html($u, 'adventure', true); }   // 2.7.57: the intro card (open the first time, hidden after: the help sheet opens it again)
    return $h . '</div><link rel="stylesheet" href="' . e(url('assets/pfight.css?v=' . APP_VERSION)) . '"><script src="' . e(url('assets/pfx.js?v=' . APP_VERSION)) . '" data-rerun defer></script><script src="' . e(url('assets/' . (isset($v['v1']) ? 'pfparts47.js' : 'pfparts.js') . '?v=' . APP_VERSION)) . '" data-rerun defer></script>' . (isset($v['v1']) ? '<link rel="stylesheet" href="' . e(url('assets/pfv1.css?v=' . APP_VERSION)) . '"><script src="' . e(url('assets/pfv1box.js?v=' . APP_VERSION)) . '" data-rerun defer></script><script src="' . e(url('assets/pfanim.js?v=' . APP_VERSION)) . '" data-rerun defer></script><script src="' . e(url('assets/pfboardv1.js?v=' . APP_VERSION)) . '" data-rerun defer></script>'   // v1 (stage C): its own board script (a fork of pfboard.js), so the old one stays as it is
        : '<script src="' . e(url('assets/pfboard.js?v=' . APP_VERSION)) . '" data-rerun defer></script>');
}

/** A hand piece in board mode: a button with its four edges drawn as marks. */
function pfight_board_piece_html(array $t, int $i, bool $v1 = false): string
{
    $tg = PF_TAGS[(string)($t['tag'] ?? '')] ?? null; $md = PF_MODS[(string)($t['m'] ?? '')] ?? null;
    $tw = $v1 ? (PF_TAGS_V1[(string)($t['tag'] ?? '')] ?? $tg) : $tg;   // 2.6.96: the v1 pages read the new words (the old pages stay as they were)
    if ($v1 && $md && isset(PF_MODS_V1[(string)$t['m']])) $md[2] = PF_MODS_V1[(string)$t['m']];
    $ed = ''; foreach (['L', 'R', 'T', 'B'] as $side) $ed .= pfight_edge_span($t['e'][$side], $side);
    $label = $t['n'] . ', ' . ucfirst($t['t']) . ' ' . $t['v'] . '; edges: ' . implode(', ', array_map(fn($sd) => $sd . ' ' . ($t['e'][$sd][0] === 'flat' ? 'flat' : $t['e'][$sd][0] . ' ' . $t['e'][$sd][1]), ['L', 'R', 'T', 'B'])) . ($tg ? '; ' . $tg[1] : '') . ($md ? '; upgrade ' . $md[0] . ': ' . $md[2] : '');
    $desc = ucfirst($t['t']) . ' ' . (int)$t['v'] . ($v1 ? ': ' . pf_type_text((string)$t['t'], (int)$t['v']) : '') . ($tw ? '. ' . $tw[1] : '') . ($md ? '. Upgrade ' . $md[0] . ': ' . $md[2] : '');
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
        "Fights are played with [b]tiles[/b]. You start with 5 in hand and draw 3 each turn (never above 5). Tap up to 4 tiles in the order you want them, then play the chain. The creature answers with a chain of its own, and a full chain of four gives it one more move.\n\n[b]Types:[/b] ⚔️ Hurt, 🛡️ Guard, 💚 Heal, 🌸 Charm, 😌 Soothe, 🎭 Trick, 🎒 Item. Numbers grow with your stats and level.\n\n[b]Sockets:[/b] each tile has a hole on the left and a knob on the right in one of three families (B Body, M Mind, C Craft). A knob that matches the next tile's hole is a [b]snug fit[/b]: a little extra value. A poor fit still works; it only skips the bonus.\n\n[b]Two ways to win:[/b] every creature has health. Hurt takes it down, and at 0 it backs off. Gentle creatures also have a charm bar that only Charm fills; fill it and the creature is won over, which leaves a gift. Whichever happens first ends the fight. Great creatures cannot be charmed.\n\n[b]Run[/b] always works except against the great ones, and costs nothing.\n\n[b]The Puzzle box:[/b] you do not bring every tile you own. Your box holds a limited number (8 at the start, one more every 3 levels, 14 at most), so choose. Open it from the fight card or the My Gnome page. A change applies from your next fight."],
    'Hurt tiles' => ['pfight:tiles', 'Play a Hurt tile with a tactic.',
        "Hurt tiles differ by [b]how[/b] they hit, not only how hard.\n\n⚡ [b]Jab[/b] (Quick): draws you a tile when played.\n📌 [b]Pierce[/b]: ignores the creature's guard.\n🧪 [b]Sting[/b] (Poison): keeps working for 2 more turns.\n🪢 [b]Trip[/b]: the creature plays one tile fewer next turn.\n🛡️ [b]Shield Bash[/b]: adds the guard you built earlier in the chain to the hit.\n🪨 [b]Smash[/b] (Heavy): a big blow that has to go last in a chain.\n\nThey unlock as your gnome grows: Jab at level 5, Pierce 8, Trip 11, Sting 13, Bash 14, Smash 16. Gentle creatures take Hurt at half strength; Charm suits them better."],
    'Defence and Charm tiles' => ['pfight:tiles2', 'Play a guard or charm tile with a tactic.',
        "Guards and Charms differ by how they work too.\n\n[b]Guards:[/b] ⚓ [b]Brace[/b] lasts through your next turn. 💨 [b]Roll[/b] makes the creature's first Hurt next turn miss completely. 🌵 [b]Thorn Hide[/b] pricks the creature when it hits your guard. 🩹 [b]Mending[/b] heals you 2.\n\n[b]Charms:[/b] 🎵 [b]Hum[/b] also calms the creature. 🌙 [b]Lull[/b] makes it play a tile fewer. 🤝 [b]Bond[/b] warms it to Charm for the rest of the fight (up to three times).\n\n[b]Stealing:[/b] 🤏 [b]Pluck[/b] is a Trick with a small chance to lift an item the creature could drop. Luck raises the chance, a legendary creature is harder to rob, and you can lift one thing a fight."],
    'Puzzle upgrades' => ['pfight:mods', 'Finish a puzzle to earn an upgrade.',
        "Finishing a puzzle in [b]any game and any mode[/b] can earn a [b]Puzzle upgrade[/b]: a secondary effect for one of your tiles. Open your Puzzle box and choose one of three. A bigger puzzle gives rarer upgrades.\n\nYou can earn [b]3 a day[/b] (a new day starts at midnight, server time), and up to 3 can wait unopened. Each tile holds one upgrade; it stays until you remove it, or choose another for the same tile.\n\n🧲 Sticky, 🪶 Swift, 🧱 Hardy, 💗 Tender are common. 🩸 Leech, 🦔 Spiky, 🪽 Soft touch are uncommon. 🔥 Warm, 🎯 Finisher, 🍀 Lucky, ⚖️ Steady are rare."],
    'Ambush' => ['pfight:combo:trick>hurt', 'Have a Trick and a Hurt in the same chain.', "🎭 and ⚔️ in one chain, in any order: the Hurt counts one and a half times, plus the Trick's own value."],
    'Riposte' => ['pfight:combo:guard>hurt', 'Have a Guard and a Hurt in the same chain.', "🛡️ and ⚔️ in one chain, in any order: the Hurt counts one and a half times."],
    'Double Swing' => ['pfight:combo:hurt>hurt', 'Have two Hurts in the same chain.', "⚔️ and ⚔️ in one chain: the one that fires second gets +2."],
    'Calm Charm' => ['pfight:combo:soothe>charm', 'Have a Soothe and a Charm in the same chain.', "😌 and 🌸 in one chain, in any order: the Charm counts one and a half times."],
    'Win Over' => ['pfight:combo:charm>item', 'Have a Charm and an Item or Snack in the same chain.', "🌸 and 🎒 in one chain, in any order: the offering also fills part of the charm bar."],
    'Bait' => ['pfight:combo:trick>guard', 'Have a Trick and a Guard in the same chain.', "🎭 and 🛡️ in one chain, in any order: the Guard gets the Trick's value added."],
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
