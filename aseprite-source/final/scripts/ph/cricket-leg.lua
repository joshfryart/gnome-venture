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
-- shin: straight, back down from the knee, then a short foot with two claws
local shin = c:line({ {42, 15}, {45, 29}, {47, 43} }, 4)
local foot = c:line({ {48, 44}, {50, 48}, {54, 50} }, 2)
foot:add(c:line({ {52, 50}, {54, 54} }, 2))
-- spines sticking out the back of the shin, pointing down
local spines = c:mask()
for _, s in ipairs({ { 47, 21 }, { 48, 28 }, { 49, 35 } }) do
  spines:add(c:line({ { s[1], s[2] }, { s[1] + 3, s[2] + 2 }, { s[1] + 4, s[2] + 4 } }, 2))
end
-- hip end: a clay-crusted cap cut off the femur across its axis
local ax, ay = 0.61, -0.79                     -- femur axis (hip -> knee)
local px, py = -ay, ax                         -- across the axis
local hx, hy = 21.5, 39.5                      -- where the join sits
local hip = c:poly({ { hx + px * 14, hy + py * 14 }, { hx - px * 14, hy - py * 14 },
                     { hx - px * 14 - ax * 16, hy - py * 14 - ay * 16 }, { hx + px * 14 - ax * 16, hy + py * 14 - ay * 16 } })

local p = c:build{
  { "spines", spines, legR, { flat = true } },
  { "foot",   foot, legR, { flat = true } },
  { "shin",   shin, GV.ramp("#6a3a22"), { gloss = false, cres = 2, deep = 1 } },
  { "femur",  femur, brown, { gloss = { 27, 25 } } },
  { "knee",   c:ellipse(41, 14, 3.5, 3.5), legR, { gloss = false } },
}
local hipm = hip:clip(p.femur.m)
local ph = c:part(hipm, clay, { light = p.femur.m, gloss = { 11, 44 } })
-- chevron ridges down the femur (the herringbone of a cricket's jumping leg)
local rid = c:mask()
for i = 0, 2 do
  local cx, cy = 26 + i * 5, 33 - i * 6.5
  rid:add(c:line({ { cx - 4, cy - 2 }, { cx, cy + 2 }, { cx + 3, cy - 3 } }, 1))
end
c:fill(rid:clip(p.femur.m:shrink(2)):cut(hipm:grow(1)), "#c08048")
-- clay crust: a glazed bean chip on the femur
c:spot(c:ellipse(34, 28, 2, 1.5), "#9a6b3f", "#c9a96e")
-- seam across the hip join, with a button at its head
c:seam({ { hx - px * 9 + 1, hy - py * 9 + 1 }, { hx + px * 9, hy + py * 9 } })
c:button(12, 32)

local t = c:save(D .. "final/aseprite/ph/cricket-leg.aseprite", PNG .. "cricket-leg.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
