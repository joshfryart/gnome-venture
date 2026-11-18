<?php
// Wear piece balance sim (claude/wear-pieces/balance.md). Real engine, real decks, the bots of tests/pf_bots.php. No DB.
//   php wear_sim.php run REGIONS BOTS N RANK [SHARD/NSHARDS] [ONLY] [NBASE]   json lines on stdout
//     REGIONS: all or a comma list (NA,CA...).  BOTS: look,greedy (careful, careless).  N: fights per piece and bot.  RANK: 1 Common, 2 Lined, 3 Fine.
//     ONLY: '' = every piece, rare = only the Rare pieces, nobase = every piece but no baseline fights, a comma list of slugs = only those.  NBASE: baseline fights per region and bot (default 10 x N).
//   A piece is played two ways on the same creature and seed: plain (its effect taken off: a plain piece of the same type, value and edges) and fx (the real piece).
//   Their decks are the same size, so the shuffles match and fx - plain is the effect alone (paired). The baseline (no wear piece) has a smaller deck, so it cannot be
//   paired: it gets many fights per region instead, and every piece its own seeds (so the pieces of a region do not share one draw of luck).
// The gnome: level = the region level (REGION_LEVELS), the tuner's normal kit (tests/pfboard_tune_v1.php tv_sources), the wear piece switched on in its Keepsake slot.
// The creatures: every creature within 3 levels of the region level (widened until there are 6), at their own level.
require_once __DIR__ . '/../../../tests/pf_bots.php';
require_once __DIR__ . '/../../../game/includes/progression.php';
require_once __DIR__ . '/../../../game/includes/wearables.php';

function ws_pieces(): array { return json_decode(file_get_contents(__DIR__ . '/../pieces.json'), true); }

/** Creatures met at a region level. */
function ws_pool(int $L): array
{
    $cr = tv_creatures();
    for ($w = 3; ; $w++) { $p = array_values(array_filter($cr, fn($c) => abs($c['level'] - $L) <= $w)); if (count($p) >= 6) return $p; }
}

/** tv_player($lv) with one wear piece (item slug, rank 1-3) switched on. $mode: base | plain | fx. */
function ws_player(int $lv, ?string $slug, int $rank, string $mode): array
{
    $m = max(0, intdiv($lv + 3, 14));
    $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv]; $max = 20 + 3 * $lv + 5 * $m;
    $src = tv_sources($lv);
    if ($mode !== 'base') { $src['wears'] = [wear_slug($slug, 'a', $rank) => 1]; $src['state']['w:' . $slug] = true; }
    $deck = pfd_tiles(pfd_fight_entries($src), $st, [], $src['calling'], $src['ctier']);
    if ($mode !== 'base') {
        $hit = 0;
        foreach ($deck as $i => $t) if (($t['src'] ?? '') === 'wear') { $hit++; if ($mode === 'plain') unset($deck[$i]['fx'], $deck[$i]['fxa'], $deck[$i]['fxb']); }
        if ($hit !== 1) throw new RuntimeException("wear piece $slug rank $rank not in the deck ($hit)");
    }
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => array_values($deck), 'luck' => $m];
}

/** pb_fight (tests/pf_bots.php) with two counts more: pl = times you placed the wear piece, fx = wear effect actions that happened (events with 'wfx'). */
function ws_fight(array $c, int $lv, string $bot, int $seed, array $player): array
{
    mt_srand($seed); $rng = fn(int $n) => $n > 0 ? mt_rand(0, $n - 1) : 0;
    try {
        $cr = pfd_foe_row($c, array_keys(pfd_region_pieces())[(crc32($c['slug']) + $seed) % 14]);
        $s = pfb_new($player, $cr, $seed, ['blank' => true, 'v1' => true]);
        $hand = $s['me']['hand'];
        if ($hand) { $bi = 0; foreach ($hand as $i => $t) if ($t['t'] === 'hurt' && $t['v'] > $hand[$bi]['v']) $bi = $i; pfb_start($s, $bi, ['L', 'R', 'T', 'B'][$seed % 4]); }
        $t = 0; $pl = 0; $fx = 0;
        while (!$s['over'] && $t++ < 40) {
            $places = tv_places($s); $a = pb_choose($s, $bot, $places, $rng);
            if (is_int($a[0]) && ($s['me']['hand'][$a[0]]['src'] ?? '') === 'wear') $pl++;
            $r = tv_act($s, $a);
            if ($r['err']) { $r = pfb_pass($s, $s['turn']); if ($r['err']) { if (!$places) break; $r = tv_act($s, $places[0]); if ($r['err']) break; } }
            foreach ($r['ev'] ?? [] as $e) if (!empty($e['wfx'])) $fx += count($e['wfx']);
        }
        return ['win' => in_array($s['over'], ['seen_off', 'charmed'], true) ? 1 : 0, 'turns' => (int)$s['turn'], 'hp' => 1 - max(0, $s['me']['hp']) / max(1, $s['me']['max']), 'over' => (string)$s['over'], 'pl' => $pl, 'fx' => $fx];
    } catch (Throwable $e) {
        return ['win' => 0, 'turns' => 0, 'hp' => 0, 'over' => 'err', 'pl' => 0, 'fx' => 0, 'err' => get_class($e) . ': ' . $e->getMessage()];
    }
}

