<?php
declare(strict_types=1);
/**
 * Cat Fish (Lazy Rod), build step 1: data, cat generator, shelter, tick, upgrades. Plan: claude/plan-catfish.md.
 * Every name here starts catfish_ (cf_ for tables). Behind the setting catfish_open (admins always).
 *
 * A cat is ONE integer seed; every trait comes from a seeded RNG, so a cat is never stored beyond (user_id, seed, name).
 * The shelter shows 3 cats a day per gnome: seed = crc32(user_id|date|slot), re-derived on the server at adoption time.
 * Kibble is earned on the server clock only (catfish_tick): 100% while the page is polling, 50% when away, capped at CATFISH_OFFLINE_CAP seconds.
 */

const CATFISH_BASE_KPH = 60;            // kibble per hour with nothing bought
const CATFISH_OFFLINE_CAP = 8 * 3600;   // seconds of away time that count
const CATFISH_AWAY_AFTER = 300;         // a gap longer than this since the last tick counts as away (50%)
const CATFISH_GROWTH = 1.15;            // cost = base * growth^owned
const CATFISH_MILESTONES = [10, 25, 50];   // owned counts that double an upgrade's effect
const CATFISH_SHELTER = 3;              // cats on show per day
const CATFISH_MAX_CATS = 4;
const CATFISH_NAME_MAX = 20;

/** key => [name, icon, base cost, kibble/hour added per level, share of total added per level (0.05 = +5%)] */
const CATFISH_UPGRADES = [
    'fish'    => ['Plushie fish',   '🐟', 10,    12,  0.0],
    'string'  => ['Longer string',  '🧵', 80,    40,  0.0],
    'spring'  => ['Springy rod',    '🎣', 600,   150, 0.0],
    'motor'   => ['Rod motor',      '⚙️', 4000,  600, 0.0],
    'sunbeam' => ['Sunbeam',        '☀️', 300,   0,   0.05],
    'rug'     => ['Cosy rug',       '🧶', 2500,  0,   0.08],
    'scratch' => ['Scratch post',   '🪵', 15000, 0,   0.10],
    'window'  => ['Window bird',    '🐦', 90000, 0,   0.15],
];

/** trait => [value => weight]. Rarer value = smaller weight. */
const CATFISH_TRAITS = [
    'pattern' => ['solid' => 30, 'tabby' => 28, 'tuxedo' => 18, 'calico' => 12, 'pointed' => 8, 'spotted' => 4],
    'colour'  => ['ginger' => 22, 'black' => 20, 'grey' => 20, 'cream' => 14, 'white' => 12, 'brown' => 8, 'lilac' => 3, 'silver' => 1],
    'eyes'    => ['amber' => 30, 'green' => 30, 'blue' => 20, 'hazel' => 18, 'odd' => 2],
    'ears'    => ['upright' => 85, 'folded' => 15],
    'tail'    => ['long' => 85, 'bobtail' => 15],
    'mood'    => ['lazy' => 20, 'hyper' => 20, 'sneaky' => 20, 'greedy' => 20, 'dreamy' => 20],
];
const CATFISH_QUIRKS = ['sleeps in a box', 'hates cucumbers', 'chirps at birds', 'knocks things off shelves', 'loves a sunbeam', 'steals one sock'];
const CATFISH_QUIRK_CHANCE = 6;   // 1 in 6 cats has one
const CATFISH_NAMES = ['Biscuit', 'Pickle', 'Mochi', 'Nutmeg', 'Clover', 'Pebble', 'Maple', 'Tansy', 'Fennel', 'Sorrel', 'Thimble', 'Bramble', 'Juniper', 'Poppy', 'Marmalade', 'Whisk', 'Truffle', 'Cricket', 'Dumpling', 'Sprout'];
/** Rarity bands on the summed -log2(probability) of a cat's traits (tuned by tests/catfish.sh's distribution check). */
const CATFISH_RARITY = ['common' => 0.0, 'uncommon' => 10.8, 'rare' => 12.6, 'legendary' => 16.3];   // about 50 / 30 / 18.5 / 1.5 percent of cats

