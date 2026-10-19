<?php
declare(strict_types=1);

/**
 * v1.0.0 wave 3: townsfolk on every board.
 * NPC entries for the Village Show, the Grand Harvest Fair, Garden of the Month, the Arrangements show, the Snail Race and Pumpkin Carving.
 * They are made up on the spot from the NPC roster and a seed (the period and the board), so they are the same for everyone
 * all week and nothing is stored. They are clearly marked 🏡 and they are for company and a score to beat only:
 * the judging code never sees them, so they never take a prize, a place or a ribbon from a gnome. Where a board shows places,
 * the gnomes' places are counted among gnomes only. Switch off: setting townsfolk_entries.
 */

function townsfolk_on(): bool
{
    return setting('townsfolk_entries') === '1';
}

/** Small seeded generator whose numbers come from the high bits (so they look random). */
final class TownRng
{
    private int $s;
    public function __construct(string $seed) { $this->s = (crc32($seed) ^ 0x5bd1e995) & 0x7fffffff ?: 1; }
    public function next(): int
    {
        $this->s = ($this->s * 1103515245 + 12345) & 0x7fffffff;
        return $this->s >> 8;
    }
    /** Whole number from $min to $max. */
    public function int(int $min, int $max): int { return $max <= $min ? $min : $min + $this->next() % ($max - $min + 1); }
    /** A fraction from 0 up to just under 1. */
    public function frac(): float { return ($this->next() % 10000) / 10000; }
    public function pick(array $a) { return $a ? $a[array_keys($a)[$this->int(0, count($a) - 1)]] : null; }
}

/** The townsfolk who can enter: active NPCs (id, name, species), in a fixed order. */
function townsfolk_roster(): array
{
    static $r = null;
    return $r ??= q('SELECT id, name, slug, species FROM npcs WHERE active = 1 ORDER BY id')->fetchAll();
}

/** $n different townsfolk for a seed. */
function townsfolk_picks(string $seed, int $n): array
{
    $roster = townsfolk_roster();
    if (!$roster) return [];
    $rng = new TownRng($seed);
    $out = [];
    $guard = 0;
    while (count($out) < min($n, count($roster)) && $guard++ < 200) {
        $p = $roster[$rng->int(0, count($roster) - 1)];
        $out[(int)$p['id']] = $p;
    }
    return array_values($out);
}

/** The little marker shown next to a townsfolk entry. */
function townsfolk_tag(): string
{
    return '<span class="tfolk" title="Townsfolk enter for company. They never take a prize from a gnome.">🏡 townsfolk</span>';
}

/** One line of help text for a board that has townsfolk on it. */
function townsfolk_note(): string
{
    return '<p class="help tfnote">🏡 Townsfolk enter too, for company and a score to beat. Prizes and places are for gnomes only.</p>';
}

/**
 * Merge gnomes' rows and townsfolk rows into one list, best first by $field (higher is better).
 * Ties go to the gnome. Each gnome row gets 'prank' = their place among gnomes only (1, 2, 3 ...), which is what the prizes follow.
 */
function townsfolk_merge(array $players, array $folk, string $field): array
{
    $rank = 0;
    foreach ($players as &$p) { $p['prank'] = ++$rank; $p['npc'] = 0; }
    unset($p);
    $all = array_merge($players, $folk);
    $order = array_keys($all);
    usort($order, function ($a, $b) use ($all, $field) {
        $d = ($all[$b][$field] <=> $all[$a][$field]);
        if ($d !== 0) return $d;
        return ((int)$all[$a]['npc'] <=> (int)$all[$b]['npc']) ?: ($a <=> $b);
    });
    $out = [];
    foreach ($order as $i) $out[] = $all[$i];
    return $out;
}

// ---------------- Village Show ----------------

/** Townsfolk growers for this week's show crop: [['npc' => 1, 'gname', 'size', 'user_id' => 0], ...]. */
function townsfolk_show(string $week, string $crop): array
{
    if (!townsfolk_on() || !isset(SHOW_CROPS[$crop])) return [];
    $rng = new TownRng('show|' . $week . '|' . $crop);
    $base = SHOW_CROPS[$crop][2];
    $dec = SHOW_CROPS[$crop][3];
    $out = [];
    foreach (townsfolk_picks('showpick|' . $week, 3 + $rng->int(0, 2)) as $p) {
        $out[] = ['npc' => 1, 'user_id' => 0, 'gname' => (string)$p['name'], 'size' => round($base * (0.72 + $rng->frac() * 0.5), $dec)];
    }
    return $out;
}

// ---------------- Grand Harvest Fair ----------------

const TOWNSFOLK_JARS = ['Dill Pickles', 'Plum Jam', 'Pickled Beets', 'Sauerkraut', 'Apple Butter', 'Chilli Relish', 'Bean Kimchi', 'Rhubarb Chutney'];

/** Townsfolk entries in one fair class this month: [['npc' => 1, 'gname', 'crop', 'score']]. */
function townsfolk_fair(string $month, string $cat): array
{
    if (!townsfolk_on() || !isset(FAIR_CATS[$cat])) return [];
    $rng = new TownRng('fair|' . $month . '|' . $cat);
    $kinds = FAIR_CATS[$cat][2];
    $crops = $kinds ? q('SELECT name FROM plants WHERE kind IN (' . implode(',', array_fill(0, count($kinds), '?')) . ') ORDER BY id', $kinds)->fetchAll(PDO::FETCH_COLUMN) : TOWNSFOLK_JARS;
    if (!$crops) return [];
    $out = [];
    foreach (townsfolk_picks('fairpick|' . $month . '|' . $cat, 2 + $rng->int(0, 1)) as $p) {
        $out[] = ['npc' => 1, 'gname' => (string)$p['name'], 'crop' => (string)$rng->pick($crops), 'score' => 30 + $rng->int(0, 44)];
    }
    return $out;
}

