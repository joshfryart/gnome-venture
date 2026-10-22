local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 48, h = 48, mode = "icon", margin = 3 }

local roof = c:poly({ {24, 9}, {7, 26}, {41, 26} }):cut(c:poly({ {24, 15}, {7, 32}, {41, 32} }))
local walls = c:rect(11, 21, 36, 37):add(c:poly({ {24, 14}, {10, 28}, {38, 28} }))

local p = c:build{
  { "ground",  c:rrect(8, 36, 39, 39, 1), "#7a4a1f", { gloss = false } },
  { "chimney", c:rect(30, 9, 34, 20), "#a8582f", { gloss = false } },
  { "walls",   walls, "#e9b98a" },
  { "roof",    roof, "red" },
  { "door",    c:rrect(20, 29, 27, 37, 2), "#8a4f2a", { gloss = false } },
  { "winL",    c:rect(12, 27, 17, 32), "#8fcbd8", { gloss = false } },
  { "winR",    c:rect(30, 27, 35, 32), "#8fcbd8", { gloss = false } },
}
-- window crosses + a glint pane
for _, x0 in ipairs({ 12, 30 }) do
  for y = 27, 32 do c:px(x0 + 3, y, "#8a4f2a") end
  for x = x0, x0 + 5 do c:px(x, 29, "#8a4f2a") end
  c:px(x0 + 1, 28, "#c8ecdc")
end
c:px(25, 33, "#f5cf6a"); c:px(25, 32, "#fff1c8")   -- door knob
for x = 30, 34 do c:px(x, 9, "#d9a660") end         -- chimney cap
c:seam({ {23, 11}, {9, 25} })
c:seam({ {25, 11}, {39, 25} })
c:button(22, 10)
local t = c:save(O .. "aseprite/stops/inn.aseprite", O .. "png/stops/inn.png")
print(GV.report(t))
