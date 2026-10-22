local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local rim = c:ellipse(31.5, 34, 24, 18)
local step = c:ellipse(31.5, 33, 21, 15.5)
local water = c:ellipse(31.5, 33, 19, 13)
local padL = c:ellipse(23, 39, 7, 4.5)
padL:cut(c:poly({ { 24, 39 }, { 29, 35 }, { 30, 37 } }))
local padR = c:ellipse(42.5, 28, 6, 4)
padR:cut(c:poly({ { 42, 28 }, { 38, 24 }, { 37, 26 } }))
local body = c:ellipse(35, 30, 6.5, 4.5)
local eyeL = c:ellipse(32, 25.5, 2.5, 2.5)
local eyeR = c:ellipse(38, 25.5, 2.5, 2.5)
local reedL = c:line({ { 10, 44 }, { 9, 40 }, { 9, 37 }, { 11, 35 } }, 2)
local reedR = c:line({ { 53, 26 }, { 54, 22 }, { 54, 19 }, { 52, 17 } }, 2)

c:build{
  { "rim", rim, "stone" },
  { "step", step, "#5b6470", { gloss = false, contact = false } },
  { "water", water, "#4a90b8", { gloss = false } },
}
-- hard-stepped lit patch and ripple on the water
local lit = c:ellipse(26, 29, 11, 5):clip(water:shrink(1))
c:fill(lit, "#8fcbd8")
c:fill(c:line({ { 13, 39 }, { 18, 42 }, { 26, 44 } }, 1):clip(water), "#c8ecdc")
c:build{
  { "padL", padL, "#4f9a45" },
  { "padR", padR, "#4f9a45" },
  { "body", body, "#5da443" },
  { "eyeL", eyeL, "#6fb552", { gloss = false, contact = false } },
  { "eyeR", eyeR, "#6fb552", { gloss = false, contact = false } },
  { "reedL", reedL, "#5a7a3a", { flat = true } },
  { "reedR", reedR, "#5a7a3a", { flat = true } },
}
-- pink bud on the left pad
c:part(c:ellipse(20, 37.5, 2, 2), "#f6b8cf", { flat = true })
c:px(20, 36, "#e46a9b")
-- locked small eyes and a smile
c:eye(31, 24, true); c:eye(37, 24, true)
c:paint({ "u...u", ".uuu." }, 33, 30, { u = "umber" })
local t = c:save(O .. "aseprite/animals/frog_pond.aseprite", O .. "png/animals/frog_pond.png")
print(GV.report(t))
