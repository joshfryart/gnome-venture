<?php
declare(strict_types=1);

/*
 * v0.8.9: region climates that really do something.
 * Each region has a flavour name (regions.climate_trait, e.g. "Crisp winters") and an effect list (regions.climate,
 * e.g. "cool:10, tropical:-10"), both editable in Admin → Regions. The sentence players see is written from the
 * effect list, so the text always matches what the game does. Effects apply to gardens in that region
 * (growing, watering, weeds, perennial regrowths) and to walks into it (walk time, finds).
 *
 * Effect keys (numbers are percentages, + or −):
 *   grow        every crop grows faster/slower
 *   cool        crops labelled cool-climate (plants.climate, Admin → Plants)
 *   tropical    crops labelled tropical
 *   fast        quick crops (grow time up to setting climate_fast_minutes)
 *   perennial   perennial crops
 *   <kind>      a crop kind: vegetable, fruit, tree, nut, grain, herb, spice, legume, tuber, flower, cover
 *   <slug>      one crop by its slug, e.g. coffee
 *   water       how long a watering lasts
 *   water_bare  extra change to watering on squares with no mulch
 *   weeds       how fast weeds creep into no-till beds
 *   regrow_yield  extra harvest from perennial regrowths
 *   walk        how long road walks into the region take
 *   finds       extra Petals and a chance of a second find on walks there
 * A greenhouse shelters crops from growth penalties (bonuses still count).
 */

const CLIMATE_DEFAULTS = [
    'NA' => ['Crisp winters', 'cool:10, tropical:-10'],
    'CA' => ['Dry spells', 'water:-10'],
    'CB' => ['Sea breeze', 'perennial:15'],
    'SA' => ['Two worlds', 'cool:10, tropical:10'],
    'NWE' => ['Soft rain', 'water:20'],
    'SE' => ['Long sunny days', 'fruit:15, tree:15'],
    'EE' => ['Short, hot summers', 'fast:15'],
    'MENA' => ['Dry heat', 'water:-10, water_bare:-20'],
    'WCA' => ['Rainy season', 'water:20, weeds:25'],
    'ESA' => ['Highland sun', 'grain:15, coffee:15'],
    'CSA' => ['Monsoon', 'spice:15, herb:15'],
    'EA' => ['Four seasons', 'regrow_yield:10'],
    'SEA' => ['Steamy', 'water:-15, grow:10'],
    'OC' => ['Island time', 'walk:25, finds:25'],
];

const CLIMATE_KINDS = ['vegetable', 'fruit', 'tree', 'nut', 'grain', 'herb', 'spice', 'legume', 'tuber', 'flower', 'cover'];

/** Fill in missing climates (fresh worlds and upgrades) and trim old full sentences down to the flavour name. */
function ensure_climates(): void
{
    foreach (CLIMATE_DEFAULTS as $code => [$name, $fx]) {
        q("UPDATE regions SET climate = ? WHERE code = ? AND (climate IS NULL OR climate = '')", [$fx, $code]);
        q("UPDATE regions SET climate_trait = ? WHERE code = ? AND climate_trait LIKE ?", [$name, $code, $name . ':%']);
    }
    require_once __DIR__ . '/gardens.php';
    ensure_plant_climates();
}

/** A region's effects as key => percent. */
function climate_fx(int $regionId): array
{
    static $cache = [];
    if ($regionId <= 0) return [];
    if (!isset($cache[$regionId])) {
        $fx = [];
        foreach (explode(',', (string)q_val('SELECT climate FROM regions WHERE id = ?', [$regionId])) as $part) {
            if (!preg_match('/^\s*([a-z0-9_-]+)\s*:\s*([+-]?\d+)\s*$/i', $part, $m)) continue;
            $fx[strtolower($m[1])] = max(-90, min(300, (int)$m[2]));
        }
        $cache[$regionId] = $fx;
    }
    return $cache[$regionId];
}

/** Crops that count as cool-climate or tropical (each plant's label is editable in Admin → Plants; this only fills in blanks). */
const CLIMATE_COOL_CROPS = 'crimson-clover white-clover winter-rye blackcurrant blueberry cloudberry cranberry elderberry gooseberry lingonberry raspberry sea-buckthorn strawberry '
    . 'barley buckwheat oats rye wheat wild-rice dill mint parsley sorrel thyme fava-bean pea chestnut hazelnut walnut pecan hops ginseng wasabi horseradish '
    . 'apple cherry pear plum quince apricot rhubarb potato asparagus beet bok-choy broccoli brussels-sprouts cabbage carrot cauliflower celery collard kale '
    . 'kohlrabi leek lettuce napa-cabbage radish spinach turnip daikon garlic onion fennel';
const CLIMATE_TROPICAL_CROPS = 'banana dragon-fruit ensete papaya passion-fruit pineapple plantain fonio sugarcane lemongrass black-pepper cardamom cinnamon clove '
    . 'ginger grains-of-paradise nutmeg turmeric vanilla acai ackee breadfruit cacao coconut coffee durian guava jackfruit kava longan lychee mamey mango '
    . 'mangosteen noni pandanus rambutan sago salak soursop starfruit cassava taro yam kangkong bitter-melon okra chayote egusi jute-mallow lotus-root '
    . 'brazil-nut cashew kola macadamia shea bambara cowpea pigeon-pea moringa naranjilla cherimoya tamarind avocado';

