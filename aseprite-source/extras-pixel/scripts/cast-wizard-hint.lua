-- Wizard hint: Old Wizard holds a brass lantern out in his left hand (staff stays in the right). Helpful smile.
local K = dofile("/home/user/gnome-venture/aseprite-source/extras-pixel/scripts/cast-common.lua")
local GV = K.GV
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dx, dy = 0, 4
local body, arms, hat, beard = K.wizardShapes(c, dx, dy)
local staff = c:rect(52, 15, 53, 54)
local ball = c:ellipse(52.5, 12, 3, 3)

-- lantern hangs from the left hand: loop, cap, glass box, foot
local lx, ly = 7, 40                                               -- top-left of the lantern cap
local cap = c:rrect(lx, ly, lx+9, ly+2, 1); cap:add(c:rrect(lx+3, ly-3, lx+6, ly-1, 1))
local glass = c:rrect(lx+1, ly+3, lx+8, ly+12, 1)
local foot = c:rrect(lx, ly+13, lx+9, ly+15, 1)
local flame = c:ellipse(lx+4.5, ly+8, 2, 3)

c:build{
  { "staff", staff, "wood", { flat = true } },
  { "ball",  ball,  "gold", {} },
  { "arms",  arms,  K.WIZ_ARM, { flat = true } },
  { "body",  body,  K.WIZ_BODY, { stitch = { side = "lit" } } },
  { "beard", beard, K.WIZ_BEARD, { gloss = { 26+dx, 41+dy-4 } } },
  { "hat",   hat,   K.WIZ_HAT, { gloss = { 29+dx, 10+dy-4 } } },
  { "foot",  foot,  "gold", { flat = true } },
  { "glass", glass, GV.ramp("#fff1c8", { pale = true, dot = "#fff3c8" }), { gloss = false, contour = false } },
  { "cap",   cap,   "gold", { flat = true } },
  { "flame", flame, GV.ramp("#f08a24"), { gloss = { lx+3, ly+6 }, contour = false, contact = false } },
}
-- hands: right grips the staff, left pinches the loop
c:paint({ "aaaa", "aaaa", "aaaa" }, 50, 40, { a = "#f08a24" }); c:px(50, 40, "#ffc27a")
c:paint({ "aaaa", "aaaa" }, lx+3, ly-5, { a = "#f08a24" }); c:px(lx+3, ly-5, "#ffc27a")
c:fill(c:rect(lx+4, ly+7, lx+5, ly+9), "#ffc27a"); c:px(lx+4, ly+6, "#fff1c8")   -- flame core
-- hint sparkles: three gold glints popping out of the lantern
c:paint({ "..g..", "..g..", "gg.gg", "..g..", "..g.." }, lx+11, ly+1, { g = "#f5cf6a" })
c:paint({ ".g.", "ggg", ".g." }, lx+12, ly+9, { g = "#fff1c8" })
K.wizardFace(c, dx, dy-4)
K.save(c, "wizard-hint")
