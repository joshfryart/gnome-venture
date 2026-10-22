local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- five-point star fruit, rounded
local pts = {}
local cx, cy = 31, 20
for i = 0, 9 do
  local a = -math.pi / 2 + i * math.pi / 5
  local r = (i % 2 == 0) and 14 or 7
  pts[#pts + 1] = { cx + r * math.cos(a), cy + r * math.sin(a) }
end
local star = c:poly(pts):closed(2)

local p = c:build{
  { "crate", c:rrect(13, 30, 51, 54, 2), "wood" },
  { "brace", c:line({ {17, 51}, {47, 37} }, 3), GV.ramp("#b07a45", { base = "#a8703f" }), { flat = true, contact = false } },
  { "rim",   c:rect(11, 27, 53, 32), GV.ramp("#d9a660"), { gloss = false } },
  { "fruit", star, "gold" },
  { "stem",  c:line({ {31, 8}, {32, 6} }, 2), "#5e2f1e", { flat = true } },
  { "leaf",  c:ellipse(37, 7, 4, 2), "moss", { gloss = false } },
}
-- slat gaps
c:fill(c:rect(14, 40, 50, 40):cut(p.brace.m), "#5e2f1e")
c:fill(c:rect(14, 47, 50, 47):cut(p.brace.m), "#5e2f1e")
-- nails
c:px(14, 29, "#5e2f1e"); c:px(50, 29, "#5e2f1e")
c:px(16, 34, "#5e2f1e"); c:px(48, 34, "#5e2f1e")
c:px(16, 51, "#5e2f1e"); c:px(48, 51, "#5e2f1e")
-- fruit ridges from centre to points
c:fill(c:line({ {31, 19}, {31, 10} }, 1):clip(p.fruit.m), "#f5cf6a")
c:fill(c:line({ {31, 20}, {39, 24} }, 1):clip(p.fruit.m), "#d0862a")
c:fill(c:line({ {31, 20}, {23, 24} }, 1):clip(p.fruit.m), "#f5cf6a")
-- leaf vein
c:fill(c:line({ {35, 7}, {39, 7} }, 1), "#4a8a3e")
c:ground(32, 57, 17, 2)
local t = c:save(O .. "aseprite/ph/starfruit-seed.aseprite", O .. "png/ph/starfruit-seed.png")
print(GV.report(t))
