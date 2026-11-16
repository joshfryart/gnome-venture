<?php
declare(strict_types=1);
/**
 * Maplewold family layer (2.7.01): the Sugar-shack ledger above the Trail map of the 82 hand-drawn landmarks (shows when ctx['maplewold']).
 * - a felt strip: one stitched patch per Maplewold Sight the gnome has ever used (trail_sight_first), N/82; the patches of THIS stretch first, lit when ready;
 *   the whole quilt (82 patches) folds away under it;
 * - next-appointment chips from npc_cw_sight_lines / npc_cw_forecast ("Bramble at the dandelion clocks, Thu 7 am");
 * - Pantry Round: the three villagers who want something today (rows of the folk files with `give=` and `gd=`), what, where, when, and whether you have it;
 * - the Opening Day Parade lanterns (quest line `opening-day-parade`, data/trail_sight_quests_fam_maplewold.txt).
 * Server-rendered, no script. Styles: `.mwl*` in assets/style.css.
 */

/** The slugs of the Maplewold family in the data file's order (the 82 landmarks), minus any the admin switched off. */
function trail_fam_maplewold_slugs(): array
{
    $mine = array_keys(trail_sights_file(__DIR__ . '/data/trail_sights_maplewold.txt'));
    $all = trail_sights_all();
    return array_values(array_filter($mine, fn($s) => isset($all[$s])));
}

/** The Maplewold Sights this gnome has used successfully at least once: [slug => true]. */
function trail_fam_maplewold_done(int $uid): array
{
    try { return array_fill_keys(array_column(q('SELECT slug FROM trail_sight_first WHERE user_id = ?', [$uid])->fetchAll(), 'slug'), true); } catch (Throwable $e) { return []; }
}

/** "Bramble", "Clover"; a title first ("Mister Plink", "Keeper Marram", "Beaver Foreman") keeps the full name. */
function trail_fam_maplewold_first(string $who): string
{
    $n = trail_sight_split_who($who)[0];
    $w = explode(' ', $n);
    return in_array($w[0], ['Mister', 'Mrs', 'Keeper', 'Beaver', 'Great'], true) ? $n : $w[0];
}

/** "here now until 6 pm" / "today 3 pm" / "tomorrow 7 am" / "Thu 7 am" from an npc_cw_forecast answer. */
function trail_fam_maplewold_when(array $f): string
{
    if (!empty($f['now'])) return 'here now until ' . hour_label((int)$f['to']);
    if ((int)$f['in'] === 0) return 'today ' . hour_label((int)$f['from']);
    if ((int)$f['in'] === 1) return 'tomorrow ' . hour_label((int)$f['from']);
    return NPC_CW_DOW[(int)$f['dow']] . ' ' . hour_label((int)$f['from']);
}

/** The appointment chips for the Sights of this stretch: [['text', 'now', 'in', 'from']] soonest first (one per villager and Sight; a row with a game-day condition is left to the Pantry Round block). */
function trail_fam_maplewold_chips(array $marks, int $max = 5): array
{
    $out = []; $seen = [];
    if (!npc_cw_on()) return $out;
    foreach ($marks as $m) {
        $slug = (string)$m['slug'];
        $gdWho = [];
        foreach (trail_sight_folk()[$slug] ?? [] as $r) if (str_contains($r['when'], 'gd=')) $gdWho[$r['who']] = true;
        foreach (npc_cw_sight_lines($slug) as $l) {
            $k = $l['who'] . '|' . $slug;
            if (isset($seen[$k]) || isset($gdWho[$l['who']])) continue;
            $seen[$k] = true;
            $f = npc_cw_forecast($l['who'], $slug);
            if (!$f) continue;
            $out[] = ['text' => trail_fam_maplewold_first($l['who']) . ' at ' . trail_sight_label($slug)[0] . ', ' . trail_fam_maplewold_when($f), 'now' => !empty($f['now']), 'in' => (int)$f['in'], 'from' => (int)$f['from']];
        }
    }
    usort($out, fn($a, $b) => [$b['now'], $a['in'], $a['from']] <=> [$a['now'], $b['in'], $b['from']]);
    return array_slice($out, 0, $max);
}

