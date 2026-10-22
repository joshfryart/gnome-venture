local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fur = GV.ramp("#a5663a")
local cream = GV.ramp("#dcb06a")
local flip = GV.ramp("#8c4a1a")
-- flipper feet splayed outward
local fl = c:ellipse(20, 52, 8, 3.5):add(c:ellipse(43, 52, 8, 3.5))
local body = c:ellipse(31.5, 40, 18, 14)
local belly = c:ellipse(31.5, 44, 10, 8):clip(body)
local head = c:ellipse(31.5, 24, 13, 12)
local muzzle = c:ellipse(31.5, 29, 8, 5)
c:build{
  { "flip", fl, flip },
  { "body", body, fur, { stitch = { side = "lit" } } },
  { "belly", belly, cream, { gloss = false } },
  { "head", head, fur },
  { "muzzle", muzzle, cream, { gloss = false } },
}
-- nose
c:paint({ ".nnnn.", "nnnnnn", ".nnnn." }, 29, 25, { n = "#2a1a10" })
c:px(30, 25, "#5e2a3a")
-- eyes (sleepy-cheerful, locked)
c:eye(22, 18); c:eye(37, 18)
-- smile
c:paint({ "s....s", ".ssss." }, 29, 31, { s = "#2a1a10" })
-- whiskers fanning past the head
local W = "#2a1a10"
for x = 10, 24 do c:px(x, 28, W) end
for x = 39, 53 do c:px(x, 28, W) end
c:paint({ "ww.........", "..www......", ".....www...", "........ww." }, 13, 30, { w = W })
c:paint({ ".........ww", "......www..", "...www.....", ".ww........" }, 40, 30, { w = W })
local t = c:save(O .. "aseprite/ph/creature-salt-sea-lion.aseprite", O .. "png/ph/creature-salt-sea-lion.png")
print(GV.report(t))
