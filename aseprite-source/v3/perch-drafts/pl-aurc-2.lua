-- pl-aurc-2-perch.lua : 36x36 perch for the moss-pot pal (spec.md)
local D = "C:/Users/hello/AppData/Local/Temp/ollama-art/pl-aurc-2-perch-20261120-163648/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 36, h = 36, mode = "sticker" }

-- ramps (from the pal's palette)
local moss  = GV.ramp("#437e4e")                       -- body: base green, dark green shade
local gold  = GV.ramp("#ea9e3f")                       -- fronds / bolt
local stone = GV.ramp("#6e5e8e")                       -- perch slab / shadow accent
local INK   = "#2b1c26"                                -- dark ink

-- ===== ph2 BLOCK-IN: flat silhouettes only =====
-- ground shadow (soft ellipse under the perch)
c:ground(17.5, 30.5, 10, 1.5, "#4b3b69")
local p = c:build{
  { "perch", c:rrect(7, 25, 26, 30, 3), stone, { cres = 3, deep = 2, gloss = false } },
  -- body/head: one chibi blob sitting on the perch
  { "body", c:ellipse(17.5, 17, 9.5, 10), moss, { cres = 3, deep = 2, gloss = { 13, 11 } } },
  -- three gold fronds on the crown (2px stalks + club tips)
  { "fronds", c:mask()
      :rrect(9, 5, 12, 7, 1):line({ {11, 8}, {11, 8} }, 2)
      :rrect(15, 4, 19, 7, 1):line({ {16, 8}, {18, 8} }, 2)
      :rrect(22, 4, 25, 7, 1):line({ {23, 8}, {23, 8} }, 2), gold, { flat = true, contour = false, contact = false, rim = false } },
  -- gold bolt accent, tucked against the body's right shoulder
  { "bolt", c:line({ {28, 12}, {28, 12} }, 3), gold, { flat = true, contour = false, contact = false } },
}

-- ===== ph5 TEXTURE: hand-placed, subtle, following the form =====
local mossR, stoneR, goldR = GV.ramp("#437e4e"), GV.ramp("#6e5e8e"), GV.ramp("#ea9e3f")
-- moss speckles (tone-on-tone, 1 shade step)
for _, q in ipairs({ { 11, 13 }, { 14, 10 }, { 19, 12 }, { 12, 17 }, { 16, 21 } }) do
  c:px(q[1], q[2], mossR.gloss)
end
-- 1px dither just inside the terminator
for _, q in ipairs({ { 24, 15 }, { 23, 20 }, { 21, 23 }, { 25, 18 } }) do
  c:px(q[1], q[2], mossR.shade)
end
-- perch top face lit + tiny joints on the stone front
-- perch top face lit (clipped to the perch and cut from the body, never over the body)
c:fill(c:rect(10, 25, 23, 25):clip(p.perch.m):cut(p.body.m), stoneR.rim)
c:px(12, 25, stoneR.gloss)
c:px(13, 28, stoneR.shade); c:px(14, 28, stoneR.shade)
c:px(18, 27, stoneR.shade); c:px(19, 27, stoneR.shade)
-- dark club tips (the pal's frond-end nubs), one tone step down
c:px(11, 5, "#da892d"); c:px(17, 4, "#da892d"); c:px(24, 5, "#da892d")
-- bolt centre hole
c:px(28, 12, INK)

-- ===== ph6 DETAIL: face, gloss, accents =====
-- big round dark eyes with a cream glint (as on the 64px pal)
for _, e in ipairs({ { 12, 14 }, { 20, 14 } }) do
  c:fill(c:rect(e[1], e[2], e[1] + 2, e[2] + 2), INK)
  c:px(e[1], e[2], "#f8dc9a")
end
-- tiny smile
c:px(17, 19, INK); c:px(18, 19, INK)

local t = c:save(D .. "out/pl-aurc-2-perch.aseprite", D .. "out/pl-aurc-2-perch.png")
print(GV.report(t))
assert(t.semi == 0 and t.margin >= 1)
