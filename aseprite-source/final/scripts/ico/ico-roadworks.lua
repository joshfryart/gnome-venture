local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- two splayed posts with feet
local legL = c:poly({ {14,34}, {21,34}, {20,52}, {13,52} })
legL:add(c:rrect(9, 50, 23, 54, 1))
local legR = c:poly({ {43,34}, {50,34}, {51,52}, {44,52} })
legR:add(c:rrect(41, 50, 55, 54, 1))
local board = c:rrect(8, 16, 56, 37, 3)
-- diagonal stripes, clipped to the board
local stripes = c:mask()
stripes:add(c:poly({ {16,16}, {25,16}, {16,38}, {7,38} }))
stripes:add(c:poly({ {32,16}, {41,16}, {32,38}, {23,38} }))
stripes:add(c:poly({ {48,16}, {57,16}, {48,38}, {39,38} }))
stripes:clip(board)
local white = board:copy():cut(stripes)

local p = c:build{
  { "legs",  legL:copy():add(legR), GV.ramp("#b07a45") },
  { "board", board, GV.ramp("#f8eed2") },
}
-- stripes painted with a red ramp, lit to the board's light
local red = GV.R.red
c:part(stripes, "red", { light = board, rim = true, gloss = false, contour = false, contact = false })
c:gloss(white, GV.ramp("#f8eed2"), { 12, 19 })
c:seam({ {10,34}, {54,34} })
-- bolts where the board meets the posts
c:button(15, 38); c:button(44, 38)
local t = c:save(O .. "aseprite/ico/ico-roadworks.aseprite", O .. "png/ico/ico-roadworks.png")
print(GV.report(t))
