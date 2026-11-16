<?php
declare(strict_types=1);
/**
 * 2.5D villager sprites (aseprite-source/npc25/PATHWAY.md): one strip per species and view in assets/img/npc25/<species>-<front|back|side>.png (512 x 80: 8 frames of 64 x 80; frames 1-2 idle, 3-8 walk),
 * and one per gnome NPC (gnome-<npc slug>-<view>.png, drawn from the player's gnome rig by tools/gen_gnome_npcs.php). Every place that draws a villager asks here first and falls back to the old
 * idle sprite or emoji when a strip is missing, so nothing breaks if a file is removed.
 */

/** 'Field mouse' / 'Stag beetle' / 'Wood Mouse' => 'field-mouse' ... (the file names of the npc25 strips and the folk sprites). */
function npc25_species_key(string $species): string
{
    $sp = strtolower(trim($species));
    if ($sp === 'mouse') $sp = 'field-mouse';
    if ($sp === 'dormouse') return 'dormouse';
    return str_replace(' ', '-', $sp);
}

/** The strip of a species and view (front back side) as [url, [64, 80]], or null while that species is not drawn yet. */
function npc25_file_strip(string $species, string $view = 'front'): ?array
{
    static $memo = [];
    $k = npc25_species_key($species) . '-' . $view;
    if (!array_key_exists($k, $memo)) { $rel = 'assets/img/npc25/' . $k . '.png'; $memo[$k] = is_file(APP_ROOT . '/' . $rel) ? [url($rel), [64, 80]] : null; }
    return $memo[$k];
}


/** The strip of a species (or of a named gnome NPC when $slug is given and the species is Gnome) and view: [url, [64, 80]] or null. */
function npc25_strip(string $species, string $view = 'front', string $slug = ''): ?array
{
    if (strtolower(trim($species)) === 'gnome') return $slug !== '' ? npc25_file_strip('gnome-' . preg_replace('/[^a-z0-9-]/', '', strtolower($slug)), $view) : null;
    return npc25_file_strip($species, $view);
}

/** The strip of a town NPC row (species + slug) or a stop villager row, as above. */
function npc25_for(array $npc, string $view = 'front'): ?array
{
    return npc25_strip((string)($npc['species'] ?? ''), $view, (string)($npc['slug'] ?? ''));
}
