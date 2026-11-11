<?php
declare(strict_types=1);
require_once __DIR__ . '/pfight_data.php';
/**
 * Puzzle Combat engine (design: claude/plan-puzzle-combat.md). Pure PHP: no DB, no session, no clock.
 * State is a plain array (JSON-safe) so it can live in the expedition row. Seeded RNG: same seed + same moves = same fight.
 * Server authoritative: callers must never send 'draw' or the foe's 'hand' to the client (use pf_view()).
 */

const PF_HAND_CAP = 5;
const PF_DRAW = 3;
const PF_CHAIN_MAX = 4;
const PF_TURN_CAP = 24;
/** Resolve bar = pace turns x K x (base + slope x creature level); bosses use their own K. Tuned with tests/pfight_sim.php (a realistic gnome: stat modifier about (level+3)/14). */
const PF_BAR_K = 1.7, PF_BAR_BOSS = 2.0, PF_BAR_BASE = 5, PF_BAR_SLOPE = 0.4;
const PF_FOE_DMG = 1.4, PF_FOE_BOSS = 0.78;   // foe tile values scale with its damage die; bosses hit a little softer so a long fight is survivable

/** Effect type -> family of the hole on a tile's left side. Knob (right side) family is set per tile; null = flat/wild. */
const PF_HOLE = ['hurt' => 'body', 'guard' => 'body', 'heal' => 'mind', 'charm' => 'mind', 'soothe' => 'mind', 'trick' => 'craft', 'item' => 'craft'];
const PF_STAT = ['hurt' => 'grit', 'guard' => 'nimble', 'heal' => 'hardiness', 'charm' => 'charm', 'soothe' => 'charm', 'trick' => 'lore', 'item' => 'lore'];

/** Combos by "prev>next" type pair. Bonus lands on the later tile. mul = value x mul (percent), flat = +value. */
const PF_COMBOS = [
    'trick>hurt'  => ['name' => 'Ambush',      'mul' => 150, 'flat' => 'prev'],   // flat 'prev' = plus the value of the tile before
    'guard>hurt'  => ['name' => 'Riposte',     'mul' => 150, 'flat' => 0],
    'hurt>hurt'   => ['name' => 'Double Swing', 'mul' => 100, 'flat' => 2],
    'soothe>charm' => ['name' => 'Calm Charm', 'mul' => 150, 'flat' => 0],
    'charm>item'  => ['name' => 'Win Over',    'mul' => 100, 'flat' => 0, 'barPct' => 50],
    'trick>guard' => ['name' => 'Bait',        'mul' => 100, 'flat' => 'prev'],
];

/** What a tile's tag does (shown on the card). Hurt tiles differ by tactic, not just by number. */
const PF_TAGS = [
    'quick'  => ['⚡', 'Quick: draw a tile when played'],
    'heavy'  => ['🪨', 'Heavy: has to be the last tile of a chain'],
    'pierce' => ['📌', 'Pierce: ignores the creature\'s guard'],
    'poison' => ['🧪', 'Poison: keeps working for 2 more turns'],
    'trip'   => ['🪢', 'Trip: the creature plays one tile fewer next turn'],
    'bash'   => ['🛡️', 'Bash: adds the guard you built earlier in this chain to the hit'],
];

