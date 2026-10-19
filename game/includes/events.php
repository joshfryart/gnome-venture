<?php
declare(strict_types=1);
/**
 * Random events (v0.7.19): rare, small surprises while browsing, shown in a pop-up box.
 * About 1 in N page views (setting event_chance), at least event_cooldown_minutes apart, at most event_daily_max a day.
 * Events live in the random_events table (Admin → Random events), first filled from includes/data/events.txt.
 * Click/choice/game events are remembered in the session and finished on event.php, so they can only be claimed once.
 */

function ensure_events(): int
{
    require_once __DIR__ . '/catalog.php';
    if (!q_val("SELECT 1 FROM items WHERE slug = 'puddle-hat'")) {
        db_insert('items', ['name' => 'Puddle Hat', 'slug' => 'puddle-hat', 'category' => 'part', 'rarity' => 40, 'base_price' => 30,
            'description' => 'A very fine hat, found in a puddle. Still a bit soggy. Collectors love them.']);
    }
    if (!q_val("SELECT 1 FROM items WHERE slug = 'pretty-feather'")) {
        db_insert('items', ['name' => 'Pretty Feather', 'slug' => 'pretty-feather', 'category' => 'part', 'rarity' => 10, 'base_price' => 12,
            'description' => 'A soft, striped feather that drifted down from somewhere. Crafters like them.']);
    }
    $added = 0;
    foreach (catalog_lines('events.txt') as $r) {
        if (count($r) < 7) continue;
        [$slug, $weight, $kind, $effect, $icon, $title, $text] = $r;
        $button = $r[7] ?? '';
        if (q_val('SELECT 1 FROM random_events WHERE slug = ?', [$slug])) continue;
        db_insert('random_events', ['slug' => $slug, 'weight' => max(0, (int)$weight), 'kind' => $kind, 'effect' => energy_scale_effect($effect), 'icon' => $icon,
            'title' => $title, 'text' => energy_scale_text($text), 'button' => $button ?: null, 'active' => 1]);
        $added++;
    }
    return $added;
}

/** Riddles for the riddle letter: [riddle, options, index of the answer]. */
const EVENT_RIDDLES = [
    ['I have roots that nobody sees, I’m taller than trees, up, up I go, yet I never grow.', ['A mountain', 'A beanstalk', 'A cloud'], 0],
    ['What has ears but cannot hear?', ['A rabbit', 'Corn', 'A teapot'], 1],
    ['I’m full of holes but still hold water.', ['A sponge', 'A sieve', 'A watering can'], 0],
    ['The more you take, the more you leave behind.', ['Seeds', 'Footsteps', 'Petals'], 1],
    ['What has a head and a tail but no body?', ['A worm', 'A coin', 'A comet'], 1],
    ['I am always in front of you but can’t be seen.', ['The future', 'Your nose', 'The wind'], 0],
    ['What kind of tree fits in your hand?', ['A bonsai', 'A palm', 'A pine'], 1],
    ['What grows when it eats, but dies when it drinks?', ['A slug', 'Fire', 'A seed'], 1],
];

/** Called on page loads. Maybe something happens! */
function maybe_random_event(array $u): void
{
    if (!empty($_SESSION['event_pending']) || !empty($_SESSION['event_box'])) return;
    $force = !empty($_SESSION['event_force']);   // the admin's "test an event" button
    if (!$force) {
        $chance = max(2, (int)setting('event_chance'));
        if (random_int(1, $chance) !== 1) return;
        $cool = max(0, (int)setting('event_cooldown_minutes')) * 60;
        if ($u['event_at'] && strtotime($u['event_at'] . ' UTC') > time() - $cool) return;
        $day = hollow_date('Y-m-d');   // v0.7.85: the Hollow's day, not UTC
        if (($u['event_day'] ?? '') === $day && (int)$u['event_count'] >= (int)setting('event_daily_max')) return;
    }
    unset($_SESSION['event_force']);
    $ev = pick_event();
    if (!$ev) return;
    $day = hollow_date('Y-m-d');
    q('UPDATE users SET event_at = ?, event_count = CASE WHEN event_day = ? THEN event_count + 1 ELSE 1 END, event_day = ? WHERE id = ?',
        [now(), $day, $day, $u['id']]);
    if ($ev['kind'] === 'instant') {
        $lines = apply_event_effect($u, (string)$ev['effect']);
        $_SESSION['event_box'] = ['icon' => $ev['icon'], 'title' => $ev['title'], 'text' => $ev['text'], 'lines' => $lines];
    } else {
        $_SESSION['event_pending'] = ['slug' => $ev['slug'], 'token' => bin2hex(random_bytes(8))];
    }
}

