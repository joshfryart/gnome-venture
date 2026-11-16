-- flood-boots-fine: Fine rank of the Flood Boots (Opus second pass, batch3). 64x64.
-- Base: game ph/flood-boots.png (read only). Same green wellies, same splash quirk.
-- Fine = the cuffs are polished chestnut leather with gold piping (top edge and the fold),
-- a chestnut ankle strap with a cast gold buckle across both boots, and a brighter
-- specular streak on the glossy front shaft with one cream glint on the buckle.
-- quirk kept from base: blue water splash at the toe.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o2.lua")
local G = O.GOLD
local img = O.load(O.PH .. "flood-boots.png")

-- 1. cuffs: tan -> polished chestnut (both boots, cuff rows only)
local CH = { ["#f6dca6"] = "#dc9c68", ["#e6bd7e"] = "#c47e4c", ["#cf9b5c"] = "#a5603a",
             ["#b07a46"] = "#86472f", ["#8a5a36"] = "#683424", ["#5a3a2a"] = "#4a2420" }
O.remap(img, 21, 7, 41, 15, CH)   -- back cuff
O.remap(img, 10, 12, 30, 20, CH)  -- front cuff
-- 2. gold piping: top edge row and the fold line of each cuff
O.hrun(img, 23, 37, 8, G.hi); O.hrun(img, 38, 40, 8, G.base)
O.hrun(img, 30, 37, 11, G.base); O.hrun(img, 38, 40, 11, G.shade)
O.hrun(img, 12, 24, 13, G.hi); O.hrun(img, 25, 28, 13, G.base)
O.hrun(img, 11, 23, 16, G.base); O.hrun(img, 24, 29, 16, G.shade)
O.px(img, 11, 16, G.hi); O.px(img, 12, 16, G.hi)

-- 3. ankle strap across both shafts (chestnut, lit top row, dark under-row)
local S = { hi = "#c47e4c", base = "#a5603a", shade = "#683424" }
O.hrun(img, 13, 28, 31, S.hi); O.hrun(img, 13, 28, 32, S.base); O.hrun(img, 13, 28, 33, S.shade)
O.hrun(img, 29, 39, 31, "#86472f"); O.hrun(img, 29, 39, 32, "#683424"); O.hrun(img, 29, 39, 33, "#4a2420")
O.hrun(img, 13, 28, 34, "#2e6b45")                  -- contact shadow on the rubber
-- cast gold buckle on the front strap
O.paint(img, 18, 30, {
  "#####.",
  "#ABBC#",
  "#B##D#",
  "#ABBD#",
  "#CDDD#",
  "######",
}, { A = G.hi, B = G.base, C = G.shade, D = G.deep })
O.px(img, 20, 32, "#683424"); O.px(img, 21, 32, "#c47e4c")     -- strap through the frame
-- 4. gleam: brighter specular streak on the front shaft, one glint on the buckle
for y = 22, 29 do O.body(img, 15, y, "#c4e07a") end
for y = 35, 38 do O.body(img, 15, y, "#c4e07a") end
O.px(img, 15, 23, "#fff4d6"); O.px(img, 15, 24, "#fff4d6")
O.px(img, 19, 31, "#fff4d6")
O.reink(img)
O.save(img, "flood-boots-fine")
