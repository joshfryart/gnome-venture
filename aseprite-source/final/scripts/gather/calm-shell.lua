local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 100, h = 100, mode = "sticker", out = 2 }
-- fan: wedge from hinge to a big arc with scallop bumps
local fan = c:ellipse(50, 50, 35, 31):cut(c:rect(0, 52, 99, 99))
fan:add(c:poly({ {15, 50}, {85, 50}, {58, 84}, {42, 84} }))
for i = 0, 6 do
  local a = math.pi * (0.08 + i * 0.84 / 6)
  fan:add(c:ellipse(50 - math.cos(a) * 34, 50 - math.sin(a) * 30, 5, 5))
end
local p = c:build{
  { "shell", fan, GV.ramp("#f6b8cf") },
  { "hinge", c:rrect(36, 80, 63, 89, 4), GV.ramp("#e08aa0") },
}
local tips = { {50,22}, {35,26}, {65,26}, {23,40}, {77,40} }
for _, tp in ipairs(tips) do
  local m = c:line({ {50, 79}, tp }, 1):clip(p.shell.m)
  m:cut(c:rect(0, 0, 99, 20))
  m:each(function(x, y) c:px(x, y, "#b8452f") end)
end
c:seam({ {40, 84}, {60, 84} })
local t = c:save(O .. "aseprite/gather/calm-shell.aseprite", O .. "png/gather/calm-shell.png")
print(GV.report(t))
