local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local leaf = c:poly({ {34,19}, {37,12}, {42,8}, {49,7}, {48,13}, {44,17}, {39,20} })
local stem = c:rect(31, 14, 33, 20)
local rind = c:ellipse(31.5, 38, 19.5, 19.5)
local flesh = c:ellipse(31.5, 38, 15.5, 15.5)
local p = c:build{
  { "stem", stem, "wood", { flat = true } },
  { "leaf", leaf, GV.ramp("#58a03e") },
  { "rind", rind, GV.ramp("#f1ece0") },
  { "flesh", flesh, GV.ramp("#ee6656"), { gloss = { 21, 28 } } },
}
-- 8 spokes
local pale = "#f6e8c8"
for i = 0, 7 do
  local a = i * math.pi / 4 + math.pi / 8
  local x0, y0 = 31.5 + math.cos(a) * 3.5, 38 + math.sin(a) * 3.5
  local x1, y1 = 31.5 + math.cos(a) * 13.5, 38 + math.sin(a) * 13.5
  c:fill(c:line({ { math.floor(x0 + 0.5), math.floor(y0 + 0.5) }, { math.floor(x1 + 0.5), math.floor(y1 + 0.5) } }, 1), pale)
end
c:fill(c:ellipse(31.5, 38, 2.5, 2.5), pale)
local t = c:save(O .. "aseprite/ph/grapefruit.aseprite", O .. "png/ph/grapefruit.png")
print(GV.report(t))
