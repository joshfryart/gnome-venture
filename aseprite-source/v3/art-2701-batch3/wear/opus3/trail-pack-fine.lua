-- trail-pack-fine: Fine rank of the Trail Pack (Opus richness pass, opus3). 64x64.
-- Base: opus2/trail-pack-fine.png (read only): oat canvas pack with blanket roll, gold cord
-- at the mouth, gold braid on the flap hem, strap with buckle and aglet.
-- opus3 fixes the 16 px read (Lined and Fine were both a light band): the flap is now a
-- dyed navy waxed canvas (6-tone hue-shifted ramp that keeps the base weave), with a dark
-- hem edge and a contact shadow on the oat body, so Fine reads as "dark flap + gold" and
-- Lined as "white collar". The wheat-like ferns are unpicked and replaced by two fern
-- fronds in gold thread with curled fiddlehead tips. Also: rim light on the lit left side,
-- a cool bounce on the lower right.
-- quirk: base lavender sprig on the roll, plus a gold pocket-watch on its chain spilling
-- out of the right side pocket.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o3.lua")
local G = O.GOLD6
local img = O.base("trail-pack-fine")

-- 1. navy flap: canvas tones -> navy, x17..43, y24..41
local NAVY = { ["#e4d8b0"] = "#a8bfe6", ["#c9bb92"] = "#6f8ccc", ["#ad9e7a"] = "#4f68ac",
               ["#8e7e62"] = "#3e5294", ["#6c5c4a"] = "#323f78", ["#4a3c34"] = "#262c58" }
local GOLDS = { [G.hi] = 1, [G.base] = 1, [G.shade] = 1, [G.deep] = 1, ["#8f4a1f"] = 1 }
-- unpick the opus2 ferns first (back to canvas base), then dye
for _, b in ipairs({ { 20, 28 }, { 36, 28 } }) do
  for y = b[2], b[2] + 6 do for x = b[1], b[1] + 6 do
    if GOLDS[O.get(img, x, y) or ""] then O.px(img, x, y, "#ad9e7a") end
  end end
end
O.remap(img, 17, 24, 43, 41, NAVY)
-- flap edges: lit left edge, deep right edge and hem, contact shadow on the oat below
for y = 25, 41 do O.body(img, 17, y, "#6f8ccc"); O.body(img, 43, y, "#262c58") end
for x = 17, 43 do
  local h = O.get(img, x, 41)
  if h and not (x >= 29 and x <= 33) then O.px(img, x, 41, "#262c58") end
  local h2 = O.get(img, x, 42)
  if h2 and not (x >= 27 and x <= 35) then O.px(img, x, 42, "#6c5c4a") end
end

-- 2. gold-thread ferns: an open frond (alternate pinnae, longest low) left of the strap,
--    an unfurling fiddlehead (crozier spiral) right of it, in the shade
O.paint(img, 19, 26, {
  "...h...",
  "..hh...",
  "...hh..",
  ".hhh...",
  "...hhh.",
  "bbbb...",
  "...bbbb",
  ".bbb...",
  "...bbb.",
  "...s...",
  "...s...",
}, { h = G.hi, b = G.base, s = G.shade })
O.paint(img, 36, 27, {
  "..bbb..",
  ".b...s.",
  "b..b..s",
  "b.b.s.s",
  "b.b..s.",
  "b..ss..",
  ".b.....",
  ".b.....",
  "..d....",
}, { b = G.base, s = G.shade, d = G.deep })

-- 3. rim light on the lit left side panel, cool bounce along the lower right
O.rim(img, "left", "#e4d8b0", { ["#c9bb92"] = 1, ["#ad9e7a"] = 1 }, { 8, 24, 20, 58 })
O.rim(img, "bottom", "#56607a", { ["#4a3c34"] = 1, ["#6c5c4a"] = 1 }, { 30, 50, 56, 60 })

-- 4. quirk: pocket-watch on a gold chain out of the right side pocket
O.paint(img, 45, 39, {
  "b.....",
  ".s....",
  "..b...",
  "...s..",
  "..sbs.",
  "..bWbd",
  "..sdd.",
}, { b = G.base, s = G.shade, d = G.deep, W = "#fff4d6" })
O.reink(img)
O.save(img, "trail-pack-fine")
