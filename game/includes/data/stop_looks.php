<?php
declare(strict_types=1);
/**
 * Rest-stop picture looks. A stop's picture is chosen by its TYPE, its LANDSCAPE and a regional building STYLE:
 *   scenes/here-stop-<type>-<landscape>_<style>.png (+ a layout key of the same name in here_layouts.json).
 * This file maps a region code (regions.code) to the style. A region with no entry (or a style with no picture) falls back to another look of the
 * same type + landscape, then stop-<type>-<landscape>, stop-<type>, stop-<landscape>, stop, generic (here_layout_find).
 * Looks drawn: grassland_maplewold for market, mill, shrine, jetty, herb, workshop, orchard, tower, camp (2.7.01, art-2701-batch3/stops/opus3) and inn, ferry,
 * spring (2.7.01 step 2, art-2701-batch4/stops/opus3): all 12 types; desert_adobe for all 12 types.
 * Adding a look = draw it (aseprite-source/v3/here-gate/pilot-market.lua takes pal=<landscape>_<style>), add the PNG + layout, and one line here.
 */
return [
    'NA' => 'maplewold', 'NWE' => 'maplewold', 'EE' => 'maplewold',
    'MENA' => 'adobe', 'CA' => 'adobe', 'ESA' => 'adobe', 'CSA' => 'adobe',
];
