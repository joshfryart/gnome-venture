local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:rect(20, 13, 44, 56)
local flap = c:poly({ {20, 13}, {45, 13}, {32.5, 29} })
local p = c:build{
  { "body", body, GV.ramp("#f1ece0"), { gloss = { 22, 31 } } },
  { "flap", flap, GV.ramp("#dcb06a"), { gloss = { 24, 15 } } },
}
-- edge stitches down the envelope sides
c:seam({ {22, 31}, {22, 54} }); c:seam({ {42, 31}, {42, 54} })
-- label
c:part(c:rrect(25, 34, 39, 51, 3), GV.ramp("#f08a24"), { flat = true })
c:part(c:rrect(26, 35, 38, 50, 3), GV.ramp("#f4f0e0"), { gloss = false, rim = false })
c:part(c:ellipse(32, 43.5, 5, 5), GV.ramp("#f08a24"), { gloss = { 29, 41 } })
c:part(c:rect(32, 36, 33, 38), GV.ramp("#2e5a2c"), { flat = true })
c:part(c:poly({ {34, 36}, {37, 35}, {38, 36}, {36, 39}, {34, 39} }), GV.ramp("#58a03e"), { flat = true })
-- flap seam and button
c:seam({ {21, 14}, {32, 27}, {44, 14} })
c:button(31, 25)
-- tab top right
c:part(c:poly({ {45, 8}, {51, 16}, {40, 16} }), GV.ramp("#2e5a2c"), { gloss = false })
local t = c:save(D .. "img-redraw-full/aseprite/ph/orange-seed.aseprite", D .. "img-redraw-full/png/ph/orange-seed.png")
print(GV.report(t))
