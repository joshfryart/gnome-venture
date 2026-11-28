<?php
declare(strict_types=1);
/**
 * Quest content of Wren's Journey v2 (2026-11-28; claude/proposal-story-2-quests.md 3 to 5, claude/proposal-story-3-flavor.md 3 and 4):
 * the loaders of the data files that have no engine of their own yet. Read only while the setting journey_v2_open is on (journey_v2_on());
 * with it off every loader here returns nothing, so the game has none of this content.
 *
 *   data/journey_errands.txt   errands (side quests), happening acts and the two helper errands of the main line
 *   data/journey_extras.txt    what they give the first time: secret places, stop themes, recipes, teas, stall lines, pages, carried things
 *   data/stop_state.txt        a stop's dark and relit arrival text, by stop type
 *   data/stop_band_lines.txt   ambience, Regulars' chat and plaque lines by band
 * The main chapters are data/journey_chapters.txt (journey_v2.php) and the threads data/stop_threads_v2.txt (stop_threads(), stop_living.php).
 * Nothing in the game shows or grants these rows yet: the errands engine (build plan 10) reads them from here.
 */

require_once __DIR__ . '/catalog.php';
require_once __DIR__ . '/journey_v2.php';

/** Q row fields after the "Q" (journey_errands.txt). */
const QUEST_Q_COLS = ['id', 'area', 'zone', 'kind', 'giver', 'trigger', 'repeat', 'lv', 'reward', 'extra', 'title', 'intro', 'outro'];
/** S row fields after the "S". */
const QUEST_S_COLS = ['errand', 'kind', 'spec', 'qty', 'alt', 'label'];
/** Errand kinds that count as side quests (the others: helper, happening). */
const QUEST_SIDE_KINDS = ['lost', 'creature', 'deliver', 'garden'];
/** Row fields of journey_extras.txt after the row type. */
const QUEST_EXTRA_COLS = [
    'PLACE' => ['slug', 'region', 'zone', 'type', 'name', 'text'],
    'THEME' => ['slug', 'types', 'tier', 'name', 'icon', 'gives', 'plaque'],
    'RECIPE' => ['slug', 'name', 'ingredients', 'buff', 'minutes', 'energy', 'text', 'tier', 'cook'],
    'TEA' => ['slug', 'name', 'components', 'note'],
    'SHOP' => ['slug', 'region', 'name', 'text'],
    'PAGE' => ['slug', 'title', 'text'],
    'ITEM' => ['slug', 'name', 'text'],
];
/** Areas by band (master doc 2.1), for the band lines. */
const QUEST_BANDS = ['NA' => 1, 'CA' => 2, 'NWE' => 2, 'CB' => 3, 'SA' => 3, 'SE' => 3, 'EE' => 3, 'MENA' => 4, 'CSA' => 4, 'WCA' => 4, 'ESA' => 4, 'EA' => 5, 'SEA' => 5, 'OC' => 5];

/** The rows of a v2 data file, or none while Journey v2 is off. */
function quest_data_rows(string $file): array
{
    return journey_v2_on() ? catalog_lines($file) : [];
}

/** A row as named fields (missing ones are ''), or null when it is too short. */
function quest_data_row(array $r, array $cols, int $need): ?array
{
    return count($r) < $need ? null : array_combine($cols, array_slice(array_pad($r, count($cols), ''), 0, count($cols)));
}

/** data/journey_errands.txt: id => the Q row with 'steps' => its S rows in file order. "\n" in the intro and outro is a new line. */
function journey_errands(): array
{
    $out = [];
    foreach (quest_data_rows('journey_errands.txt') as $r) {
        $kind = array_shift($r);
        if ($kind === 'Q' && ($q = quest_data_row($r, QUEST_Q_COLS, count(QUEST_Q_COLS)))) {
            foreach (['intro', 'outro'] as $k) $q[$k] = str_replace('\n', "\n", $q[$k]);
            $out[$q['id']] = $q + ['steps' => []];
        } elseif ($kind === 'S' && ($s = quest_data_row($r, QUEST_S_COLS, count(QUEST_S_COLS))) && isset($out[$s['errand']])) {
            $out[$s['errand']]['steps'][] = $s;
        }
    }
    return $out;
}

/** The errands that are side quests (63; with the 17 area threads, the 80 of the quests doc). */
function journey_side_errands(): array
{
    return array_filter(journey_errands(), fn($q) => in_array($q['kind'], QUEST_SIDE_KINDS, true));
}

/** data/journey_extras.txt: row type => slug => row. */
function journey_extras(): array
{
    $out = array_fill_keys(array_keys(QUEST_EXTRA_COLS), []);
    foreach (quest_data_rows('journey_extras.txt') as $r) {
        $type = (string)array_shift($r);
        $cols = QUEST_EXTRA_COLS[$type] ?? null;
        if ($cols && ($row = quest_data_row($r, $cols, 3))) $out[$type][$row['slug']] = $row;
    }
    return $out;
}

/** An `extra` field as [[key, value], …]: "page=a,unlock=place:b" => [['page', 'a'], ['unlock', 'place:b']]. */
function quest_extra_parts(string $extra): array
{
    $out = [];
    foreach (array_filter(array_map('trim', explode(',', $extra)), fn($p) => $p !== '' && $p !== '-') as $part) {
        $kv = explode('=', $part, 2);
        $out[] = [$kv[0], $kv[1] ?? ''];
    }
    return $out;
}

/** What a stop of this type looks like on arrival, dark (tier 0) or lit: '' when there is no line (or Journey v2 is off). */
function stop_state_text(string $type, bool $lit): string
{
    foreach (quest_data_rows('stop_state.txt') as $r) {
        if (count($r) >= 3 && $r[0] === $type && $r[1] === ($lit ? 'lit' : 'dark')) return $r[2];
    }
    return '';
}

/**
 * data/stop_band_lines.txt for an area: ['A' => [[when, text], …], 'C' => [[glow, personality, line], …], 'P' => [[tier, plaque], …]].
 * Empty lists for an unknown area (or while Journey v2 is off).
 */
function stop_band_lines(string $regionCode): array
{
    $out = ['A' => [], 'C' => [], 'P' => []];
    $band = QUEST_BANDS[$regionCode] ?? 0;
    foreach (quest_data_rows('stop_band_lines.txt') as $r) {
        if (count($r) >= 4 && isset($out[$r[0]]) && (int)$r[1] === $band) $out[$r[0]][] = array_slice($r, 2);
    }
    return $out;
}
