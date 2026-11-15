-- trail-pack (Common, cut a): Haiku first pass, batch4. 64x64.
-- Base: game ph/trail-pack.png (read only). No rank overlay: a Common carries no lining or trim.
-- Wear cue: a rubbed patch on the front flap and a worn corner. Opus redraws.
-- quirk kept from base: lavender sprig on the blanket roll.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../../../game/assets/img/ph/trail-pack.png")

-- rubbed patch on the flap
H.put(img, 19, 31, "#6c5c4a")
H.put(img, 20, 31, "#6c5c4a")
H.put(img, 21, 32, "#6c5c4a")
-- worn lower corner
H.put(img, 40, 44, "#6c5c4a")
H.put(img, 41, 45, "#6c5c4a")

H.save(img, "trail-pack")
