<?php
declare(strict_types=1);
/**
 * 2.6.89: where the piece renderer (assets/pfparts.js) finds its parts kit. The new jigsaw pieces (56 x 47 body, 13 px tabs, drawn in Aseprite:
 * assets/img/pfight/parts47/, built by tools/build_parts47.py from aseprite-source/pfight/v47) are used when their atlas.json exists; the setting
 * pfight_jigsaw = 0 switches back to the old kit (assets/img/pfight/parts/) without a deploy. Returns null when neither kit is there.
 */
function pfight_parts_url(): ?string
{
    static $u = false;
    if ($u !== false) return $u;
    $base = __DIR__ . '/../assets/img/pfight/';
    if (setting('pfight_jigsaw') !== '0' && is_file($base . 'parts47/atlas.json')) return $u = url('assets/img/pfight/parts47/');
    return $u = is_file($base . 'parts/atlas.json') ? url('assets/img/pfight/parts/') : null;
}
