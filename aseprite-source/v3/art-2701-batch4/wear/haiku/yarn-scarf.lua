-- yarn-scarf (Common, cut a): Haiku first pass, batch4. 64x64.
-- Base: game ph/yarn-scarf.png (read only). No rank overlay: a Common carries no lining or trim.
-- Wear cue: a few pale sheen pixels on the teal stripes, so the yarn reads as soft. Opus redraws.
-- quirk kept from base: the two loose tails with fringe.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../../../game/assets/img/ph/yarn-scarf.png")

-- yarn sheen on the teal stripes
H.put(img, 18, 36, "#a2dcc0")
H.put(img, 20, 36, "#a2dcc0")
H.put(img, 17, 45, "#a2dcc0")
H.put(img, 31, 17, "#a2dcc0")

H.save(img, "yarn-scarf")