function pick_event(): ?array
{
    $all = q('SELECT * FROM random_events WHERE active = 1 AND weight > 0')->fetchAll();
    if (!$all) return null;
    $roll = random_int(1, array_sum(array_map(fn($e) => (int)$e['weight'], $all)));
    foreach ($all as $e) {
        $roll -= (int)$e['weight'];
        if ($roll <= 0) return $e;
    }
    return $all[0];
}

/** A random item of a kind, for rand:… effects. */
function event_random_item(string $kind): ?array
{
    $sql = match ($kind) {
        'seed' => "SELECT i.id, i.name FROM plants p JOIN items i ON i.id = p.seed_item_id WHERE p.common = 1 AND p.kind NOT IN ('cover', 'flower')",
        'flowerseed' => "SELECT i.id, i.name FROM plants p JOIN items i ON i.id = p.seed_item_id WHERE p.kind = 'flower'",
        'treeseed' => "SELECT i.id, i.name FROM plants p JOIN items i ON i.id = p.seed_item_id WHERE p.kind IN ('tree', 'nut', 'fruit')",
        'forage' => "SELECT i.id, i.name FROM gatherables g JOIN items i ON i.id = g.item_id WHERE g.rarity = 'common' AND g.active = 1",
        'uncommon' => "SELECT i.id, i.name FROM gatherables g JOIN items i ON i.id = g.item_id WHERE g.rarity = 'uncommon' AND g.active = 1",
        'rare' => "SELECT i.id, i.name FROM gatherables g JOIN items i ON i.id = g.item_id WHERE g.rarity = 'rare' AND g.active = 1",   // v1.2.2: Reef Garden rand:rare had no arm
        'food' => "SELECT id, name FROM items WHERE category = 'food'",
        'soil' => "SELECT id, name FROM items WHERE category IN ('soil', 'mulch')",
        default => null,
    };
    return $sql ? (q_one($sql . ' ORDER BY ' . sql_random() . ' LIMIT 1') ?: null) : null;
}