/** Is Cat Fish open to this viewer? (Admins always; players need the catfish_open setting.) */
function catfish_open(): bool
{
    return is_admin() || setting('catfish_open') === '1';
}

/** Create the three tables the first time they're needed (same lazy pattern as puzzles_ensure()). */
function catfish_ensure(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    try { q('SELECT 1 FROM cats LIMIT 1'); q('SELECT 1 FROM catfish_state LIMIT 1'); q('SELECT 1 FROM cat_book LIMIT 1'); return $ok = true; } catch (Throwable $e) {}
    try {
        $s = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite';
        $PK = $s ? 'INTEGER PRIMARY KEY AUTOINCREMENT' : 'INT UNSIGNED AUTO_INCREMENT PRIMARY KEY';
        $ID = $s ? 'INTEGER' : 'INT UNSIGNED';
        $END = $s ? '' : ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci';
        db()->exec("CREATE TABLE IF NOT EXISTS cats (
            id $PK, user_id $ID NOT NULL, seed $ID NOT NULL, name VARCHAR(30) NOT NULL, adopted_at DATETIME NOT NULL,
            UNIQUE (user_id, seed)
        )$END");
        db()->exec("CREATE TABLE IF NOT EXISTS catfish_state (
            user_id $ID NOT NULL PRIMARY KEY, kibble BIGINT NOT NULL DEFAULT 0, yarn $ID NOT NULL DEFAULT 0, upgrades TEXT NULL,
            active_cat_id $ID NULL, last_tick $ID NOT NULL DEFAULT 0, naps $ID NOT NULL DEFAULT 0, created_at DATETIME NOT NULL
        )$END");
        db()->exec("CREATE TABLE IF NOT EXISTS cat_book (
            user_id $ID NOT NULL, pattern VARCHAR(12) NOT NULL, colour VARCHAR(12) NOT NULL, found_at DATETIME NOT NULL,
            PRIMARY KEY (user_id, pattern, colour)
        )$END");
        return $ok = true;
    } catch (Throwable $e) {
        error_log('catfish_ensure: ' . $e->getMessage());
        return $ok = false;
    }
}

// ---------- cat generator ----------

/** Seeded RNG (mulberry32). Returns a closure giving floats in [0, 1). */
function catfish_rng(int $seed): Closure
{
    $a = $seed & 0xFFFFFFFF;
    return function () use (&$a): float {
        $a = ($a + 0x6D2B79F5) & 0xFFFFFFFF;
        $t = $a;
        $t = (($t ^ ($t >> 15)) * ($t | 1)) & 0xFFFFFFFF;
        $t ^= ($t + ((($t ^ ($t >> 7)) * ($t | 61)) & 0xFFFFFFFF)) & 0xFFFFFFFF;
        return (($t ^ ($t >> 14)) & 0xFFFFFFFF) / 4294967296;
    };
}

/** Weighted pick; also returns the pick's probability. */
function catfish_pick(array $weights, float $r): array
{
    $sum = array_sum($weights); $x = $r * $sum;
    foreach ($weights as $k => $w) { if ($x < $w) return [$k, $w / $sum]; $x -= $w; }
    $k = array_key_last($weights);
    return [$k, $weights[$k] / $sum];
}

