<?php
declare(strict_types=1);

/**
 * v1.0.0 wave 2a: garden animals at gnome scale. One shared animal-care core, driven by the critter_kinds table (Admin -> Garden animals):
 *   Worm Farm      worm colonies turn Food Scraps into Worm Castings
 *   Ladybird Lodge ladybirds keep aphids off the beds within two squares, and leave a Ladybird Charm now and then
 *   Frog Pond      frogs keep slugs, snails and gnats off the beds within three squares; they lay Frogspawn, which hatches into tadpoles
 *   Biddy          the neighbour's hen (a giant!) drops by the fence on some days and trades Hen Eggs and Feathers for Food Scraps
 *
 * Housing is a garden building (BUILDINGS / the yard). Residents have a name, a mood (sulking / content / delighted), an optional feeder
 * (meals), and a stored gift that waits up to a cap. All of it is lazy (worked out on view). Cosy: nothing ever dies, leaves or is lost;
 * a sulking animal just works slower, and idle time never banks.
 */

require_once __DIR__ . '/garden_world.php';
require_once __DIR__ . '/animals120.php';   // v1.2.0: Quail Coop, Silkworm Shelf, Tortoise Run, Clementine and Percy
require_once __DIR__ . '/animals140.php';   // v1.4.0: Butterfly Bush, Snail Jar

/** Critter kinds from the data table: slug => row (cached). */
function critter_kinds(bool $reset = false): array
{
    static $k = null;
    if ($k === null || $reset) {
        $k = [];
        foreach (q('SELECT * FROM critter_kinds WHERE active = 1 ORDER BY id')->fetchAll() as $r) $k[(string)$r['slug']] = $r;
    }
    return $k;
}

function critter_is_home(string $b): bool
{
    return isset(GARDEN_CRITTER_HOMES[$b]);
}

/** How many residents a home holds at its level (from the building's main kind). */
function critter_homes(int $plotId, string $building): int
{
    $lv = max(1, building_level($plotId, $building));
    foreach (critter_kinds() as $k) {
        if ($k['building'] !== $building) continue;
        $h = array_map('intval', explode(',', (string)$k['homes']));
        return max(1, $h[min($lv, count($h)) - 1] ?? 2);
    }
    return 2;
}

/** The kind a home welcomes by the player's choice (the first listed that isn't a tadpole). */
function critter_main_kind(string $building): ?array
{
    foreach (critter_kinds() as $k) if ($k['building'] === $building && $k['slug'] !== 'tadpole') return $k;
    return null;
}

/** What the garden gives an animal's mood: weather, flowers, herbs, a rain barrel. */
function critter_ctx(int $plotId): array
{
    static $c = [];
    if (!isset($c[$plotId])) {
        $c[$plotId] = [
            'weather' => garden_weather_on($plotId),
            'flowers' => (int)q_val("SELECT COUNT(*) FROM plot_tiles t JOIN plants p ON p.id = t.plant_id WHERE t.plot_id = ? AND p.kind = 'flower'", [$plotId]),
            'herbs' => (int)q_val("SELECT COUNT(*) FROM plot_tiles t JOIN plants p ON p.id = t.plant_id WHERE t.plot_id = ? AND p.kind = 'herb'", [$plotId]),
            'barrel' => building_level($plotId, 'rain_barrel') > 0,
        ];
    }
    return $c[$plotId];
}

/** Mood 0-100 from how recently it ate and what it likes around it. */
function critter_mood_for(array $c, array $k, array $ctx): int
{
    $eats = trim((string)$k['foods']) !== '';
    $fedAge = $c['fed_at'] ? time() - ts($c['fed_at']) : PHP_INT_MAX;
    $mood = !$eats ? 60 : ($fedAge <= 36 * 3600 ? 60 : ($fedAge <= 96 * 3600 ? 45 : 25));
    $raining = in_array($ctx['weather'], ['rain', 'storm'], true);
    foreach (array_filter(array_map('trim', explode(',', (string)$k['likes']))) as $like) {
        if ($like === 'rain' && $raining) $mood += 15;
        elseif ($like === 'flowers') $mood += $ctx['flowers'] >= 6 ? 25 : ($ctx['flowers'] >= 3 ? 15 : 0);
        elseif ($like === 'herbs' && $ctx['herbs'] >= 2) $mood += 10;
        elseif ($like === 'damp' && ($raining || $ctx['barrel'])) $mood += 15;
        elseif ($like === 'water') $mood += 10;
    }
    return max(0, min(100, $mood));
}

function critter_mood_word(int $mood): array
{
    return $mood >= 80 ? ['Delighted', '😊', 'delighted'] : ($mood >= 30 ? ['Content', '🙂', 'content'] : ['Sulking', '😴', 'sulking']);
}