/** Apply effects like "coins:10-30+xp:5". Returns what happened, as short lines for the box. */
function apply_event_effect(array $u, string $effect): array
{
    $uid = (int)$u['id'];
    $lines = [];
    foreach (explode('+', $effect) as $fx) {
        $p = explode(':', trim($fx));
        switch ($p[0]) {
            case 'coins':
                [$lo, $hi] = array_map('intval', explode('-', ($p[1] ?? '10') . '-')) + [1 => 0];
                $n = random_int($lo, max($lo, $hi ?: $lo));
                q('UPDATE users SET coins = coins + ? WHERE id = ?', [$n, $uid]);
                $lines[] = '+' . money($n);
                break;
            case 'item':
                $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [$p[1] ?? '']);
                if ($id) { give_item($uid, $id, max(1, (int)($p[2] ?? 1))); $lines[] = '+' . max(1, (int)($p[2] ?? 1)) . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$id]); }
                break;
            case 'rand':
                $it = event_random_item($p[1] ?? '');
                if ($it) { give_item($uid, (int)$it['id'], 1); $lines[] = '+1 × ' . $it['name']; }
                break;
            case 'energy':
                $n = (int)($p[1] ?? 5);
                $cap = max_energy($u);   // CASE works on both MySQL and SQLite (no scalar MIN in MySQL)
                // whole numbers written into the SQL (both are ints), so the comparison is numeric on every database
                q('UPDATE users SET energy = CASE WHEN energy + ' . (int)$n . ' > ' . (int)$cap . ' THEN ' . (int)$cap . ' ELSE energy + ' . (int)$n . ' END WHERE id = ? AND energy < ' . (int)$cap, [$uid]);
                $lines[] = '+' . $n . ' energy';
                break;
            case 'xp':
                add_xp($uid, (int)($p[1] ?? 5));
                $lines[] = '+' . (int)($p[1] ?? 5) . ' XP';
                break;
            case 'buff':
                if (isset(GNOME_STATS[$p[1] ?? ''])) {
                    q('UPDATE users SET ev_stat = ?, ev_amt = ?, ev_until = ? WHERE id = ?', [$p[1], (int)($p[2] ?? 1), gmdate('Y-m-d H:i:s', time() + (int)($p[3] ?? 60) * 60), $uid]);
                    $lines[] = GNOME_STATS[$p[1]][1] . ' +' . (int)($p[2] ?? 1) . ' ' . GNOME_STATS[$p[1]][0] . ' for ' . (int)($p[3] ?? 60) . ' minutes';
                }
                break;
            // v0.7.31 boons
            case 'fairyring':
                q('UPDATE users SET ev_harvest_bonus = 2 WHERE id = ?', [$uid]);
                $lines[] = '🍄 Your next harvest: +2';
                break;
            case 'bee':
                require_once __DIR__ . '/garden_logic.php';
                $tile = q_one('SELECT id, plant_id FROM plot_tiles WHERE plot_id = ? AND plant_id IS NOT NULL ORDER BY ' . sql_random() . ' LIMIT 1', [active_plot_id($uid)]);
                if ($tile) {
                    q('UPDATE plot_tiles SET bonus_yield = bonus_yield + 1 WHERE id = ?', [$tile['id']]);
                    $lines[] = '🐝 Your ' . q_val('SELECT name FROM plants WHERE id = ?', [$tile['plant_id']]) . ' will give +1';
                } else {
                    $lines[] = 'Nothing’s growing, so it buzzes off. Plant something!';
                }
                break;
            case 'fireflies':
                q('UPDATE users SET ev_quickwalk = 1 WHERE id = ?', [$uid]);
                $lines[] = '✨ Your next walk: no energy and no waiting';
                break;
            case 'moonlit':
                require_once __DIR__ . '/garden_logic.php';
                load_plot($uid);
                $n = 0;
                foreach (q('SELECT t.id, t.growth_seconds, p.grow_minutes FROM plot_tiles t JOIN plants p ON p.id = t.plant_id WHERE t.plot_id = ?', [active_plot_id($uid)])->fetchAll() as $t) {
                    if ((int)$t['growth_seconds'] >= (int)$t['grow_minutes'] * 60) continue;
                    q('UPDATE plot_tiles SET growth_seconds = ? WHERE id = ?', [min((int)$t['grow_minutes'] * 60, (int)$t['growth_seconds'] + 900), $t['id']]);
                    $n++;
                }
                $lines[] = $n ? '🌙 ' . $n . ' plant' . ($n === 1 ? '' : 's') . ' grew 15 minutes' : 'Nothing was growing, but it was a lovely moon';
                break;
            case 'rainbow':
                q('UPDATE users SET ev_gather_until = ? WHERE id = ?', [gmdate('Y-m-d H:i:s', time() + 3600), $uid]);
                $lines[] = '🌈 Double gathering for an hour';
                break;
            case 'sale':
                q('UPDATE users SET ev_sale_until = ? WHERE id = ?', [gmdate('Y-m-d H:i:s', time() + 1800), $uid]);
                $lines[] = '🐓 20% off in every shop for 30 minutes';
                break;
            case 'caterpillar':
                require_once __DIR__ . '/garden_logic.php';
                $n = q('UPDATE plot_tiles SET weeds = CASE WHEN weeds > 30 THEN weeds - 30 ELSE 0 END WHERE plot_id = ? AND weeds > 0', [active_plot_id($uid)])->rowCount();
                $lines[] = $n ? '🐛 Weeds munched in ' . $n . ' bed' . ($n === 1 ? '' : 's') : 'There were no weeds, so it just had a nap';
                break;
            case 'tbuff':   // a town outing's boost: its own slot, so it doesn't replace a random event's
                if (isset(GNOME_STATS[$p[1] ?? ''])) {
                    q('UPDATE users SET town_stat = ?, town_amt = ?, town_until = ? WHERE id = ?', [$p[1], (int)($p[2] ?? 1), gmdate('Y-m-d H:i:s', time() + (int)($p[3] ?? 60) * 60), $uid]);
                    $lines[] = GNOME_STATS[$p[1]][1] . ' +' . (int)($p[2] ?? 1) . ' ' . GNOME_STATS[$p[1]][0] . ' for ' . (int)($p[3] ?? 60) . ' minutes';
                }
                break;
            case 'water':
                require_once __DIR__ . '/garden_logic.php';
                load_plot($uid);   // bring growth up to date first, so thirsty time isn't counted as growing
                $n = q("UPDATE plot_tiles SET last_watered = ?, growth_updated_at = ? WHERE plot_id = ? AND plant_id IS NOT NULL",
                    [now(), now(), active_plot_id($uid)])->rowCount();
                $lines[] = $n ? '💧 ' . $n . ' plant' . ($n === 1 ? '' : 's') . ' watered' : 'Nothing was planted, but the soil enjoyed it';
                break;
            case 'tip':
                require_once __DIR__ . '/friends.php';
                $lines[] = '“' . ucfirst((string)preg_replace('/^Tip: /', '', TALK_TIPS[array_rand(TALK_TIPS)])) . '”';
                break;
            case 'landmark':
                // v1.2.2: actually reveal a hidden place (was only a name that unlocked nothing)
                require_once __DIR__ . '/adventure.php';
                require_once __DIR__ . '/stops.php';
                $lines[] = stop_reveal_hidden($uid, player_node($u));
                add_xp($uid, 5);
                $lines[] = '+5 XP';
                break;
            case 'swapseed':
                // v1.2.2: only common seeds get swapped, never treasure ones
                $have = q_one("SELECT ui.item_id, i.name FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.category = 'seed' AND ui.qty > 0
                    AND EXISTS (SELECT 1 FROM plants p WHERE p.seed_item_id = ui.item_id AND p.common = 1) ORDER BY " . sql_random() . ' LIMIT 1', [$uid]);
                $new = event_random_item('seed');
                if ($have && $new && (int)$new['id'] !== (int)$have['item_id'] && give_item($uid, (int)$have['item_id'], -1)) {
                    give_item($uid, (int)$new['id'], 1);
                    $lines[] = '−1 × ' . $have['name'];
                    $lines[] = '+1 × ' . $new['name'];
                } else {
                    $lines[] = 'It couldn’t find anything to swap, so it left you a worm instead.';
                    $w = (int)q_val("SELECT id FROM items WHERE slug = 'earthworm'");
                    if ($w) give_item($uid, $w, 1);
                }
                break;
            case 'friendmail':
                $f = q_one('SELECT n.name, n.id FROM npc_friends f JOIN npcs n ON n.id = f.npc_id WHERE f.user_id = ? AND f.points >= 20 ORDER BY ' . sql_random() . ' LIMIT 1', [$uid]);
                $it = event_random_item('food') ?? event_random_item('seed');
                if ($it) give_item($uid, (int)$it['id'], 1);
                $lines[] = ($f ? 'From ' . $f['name'] . ': ' : 'No name on it: ') . '+1 × ' . ($it['name'] ?? 'something nice');
                break;
            case 'community':
                $n = (int)($p[2] ?? 5);
                $cap = '(' . (int)setting('max_energy') . ' + ' . (int)setting('energy_per_level') . ' * (level - 1))';   // each gnome's own max (before Hardiness)
                q('UPDATE users SET energy = CASE WHEN energy + ' . (int)$n . ' > ' . $cap . ' THEN ' . $cap . ' ELSE energy + ' . (int)$n . ' END WHERE last_seen > ? AND banned = 0 AND energy < ' . $cap,
                    [gmdate('Y-m-d H:i:s', time() - 900)]);
                $lines[] = '+' . $n . ' energy for you and every gnome online';
                break;
        }
    }
    return $lines;
}

