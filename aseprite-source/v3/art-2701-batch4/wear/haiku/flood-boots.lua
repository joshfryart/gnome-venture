-- flood-boots (Common, cut a): Haiku first pass, batch4. 64x64.
-- Base: game ph/flood-boots.png (read only). No rank overlay: a Common carries no lining or trim.
-- Wear cue: two scuffs on the shafts in the deep green, so the boots read as used. Opus redraws.
-- quirk kept from base: blue water splash at the toe.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../../../game/assets/img/ph/flood-boots.png")

-- scuffs: left shaft, right shaft
H.put(img, 17, 35, "#22503f")
H.put(img, 18, 36, "#22503f")
H.put(img, 17, 40, "#22503f")
H.put(img, 30, 30, "#2e6b45")
H.put(img, 31, 31, "#2e6b45")

H.save(img, "flood-boots")
