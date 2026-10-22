local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:rrect(13, 16, 51, 55, 3)
local flap = c:poly({ {13, 16}, {52, 16}, {32, 33} })
local win  = c:rrect(18, 34, 46, 51, 5)
local seed = c:ellipse(32, 43, 8, 7)

local p = c:build{
  { "body", body, GV.ramp("#f1ece0") },
  { "flap", flap, GV.ramp("#e6d6a8"), { gloss = false } },
  { "win",  win,  GV.ramp("#f08a24"), { gloss = false, rim = false } },
}
-- window inner paper
c:part(c:rrect(20, 36, 44, 49, 4), GV.ramp("#f4f0e0"), { flat = true, contour = false, contact = false })
c:part(seed, GV.ramp("#f08a24"), { gloss = { 28, 39 } })
-- belly crescent line
c:paint({ "..eeeee..", ".e.....e." }, 28, 49, { e = "#e0501f" })
-- sprout
c:fill(c:line({ {32, 37}, {32, 31} }, 2), "#2f5a2a")
c:fill(c:ellipse(36, 30, 3, 2), "#58a03e")
c:px(35, 29, "#8fd06a")
-- fold edge on flap
c:seam({ {14, 17}, {32, 32}, {51, 17} })
c:button(30, 29)
-- label dots
for _, x in ipairs({ 25, 31, 37 }) do c:fill(c:rect(x, 52, x + 1, 53), "#8c4a1a") end
c:ground(32, 57, 17, 3)
local t = c:save(O .. "aseprite/ph/crinum-lily-seed.aseprite", O .. "png/ph/crinum-lily-seed.png")
print(GV.report(t))