/** Bring one resident up to date (mood, a tadpole growing, gifts made). Saves if anything changed. */
/** v1.0.0: only the garden's owner (or a script with nobody logged in) saves a resident's progress; a visitor's view is worked out but never written. */
function critter_can_write(int $plotId): bool
{
    static $owner = [];
    $cu = current_user();
    if (!$cu) return true;
    $owner[$plotId] ??= (int)q_val('SELECT user_id FROM plots WHERE id = ?', [$plotId]);
    return $owner[$plotId] === (int)$cu['id'];
}

function critter_tick(array $c, array $k): array
{
    $now = time();
    $news = [];
    $orig = ['kind' => (string)$c['kind'], 'meals' => (int)$c['meals'], 'held' => (int)$c['held'], 'gifts_made' => (int)$c['gifts_made']];
    $plotId = (int)$c['plot_id'];
    $ctx = critter_ctx($plotId);
    $before = [$c['kind'], (int)$c['mood'], (int)$c['meals'], (string)$c['gift_at'], (int)$c['held'], (int)$c['gifts_made']];
    $c['mood'] = critter_mood_for($c, $k, $ctx);
    // a tadpole that has been fed grows into a frog
    if ($c['kind'] === 'tadpole' && $c['grows_at'] && $now >= ts($c['grows_at']) && $c['fed_at']) {
        $frog = critter_kinds()['frog'] ?? null;
        if ($frog) { $c['kind'] = 'frog'; $c['grows_at'] = null; $c['gift_at'] = now(); $k = $frog; $news[] = '🐸 ' . $c['name'] . ' the tadpole has grown into a frog!'; }
    }
    if (trim((string)$k['gift_slug']) !== '' && (int)$k['gift_cap'] > 0) {
        $lv = max(1, building_level($plotId, (string)$c['building']));
        $hrs = max(1.0, (int)$k['gift_hours'] * (100 - 15 * ($lv - 1)) / 100);
        $rate = (int)$c['mood'] < 30 ? max(10, (int)setting('critter_sleepy_pct')) / 100 : 1.0;
        $need = (int)$k['meals_per'];
        if (!$c['gift_at']) $c['gift_at'] = now();
        $periods = (int)floor(($now - ts($c['gift_at'])) * $rate / ($hrs * 3600));
        if ($need > 0 && (int)$c['meals'] < $need) {   // nothing to eat: the timer starts when it has food again
            $c['gift_at'] = now();
        } elseif ($periods > 0) {
            $room = max(0, (int)$k['gift_cap'] - (int)$c['held']);
            $make = min($periods, $room, $need > 0 ? intdiv((int)$c['meals'], $need) : $periods);
            $c['held'] = (int)$c['held'] + $make;
            $c['meals'] = (int)$c['meals'] - $make * $need;
            $c['gifts_made'] = (int)$c['gifts_made'] + $make;
            if ($make < $periods || (int)$c['held'] >= (int)$k['gift_cap']) $c['gift_at'] = now();   // idle time never banks
            else $c['gift_at'] = gmdate('Y-m-d H:i:s', ts($c['gift_at']) + (int)round($periods * $hrs * 3600 / $rate));
        }
    }
    if ($before !== [$c['kind'], (int)$c['mood'], (int)$c['meals'], (string)$c['gift_at'], (int)$c['held'], (int)$c['gifts_made']]) {
        if (!critter_can_write($plotId)) return $c;   // a visitor's peek: show it, don't save it (and don't use up the owner's news)
        // compare-and-swap on what we read: if the owner collected or fed meanwhile, drop this tick and show the fresh row
        $ok = q('UPDATE garden_critters SET kind = ?, mood = ?, meals = ?, gift_at = ?, held = ?, gifts_made = ?, grows_at = ? WHERE id = ? AND kind = ? AND meals = ? AND held = ? AND gifts_made = ?',
            [$c['kind'], $c['mood'], $c['meals'], $c['gift_at'], $c['held'], $c['gifts_made'], $c['grows_at'], $c['id'], $orig['kind'], $orig['meals'], $orig['held'], $orig['gifts_made']])->rowCount() === 1;
        if (!$ok) return q_one('SELECT * FROM garden_critters WHERE id = ?', [$c['id']]) ?: $c;
        foreach ($news as $m) $GLOBALS['gv_critter_news'][] = $m;
    }
    return $c;
}

