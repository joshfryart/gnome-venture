local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local lilac = GV.ramp("#b8a2ea")
local ice = GV.ramp("#a9d6ea")
local plateL = c:poly({ {8,55}, {18,33}, {29,55} })
local plateR = c:poly({ {35,55}, {47,35}, {57,55} })
local spire = c:poly({ {32,5}, {44,20}, {39,55}, {26,55}, {20,20} })
local p = c:build{
  { "plateL", plateL, lilac },
  { "plateR", plateR, lilac },
  { "spire", spire, ice, { gloss = { 25, 18 } } },
}
-- facet lines: Y plus centre ridge
local fac = c:line({ {22,21}, {32,28}, {42,21} }, 1):add(c:line({ {32,29}, {32,52} }, 1))
fac:clip(spire:shrink(1))
c:fill(fac, "#3f93b2")
-- right facet a touch darker
local rf = spire:copy():clip(c:poly({ {33,29}, {44,20}, {44,56}, {33,56} })):shrink(1)
rf:cut(fac)
rf:each(function(x, y) if c:get(x, y) == ice.base then c:px(x, y, "#8fcbd8") end end)
-- plate facet ridges
c:fill(c:line({ {16,37}, {15,52} }, 1):clip(plateL:shrink(1)), "#a894dc")
c:fill(c:line({ {47,39}, {49,52} }, 1):clip(plateR:shrink(1)), "#a894dc")
-- glints
c:px(24, 30, "#c8ecdc"); c:px(25, 31, "#c8ecdc")
c:ground(32, 56, 17, 2)
local t = c:save(O .. "aseprite/ph/desert-rose-stone.aseprite", O .. "png/ph/desert-rose-stone.png")
print(GV.report(t))
