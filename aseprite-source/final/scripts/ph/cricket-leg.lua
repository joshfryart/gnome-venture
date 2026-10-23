-- ph/cricket-leg : one big folded hind leg of the Drumming Cricket (fat chevron femur, spiny shin, clay crust)
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- same browns as creature-drumming-cricket
local brown = GV.ramp("#8c4a1a")
local legR  = GV.ramp("#44281c")
local clay  = GV.ramp("#c9a96e")   -- soil family: the clay crust

-- femur: a fat drumstick from the hip (lower left) up to the knee (upper right)
local femur = c:mask()
local x0, y0, r0, x1, y1, r1 = 17, 45, 8.5, 40, 15, 3.5
for i = 0, 20 do
  local t = i / 20
  local r = r0 + (r1 - r0) * t ^ 0.8
  femur:add(c:ellipse(x0 + (x1 - x0) * t, y0 + (y1 - y0) * t, r, r))
end
femur = femur:closed(2)
-- shin: thin and straight, back down from the knee, then a short foot with two claws
local shin = c:line({ {42, 14}, {46, 30}, {48, 44} }, 3)
local foot = c:line({ {48, 44}, {50, 48}, {53, 50} }, 2)
foot:add(c:line({ {52, 50}, {54, 53} }, 2))
-- spines along the back of the shin
local spines = c:mask()
for _, s in ipairs({ { 45, 20 }, { 46, 26 }, { 47, 32 }, { 47, 38 } }) do
  spines:add(c:line({ { s[1] + 1, s[2] }, { s[1] + 4, s[2] + 2 } }, 2))
end
-- hip cuff where the leg came off, a felt join
local cuff = c:ellipse(14, 49, 7, 6)

local p = c:build{
  { "spines", spines, legR, { flat = true } },
  { "foot",   foot, legR, { flat = true } },
  { "shin",   shin, legR, { flat = true } },
  { "femur",  femur, brown, { gloss = { 18, 34 } } },
  { "knee",   c:ellipse(41, 14, 3.5, 3.5), legR, { gloss = false } },
  { "cuff",   cuff, clay, { gloss = false, stitch = false } },
}
-- chevron ridges down the femur (the herringbone of a cricket's jumping leg)
local rid = c:mask()
for i = 0, 3 do
  local cx, cy = 20 + i * 5, 39 - i * 6.5
  rid:add(c:line({ { cx - 4, cy - 2 }, { cx, cy + 2 }, { cx + 3, cy - 3 } }, 1))
end
c:fill(rid:clip(p.femur.m:shrink(2)), "#a5663a")
-- clay crust: two glazed bean chips on the femur
c:spot(c:ellipse(29, 34, 2.5, 1.5), "#9a6b3f", "#c9a96e")
c:spot(c:ellipse(22, 45, 2, 1.5), "#9a6b3f", "#c9a96e")
-- seam round the hip cuff, with a button pinning it
c:seam({ { 9, 43 }, { 15, 42 }, { 20, 46 }, { 21, 52 } })
c:button(11, 47)

local t = c:save(D .. "final/aseprite/ph/cricket-leg.aseprite", PNG .. "cricket-leg.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
