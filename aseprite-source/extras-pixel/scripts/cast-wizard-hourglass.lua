-- Wizard hourglass: Old Wizard holds a big hourglass up in his left hand (staff in the right). Time's ticking.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dx, dy = 0, 4
local body, arms, hat, beard = K.wizardShapes(c, dx, dy)
local staff = c:rect(52, 15, 53, 54)
local ball = c:ellipse(52.5, 12, 3, 3)

-- hourglass: wood caps top and bottom, two glass bulbs meeting at a 2 px waist, sand in the lower bulb
local hx, hy = 6, 20                                                 -- top-left of the top cap
local caps = c:rrect(hx, hy, hx+11, hy+2, 1); caps:add(c:rrect(hx, hy+21, hx+11, hy+23, 1))
local glass = c:poly({ {hx+1, hy+3}, {hx+11, hy+3}, {hx+7, hy+11}, {hx+7, hy+13}, {hx+11, hy+21}, {hx+1, hy+21}, {hx+5, hy+13}, {hx+5, hy+11} })
glass:cut(c:poly({ {hx+1, hy+8}, {hx+4, hy+8}, {hx+5, hy+11}, {hx+5, hy+13}, {hx+4, hy+16}, {hx+1, hy+16} }))
glass:cut(c:poly({ {hx+8, hy+8}, {hx+11, hy+8}, {hx+11, hy+16}, {hx+8, hy+16}, {hx+7, hy+13}, {hx+7, hy+11} }))
local sand = c:poly({ {hx+4, hy+18}, {hx+8, hy+18}, {hx+10, hy+21}, {hx+2, hy+21} })
sand:add(c:rect(hx+5, hy+14, hx+6, hy+18))
local sandTop = c:poly({ {hx+3, hy+4}, {hx+9, hy+4}, {hx+7, hy+7}, {hx+5, hy+7} })

c:build{
  { "staff", staff, "wood", { flat = true } },
  { "ball",  ball,  "gold", {} },
  { "arms",  arms,  K.WIZ_ARM, { flat = true } },
  { "body",  body,  K.WIZ_BODY, { stitch = { side = "lit" } } },
  { "beard", beard, K.WIZ_BEARD, { gloss = { 26+dx, 41+dy-4 } } },
  { "hat",   hat,   K.WIZ_HAT, { gloss = { 29+dx, 10+dy-4 } } },
  { "glass", glass, GV.ramp("#8fcbd8"), { gloss = { hx+2, hy+5 }, contour = false } },
  { "sandTop", sandTop, "gold", { flat = true } },
  { "sand",  sand,  "gold", { flat = true } },
  { "caps",  caps,  "wood", { flat = true } },
}
-- hands: right grips the staff, left holds the hourglass by its lower cap
c:paint({ "aaaa", "aaaa", "aaaa" }, 50, 40, { a = "#f08a24" }); c:px(50, 40, "#ffc27a")
c:paint({ "aaaaa", "aaaaa", "aaaaa" }, hx+5, hy+21, { a = "#f08a24" }); c:px(hx+5, hy+21, "#ffc27a")
c:px(hx+6, hy+12, "#f5cf6a")                                         -- grain in the waist
K.wizardFace(c, dx, dy-4)
K.save(c, "wizard-hourglass")
