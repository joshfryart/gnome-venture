local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local pod = c:mask()
for i = 0, 40 do
  local t = i / 40
  local x = (1-t)^2*21 + 2*(1-t)*t*42 + t*t*50
  local y = (1-t)^2*24 + 2*(1-t)*t*18 + t*t*51
  local r = 7.5 - 6 * t^1.3
  pod:add(c:ellipse(x, y, r, r))
end
local p = c:build{
  { "pod",  pod, "#d6322b" },
  { "cap",  c:ellipse(19.5, 24, 6.5, 6), "#58a03e" },
  { "stem", c:line({ {19, 19}, {18, 15}, {15, 12} }, 4), "#2e5a2c" },
}
local t = c:save(O .. "aseprite/ico/ico-chili.aseprite", O .. "png/ico/ico-chili.png")
print(GV.report(t))
