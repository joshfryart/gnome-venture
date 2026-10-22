local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local glass = GV.ramp("#c8ecdc", { rim = "#8fcbd8", shade = "#8fcbd8", deep = "#3f8fb0" })
local wood  = "wood"
local blue  = GV.ramp("#3f93b2", { shade = "#256a80" })
local leaf  = GV.ramp("#58a03e")

-- tall narrow straight-sided jar, neck flush with the body (no shoulder step)
local jar = c:rrect(21, 17, 43, 53, 5)
jar:add(c:rect(24, 14, 40, 22))
local cork = c:poly({ {24, 7}, {41, 7}, {40, 16}, {25, 16} })

local p = c:build{
  { "jar",  jar,  glass, { gloss = false } },
  { "cork", cork, wood },
}
-- neck lip ring
c:fill(c:rect(24, 16, 40, 17), "#8fcbd8")
-- cork pores
c:paint({ "p.....p", "...p...", ".p....p" }, 28, 9, { p = "#8a4f2a" })
-- contents: blue orb, leaf, seed pile
c:part(c:ellipse(32, 41, 7.5), blue)
c:part(c:poly({ {30, 30}, {36, 28}, {35, 33}, {31, 34} }), leaf, { flat = true })
for i = 0, 3 do
  c:part(c:rect(25 + i * 4, 49, 27 + i * 4, 51), "#8c4a1a", { flat = true })
end
-- glass gloss streak on the lit side
c:fill(c:rect(24, 22, 24, 37), "#fff3c8")
c:fill(c:rect(25, 22, 25, 27), "#fff3c8")
c:px(24, 40, "#fff3c8")
c:ground(32, 54, 14, 2)
local t = c:save(O .. "aseprite/ph/red-hot-poker-seed.aseprite", O .. "png/ph/red-hot-poker-seed.png")
print(GV.report(t))
