-- flood-boots-fine: Fine rank of the Flood Boots (Haiku pass, batch3). 64x64.
-- Base: game ph/flood-boots.png. Fine = gold trim on both cuff tops and gold stitching
-- down the left shaft and along the sole seam; a cream gleam on the shaft.
-- quirk kept from base: blue water splash at the toe.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local G = H.GOLD
local img = H.load(H.DIR .. "/../../../../../game/assets/img/ph/flood-boots.png")

-- gold cuff tops, hi on the lit side
H.hline(img, 12, 28, 12, G.base)
H.hline(img, 12, 28, 13, G.hi)
H.hline(img, 22, 39, 8, G.base)
H.hline(img, 22, 39, 9, G.hi)

-- gold stitch dashes under each cuff, and down the shaft
H.dashRow(img, 13, 27, 19, G.shade, 2, 1)
H.dashRow(img, 30, 38, 13, G.shade, 2, 1)
H.dashCol(img, 22, 22, 46, G.base, 2, 1)

-- gold seam along the sole edge
H.dashRow(img, 14, 36, 50, G.base, 2, 1)

-- cream gleam on the left shaft
H.put(img, 14, 24, H.CREAM)
H.put(img, 15, 24, H.CREAM)

H.save(img, "flood-boots-fine")
