-- animals/worm_farm : wooden bin of compost with a pink worm and a leaf
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function leaf(x0, y0, x1, y1, w)
  local m = c:mask()
  local L = math.sqrt((x1 - x0)^2 + (y1 - y0)^2)
  local ux, uy = (x1 - x0) / L, (y1 - y0) / L
  for y = 0, 63 do for x = 0, 63 do
    local t = (x - x0) * ux + (y - y0) * uy
    local d = -(x - x0) * uy + (y - y0) * ux
    if t >= 0 and t <= L and math.abs(d) <= w * math.sin(math.pi * (t / L) ^ 0.8) then m:set(x, y) end
  end end
  return m
end

local bin = c:poly({ { 13, 34 }, { 51, 34 }, { 46, 54 }, { 18, 54 } })
bin:cut(c:rect(18, 52, 19, 53)); bin:cut(c:rect(45, 52, 46, 53)); bin:set(19, 52); bin:set(45, 52)
local soil = c:ellipse(31.5, 33, 19, 10):cut(c:rect(0, 33, 63, 63))
local pink = GV.ramp("#c9707a")
local worm = c:line({ { 23, 31 }, { 21, 27 }, { 22, 23 }, { 25, 20 }, { 28, 18 } }, 4)
worm:add(c:ellipse(31, 16.5, 4.5, 4))

c:build{
  { "leaf", leaf(42, 26, 50, 11, 4.5), "moss" },
  { "soil", soil, GV.ramp("#3d2a1c") },
  { "bin",  bin, GV.ramp("#9a6b3f") },
  { "rim",  c:rrect(11, 31, 52, 36, 1), GV.ramp("#7a4a1f"), { gloss = false } },
  { "worm", worm, pink, { gloss = { 29, 14 } } },
}
-- leaf vein
c:fill(c:line({ { 43, 24 }, { 48, 15 } }, 1), "#4a8a3e")
-- crumbly soil lumps
for _, p in ipairs({ { 16, 29 }, { 35, 27 }, { 42, 29 }, { 29, 30 }, { 47, 31 } }) do
  c:paint({ "ll" }, p[1], p[2], { l = "#7a4a1f" })
end
-- worm segment rings
c:px(22, 27, pink.shade); c:px(23, 27, pink.shade); c:px(24, 22, pink.shade); c:px(25, 23, pink.shade)
-- plank line on bin
c:fill(c:rect(17, 45, 47, 45):clip(bin:shrink(1)), "#7a4a1f")
-- rim seam
c:seam({ { 13, 33 }, { 50, 33 } })
c:eye(30, 14, true)

local t = c:save(O .. "aseprite/animals/worm_farm.aseprite", O .. "png/animals/worm_farm.png")
print(GV.report(t))
