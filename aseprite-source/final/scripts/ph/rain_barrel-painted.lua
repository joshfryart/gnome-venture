local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local blue = GV.ramp("#3f93b2", { gloss = "#c8ecdc", shade = "#2f6290" })
local stone = GV.ramp("#8b8f96")
local pipe = c:rect(8, 7, 12, 23)
pipe:add(c:rrect(8, 18, 22, 23, 2))
-- barrel bulges a little in the middle
local barrel = c:rrect(15, 22, 49, 55, 7)
barrel:add(c:rrect(13, 30, 51, 47, 4))
local p = c:build{
  { "pipe", pipe, stone },
  { "barrel", barrel, blue },
}
-- staves
for _, x in ipairs({ 23, 32, 41 }) do c:fill(c:rect(x, 25, x, 54):clip(barrel), "#2f6290") end
-- hoops (drawn as parts so they get shading)
local h1 = c:rect(13, 29, 51, 32):clip(barrel)
local h2 = c:rect(13, 45, 51, 48):clip(barrel)
c:part(h1, "petal", { gloss = false })
c:part(h2, "petal", { gloss = false })
c:seam({ {14, 47}, {50, 47} })
-- open top: wood rim with water inside
local rim = c:ellipse(31.5, 22, 18, 5)
local water = c:ellipse(31.5, 22, 15, 3.5)
c:part(rim, "wood", { gloss = false })
c:part(water, blue, { rim = false, contour = false, contact = false, gloss = false, flat = true })
c:fill(c:rect(24, 21, 28, 21), "#a9d6ea"); c:fill(c:rect(34, 23, 38, 23), "#a9d6ea")
-- drip from the pipe mouth into the barrel
c:paint({ ".w.", "www", "www" }, 21, 24, { w = "#a9d6ea" })
-- tap on the front, below the lower hoop
c:part(c:rect(29, 49, 35, 52), GV.ramp("#6a6070"), { flat = true })
c:fill(c:rect(31, 53, 33, 53), "#4e4656")
c:px(32, 54, "#a9d6ea")
c:ground(31.5, 56, 19, 1.5)
local t = c:save(O .. "aseprite/ph/rain_barrel-painted.aseprite", O .. "png/ph/rain_barrel-painted.png")
print(GV.report(t))