if (PHP_SAPI !== 'cli' || realpath($argv[0]) !== __FILE__) return;
[, $cmd, $regs, $bots, $N, $rank] = $argv + [null, 'run', 'all', 'look,greedy', 40, 1];
[$sh, $nsh] = array_map('intval', explode('/', $argv[6] ?? '0/1')); $only = $argv[7] ?? ''; $N = (int)$N; $NB = (int)($argv[8] ?? 10 * $N); $rank = (int)$rank; $bots = explode(',', $bots);
$P = ws_pieces(); $idx = array_flip(array_column($P, 'slug'));
if ($regs !== 'all') { $rs = explode(',', $regs); $P = array_values(array_filter($P, fn($p) => in_array($p['region'], $rs, true))); }
$withBase = $only === '';   // the baseline does not depend on the rank: only a full run plays it
if ($only === 'rare') $P = array_values(array_filter($P, fn($p) => $p['rarity'] === 'Rare'));
elseif ($only !== '' && $only !== 'nobase') { $os = explode(',', $only); $P = array_values(array_filter($P, fn($p) => in_array($p['slug'], $os, true))); }
$jobs = []; $seenReg = [];   // [region, slug|null, piece, k0, k1]: the baseline is cut in chunks of N so the shards share it
foreach ($P as $p) {
    if ($withBase && !isset($seenReg[$p['region']])) { $seenReg[$p['region']] = 1; for ($k0 = 0; $k0 < $NB; $k0 += $N) $jobs[] = [$p['region'], null, null, $k0, min($NB, $k0 + $N)]; }
    $jobs[] = [$p['region'], $p['slug'], $p, 0, $N];
}
$pls = [];
foreach ($jobs as $ji => [$reg, $slug, $p, $k0, $k1]) {
    if ($ji % $nsh !== $sh) continue;
    $L = REGION_LEVELS[$reg]; $pool = ws_pool($L);
    $modes = $slug === null ? ['base'] : ['plain', 'fx'];
    $pl = []; foreach ($modes as $md) $pl[$md] = $md === 'base' ? ($pls[$reg] ??= ws_player($L, null, $rank, 'base')) : ws_player($L, $slug, $rank, $md);
    $sb = $slug === null ? 900000 : 100000 * (1 + $idx[$slug]);   // every piece its own seeds; the baseline its own
    foreach ($bots as $bot) for ($k = $k0; $k < $k1; $k++) {
        $c = $pool[$k % count($pool)]; $seed = $sb + 13 * $k + $L;
        foreach ($modes as $md) {
            $r = ws_fight($c, $L, $bot, $seed, $pl[$md]);
            echo json_encode(['reg' => $reg, 'slug' => $slug ?? 'base', 'rar' => $p['rarity'] ?? '', 'type' => $p['type'] ?? '', 'code' => $p['code'] ?? '', 'rank' => $rank, 'bot' => $bot, 'md' => $md, 'k' => $k, 'cr' => $c['slug'],
                'win' => $r['win'], 'hp' => round($r['hp'], 4), 'turns' => $r['turns'], 'over' => $r['over'], 'pl' => $r['pl'], 'fx' => $r['fx']] + (isset($r['err']) ? ['err' => $r['err']] : [])), "\n";
        }
    }
}