/** All residents of a home, brought up to date: [row + 'k' => kind row]. */
function critter_list(int $plotId, string $building): array
{
    $key = $plotId . '|' . $building;   // v1.0.1: one read and tick per home per page (it was asked for up to 5 times); writes call critter_forget()
    if (isset($GLOBALS['gv_critter_list'][$key])) return $GLOBALS['gv_critter_list'][$key];
    $out = [];
    foreach (q('SELECT * FROM garden_critters WHERE plot_id = ? AND building = ? ORDER BY id', [$plotId, $building])->fetchAll() as $c) {
        $k = critter_kinds()[(string)$c['kind']] ?? null;
        if (!$k) continue;
        $c = critter_tick($c, $k);
        $c['k'] = critter_kinds()[(string)$c['kind']] ?? $k;
        $out[] = $c;
    }
    return $GLOBALS['gv_critter_list'][$key] = $out;
}

/** v1.0.1: drop the remembered lists (after anything changes an animal). */
function critter_forget(): void
{
    $GLOBALS['gv_critter_list'] = [];
}

/** Gifts waiting in a home. */
function critter_ready(int $plotId, string $building): int
{
    return array_sum(array_map(fn($c) => (int)$c['held'], critter_list($plotId, $building)));
}

/** News lines made while ticking (a tadpole grew up): flash and clear. */
function critter_flush_news(): void
{
    foreach ($GLOBALS['gv_critter_news'] ?? [] as $m) flash($m);
    $GLOBALS['gv_critter_news'] = [];
}

function critter_name_ok(array $u, string $name): array
{
    $name = trim(preg_replace('/\s+/', ' ', $name));
    if ($name === '' || mb_strlen($name) > 20) return [false, 'Names need 1–20 characters.'];
    require_once __DIR__ . '/moderation.php';
    if ($bad = text_problem($u, $name)) return [false, $bad];
    return [true, $name];
}

function critter_default_name(array $k, int $plotId): string
{
    $names = array_values(array_filter(array_map('trim', explode(',', (string)$k['names']))));
    if (!$names) return (string)$k['name'];
    $used = array_column(q('SELECT name FROM garden_critters WHERE plot_id = ?', [$plotId])->fetchAll(), 'name');
    foreach ($names as $n) if (!in_array($n, $used, true)) return $n;
    return $names[array_rand($names)];
}

/** Welcome a new resident (costs Petals) into a home. */
function critter_welcome(array $u, int $plotId, string $building, string $name): array
{
    if (setting('animals_on') === '0') return [false, 'Garden animals are resting for now.'];
    if (!critter_is_home($building)) return [false, 'That isn’t an animal home.'];
    if (animals120_blocked($building) || animals140_blocked($building)) return [false, 'Garden animals are resting for now.'];
    if ($building === 'snail_jar') return [false, 'Snails can’t be bought. Pick slugs and snails off your beds by hand and now and then one asks to stay.'];   // v1.4.0
    $plot = q_one('SELECT * FROM plots WHERE id = ? AND user_id = ?', [$plotId, $u['id']]);
    if (!$plot || !building_level($plotId, $building)) return [false, 'You haven’t built that here.'];
    $k = critter_main_kind($building);
    if (!$k) return [false, 'Nobody lives there yet.'];
    $have = (int)q_val('SELECT COUNT(*) FROM garden_critters WHERE plot_id = ? AND building = ?', [$plotId, $building]);
    if ($have >= critter_homes($plotId, $building)) return [false, 'Every home is taken. Upgrade the building to make room.'];
    $name = trim($name) === '' ? critter_default_name($k, $plotId) : $name;
    [$ok, $name] = critter_name_ok($u, $name);
    if (!$ok) return [false, $name];
    $cost = (int)$k['welcome_cost'];
    critter_forget();
    $res = db_tx(function () use ($u, $plotId, $building, $k, $name, $cost): ?array {
        if ($cost > 0 && !take_petals((int)$u['id'], (int)$cost)) {
            db()->rollBack();
            return [false, 'Welcoming a ' . strtolower((string)$k['name']) . ' costs ' . money($cost) . '.'];
        }
        db_insert('garden_critters', ['plot_id' => $plotId, 'building' => $building, 'kind' => $k['slug'], 'name' => $name, 'mood' => 50, 'meals' => 0,
            'fed_at' => null, 'gift_at' => now(), 'held' => 0, 'born_at' => now(), 'grows_at' => null, 'gifts_made' => 0]);
        if ((int)q_val('SELECT COUNT(*) FROM garden_critters WHERE plot_id = ? AND building = ?', [$plotId, $building]) > critter_homes($plotId, $building)) {   // v1.0.0: counted again inside the transaction
            db()->rollBack();
            return [false, 'Every home is taken. Upgrade the building to make room.'];
        }
        return null;
    });
    critter_forget();
    if ($res) return $res;
    unlock_entries((int)$u['id'], 'critter:' . $building);
    return [true, $k['icon'] . ' ' . $name . ' the ' . strtolower((string)$k['name']) . ' moves in!'];
}

