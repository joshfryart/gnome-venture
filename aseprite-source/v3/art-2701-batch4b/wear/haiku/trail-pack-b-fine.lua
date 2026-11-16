-- trail-pack-b-fine: Fine rank of the Trail Pack cut-b (blue patch and buckle kept). Haiku, batch4b. 64x64.
-- Base: art-2701-next8/opus3/trail-pack-b.png (read only).
-- Fine = gold stitch along the pack mouth, gold rivets on the two top corners, a cream gleam on the left body.
-- quirk kept: lavender sprig on top of the roll. Patch and buckle untouched.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../art-2701-next8/opus3/trail-pack-b.png")
local G = H.GOLD

H.dashRow(img, 17, 47, 24, G.base, 2, 1)
H.put(img, 18, 25, G.hi); H.put(img, 46, 25, G.hi)
H.put(img, 19, 27, "#fff4d6"); H.put(img, 20, 27, "#fff4d6")

H.save(img, "trail-pack-b-fine")
