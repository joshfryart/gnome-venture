-- trail-pack-b-fine: Fine rank of the Trail Pack cut b (sewn denim patch with the trail-blaze arrow). Opus second pass,
-- batch4b. 64x64.
-- Start: the finished cut-a Fine (art-2701-batch3/wear/opus3/trail-pack-fine.png: navy waxed-canvas flap with gold
-- fern and fiddlehead embroidery, gold buckle, rim and bounce) with the cut-b patch grafted in from
-- art-2701-next8/opus3/trail-pack-b.png.
-- Fix: the cut-a pocket-watch quirk hung exactly where the patch is sewn, so only stray chain links showed past the
-- patch's edge. The old links are unpicked (plain canvas from the cut-b base) and the watch is re-hung 3 px right,
-- on the side pocket, its chain running from the flap's corner past the patch's top-right stitches.
-- quirk kept: lavender sprig on the roll, the cream trail-blaze arrow and its loose thread on the patch.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o4.lua")
local G = O.GOLD6
local CB = O.V3 .. "/art-2701-next8/opus3/trail-pack-b.png"
local img, M = O.graft(O.OP3 .. "trail-pack-fine.png", CB, O.PH .. "trail-pack.png")
local B = O.load(CB)
-- 1. unpick the old watch and chain (x 44-53, y 38-48)
local GOLDS = { [G.hi] = 1, [G.base] = 1, [G.shade] = 1, [G.deep] = 1, ["#fff4d6"] = 1, ["#a0601e"] = 1, ["#ffd25a"] = 1 }
for y = 38, 48 do for x = 44, 53 do
  if not O.inMask(M, x, y) and GOLDS[O.get(img, x, y) or ""] then img:putPixel(x, y, B:getPixel(x, y)) end
end end
-- 2. re-hang the watch on the side pocket (skip any patch pixel)
local function put(x, y, hex) if not O.inMask(M, x, y) and O.isBody(img, x, y) then O.px(img, x, y, hex) end end
local chain = { { 46, 39, G.base }, { 47, 40, G.shade }, { 48, 41, G.base }, { 49, 42, G.shade }, { 50, 43, G.base } }
for _, c in ipairs(chain) do put(c[1], c[2], c[3]) end
O.paint(img, 49, 44, {
  "sbs.",
  "bWhd",
  "sdd.",
}, { b = G.base, s = G.shade, d = G.deep, h = G.hi, W = "#fff4d6" })
O.save4(img, "trail-pack-b-fine")
