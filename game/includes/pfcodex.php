<?php
declare(strict_types=1);
/**
 * 2.7.55 Creature Codex (a tab of the v1 Puzzle box). A creature shows once you have met it in a fight; its pieces show as they are played on the board;
 * its description, class, level and abilities show after you beat (or charm) it once. Table pf_codex: one row per creature (piece = '') plus one per piece seen (piece = its name);
 * won = 1 on the creature row. Written by pfight_do (pfcx_note), read by the Codex tab (pfcx_html).
 * 2.7.57: a piece row keeps what the piece looked like when it was first seen (column pd: compact JSON of t, v, tag, ik and the four edges), so a piece that is not in the
 * creature's standard deck (a region piece) can still be drawn. Rows from 2.7.55 / 2.7.56 have pd NULL: it is filled the next time the piece is seen, and a standard piece
 * is drawn from the deck list meanwhile. The page works without script (plain links, the pieces as text cards); assets/pfcodex.js draws the pieces with the game's renderer
 * (assets/pfparts47.js) and handles Esc and focus. No inline script or style (CSP); CSS: the .cx block in assets/pfv1.css.
 */

function pfcx_ensure(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    try { db()->exec('CREATE TABLE IF NOT EXISTS pf_codex (user_id INTEGER NOT NULL, slug VARCHAR(80) NOT NULL, piece VARCHAR(64) NOT NULL, won INTEGER NOT NULL DEFAULT 0, pd TEXT NULL, PRIMARY KEY (user_id, slug, piece))'); }
    catch (Throwable $e) { return $ok = false; }
    try { q('SELECT pd FROM pf_codex WHERE 1 = 0'); }   // a 2.7.55 table: add the column (plain SQL that SQLite and MySQL both take)
    catch (Throwable $e) { try { db()->exec('ALTER TABLE pf_codex ADD COLUMN pd TEXT NULL'); } catch (Throwable $e2) { /* another request added it */ } }
    return $ok = true;
}

/** Whether the pd column is there (false only when the ALTER failed: the Codex then works as in 2.7.55). */
function pfcx_has_pd(): bool
{
    static $has = null;
    if ($has !== null) return $has;
    try { q('SELECT pd FROM pf_codex WHERE 1 = 0'); return $has = true; } catch (Throwable $e) { return $has = false; }
}

/** The compact look of a board piece: t, v (as the creature played it), tag, ik, e (L R T B => [kind, family]). */
function pfcx_piece_data(array $tile): array
{
    $e = (array)($tile['e'] ?? []);
    if (!$e && isset($tile['t']) && (isset($tile['ed']) || isset($tile['k'])) && function_exists('pfb_edges')) { try { $e = pfb_edges($tile); } catch (Throwable $x) { $e = []; } }
    $d = ['t' => (string)($tile['t'] ?? ''), 'v' => (int)($tile['v'] ?? 0), 'tag' => (string)($tile['tag'] ?? ''), 'ik' => (string)($tile['ik'] ?? '')];
    foreach (['L', 'R', 'T', 'B'] as $s) if (isset($e[$s][0])) $d['e'][$s] = [(string)$e[$s][0], ($e[$s][1] ?? null) === null ? null : (string)$e[$s][1]];
    return $d;
}

