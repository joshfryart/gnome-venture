local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- hinge knuckles on the back top edge (behind the lid)
local hinge = c:rrect(13, 11, 18, 16, 1):add(c:rrect(45, 11, 50, 16, 1))
local body = c:rrect(10, 26, 53, 54, 4)
-- lid sits proud: 2 px wider each side, slightly ajar (tilted up at left)
local lid = c:poly({ {8, 16}, {56, 18}, {56, 28}, {8, 28} }):clip(c:rrect(8, 14, 55, 27, 4))
lid:add(c:rrect(8, 18, 55, 27, 3))
local label = c:rrect(18, 32, 45, 51, 5)

local p = c:build{
  { "hinge", hinge, GV.ramp("#5b6470"), { flat = true } },
  { "body",  body,  GV.ramp("#c9c5bc") },
  { "lid",   lid,   GV.ramp("#8b8f96") },
  { "label", label, GV.ramp("#f1ece0"), { pale = true } },
}
-- darker bottom band on the tin
c:fill(c:rect(13, 52, 50, 52), GV.ramp("#c9c5bc").shade)
-- ajar gap on the right half of the lid seam
c:fill(c:rect(33, 27, 52, 27), "#2a1a10")

-- label rim
c:fill(c:rrect(18, 32, 45, 51, 5):cut(c:rrect(20, 34, 43, 49, 3)), "#b0bc66")
-- seed emblem
local moss = GV.ramp("#a4b86a")
c:part(c:ellipse(31.5, 42.5, 6.5, 6), moss)
c:fill(c:rect(31, 34, 32, 37), "#4a8a3e")
c:fill(c:ellipse(35.5, 35, 2, 1.5), "#7ab55c")
c:px(34, 34, "#c8d77a")

c:seam({ {12, 28}, {29, 28} })
c:button(30, 25)

c:ground(31.5, 57, 17, 3)
local t = c:save(O .. "aseprite/ph/miss-joaquim-seed.aseprite", O .. "png/ph/miss-joaquim-seed.png")
print(GV.report(t))