/** Every trait of the cat with this seed, plus a rarity score and band. Pure: same seed, same cat, always. */
function catfish_cat(int $seed): array
{
    $seed &= 0xFFFFFFFF;
    $rng = catfish_rng($seed);
    $cat = ['seed' => $seed]; $bits = 0.0;
    foreach (CATFISH_TRAITS as $trait => $weights) {
        [$v, $p] = catfish_pick($weights, $rng());
        $cat[$trait] = $v; $bits += -log($p, 2);
    }
    $cat['quirk'] = '';
    if ($rng() < 1 / CATFISH_QUIRK_CHANCE) {
        $cat['quirk'] = CATFISH_QUIRKS[(int)floor($rng() * count(CATFISH_QUIRKS))];
        $bits += log(CATFISH_QUIRK_CHANCE, 2);
    } else {
        $rng();   // keep the stream the same length either way
    }
    $cat['name'] = CATFISH_NAMES[(int)floor($rng() * count(CATFISH_NAMES))];
    $cat['score'] = round($bits, 2);
    $band = 'common';
    foreach (CATFISH_RARITY as $b => $min) if ($bits >= $min) $band = $b;
    $cat['rarity'] = $band;
    return $cat;
}

/** The day's shelter for a gnome: CATFISH_SHELTER cats, each ['slot' => n] + catfish_cat(). $day is 'Y-m-d' (UTC). */
function catfish_shelter(int $uid, ?string $day = null): array
{
    $day = $day ?? gmdate('Y-m-d');
    $out = [];
    for ($slot = 0; $slot < CATFISH_SHELTER; $slot++) {
        $c = catfish_cat(crc32($uid . '|' . $day . '|' . $slot));
        $c['slot'] = $slot;
        $out[] = $c;
    }
    return $out;
}

/** Kibble price of the next adoption for a gnome who owns $owned cats. The first is free. */
function catfish_adopt_cost(int $owned): int
{
    return $owned <= 0 ? 0 : (int)(500 * 4 ** ($owned - 1));
}

/** Cats a gnome may own (raised by shelter upgrades in a later step). */
function catfish_slots(int $uid): int
{
    return 2;
}

// ---------- state and tick ----------

/** Run $fn inside a per-gnome lock (a transaction that touches the users row), so two tabs cannot double-spend. */
function catfish_locked(int $uid, callable $fn)
{
    $own = !db()->inTransaction();
    if ($own) db()->beginTransaction();
    try {
        q('UPDATE users SET id = id WHERE id = ?', [$uid]);
        $r = $fn();
        if ($own) db()->commit();
        return $r;
    } catch (Throwable $e) {
        if ($own && db()->inTransaction()) db()->rollBack();
        throw $e;
    }
}

/** The gnome's Cat Fish row, created on first sight. */
function catfish_state(int $uid): array
{
    $s = q_one('SELECT * FROM catfish_state WHERE user_id = ?', [$uid]);
    if (!$s) {
        try { db_insert('catfish_state', ['user_id' => $uid, 'kibble' => 0, 'yarn' => 0, 'upgrades' => '{}', 'active_cat_id' => null, 'last_tick' => time(), 'naps' => 0, 'created_at' => now()]); }
        catch (Throwable $e) {}   // a second tab created it first
        $s = q_one('SELECT * FROM catfish_state WHERE user_id = ?', [$uid]);
    }
    $up = json_decode((string)($s['upgrades'] ?? ''), true);
    $s['up'] = is_array($up) ? array_map('intval', $up) : [];
    return $s;
}

function catfish_cost(string $key, int $owned): int
{
    return (int)ceil(CATFISH_UPGRADES[$key][2] * CATFISH_GROWTH ** $owned);
}

/** Effect multiplier of an upgrade: x2 at each milestone owned count reached. */
function catfish_milestone_mult(int $owned): int
{
    $m = 1;
    foreach (CATFISH_MILESTONES as $at) if ($owned >= $at) $m *= 2;
    return $m;
}

