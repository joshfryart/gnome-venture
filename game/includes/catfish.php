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

const CATFISH_BASE_KPH = 600;           // kibble per hour with nothing bought
const CATFISH_OFFLINE_CAP = 8 * 3600;   // seconds of away time that count
const CATFISH_AWAY_AFTER = 300;         // a gap longer than this since the last tick counts as away (50%)
const CATFISH_GROWTH = 1.18;            // cost = base * growth^owned
const CATFISH_MILESTONES = [10, 25, 50];   // owned counts that double an upgrade's effect
const CATFISH_SHELTER = 3;              // cats on show per day
const CATFISH_MAX_CATS = 4;
const CATFISH_NAME_MAX = 20;
const CATFISH_SLOT_COSTS = [5, 20];     // Yarn for the 3rd and 4th place in the home
const CATFISH_RARE_COSTS = [3, 10];     // Yarn for Rare Shelter levels 1 and 2 (the shelter shows the best of 2, then 3, candidates per slot)
const CATFISH_REROLL_COST = 1;          // Yarn to swap one shelter cat for another
const CATFISH_REROLL_MAX = 3;           // rerolls per slot per day
/** Petal milestones: key => [label, base Petals (then scaled by game_petals())]. Each pays once, inside the weekly cap (setting catfish_petal_cap). */
const CATFISH_MILESTONES_PETALS = [
    'adopt1'    => ['Brought your first cat home', 20],
    'nap1'      => ['Took your first Nap', 40],
    'book12'    => ['12 coats in the Cat Book', 30],
    'nap5'      => ['Took five Naps', 80],
    'full4'     => ['Four cats at home', 60],
    'book_half' => ['Half the Cat Book', 100],
];

/** Branch key => label, in display order. */
const CATFISH_BRANCHES = ['fish' => '🐟 Fish', 'rod' => '🎣 Rod', 'room' => '🛋️ Room', 'cat' => '🐾 Cat'];
/** key => [name, icon, base cost, Kibble/hour added per level, share of the total added per level (0.05 = +5%), branch] */
const CATFISH_UPGRADES = [
    'fish'    => ['Plushie fish',   '🐟', 10,     48,   0.0,  'fish'],
    'silk'    => ['Silk tail',      '🎀', 150,    220,   0.0,  'fish'],
    'catnip'  => ['Catnip stuffing', '🌿', 2200,  1040,  0.0,  'fish'],
    'glitter' => ['Glitter scales', '✨', 30000,  4800, 0.0,  'fish'],
    'string'  => ['Longer string',  '🧵', 80,     160,   0.0,  'rod'],
    'spring'  => ['Springy rod',    '🪀', 600,    600,  0.0,  'rod'],
    'motor'   => ['Rod motor',      '⚙️', 4000,   2400,  0.0,  'rod'],
    'double'  => ['Double rod',     '🎣', 60000,  11200, 0.0,  'rod'],
    'sunbeam' => ['Sunbeam',        '☀️', 300,    0,    0.01, 'room'],
    'rug'     => ['Cosy rug',       '🧶', 2500,   0,    0.015, 'room'],
    'scratch' => ['Scratch post',   '🪵', 15000,  0,    0.02, 'room'],
    'window'  => ['Window bird',    '🐦', 90000,  0,    0.03, 'room'],
    'bowl'    => ['Fancy bowl',     '🥣', 1200,   0,    0.012, 'cat'],
    'toybox'  => ['Toy box',        '🧸', 9000,   0,    0.018, 'cat'],
    'cattree' => ['Cat tree',       '🌳', 55000,  0,    0.024, 'cat'],
    'catflap' => ['Cat flap',       '🚪', 320000, 0,    0.036, 'cat'],
];
const CATFISH_YARN_STEP = 0.10;        // Kibble multiplier = 1 + STEP * Yarn^POW
const CATFISH_YARN_POW = 0.6;          // below 1 so a huge pile of Yarn keeps paying, but ever more slowly
const CATFISH_NAP_ROOT = 3.0;          // Yarn from a Nap = floor((run / base)^(1/ROOT))
const CATFISH_MAX_KPH = 1.0e12;        // hard ceiling on Kibble/hour, so the sums can never reach the BIGINT edge
const CATFISH_MAX_COST = 1.0e15;
const CATFISH_NAP_BASE = 500;          // a Nap needs this much Kibble earned in the run
const CATFISH_RARE_PER_HOUR = 0.5;     // Sneaky cats: expected rare fish per hour, each worth a tenth of an hour's Kibble

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

