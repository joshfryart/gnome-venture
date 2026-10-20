<?php
declare(strict_types=1);

/**
 * v1.0.0 wave 3: the seasonal festival framework. Opening Day (the 1.0 launch) is the first festival.
 *
 * A festival is one entry in festival_defs(): a name, a blurb, a shared Hollow jar (kind "any" counts whatever gnomes do),
 * a few stalls run by townsfolk selling one-off goods, a flag to find every festival day, and a few rewards for the flags.
 * Its dates are settings (fest_<slug>_start / fest_<slug>_end, Hollow dates; Admin → Settings), so a festival can be moved or
 * switched off (clear the dates) without code. While it runs: a bunting strip on every game page, the festival page (festival.php),
 * a jar beside the weekly one, an extra gate stamp, and the festival stall goods. Nothing in it is a limited-time currency:
 * cosmetics come back at the next festival.
 *
 * To add a festival: add its slug to SOCIAL_FESTIVAL_SLUGS (social.php) and an entry here. The 'season' key is for the season helper
 * (hollow_season() in hollow_clock.php): a festival names the season it belongs to and the page says when that season is on;
 * nothing else depends on it, so a festival also works with the helper missing.
 */

require_once __DIR__ . '/townsfolk.php';

function festival_defs(): array
{
    return [
        'opening_day' => [
            'name' => 'Opening Day', 'icon' => '🎏', 'season' => null,
            'blurb' => 'The Hollow is open! Bunting is up from the market to the farthest garden gate, the townsfolk have set up stalls, and everyone is invited. '
                . 'Do what you were going to do anyway (every harvest, walk and pot counts) and fill the festival jar together. Find the day’s flag, shop the stalls, and sign a friend’s guestbook with bunting.',
            'goal' => ['kind' => 'any', 'icon' => '🎏', 'title' => 'Hang the bunting: {n} good deeds across the Hollow', 'per' => 40],
            'flag_rewards' => [3 => ['coins' => 150, 'text' => '150 Petals'], 5 => ['item' => 'opening-day-bunting:1', 'text' => 'an Opening Day Bunting for your yard'],
                               7 => ['title' => 'Opening Day Gnome', 'coins' => 250, 'text' => '250 Petals and the title “Opening Day Gnome”']],
            'stalls' => [
                ['key' => 'compost', 'name' => 'Compost Corner', 'icon' => '🪱', 'sells' => [['plain-compost', 40, 6], ['worm-castings', 120, 4]]],
                ['key' => 'bunting', 'name' => 'Bunting & Baubles', 'icon' => '🎏', 'sells' => [['opening-day-bunting', 300, 3]]],
                ['key' => 'fare', 'name' => 'Festival Fare', 'icon' => '🍯', 'sells' => [['rich-loam', 200, 3], ['rope', 60, 5]]],
            ],
        ],
    ];
}

/** The decoration item sold at the bunting stall (made once; the admin can edit it afterwards). */
function festival_ensure_items(): void
{
    if (q_val("SELECT 1 FROM items WHERE slug = 'opening-day-bunting'")) return;
    db_insert('items', ['name' => 'Opening Day Bunting', 'slug' => 'opening-day-bunting', 'category' => 'decor', 'rarity' => 5, 'base_price' => 300, 'tradable' => 0,
        'description' => 'A string of little flags from the Hollow’s very first Opening Day. Hang it in your yard.',
        'effects' => json_encode(['decor' => ['type' => 'ornament', 'w' => 1, 'h' => 1, 'icon' => '🎏', 'appeal' => 6, 'bonus' => '']], JSON_UNESCAPED_UNICODE)]);
}

/** A valid Y-m-d, or ''. */
function festival_date(string $s): string
{
    $s = trim($s);
    return preg_match('/^(\d{4})-(\d{2})-(\d{2})$/', $s, $m) && checkdate((int)$m[2], (int)$m[3], (int)$m[1]) ? $s : '';
}

/** [first day, last day] of a festival (Hollow dates), or null when it has no dates. */
function festival_window(string $slug): ?array
{
    $a = festival_date(setting('fest_' . $slug . '_start'));
    $b = festival_date(setting('fest_' . $slug . '_end'));
    if ($a === '') return null;
    if ($b === '' || $b < $a) $b = $a;
    $max = gmdate('Y-m-d', strtotime($a . ' UTC') + 30 * 86400);   // a typo can't make a 35,000-day festival
    if ($b > $max) $b = $max;
    return [$a, $b];
}

/** The festival on today, or null: def + slug, starts, ends, day (1-based), days, left (seconds to the end of the last day). */
function festival_active(): ?array
{
    static $cache = false;
    if ($cache !== false) return $cache;
    $cache = null;
    if (setting('festivals_on') !== '1') return null;
    $today = hollow_date('Y-m-d');
    foreach (festival_defs() as $slug => $def) {
        if (!($w = festival_window($slug)) || $today < $w[0] || $today > $w[1]) continue;
        $days = (int)round((strtotime($w[1] . ' UTC') - strtotime($w[0] . ' UTC')) / 86400) + 1;
        $cache = $def + ['slug' => $slug, 'starts' => $w[0], 'ends' => $w[1], 'days' => $days,
            'day' => (int)round((strtotime($today . ' UTC') - strtotime($w[0] . ' UTC')) / 86400) + 1, 'left' => festival_end_ts($w[1]) - time()];
        return $cache;
    }
    return null;
}

