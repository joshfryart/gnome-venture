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

/** The player side of a fight: stats modifiers, deck (gnome six + calling tile + pals), HP carried in the expedition. */
function pfight_me(array $u, array $exp): array
{
    $st = ['level' => (int)$u['level']];
    foreach (['grit', 'nimble', 'hardiness', 'charm', 'lore', 'luck'] as $k) $st[$k] = eff_mod($u, $k);
    $pals = [];
    if (function_exists('ppal_equipped') && setting('ppal_party') === '1') $pals = pfight_pal_tiles($u);
    $deck = pf_player_deck($st, (string)($u['calling'] ?? ''), max(1, min(3, (int)calling_tier($u))), $pals);
    return ['hp' => max(1, (int)$exp['hp']), 'max_hp' => (int)$exp['max_hp'], 'stats' => $st, 'deck' => $deck, 'luck' => max(0, $st['luck'] * 2)];
}

/** Pal tiles: each equipped pal swaps in for one gnome tile; the tile comes from its calling and rarity (placeholder mapping until the pal tile table is authored). */
function pfight_pal_tiles(array $u): array
{
    $out = [];
    $swapFor = ['guard' => 'dodge', 'hurt' => 'swing', 'heal' => 'rest', 'charm' => 'charm'];
    $byCalling = ['rootwarden' => 'guard', 'thornblade' => 'hurt', 'brewroot' => 'heal', 'bloomcaller' => 'charm', 'seedkeeper' => 'heal', 'wayfinder' => 'guard'];
    foreach (array_slice((array)ppal_equipped($u), 0, 2) as $p) {
        $t = $byCalling[(string)($p['calling'] ?? '')] ?? 'hurt';
        $out[] = ['swap' => $swapFor[$t], 'n' => (string)($p['name'] ?? 'Pal'), 't' => $t, 'v' => 5 + (int)($p['rarity'] ?? 0), 'r' => ['hurt' => 'mind', 'guard' => 'craft', 'heal' => 'body', 'charm' => 'body'][$t]];
    }
    return $out;
}

/** The fight state inside the encounter ($enc['pf']); created on first sight. Returns the state (also stored in $enc). */
function pfight_state(array $u, array $exp, array &$enc, array $c): array
{
    if (empty($enc['pf'])) $enc['pf'] = pf_new(pfight_me($u, $exp), $c, random_int(1, 0x7FFFFFFE));
    return $enc['pf'];
}