function critter_rename(array $u, int $plotId, int $id, string $name): array
{
    $c = q_one('SELECT c.* FROM garden_critters c JOIN plots p ON p.id = c.plot_id WHERE c.id = ? AND c.plot_id = ? AND p.user_id = ?', [$id, $plotId, $u['id']]);
    if (!$c) return [false, 'That isn’t one of your animals.'];
    [$ok, $name] = critter_name_ok($u, $name);
    if (!$ok) return [false, $name];
    q('UPDATE garden_critters SET name = ? WHERE id = ?', [$name, $c['id']]);
    critter_forget();
    return [true, '✏️ Now called ' . $name . '.'];
}

/** Fill the feeders from the satchel. */
function critter_feed(array $u, int $plotId, string $building): array
{
    $uid = (int)$u['id'];
    if (!q_val('SELECT 1 FROM plots WHERE id = ? AND user_id = ?', [$plotId, $uid]) || !building_level($plotId, $building)) return [false, 'You haven’t built that here.'];
    $cap = max(1, (int)setting('critter_meals_cap'));
    $given = 0;
    $names = [];
    $hungry = false;
    $short = '';
    $foodNames = [];
    critter_forget();   // v1.0.1: read fresh before writing
    $r = db_tx(function () use ($uid, $plotId, $building, $cap, &$given, &$names, &$hungry, &$short, &$foodNames): array {
    foreach (critter_list($plotId, $building) as $c) {
        $foods = array_values(array_filter(array_map('trim', explode(',', (string)$c['k']['foods']))));
        if (!$foods) continue;
        $room = $cap - (int)$c['meals'];
        if ($room < 1) continue;
        $hungry = true;
        $foodNames = array_map(fn($s) => (string)(q_val('SELECT name FROM items WHERE slug = ?', [$s]) ?: $s), $foods);   // v1.2.0: the message names what they eat
        $took = 0;
        foreach ($foods as $slug) {
            $iid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
            $short = (string)q_val('SELECT name FROM items WHERE id = ?', [$iid]);
            $have = $iid ? (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $iid]) : 0;
            $n = min($room - $took, $have);
            if ($n > 0 && give_item($uid, $iid, -$n)) $took += $n;
            if ($took >= $room) break;
        }
        if ($took > 0) {
            if (q('UPDATE garden_critters SET meals = meals + ?, fed_at = ? WHERE id = ? AND meals + ? <= ?', [$took, now(), $c['id'], $took, $cap])->rowCount() !== 1) {   // v1.0.0: never past the cap, even with two feeders at once
                db()->rollBack();
                return [false, 'The feeder was just filled. Take a look again.'];
            }
            $given += $took;
            $names[] = $c['name'];
        }
    }
    if ($given > 0) return [true, '🍽️ You fill the feeder' . (count($names) > 1 ? 's' : '') . ' for ' . implode(', ', $names) . ' (' . $given . ' ' . ($short ?: 'food') . '). They look pleased.'];
    if (!$hungry) return [false, 'Everyone is full already, or finds their own food.'];
    if ($foodNames === ['Food Scrap']) return [false, 'You have nothing to feed them. Food Scraps are left over from eating raw crops.'];
    return [false, 'You have nothing to feed them. They eat ' . implode(', ', $foodNames) . '.'];
    });
    critter_forget();
    return $r;
}

/** Collect what the animals in a home have left. */
function critter_collect(array $u, int $plotId, string $building): array
{
    $uid = (int)$u['id'];
    if (!q_val('SELECT 1 FROM plots WHERE id = ? AND user_id = ?', [$plotId, $uid]) || !building_level($plotId, $building)) return [false, 'You haven’t built that here.'];
    $tally = [];
    critter_forget();
    $r = db_tx(function () use ($uid, $plotId, $building, &$tally): array {
    foreach (critter_list($plotId, $building) as $c) {
        $n = (int)$c['held'];
        if ($n < 1 || trim((string)$c['k']['gift_slug']) === '') continue;
        if (q('UPDATE garden_critters SET held = 0 WHERE id = ? AND held = ?', [$c['id'], $n])->rowCount() !== 1) continue;
        if ((int)$c['mood'] >= 80 && random_int(1, 100) <= max(0, (int)setting('critter_delight_pct'))) $n++;
        $tally[(string)$c['k']['gift_slug']] = ($tally[(string)$c['k']['gift_slug']] ?? 0) + $n;
    }
    if (!$tally) { db()->rollBack(); return [false, 'Nothing waiting yet. Check back soon.']; }
    $bits = [];
    foreach ($tally as $slug => $n) {
        $iid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
        if (!$iid) continue;
        give_item($uid, $iid, $n);
        $bits[] = $n . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$iid]);
    }
    return [true, BUILDINGS[$building][1] . ' You collect ' . implode(', ', $bits) . '.'];
    });
    critter_forget();
    return $r;
}