/** A Cat Fish picture: the real PNG (assets/img/catfish/cf-<name>.png) when it exists, else the emoji placeholder. See claude/catfish-art-brief.md for the names. */
function catfish_img(string $name, string $fallback, string $alt = '', int $px = 48): string
{
    static $have = [];
    if (!preg_match('/^[a-z0-9_-]+$/', $name)) return '<span aria-hidden="true">' . $fallback . '</span>';
    $file = 'assets/img/catfish/cf-' . $name . '.png';
    $have[$name] ??= is_file(APP_ROOT . '/' . $file);
    if (!$have[$name]) return '<span aria-hidden="true">' . $fallback . '</span>';
    return '<img class="cfimg" src="' . e(url($file . '?v=' . APP_VERSION)) . '" alt="' . e($alt) . '" width="' . $px . '" height="' . $px . '">';
}

/** Is Cat Fish open to this viewer? (Admins always; players need the catfish_open setting.) */
function catfish_open(): bool
{
    return is_admin() || setting('catfish_open') === '1';
}

/** Create the tables the first time they're needed, and patch columns on databases made by earlier builds (same lazy pattern as puzzles_ensure()). */
function catfish_ensure(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    if (PHP_INT_SIZE < 8) return $ok = false;   // seeds and the RNG need 64-bit integers
    try { q('SELECT 1 FROM cats LIMIT 1'); q('SELECT adopted FROM cat_book LIMIT 1'); q('SELECT run_kibble, total_kibble, meta FROM catfish_state LIMIT 1'); q('SELECT 1 FROM cat_ribbons LIMIT 1'); return $ok = true; } catch (Throwable $e) {}
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
            active_cat_id $ID NULL, last_tick $ID NOT NULL DEFAULT 0, naps $ID NOT NULL DEFAULT 0, run_kibble BIGINT NOT NULL DEFAULT 0, total_kibble BIGINT NOT NULL DEFAULT 0, meta TEXT NULL, created_at DATETIME NOT NULL
        )$END");
        db()->exec("CREATE TABLE IF NOT EXISTS cat_book (
            user_id $ID NOT NULL, pattern VARCHAR(12) NOT NULL, colour VARCHAR(12) NOT NULL, adopted $ID NOT NULL DEFAULT 0, found_at DATETIME NOT NULL,
            PRIMARY KEY (user_id, pattern, colour)
        )$END");
        db()->exec("CREATE TABLE IF NOT EXISTS cat_ribbons (
            id $PK, user_id $ID NOT NULL, week VARCHAR(8) NOT NULL, theme VARCHAR(60) NOT NULL, cat_name VARCHAR(30) NOT NULL, tier VARCHAR(10) NOT NULL, score $ID NOT NULL DEFAULT 0, created_at DATETIME NOT NULL,
            UNIQUE (user_id, week)
        )$END");
        foreach ([['catfish_state', 'run_kibble', 'BIGINT NOT NULL DEFAULT 0'], ['catfish_state', 'total_kibble', 'BIGINT NOT NULL DEFAULT 0'], ['catfish_state', 'meta', 'TEXT NULL'], ['cat_book', 'adopted', 'INT NOT NULL DEFAULT 0']] as [$t, $col, $def]) {
            try { q('SELECT ' . $col . ' FROM ' . $t . ' LIMIT 1'); } catch (Throwable $e) { db()->exec('ALTER TABLE ' . $t . ' ADD COLUMN ' . $col . ' ' . $def); }
        }
        return $ok = true;
    } catch (Throwable $e) {
        error_log('catfish_ensure: ' . $e->getMessage());
        return $ok = false;
    }
}

// ---------- cat generator ----------

/** 32-bit unsigned multiply (Math.imul), done in 16-bit halves so PHP never overflows into a float. */
function catfish_mul32(int $a, int $b): int
{
    return ((($a & 0xFFFF) * $b) + (((($a >> 16) * $b) & 0xFFFF) << 16)) & 0xFFFFFFFF;
}

