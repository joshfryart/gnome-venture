-- per slug: look = posture, beak and marking overrides, quirk = its one odd tell (keys: see the header of types/bird.lua)
return {
  ["carrion-crow"]      = { look = { beak = "crow", beakcol = "ink", leg = "slate", gloss = "#a9d6ea" }, quirk = "button" },
  ["herring-gull"]      = { look = { beak = "gull", wingtip = true, eyering = "gold", prim = 4 }, quirk = "chip" },
  ["grey-heron"]        = { look = { cap = true, plumes = true }, quirk = "fish" },
  ["tawny-owl"]         = { quirk = "monocle" },
  ["great-hawk"]        = { quirk = "kink" },
  ["snow-owl-monarch"]  = { quirk = "crown" },
  ["storm-eagle"]       = { look = { headcol = "white", cap = false }, quirk = "scarf" },
  ["fern-cassowary"]    = { look = { beak = "casque", tail = "plume", neckcol = "ocean", headcol = "ocean", wattle = true, leg = "slate", legw = 2.3, legt = 15, shaggy = 1.8, brx = 10.5, bry = 8, srx = 6.6 }, quirk = "ring" },
  ["ptarmigan-flock"]   = { look = { brx = 9, bry = 8.4, leg = "white", beakcol = "slate", feathered = true, legt = 5.5, comb = true, flecks = "stone", tail = "short" }, quirk = "snow" },
  ["pelican-parliament"] = { look = { beak = "pouch", nape = true }, quirk = "plaster" },
  ["griffon-vulture"]   = { look = { base = "raptor", bald = true, cap = false, headcol = "blush", hy = 31, hx = 8, wrinkle = true, prim = 5 }, quirk = "bone" },
  ["echo-bat"]          = { look = { base = "bat" }, quirk = "notch" },
}
