-- travel-cloak-b-fine: Fine rank of the Travel Cloak cut-b (shoulder patch and bee kept). Haiku, batch4b. 64x64.
-- Base: art-2701-next8/opus3/travel-cloak-b.png (read only).
-- Fine = gold stitch along the collar, the tan front cord turned to gold, a cream gleam on the cord.
-- quirk kept: the orange leaf on the hem. Patch and bee untouched.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../art-2701-next8/opus3/travel-cloak-b.png")
local G = H.GOLD

H.dashRow(img, 17, 47, 15, G.base, 2, 1)
H.swap(img, 14, 16, 42, 42, { ["#e6bd7e"] = G.base, ["#cdb07e"] = G.shade, ["#efdcb4"] = G.hi, ["#f2e2c0"] = G.hi })
H.put(img, 22, 22, "#fff4d6")

H.save(img, "travel-cloak-b-fine")
