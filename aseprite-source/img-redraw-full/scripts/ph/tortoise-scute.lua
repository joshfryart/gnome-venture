local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local outer = c:poly({ {32,6}, {54,18}, {51,46}, {32,57}, {13,46}, {10,18} })
local inner = c:poly({ {32,15}, {45,22}, {43,40}, {32,47}, {21,40}, {19,22} })
local p = c:build{
  { "plate", outer, "moss", { gloss = false } },
  { "inner", inner, GV.ramp("#5f9c48"), { gloss = false, contact = false } },
}
-- facet lines from inner corners to outer corners
local fl = "#2f5a2a"
c:line({ {32,7}, {32,14} }, 2):each(function(x,y) if outer:has(x,y) then c:px(x,y,"#9fcc6e") end end)
c:line({ {45,22}, {52,19} }, 1):each(function(x,y) c:px(x,y,fl) end)
c:line({ {43,40}, {49,45} }, 1):each(function(x,y) c:px(x,y,fl) end)
c:line({ {32,48}, {32,55} }, 1):each(function(x,y) c:px(x,y,fl) end)
c:line({ {21,40}, {15,45} }, 1):each(function(x,y) c:px(x,y,"#4a8a3e") end)
c:line({ {19,22}, {12,19} }, 1):each(function(x,y) c:px(x,y,"#4a8a3e") end)
-- centre ridge on inner plate (bright spine)
c:line({ {31,17}, {31,44} }, 2):each(function(x,y) if inner:has(x,y) then c:px(x,y,"#a4b86a") end end)
c:line({ {33,18}, {33,44} }, 1):each(function(x,y) if inner:has(x,y) then c:px(x,y,"#3d7a34") end end)
-- growth rings (inner hex outline, smaller)
local ring = c:poly({ {32,21}, {40,26}, {39,37}, {32,41}, {25,37}, {24,26} }):edge()
ring:each(function(x,y) if x < 30 or x > 34 then c:px(x,y,"#3d7a34") end end)
c:gloss(outer, GV.R.moss, { 22, 19 })
c:px(17, 25, "#fff3c8")
local t = c:save(O .. "aseprite/ph/tortoise-scute.aseprite", O .. "png/ph/tortoise-scute.png")
print(GV.report(t))