/** One POST: 'pf_play' (chain = "2,0,3", turn), 'pf_run', 'pf_redraw' (card = index). The caller holds the transaction and has locked the gnome. Returns true when the fight ended. */
function pfight_do(array $u, array &$exp, string $do): bool
{
    $enc = json_decode((string)$exp['encounter'], true);
    $c = encounter_creature($enc);
    if (!$c) return false;
    $s = pfight_state($u, $exp, $enc, $c);
    $hp0 = (int)$s['me']['hp'];
    $snackUsed = 0;
    if ($do === 'pf_run') {
        if (!pf_run($s)) { flash('You cannot run from this one.', 'err'); return false; }
    } elseif ($do === 'pf_redraw') {
        if (!pf_redraw($s, (int)($_POST['card'] ?? -1))) flash('No redraws left this turn.', 'err');
    } elseif ($do === 'pf_play') {
        $idx = array_map('intval', array_filter(explode(',', (string)($_POST['chain'] ?? '')), 'strlen'));
        $left = function_exists('snacks_left') ? snacks_left($u, $enc) : 0;
        $snacks = fight_snacks($u);
        $want = 0;
        $r = pf_play($s, $idx, (int)($_POST['turn'] ?? -1), function (array $t) use (&$want, $left, $snacks) {
            if ($t['tag'] !== 'snack') return null;
            if (++$want > min($left, count($snacks) ? array_sum(array_column($snacks, 'qty')) : 0)) return 'You have no snack to eat' . ($left <= 0 ? ' (snack limit reached this fight).' : '.');
            return null;
        });
        if ($r['err'] === 'stale') { $exp['encounter'] = json_encode($enc); return false; }   // double tap or an old page: nothing happens
        if ($r['err']) { flash($r['err'], 'err'); return false; }
        $snackUsed = $want;
        foreach ($r['ev'] as $e) exp_log($exp, pfight_line($e, (string)$c['name']));
        for ($i = 0; $i < $snackUsed; $i++) {   // eat the real snacks (the first one in the list that is left)
            foreach (fight_snacks($u) as $sn) if (give_item((int)$u['id'], (int)$sn['id'], -1)) { $enc['snacks'] = (int)($enc['snacks'] ?? 0) + 1; break; }
        }
    } else return false;
    $exp['hp'] = (int)$s['me']['hp'];
    $enc['pf'] = $s;
    $exp['encounter'] = json_encode($enc);
    switch ($s['over']) {
        case 'seen_off': case 'charmed':
            $charm = $s['over'] === 'charmed';
            exp_log($exp, $charm ? '🌸 The ' . $c['name'] . ' calms down and takes to you.' : '🏆 You see off the ' . $c['name'] . '.');
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
    if ($fresh) q('UPDATE expeditions SET encounter = ? WHERE id = ?', [json_encode($enc), $exp['id']]);   // the hand you see must be the hand the server plays
    $v = pf_view($s);
    $h = '<div class="pfight" id="pfight" data-turn="' . (int)$v['turn'] . '" data-open="' . e((string)($v['open'] ?? '')) . '" data-opent="' . e($v['strip'] ? (string)end($v['strip'])['t'] : '') . '" data-redraws="' . (int)$v['redraws'] . '">';
    $h .= '<div class="pf-foe"><b>' . e((string)$c['name']) . '</b> <small class="muted">' . e((string)$c['size']) . ' · lv ' . (int)$c['level'] . ' · ' . ($s['temper'] === 'gentle' ? 'gentle' : 'wary') . '</small>';
    $h .= '<div class="pf-bar" role="img" aria-label="Resolve ' . (int)$v['bar']['now'] . ' of ' . (int)$v['bar']['max'] . '"><progress max="' . (float)$v['bar']['max'] . '" value="' . (float)$v['bar']['now'] . '"></progress></div>';
    $h .= '<small>🃏 ' . (int)$v['foe']['hand'] . ' · next: <span class="pf-intent">' . e(pfight_icon((string)$v['foe']['intent'])) . ' ' . e((string)$v['foe']['intent']) . '</span>' . ($v['foe']['calm'] ? ' · 😌 calm ' . (int)$v['foe']['calm'] : '') . '</small></div>';
    $h .= '<div class="pf-strip" aria-live="polite" aria-label="The last tiles played">';
    foreach ($v['strip'] as $t) $h .= pfight_tile_html($t, true);
    if (!$v['strip']) $h .= '<small class="muted">Nothing played yet. You go first.</small>';
    $h .= '</div>';
    $h .= '<div class="pf-me">❤️ <progress max="' . (int)$v['max'] . '" value="' . (int)$v['hp'] . '"></progress> ' . (int)$v['hp'] . '/' . (int)$v['max'] . ($v['block'] ? ' · 🛡️ ' . (int)$v['block'] : '') . '</div>';
    $h .= '<p class="pf-preview help" id="pf-preview" aria-live="polite">Tap tiles in the order you want them (1 to 4).</p>';
    $h .= '<div class="pf-hand" id="pf-hand">';
    foreach ($v['hand'] as $i => $t) $h .= pfight_tile_html($t, false, $i);
    $h .= '</div>';
    $h .= '<form method="post" class="pf-form" id="pf-form">' . csrf_field() . '<input type="hidden" name="do" value="pf_play"><input type="hidden" name="turn" value="' . (int)$v['turn'] . '"><input type="hidden" name="chain" id="pf-chain" value="">'
        . '<button class="btn primary" id="pf-go" disabled>Play chain</button> <button type="button" class="btn" id="pf-undo" disabled>Undo</button></form>';
    $h .= '<div class="pf-extra">';
    if ($v['can_run']) $h .= '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="pf_run"><button class="btn">🏃 Run</button></form> ';
    $h .= '<form method="post" class="inline" id="pf-rform" hidden>' . csrf_field() . '<input type="hidden" name="do" value="pf_redraw"><input type="hidden" name="card" id="pf-card" value=""></form>';
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
    $l = $fam[PF_HOLE[$t['t']] ?? ''] ?? '·'; $r = $t['r'] ? $fam[$t['r']] : '·';
    $label = $t['n'] . ', ' . ucfirst($t['t']) . ' ' . $t['v'] . ', starts ' . ($t['hole'] ?? PF_HOLE[$t['t']] ?? '') . ', ends ' . ($t['r'] ?? 'flat');
    $cls = 'pf-tile pf-' . $t['t'] . (!empty($t['by']) ? ' by-' . $t['by'] : '');
    $inner = '<span class="pf-sock l" aria-hidden="true">' . $l . '</span><span class="pf-ico" aria-hidden="true">' . pfight_icon($t['t']) . '</span><span class="pf-nm">' . e($t['n']) . '</span><span class="pf-val">' . (int)$t['v'] . '</span><span class="pf-sock r" aria-hidden="true">' . $r . '</span>';
    if ($strip) return '<span class="' . $cls . '" role="img" aria-label="' . e($label) . '">' . $inner . '</span>';
    return '<button type="button" class="' . $cls . '" data-i="' . $i . '" data-hole="' . e((string)($t['hole'] ?? '')) . '" data-knob="' . e((string)($t['r'] ?? '')) . '" data-t="' . e($t['t']) . '" data-v="' . (int)$t['v'] . '" aria-label="' . e($label) . '" aria-pressed="false">' . $inner . '</button>';
}
