local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local p = c:build{
  { "board", c:rrect(9, 46, 54, 54, 2), "wood" },
  { "eggL", c:ellipse(17.5, 29, 9, 9), "#c9a96e" },
  { "eggR", c:ellipse(46.5, 29, 9, 9), "#c9a96e" },
  { "front", c:ellipse(32, 38, 12, 12), "#9a6b3f", { gloss = false } },
  { "white", c:ellipse(32, 37, 8, 8), "#f1ece0", { gloss = { 27, 32 } } },
  { "yolk", c:ellipse(32.5, 37.5, 4.5, 4.5), "gold", { gloss = { 31, 35 } } },
}
-- crumb dots
local dots = { {12,26},{19,23},{10,31},{15,33},{21,29},{43,24},{50,26},{52,31},{46,33},{40,28},
  {23,44},{26,30},{38,47},{41,43},{36,28},{24,38} }
for _, d in ipairs(dots) do
  local x, y = d[1], d[2]
  local col = "#7a4a1f"
  if p.white.m:has(x,y) or p.white.m:has(x+1,y+1) then col = nil end
  if col then c:px(x, y, col); c:px(x+1, y, col) end
end
-- board grain
c:paint({ "ww....ww" }, 12, 51, { w = "#8a4f2a" })
c:paint({ "ww....ww" }, 46, 51, { w = "#8a4f2a" })
local t = c:save(O .. "aseprite/ph/scotch-quail-eggs.aseprite", O .. "png/ph/scotch-quail-eggs.png")
print(GV.report(t))
