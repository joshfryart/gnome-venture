-- work-gloves-fine: Fine rank of the Work Gloves (Opus second pass, batch3). 64x64.
-- Base: game ph/work-gloves.png (read only). Same tan leather pair, same silhouette.
-- Fine = gold piping at the top of each cuff, gold thread in the cuff stitch row, a gold
-- binding along each cuff mouth, a gold diamond embroidered on the back of the front
-- glove, and a gold snap on the front cuff with one cream glint.
-- quirk kept from base: the stitch row across each cuff (now in gold thread).
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o2.lua")
local G = O.GOLD
local img = O.load(O.PH .. "work-gloves.png")
local function swapRow(y, x0, x1, from, to)
  for x = x0, x1 do if O.get(img, x, y) == from then O.px(img, x, y, to(x)) end end
end
local function lit(split, a, b) return function(x) return x < split and a or b end end

-- back (right) glove cuff, x34..45
swapRow(41, 34, 45, "#4a2a22", lit(43, G.shade, G.deep))        -- piping
swapRow(44, 34, 45, "#f2e2b8", lit(43, G.base, G.shade))        -- stitch row
swapRow(50, 34, 45, "#6b3d2c", lit(43, G.base, G.shade))        -- binding
swapRow(51, 34, 45, "#4a2a22", function() return G.deep end)
-- front (left) glove cuff, x16..34
swapRow(44, 18, 32, "#4a2a22", lit(29, G.base, G.shade))        -- piping
swapRow(47, 18, 33, "#f2e2b8", lit(30, G.base, G.shade))           -- stitch row
swapRow(53, 16, 34, "#88523a", lit(30, G.base, G.shade))        -- binding
O.px(img, 17, 53, G.hi); O.px(img, 18, 53, G.hi)
swapRow(54, 16, 34, "#4a2a22", lit(30, G.shade, G.deep))
swapRow(54, 16, 34, "#6b3d2c", function() return G.shade end)
-- gold snap on the front cuff
O.paint(img, 28, 49, { "AB", "BC", "DD" }, { A = G.hi, B = G.base, C = G.shade, D = "#80492c" })
O.px(img, 28, 49, "#fff4d6")
-- embroidered diamond on the back of the front glove (centre 25,35)
O.paint(img, 22, 32, {
  "...A...",
  "..AhB..",
  ".AhBBC.",
  "AhBPBCD",
  ".BBBCD.",
  "..BCD..",
  "...D...",
}, { A = G.hi, h = G.pale, B = G.base, P = "#fff4d6", C = G.shade, D = G.deep })
O.save(img, "work-gloves-fine")
