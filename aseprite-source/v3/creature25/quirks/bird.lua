-- per slug: look = posture, beak and marking overrides, quirk = its one odd tell (keys: see the header of types/bird.lua)
return {
  ["carrion-crow"]      = { look = { beakcol = "ink", leg = "slate" }, quirk = "button" },
  ["herring-gull"]      = { look = { beak = "gull" }, quirk = "chip" },
  ["grey-heron"]        = { look = { cap = true }, quirk = "fish" },
  ["tawny-owl"]         = { quirk = "monocle" },
  ["great-hawk"]        = { quirk = "kink" },
  ["snow-owl-monarch"]  = { quirk = "crown" },
  ["storm-eagle"]       = { look = { headcol = "white", cap = false }, quirk = "scarf" },
  ["fern-cassowary"]    = { look = { beak = "casque", tail = "plume", neckcol = "ocean", headcol = "ocean", wattle = true, leg = "slate" }, quirk = "ring" },
  ["ptarmigan-flock"]   = { look = { brx = 9, bry = 8.4, leg = "white", beakcol = "slate" }, quirk = "snow" },
  ["pelican-parliament"] = { look = { beak = "pouch" }, quirk = "plaster" },
  ["griffon-vulture"]   = { look = { base = "raptor", bald = true, cap = false, headcol = "blush", hy = 31, hx = 8 }, quirk = "bone" },
  ["echo-bat"]          = { look = { base = "bat" }, quirk = "notch" },
}