/** The next festival that has not started: def + slug, starts, ends. */
function festival_next(): ?array
{
    if (setting('festivals_on') !== '1') return null;
    $today = hollow_date('Y-m-d');
    $best = null;
    foreach (festival_defs() as $slug => $def) {
        if (!($w = festival_window($slug)) || $w[0] <= $today) continue;
        if (!$best || $w[0] < $best['starts']) $best = $def + ['slug' => $slug, 'starts' => $w[0], 'ends' => $w[1]];
    }
    return $best;
}

/** The latest festival that has finished, for the "it was lovely" line. */
function festival_last(): ?array
{
    $today = hollow_date('Y-m-d');
    $best = null;
    foreach (festival_defs() as $slug => $def) {
        if (!($w = festival_window($slug)) || $w[1] >= $today) continue;
        if (!$best || $w[1] > $best['ends']) $best = $def + ['slug' => $slug, 'starts' => $w[0], 'ends' => $w[1]];
    }
    return $best;
}

/** UTC timestamp of the Hollow midnight that starts a Hollow date. */
function festival_start_ts(string $date): int
{
    return (new DateTime($date . ' 00:00:00', hollow_tz()))->getTimestamp();
}

/** UTC timestamp of the end of a Hollow date (the next midnight). */
function festival_end_ts(string $date): int
{
    return festival_start_ts(gmdate('Y-m-d', strtotime($date . ' UTC') + 86400));
}

/** Make the festival's jar the first time anyone looks (called by hollow_goals_active()). */
function festival_ensure_goals(): void
{
    $f = festival_active();
    if (!$f || empty($f['goal'])) return;
    $pk = 'fest:' . $f['slug'] . ':' . $f['starts'];
    if (q_val('SELECT 1 FROM hollow_goals WHERE period_key = ?', [$pk])) return;
    require_once __DIR__ . '/hollow_goals.php';
    $g = $f['goal'];
    $target = hollow_goal_round((int)$g['per'] * hollow_goal_gnomes());
    try {
        db_insert('hollow_goals', ['period_key' => $pk, 'kind' => $g['kind'], 'filter' => '', 'title' => str_replace('{n}', (string)$target, $g['title']), 'icon' => $g['icon'],
            'target' => $target, 'progress' => 0, 'festival' => $f['slug'], 'starts_at' => gmdate('Y-m-d H:i:s', festival_start_ts($f['starts'])),
            'ends_at' => gmdate('Y-m-d H:i:s', festival_end_ts($f['ends'])), 'created_at' => now()]);
    } catch (PDOException $e) {
        // two visitors at once
    }
}

/** The festival's jar row, or null. */
function festival_goal(array $f): ?array
{
    return q_one('SELECT * FROM hollow_goals WHERE period_key = ?', ['fest:' . $f['slug'] . ':' . $f['starts']]) ?: null;
}

/** Extra gate stamps while a festival runs. */
function festival_stamps(): array
{
    return festival_active() ? ['bunting' => ['🎏', 'Bunting']] : [];
}

// ---------------- The flag, the stalls, the rewards ----------------

function festival_flags(string $slug, int $uid): int
{
    return (int)q_val('SELECT COUNT(*) FROM festival_flags WHERE festival = ? AND user_id = ?', [$slug, $uid]);
}

function festival_flag_today(string $slug, int $uid): bool
{
    return (bool)q_val('SELECT 1 FROM festival_flags WHERE festival = ? AND user_id = ? AND day = ?', [$slug, $uid, hollow_date('Y-m-d')]);
}

/** Find today's flag (one a day), and take any flag reward that has been earned. */
function festival_find_flag(array $u): array
{
    $f = festival_active();
    if (!$f) return [false, 'There’s no festival on right now.'];
    $uid = (int)$u['id'];
    try {
        db_insert('festival_flags', ['festival' => $f['slug'], 'user_id' => $uid, 'day' => hollow_date('Y-m-d'), 'at' => now()]);
    } catch (PDOException $e) {
        return [false, 'You’ve found today’s flag. A new one is hung tomorrow.'];
    }
    $n = festival_flags($f['slug'], $uid);
    $msgs = ['🎏 You find today’s flag! That’s ' . $n . '.'];
    foreach (($f['flag_rewards'] ?? []) as $need => $r) {
        if ($n < $need) continue;
        $msg = festival_take_reward($f, $uid, 'flags' . $need, $r);
        if ($msg !== '') $msgs[] = $msg;
    }
    return [true, implode(' ', $msgs)];
}