/** Pop a Frogspawn from the satchel into the pond: it hatches into a tadpole if there is a free home. */
function critter_hatch(array $u, int $plotId): array
{
    $uid = (int)$u['id'];
    if (!q_val('SELECT 1 FROM plots WHERE id = ? AND user_id = ?', [$plotId, $uid]) || !building_level($plotId, 'frog_pond')) return [false, 'You need a Frog Pond here.'];
    $tad = critter_kinds()['tadpole'] ?? null;
    if (!$tad) return [false, 'No tadpoles today.'];
    if ((int)q_val('SELECT COUNT(*) FROM garden_critters WHERE plot_id = ? AND building = ?', [$plotId, 'frog_pond']) >= critter_homes($plotId, 'frog_pond')) return [false, 'The pond is full of friends. Upgrade it to make room.'];
    $iid = (int)q_val("SELECT id FROM items WHERE slug = 'frogspawn'");
    $name = '';
    $res = db_tx(function () use ($uid, $iid, $tad, $plotId, &$name): ?array {
        if (!$iid || !give_item($uid, $iid, -1)) { db()->rollBack(); return [false, 'You need some Frogspawn. Frogs lay it in good weather.']; }
        $name = critter_default_name($tad, $plotId);
        db_insert('garden_critters', ['plot_id' => $plotId, 'building' => 'frog_pond', 'kind' => 'tadpole', 'name' => $name, 'mood' => 50, 'meals' => 0, 'fed_at' => null,
            'gift_at' => null, 'held' => 0, 'born_at' => now(), 'grows_at' => gmdate('Y-m-d H:i:s', time() + max(1, (int)setting('tadpole_days')) * 86400), 'gifts_made' => 0]);
        if ((int)q_val('SELECT COUNT(*) FROM garden_critters WHERE plot_id = ? AND building = ?', [$plotId, 'frog_pond']) > critter_homes($plotId, 'frog_pond')) {   // v1.0.0: re-counted inside the transaction
            db()->rollBack();
            return [false, 'The pond is full of friends. Upgrade it to make room.'];
        }
        return null;
    });
    critter_forget();
    if ($res) return $res;
    return [true, '🫧 The frogspawn hatches: ' . $name . ' the tadpole wriggles off. Feed it some scraps and it will grow.'];
}

/** Animal homes with something waiting: building => count. */
function critter_ready_map(int $plotId): array
{
    $out = [];
    foreach (array_keys(GARDEN_CRITTER_HOMES) as $b) {
        if (!building_level($plotId, $b)) continue;
        $n = critter_ready($plotId, $b);
        if ($n > 0) $out[$b] = $n;
    }
    return $out;
}

/** The art for a critter kind (assets/img/animals/{kind}.svg). */
function critter_img(string $kind, string $cls = 'cimg'): string
{
    $rel = 'assets/img/animals/' . $kind . '.svg';
    return is_file(APP_ROOT . '/' . $rel) ? '<img class="' . e($cls) . '" src="' . e(url($rel)) . '" alt="" width="40" height="40" loading="lazy">' : '';
}

/** v1.6.3: the word for what a home's animals are fed (scraps for most, leaves for silkworms, greens for the tortoise). */
function critter_food_unit(string $b, array $foodSlugs): string
{
    return array_keys($foodSlugs) === ['food-scrap'] ? 'scraps' : ($b === 'silk_shelf' ? 'leaves' : ($b === 'snail_jar' ? 'scraps and lettuce' : 'greens'));
}

/**
 * v1.6.3: the "Next gift" line for one resident, worked out the way critter_tick does (gift_hours, -15% per building level past 1,
 * half speed or so while sulking, the clock waits while the feeder is short, and stops while the gifts are full).
 * Returns '' when this animal makes no gifts.
 */
