<?php
// v2.0.23: emoji => [slug, decorative(bool), accessible name (only used when decorative is false)].
// The slug is the file assets/img/ico/{slug}.svg. An emoji whose file does not exist yet stays an emoji, so rows can be added before the art.
// SAMPLE: replaced by the full map later. Write keys WITHOUT the variation selector (U+FE0F); it is matched as optional.
return [
    '🌱' => ['seedling', true],
    '⚡' => ['energy', false, 'Energy'],
    '✨' => ['sparkle', true],
    '🌿' => ['herb', true],
    '🏡' => ['garden-house', true],
    '🧺' => ['basket', true],
    '✔' => ['check', false, 'Done'],
    '🧭' => ['compass', true],
    '🍄' => ['mushroom', true],
    '💧' => ['droplet', true],
    '🪙' => ['petal-coin', false, 'Petals'],
    '🔒' => ['lock', false, 'Locked'],
];