/** Label crops that have no climate yet: the lists above, then flowers by where they're native. Runs on every upgrade; only fills blanks. */
function ensure_plant_climates(): void
{
    $cool = array_flip(explode(' ', CLIMATE_COOL_CROPS));
    $trop = array_flip(explode(' ', CLIMATE_TROPICAL_CROPS));
    $codes = array_column(q('SELECT id, code FROM regions')->fetchAll(), 'code', 'id');
    foreach (q('SELECT id, slug, kind FROM plants WHERE climate IS NULL')->fetchAll() as $p) {
        $c = isset($cool[$p['slug']]) ? 'cool' : (isset($trop[$p['slug']]) ? 'tropical' : '');
        if ($c === '' && $p['kind'] === 'flower') {
            $mine = array_map(fn($id) => $codes[$id] ?? '', plant_regions_native((int)$p['id']));
            if ($mine && !array_diff($mine, ['NA', 'NWE', 'EE'])) $c = 'cool';
            elseif ($mine && !array_diff($mine, ['CB', 'SA', 'WCA', 'SEA'])) $c = 'tropical';
        }
        q('UPDATE plants SET climate = ? WHERE id = ?', [$c, $p['id']]);
    }
}

/** Is this crop cool-climate, tropical or neither? */
function climate_class(array $p): string
{
    $c = (string)($p['climate'] ?? '');
    return in_array($c, ['cool', 'tropical'], true) ? $c : '';
}

/** What a region's climate does to one square (and the crop in it, if any). */
function climate_tile(int $regionId, ?array $p, bool $greenhouse = false): array
{
    $fx = climate_fx($regionId);
    if (!$fx) return [];
    $out = ['grow' => 0];
    foreach (['water', 'water_bare', 'weeds', 'regrow_yield'] as $k) if (isset($fx[$k])) $out[$k] = $fx[$k];
    if ($p) {
        $g = $fx['grow'] ?? 0;
        $class = climate_class($p);
        if ($class !== '') $g += $fx[$class] ?? 0;
        if (isset($fx['fast']) && (int)$p['grow_minutes'] <= (int)setting('climate_fast_minutes')) $g += $fx['fast'];
        if (isset($fx['perennial']) && (int)$p['perennial']) $g += $fx['perennial'];
        if (isset($fx[(string)$p['kind']])) $g += $fx[(string)$p['kind']];
        $slug = (string)($p['slug'] ?? '');
        if ($slug !== '' && !in_array($slug, CLIMATE_KINDS, true) && isset($fx[$slug])) $g += $fx[$slug];
        $out['grow'] = $greenhouse ? max(0, $g) : $g;
    }
    return $out;
}

/** The sentence players see, e.g. "Crisp winters: cool-climate crops grow 10% faster, tropical crops 10% slower." */
function climate_text(array $region): string
{
    $name = trim(strtok((string)($region['climate_trait'] ?? ''), ':') ?: '');
    $fx = climate_fx((int)$region['id']);
    $grow = fn(string $what, int $n) => $what . ' grow' . (str_ends_with($what, 'thing') ? 's ' : ' ') . abs($n) . '% ' . ($n >= 0 ? 'faster' : 'slower');
    $bits = [];
    foreach ($fx as $k => $n) {
        $bits[] = match (true) {
            $k === 'grow' => $grow('everything', $n),
            $k === 'cool' => $grow('cool-climate crops', $n),
            $k === 'tropical' => $grow('tropical crops', $n),
            $k === 'fast' => $grow('quick crops (' . (int)setting('climate_fast_minutes') . ' min or less)', $n),
            $k === 'perennial' => $grow('perennials', $n),
            in_array($k, CLIMATE_KINDS, true) => $grow(['tree' => 'trees', 'herb' => 'herbs', 'spice' => 'spices', 'grain' => 'grains', 'nut' => 'nut trees',
                'legume' => 'beans and peas', 'tuber' => 'tubers', 'flower' => 'flowers', 'cover' => 'cover crops', 'vegetable' => 'vegetables', 'fruit' => 'fruit crops'][$k], $n),
            $k === 'water' => 'watering lasts ' . abs($n) . '% ' . ($n >= 0 ? 'longer' : 'shorter'),
            $k === 'water_bare' => abs($n) . '% ' . ($n >= 0 ? 'longer' : 'shorter') . ' again without mulch',
            $k === 'weeds' => 'weeds grow ' . abs($n) . '% ' . ($n >= 0 ? 'faster' : 'slower'),
            $k === 'regrow_yield' => 'perennial regrowths give ' . abs($n) . '% ' . ($n >= 0 ? 'more' : 'less'),
            $k === 'walk' => 'walks here take ' . abs($n) . '% ' . ($n >= 0 ? 'longer' : 'less time'),
            $k === 'finds' => 'finds on the way are ' . abs($n) . '% ' . ($n >= 0 ? 'richer' : 'poorer'),
            default => strtolower((string)(q_val('SELECT name FROM plants WHERE slug = ?', [$k]) ?: str_replace('-', ' ', $k)))
                . ' grows ' . abs($n) . '% ' . ($n >= 0 ? 'faster' : 'slower'),   // one crop by slug, e.g. "coffee grows 15% faster"
        };
    }
    $txt = implode(', ', $bits);
    if ($txt === '') return $name;
    return ($name !== '' ? $name . ': ' : '') . $txt . '.';
}