function critter_gift_line(array $c, array $k, string $unit): string
{
    if (trim((string)$k['gift_slug']) === '' || (int)$k['gift_cap'] < 1) return '';
    static $names = [];
    $slug = (string)$k['gift_slug'];
    $names[$slug] ??= (string)(q_val('SELECT name FROM items WHERE slug = ?', [$slug]) ?: $slug);
    if ((int)$c['held'] >= (int)$k['gift_cap']) return 'Gifts are full: collect them';
    $need = (int)$k['meals_per'];
    if ($need > 0 && (int)$c['meals'] < $need) return 'Needs ' . $need . ' ' . $unit . ' to start the next ' . $names[$slug];
    $lv = max(1, building_level((int)$c['plot_id'], (string)$c['building']));
    $hrs = max(1.0, (int)$k['gift_hours'] * (100 - 15 * ($lv - 1)) / 100);
    $rate = (int)$c['mood'] < 30 ? max(10, (int)setting('critter_sleepy_pct')) / 100 : 1.0;
    $gift = $c['gift_at'] ? ts($c['gift_at']) : time();
    $left = max(60, (int)round($hrs * 3600 / $rate) - (time() - $gift));
    return 'Next ' . $names[$slug] . ' in ~' . ($left >= 3600 ? max(1, (int)round($left / 3600)) . 'h' : max(1, (int)ceil($left / 60)) . 'm');
}

/** The panel inside a home's building tile: residents, feeder, gifts, welcome form. */
function critter_panel_html(array $u, array $plot, string $b): string
{
    $plotId = (int)$plot['id'];
    $list = critter_list($plotId, $b);
    $homes = critter_homes($plotId, $b);
    $main = critter_main_kind($b);
    $cap = max(1, (int)setting('critter_meals_cap'));
    $h = '<div class="crits">';
    $anyFood = false;
    $ready = 0;
    if ($list) {
        $h .= '<ul class="critlist">';
        foreach ($list as $c) {
            $k = $c['k'];
            [$word, $face, $cls] = critter_mood_word((int)$c['mood']);
            $eats = trim((string)$k['foods']) !== '';
            $anyFood = $anyFood || $eats;
            $ready += (int)$c['held'];
            $line = [];
            $unitC = critter_food_unit($b, array_fill_keys(array_filter(array_map('trim', explode(',', (string)$k['foods']))), true));   // v1.6.3
            if ($eats) $line[] = '🍽️ ' . (int)$c['meals'] . '/' . ((int)$k['meals_per'] > 0 ? (int)$k['meals_per'] . ' ' . $unitC : $cap);   // v1.6.3: feeder against what one gift needs
            if (($gl = critter_gift_line($c, $k, $unitC)) !== '') $line[] = '⏳ ' . $gl;   // v1.6.3
            if ((int)$c['held'] > 0) $line[] = '🎁 ' . (int)$c['held'];
            if ($c['kind'] === 'tadpole' && $c['grows_at']) $line[] = $c['fed_at'] ? '🌱 growing up in ' . nice_time(max(60, ts($c['grows_at']) - time())) : '🌱 needs a feed to grow';
            $h .= '<li class="crit ' . e($cls) . '">' . critter_img((string)$c['kind'])
                . '<span class="critmain"><b>' . eu($c['name']) . '</b> <small class="muted">' . e($k['name']) . '</small>'
                . ' <span class="mood ' . e($cls) . '" title="' . e($word === 'Sulking' ? 'Works at half speed until it is fed or happier' : ($word === 'Delighted' ? 'Might leave an extra gift' : 'Doing fine')) . '">' . $face . ' ' . e($word) . ($word === 'Sulking' ? ' <small class="muted">half speed</small>' : ($word === 'Delighted' ? ' <small class="muted">extra gift</small>' : '')) . '</span>'
                . ($line ? '<br><small>' . e(implode(' · ', $line)) . '</small>' : '') . '</span>'
                . '<details class="critname"><summary aria-label="Rename ' . e($c['name']) . '">✏️</summary><form method="post" class="inline">' . csrf_field()
                . '<input type="hidden" name="do" value="critter_rename"><input type="hidden" name="critter" value="' . (int)$c['id'] . '"><input type="hidden" name="building" value="' . e($b) . '">'
                . '<input name="name" value="' . e($c['name']) . '" maxlength="20" aria-label="New name"> <button class="btn small">Rename</button></form></details></li>';
        }
        $h .= '</ul>';
    } else {
        $h .= '<p class="help">No residents yet.</p>';
    }
    $h .= '<div class="btrow">';
    $foodSlugs = [];   // v1.2.0: what this home's animals eat (scraps for most, leaves for silkworms, greens for the tortoise)
    foreach ($list as $c) foreach (array_filter(array_map('trim', explode(',', (string)$c['k']['foods']))) as $fs) $foodSlugs[$fs] = true;
    $scraps = 0;
    if ($foodSlugs) {
        $in = implode(',', array_fill(0, count($foodSlugs), '?'));
        $scraps = (int)q_val("SELECT COALESCE(SUM(ui.qty), 0) FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug IN ($in)", array_merge([(int)$u['id']], array_keys($foodSlugs)));
    }
    $unit = critter_food_unit($b, $foodSlugs);   // v1.6.3
    if ($anyFood) {
        $h .= '<form method="post">' . csrf_field() . '<input type="hidden" name="do" value="critter_feed"><input type="hidden" name="building" value="' . e($b) . '">'
            . '<button class="btn small"' . ($scraps > 0 ? '' : ' disabled') . '>🍽️ Feed' . ($scraps > 0 ? ' (' . $scraps . ' ' . $unit . ')' : '') . '</button></form>';
    }
    if ($b === 'frog_pond' && count($list) < $homes) {
        $spawn = (int)q_val("SELECT ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = 'frogspawn'", [(int)$u['id']]);
        if ($spawn > 0) $h .= '<form method="post">' . csrf_field() . '<input type="hidden" name="do" value="critter_hatch"><button class="btn small alt">🫧 Hatch Frogspawn (' . $spawn . ')</button></form>';
    }
    $h .= '</div>';
    if ($main && count($list) < $homes && $b !== 'snail_jar') {   // v1.4.0: snails are rescued, not welcomed
        $h .= '<form method="post" class="welcome inline">' . csrf_field() . '<input type="hidden" name="do" value="critter_welcome"><input type="hidden" name="building" value="' . e($b) . '">'
            . '<label>Name <input name="name" maxlength="20" placeholder="' . e(explode(',', (string)$main['names'])[0] ?? '') . '" aria-label="A name for the new ' . e(strtolower((string)$main['name'])) . '"></label> '
            . '<button class="btn small">' . e((string)$main['icon']) . ' Welcome a ' . e(strtolower((string)$main['name'])) . ' · ' . money((int)$main['welcome_cost']) . '</button></form>';
    }
    $h .= '<p class="help">' . count($list) . ' of ' . $homes . ' homes. ' . e($main['quirk'] ?? '') . '</p>';
    if ($anyFood) $h .= '<p class="help">⏳ The gift clock only runs while the feeder holds enough for one gift, and each gift uses that much up.</p>';   // v1.6.3
    if ($b === 'snail_jar' && count($list) < $homes) $h .= '<p class="help">🐌 Pick slugs and snails off your beds by hand: now and then a snail asks to come and live here.</p>';   // v1.4.0
    if ($b === 'butterfly_bush') $h .= '<p class="help">🦋 Flowers growing within 2 squares of the bush (place it by your flower beds in the yard designer) sometimes give an extra stem.</p>';
    if ($b === 'frog_pond' && $list && in_array(hollow_now()['daypart'], ['dusk', 'night'], true)) {
        foreach ($list as $c) if ($c['kind'] === 'frog') { $h .= '<p class="help">🌙 ' . eu($c['name']) . ' croaks happily from a lily pad.</p>'; break; }
    }
    return $h . '</div>';
}

