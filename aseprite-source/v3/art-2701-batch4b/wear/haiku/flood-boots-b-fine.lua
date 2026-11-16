-- flood-boots-b-fine: Fine rank of the Flood Boots cut-b (sewn gingham patch kept). Haiku, batch4b. 64x64.
-- Base: art-2701-opus/wear/flood-boots-b.png (read only).
-- Fine = gold stitch trim on both cuffs, a leather strap with a gold buckle, a gleam on the back shaft.
-- quirk kept: splash at the toe. Patch and dog-ear untouched.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_hb.lua")
local img = H.load(H.DIR .. "/../../../art-2701-opus/wear/flood-boots-b.png")
local G = H.GOLD

-- gold 2-on-1-off stitch along the lower edge of each cuff
H.dashRow(img, 12, 28, 19, G.base, 2, 1)
H.dashRow(img, 23, 39, 14, G.base, 2, 1)
-- leather strap across the front shaft (above the patch) with a gold buckle
H.hline(img, 14, 27, 25, "#6a4537")
H.hline(img, 14, 27, 26, "#8a5a36")
H.hline(img, 19, 22, 24, G.base)
H.hline(img, 19, 22, 27, G.shade)
H.vline(img, 19, 25, 26, G.base)
H.vline(img, 22, 25, 26, G.base)
H.put(img, 19, 24, G.hi)
H.put(img, 20, 25, "#3a2629"); H.put(img, 21, 26, "#3a2629")
-- gleam on the back shaft
H.put(img, 33, 20, "#fff4d6"); H.put(img, 34, 20, "#fff4d6")

H.save(img, "flood-boots-b-fine")