/** After a board move: the creature is met, every piece of its on the board is seen, and a win marks it beaten. Never throws (a codex write must not break a fight). */
function pfcx_note(array $u, array $c, array $s, bool $won = false): void
{
    try {
        $slug = (string)($c['slug'] ?? '');
        if ($slug === '' || !pfcx_ensure()) return;
        $uid = (int)$u['id']; $pd = pfcx_has_pd();
        $ig = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite' ? 'INSERT OR IGNORE' : 'INSERT IGNORE';
        q($ig . ' INTO pf_codex (user_id, slug, piece, won) VALUES (?, ?, ?, 0)', [$uid, $slug, '']);
        $done = [];
        foreach ((array)($s['pcs'] ?? []) as $p) {
            if (($p['by'] ?? '') !== 'foe') continue;
            $n = trim((string)($p['tile']['n'] ?? ''));
            if ($n === '' || mb_strlen($n) > 64 || isset($done[$n])) continue;
            $done[$n] = 1;
            if (!$pd) { q($ig . ' INTO pf_codex (user_id, slug, piece, won) VALUES (?, ?, ?, 0)', [$uid, $slug, $n]); continue; }
            $j = json_encode(pfcx_piece_data((array)$p['tile']), JSON_UNESCAPED_UNICODE);
            q($ig . ' INTO pf_codex (user_id, slug, piece, won, pd) VALUES (?, ?, ?, 0, ?)', [$uid, $slug, $n, $j]);   // the first sight is kept
            q('UPDATE pf_codex SET pd = ? WHERE user_id = ? AND slug = ? AND piece = ? AND pd IS NULL', [$j, $uid, $slug, $n]);   // a row from before 2.7.57 gets its look
        }
        if ($won) q('UPDATE pf_codex SET won = 1 WHERE user_id = ? AND slug = ? AND piece = ?', [$uid, $slug, '']);
    } catch (Throwable $e) { /* the codex is a bonus */ }
}

/** 2.7.58 creature parts: table pf_codex_parts (user_id, slug, given, done_at), created on first use like pf_codex. */
function pfcx_parts_ensure(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    try { db()->exec('CREATE TABLE IF NOT EXISTS pf_codex_parts (user_id INTEGER NOT NULL, slug VARCHAR(80) NOT NULL, given INTEGER NOT NULL DEFAULT 0, done_at VARCHAR(32) NULL, PRIMARY KEY (user_id, slug))'); return $ok = true; }
    catch (Throwable $e) { return $ok = false; }
}

/** The part items (id, slug, name) this creature (or, for a variant, its family) can drop, from creature_drops. */
function pfcx_drop_parts(string $slug): array
{
    $fam = (string)(pfcx_creatures()[$slug]['family'] ?? '');
    $in = array_values(array_unique(array_filter([$slug, $fam])));
    return q("SELECT DISTINCT i.id, i.slug, i.name FROM creature_drops cd JOIN creatures c ON c.id = cd.creature_id JOIN items i ON i.id = cd.item_id
        WHERE i.category = 'part' AND c.slug IN (" . implode(',', array_fill(0, count($in), '?')) . ') ORDER BY i.id', $in)->fetchAll();
}

/** [given, done] of a creature for this gnome. */
function pfcx_parts_state(int $uid, string $slug): array
{
    if (!pfcx_parts_ensure()) return [0, false];
    $r = q_one('SELECT given, done_at FROM pf_codex_parts WHERE user_id = ? AND slug = ?', [$uid, $slug]);
    return $r ? [(int)$r['given'], $r['done_at'] !== null] : [0, false];
}

/** How many of this creature's parts the gnome holds. */
function pfcx_parts_held(int $uid, string $slug): int
{
    $n = 0; foreach (pfcx_drop_parts($slug) as $p) $n += (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, (int)$p['id']]);
    return $n;
}

/** Give a met creature the parts it drops (up to the number still needed). The last one pays once: Petals x the creature's level band, and XP. [ok, message] */
function pfcx_donate(array $u, string $slug): array
{
    $uid = (int)$u['id']; $list = pfcx_creatures();
    if (!isset($list[$slug]) || !pfcx_ensure() || !pfcx_parts_ensure()) return [false, 'The Codex cannot take that.'];
    if (!q_val('SELECT 1 FROM pf_codex WHERE user_id = ? AND slug = ? AND piece = ?', [$uid, $slug, ''])) return [false, 'Meet that creature in a fight first.'];
    $need = max(1, (int)setting('codex_part_need'));
    [$given, $done] = pfcx_parts_state($uid, $slug);
    if ($done) return [false, 'You have already given this creature’s parts to the Codex.'];
    $want = $need - $given; $took = 0;
    foreach (pfcx_drop_parts($slug) as $p) {
        $have = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, (int)$p['id']]);
        $use = min($want - $took, $have);
        if ($use > 0 && give_item($uid, (int)$p['id'], -$use)) $took += $use;
        if ($took >= $want) break;
    }
    if ($took < 1) return [false, 'You carry no part this creature leaves behind.'];
    if ($given === 0 && !q_val('SELECT 1 FROM pf_codex_parts WHERE user_id = ? AND slug = ?', [$uid, $slug])) q('INSERT INTO pf_codex_parts (user_id, slug, given) VALUES (?, ?, 0)', [$uid, $slug]);
    q('UPDATE pf_codex_parts SET given = given + ? WHERE user_id = ? AND slug = ?', [$took, $uid, $slug]);
    $now = $given + $took; $name = (string)$list[$slug]['name'];
    if ($now < $need) return [true, 'You give the Codex ' . $took . ' part' . ($took === 1 ? '' : 's') . ' (' . $now . ' of ' . $need . ').'];
    if (q('UPDATE pf_codex_parts SET done_at = ? WHERE user_id = ? AND slug = ? AND done_at IS NULL', [now(), $uid, $slug])->rowCount() !== 1) return [true, 'Parts given.'];
    $band = 1 + intdiv(max(1, (int)$list[$slug]['level']) - 1, 10);
    $pet = (int)setting('codex_part_petals') * $band; $xp = (int)setting('codex_part_xp');
    if ($pet > 0) give_petals($uid, $pet, 'codex parts');
    if ($xp > 0) add_xp($uid, $xp, 'Codex');
    return [true, '📖 The Codex now has all it needs of the ' . $name . '’s parts: +' . $pet . ' Petals, +' . $xp . ' XP.'];
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