/** The tile library. t = type, v = base value, r = knob family of the right end (null = flat), tag = optional rule. */
function pf_tiles(): array
{
    static $T = null;
    if ($T) return $T;
    $T = [
        // gnome base six
        'swing'  => ['n' => 'Swing',  't' => 'hurt',   'v' => 4, 'r' => 'mind'],
        'dodge'  => ['n' => 'Dodge',  't' => 'guard',  'v' => 4, 'r' => 'body'],
        'rest'   => ['n' => 'Rest',   't' => 'heal',   'v' => 3, 'r' => 'craft'],
        'charm'  => ['n' => 'Charm',  't' => 'charm',  'v' => 4, 'r' => 'craft'],
        'snack'  => ['n' => 'Snack',  't' => 'item',   'v' => 5, 'r' => 'body', 'tag' => 'snack'],
        'hide'   => ['n' => 'Hide',   't' => 'trick',  'v' => 3, 'r' => 'body'],
        // unlock / craft later
        'soothe' => ['n' => 'Soothe', 't' => 'soothe', 'v' => 2, 'r' => 'mind'],
        'offer'  => ['n' => 'Offer',  't' => 'charm',  'v' => 6, 'r' => null],
        'taunt'  => ['n' => 'Taunt',  't' => 'trick',  'v' => 3, 'r' => 'body'],
        // Hurt tiles that play differently (unlocks: see pfight_me)
        'jab'    => ['n' => 'Jab',    't' => 'hurt',   'v' => 2, 'r' => 'craft', 'tag' => 'quick'],
        'pierce' => ['n' => 'Pierce', 't' => 'hurt',   'v' => 3, 'r' => 'mind',  'tag' => 'pierce'],
        'sting'  => ['n' => 'Sting',  't' => 'hurt',   'v' => 2, 'r' => 'body',  'tag' => 'poison'],
        'trip'   => ['n' => 'Trip',   't' => 'hurt',   'v' => 2, 'r' => 'craft', 'tag' => 'trip'],
        'bash'   => ['n' => 'Shield Bash', 't' => 'hurt', 'v' => 2, 'r' => 'mind', 'tag' => 'bash'],
        'smash'  => ['n' => 'Smash',  't' => 'hurt',   'v' => 6, 'r' => 'body',  'tag' => 'heavy'],
        'breather' => ['n' => 'Breather', 't' => 'heal', 'v' => 2, 'r' => 'body'],   // stands in for Snack when there is nothing to eat
        // calling tiles (tier I; II/III raise v, see pf_calling_tile)
        'bark'   => ['n' => 'Bark Wall',   't' => 'guard',  'v' => 6, 'r' => 'body'],
        'bloom'  => ['n' => 'Bloom',       't' => 'charm',  'v' => 8, 'r' => 'mind'],
        'thorn'  => ['n' => 'Thorn Cut',   't' => 'hurt',   'v' => 7, 'r' => 'craft'],
        'sow'    => ['n' => 'Sow Doubt',   't' => 'trick',  'v' => 5, 'r' => 'mind'],
        'wayfind' => ['n' => 'Slip Past',  't' => 'trick',  'v' => 5, 'r' => 'body'],
        'brew'   => ['n' => 'Steep',       't' => 'heal',   'v' => 6, 'r' => 'craft'],
    ];
    return $T;
}

const PF_CALLING_TILE = ['rootwarden' => 'bark', 'bloomcaller' => 'bloom', 'thornblade' => 'thorn', 'seedkeeper' => 'sow', 'wayfinder' => 'wayfind', 'brewroot' => 'brew'];

/** Deterministic RNG (xorshift32); the seed lives in state['rng'] so it advances with the fight. */
function pf_rand(array &$s, int $max): int
{
    $x = (int)$s['rng'] & 0xFFFFFFFF; if ($x === 0) $x = 0x9E3779B9;
    $x ^= ($x << 13) & 0xFFFFFFFF; $x ^= $x >> 17; $x ^= ($x << 5) & 0xFFFFFFFF;
    $s['rng'] = $x;
    return $max <= 1 ? 0 : $x % $max;
}

function pf_shuffle(array &$s, array $a): array
{
    for ($i = count($a) - 1; $i > 0; $i--) { $j = pf_rand($s, $i + 1); [$a[$i], $a[$j]] = [$a[$j], $a[$i]]; }
    return $a;
}

/** A tile instance as stored in a deck/hand: ['k' => key, 'v' => final value, 't', 'r', 'n', 'tag']. Built once per fight. */
function pf_make_tile(string $key, array $stats, int $bonus = 0, array $over = []): array
{
    $d = (pf_tiles()[$key] ?? pf_tiles()['swing']) + ['tag' => ''];
    $d = $over + $d;
    $stat = max(0, (int)($stats[PF_STAT[$d['t']]] ?? 0));
    $lvl = intdiv(max(1, (int)($stats['level'] ?? 1)), 3);
    return ['k' => $key, 'n' => $d['n'], 't' => $d['t'], 'v' => max(1, (int)$d['v'] + $stat + $lvl + $bonus), 'r' => $d['r'], 'tag' => (string)$d['tag']];
}

/** Player deck: gnome base six, the calling tile (tier upgrades value) and pals swapping in for gnome tiles.
 *  $pals = list of ['swap' => gnomeTileKey, 'n' => name, 't' => type, 'v' => base, 'r' => knob|null]. */