/** Finish a click/choice/game event from event.php. */
function finish_event(array $u, string $token, string $choice): array
{
    $pend = $_SESSION['event_pending'] ?? null;
    if (!$pend || !hash_equals((string)$pend['token'], $token)) return [false, 'That moment has passed.'];
    unset($_SESSION['event_pending']);   // one go only
    $ev = q_one('SELECT * FROM random_events WHERE slug = ?', [$pend['slug']]);
    if (!$ev) return [false, 'That moment has passed.'];
    $uid = (int)$u['id'];
    $lines = [];
    $title = $ev['title'];
    switch ($ev['effect']) {
        case 'star':
            $title = 'Your wish comes true!';
            $lines = apply_event_effect($u, ['petals' => 'coins:50-50', 'energy' => 'energy:3', 'seed' => 'rand:treeseed'][$choice] ?? 'coins:50-50');
            break;
        case 'rps':
            $moves = ['rock' => '✊ Rock', 'paper' => '✋ Paper', 'trowel' => '🔪 Trowel'];
            if (!isset($moves[$choice])) $choice = 'rock';
            $them = array_rand($moves);
            $beats = ['rock' => 'trowel', 'trowel' => 'paper', 'paper' => 'rock'];
            $result = $choice === $them ? 'draw' : ($beats[$choice] === $them ? 'win' : 'lose');
            $title = ['win' => 'You win!', 'lose' => 'You lose!', 'draw' => 'A draw!'][$result];
            $lines[] = 'You: ' . $moves[$choice] . ' · Them: ' . $moves[$them];
            $lines = array_merge($lines, $result === 'win' ? apply_event_effect($u, 'coins:30-50') : ($result === 'draw' ? apply_event_effect($u, 'coins:10-10') : ['“Better luck next time!”']));
            break;
        case 'duel':
            if ($choice === 'bow') {
                $title = 'You bow out politely.';
                $lines = array_merge(['The beetle knight bows back, deeply impressed by your manners.'], apply_event_effect($u, 'xp:2'));
                break;
            }
            $win = random_int(1, 100) <= 55 + 3 * max(0, eff_mod($u, 'grit'));
            $title = $win ? 'Victory! The beetle knight yields.' : 'The beetle knight wins this round.';
            $lines = $win ? apply_event_effect($u, 'coins:40-60+item:flint:1+xp:10') : array_merge(['It bows politely and marches off.'], apply_event_effect($u, 'xp:3'));
            break;
        case 'pebbles':
            $skips = random_int(1, 6) + (eff_mod($u, 'nimble') > 0 ? 1 : 0);
            $title = $skips > 4 ? $skips . ' skips! You beat the toad!' : $skips . ' skip' . ($skips === 1 ? '' : 's') . '. The toad looks smug.';
            $lines = apply_event_effect($u, 'coins:' . ($skips * 6) . '-' . ($skips * 6) . ($skips > 4 ? '+xp:5' : ''));
            break;
        case 'merchant':
            if ($choice !== 'buy') {
                $title = 'Maybe next time.';
                $lines = ['“No matter! I’ll be on the Green in some town or other.” He trundles off.'];
                break;
            }
            $seed = q_one("SELECT i.id, i.name FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id JOIN items i ON i.id = p.seed_item_id
                           WHERE pr.tier = 'uncommon' ORDER BY " . sql_random() . ' LIMIT 1');
            if ($seed && q('UPDATE users SET coins = coins - 60 WHERE id = ? AND coins >= 60', [$uid])->rowCount() === 1) {
                give_item($uid, (int)$seed['id'], 1);
                $title = 'A bargain!';
                $lines = ['−' . money(60), '+1 × ' . $seed['name']];
            } else {
                $common = event_random_item('seed');
                if ($common) give_item($uid, (int)$common['id'], 1);
                $title = 'Short of Petals?';
                $lines = ['“Ah, never mind. Have this one on me.”', '+1 × ' . ($common['name'] ?? 'seed')];
            }
            break;
        case 'riddle':
            $rd = EVENT_RIDDLES[crc32((string)$pend['token']) % count(EVENT_RIDDLES)];
            if ($choice === (string)$rd[2]) {
                $title = 'Correct!';
                $lines = array_merge(['“' . $rd[1][$rd[2]] . '.” A puff of glitter, and a prize falls out of the envelope.'], apply_event_effect($u, 'coins:40-70+xp:8'));
            } else {
                $title = 'Not quite…';
                $lines = ['The letter crumbles into leaves. (It was “' . $rd[1][$rd[2]] . '”.)'];
                $lines = array_merge($lines, apply_event_effect($u, 'xp:2'));
            }
            break;
        case 'duck':
            $title = 'Back with its family!';
            $lines = array_merge(['The mother duck quacks her thanks.'], apply_event_effect($u, 'coins:30-40+xp:10'));
            break;
        default:   // plain click: the effect itself (e.g. chasing your hat)
            $title = $ev['kind'] === 'click' ? 'Got it!' : $ev['title'];
            $lines = apply_event_effect($u, (string)$ev['effect']);
    }
    $_SESSION['event_box'] = ['icon' => $ev['icon'], 'title' => $title, 'text' => '', 'lines' => $lines];
    return [true, ''];
}

/** The pop-up box for the current page: a finished event, or one waiting for a click. */
/** v1.4.6: the delve chest's hidden treat block (assets/chest.js) rides in front of the event box on every page. */
function event_box_html(): string
{
    require_once __DIR__ . '/chest.php';
    return chest_stage() . event_box_html_core();
}

function event_box_html_core(): string
{
    if (!empty($_SESSION['event_box'])) {
        $b = $_SESSION['event_box'];
        unset($_SESSION['event_box']);
        return '<div class="eventbox" role="status"><div class="evicon">' . e($b['icon']) . '</div><div class="evbody">'
            . '<div class="evkicker">✨ Something has happened!</div><div class="evtitle">' . e($b['title']) . '</div>'
            . ($b['text'] !== '' ? '<p>' . e($b['text']) . '</p>' : '')
            . ($b['lines'] ? '<ul>' . implode('', array_map(fn($l) => '<li>' . e($l) . '</li>', $b['lines'])) . '</ul>' : '')
            . '</div></div>';
    }
    $pend = $_SESSION['event_pending'] ?? null;
    if (!$pend) return '';
    $ev = q_one('SELECT * FROM random_events WHERE slug = ?', [$pend['slug']]);
    if (!$ev) { unset($_SESSION['event_pending']); return ''; }
    $back = ltrim((string)preg_replace('~^' . preg_quote(rtrim(url(''), '/'), '~') . '/~', '', (string)($_SERVER['REQUEST_URI'] ?? '')), '/');
    if (!preg_match('~^[a-z0-9_/-]+\.php(\?[A-Za-z0-9=&_.-]*)?$~', $back)) $back = 'index.php';
    $form = function (string $choice, string $label) use ($pend, $back): string {
        return '<form method="post" action="' . e(url('event.php')) . '">' . csrf_field()
            . '<input type="hidden" name="token" value="' . e($pend['token']) . '"><input type="hidden" name="choice" value="' . e($choice) . '">'
            . '<input type="hidden" name="back" value="' . e($back) . '">'
            . '<button class="btn">' . $label . '</button></form>';
    };
    $buttons = match ($ev['effect']) {
        'star' => $form('petals', '💰 Petals') . $form('energy', '⚡ Energy') . $form('seed', '🌳 A tree seed'),
        'rps' => $form('rock', '✊ Rock') . $form('paper', '✋ Paper') . $form('trowel', '🔪 Trowel'),
        'duel' => $form('fight', '⚔️ Accept the duel') . $form('bow', '🙇 Bow out politely'),
        'merchant' => $form('buy', '🌱 Buy a rare seed (60 Petals)') . $form('pass', 'No thanks'),
        'riddle' => (function () use ($pend, $form) {
            $rd = EVENT_RIDDLES[crc32((string)$pend['token']) % count(EVENT_RIDDLES)];
            $h = '<p class="riddle"><i>' . e($rd[0]) . '</i></p>';
            foreach ($rd[1] as $i => $opt) $h .= $form((string)$i, e($opt));
            return $h;
        })(),
        default => $form('go', e((string)($ev['button'] ?: 'Okay!'))),
    };
    return '<div class="eventbox waiting" role="dialog" aria-label="' . e($ev['title']) . '"><div class="evicon">' . e($ev['icon']) . '</div><div class="evbody">'
        . '<div class="evkicker">✨ Something is happening!</div><div class="evtitle">' . e($ev['title']) . '</div><p>' . e($ev['text']) . '</p>'
        . '<div class="evbtns">' . $buttons . '</div></div></div>';
}