/** Today's Pantry Round: the folk rows with give= whose game-day condition holds today. [['who','first','slug','sight','item','need','have','name','hours','now','done']] */
function trail_fam_maplewold_pantry(array $ctx): array
{
    $out = [];
    $uid = (int)$ctx['u']['id'];
    $tal = trail_sight_tallies($uid);
    $dayNo = (int)floor(strtotime((function_exists('gclock_my_date') ? gclock_my_date() : date('Y-m-d')) . ' UTC') / 86400);
    $nowH = (int)floor((float)$ctx['clock'][1]);
    foreach (trail_sight_folk() as $slug => $rows) foreach ($rows as $idx => $r) {
        if (!str_contains($r['when'], 'gd=') || !trail_sight_cond_ok($r['when'], $ctx['now'])) continue;
        $g = null; foreach (trail_sight_tokens($r['rewards']) as $t) if (str_starts_with($t['tok'], 'give=')) $g = explode(':', substr($t['tok'], 5));
        if (!$g) continue;
        $need = max(1, (int)($g[1] ?? 1));
        $it = q_one('SELECT id, name FROM items WHERE slug = ?', [$g[0]]);
        $have = $it ? (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, (int)$it['id']]) : 0;
        $hrs = array_keys(npc_cw_on() ? npc_cw_hours_at($r['who'], $slug) : []);
        $out[] = ['who' => $r['who'], 'first' => trail_fam_maplewold_first($r['who']), 'slug' => $slug, 'sight' => trail_sight_label($slug)[0], 'name' => $it ? (string)$it['name'] : (trail_sight_items_file()[$g[0]][0] ?? ucfirst(str_replace('-', ' ', $g[0]))), 'need' => $need, 'have' => $have,
            'hours' => $hrs ? [min($hrs), max($hrs) + 1] : null, 'now' => in_array($nowH, $hrs, true), 'done' => (int)($tal['give~' . substr(md5($slug . '|' . $idx), 0, 16)] ?? 0) === $dayNo];
    }
    return $out;
}

