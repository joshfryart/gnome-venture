local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local left  = c:poly({ {11,55},{19,36},{23,37},{29,55} })
local right = c:poly({ {41,55},{47,38},{50,38},{57,55} })
local main  = c:poly({ {32,6},{45,20},{39,56},{25,56},{19,20} })
local all = left:copy(); all:add(right); all:add(main)
local lil = GV.ramp("#c3b2ea")
local blu = GV.ramp("#a9d6ea")
local p = c:build{
  { "left",  left,  lil, { gloss = false, cres = 2, deep = 1 } },
  { "right", right, lil, { gloss = false, cres = 2, deep = 1 } },
  { "main",  main,  blu, { light = all, gloss = false } },
}
-- facet lines
c:fill(c:line({ {20,20},{32,28} }, 2):clip(main), "#3f93b2")
c:fill(c:line({ {32,28},{44,20} }, 2):clip(main), "#3f93b2")
c:fill(c:rect(31, 28, 32, 55):clip(main), "#3f93b2")
-- lit top facet a touch lighter
c:fill(c:line({ {31,9},{23,20} }, 1):clip(main), "#c8ecdc")
-- facets on satellites
c:fill(c:line({ {20,39},{20,54} }, 1):clip(left), "#9a86cc")
c:fill(c:line({ {48,41},{49,54} }, 1):clip(right), "#9a86cc")
c:px(18, 42, "#e6dcff"); c:px(17, 44, "#e6dcff")
c:px(45, 44, "#e6dcff"); c:px(44, 46, "#e6dcff")
-- sparkle (4-point plus) as the gloss
c:paint({ "...g...", "...g...", "..ggg..", "gggwggg", "..ggg..", "...g...", "...g..." }, 23, 15, { g = "#fff3c8", w = "#ffffff" })
c:px(36, 13, "#fff3c8")
local t = c:save(O .. "aseprite/ph/shiny-quartz.aseprite", O .. "png/ph/shiny-quartz.png")
print(GV.report(t))
