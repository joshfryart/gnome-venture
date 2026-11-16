-- work-gloves-fine: Fine rank of the Work Gloves (Opus richness pass, opus3). 64x64.
-- Base: opus2/work-gloves-fine.png (read only): tan leather pair with gold piping, gold
-- thread stitch row and gold binding on each cuff, a snap on the front cuff.
-- opus3 adds: the filled gold diamond (it read as a gem) is unpicked and replaced by an
-- oak leaf embroidered in gold thread as open line-work (outline + midrib, leather showing
-- between the stitches), a 3x3 domed snap with a dimple and glint (opus2: 2x3), leather
-- pores, a pale rim light on every lit left edge, a cool lilac bounce on the back glove.
-- quirk: the gold-thread stitch row (base), plus a gold ring worn over the glove's thumb.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o3.lua")
local G = O.GOLD6
local img = O.base("work-gloves-fine")
-- 1. unpick the diamond: restore the base leather under it
local base = O.load(O.PH .. "work-gloves.png")
for y = 31, 39 do for x = 21, 29 do
  local h = O.get(base, x, y)
  if h then O.px(img, x, y, h) end
end end
O.gloveLeather(img)
-- 2. embroidered oak leaf in gold thread: raised stitches (each casts a 1 px leather
--    shadow lower right), lobed outline lit left / shaded right, midrib and a short stem
local LEAF = {
  "....a....",
  "...a.b...",
  "..aa.bb..",
  ".a..h..b.",
  "..a.h.b..",
  ".a.vhv.b.",
  "..a.h.b..",
  ".a..h..b.",
  "..a.h.b..",
  "...ahb...",
  "....s....",
}
local function at(i, j) local r = LEAF[j]; return r and i >= 1 and i <= #r and r:sub(i, i) ~= "." end
for j = 1, #LEAF do for i = 1, #LEAF[j] do
  if at(i, j) and not at(i + 1, j + 1) then O.body(img, 21 + i, 28 + j, "#80492c") end
end end
O.paint(img, 21, 28, LEAF, { a = G.base, b = G.shade, h = G.hi, v = G.base, s = G.deep })
O.px(img, 25, 28, G.pale)

-- 3. domed snap on the front cuff
O.paint(img, 27, 48, { "hbs", "bus", "sdd" }, { h = G.hi, b = G.base, s = G.shade, d = G.deep, u = G.umber })
O.px(img, 27, 48, "#fff4d6")
-- 4. quirk: a gold ring over the thumb
O.paint(img, 10, 22, { "eeeee", "phbsd", "bssdu", "eeeee" }, { p = G.pale, h = G.hi, b = G.base, s = G.shade, d = G.deep, u = G.umber, e = "#80492c" })
O.reink(img)
O.save(img, "work-gloves-fine")
