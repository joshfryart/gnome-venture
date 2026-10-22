local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "scene" }
c:fill(c:rect(0, 0, 63, 63), "#7a4a1f")
for _, y in ipairs({ 6, 21, 36, 51 }) do
  c:fill(c:rect(0, y, 63, y + 6), "#3d2a1c")
  -- hard 2px steps on the furrow's upper edge (period 16 so it tiles)
  for x = 0, 63 do if (x % 16) < 6 then c:px(x, y, "#7a4a1f") end end
  for x = 0, 63 do if (x % 16) >= 8 and (x % 16) < 12 then c:px(x, y + 6, "#9a6b3f") end end
  c:fill(c:rect(0, y + 7, 63, y + 9), "#9a6b3f")
  -- lit top edge of the ridge, broken every 8 px
  for x = 0, 63 do if (x % 8) < 5 then c:px(x, y + 7, "#c9a96e") end end
end
for _, p in ipairs({ {6,2}, {30,17}, {35,33}, {15,47}, {39,32}, {49,62} }) do
  c:fill(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), "#c9a96e")
end
for _, s in ipairs({ {12,16,19}, {44,47,4}, {26,30,48}, {52,55,33} }) do
  c:fill(c:rect(s[1], s[3], s[2], s[3]), "#2a1a10")
end
local t = c:save(O .. "aseprite/ph/tile-tilled.aseprite", O .. "png/ph/tile-tilled.png")
print(GV.report(t))
