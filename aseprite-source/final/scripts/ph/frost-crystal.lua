local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local main  = c:poly({ {32,5},{45,20},{39,55},{25,55},{19,20} })
local left  = c:poly({ {11,55},{20,37},{29,55} })
local right = c:poly({ {37,55},{47,39},{55,55} })
local ice   = GV.ramp("#a9d6ea")
local lilac = GV.ramp("#c3b2ea")
local p = c:build{
  { "main",  main,  ice },
  { "left",  left,  lilac },
  { "right", right, lilac },
}
local facet = c:line({ {20,20},{32,28},{44,20} }, 2):add(c:line({ {32,28},{32,54} }, 2)):clip(p.main.m:shrink(1))
facet:cut(left):cut(right)
c:fill(facet, "#3f93b2")
-- shard facet lines
c:fill(c:line({ {20,39},{20,54} }, 1):clip(left:shrink(1)), "#8f7bc8")
c:fill(c:line({ {47,41},{47,54} }, 1):clip(right:shrink(1)), "#8f7bc8")
c:paint({ ".s.", "sss", ".s." }, 26, 13, { s = "#fffaf0" })
c:ground(33, 56, 22, 1.5)
local t = c:save(O .. "aseprite/ph/frost-crystal.aseprite", O .. "png/ph/frost-crystal.png")
print(GV.report(t))
