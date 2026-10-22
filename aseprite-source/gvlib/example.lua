-- example.lua : a felt toadstool sticker drawn with gvlib (64x64, sticker mode)
-- Run: "C:\Program Files\Aseprite\Aseprite.exe" -b --script example.lua
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/"
local GV = dofile(D .. "gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- shapes (pixel indices)
local stem = c:rrect(23, 30, 40, 50, 5)
local cap  = c:ellipse(31.5, 27, 20, 13):cut(c:rect(0, 32, 63, 63)) -- upper half-dome
cap:add(c:rrect(12, 26, 51, 33, 3))                                   -- thick brim

-- parts, back to front: shading, rim, bounce, gloss, contour, contact shadow are automatic
c:part(stem, GV.R.skin)
c:part(cap, GV.R.red, { stitch = { side = "lit" } })

-- markings: bean spots with a glaze glint
c:spot(c:ellipse(24, 20, 2, 1.5)); c:spot(c:ellipse(37, 17, 2.5, 2)); c:spot(c:ellipse(44, 25, 2, 1.5))

-- stitched join: seam along the brim with a button at its head
c:seam({ {16, 31}, {48, 31} })
c:button(29, 29)

-- face on the stem: locked eyes set wide, 1 px smile
c:eye(25, 38); c:eye(34, 38)
c:paint({ "u...u", ".uuu." }, 29, 45, { u = "umber" })

c:ground(31.5, 52, 13, 1.5)
local t = c:save(D .. "test/example.aseprite", D .. "test/example.png")
print(GV.report(t))