/** The creature's picture (its own, its family's, or the drawn placeholder), '' when there is none. */
function pfcx_image(array $c): string
{
    require_once __DIR__ . '/items.php';
    $img = creature_image((string)$c['slug'], true);
    if ($img === '' && (string)($c['family'] ?? '') !== '') $img = creature_image((string)$c['family'], true);
    return $img;
}

/** A link inside the Codex (the size filter kept). */
function pfcx_url(string $size, string $slug = '', string $anchor = ''): string
{
    return url('puzzlebox.php?t=codex' . ($size !== 'all' ? '&z=' . $size : '') . ($slug !== '' ? '&c=' . rawurlencode($slug) : '')) . ($anchor !== '' ? '#' . $anchor : '');
}

function pfcx_tile(array $c, int $st, int $seen, string $size): string
{
    $img = $st ? pfcx_image($c) : '';
    $art = $img !== '' ? '<img src="' . e(url($img)) . '" alt="" loading="lazy" decoding="async">' : '<span class="cx-mono">' . ($st ? e(mb_strtoupper(mb_substr((string)$c['name'], 0, 1))) : '?') . '</span>';
    return '<a class="cx-tile cx-' . ($st > 1 ? 'won' : ($st ? 'met' : 'new')) . ' cx-s-' . e((string)$c['size']) . '" id="cx-' . e((string)$c['slug']) . '" href="' . e(pfcx_url($size, (string)$c['slug'])) . '" aria-label="' . e($st ? (string)$c['name'] . ($st > 1 ? ', beaten' : ', met') . ', ' . $seen . ' piece' . ($seen === 1 ? '' : 's') . ' seen' : 'Unknown creature') . '">'
        . $art . ($st ? '<b>' . e((string)$c['name']) . '</b>' . ($seen ? '<i aria-hidden="true">' . $seen . '</i>' : '') : '') . '</a>';
}

/** The four edges in words, for a text card and a screen reader: "knob right, hole left". */
function pfcx_edges_text(array $e): string
{
    $out = [];
    foreach (['L' => 'left', 'R' => 'right', 'T' => 'top', 'B' => 'bottom'] as $s => $w) {
        $k = (string)($e[$s][0] ?? 'flat');
        if ($k === 'knob' || $k === 'hole') $out[] = $k . ' ' . $w;
    }
    return $out ? implode(', ', $out) : 'flat edges';
}