function pf_player_deck(array $stats, string $calling = '', int $tier = 1, array $pals = [], array $unlocked = [], array $typeBonus = [], bool $snack = true, ?array $box = null): array
{
    if ($box !== null) $keys = $box;   // the puzzle box the gnome packed
    else {   // no box given (tests): base six, the calling tile, and whatever is unlocked
        $keys = PF_BASE_KEYS;
        if (isset(PF_CALLING_TILE[$calling])) $keys[] = PF_CALLING_TILE[$calling];
        foreach ($unlocked as $k) if (isset(pf_tiles()[$k]) && !in_array($k, $keys, true)) $keys[] = $k;
    }
    $deck = [];
    foreach ($keys as $k) {
        if ($k === 'snack' && !$snack) $k = 'breather';   // nothing to eat: a weak Breather instead of a dead tile
        $t = pf_tiles()[$k] ?? null; if (!$t) continue;
        $b = (int)($typeBonus[$t['t']] ?? 0) + ($calling === 'bloomcaller' && in_array($t['t'], ['charm', 'soothe'], true) ? 2 : 0);   // Bloomcallers: bigger Charm and Soothe numbers
        if (in_array($k, PF_CALLING_TILE, true)) $b += max(0, $tier - 1) * 2;   // calling tile: tiers upgrade it
        $deck[] = pf_make_tile($k, $stats, $b);
    }
    foreach (array_slice($pals, 0, 2) as $p) {   // a pal replaces the gnome tile it swaps for, else another plain tile of its type; the last Hurt tile is never replaced by something else
        $hurts = count(array_filter($deck, fn($t) => $t['t'] === 'hurt'));
        $at = null;
        foreach ($deck as $i => $t) if ($t['k'] === ($p['swap'] ?? '')) { $at = $i; break; }
        if ($at === null) foreach ($deck as $i => $t) if ($t['t'] === ($p['t'] ?? '') && !in_array($t['k'], PF_CALLING_TILE, true) && !str_starts_with($t['k'], 'pal:')) { $at = $i; break; }
        if ($at === null || ($deck[$at]['t'] === 'hurt' && $hurts < 2 && ($p['t'] ?? '') !== 'hurt')) continue;
        $deck[$at] = pf_make_tile('pal:' . $p['n'], $stats, (int)($typeBonus[(string)$p['t']] ?? 0), ['n' => (string)$p['n'], 't' => (string)$p['t'], 'v' => (int)$p['v'], 'r' => $p['r'] ?? null, 'tag' => 'pal']);
    }
    return $deck;
}

/** The tiles a gnome of this level has unlocked beyond the base six (interim: levels, until the crafting hook exists). Shared by the game and the sim. */
function pf_unlocks(int $level): array
{
    $out = [];
    foreach ([4 => 'soothe', 5 => 'jab', 8 => 'pierce', 10 => 'taunt', 11 => 'trip', 12 => 'offer', 13 => 'sting', 14 => 'bash', 16 => 'smash'] as $lv => $k) if ($level >= $lv) $out[] = $k;
    return $out;
}

/**
 * The PUZZLE BOX: the tiles a gnome brings to a fight. It only holds so many (capacity grows with level), so the gnome chooses.
 * Collection = the base six + everything unlocked + the calling tile. Capacity: 8 at level 1, +1 per 3 levels, 14 at most.
 */
const PF_BASE_KEYS = ['swing', 'dodge', 'rest', 'charm', 'snack', 'hide'];
const PF_BOX_MIN = 6;

function pf_box_capacity(int $level): int
{
    return min(14, 8 + intdiv(max(1, $level), 3));
}

/** Every tile key this gnome owns, in the order the default box fills: base six, calling tile, then unlocks. */
function pf_collection(int $level, string $calling = ''): array
{
    $keys = PF_BASE_KEYS;
    if (isset(PF_CALLING_TILE[$calling])) $keys[] = PF_CALLING_TILE[$calling];
    foreach (pf_unlocks($level) as $k) if (!in_array($k, $keys, true)) $keys[] = $k;
    return $keys;
}

/** The box actually used: the saved list cleaned up (owned tiles only, no repeats, within capacity), or the default (collection in order up to capacity). */
function pf_box(int $level, string $calling, ?array $saved): array
{
    $own = pf_collection($level, $calling); $cap = pf_box_capacity($level);
    $box = [];
    foreach ((array)$saved as $k) if (is_string($k) && in_array($k, $own, true) && !in_array($k, $box, true)) $box[] = $k;
    $box = array_slice($box, 0, $cap);
    if (pf_box_check($box, $cap) !== null) $box = array_slice($own, 0, $cap);   // nothing saved, or a saved box that no longer works: the default
    return $box;
}

/** null if the list is a legal box, else why not. */
function pf_box_check(array $keys, int $cap): ?string
{
    if (count($keys) > $cap) return 'The box only holds ' . $cap . ' tiles.';
    if (count($keys) < PF_BOX_MIN) return 'Bring at least ' . PF_BOX_MIN . ' tiles.';
    $hurt = false;
    foreach ($keys as $k) if ((pf_tiles()[$k]['t'] ?? '') === 'hurt') $hurt = true;
    if (!$hurt) return 'Bring at least one Hurt tile (the great creatures cannot be charmed).';
    return null;
}