/** Pay one flag reward once. Returns a line to say, or ''. */
function festival_take_reward(array $f, int $uid, string $key, array $r): string
{
    try {
        db_insert('festival_claims', ['festival' => $f['slug'], 'user_id' => $uid, 'reward' => $key, 'at' => now()]);
    } catch (PDOException $e) {
        return '';
    }
    if (!empty($r['coins'])) q('UPDATE users SET coins = coins + ? WHERE id = ?', [(int)$r['coins'], $uid]);
    if (!empty($r['item'])) {
        [$slug, $qty] = explode(':', $r['item']) + [1 => '1'];
        if ($iid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug])) give_item($uid, $iid, max(1, (int)$qty));
    }
    if (!empty($r['title'])) q("UPDATE users SET title = ? WHERE id = ? AND (title IS NULL OR title = '')", [$r['title'], $uid]);
    return '🎁 Reward: ' . $r['text'] . '.';
}

/** Stall goods with item rows, who runs each stall, and what this gnome has bought. */
function festival_stalls(array $f, int $uid): array
{
    $folk = townsfolk_picks('stall|' . $f['slug'], count($f['stalls']));
    $out = [];
    foreach ($f['stalls'] as $i => $s) {
        $goods = [];
        foreach ($s['sells'] as $j => [$slug, $price, $limit]) {
            $item = q_one('SELECT * FROM items WHERE slug = ?', [$slug]);
            if (!$item) continue;
            $bought = (int)q_val('SELECT qty FROM festival_buys WHERE festival = ? AND user_id = ? AND stall = ?', [$f['slug'], $uid, $s['key'] . ':' . $j]);
            $goods[] = ['idx' => $j, 'item' => $item, 'price' => $price, 'limit' => $limit, 'bought' => $bought];
        }
        $out[] = $s + ['goods' => $goods, 'keeper' => $folk[$i]['name'] ?? null];
    }
    return $out;
}

function festival_buy(array $u, string $stallKey, int $idx): array
{
    $f = festival_active();
    if (!$f) return [false, 'The stalls are packed away until the next festival.'];
    $uid = (int)$u['id'];
    foreach ($f['stalls'] as $s) {
        if ($s['key'] !== $stallKey || !isset($s['sells'][$idx])) continue;
        [$slug, $price, $limit] = $s['sells'][$idx];
        $item = q_one('SELECT id, name FROM items WHERE slug = ?', [$slug]);
        if (!$item) return [false, 'That’s sold out.'];
        $key = $s['key'] . ':' . $idx;
        db()->beginTransaction();
        if (!q_val('SELECT 1 FROM festival_buys WHERE festival = ? AND user_id = ? AND stall = ?', [$f['slug'], $uid, $key])) {
            try { db_insert('festival_buys', ['festival' => $f['slug'], 'user_id' => $uid, 'stall' => $key, 'qty' => 0]); } catch (PDOException $e) { /* a double tap */ }
        }
        if (q('UPDATE festival_buys SET qty = qty + 1 WHERE festival = ? AND user_id = ? AND stall = ? AND qty < ?', [$f['slug'], $uid, $key, $limit])->rowCount() !== 1) {
            db()->rollBack();
            return [false, 'You’ve taken all you can of that one (' . $limit . ').'];
        }
        if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$price, $uid, $price])->rowCount() !== 1) {
            db()->rollBack();
            return [false, 'You need ' . money($price) . ' for that.'];
        }
        give_item($uid, (int)$item['id'], 1);
        db()->commit();
        return [true, '🛍️ You buy ' . $item['name'] . ' for ' . money($price) . '.'];
    }
    return [false, 'No such stall.'];
}

// ---------------- Decorations ----------------

/** The bunting strip shown at the top of game pages while a festival runs ('' otherwise). */
function festival_bar_html(bool $full = true): string
{
    $f = festival_active();
    if (!$f) return '';
    return '<a class="festbar' . ($full ? ' festfull' : '') . '" href="' . e(url('festival.php')) . '"><span class="festbunting" aria-hidden="true"></span>'
        . '<span class="festtxt">' . e($f['icon'] . ' ' . $f['name']) . ' is on · day ' . (int)$f['day'] . ' of ' . (int)$f['days'] . '</span></a>';
}

/** Words for a span of seconds ("2 days", "5 hours"). */
function festival_left_text(int $s): string
{
    if ($s >= 86400) { $d = (int)ceil($s / 86400); return $d . ' day' . ($d === 1 ? '' : 's'); }
    if ($s >= 3600) { $h = (int)floor($s / 3600); return $h . ' hour' . ($h === 1 ? '' : 's'); }
    return 'less than an hour';
}

/** The season the Hollow is in, from the season helper if it is there (hollow_clock.php), else null. */
function festival_season_line(): ?string
{
    if (!function_exists('hollow_season')) return null;
    $s = hollow_season();
    if (!is_string($s) || $s === '') return null;
    $info = defined('HOLLOW_SEASONS') ? (HOLLOW_SEASONS[$s] ?? null) : null;
    return $info ? $info[0] . ' It is ' . strtolower($info[1]) . ' in the Hollow.' : ucfirst($s) . ' in the Hollow.';
}
