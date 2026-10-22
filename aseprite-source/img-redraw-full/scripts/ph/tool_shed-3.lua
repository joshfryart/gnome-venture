local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local wood  = GV.ramp("#b07a45")
local stone = GV.ramp("#8b8f96")
local door  = GV.ramp("#6e3616")
local red   = GV.ramp("#d6322b")

-- flag pole behind roof
c:part(c:rect(31, 8, 32, 22), "wood", { flat = true })
c:part(c:poly({ {33, 8}, {42, 11}, {33, 15} }), red, { flat = true })

local p = c:build{
  { "wall", c:rect(13, 31, 50, 53), wood },
  { "roof", c:poly({ {8, 35}, {17, 20}, {47, 20}, {56, 35} }), stone },
  { "door", c:rect(25, 39, 38, 53), door },
}
-- planks on the wall
local plank = c:line({ {14, 41}, {24, 41} }, 1):add(c:line({ {39, 41}, {49, 41} }, 1))
plank:add(c:line({ {14, 47}, {24, 47} }, 1)):add(c:line({ {39, 47}, {49, 47} }, 1))
c:fill(plank, "#8a4f2a")
-- eave strip
c:fill(c:rect(10, 33, 54, 34):clip(p.roof.m), "#6a6070")
-- door X brace
c:fill(c:line({ {26, 40}, {37, 52} }, 1):add(c:line({ {37, 40}, {26, 52} }, 1)), "#44281c")
c:px(31, 46, "#44281c"); c:px(32, 46, "#44281c")

-- spade leaning on the left wall
c:part(c:line({ {12, 53}, {14, 40} }, 2), "wood", { flat = true })
c:part(c:rrect(11, 41, 16, 47, 1), stone, { flat = true })
-- rake leaning on the right wall
c:part(c:line({ {52, 53}, {50, 40} }, 2), "wood", { flat = true })
c:part(c:rect(47, 38, 54, 40), stone, { flat = true })
c:fill(c:ascii({ "x.x.x.x." }, 47, 41), "#6a6070")

-- gold tag on left wall
c:part(c:rrect(18, 42, 22, 47, 1), "gold", { flat = true })
c:px(20, 43, "#8a4a1c")
-- sparkle
c:paint({ "..s..", ".sss.", "sssss", ".sss.", "..s.." }, 48, 9, { s = "#f5cf6a" })

c:seam({ {14, 52}, {49, 52} })
c:button(30, 40)
c:ground(31.5, 55, 24, 1.5)

local t = c:save(O .. "aseprite/ph/tool_shed-3.aseprite", O .. "png/ph/tool_shed-3.png")
print(GV.report(t))
