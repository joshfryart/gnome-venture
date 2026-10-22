local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local tin = GV.ramp("#8b8f96", { gloss = "#e4e0d6", rim = "#c9c5bc", shade = "#5b6470", deep = "#3c4250" })
local orange = GV.ramp("#f08a24")

-- seed mound peeking out of the open box
local mound = c:ellipse(32, 33, 16, 5)
-- squat tin body
local body = c:rrect(12, 32, 51, 54, 3)
-- lid tilted up and back: parallelogram hinged at the back
local lid = c:poly({ {10, 24}, {52, 12}, {55, 22}, {13, 33} })

local p = c:build{
  { "lid", lid, tin, { gloss = { 16, 25 } } },
  { "mound", mound, orange, { gloss = { 22, 30 } } },
  { "body", body, tin, { gloss = { 15, 36 } } },
}
-- seeds in the mound
c:fill(c:rrect(25, 30, 27, 31, 1), "#8c4a1a")
c:fill(c:rrect(33, 29, 35, 30, 1), "#8c4a1a")
c:fill(c:rrect(40, 31, 42, 32, 1), "#8c4a1a")
-- lid label: pumpkin disc
c:part(c:ellipse(33, 22, 5, 4), orange, { flat = true })
c:fill(c:rect(31, 20, 31, 24), "#e0501f"); c:fill(c:rect(35, 19, 35, 23), "#e0501f")
c:fill(c:rect(33, 16, 34, 18), "#2e5a2c")
-- rolled rim band on body
c:fill(c:rect(13, 36, 50, 36), "#c9c5bc")
c:fill(c:rect(13, 37, 50, 37), "#5b6470")
-- hinge pins at the back corners
c:part(c:rect(14, 30, 16, 33), "stone", { flat = true })
c:part(c:rect(47, 26, 49, 29), "stone", { flat = true })
c:fill(c:rect(15, 31, 15, 32), "#5b6470"); c:fill(c:rect(48, 27, 48, 28), "#5b6470")
-- clasp tab with button
c:part(c:rrect(28, 38, 35, 44, 1), GV.ramp("#5b6470"), { flat = true })
c:button(30, 39)

c:ground(32, 57, 18, 2.5)
local t = c:save(O .. "aseprite/ph/pumpkin-seed.aseprite", O .. "png/ph/pumpkin-seed.png")
print(GV.report(t))
