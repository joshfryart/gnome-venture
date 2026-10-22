local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local copper = GV.ramp("#d0862a", { shade = "#b8661a" })
local dark = GV.ramp("#b8661a")
local brass = GV.ramp("#e8a317")

-- handle arch (behind body)
local handle = c:line({ {14, 30}, {16, 18}, {21, 12}, {27, 11}, {33, 13}, {37, 20}, {38, 30} }, 3)
-- spout: long tube up-right
local spout = c:poly({ {35, 37}, {39, 33}, {48, 20}, {52, 23}, {43, 37}, {38, 43} })
-- rose head
local rose = c:ellipse(51, 18.5, 3.5, 3.5)
-- body: squat tapered can
local body = c:poly({ {11, 29}, {40, 29}, {43, 55}, {8, 55} })
body:cut(c:rect(8, 54, 9, 55)); body:cut(c:rect(42, 54, 43, 55))
local rim = c:rrect(9, 26, 42, 31, 2)

local p = c:build{
  { "handle", handle, dark, { flat = true } },
  { "spout", spout, dark },
  { "body", body, copper },
  { "rim", rim, brass },
  { "rose", rose, brass },
}
c:seam({ {12, 28}, {40, 28} })
c:button(10, 27)
-- rose holes
c:px(51, 17, "#7a3a14"); c:px(53, 18, "#7a3a14"); c:px(52, 20, "#7a3a14")
-- water drop
c:paint({ ".w.", "wwg", "www", ".w." }, 51, 25, { w = "#8fcbd8", g = "#c8ecdc" })
-- gloss strip on left of body
c:paint({ "g", "g", "g", "g", "g", "g", "g", ".", "g", "g" }, 14, 35, { g = copper.gloss })
-- base band
c:seam({ {10, 50}, {41, 50} })

local t = c:save(O .. "aseprite/ph/copper-watering-can.aseprite", O .. "png/ph/copper-watering-can.png")
print(GV.report(t))
