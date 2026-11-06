<?php
declare(strict_types=1);
/**
 * Rest-stop picture looks. A stop's picture is chosen by its TYPE, its LANDSCAPE and a regional building STYLE:
 *   scenes/here-stop-<type>-<landscape>_<style>.png (+ a layout key of the same name in here_layouts.json).
 * This file maps a region code (regions.code) to the style. A region with no entry (or a style with no picture) falls back to another look of the
 * same type + landscape, then stop-<type>-<landscape>, stop-<type>, stop-<landscape>, stop, generic (here_layout_find).
 * Adding a look = draw it (aseprite-source/v3/here-gate/pilot-market.lua takes pal=<landscape>_<style>), add the PNG + layout, and one line here.
 */
return [
    'NA' => 'maplewold', 'NWE' => 'maplewold', 'EE' => 'maplewold',
    'MENA' => 'adobe', 'CA' => 'adobe', 'ESA' => 'adobe', 'CSA' => 'adobe',
];
