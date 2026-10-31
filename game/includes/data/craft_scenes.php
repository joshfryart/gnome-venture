<?php
// Hotspot boxes come from aseprite-source/craftmap/scenes/*.json (% of the picture). The last field is what an object opens:
// a list of recipe-slug globs (v2.3.7, fnmatch; the link is ?o=<id> and the list shows only the matching recipes, known or not),
// or a plain query string (Potions, left to the potions work). tests/craft_tags.php checks every recipe of a tagged area lands on an object.
return [
  'cooking' => ['alt' => "Kitchen scene", 'hot' => [
    ["oven", "Bread oven", 1.33, 5.00, 30.00, 45.00, ["*bread*", "*-buns", "*-toast", "feast-*-pie", "feast-*-bake", "feast-*-roast", "roasted-roots", "*-quiche", "stuffed-peppers-*", "bean-tamales"]],
    ["produce", "Produce barrel", 4.00, 50.50, 24.00, 45.50, ["*salad*", "*-fruit-bowl", "*-sorbet", "sunflower-snack", "ramson-pesto", "pickled-radishes", "fiery-pickled-cabbage", "devilled-eggs"]],
    ["stove", "Stove", 33.33, 15.00, 32.67, 74.00, ["*soup*", "*stew*", "*broth", "*-dal", "*curry", "khichdi", "*kasha", "*porridge", "*risotto", "*rice*", "colcannon", "palusami", "sukuma-wiki", "*-tea", "hot-cocoa", "*-cordial", "feast-*-pot", "feast-*-pilaf", "feast-*-mole", "feast-*-thali", "feast-*-supper"]],
    ["rack", "Pan rack", 68.00, 5.00, 30.67, 26.00, ["*fry*", "*fritters", "falafel", "scrambled-eggs", "*tortilla", "*frittata", "shakshuka", "grilled-*", "smoked-*", "scotch-*", "golden-carp-feast", "pancakes"]],
    ["table", "Worktable", 67.33, 36.00, 32.00, 53.00, ["*-cake", "*-tart", "*crumble*", "feast-*-table", "wild-berry-jam"]],
  ]],
  'pantry' => ['alt' => "Pantry scene", 'hot' => [
    ["jams", "Jam cupboard", 0.67, 6.00, 41.33, 78.00, ["*-jam", "*-marmalade", "*-curd", "*-butter", "quince-paste", "cranberry-sauce", "dried-*", "raisins", "prunes", "banana-chips", "candied-*", "marzipan", "halva", "hazelnut-spread"]],
    ["cheese", "Hanging cheese", 42.00, 7.00, 19.33, 36.00, ["*cheese*", "yogurt", "salted-eggs", "sourdough-starter", "chai-blend", "curry-paste", "dukkah", "garam-masala", "smoked-paprika", "chili-flakes"]],
    ["cordials", "Cordial bottles", 64.00, 10.00, 35.33, 41.00, ["*-cordial", "*-syrup", "*-juice", "*-drink", "*-concentrate", "*-cider", "ginger-beer", "kombucha", "kvass", "chicha", "tepache", "cold-brew-coffee", "vanilla-extract", "pomegranate-molasses", "*hot-sauce", "soy-sauce"]],
    ["crock", "Pickle crock", 42.00, 45.00, 22.00, 51.00, ["pickled-*", "*-pickles", "*-chutney", "*-relish", "piccalilli", "preserved-lemons", "cured-olives", "olive-tapenade", "salsa-verde", "*-pesto", "harissa", "tomato-passata", "sun-dried-tomatoes", "hummus-jar", "tahini"]],
    ["kraut", "Sauerkraut tub", 65.33, 51.00, 34.67, 48.00, ["sauerkraut", "*kimchi", "fermented-carrots", "miso", "doenjang", "gochujang", "natto", "tempeh", "poi"]],
  ]],
  'tools' => ['alt' => "Tool shed scene", 'hot' => [
    ["rack", "Tool rack", 0.67, 3.00, 29.33, 37.00, ["*staff", "fine-mesh-net", "gathering-basket", "copper-watering-can", "masterwork-rain-wand"]],
    ["bench", "Workbench", 0.67, 40.00, 29.33, 54.00, ["garden-hoe", "soil-probe", "masterwork-gnome-seeder", "masterwork-barrow", "masterwork-harvest-cart"]],
    ["anvil", "Anvil", 30.00, 11.00, 41.33, 83.00, ["masterwork-*"]],
    ["toolbox", "Toolbox", 71.33, 6.00, 28.00, 38.00, ["*lantern", "soil-probe", "masterwork-secateurs"]],
    ["grindstone", "Grindstone", 71.33, 44.00, 28.00, 50.00, ["*pick", "garden-hoe", "masterwork-*-hoe", "masterwork-secateurs"]],
  ]],
  'garden' => ['alt' => "Garden shed scene", 'hot' => [
    ["can", "Watering can and trowels", 1.33, 7.00, 32.00, 41.00, ["*-tea", "kelp-meal"]],
    ["sacks", "Sacks of loam", 2.00, 52.00, 30.67, 44.00, ["*-loam", "rock-dust*", "shell-meal-*"]],
    ["compost", "Compost bin", 34.00, 14.00, 32.00, 76.00, ["*compost", "worm-bedding", "worm-bin", "*leaf-mould"]],
    ["seeds", "Seed trays", 67.33, 7.00, 32.00, 41.00, ["worm-bedding", "*leaf-mould", "kelp-meal", "wood-ash", "*-tea"]],
    ["barrow", "Mulch barrow", 67.33, 50.00, 32.00, 46.00, ["*-chips*", "*-straw", "wood-ash", "*leaf-mould"]],
  ]],
  'potions' => ['alt' => "Alchemy station scene", 'hot' => [
    ["flasks", "Potion shelf", 1.33, 4.00, 32.00, 38.00, "q=draught"],
    ["mortar", "Mortar and pestle", 2.67, 42.00, 28.00, 52.00, "q=tonic"],
    ["cauldron", "Cauldron", 34.00, 16.00, 33.33, 79.00, "q=healing"],
    ["book", "Spellbook", 70.00, 6.00, 28.67, 34.00, "q=elixir"],
    ["still", "Copper still", 68.67, 42.00, 30.67, 52.00, "q=brew"],
  ]],
  'building' => ['alt' => "Builders\u2019 yard scene", 'hot' => [
    ["pulley", "Crane pulley", 4.67, 3.00, 26.00, 43.00, ["rope*", "building-stone*"]],
    ["sawhorse", "Sawhorse", 0.67, 46.00, 30.67, 49.00, ["timber-plank-*"]],
    ["stones", "Stone blocks", 31.33, 18.00, 37.33, 76.00, ["building-stone*"]],
    ["rope", "Rope coil", 71.33, 4.00, 27.33, 50.50, ["rope*"]],
    ["timber", "Timber stack", 68.67, 55.00, 30.67, 40.00, ["timber-plank*"]],
  ]],
  'decor' => ['alt' => "Yard corner scene", 'hot' => [
    ["lantern", "Lantern post", 6.67, 0.00, 24.00, 64.00, ["*lantern", "firefly-jar", "beeswax-candles"]],
    ["planter", "Flower planter", 0.67, 65.00, 30.00, 34.00, ["glazed-garden-pot", "rock-garden", "toadstool-ring", "fairy-house"]],
    ["birdbath", "Birdbath", 30.67, 16.00, 38.67, 78.00, ["bird-box", "*wind-chime", "fairy-house", "toadstool-ring"]],
    ["fence", "Picket fence", 69.33, 32.00, 30.00, 35.00, ["*-fence", "stone-wall", "silk-*", "log-*"]],
    ["path", "Stepping stones", 71.33, 67.00, 28.67, 33.00, ["stepping-stones", "rock-garden", "stone-wall", "log-seat"]],
  ]],
];
