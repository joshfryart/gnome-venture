-- work-gloves (Common, cut a): Haiku first pass, batch4. 64x64.
-- Base: game ph/work-gloves.png (read only). No rank overlay: a Common carries no lining or trim.
-- Wear cue: darker knuckle creases on the back of each glove. Opus redraws.
-- quirk kept from base: cream stitch row on the cuffs.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../../../game/assets/img/ph/work-gloves.png")

-- knuckle creases: left glove, right glove
H.put(img, 28, 30, "#80492c")
H.put(img, 28, 31, "#80492c")
H.put(img, 24, 40, "#80492c")
H.put(img, 33, 43, "#80492c")

H.save(img, "work-gloves")