/** One seen piece: a text card that assets/pfcodex.js turns into the drawn piece (the name and type stay under it). $d = t, v, tag, ik, e. */
function pfcx_piece_li(string $name, array $d, int $tint): string
{
    $t = (string)($d['t'] ?? 'hurt'); $ty = PFV_TYPE[$t] ?? pfcx_human($t); $fam = PF_HOLE[$t] ?? 'body'; $v = max(0, (int)($d['v'] ?? 0));
    $tag = (string)($d['tag'] ?? ''); $tagOk = $tag !== '' && isset(PF_TAGS[$tag]); $tagTx = PFV_FOE_TAG[$tag] ?? '';
    $ok = is_array($d['e'] ?? null) && count((array)$d['e']) === 4;
    $art = ['t' => $t, 'e' => $d['e'] ?? null, 'tag' => $tagOk ? $tag : '', 'ik' => (string)($d['ik'] ?? ''), 'v' => $v, 'tint' => $tint];
    $edTx = $ok ? pfcx_edges_text((array)$d['e']) : '';
    return '<li class="cx-pc f-' . e($fam) . '" aria-label="' . e($name . ', ' . $ty . ' ' . $v . ($tagOk ? ', ' . $tag : '') . ($edTx !== '' ? ', ' . $edTx : '')) . '">'
        . '<span class="cx-art">' . ($ok ? '<i class="cxp" data-p="' . e((string)json_encode($art, JSON_UNESCAPED_UNICODE)) . '"></i>' : '') . '<span class="cx-tc" aria-hidden="true"><img src="' . e(url('assets/img/pfight/ico-' . $t . '-s.png')) . '" width="24" height="24" alt=""><b>' . $v . '</b></span></span>'
        . '<span class="cx-nm" aria-hidden="true">' . e($name) . '</span><small class="cx-ty" aria-hidden="true"><i class="cx-fd"></i>' . e($ty) . ($tagOk ? ' · ' . e(pfcx_human($tag)) : '') . '</small>'
        . ($edTx !== '' ? '<small class="cx-ed" aria-hidden="true">' . e(ucfirst($edTx)) . '</small>' : '') . ($tagTx !== '' ? '<small class="cx-tg" aria-hidden="true">' . e($tagTx) . '</small>' : '') . '</li>';
}

