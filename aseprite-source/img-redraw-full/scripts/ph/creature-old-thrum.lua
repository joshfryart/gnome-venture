local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local legR = GV.ramp("#5a3424")
local barrel = c:rrect(14, 24, 49, 47, 8)
local hoop = c:ellipse(31.5, 24, 17.5, 6)
local skin = c:ellipse(31.5, 23.5, 14, 4)
local p = c:build{
  { "armL", c:line({ {14, 34}, {9, 29}, {7, 25} }, 3), legR, { flat = true } },
  { "armR", c:line({ {49, 34}, {54, 29}, {56, 25} }, 3), legR, { flat = true } },
  { "legL", c:line({ {20, 45}, {17, 50}, {12, 53} }, 3), legR, { flat = true } },
  { "legR", c:line({ {43, 45}, {46, 50}, {51, 53} }, 3), legR, { flat = true } },
  { "tick", c:line({ {28, 9}, {31, 17}, {32, 17}, {35, 9} }, 3), GV.ramp("#f08a24"), { flat = true } },
  { "barrel", barrel, GV.ramp("#a5663a"), { stitch = false } },
  { "base", c:rect(14, 41, 49, 47):clip(barrel), GV.ramp("#8c4a1a"), { gloss = false, light = barrel } },
  { "hoop", hoop, GV.ramp("#8c4a1a"), { gloss = false } },
  { "skin", skin, GV.ramp("#ecd09a"), { gloss = { 22, 21 } } },
}
-- seam between barrel and base hoop
c:seam({ {15, 41}, {48, 41} })
-- lashing star across drum skin
c:seam({ {19, 24}, {44, 24} })
c:seam({ {24, 21}, {39, 26} })
c:seam({ {39, 21}, {24, 26} })
c:button(30, 22)
-- staves
for _, x in ipairs({ 20, 43 }) do
  for y = 31, 38 do c:px(x, y, "#8a4f2a") end
end
-- eyes, sleepy lids
c:eye(21, 32); c:eye(37, 32)
c:paint({ ".uuu.", "lllll" }, 21, 31, { l = "#8a4f2a", u = "#4a2c1a" })
c:paint({ ".uuu.", "lllll" }, 37, 31, { l = "#8a4f2a", u = "#4a2c1a" })
-- belly smile
c:paint({ "u.....u", ".uuuuu." }, 28, 39, { u = "#4a2c1a" })
c:ground(31.5, 55, 19, 1.5)
local t = c:save(O .. "aseprite/ph/creature-old-thrum.aseprite", O .. "png/ph/creature-old-thrum.png")
print(GV.report(t))
