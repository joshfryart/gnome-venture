local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- strap handle: thick arch above the bag
local strap = c:ellipse(31.5, 27, 14, 17):cut(c:ellipse(31.5, 27, 9, 12)):cut(c:rect(0, 27, 63, 63))
local body = c:rrect(9, 25, 54, 57, 8)
local flap = c:rrect(9, 25, 54, 41, 7):cut(c:rect(0, 42, 63, 63))
-- flap has a rounded lower lip in the middle
flap:add(c:ellipse(31.5, 40, 12, 4):cut(c:rect(0, 0, 63, 37)))
local buckle = c:rrect(26, 36, 37, 47, 2)

local p = c:build{
  { "strap", strap, GV.ramp("#b6814d") },
  { "body", body, GV.ramp("#a5663a") },
  { "flap", flap, GV.ramp("#8c4a1a"), { light = body } },
  { "buckle", buckle, "gold" },
}
-- buckle hole / tongue
c:fill(c:rect(30, 40, 33, 43), "#b07a10")
c:fill(c:rect(31, 41, 32, 42), "#7a3a14")
-- strap rivets where it meets the bag
c:fill(c:rect(19, 25, 21, 27), "#e8a317")
c:fill(c:rect(42, 25, 44, 27), "#e8a317")
-- stitch along flap edge and a pocket seam
c:seam({ {13, 39}, {20, 41}, {24, 43} })
c:seam({ {40, 43}, {43, 41}, {50, 39} })
c:seam({ {14, 52}, {49, 52} })

local t = c:save(D .. "img-redraw-full/aseprite/ico/ico-satchel.aseprite", D .. "img-redraw-full/png/ico/ico-satchel.png")
print(GV.report(t))
