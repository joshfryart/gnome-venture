local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leaf = c:poly({ {32, 7}, {44, 18}, {53, 32}, {50, 42}, {40, 52}, {32, 55}, {24, 52}, {14, 42}, {11, 32}, {20, 18} })
leaf = leaf:closed(3)
leaf:add(c:ellipse(32, 40, 19, 14))
local p = c:build{
  { "leaf", leaf, GV.ramp("#58a03e"), { gloss = { 21, 24 } } },
}
-- lit left half
local lit = leaf:copy():clip(c:rect(0, 0, 31, 63)):shrink(2)
lit:each(function(x, y)
  local col = c:get(x, y)
  if col == GV.ramp("#58a03e").base then c:px(x, y, "#7ab55c") end
end)
local V = "#2f5a2a"
local v = c:line({ {31, 51}, {31, 14} }, 2)
v:add(c:line({ {31, 34}, {21, 27} }, 2))
v:add(c:line({ {32, 28}, {41, 21} }, 2))
v:add(c:line({ {31, 44}, {22, 38} }, 2))
v:add(c:line({ {32, 40}, {42, 33} }, 2))
v:clip(leaf:shrink(3))
c:fill(v, V)
c:ground(31.5, 58, 16, 2, "#6a4528")
local t = c:save(O .. "aseprite/ph/warrigal-greens.aseprite", O .. "png/ph/warrigal-greens.png")
print(GV.report(t))
