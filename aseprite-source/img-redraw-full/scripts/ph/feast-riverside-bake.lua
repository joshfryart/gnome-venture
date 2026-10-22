-- ph/feast-riverside-bake
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local platter = c:ellipse(31.5, 45, 26, 10)
local dish = c:ellipse(31.5, 43, 21, 7)
local dome = c:ellipse(31.5, 40, 17, 16):cut(c:rect(0, 42, 63, 63)):add(c:ellipse(31.5, 41, 17, 3))
-- 5-point star
local pts = {}
for i = 0, 9 do
  local a = -math.pi / 2 + i * math.pi / 5
  local r = (i % 2 == 0) and 7 or 3
  pts[#pts + 1] = { 32 + r * math.cos(a), 15 + r * math.sin(a) }
end
local star = c:poly(pts)

c:build{
  { "platter", platter, GV.ramp("#d6c9b6"), { pale = true } },
  { "dish",    dish, GV.ramp("#f4f0e0"), { gloss = false } },
  { "dome",    dome, "petal" },
  { "berry",   c:ellipse(24, 33, 4, 4), GV.ramp("#a8241f") },
  { "green",   c:ellipse(39, 31, 4.5, 4.5), "moss" },
  { "dot",     c:ellipse(31.5, 25, 3, 3), "gold", { gloss = false } },
  { "star",    star, "gold", { gloss = false } },
}
c:seam({ {16, 40}, {47, 40} })

local t = c:save(O .. "aseprite/ph/feast-riverside-bake.aseprite", O .. "png/ph/feast-riverside-bake.png")
print(GV.report(t))