/** Kibble per hour for these owned levels and this cat (null = no cat yet). */
function catfish_kph(array $up, ?array $cat = null, bool $present = false): float
{
    $add = CATFISH_BASE_KPH; $pct = 0.0;
    foreach (CATFISH_UPGRADES as $key => [, , , $a, $p]) {
        $n = (int)($up[$key] ?? 0);
        if ($n <= 0) continue;
        $mm = catfish_milestone_mult($n);
        $add += $a * $n * $mm;
        $pct += $p * $n * $mm;
    }
    $kph = $add * (1 + $pct);
    $mood = $cat['mood'] ?? '';
    if ($mood === 'greedy') $kph *= 1.10;
    if ($mood === 'hyper' && $present) $kph *= 1.15;
    return $kph;
}

/** Seconds of away time that count for this cat. */
function catfish_offline_cap(?array $cat): int
{
    return (int)(CATFISH_OFFLINE_CAP * (($cat['mood'] ?? '') === 'lazy' ? 1.25 : 1));
}

/** The gnome's active cat as a full trait array, or null. */
function catfish_active(int $uid, array $s): ?array
{
    if (empty($s['active_cat_id'])) return null;
    $row = q_one('SELECT * FROM cats WHERE id = ? AND user_id = ?', [(int)$s['active_cat_id'], $uid]);
    if (!$row) return null;
    $c = catfish_cat((int)$row['seed']);
    $c['id'] = (int)$row['id']; $c['name'] = (string)$row['name'];
    return $c;
}

/** Pay out kibble earned since the last tick (server clock only). Returns the fresh state, plus 'gained'. */
function catfish_tick(int $uid): array
{
    return catfish_locked($uid, function () use ($uid) {
        $s = catfish_state($uid);
        $cat = catfish_active($uid, $s);
        $now = time(); $gap = max(0, $now - (int)$s['last_tick']);
        $s['gained'] = 0;
        if (!$cat || $gap < 1) return $s;
        $away = $gap > CATFISH_AWAY_AFTER;
        $secs = $away ? min($gap, catfish_offline_cap($cat)) : $gap;
        $gain = (int)floor(catfish_kph($s['up'], $cat, !$away) * $secs / 3600 * ($away ? 0.5 : 1));
        $claim = q('UPDATE catfish_state SET kibble = kibble + ?, last_tick = ? WHERE user_id = ? AND last_tick = ?', [$gain, $now, $uid, (int)$s['last_tick']])->rowCount();
        if ($claim === 1) { $s['kibble'] = (int)$s['kibble'] + $gain; $s['last_tick'] = $now; $s['gained'] = $gain; }
        return $s;
    });
}

// ---------- actions (each returns [ok, message]) ----------

function catfish_buy(int $uid, string $key): array
{
    if (!isset(CATFISH_UPGRADES[$key])) return [false, 'No such upgrade.'];
    return catfish_locked($uid, function () use ($uid, $key) {
        $s = catfish_tick($uid);
        $owned = (int)($s['up'][$key] ?? 0); $cost = catfish_cost($key, $owned);
        if ((int)$s['kibble'] < $cost) return [false, 'Not enough Kibble.'];
        $s['up'][$key] = $owned + 1;
        $paid = q('UPDATE catfish_state SET kibble = kibble - ?, upgrades = ? WHERE user_id = ? AND kibble >= ?', [$cost, json_encode($s['up']), $uid, $cost])->rowCount();
        return $paid === 1 ? [true, CATFISH_UPGRADES[$key][0] . ' bought.'] : [false, 'Not enough Kibble.'];
    });
}

function catfish_clean_name(string $name, string $fallback): string
{
    $name = trim(preg_replace('/[^\p{L}\p{N} \'-]/u', '', $name) ?? '');
    $name = mb_substr($name, 0, CATFISH_NAME_MAX);
    return $name !== '' ? $name : $fallback;
}

