-- clay-pot: a small round-bellied pot fresh off the wheel, lopsided on purpose
-- (belly sags right, neck and lip tilt left), with throwing rings and a seamed foot.
-- Family: wood/soil clay tan, GV.ramp("#c47a52") (skin-shade terracotta run through the recipe).
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local clay = GV.ramp("#c47a52")

-- tilted ellipse as a polygon (deg > 0 tips the right side up)
local function tilt(cx, cy, rx, ry, deg)
  local a, pts = math.rad(-deg), {}
  for i = 0, 35 do
    local t = i * math.pi / 18
    local x, y = rx * math.cos(t), ry * math.sin(t)
    pts[#pts + 1] = { cx + x * math.cos(a) - y * math.sin(a) + 0.5, cy + x * math.sin(a) + y * math.cos(a) + 0.5 }
  end
  return c:poly(pts)
end

-- belly: a squat ball that sags to the right
local belly = c:ellipse(31, 39, 16, 12):add(c:ellipse(36, 42, 14, 9)):closed(2)
-- neck: short, pinched, leaning left
local neck = c:poly({ {21, 17}, {35, 16}, {37, 29}, {22, 30} }):closed(1)
-- lip: a flared ring, tipped up on the right (lopsided)
local lip = tilt(28, 17, 13, 5, 10)
-- foot ring
local foot = c:rrect(25, 50, 44, 54, 2)

local p = c:build{
  { "foot",  foot,  clay, { gloss = false } },
  { "belly", belly, clay, { gloss = false } },
  { "neck",  neck,  clay, { gloss = false } },
  { "lip",   lip,   clay, { gloss = false } },
}
-- the mouth: dark tilted opening inside the lip, deeper at the back
c:fill(tilt(28.5, 17.5, 9, 2.6, 10), "#5e2f1e")
c:fill(tilt(28.5, 16.5, 7, 1.4, 10), "#2a1a10")
-- hand-laid enamel commas (belly, lip)
c:paint({ "..gg", ".g..", "g...", "g..." }, 19, 31, { g = clay.gloss })
c:px(21, 33, clay.dot)
c:paint({ ".gg", "g.." }, 16, 16, { g = clay.gloss })
-- throwing rings: two shallow grooves round the belly, following its sag
local G = clay.shade
c:fill(c:line({ {18, 37}, {25, 38}, {33, 38}, {41, 39}, {46, 40} }, 1):clip(belly:shrink(2)), G)
c:fill(c:line({ {20, 44}, {28, 45}, {37, 46}, {45, 46} }, 1):clip(belly:shrink(2)), G)
-- a thumb dent on the sagging side
c:fill(c:ellipse(42, 32, 1.5, 1), clay.shade)
c:px(41, 31, clay.deep); c:px(42, 31, clay.deep)
-- foot join: a seam round the plinth lip
c:seam({ {26, 51}, {43, 51} })

c:ground(34, 55, 15, 1.5)
local t = c:save(D .. "final/aseprite/ph/clay-pot.aseprite", PNG .. "clay-pot.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