// ---------------- Garden of the Month ----------------

const TOWNSFOLK_GARDENS = ['Window Box', 'Herb Corner', 'Cottage Patch', 'Sunny Strip', 'Pebble Path Garden', 'Moss Corner', 'Back Step Beds', 'Hedgerow Plot'];

/** Townsfolk gardens for the month. $topVotes = the most votes any gnome's entry has, so they sit near the real race. */
function townsfolk_gotm(string $month, int $topVotes): array
{
    if (!townsfolk_on()) return [];
    require_once __DIR__ . '/npc_life.php';   // npc_icon()
    $rng = new TownRng('gotm|' . $month);
    $out = [];
    foreach (townsfolk_picks('gotmpick|' . $month, 2 + $rng->int(0, 1)) as $p) {
        $first = explode(' ', trim((string)$p['name']))[0];
        $out[] = ['npc' => 1, 'id' => 0, 'uid' => 0, 'plot_id' => 0, 'garden_name' => $first . '’s ' . $rng->pick(TOWNSFOLK_GARDENS),
            'owner' => (string)$p['name'], 'icon' => npc_icon($p['species'] ?? ''), 'appeal' => 12 + $rng->int(0, 40),
            'votes' => (int)round(max(4, $topVotes + 1) * (0.25 + $rng->frac() * 0.75))];
    }
    return $out;
}

// ---------------- Arrangements show ----------------

const TOWNSFOLK_POSY_A = ['Meadow', 'Morning', 'Market', 'Sunday', 'Lantern', 'Dewdrop', 'Hedgerow', 'Cottage', 'Twilight', 'Honey'];
const TOWNSFOLK_POSY_B = ['Posy', 'Bouquet', 'Jar', 'Medley', 'Bunch', 'Nosegay', 'Gathering', 'Surprise'];

function townsfolk_arrangements(string $week): array
{
    if (!townsfolk_on()) return [];
    $rng = new TownRng('arr|' . $week);
    $out = [];
    foreach (townsfolk_picks('arrpick|' . $week, 2 + $rng->int(0, 1)) as $p) {
        $out[] = ['npc' => 1, 'gname' => (string)$p['name'], 'title' => $rng->pick(TOWNSFOLK_POSY_A) . ' ' . $rng->pick(TOWNSFOLK_POSY_B), 'score' => 38 + $rng->int(0, 42)];
    }
    return $out;
}

// ---------------- Snail Race ----------------

/** Townsfolk cheering from the stands: [snail index => [first names]]. Same for everyone for a given race. */
function townsfolk_cheer(string $race, int $snails): array
{
    if (!townsfolk_on() || $snails < 1) return [];
    $rng = new TownRng('cheer|' . $race);
    $out = [];
    foreach (townsfolk_picks('cheerpick|' . $race, 3 + $rng->int(0, 2)) as $p) {
        $out[$rng->int(0, $snails - 1)][] = explode(' ', trim((string)$p['name']))[0];
    }
    return $out;
}

// ---------------- Pumpkin Carving ----------------

const TOWNSFOLK_CARVE_TITLES = ['Grinning Gourd', 'Moonlit Mutterer', 'Sir Squash', 'Gap-Tooth Gus', 'The Surprised Pumpkin', 'Spooky Spud', 'Jolly Jack', 'Old Lantern Face'];

/** A 10 x 10 pattern string ('1' = cut) of a symmetric face. */
function townsfolk_face(TownRng $rng): string
{
    $g = array_fill(0, 100, '0');
    $cut = function (int $x, int $y) use (&$g): void { if ($x >= 0 && $x < 10 && $y >= 0 && $y < 10) $g[$y * 10 + $x] = '1'; };
    $eye = $rng->int(0, 2);
    foreach ([[2, 2], [6, 2]] as [$ex, $ey]) {
        if ($eye === 0) { $cut($ex, $ey); $cut($ex + 1, $ey); $cut($ex, $ey + 1); $cut($ex + 1, $ey + 1); }
        elseif ($eye === 1) { $cut($ex, $ey); $cut($ex, $ey + 1); $cut($ex, $ey + 2); }
        else { $cut($ex + 1, $ey); $cut($ex, $ey + 1); $cut($ex + 1, $ey + 1); }
    }
    $cut(4, 5); $cut(5, 5);
    if ($rng->int(0, 1)) { for ($x = 2; $x <= 7; $x++) $cut($x, 7); $cut(1, 6); $cut(8, 6); }
    else { foreach ([2, 4, 6] as $x) { $cut($x, 7); $cut($x + 1, 8); } }
    return implode('', $g);
}

function townsfolk_carvings(int $year, int $topVotes): array
{
    if (!townsfolk_on()) return [];
    $rng = new TownRng('carve|' . $year);
    $out = [];
    foreach (townsfolk_picks('carvepick|' . $year, 2 + $rng->int(0, 1)) as $p) {
        $out[] = ['npc' => 1, 'id' => 0, 'user_id' => 0, 'gname' => (string)$p['name'], 'title' => (string)$rng->pick(TOWNSFOLK_CARVE_TITLES),
            'pattern' => townsfolk_face($rng), 'votes' => (int)round(max(3, $topVotes + 1) * (0.2 + $rng->frac() * 0.8)), 'placed' => null, 'voted' => 1];
    }
    return $out;
}
