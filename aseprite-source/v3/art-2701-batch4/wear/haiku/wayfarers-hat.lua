-- wayfarers-hat (Common, cut a): Haiku first pass, batch4. 64x64.
-- Base: game ph/wayfarers-hat.png (read only). No rank overlay: a Common carries no lining or trim.
-- Wear cue: two pinch-crease marks on the crown, so the felt reads as worn. Opus redraws.
-- quirk kept from base: blue feather and the red band.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../../../game/assets/img/ph/wayfarers-hat.png")

-- pinch creases on the crown
H.put(img, 26, 25, "#704033")
H.put(img, 27, 26, "#704033")

H.save(img, "wayfarers-hat")
