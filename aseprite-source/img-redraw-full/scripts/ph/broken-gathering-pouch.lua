local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- slumped bag: wide bottom, narrower shoulders
local body = c:ellipse(32,42,20,14):cut(c:rect(0,55,63,63))
body:add(c:rrect(14,44,50,54,6))
body:add(c:poly({ {21,32},{43,32},{48,38},{16,38} }))
-- drooping ruffled neck, leaning left
local neck = c:poly({ {24,27},{40,27},{42,18},{38,15},{34,18},{30,14},{26,17},{20,16},{22,22} })
local p = c:build{
  { "body", body, "wood" },
  { "neck", neck, GV.ramp("#d9a660") },
}
-- ruffle folds
c:line({ {29,19},{29,25} }, 1):each(function(x,y) c:px(x,y,"#a8582f") end)
c:line({ {35,20},{35,25} }, 1):each(function(x,y) c:px(x,y,"#a8582f") end)
-- drawstring cord with dangling ends
local cord = "#8c4a1a"
c:line({ {21,26},{43,26} }, 2):each(function(x,y) c:px(x,y,cord) end)
c:line({ {22,27},{21,31},{23,34} }, 2):each(function(x,y) c:px(x,y,cord) end)
c:line({ {42,27},{43,30} }, 2):each(function(x,y) c:px(x,y,cord) end)
c:paint({ "kk", "kk" }, 22, 34, { k = "#5e2f1e" })
-- gold band
c:seam({ {13,41},{51,41} }, { on = 3, off = 1 })
c:rect(13,40,50,42):each(function(x,y) if p.body.m:has(x,y) then c:px(x,y,(y==42) and "#e8a317" or "#f5cf6a") end end)
-- edge stitch left side
c:stitch(p.body.m:copy():clip(c:rect(0,0,28,63)), { side = "lit" })
-- tear: jagged dark gash in the right side
local tear = c:line({ {50,33},{43,39},{48,45},{41,51} }, 4)
tear:clip(p.body.m:shrink(1)); tear:add(c:rect(48,44,50,47):clip(p.body.m))
tear:each(function(x,y) c:px(x,y,"#2a1a10") end)
tear:edge():each(function(x,y) if p.body.m:has(x,y) and not tear:has(x,y) then c:px(x,y,"#5e2f1e") end end)
-- loose thread dangling out
c:paint({ "g...", "g...", ".g..", ".gg.", "..gg", "...g", "...g" }, 49, 47, { g = "#f5cf6a" })
c:ground(32,56,17,1.5)
local t = c:save(O .. "aseprite/ph/broken-gathering-pouch.aseprite", O .. "png/ph/broken-gathering-pouch.png")
print(GV.report(t))