/** The status word for a home's tile in the buildings panel. */
function critter_status(int $plotId, string $b): string
{
    $list = critter_list($plotId, $b);
    $ready = array_sum(array_map(fn($c) => (int)$c['held'], $list));
    if ($ready > 0) return $ready . ' ready';
    return count($list) . '/' . critter_homes($plotId, $b) . ' home' . (critter_homes($plotId, $b) === 1 ? '' : 's');
}

/** For visitors: a line about the home. */
function critter_peek_lines(int $plotId, string $b): array
{
    $out = [];
    $list = critter_list($plotId, $b);
    if (!$list) return ['Quiet and empty. For now.'];
    foreach (array_slice($list, 0, 4) as $c) {
        [$word, $face] = critter_mood_word((int)$c['mood']);
        $out[] = $face . ' ' . $c['name'] . ' the ' . strtolower((string)$c['k']['name']) . ' looks ' . strtolower($word) . '.';
    }
    return $out;
}

/** Curb appeal from the animals: a point for each resident (up to 8). */
function critter_appeal(int $plotId): int
{
    return min(8, (int)q_val('SELECT COUNT(*) FROM garden_critters WHERE plot_id = ?', [$plotId]));
}

// ----------------------------------------------------------------- Biddy, the neighbour's hen

/** Is Biddy at this garden's fence on a Hollow day? */
function biddy_here(array $plot, ?string $date = null): bool
{
    if (setting('biddy_on') === '0' || setting('animals_on') === '0') return false;
    $date ??= hollow_today();
    $chance = max(0, (int)setting('biddy_chance')) + min(20, intdiv((int)($plot['appeal'] ?? 0), 5));
    return hollow_unit('biddy|' . $plot['id'] . '|' . $date) * 100 < min(100, $chance);
}

/** Days she has traded with this garden. */
function biddy_friendship(int $plotId): int
{
    return (int)q_val("SELECT COUNT(*) FROM garden_visitors WHERE plot_id = ? AND kind = 'biddy' AND traded = 1", [$plotId]);
}

