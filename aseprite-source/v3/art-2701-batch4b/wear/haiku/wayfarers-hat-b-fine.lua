-- wayfarers-hat-b-fine: Fine rank of the Wayfarer's Hat cut-b (crown patch kept). Haiku, batch4b. 64x64.
-- Base: art-2701-rest/opus3/wayfarers-hat-b.png (read only).
-- Fine = gold dashed embroidery along the brim's lower edge, a cream gleam on the crown.
-- quirk kept: blue feather and red band. Patch untouched.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../art-2701-rest/opus3/wayfarers-hat-b.png")
local G = H.GOLD

H.dashRow(img, 10, 50, 46, G.base, 2, 1)
H.put(img, 34, 23, "#fff4dc"); H.put(img, 35, 23, "#fff4dc")

H.save(img, "wayfarers-hat-b-fine")