/** Foe temperament: gentle creatures take Charm well (resolve x1) and Hurt badly (x0.5); hostile the reverse. */
function pf_temper(array $c): string
{
    if (!empty($c['temper'])) return (string)$c['temper'];
    return in_array((string)($c['slug'] ?? ''), PF_GENTLE, true) ? 'gentle' : 'hostile';
}

/** Archetype from size + temperament: which foe tiles it carries. */
function pf_foe_deck(array $c): array
{
    $size = (string)($c['size'] ?? 'small');
    $temper = pf_temper($c);
    $boss = $size === 'boss';
    $v = max(1, (int)round((((int)($c['dmg_die'] ?? 4) + 1) / 2 + (int)($c['dmg_bonus'] ?? 0)) * ($boss ? PF_FOE_BOSS : PF_FOE_DMG)));
    $mk = fn(string $k, string $n, string $t, int $val, ?string $r, string $tag = '') => ['k' => 'f:' . $k, 'n' => $n, 't' => $t, 'v' => max(1, $val), 'r' => $r, 'tag' => $tag];
    $deck = [
        $mk('hit1', 'Lunge', 'hurt', $v, 'mind'), $mk('hit2', 'Snap', 'hurt', $v, 'body'),
        $mk('guard', 'Brace', 'guard', max(1, intdiv($v * 2, 3)), 'craft'),
        $mk('feint', 'Feint', 'trick', max(1, intdiv($v, 2)), 'body'),
        $mk('rest', 'Recover', 'heal', max(1, intdiv($v, 2)), 'mind'),
    ];
    if ($temper === 'hostile') { $deck[] = $mk('hit3', 'Rend', 'hurt', $v + 1, 'craft'); }
    else { $deck[] = $mk('guard2', 'Shy Back', 'guard', max(1, intdiv($v * 2, 3)), 'body'); }
    if ($size === 'large' || $boss) { $deck[] = $mk('hit4', 'Slam', 'hurt', $v + 2, 'mind'); $deck[] = $mk('guard3', 'Bulk', 'guard', max(1, $v - 1), 'craft'); }
    if ($boss) { $deck[] = $mk('hit5', 'Crush', 'hurt', $v + 3, 'body'); $deck[] = $mk('feint2', 'Scheme', 'trick', max(1, intdiv($v, 2)), 'mind'); }
    if ($boss) {   // authored pattern: wind up, guard, strike, feint, heavy blows late. The boss plays the deck in this order.
        $order = ['f:feint', 'f:guard', 'f:hit1', 'f:feint2', 'f:hit2', 'f:guard3', 'f:hit3', 'f:hit4', 'f:rest', 'f:hit5'];
        $rank = array_flip($order);
        usort($deck, fn($a, $b) => ($rank[$a['k']] ?? 99) <=> ($rank[$b['k']] ?? 99));
    }
    foreach ((array)($c['signature'] ?? PF_SIGNATURE[(string)($c['slug'] ?? '')] ?? []) as $sig) $deck[] = $mk('sig' . count($deck), (string)$sig['n'], (string)$sig['t'], (int)$sig['v'], $sig['r'] ?? null, 'sig');
    return $deck;
}

/** Pace target in turns (design section 8): small 2-3, medium 3-4, large 4-5, boss 6-8. */
function pf_pace(string $size): float
{
    return ['small' => 2.5, 'medium' => 3.5, 'large' => 4.5, 'boss' => 7.0][$size] ?? 3.5;
}

/**
 * Start a fight. $me = ['hp','max_hp','stats'=>[...],'deck'=>tiles,'luck'=>int,'name'].
 * $c = creature row (size, level, dmg_die, dmg_bonus, slug...). Returns state.
 */