/** The creature's sheet: picture, name, tags, where to look, about (after a win), what it does (after a win), the pieces seen (drawn) and blanks for the rest. $seen: name => pd (array or null). */
function pfcx_sheet(array $c, int $st, array $seen, string $size = 'all', ?array $u = null): string
{
    require_once __DIR__ . '/pfdeck.php';
    require_once __DIR__ . '/pfdeck_view.php';
    $slug = (string)$c['slug'];
    $close = e(pfcx_url($size, '', 'cx-' . $slug));
    $img = $st ? pfcx_image($c) : '';
    $pic = $img !== '' ? '<img src="' . e(url($img)) . '" alt="" decoding="async">' : '<span class="cx-mono">' . ($st ? e(mb_strtoupper(mb_substr((string)$c['name'], 0, 1))) : '?') . '</span>';
    $title = $st ? (string)$c['name'] : 'Unknown creature';
    $h = '<div class="cx-scrim" id="cx-scrim"><a class="cx-back" href="' . $close . '" tabindex="-1" aria-hidden="true"></a><section class="cx-sheet cx-sz-' . e((string)$c['size']) . '" id="cx-sheet" role="dialog" aria-modal="true" aria-labelledby="cx-h" tabindex="-1">'
        . '<a class="cx-x" href="' . $close . '" aria-label="Close">×</a><div class="cx-top"><div class="cx-pic' . ($st ? '' : ' cx-unk') . '">' . $pic . '</div><div class="cx-ttl"><h3 id="cx-h">' . e($title) . '</h3><div class="cx-tags">';
    $ov = pfd_creature_overlay(['slug' => $slug, 'size' => $c['size'], 'name' => $c['name'], 'level' => $c['level']]);
    if ($st > 1) {
        $cl = pfd_class($ov);
        $h .= '<span>' . (PFV_CLASS_ICON[$cl] ?? '🐾') . ' ' . e($cl) . '</span><span>' . e(pfcx_human((string)$c['size'])) . '</span><span>Level ' . (int)$c['level'] . '</span>';
    } else $h .= '<span>Type unknown</span><span>' . e(pfcx_human((string)$c['size'])) . '</span>';
    $h .= '<span class="cx-st">' . ($st > 1 ? 'Beaten' : ($st ? 'Met' : 'Not met yet')) . '</span></div></div></div>';
    $where = [];
    foreach (array_filter(array_map('trim', explode(',', (string)$c['lands']))) as $l) if ($l !== 'any') $where[] = pfcx_human($l);
    foreach ((array)$c['regions'] as $rg) if ($rg !== '*') $where[] = pfcx_human((string)$rg);
    $h .= '<h4>Where to look</h4><p class="cx-where">' . ($where ? implode('', array_map(fn($w) => '<span>' . e($w) . '</span>', array_values(array_unique($where)))) : '<span>Almost anywhere</span>') . '</p>';
    $h .= '<h4>About</h4>' . ($st > 1 ? '<p class="cx-desc">' . e((string)$c['desc']) . '</p>' : '<p class="cx-lock">Win a fight against it to learn what it is.</p>');
    if ($st > 1) {   // what it does, in plain words: its class rule (or that rule's variant) and its own abilities, the same texts the fight shows
        $ab = [];
        $kind = pfb_kind_of(['class' => pfd_class($ov)], (string)$c['size']);
        if ($kind !== '' && isset(PFB_KIND_TEXT[$kind])) $ab[] = PFB_KIND_TEXT[$kind];
        foreach ((array)($ov['ab'] ?? []) as $id) {
            if (!isset(PFB_ABIL[$id])) continue;
            $line = [PFB_ABIL[$id][4], PFB_ABIL[$id][5] . '.'];
            if (PFB_ABIL[$id][0] === 'E' && $ab && $kind !== '') $ab[0] = $line; else $ab[] = $line;
        }
        if ($ab) $h .= '<h4>What it does</h4><ul class="cx-ab">' . implode('', array_map(fn($a) => '<li><b>' . e($a[0]) . '</b> ' . e($a[1]) . '</li>', $ab)) . '</ul>';
    }
    // the pieces: the standard deck in its order (seen ones drawn, the rest as dashed blanks), then pieces seen elsewhere (a region's)
    $deck = [];
    if ($st) foreach (pfd_foe_row($ov, '')['deck'] as $p) {
        $n = (string)$p['n']; if (isset($deck[$n])) continue;
        $deck[$n] = ['t' => (string)$p['t'], 'v' => pfv_foe_v($ov, (int)$p['v']), 'tag' => (string)$p['tag'], 'ik' => (string)($p['ik'] ?? ''), 'e' => pfb_author_edges(['t' => $p['t'], 'r' => $p['r']], (string)$p['col'])];
    }
    $extra = array_diff_key($seen, $deck);
    $nAll = count($deck) + count($extra);
    $h .= '<h4>Pieces seen <span class="cx-cnt">' . count($seen) . ($st ? ' of ' . $nAll . (count($extra) ? '' : '+') : '') . '</span></h4>';
    if (!$st) $h .= '<p class="cx-lock">Meet it in a fight to see its pieces.</p>';
    else {
        $tint = (int)(crc32($slug) % 360);   // the creature's colour on its pieces, as in the fight (pfight_game.php)
        $h .= '<ul class="cx-pcs" data-pico="' . e(url('assets/img/pfight/pieces/')) . '">';
        foreach ($deck as $n => $d) {
            if (!array_key_exists($n, $seen)) { $h .= '<li class="cx-pc cx-q" aria-label="A piece not seen yet"><span class="cx-art"></span><span class="cx-nm">Not seen yet</span></li>'; continue; }
            $h .= pfcx_piece_li((string)$n, $d + (is_array($seen[$n]) ? $seen[$n] : []), $tint);   // the standard deck's value and look (the same as the pre-fight card)
        }
        foreach ($extra as $n => $sd) {
            $h .= is_array($sd) && $sd ? pfcx_piece_li((string)$n, $sd, $tint)
                : '<li class="cx-pc cx-old"><span class="cx-art"></span><span class="cx-nm">' . e((string)$n) . '</span><small class="cx-ty">Drawn after your next meeting</small></li>';   // seen before 2.7.57 and not in the standard deck
        }
        $h .= '</ul>' . (count($extra) ? '' : '<p class="cx-note">It may also play a piece of the region you meet it in.</p>');
    }
    if ($u !== null && $st && pfcx_drop_parts($slug)) {   // 2.7.58: donate its parts
        [$gv, $dn] = pfcx_parts_state((int)$u['id'], $slug); $need = max(1, (int)setting('codex_part_need')); $hv = pfcx_parts_held((int)$u['id'], $slug);
        $h .= '<h4>Parts</h4>' . ($dn ? '<p class="cx-parts">Donated. The Codex has what it needs of this creature’s parts.</p>'
            : '<p class="cx-parts">' . $gv . ' of ' . $need . ' given to the Codex. You carry ' . $hv . '.</p>'
              . ($hv > 0 ? '<form method="post" action="' . e(url('puzzlebox.php')) . '" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="cx_donate"><input type="hidden" name="c" value="' . e($slug) . '"><input type="hidden" name="z" value="' . e($size) . '"><button class="btn small">Give parts</button></form>'
                : '<p class="cx-note">Its parts come from beating it.</p>'));
    }
    return $h . '<p class="cx-foot"><a class="btn ghost small" href="' . $close . '">Back to the Codex</a></p></section></div>';
}