/** Seeded RNG (mulberry32, identical to the usual JS version). Returns a closure giving floats in [0, 1). */
function catfish_rng(int $seed): Closure
{
    $a = $seed & 0xFFFFFFFF;
    return function () use (&$a): float {
        $a = ($a + 0x6D2B79F5) & 0xFFFFFFFF;
        $t = catfish_mul32($a ^ ($a >> 15), 1 | $a);
        $t = (($t + catfish_mul32($t ^ ($t >> 7), 61 | $t)) & 0xFFFFFFFF) ^ $t;
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

/**
 * The day's shelter for a gnome: CATFISH_SHELTER cats, each ['slot' => n] + catfish_cat(). $day is 'Y-m-d' (UTC).
 * $rolls[slot] = rerolls bought today for that slot; $rare = Rare Shelter level (the best-scoring of 1 + $rare candidates is shown).
 * With no rolls and no Rare Shelter the seeds are the plain crc32(user|day|slot), so older shelters do not change.
 */
function catfish_shelter(int $uid, ?string $day = null, array $rolls = [], int $rare = 0): array
{
    $day = $day ?? gmdate('Y-m-d');
    $out = [];
    for ($slot = 0; $slot < CATFISH_SHELTER; $slot++) {
        $n = (int)($rolls[$slot] ?? 0); $best = null;
        for ($c = 0; $c <= $rare; $c++) {
            $cand = catfish_cat(crc32($uid . '|' . $day . '|' . $slot . ($n > 0 ? '|r' . $n : '') . ($c > 0 ? '|c' . $c : '')));
            if ($best === null || $cand['score'] > $best['score']) $best = $cand;
        }
        $best['slot'] = $slot;
        $out[] = $best;
    }
    return $out;
}

/** Today's shelter for a gnome with their rerolls and Rare Shelter level applied. */
function catfish_shelter_now(int $uid, ?array $meta = null): array
{
    $meta = $meta ?? catfish_state($uid)['meta'];
    $today = gmdate('Y-m-d');
    $rolls = ($meta['roll']['day'] ?? '') === $today ? (array)($meta['roll']['n'] ?? []) : [];
    return catfish_shelter($uid, $today, $rolls, (int)($meta['rare'] ?? 0));
}

/** Kibble price of the next adoption for a gnome who owns $owned cats. The first is free. */
function catfish_adopt_cost(int $owned): int
{
    return $owned <= 0 ? 0 : (int)(500 * 4 ** ($owned - 1));
}

/** Cats a gnome may own: 2, plus one per bigger-home upgrade (up to CATFISH_MAX_CATS). */
function catfish_slots(int $uid, ?array $state = null): int
{
    return min(CATFISH_MAX_CATS, 2 + (int)(($state ?? catfish_state($uid))['meta']['extra'] ?? 0));
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
        try { db_insert('catfish_state', ['user_id' => $uid, 'kibble' => 0, 'yarn' => 0, 'upgrades' => '{}', 'active_cat_id' => null, 'last_tick' => time(), 'naps' => 0, 'run_kibble' => 0, 'total_kibble' => 0, 'meta' => '{}', 'created_at' => now()]); }
        catch (Throwable $e) {}   // a second tab created it first
        $s = q_one('SELECT * FROM catfish_state WHERE user_id = ?', [$uid]);
    }
    $up = json_decode((string)($s['upgrades'] ?? ''), true);
    $s['up'] = is_array($up) ? array_map('intval', $up) : [];
    $meta = json_decode((string)($s['meta'] ?? ''), true);
    $s['meta'] = is_array($meta) ? $meta : [];
    return $s;
}

function catfish_cost(string $key, int $owned): int
{
    return (int)ceil(min(CATFISH_MAX_COST, CATFISH_UPGRADES[$key][2] * CATFISH_GROWTH ** $owned));
}

/** Effect multiplier of an upgrade: x2 at each milestone owned count reached. */
function catfish_milestone_mult(int $owned): int
{
    $m = 1;
    foreach (CATFISH_MILESTONES as $at) if ($owned >= $at) $m *= 2;
    return $m;
}

const CATFISH_PAL_STEP = 0.02;          // Puzzle Pals: +2% Kibble per pal found (needs Puzzle Pals open and gnome level 15)
const CATFISH_PAL_MAX = 10;             // ...for up to this many pals (+20%)
const CATFISH_PAL_LEVEL = 15;

/** Extra Kibble multiplier outside the Yarn maths: Puzzle Pals found (gnome level 15+, ppal_open). 1.0 when none. One cheap count per call, cached per request. */
function catfish_extra_mult(int $uid): float
{
    static $cache = [];
    if (isset($cache[$uid])) return $cache[$uid];
    $m = 1.0;
    try {
        require_once __DIR__ . '/puzzle_pals.php';
        if (ppal_open() && ppal_ensure() && (int)q_val('SELECT level FROM users WHERE id = ?', [$uid]) >= CATFISH_PAL_LEVEL) {
            $found = (int)q_val('SELECT COUNT(*) FROM ppal_found WHERE user_id = ?', [$uid]);
            $m += CATFISH_PAL_STEP * min($found, CATFISH_PAL_MAX);
        }
    } catch (Throwable $e) {}
    return $cache[$uid] = $m;
}

/** 2 while a festival is running (Yarn from a Nap doubles), else 1. */
function catfish_festival_mult(): int
{
    try { require_once __DIR__ . '/festival.php'; return festival_active() ? 2 : 1; } catch (Throwable $e) { return 1; }
}

/** Kibble multiplier from Yarn. */
function catfish_yarn_mult(int $yarn): float
{
    return 1 + CATFISH_YARN_STEP * max(0, $yarn) ** CATFISH_YARN_POW;
}

/** Kibble per hour for these owned levels and this cat (null = no cat yet). */
function catfish_kph(array $up, ?array $cat = null, bool $present = false, int $yarn = 0, float $extra = 1.0): float
{
    $add = CATFISH_BASE_KPH; $pct = 0.0;
    foreach (CATFISH_UPGRADES as $key => [, , , $a, $p]) {
        $n = (int)($up[$key] ?? 0);
        if ($n <= 0) continue;
        $mm = catfish_milestone_mult($n);
        $add += $a * $n * $mm;
        $pct += $p * $n * $mm;
    }
    $kph = $add * (1 + $pct) * catfish_yarn_mult($yarn) * max(1.0, $extra);
    $mood = $cat['mood'] ?? '';
    if ($mood === 'greedy') $kph *= 1.10;
    if ($mood === 'hyper' && $present) $kph *= 1.15;
    return min($kph, CATFISH_MAX_KPH);
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
        $eff = catfish_kph($s['up'], $cat, !$away, (int)$s['yarn'], catfish_extra_mult($uid)) * ($away ? 0.5 : 1);   // Kibble per hour actually paid
        $base = (int)floor(min($eff * $secs / 3600, PHP_INT_MAX >> 4));
        if ($base < 1) return $s;   // nothing whole earned yet: leave last_tick alone so the part-earned fraction is kept
        $gain = $base + (($cat['mood'] ?? '') === 'sneaky' ? catfish_rare_fish($eff, $secs, mt_rand() / (mt_getrandmax() + 1)) : 0);
        $tick = $secs < $gap ? $now : min($now, (int)$s['last_tick'] + (int)ceil($base * 3600 / $eff));   // clamped away time is dropped; otherwise move the clock only by the seconds paid
        $claim = q('UPDATE catfish_state SET kibble = kibble + ?, run_kibble = run_kibble + ?, total_kibble = total_kibble + ?, last_tick = ? WHERE user_id = ? AND last_tick = ?', [$gain, $gain, $gain, $tick, $uid, (int)$s['last_tick']])->rowCount();
        if ($claim === 1) { $s['kibble'] = (int)$s['kibble'] + $gain; $s['run_kibble'] = (int)$s['run_kibble'] + $gain; $s['last_tick'] = $tick; $s['gained'] = $gain; }
        return $s;
    });
}