function pf_new(array $me, array $c, int $seed, array $opt = []): array
{
    $size = (string)($c['size'] ?? 'small');
    $boss = $size === 'boss';
    $temper = pf_temper($c);
    $hm = $temper === 'hostile' ? 1.0 : 0.5;   // Hurt multiplier on the bar
    $cm = $temper === 'hostile' ? 0.4 : 1.0;   // Charm multiplier (wary creatures are hard to win over)
    if ($boss && empty($opt['boss_charm'])) { $hm = 1.0; $cm = 0.0; }   // story bosses: see off only
    $s = ['rng' => $seed ?: 1, 'nonce' => bin2hex(random_bytes(4)), 'turn' => 1, 'over' => null, 'strip' => [], 'log' => [],
        'hm' => $hm, 'cm' => $cm, 'boss' => $boss, 'temper' => $temper, 'size' => $size,
        'me' => ['hp' => (int)$me['hp'], 'max' => (int)$me['max_hp'], 'block' => 0, 'hand' => [], 'draw' => [], 'discard' => [], 'redraws' => max(0, min(3, intdiv((int)($me['luck'] ?? 0), 3)))],   // a per-fight budget (Luck modifier / 3, at most 3)
        'foe' => ['hand' => [], 'draw' => [], 'discard' => [], 'block' => 0, 'agg' => 0, 'poison' => 0, 'poison_v' => 0, 'slow' => 0, 'hsize' => $boss ? 4 : 3, 'name' => (string)($c['name'] ?? 'Creature'), 'intent' => null],
        'bar' => ['now' => 0.0, 'max' => 1.0, 'hurt' => 0.0, 'charm' => 0.0],
        'run_ok' => !$boss,
    ];
    $s['me']['draw'] = pf_shuffle($s, array_values($me['deck']));
    $foeDeck = pf_foe_deck($c);
    $s['foe']['ordered'] = $boss;
    $s['foe']['draw'] = $boss ? array_reverse($foeDeck) : pf_shuffle($s, $foeDeck);   // a boss plays its authored order (the deck list), over and over
    $s['bar']['max'] = max(6.0, round(pf_pace($size) * ($boss ? PF_BAR_BOSS : PF_BAR_K) * (PF_BAR_BASE + PF_BAR_SLOPE * max(1, (int)($c['level'] ?? 1))), 1));   // sized by the creature, so your stats and level shorten fights
    // turn one: player draws up to the cap, foe draws its hand
    pf_draw($s, 'me', PF_HAND_CAP);
    pf_draw($s, 'foe', $s['foe']['hsize']);
    pf_intent($s);
    return $s;
}

/** Draw up to $upTo cards total in hand (reshuffling discard into draw when empty). */
function pf_draw(array &$s, string $who, int $upTo): void
{
    $p = &$s[$who];
    while (count($p['hand']) < $upTo) {
        if (!$p['draw']) {
            if (!$p['discard']) return;
            $p['draw'] = ($who === 'foe' && !empty($p['ordered'])) ? array_reverse($p['discard']) : pf_shuffle($s, $p['discard']); $p['discard'] = [];
            $p = &$s[$who];
        }
        $p['hand'][] = array_pop($p['draw']);
    }
}

/** Does tile $b fit snugly against open end tile $a? (knob family of a = hole family of b; flat knob or flat hole = wild). */
function pf_fits(?array $a, array $b): bool
{
    if (!$a) return false;
    if ($a['r'] === null) return true;
    return $a['r'] === (PF_HOLE[$b['t']] ?? null);
}

function pf_combo(?array $a, array $b): ?array
{
    return $a ? (PF_COMBOS[$a['t'] . '>' . $b['t']] ?? null) : null;
}

/** Value of $b played after $a (a = strip's open end or earlier chain tile) including fit bonus and combo. Returns [value, fit, comboKey|null]. */
function pf_value(?array $a, array $b, bool $combo = true): array
{   // $combo false = the open end is the other side's tile: it can still fit, but it cannot start your combo
    $v = (float)$b['v'];
    $fit = pf_fits($a, $b);
    if ($fit) $v += max(1, (int)round($b['v'] * 0.25));
    $ck = null;
    $cb = $combo ? pf_combo($a, $b) : null;
    if ($cb) { $ck = $a['t'] . '>' . $b['t']; $v = $v * $cb['mul'] / 100 + ($cb['flat'] === 'prev' ? (int)$a['v'] : (int)$cb['flat']); }
    return [(int)round($v), $fit, $ck];
}

/** The strip's open end: [tile, who played it] or [null, null]. */
function pf_open(array $s): array
{
    if (!$s['strip']) return [null, null];
    $x = $s['strip'][count($s['strip']) - 1];
    return [$x['tile'], $x['by']];
}

