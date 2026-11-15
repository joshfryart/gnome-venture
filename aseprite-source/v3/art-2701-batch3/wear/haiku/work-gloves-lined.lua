-- work-gloves-lined: Lined rank of the Work Gloves (Haiku pass, batch3). 64x64.
-- Base: game ph/work-gloves.png (cut a silhouette). Lined = a fleece lining rolls out of
-- each cuff mouth, cream and curly, above the stitch line.
-- quirk kept from base: the cream stitch row on the cuffs.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../../../game/assets/img/ph/work-gloves.png")

-- left glove cuff: fleece on the two rows above the stitch line
H.fleece(img, 17, 32, 44)
H.fleece(img, 17, 32, 45)
-- right glove cuff: fleece at the top of its cuff
H.fleece(img, 34, 46, 40)
H.fleece(img, 34, 46, 41)

H.save(img, "work-gloves-lined")