function pfcx_html(array $u, string $slug = '', string $size = 'all'): string
{
    $uid = (int)$u['id'];
    $list = pfcx_creatures();
    $st = []; $pc = [];
    if (pfcx_ensure()) foreach (q('SELECT slug, piece, won' . (pfcx_has_pd() ? ', pd' : '') . ' FROM pf_codex WHERE user_id = ?', [$uid]) as $r) {
        $s = (string)$r['slug'];
        if ((string)$r['piece'] === '') $st[$s] = ((int)$r['won'] ? 2 : 1);
        else { $d = isset($r['pd']) && $r['pd'] !== null ? json_decode((string)$r['pd'], true) : null; $pc[$s][(string)$r['piece']] = is_array($d) ? $d : null; }
    }
    $mine = array_intersect_key($st, $list);
    $met = count($mine); $won = count(array_filter($mine, fn($v) => $v > 1));
    $h = '<div class="cx"><div class="cx-head"><h3>Creature Codex</h3><span><b>' . $met . '</b> met · <b>' . $won . '</b> beaten · ' . count($list) . ' in all</span></div>'
        . '<progress class="cx-bar" max="' . max(1, count($list)) . '" value="' . $met . '" aria-label="Creatures met"></progress><nav class="cx-chips" aria-label="Size">';
    foreach (['all' => 'All', 'small' => 'Small', 'medium' => 'Medium', 'large' => 'Large', 'boss' => 'Boss'] as $k => $l) $h .= '<a href="' . e(pfcx_url($k)) . '"' . ($k === $size ? ' class="on" aria-current="page"' : '') . '>' . $l . '</a>';
    $h .= '</nav>' . ($met === 0 ? '<p class="cx-empty">No creatures yet. Meet one in a fight and it shows up here.</p>' : '') . '<div class="cx-grid">';
    foreach ($list as $c) { if ($size !== 'all' && $c['size'] !== $size) continue; $h .= pfcx_tile($c, $st[$c['slug']] ?? 0, count($pc[$c['slug']] ?? []), $size); }
    $h .= '</div>';
    if ($slug !== '' && isset($list[$slug])) $h .= pfcx_sheet($list[$slug], $st[$slug] ?? 0, $pc[$slug] ?? [], $size, $u);
    return $h . '</div><script src="' . e(url('assets/pfcodex.js?v=' . APP_VERSION)) . '" data-rerun defer></script>';
}