/** Resolve a list of tiles for one side onto the strip. Mutates state, returns events for the client. */
function pf_resolve(array &$s, string $who, array $tiles): array
{
    $ev = [];
    $other = $who === 'me' ? 'foe' : 'me';
    $s[$who]['block'] = 0;   // your guard from last turn is spent when you act again
    foreach ($tiles as $tile) {
        if ($s['over']) { $s[$who]['discard'][] = $tile; continue; }   // the fight ended mid-chain: the rest just go to the discard
        [$prev, $prevBy] = pf_open($s);
        [$val, $fit, $ck] = pf_value($prev, $tile, $prevBy === $who);   // your combos chain off your own tiles only; a snug fit works across the seam
        $e = ['by' => $who, 'tag' => $tile['tag'], 'k' => $tile['k'], 'n' => $tile['n'], 't' => $tile['t'], 'v' => $val, 'fit' => $fit, 'combo' => $ck ? PF_COMBOS[$ck]['name'] : null];
        $mine = &$s[$who]; $theirs = &$s[$other];
        switch ($tile['t']) {
            case 'hurt':
                $dmg = $val;
                if ($who === 'me' && $tile['tag'] === 'bash') { $dmg += $mine['block']; $e['bashed'] = $mine['block']; $mine['block'] = 0; }   // Shield Bash: your guard becomes damage
                if ($who === 'foe') { $cut = min($s['foe']['agg'], $dmg); $s['foe']['agg'] -= $cut; $dmg -= $cut; $e['soothed'] = $cut; }   // Soothe cuts the foe's next Hurt by its value
                if ($who === 'foe') {   // against the player's HP
                    $abs = min($theirs['block'], $dmg); $theirs['block'] -= $abs; $dmg -= $abs;
                    $theirs['hp'] = max(0, $theirs['hp'] - $dmg);
                    $e['dmg'] = $dmg; $e['blocked'] = $abs;
                } else {   // against the foe's bar, through its guard (Pierce ignores the guard)
                    $abs = $tile['tag'] === 'pierce' ? 0 : min($theirs['block'], $dmg); $theirs['block'] -= $abs; $dmg -= $abs;
                    $add = $dmg * $s['hm'];
                    $s['bar']['now'] += $add; $s['bar']['hurt'] += $add;
                    $e['dmg'] = $dmg; $e['blocked'] = $abs; $e['bar'] = round($add, 1);
                    if ($tile['tag'] === 'poison') { $s['foe']['poison'] = 2; $s['foe']['poison_v'] = max((int)$s['foe']['poison_v'], max(1, (int)ceil($val / 2))); }
                    if ($tile['tag'] === 'trip') $s['foe']['slow'] = 1;
                    if ($tile['tag'] === 'quick') { pf_draw($s, 'me', min(PF_HAND_CAP, count($s['me']['hand']) + 1)); $e['drew'] = 1; }
                }
                break;
            case 'guard':
                $mine['block'] += $val;
                if ($prev && $prev['t'] === 'hurt' && $prevBy === $other) {   // Riposte across the seam: reflect part of the hit
                    $refl = intdiv($val, 2);
                    $e['combo'] = $e['combo'] ?: 'Riposte';
                    if ($who === 'me') { $add = $refl * $s['hm']; $s['bar']['now'] += $add; $s['bar']['hurt'] += $add; $e['bar'] = round($add, 1); }
                    else {   // the foe's reflect goes through your block like any other hit
                        $abs = min($theirs['block'], $refl); $theirs['block'] -= $abs; $refl -= $abs;
                        $e['reflect'] = min($refl, $theirs['hp']); $theirs['hp'] = max(0, $theirs['hp'] - $refl);
                    }
                }
                break;
            case 'heal':
                if ($who === 'me') $mine['hp'] = max($mine['hp'], min($mine['max'], $mine['hp'] + $val));
                else $s['bar']['now'] = max(0.0, $s['bar']['now'] - $val);   // the creature recovers: its bar drops
                break;
            case 'charm':
                if ($who === 'me') { $add = $val * $s['cm']; $s['bar']['now'] += $add; $s['bar']['charm'] += $add; $e['bar'] = round($add, 1); }
                break;
            case 'soothe':
                if ($who === 'me') $s['foe']['agg'] += $val;   // pool that blunts the foe's next Hurt(s) this turn
                break;
            case 'trick':   // setup: nothing on its own, it pays through Ambush and Bait
                break;
            case 'item':
                if ($who === 'me') $mine['hp'] = max($mine['hp'], min($mine['max'], $mine['hp'] + $val));   // Snack/Item: heal; the caller consumes the real item
                break;
        }
        if (!empty($ck) && !empty(PF_COMBOS[$ck]['barPct']) && $who === 'me') {   // Win Over: a slice of bar
            $add = $val * PF_COMBOS[$ck]['barPct'] / 100 * $s['cm']; $s['bar']['now'] += $add; $s['bar']['charm'] += $add; $e['bar'] = round(($e['bar'] ?? 0) + $add, 1);
        }
        unset($mine, $theirs);
        $s['strip'][] = ['by' => $who, 'tile' => $tile];
        if (count($s['strip']) > 24) $s['strip'] = array_slice($s['strip'], -12);
        $s[$who]['discard'][] = $tile;
        $ev[] = $e;
        pf_check_end($s);
    }
    return $ev;
}

function pf_check_end(array &$s): bool
{
    if ($s['over']) return true;
    if ($s['bar']['now'] >= $s['bar']['max']) {
        $charmWin = $s['bar']['charm'] > $s['bar']['hurt'];
        $s['over'] = $charmWin ? 'charmed' : 'seen_off';
        return true;
    }
    if ($s['me']['hp'] <= 0) { $s['over'] = 'defeat'; return true; }
    return false;
}