/** Sneaky cats: a rare fish now and then, worth a tenth of an hour's Kibble. $r is a roll in [0, 1); pure, so the tests can pin it. */
function catfish_rare_fish(float $effKph, int $secs, float $r): int
{
    $chance = min(0.9, CATFISH_RARE_PER_HOUR * $secs / 3600);
    return $r < $chance ? (int)floor($effKph / 10) : 0;
}

/** Yarn a Nap would give for this run's Kibble (Dreamy cats add 10% before rounding down). 0 means the run is too short. */
function catfish_nap_yarn(int $runKibble, ?array $cat): int
{
    $y = max(0, $runKibble) / CATFISH_NAP_BASE;
    $y = $y >= 1 ? $y ** (1 / CATFISH_NAP_ROOT) : 0.0;
    if (($cat['mood'] ?? '') === 'dreamy') $y *= 1.10;
    return (int)floor(min($y, 1.0e9) + 1e-9);   // 64 ** (1/3) is 3.9999999999999996
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

function catfish_adopt(int $uid, int $slot, string $name, string $day = '', int $seed = 0): array
{
    if ($slot < 0 || $slot >= CATFISH_SHELTER) return [false, 'No such cat.'];
    return catfish_locked($uid, function () use ($uid, $slot, $name, $seed) {
        $s = catfish_tick($uid);
        $owned = (int)q_val('SELECT COUNT(*) FROM cats WHERE user_id = ?', [$uid]);
        if ($owned >= catfish_slots($uid)) return [false, 'Your home is full.'];
        $cat = catfish_shelter_now($uid, $s['meta'])[$slot];
        if ($seed > 0 && $cat['seed'] !== $seed) {
            // a form from before the UTC reset still adopts the cat it showed, but only in the first hour of the new day
            if (time() % 86400 >= 3600) return [false, 'The shelter changed. Reload the page and try again.'];
            $old = catfish_shelter($uid, gmdate('Y-m-d', time() - 86400), [], (int)($s['meta']['rare'] ?? 0))[$slot];
            if ($old['seed'] !== $seed) return [false, 'The shelter changed. Reload the page and try again.'];
            $cat = $old;
        }
        if (q_val('SELECT 1 FROM cats WHERE user_id = ? AND seed = ?', [$uid, $cat['seed']])) return [false, 'You already adopted that cat.'];
        $cost = catfish_adopt_cost($owned);
        if ($cost > 0 && q('UPDATE catfish_state SET kibble = kibble - ? WHERE user_id = ? AND kibble >= ?', [$cost, $uid, $cost])->rowCount() !== 1) return [false, 'Not enough Kibble.'];
        $clean = catfish_clean_name($name, $cat['name']);
        $id = db_insert('cats', ['user_id' => $uid, 'seed' => $cat['seed'], 'name' => $clean, 'adopted_at' => now()]);
        if (empty($s['active_cat_id'])) q('UPDATE catfish_state SET active_cat_id = ?, last_tick = ? WHERE user_id = ?', [$id, time(), $uid]);
        catfish_book_add($uid, $cat['pattern'], $cat['colour'], 1);
        catfish_claim_petals($uid);
        return [true, 'Welcome home, ' . $clean . '!'];
    });
}

// ---------- shelter upgrades (Yarn) and Petal milestones ----------

/** Yarn the gnome can still spend: all Yarn ever earned minus what shelter upgrades cost. Spending never lowers the Kibble bonus (that follows Yarn earned). */
function catfish_spendable(array $s): int
{
    return max(0, (int)$s['yarn'] - (int)($s['meta']['ys'] ?? 0));
}

function catfish_meta_save(int $uid, array $meta): void
{
    q('UPDATE catfish_state SET meta = ? WHERE user_id = ?', [json_encode($meta), $uid]);
}

/** Run one Yarn purchase: $fn(&$meta, $s) returns [cost, message] or a [false, message] refusal, inside the lock. */
function catfish_yarn_spend(int $uid, callable $fn): array
{
    return catfish_locked($uid, function () use ($uid, $fn) {
        $s = catfish_state($uid); $meta = $s['meta'];
        $r = $fn($meta, $s);
        if ($r[0] === false) return $r;
        [$cost, $msg] = $r;
        if (catfish_spendable($s) < $cost) return [false, 'Not enough Yarn.'];
        $meta['ys'] = (int)($meta['ys'] ?? 0) + $cost;
        catfish_meta_save($uid, $meta);
        return [true, $msg];
    });
}

function catfish_reroll(int $uid, int $slot): array
{
    if ($slot < 0 || $slot >= CATFISH_SHELTER) return [false, 'No such cat.'];
    return catfish_yarn_spend($uid, function (&$meta) use ($slot) {
        $today = gmdate('Y-m-d');
        $n = ($meta['roll']['day'] ?? '') === $today ? (array)($meta['roll']['n'] ?? []) : [];
        $n = array_replace([0, 0, 0], $n);
        if ($n[$slot] >= CATFISH_REROLL_MAX) return [false, 'That spot has had its swaps for today.'];
        $n[$slot]++;
        $meta['roll'] = ['day' => $today, 'n' => $n];
        return [CATFISH_REROLL_COST, 'A new cat is waiting.'];
    });
}

function catfish_buy_slot(int $uid): array
{
    return catfish_yarn_spend($uid, function (&$meta) {
        $extra = (int)($meta['extra'] ?? 0);
        if ($extra >= count(CATFISH_SLOT_COSTS)) return [false, 'Your home is as big as it gets.'];
        $meta['extra'] = $extra + 1;
        return [CATFISH_SLOT_COSTS[$extra], 'Room for ' . (2 + $extra + 1) . ' cats.'];
    });
}

function catfish_buy_rare(int $uid): array
{
    return catfish_yarn_spend($uid, function (&$meta) {
        $lvl = (int)($meta['rare'] ?? 0);
        if ($lvl >= count(CATFISH_RARE_COSTS)) return [false, 'The shelter already sends its best.'];
        $meta['rare'] = $lvl + 1;
        return [CATFISH_RARE_COSTS[$lvl], 'The shelter will show better cats.'];
    });
}

/** Which Petal milestones this gnome has reached. */
function catfish_milestones_reached(int $uid, array $s): array
{
    $cats = (int)q_val('SELECT COUNT(*) FROM cats WHERE user_id = ?', [$uid]);
    $book = count(catfish_book($uid));
    $half = (int)(count(CATFISH_TRAITS['pattern']) * count(CATFISH_TRAITS['colour']) / 2);
    return ['adopt1' => $cats >= 1, 'nap1' => (int)$s['naps'] >= 1, 'book12' => $book >= 12, 'nap5' => (int)$s['naps'] >= 5, 'full4' => $cats >= 4, 'book_half' => $book >= $half];
}

/** Pay reached milestones that have not been paid, as long as this ISO week's total stays inside the cap. Returns Petals paid. Safe to call often. */
function catfish_claim_petals(int $uid): int
{
    $cap = (int)setting('catfish_petal_cap');
    if ($cap <= 0) return 0;
    $seen = json_decode((string)q_val('SELECT meta FROM catfish_state WHERE user_id = ?', [$uid]), true);
    if (is_array($seen) && count((array)($seen['ms'] ?? [])) >= count(CATFISH_MILESTONES_PETALS)) return 0;   // all paid: no lock, no extra queries
    return catfish_locked($uid, function () use ($uid, $cap) {
        $s = catfish_state($uid); $meta = $s['meta'];
        $week = gmdate('o-\WW');
        $paid = ($meta['pw']['week'] ?? '') === $week ? (int)$meta['pw']['paid'] : 0;
        $done = (array)($meta['ms'] ?? []); $total = 0;
        foreach (catfish_milestones_reached($uid, $s) as $key => $hit) {
            if (!$hit || in_array($key, $done, true)) continue;
            $amount = min(game_petals(CATFISH_MILESTONES_PETALS[$key][1]), $cap);   // never bigger than the cap, so a milestone can always be paid in some week
            if ($paid + $total + $amount > $cap) continue;   // waits for next week
            $done[] = $key; $total += $amount;
        }
        if ($total > 0) {
            $meta['ms'] = $done; $meta['pw'] = ['week' => $week, 'paid' => $paid + $total];
            catfish_meta_save($uid, $meta);
            give_petals($uid, $total, 'catfish');
        }
        return $total;
    });
}

/** Nap: spend the run for Yarn. Upgrades and Kibble reset; cats, Yarn, the Cat Book and badges stay. */
function catfish_nap(int $uid): array
{
    return catfish_locked($uid, function () use ($uid) {
        $s = catfish_tick($uid);
        $cat = catfish_active($uid, $s);
        $y = catfish_nap_yarn((int)$s['run_kibble'], $cat) * catfish_festival_mult();
        if ($y < 1) return [false, 'Not enough Kibble earned this run to nap yet.'];
        $done = q('UPDATE catfish_state SET yarn = yarn + ?, naps = naps + 1, kibble = 0, run_kibble = 0, upgrades = ?, last_tick = ? WHERE user_id = ? AND run_kibble = ?', [$y, '{}', time(), $uid, (int)$s['run_kibble']])->rowCount();
        if ($done === 1) catfish_claim_petals($uid);
        return $done === 1 ? [true, 'Nap time! +' . $y . ' Yarn.'] : [false, 'Try that again.'];
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
    foreach (CATFISH_UPGRADES as $key => [$name, $icon, , $a, $p, $branch]) {
        $n = (int)($s['up'][$key] ?? 0); $cost = catfish_cost($key, $n);
        $ups[] = ['key' => $key, 'branch' => $branch, 'name' => $name, 'icon' => $icon, 'owned' => $n, 'cost' => $cost, 'can' => (int)$s['kibble'] >= $cost,
            'gives' => $a > 0 ? '+' . $a . ' Kibble/h each' : '+' . rtrim(rtrim(number_format($p * 100, 1), '0'), '.') . '% each', 'mult' => catfish_milestone_mult($n)];
    }
    return ['kibble' => (int)$s['kibble'], 'yarn' => (int)$s['yarn'], 'spend' => catfish_spendable($s), 'naps' => (int)$s['naps'], 'gained' => (int)$s['gained'],
        'kph' => $cat ? round(catfish_kph($s['up'], $cat, true, (int)$s['yarn'], catfish_extra_mult($uid)), 1) : 0, 'run' => (int)$s['run_kibble'], 'nap_yarn' => catfish_nap_yarn((int)$s['run_kibble'], $cat) * catfish_festival_mult(), 'cat' => $cat, 'ups' => $ups, 'now' => time()];
}

/** Badges, worked out from what the gnome has (nothing stored): [key => [icon, label]]. */
function catfish_badges(int $uid): array
{
    if (!catfish_ensure()) return [];
    $out = [];
    $cats = catfish_cats($uid);
    if ($cats) $out['first_cat'] = ['🐱', 'First adoption'];
    if (count($cats) >= 2) $out['full_house'] = ['🏠', 'Full house'];
    foreach ($cats as $c) {
        if ($c['eyes'] === 'odd') $out['odd_eyed'] = ['👀', 'Odd-eyed finder'];
        if ($c['rarity'] === 'legendary') $out['legendary'] = ['🌟', 'Legendary cat'];
    }
    $naps = (int)q_val('SELECT naps FROM catfish_state WHERE user_id = ?', [$uid]);
    if ($naps >= 1) $out['nap1'] = ['😴', 'First nap'];
    if ($naps >= 5) $out['nap5'] = ['💤', 'Five naps'];
    $book = catfish_book($uid);
    $entries = count($book); $all = count(CATFISH_TRAITS['pattern']) * count(CATFISH_TRAITS['colour']);
    if ($entries >= 12) $out['book12'] = ['📖', 'Cat Book: 12 coats'];
    if ($entries >= (int)($all / 2)) $out['book_half'] = ['📚', 'Cat Book: half full'];
    if ($entries >= $all) $out['book_full'] = ['🏅', 'Cat Book: every coat'];
    return $out;
}

/** Put a pattern and colour in the Cat Book ($adopted 1 = taken home, 0 = only seen at the shelter). Never downgrades an adopted entry. */
function catfish_book_add(int $uid, string $pattern, string $colour, int $adopted): void
{
    $row = q_one('SELECT adopted FROM cat_book WHERE user_id = ? AND pattern = ? AND colour = ?', [$uid, $pattern, $colour]);
    if (!$row) { try { db_insert('cat_book', ['user_id' => $uid, 'pattern' => $pattern, 'colour' => $colour, 'adopted' => $adopted, 'found_at' => now()]); return; } catch (Throwable $e) {} }   // a second tab won the insert: fall through to the update
    if ($adopted && (!$row || !(int)$row['adopted'])) q('UPDATE cat_book SET adopted = 1 WHERE user_id = ? AND pattern = ? AND colour = ?', [$uid, $pattern, $colour]);
}

/** The Cat Book: list of [pattern, colour, adopted] the gnome has seen at the shelter or taken home. */
function catfish_book(int $uid): array
{
    return array_map(fn($r) => [$r['pattern'], $r['colour'], (int)$r['adopted']], q('SELECT pattern, colour, adopted FROM cat_book WHERE user_id = ?', [$uid])->fetchAll());
}

// ---------- Cat Show (weekly, cosmetic ribbons) ----------

/** Ribbon tiers: tier => [min score, icon, label]. Highest first. A cat that scores under the last one still gets "Took part". */
const CATFISH_RIBBONS = ['best' => [40, '🏆', 'Best in Show'], 'blue' => [32, '🥇', 'Blue ribbon'], 'red' => [25, '🥈', 'Red ribbon'], 'white' => [18, '🥉', 'White ribbon']];
const CATFISH_RIBBON_PART = ['part', '🎗️', 'Took part'];
const CATFISH_SHOW_THEME_MATCH = 12;   // score for a cat that fits the week's theme
const CATFISH_SHOW_RARITY = ['common' => 0, 'uncommon' => 3, 'rare' => 6, 'legendary' => 10];

/** ISO week key like '2026-W44' (UTC): the show runs Monday to Sunday. */
function catfish_show_week(?int $ts = null): string
{
    return gmdate('o-\\WW', $ts ?? time());
}

/** This week's theme: ['trait' => 'pattern', 'value' => 'tabby', 'label' => 'Best tabby coat']. Only fairly common values, so every gnome can hope to match. */
function catfish_show_theme(string $week): array
{
    $traits = ['pattern' => 'Best %s coat', 'colour' => 'Best %s cat', 'eyes' => 'Best %s eyes', 'mood' => 'Most %s cat'];
    $rng = catfish_rng(crc32('show|' . $week));
    $keys = array_keys($traits);
    $trait = $keys[(int)floor($rng() * count($keys))];
    $values = array_keys(array_filter(CATFISH_TRAITS[$trait], fn($w) => $w >= 8));
    $value = $values[(int)floor($rng() * count($values))];
    return ['trait' => $trait, 'value' => $value, 'label' => sprintf($traits[$trait], $value)];
}

/**
 * Three judges (0 to 10 each, seeded by gnome, week and cat so a refresh cannot re-roll them) plus the theme and rarity bonuses.
 * Kibble, Yarn and play time are not part of it. Pure: returns ['score' => n, 'tier' => 'blue', 'judges' => [..]].
 */
function catfish_show_judge(int $uid, string $week, array $cat, array $theme): array
{
    $rng = catfish_rng(crc32('judge|' . $uid . '|' . $week . '|' . $cat['seed']));
    $judges = [(int)floor($rng() * 11), (int)floor($rng() * 11), (int)floor($rng() * 11)];
    $score = array_sum($judges) + (($cat[$theme['trait']] ?? '') === $theme['value'] ? CATFISH_SHOW_THEME_MATCH : 0) + (CATFISH_SHOW_RARITY[$cat['rarity']] ?? 0);
    $tier = CATFISH_RIBBON_PART[0];
    foreach (CATFISH_RIBBONS as $t => [$min]) if ($score >= $min) { $tier = $t; break; }
    return ['score' => $score, 'tier' => $tier, 'judges' => $judges];
}

/** Enter (or swap) a cat for this week's show. One entry per gnome per week. */
function catfish_show_enter(int $uid, int $catId): array
{
    $row = q_one('SELECT id FROM cats WHERE id = ? AND user_id = ?', [$catId, $uid]);
    if (!$row) return [false, 'No such cat.'];
    return catfish_locked($uid, function () use ($uid, $catId) {
        catfish_show_settle($uid);   // an old entry gets its ribbon before a new one replaces it
        $s = catfish_state($uid); $meta = $s['meta'];
        $week = catfish_show_week();
        if (q_val('SELECT 1 FROM cat_ribbons WHERE user_id = ? AND week = ?', [$uid, $week])) return [false, 'This week is already judged.'];
        $meta['show'] = ['week' => $week, 'cat' => $catId];
        catfish_meta_save($uid, $meta);
        return [true, 'Entered. The judges decide when the week ends.'];
    });
}

/** Judge an entry from a finished week and hand out its ribbon (one row per gnome and week; the unique key is the claim). Returns the ribbon row or null. Safe to call often. */
function catfish_show_settle(int $uid): ?array
{
    $seen = json_decode((string)q_val('SELECT meta FROM catfish_state WHERE user_id = ?', [$uid]), true);
    $e = is_array($seen) ? ($seen['show'] ?? null) : null;
    if (!is_array($e) || ($e['week'] ?? '') >= catfish_show_week()) return null;   // nothing entered, or the week is still running
    return catfish_locked($uid, function () use ($uid) {
        $s = catfish_state($uid); $meta = $s['meta'];
        $e = $meta['show'] ?? null;
        if (!is_array($e) || ($e['week'] ?? '') >= catfish_show_week()) return null;
        unset($meta['show']);
        $row = q_one('SELECT * FROM cats WHERE id = ? AND user_id = ?', [(int)$e['cat'], $uid]);
        catfish_meta_save($uid, $meta);
        if (!$row) return null;
        $cat = catfish_cat((int)$row['seed']);
        $theme = catfish_show_theme((string)$e['week']);
        $j = catfish_show_judge($uid, (string)$e['week'], $cat, $theme);
        $r = ['user_id' => $uid, 'week' => (string)$e['week'], 'theme' => $theme['label'], 'cat_name' => (string)$row['name'], 'tier' => $j['tier'], 'score' => $j['score'], 'created_at' => now()];
        try { db_insert('cat_ribbons', $r); } catch (Throwable $ex) { return null; }   // already judged
        return $r;
    });
}

/** A gnome's ribbons, newest first. */
function catfish_ribbons(int $uid, int $limit = 20): array
{
    if (!catfish_ensure()) return [];
    return q('SELECT * FROM cat_ribbons WHERE user_id = ? ORDER BY week DESC LIMIT ' . (int)$limit, [$uid])->fetchAll();
}

/** [icon, label] for a ribbon tier. */
function catfish_ribbon_face(string $tier): array
{
    return isset(CATFISH_RIBBONS[$tier]) ? [CATFISH_RIBBONS[$tier][1], CATFISH_RIBBONS[$tier][2]] : [CATFISH_RIBBON_PART[1], CATFISH_RIBBON_PART[2]];
}

/** The active cat on the garden page: a small tinted block and a line of flavour from its personality. '' when there is no cat or Cat Fish is closed. */
function catfish_garden_html(int $uid): string
{
    if (!catfish_open() || !catfish_ensure()) return '';
    $s = q_one('SELECT active_cat_id FROM catfish_state WHERE user_id = ?', [$uid]);   // read only: just visiting the garden must not create a Cat Fish row
    $cat = $s ? catfish_active($uid, $s) : null;
    if (!$cat) return '';
    $spot = ['lazy' => 'dozing on a warm bed', 'hyper' => 'zooming between the beds', 'sneaky' => 'hiding in the leaves', 'greedy' => 'guarding the harvest basket', 'dreamy' => 'watching the clouds'][$cat['mood']] ?? 'sitting in the garden';
    return '<p class="cfgarden"><span class="cfcat c-' . e($cat['colour']) . ' p-' . e($cat['pattern']) . '" aria-hidden="true">🐱</span> <small>' . e($cat['name']) . ' is ' . e($spot) . '. <a href="' . e(url('catfish.php')) . '">Cat Fish</a></small></p>';
}

/** Profile block: a gnome's Cat Fish badges as a list, '' if none or Cat Fish is closed. */
function catfish_badges_html(int $uid): string
{
    if (!catfish_open()) return '';
    $h = '';
    foreach (catfish_badges($uid) as $key => [$icon, $label]) $h .= '<li class="cfbadge" title="' . e($label) . '">' . catfish_img('badge-' . $key, $icon, '', 32) . '<small>' . e($label) . '</small></li>';
    foreach (catfish_ribbons($uid, 8) as $r) {
        [$icon, $label] = catfish_ribbon_face((string)$r['tier']);
        $h .= '<li class="cfbadge cfribbon" title="' . e($r['theme'] . ' · ' . $r['cat_name']) . '">' . catfish_img('ribbon-' . $r['tier'], $icon, '', 32) . '<small>' . e($label . ': ' . $r['cat_name']) . '</small></li>';
    }
    return $h === '' ? '' : '<ul class="pzbadges cfbadges">' . $h . '</ul>';
}
