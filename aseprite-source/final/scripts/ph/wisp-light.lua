local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- flame body: pointed tip leaning left, round belly, tail curling to the lower right
local body = c:ellipse(30.5, 39, 13.5, 13)
body:add(c:poly({ { 26, 8 }, { 29, 8 }, { 36, 18 }, { 43, 30 }, { 44, 38 }, { 17, 38 }, { 19, 26 }, { 25, 16 } }))
body:add(c:line({ { 38, 48 }, { 44, 50 }, { 48, 48 }, { 50, 44 } }, 4))
body:add(c:ellipse(49.5, 42.5, 2.5, 2.5))

local glow = c:ellipse(30.5, 40, 8.5, 9)
glow:add(c:poly({ { 28, 20 }, { 30, 20 }, { 36, 32 }, { 39, 40 }, { 22, 40 }, { 24, 30 } }))

local p = c:build{
  { "body", body, GV.ramp("#7ab55c") },
  { "glow", glow, GV.ramp("#c8d77a"), { gloss = false, cres = 2, deep = 1 } },
  { "core", c:ellipse(30.5, 45, 4.5, 4), GV.ramp("#fff1c8"), { gloss = false, cres = 1, deep = 1 } },
}
c:gloss(p.body.m, GV.R.moss, { 21, 30 })
-- spark orbs
c:part(c:ellipse(49, 18, 3, 3), GV.ramp("#a4b86a"), { gloss = false })
c:part(c:ellipse(13, 24, 3, 3), GV.ramp("#a4b86a"), { gloss = false })
-- friendly small eyes
c:eye(23, 33); c:eye(34, 33)

local t = c:save(O .. "aseprite/ph/wisp-light.aseprite", O .. "png/ph/wisp-light.png")
print(GV.report(t))