/** Remove tiles from the player's hand by index list; returns the tiles in play order or null when the list is illegal. */
function pf_pick(array $s, array $idx): ?array
{
    $idx = array_values($idx);
    foreach ($idx as $i) if (!is_int($i)) return null;
    if (!$idx || count($idx) > PF_CHAIN_MAX || count($idx) !== count(array_unique($idx))) return null;
    $out = [];
    foreach ($idx as $i) {
        if (!is_int($i) || $i < 0 || $i >= count($s['me']['hand'])) return null;
        $out[] = $s['me']['hand'][$i];
    }
    return $out;
}

/**
 * The player plays a chain. $turn must equal state turn (double taps / stale clients are ignored: returns null).
 * $canPlay(tile): ?string — optional hook, a non-null return is a refusal reason (snack with no snacks).
 * Returns ['ev'=>[...], 'err'=>?string]; err set means nothing changed.
 */
function pf_play(array &$s, array $idx, int $turn, ?callable $canPlay = null): array
{
    if ($s['over']) return ['ev' => [], 'err' => 'The fight is over.'];
    if ($turn !== $s['turn']) return ['ev' => [], 'err' => 'stale'];
    $tiles = pf_pick($s, $idx);
    if ($tiles === null) return ['ev' => [], 'err' => 'Pick 1 to 4 tiles from your hand.'];
    foreach ($tiles as $i => $t) if ($t['tag'] === 'heavy' && $i !== count($tiles) - 1) return ['ev' => [], 'err' => 'A heavy tile has to go last in the chain.'];
    if ($canPlay) foreach ($tiles as $t) if (($why = $canPlay($t)) !== null) return ['ev' => [], 'err' => $why];
    $rm = $idx; rsort($rm);
    foreach ($rm as $i) array_splice($s['me']['hand'], $i, 1);
    $ev = pf_resolve($s, 'me', $tiles);
    $mine = count($tiles);
    if (!$s['over']) {
        $reply = pf_foe_turn($s, $mine === PF_CHAIN_MAX ? 1 : 0);
        $ev = array_merge($ev, $reply);
    }
    if (!$s['over']) pf_end_turn($s);
    $s['log'][] = ['turn' => $s['turn'], 'n' => $mine];
    return ['ev' => $ev, 'err' => null];
}

/** Foe chain length: small 1-2 tiles, others 2, boss 3; plus the +1 when you play a full chain of four. */
function pf_foe_len(array $s, int $extra): int
{
    $base = $s['size'] === 'small' ? 1 : ($s['boss'] ? 3 : 2);
    if ($s['size'] === 'small' && $s['turn'] % 2 === 0) $base = 2;
    return max(1, min(count($s['foe']['hand']), $base + $extra - (int)$s['foe']['slow']));
}

function pf_foe_turn(array &$s, int $extra): array
{
    $ev = [];
    if ($s['foe']['poison'] > 0) {   // Sting: the poison works on the creature before it acts
        $add = $s['foe']['poison_v'] * $s['hm'];
        $s['bar']['now'] += $add; $s['bar']['hurt'] += $add; $s['foe']['poison']--;
        if ($s['foe']['poison'] === 0) $s['foe']['poison_v'] = 0;
        $ev[] = ['by' => 'me', 'tag' => 'poison', 'k' => 'poison', 'n' => 'Poison', 't' => 'hurt', 'v' => (int)round($add), 'fit' => false, 'combo' => null, 'tick' => true];
        if (pf_check_end($s)) return $ev;
    }
    $n = pf_foe_len($s, $extra);
    $plan = pf_foe_plan($s, $n);
    $hand = $s['foe']['hand'];
    $tiles = [];
    foreach ($plan as $i) $tiles[] = $hand[$i];
    $rm = $plan; rsort($rm);
    foreach ($rm as $i) array_splice($s['foe']['hand'], $i, 1);
    $ev = array_merge($ev, pf_resolve($s, 'foe', $tiles));
    $s['foe']['agg'] = 0;   // Soothe lasts the foe's next turn only
    $s['foe']['slow'] = 0;  // so does Trip
    return $ev;
}

/** Foe AI: best ordered chain of $n tiles from its hand, by value on the strip, weighted by how things stand. Deterministic (ties: lowest index). */
function pf_foe_plan(array $s, int $n): array
{
    $hand = $s['foe']['hand'];
    $h = count($hand);
    if ($n <= 0 || $h === 0) return [];
    $best = null; $bestScore = -1e9;
    $walk = function (array $chosen, array $used) use (&$walk, &$best, &$bestScore, $n, $h, $hand, $s) {
        if (count($chosen) === $n) {
            $sc = pf_plan_score($s, array_map(fn($i) => $hand[$i], $chosen));
            if ($sc > $bestScore + 1e-9) { $bestScore = $sc; $best = $chosen; }
            return;
        }
        for ($i = 0; $i < $h; $i++) if (!isset($used[$i])) $walk([...$chosen, $i], $used + [$i => true]);
    };
    $walk([], []);
    return $best ?? [];
}