function trail_fam_maplewold(array $ctx): string
{
    if (empty($ctx['maplewold'])) return '';
    require_once __DIR__ . '/npc_clockwork.php';
    $uid = (int)$ctx['u']['id'];
    $slugs = trail_fam_maplewold_slugs();
    if (!$slugs) return '';
    $all = trail_sights_all();
    $done = trail_fam_maplewold_done($uid);
    $total = count($slugs); $n = count(array_filter($slugs, fn($s) => isset($done[$s])));
    $here = [];   // this stretch: slug => ready
    foreach ((array)$ctx['marks'] as $m) $here[(string)$m['slug']] = (int)$m['left'] > 0;

    $h = '<section class="mwl" aria-label="Sugar-shack ledger"><div class="mwl-h"><b>🧵 Sugar-shack ledger</b> <span class="mwl-n">' . $n . '/' . $total . ' patches</span></div>'
        . '<div class="mwl-bar" role="progressbar" aria-valuemin="0" aria-valuemax="' . $total . '" aria-valuenow="' . $n . '" aria-label="Patches stitched"><i class="mwl-w' . ($total ? (int)(round(20 * $n / $total)) * 5 : 0) . '"></i></div>';

    if ($here) {   // the patches of this stretch: lit when ready
        $h .= '<ul class="mwl-row" aria-label="Sights on this stretch">';
        foreach ($here as $slug => $ready) {
            $d = isset($done[$slug]);
            $st = $ready ? ($d ? 'stitched, ready again' : 'ready, not stitched yet') : ($d ? 'stitched, resting' : 'resting, not stitched yet');
            $h .= '<li class="mwp ' . ($d ? 'done ' : '') . ($ready ? 'lit' : '') . '"><span class="mwp-i" aria-hidden="true">' . e($all[$slug]['icon']) . '</span>'
                . '<span class="mwp-t"><b>' . e(trail_sight_label($slug)[0]) . '</b><small>' . ($d ? '🧵 ' : '▫️ ') . ($ready ? '✨ ' : '') . e($st) . '</small></span></li>';
        }
        $h .= '</ul>';
    }

    $chips = trail_fam_maplewold_chips((array)$ctx['marks']);
    if ($chips) {
        $h .= '<ul class="mwl-chips" aria-label="Next appointments">';
        foreach ($chips as $c) $h .= '<li class="mwl-chip' . ($c['now'] ? ' now' : '') . '">🕒 ' . e($c['text']) . '</li>';
        $h .= '</ul>';
    }

    if (npc_cw_on() && ($pan = trail_fam_maplewold_pantry($ctx))) {
        $h .= '<div class="mwl-pan"><b>🥣 Pantry Round today</b><ul>';
        foreach ($pan as $p) {
            $when = $p['hours'] ? ($p['now'] ? 'here now until ' . hour_label($p['hours'][1]) : hour_label($p['hours'][0]) . ' – ' . hour_label($p['hours'][1])) : 'not out today';
            $h .= '<li class="' . ($p['done'] ? 'done' : ($p['have'] >= $p['need'] ? 'have' : '')) . '"><b>' . e($p['first']) . '</b> wants ' . $p['need'] . ' × ' . e($p['name']) . ' at ' . e($p['sight']) . ', ' . e($when) . '. '
                . '<small>' . ($p['done'] ? '✅ given today' : ($p['have'] >= $p['need'] ? '🎒 you have it' : '🎒 you have ' . $p['have'])) . '</small></li>';
        }
        $h .= '</ul></div>';
    }

    $qs = trail_sight_quests()['opening-day-parade'] ?? null;
    if ($qs) {
        $gate = (string)$qs['gate']; $gateOk = true;
        if (preg_match('/^quest:([a-z0-9-]+)$/', $gate, $gm)) { $gr = trail_sight_quest_row($uid, $gm[1]); $gateOk = $gr && $gr['done_at'] !== null; }
        $row = trail_sight_quest_row($uid, $qs['slug']);
        $dn = trail_sight_quest_done($qs, $row); $nb = count($qs['beats']);
        $fin = $row && $row['done_at'] !== null;
        if ($fin || $row || $gateOk) {
            $lamps = ''; foreach (array_keys($qs['beats']) as $i) $lamps .= in_array($i, $dn, true) || $fin ? '🏮' : '▫️';
            $next = '';
            if (!$fin) foreach ($qs['beats'] as $i => $b) if (trail_sight_beat_open($qs, $dn, $i)) { $next = $b[1] . ' (' . trail_sight_label($b[0])[0] . ')'; break; }
            $h .= '<p class="mwl-par"><b>' . e($qs['icon']) . ' ' . e($qs['title']) . '</b> <span aria-label="' . count($dn) . ' of ' . $nb . ' lanterns lit">' . $lamps . '</span> '
                . ($fin ? '<small>🎉 done</small>' : '<small>' . ($row ? count($dn) . ' of ' . $nb . ' lit. Next: ' . e($next) : 'Ask Clover Puddlejump: light the first lantern at dawn.') . '</small>') . '</p>';
        } else $h .= '<p class="mwl-par muted"><small>' . e($qs['icon']) . ' The Opening Day Parade starts once Bramble\'s Picnic List is done.</small></p>';
    }

    $h .= '<details class="mwl-quilt"><summary>🪡 The whole quilt <small>' . $n . '/' . $total . '</small></summary><ul class="mwl-grid">';
    foreach ($slugs as $s) {
        $d = isset($done[$s]); $nm = trail_sight_label($s)[0];
        $h .= '<li class="mwq' . ($d ? ' done' : '') . (!empty($here[$s]) ? ' lit' : '') . '" title="' . e($nm . ($d ? ': stitched' : ': not yet')) . '"><span aria-hidden="true">' . ($d ? e($all[$s]['icon']) : '·') . '</span>'
            . '<span class="mwq-t">' . e($nm) . ($d ? ', stitched' : ', not yet') . '</span></li>';
    }
    return $h . '</ul></details></section>';
}
