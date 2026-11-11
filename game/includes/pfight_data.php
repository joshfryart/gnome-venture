<?php
declare(strict_types=1);
/** Puzzle Combat runtime data (separate from creatures.txt on purpose: the importer skips slugs that already exist). */

/** Gentle species: Charm fills their resolve bar at x1 and Hurt at x0.5. Everything else is hostile (Hurt x1, Charm x0.5). */
const PF_GENTLE = ['garden-snail', 'dusk-moth', 'cave-glowworm', 'dung-beetle', 'leopard-slug', 'aphid-swarm', 'grumpy-lemming', 'sun-lizard', 'bullfrog', 'shore-crab',
    'tunnel-mole', 'frost-hare', 'will-o-wisp', 'grass-snake', 'grey-heron', 'tawny-owl', 'mire-toad', 'sea-otter-bandit', 'hermit-crab-hoarder', 'reef-turtle',
    'ptarmigan-flock', 'beaver-foreman', 'giant-anteater', 'giant-bumblebee', 'desert-tortoise', 'pelican-parliament', 'lichen-reindeer', 'desert-camel', 'prairie-bison', 'cliff-ram'];

/** 1-2 signature tiles per species: slug => [['n'=>,'t'=>,'v'=>,'r'=>], ...]. Authored over time; archetype decks carry the rest. */
const PF_SIGNATURE = [
    'garden-snail' => [['n' => 'Slime Trail', 't' => 'guard', 'v' => 3, 'r' => 'body']],
    'paper-wasp' => [['n' => 'Sting', 't' => 'hurt', 'v' => 4, 'r' => 'craft']],
    'tunnel-mole' => [['n' => 'Burrow', 't' => 'guard', 'v' => 3, 'r' => 'mind']],
    'red-fox' => [['n' => 'Sly Pounce', 't' => 'trick', 'v' => 3, 'r' => 'body']],
    'bramble-wolf' => [['n' => 'Howl', 't' => 'trick', 'v' => 4, 'r' => 'body']],
];