function biddy_traded_today(int $plotId): bool
{
    return (bool)q_val("SELECT 1 FROM garden_visitors WHERE plot_id = ? AND kind = 'biddy' AND day = ? AND traded = 1", [$plotId, hollow_today()]);
}

/** Offer Food Scraps to Biddy at the fence. She gives a Hen Egg for each few scraps, and sometimes a feather. */
function biddy_trade(array $u, int $plotId, int $scraps): array
{
    $uid = (int)$u['id'];
    $plot = q_one('SELECT * FROM plots WHERE id = ? AND user_id = ?', [$plotId, $uid]);
    if (!$plot) return [false, 'That isn’t your garden.'];
    if (!biddy_here($plot)) return [false, 'Biddy isn’t at the fence today.'];
    $per = max(1, (int)setting('biddy_scraps_per_egg'));
    $scraps = max(0, min($scraps, max(1, (int)setting('biddy_max_scraps'))));
    $eggs = intdiv($scraps, $per);
    if ($eggs < 1) return [false, 'Biddy wants at least ' . $per . ' Food Scraps for an egg.'];
    $take = $eggs * $per;
    $scrapId = (int)q_val("SELECT id FROM items WHERE slug = 'food-scrap'");
    $eggId = (int)q_val("SELECT id FROM items WHERE slug = 'hen-egg'");
    $featherId = (int)q_val("SELECT id FROM items WHERE slug = 'hen-feather'");
    if (!$scrapId || !$eggId) return [false, 'Biddy looks confused.'];
    db()->beginTransaction();
    try {
        db_insert('garden_visitors', ['plot_id' => $plotId, 'kind' => 'biddy', 'day' => hollow_today(), 'traded' => 1, 'scraps' => $take]);
    } catch (PDOException $e) {
        db()->rollBack();
        return [false, 'Biddy has had her fill today. She’ll be back another day.'];
    }
    if (!give_item($uid, $scrapId, -$take)) { db()->rollBack(); return [false, 'You don’t have that many Food Scraps. Eating raw crops leaves them.']; }
    give_item($uid, $eggId, $eggs);
    $friend = biddy_friendship($plotId);
    $msg = '🐔 Biddy clucks happily and trades you ' . $eggs . ' × Hen Egg' . ($eggs === 1 ? '' : 's') . ' for ' . $take . ' Food Scraps.';
    if ($featherId && random_int(1, 100) <= min(80, max(0, (int)setting('biddy_feather_pct')) + 5 * max(0, $friend - 1))) {
        give_item($uid, $featherId, 1);
        $msg .= ' She leaves a speckled feather too.';
    }
    db()->commit();
    unlock_entries($uid, 'critter:biddy');
    add_xp($uid, 2);
    return [true, $msg . ' +2 XP.'];
}

/** The card shown under the yard when Biddy is at the fence. */
function biddy_html(array $u, array $plot): string
{
    if (!biddy_here($plot)) return '';
    unlock_entries((int)$u['id'], 'critter:biddy');
    $plotId = (int)$plot['id'];
    $img = is_file(APP_ROOT . '/assets/img/animals/hen.svg') ? '<img class="cimg" src="' . e(url('assets/img/animals/hen.svg')) . '" alt="" width="48" height="48" loading="lazy">' : '<span class="oi">🐔</span>';
    $h = '<div class="biddy box">' . $img . '<div><b>Biddy is at the fence</b> <small class="muted">the neighbour’s hen · ' . biddy_friendship($plotId) . ' trades so far</small><br>';
    if (biddy_traded_today($plotId)) return $h . '<small>She has had her fill today and bobs her head in thanks. 🥚</small></div></div>';
    $have = (int)q_val("SELECT ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = 'food-scrap'", [(int)$u['id']]);
    $per = max(1, (int)setting('biddy_scraps_per_egg'));
    $max = min($have, max(1, (int)setting('biddy_max_scraps')));
    if ($max < $per) return $h . '<small>She eyes the ground hopefully. Bring ' . $per . ' Food Scraps (left from eating raw crops) and she will trade an egg. Eggs cook into omelettes, pancakes and more (see Recipes).</small></div></div>';
    $h .= '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="biddy">'
        . '<label>Scraps <select name="scraps">';
    for ($n = $per; $n <= $max; $n += $per) $h .= '<option value="' . $n . '">' . $n . ' → ' . intdiv($n, $per) . ' egg' . (intdiv($n, $per) === 1 ? '' : 's') . '</option>';
    return $h . '</select></label> <button class="btn small">🥚 Trade</button></form></div></div>';
}
