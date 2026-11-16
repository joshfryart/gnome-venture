-- work-gloves-fine: Fine rank of the Work Gloves (Haiku pass, batch3). 64x64.
-- Base: game ph/work-gloves.png. Fine = the cuff stitches run in gold instead of cream,
-- a gold trim along each cuff's lower edge, and a cream gleam on the left index finger.
-- quirk kept from base: the stitch row on the cuffs.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local G = H.GOLD
local img = H.load(H.DIR .. "/../../../../../game/assets/img/ph/work-gloves.png")

-- gold stitch on each cuff, 2 on 1 off
H.dashRow(img, 17, 32, 47, G.hi, 2, 1)
H.dashRow(img, 35, 45, 44, G.hi, 2, 1)

-- gold trim on the lower edge of each cuff
H.hline(img, 17, 32, 53, G.base)
H.hline(img, 35, 45, 51, G.base)

-- cream gleam on the left index finger
H.put(img, 20, 14, H.CREAM)
H.put(img, 21, 14, H.CREAM)

H.save(img, "work-gloves-fine")
