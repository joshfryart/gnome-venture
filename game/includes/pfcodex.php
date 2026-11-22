<?php
declare(strict_types=1);
/**
 * 2.7.55 Creature Codex (a tab of the v1 Puzzle box). A creature shows once you have met it in a fight; its pieces show as they are played on the board;
 * its description and type show after you beat (or charm) it once. Table pf_codex: one row per creature (piece = '') plus one per piece seen (piece = its name);
 * won = 1 on the creature row. Written by pfight_do (pfcx_note), read by the Codex tab (pfcx_html). Plain links, no script, no inline style (CSP).
 */

function pfcx_ensure(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    try { db()->exec('CREATE TABLE IF NOT EXISTS pf_codex (user_id INTEGER NOT NULL, slug VARCHAR(80) NOT NULL, piece VARCHAR(64) NOT NULL, won INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (user_id, slug, piece))'); return $ok = true; }
    catch (Throwable $e) { return $ok = false; }
}

/** After a board move: the creature is met, every piece of its on the board is seen, and a win marks it beaten. Never throws (a codex write must not break a fight). */
function pfcx_note(array $u, array $c, array $s, bool $won = false): void
{
    try {
        $slug = (string)($c['slug'] ?? '');
        if ($slug === '' || !pfcx_ensure()) return;
        $uid = (int)$u['id'];
        $ins = (db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite' ? 'INSERT OR IGNORE' : 'INSERT IGNORE') . ' INTO pf_codex (user_id, slug, piece, won) VALUES (?, ?, ?, 0)';
        q($ins, [$uid, $slug, '']);
        foreach ((array)($s['pcs'] ?? []) as $p) {
            if (($p['by'] ?? '') !== 'foe') continue;
            $n = trim((string)($p['tile']['n'] ?? ''));
            if ($n !== '' && mb_strlen($n) <= 64) q($ins, [$uid, $slug, $n]);
        }
        if ($won) q('UPDATE pf_codex SET won = 1 WHERE user_id = ? AND slug = ? AND piece = ?', [$uid, $slug, '']);
    } catch (Throwable $e) { /* the codex is a bonus */ }
}

function pfcx_human(string $s): string { return ucfirst(str_replace(['-', '_'], ' ', trim($s))); }

/** [slug => row] of every creature the Codex lists: name, size, level, lands, class, description, from the creatures table and data/pf_creatures.txt. */
function pfcx_creatures(): array
{
    require_once __DIR__ . '/pfdeck.php';
    $db = [];
    foreach (q('SELECT slug, name, size, landscapes, level, description FROM creatures WHERE active = 1') as $r) $db[(string)$r['slug']] = $r;
    $out = [];
    foreach (pfd_creature_rows() as $slug => $r) {
        $d = $db[$slug] ?? [];
        $name = (string)($r['name'] ?? $d['name'] ?? ''); if ($name === '') $name = pfcx_human($slug);
        $base = $r['family'] !== '' ? ($db[$r['family']] ?? []) : [];
        $size = (string)($r['size'] ?? $d['size'] ?? $base['size'] ?? 'small');
        $lands = (string)($r['lands'] ?? $d['landscapes'] ?? $base['landscapes'] ?? '');
        $level = (int)($r['level'] ?? $d['level'] ?? $base['level'] ?? 1);
        $desc = (string)($r['desc'] ?? $d['description'] ?? $base['description'] ?? '');
        $out[$slug] = ['slug' => $slug, 'name' => $name, 'size' => $size, 'lands' => $lands, 'regions' => (array)$r['regions'], 'level' => $level, 'desc' => $desc, 'family' => (string)$r['family']];
    }
    uasort($out, fn($a, $b) => [['small' => 0, 'medium' => 1, 'large' => 2, 'boss' => 3][$a['size']] ?? 0, $a['level'], $a['name']] <=> [['small' => 0, 'medium' => 1, 'large' => 2, 'boss' => 3][$b['size']] ?? 0, $b['level'], $b['name']]);
    return $out;
}

function pfcx_tile(array $c, int $st, int $seen, string $tab): string
{
    $img = $st ? creature_image((string)$c['slug']) : '';
    $art = $img !== '' ? '<img src="' . e(url($img)) . '" alt="" loading="lazy" decoding="async">' : '<span class="cx-mono">' . ($st ? e(mb_strtoupper(mb_substr((string)$c['name'], 0, 1))) : '?') . '</span>';
    return '<a class="cx-tile cx-' . ($st > 1 ? 'won' : ($st ? 'met' : 'new')) . ' cx-s-' . e((string)$c['size']) . '" href="' . e(url('puzzlebox.php?t=codex&c=' . rawurlencode((string)$c['slug']))) . '" aria-label="' . e($st ? (string)$c['name'] : 'Unknown creature') . '">'
        . $art . ($st ? '<b>' . e((string)$c['name']) . '</b><i>' . $seen . '</i>' : '') . '</a>';
}

function pfcx_sheet(array $c, int $st, array $seenNames): string
{
    require_once __DIR__ . '/pfdeck.php';
    $close = e(url('puzzlebox.php?t=codex'));
    $img = $st ? creature_image((string)$c['slug']) : '';
    $pic = $img !== '' ? '<img src="' . e(url($img)) . '" alt="" decoding="async">' : '<span class="cx-mono">' . ($st ? e(mb_strtoupper(mb_substr((string)$c['name'], 0, 1))) : '?') . '</span>';
    $h = '<div class="cx-scrim"><a class="cx-back" href="' . $close . '" aria-label="Close"></a><section class="cx-sheet" role="dialog" aria-label="' . e($st ? (string)$c['name'] : 'Unknown creature') . '">'
        . '<a class="cx-x" href="' . $close . '" aria-label="Close">×</a><div class="cx-top"><div class="cx-pic">' . $pic . '</div><div><h3>' . ($st ? e((string)$c['name']) : 'Unknown creature') . '</h3><div class="cx-tags">';
    if ($st > 1) {
        $cl = pfd_class(pfd_creature_overlay(['slug' => $c['slug'], 'size' => $c['size']]));
        $h .= '<span>' . e($cl) . '</span><span>' . e(pfcx_human((string)$c['size'])) . '</span><span>Level ' . (int)$c['level'] . '</span>';
    } else $h .= '<span>Type unknown</span><span>' . e(pfcx_human((string)$c['size'])) . '</span>';
    $h .= '</div></div></div>';
    $where = [];
    foreach (array_filter(array_map('trim', explode(',', (string)$c['lands']))) as $l) if ($l !== 'any') $where[] = pfcx_human($l);
    foreach ((array)$c['regions'] as $rg) if ($rg !== '*') $where[] = pfcx_human((string)$rg);
    $h .= '<h4>Where to look</h4><p class="cx-where">' . ($where ? implode('', array_map(fn($w) => '<span>' . e($w) . '</span>', array_values(array_unique($where)))) : '<span>Almost anywhere</span>') . '</p>';
    $h .= '<h4>About</h4>' . ($st > 1 ? '<p>' . e((string)$c['desc']) . '</p>' : '<p class="cx-lock">Win a fight against it to learn what it is.</p>');
    $all = [];
    if ($st) { $row = pfd_foe_row(pfd_creature_overlay(['slug' => $c['slug'], 'size' => $c['size'], 'name' => $c['name'], 'level' => $c['level']]), ''); foreach ($row['deck'] as $p) $all[(string)$p['n']] = (string)$p['t']; }
    $h .= '<h4>Pieces seen · ' . count($seenNames) . ($all ? ' of ' . max(count($all), count(array_diff($seenNames, [''])) ) . '+' : '') . '</h4>';
    if (!$st) $h .= '<p class="cx-lock">Meet it in a fight to see its pieces.</p>';
    else {
        $h .= '<ul class="cx-pieces">';
        foreach ($seenNames as $n) $h .= '<li><b>' . e($n) . '</b>' . (isset($all[$n]) ? '<span>' . e(pfcx_human($all[$n])) . '</span>' : '') . '</li>';
        for ($i = count($seenNames); $i < count($all); $i++) $h .= '<li class="cx-q">Not seen yet</li>';
        $h .= '</ul>';
    }
    return $h . '</section></div>';
}

function pfcx_html(array $u, string $slug = '', string $size = 'all'): string
{
    $uid = (int)$u['id'];
    $list = pfcx_creatures();
    $st = []; $pc = [];
    if (pfcx_ensure()) foreach (q('SELECT slug, piece, won FROM pf_codex WHERE user_id = ?', [$uid]) as $r) {
        $s = (string)$r['slug'];
        if ((string)$r['piece'] === '') $st[$s] = ((int)$r['won'] ? 2 : 1); else $pc[$s][] = (string)$r['piece'];
    }
    $met = count($st); $won = count(array_filter($st, fn($v) => $v > 1));
    $h = '<div class="cx"><div class="cx-head"><h3>Creature Codex</h3><span><b>' . $met . '</b> met · <b>' . $won . '</b> beaten · ' . count($list) . ' in all</span></div>'
        . '<progress class="cx-bar" max="' . max(1, count($list)) . '" value="' . $met . '" aria-label="Creatures met"></progress><nav class="cx-chips" aria-label="Size">';
    foreach (['all' => 'All', 'small' => 'Small', 'medium' => 'Medium', 'large' => 'Large', 'boss' => 'Boss'] as $k => $l) $h .= '<a href="' . e(url('puzzlebox.php?t=codex' . ($k === 'all' ? '' : '&z=' . $k))) . '"' . ($k === $size ? ' class="on" aria-current="page"' : '') . '>' . $l . '</a>';
    $h .= '</nav><div class="cx-grid">';
    foreach ($list as $c) { if ($size !== 'all' && $c['size'] !== $size) continue; $h .= pfcx_tile($c, $st[$c['slug']] ?? 0, count($pc[$c['slug']] ?? []), $size); }
    $h .= '</div>';
    if ($slug !== '' && isset($list[$slug])) $h .= pfcx_sheet($list[$slug], $st[$slug] ?? 0, array_values(array_unique($pc[$slug] ?? [])));
    return $h . '</div>';
}
