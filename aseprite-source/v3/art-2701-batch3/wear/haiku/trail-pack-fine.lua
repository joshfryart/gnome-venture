-- trail-pack-fine: Fine rank of the Trail Pack (Haiku pass, batch3). 64x64.
-- Base: game ph/trail-pack.png. Fine = gold stitching along the pack mouth and the flap's
-- lower edge, the brass buckle lit gold on top, and a cream gleam on the flap.
-- quirk kept from base: lavender sprig on the roll.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local G = H.GOLD
local img = H.load(H.DIR .. "/../../../../../game/assets/img/ph/trail-pack.png")

-- gold stitch along the pack mouth
H.dashRow(img, 17, 46, 25, G.base, 2, 1)
-- gold trim on the flap lower edge
H.hline(img, 17, 46, 38, G.base)
H.hline(img, 17, 46, 39, G.shade)

-- buckle lit gold on top
H.hline(img, 28, 34, 41, G.hi)

-- cream gleam on the flap
H.put(img, 19, 27, H.CREAM)
H.put(img, 20, 27, H.CREAM)

H.save(img, "trail-pack-fine")
