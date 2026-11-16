-- wayfarers-hat-fine: Fine rank of the Wayfarer's Hat (cut a), Haiku first pass, batch4. 64x64.
-- Base: game ph/wayfarers-hat.png (plain cut a).
-- Fine = gold dashed embroidery along the brim's lower edge, and a cream gleam on the crown.
-- quirk kept from base: blue feather and the red band.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../../../game/assets/img/ph/wayfarers-hat.png")

-- gold embroidery along the brim's lower edge
H.dashRow(img, 12, 44, 49, H.GOLD.base, 2, 1)
-- cream gleam on the crown
H.put(img, 23, 21, "#fff4d6")
H.put(img, 24, 21, "#fff4d6")

H.save(img, "wayfarers-hat-fine")