function pf_plan_score(array $s, array $tiles): float
{
    [$prev, $prevBy] = pf_open($s);
    $ok = $prevBy === 'foe';
    $myHp = $s['me']['hp'] - $s['me']['block'];
    $barLeft = $s['bar']['max'] - $s['bar']['now'];
    $sc = 0.0; $dmg = 0.0;
    foreach ($tiles as $t) {
        [$v] = pf_value($prev, $t, $ok);
        $ok = true;
        switch ($t['t']) {
            case 'hurt': $sc += $v * 1.0; $dmg += $v; break;
            case 'guard': $sc += $v * 0.55; break;
            case 'heal': $sc += min($v, $s['bar']['now']) * ($barLeft < $s['bar']['max'] * 0.4 ? 1.2 : 0.6); break;
            case 'trick': $sc += 1.0; break;
        }
        $prev = $t;
    }
    if ($dmg >= $myHp) $sc += 20;   // lethal
    return $sc;
}

/** After the foe's reply: player's next turn begins. Refill hands, bump turn, apply stall cap, refresh intent and redraws. */
function pf_end_turn(array &$s): void
{
    pf_draw($s, 'foe', $s['foe']['hsize']);
    $s['turn']++;
    pf_draw($s, 'me', min(PF_HAND_CAP, count($s['me']['hand']) + PF_DRAW));
    if ($s['turn'] > PF_TURN_CAP) { $s['over'] = $s['boss'] ? 'defeat' : 'stall'; return; }   // a boss is not escaped by dawdling
    pf_intent($s);
}

/** Foe intent for the icon: the type it would open with against the current open end. A tendency, not a promise: your chain can change its plan. */
function pf_intent(array &$s): void
{
    $plan = pf_foe_plan($s, pf_foe_len($s, 0));
    $s['foe']['intent'] = $plan ? $s['foe']['hand'][$plan[0]]['t'] : null;
}

/** Luck redraw: swap one hand tile for a fresh draw. Costs one of the turn's redraws. */
function pf_redraw(array &$s, int $handIdx, int $turn): bool
{
    if ($s['over'] || $turn !== $s['turn'] || $s['me']['redraws'] < 1 || $handIdx < 0 || $handIdx >= count($s['me']['hand'])) return false;
    $t = array_splice($s['me']['hand'], $handIdx, 1)[0];
    $s['me']['discard'][] = $t;
    $s['me']['redraws']--;
    pf_draw($s, 'me', count($s['me']['hand']) + 1);
    return true;
}

/** Run: always works against non-bosses (no reward, no loss). */
function pf_run(array &$s): bool
{
    if ($s['over'] || !$s['run_ok']) return false;
    $s['over'] = 'run';
    return true;
}

/** What the client may see: never the draw pile or the foe's hand (only its size and intent icon). */
function pf_view(array $s): array
{
    $strip = array_map(fn($x) => ['by' => $x['by'], 'n' => $x['tile']['n'], 't' => $x['tile']['t'], 'v' => $x['tile']['v'], 'r' => $x['tile']['r']], array_slice($s['strip'], -4));
    [$ot, $oby] = pf_open($s);
    $open = $ot['r'] ?? null;
    return [
        'turn' => $s['turn'], 'over' => $s['over'],
        'hp' => $s['me']['hp'], 'max' => $s['me']['max'], 'block' => $s['me']['block'],
        'hand' => array_map(fn($t) => ['n' => $t['n'], 't' => $t['t'], 'v' => $t['v'], 'r' => $t['r'], 'hole' => PF_HOLE[$t['t']], 'tag' => $t['tag']], $s['me']['hand']),
        'redraws' => $s['me']['redraws'],
        'bar' => ['now' => round($s['bar']['now'], 1), 'max' => $s['bar']['max']],
        'foe' => ['name' => $s['foe']['name'], 'hand' => count($s['foe']['hand']), 'intent' => $s['foe']['intent'], 'block' => $s['foe']['block'], 'calm' => $s['foe']['agg']],
        'strip' => $strip, 'open' => $open, 'open_t' => $ot['t'] ?? null, 'open_v' => $ot['v'] ?? 0, 'open_by' => $oby, 'can_run' => $s['run_ok'], 'combos' => PF_COMBOS,
    ];
}