function catfish_adopt(int $uid, int $slot, string $name): array
{
    if ($slot < 0 || $slot >= CATFISH_SHELTER) return [false, 'No such cat.'];
    return catfish_locked($uid, function () use ($uid, $slot, $name) {
        $s = catfish_tick($uid);
        $owned = (int)q_val('SELECT COUNT(*) FROM cats WHERE user_id = ?', [$uid]);
        if ($owned >= catfish_slots($uid)) return [false, 'Your home is full.'];
        $cat = catfish_shelter($uid)[$slot];
        if (q_val('SELECT 1 FROM cats WHERE user_id = ? AND seed = ?', [$uid, $cat['seed']])) return [false, 'You already adopted that cat.'];
        $cost = catfish_adopt_cost($owned);
        if ($cost > 0 && q('UPDATE catfish_state SET kibble = kibble - ? WHERE user_id = ? AND kibble >= ?', [$cost, $uid, $cost])->rowCount() !== 1) return [false, 'Not enough Kibble.'];
        $id = db_insert('cats', ['user_id' => $uid, 'seed' => $cat['seed'], 'name' => catfish_clean_name($name, $cat['name']), 'adopted_at' => now()]);
        if (empty($s['active_cat_id'])) q('UPDATE catfish_state SET active_cat_id = ?, last_tick = ? WHERE user_id = ?', [$id, time(), $uid]);
        try { db_insert('cat_book', ['user_id' => $uid, 'pattern' => $cat['pattern'], 'colour' => $cat['colour'], 'found_at' => now()]); } catch (Throwable $e) {}   // already in the book
        return [true, 'Welcome home, ' . $cat['name'] . '!'];
    });
}

function catfish_switch(int $uid, int $catId): array
{
    return catfish_locked($uid, function () use ($uid, $catId) {
        if (!q_val('SELECT 1 FROM cats WHERE id = ? AND user_id = ?', [$catId, $uid])) return [false, 'No such cat.'];
        catfish_tick($uid);   // pay the old cat first
        q('UPDATE catfish_state SET active_cat_id = ?, last_tick = ? WHERE user_id = ?', [$catId, time(), $uid]);
        return [true, 'Switched.'];
    });
}

function catfish_rename(int $uid, int $catId, string $name): array
{
    $row = q_one('SELECT seed FROM cats WHERE id = ? AND user_id = ?', [$catId, $uid]);
    if (!$row) return [false, 'No such cat.'];
    q('UPDATE cats SET name = ? WHERE id = ? AND user_id = ?', [catfish_clean_name($name, catfish_cat((int)$row['seed'])['name']), $catId, $uid]);
    return [true, 'Renamed.'];
}

/** A gnome's cats as full trait arrays. */
function catfish_cats(int $uid): array
{
    $out = [];
    foreach (q('SELECT * FROM cats WHERE user_id = ? ORDER BY id', [$uid])->fetchAll() as $r) {
        $c = catfish_cat((int)$r['seed']); $c['id'] = (int)$r['id']; $c['name'] = (string)$r['name'];
        $out[] = $c;
    }
    return $out;
}

/** Everything the page and the JS need for one gnome, after paying out the tick. */
function catfish_view(int $uid): array
{
    $s = catfish_tick($uid);
    $cat = catfish_active($uid, $s);
    $ups = [];
    foreach (CATFISH_UPGRADES as $key => [$name, $icon, , $a, $p]) {
        $n = (int)($s['up'][$key] ?? 0); $cost = catfish_cost($key, $n);
        $ups[] = ['key' => $key, 'name' => $name, 'icon' => $icon, 'owned' => $n, 'cost' => $cost, 'can' => (int)$s['kibble'] >= $cost,
            'gives' => $a > 0 ? '+' . $a . ' Kibble/h each' : '+' . (int)round($p * 100) . '% each', 'mult' => catfish_milestone_mult($n)];
    }
    return ['kibble' => (int)$s['kibble'], 'yarn' => (int)$s['yarn'], 'naps' => (int)$s['naps'], 'gained' => (int)$s['gained'],
        'kph' => $cat ? round(catfish_kph($s['up'], $cat, true), 1) : 0, 'cat' => $cat, 'ups' => $ups, 'now' => time()];
}
