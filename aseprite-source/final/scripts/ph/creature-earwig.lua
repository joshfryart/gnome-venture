local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local Y = -2
local function P(t) local r = {} for i, v in ipairs(t) do r[i] = { v[1], v[2] + Y } end return r end
-- legs (bent, thin)
c:limb(P{ {26,40}, {20,39}, {15,35} })
c:limb(P{ {25,45}, {19,46}, {14,49} })
c:limb(P{ {27,50}, {21,52}, {17,56} })
c:limb(P{ {37,40}, {43,39}, {48,35} })
c:limb(P{ {38,45}, {44,46}, {49,49} })
c:limb(P{ {36,50}, {42,52}, {46,56} })
-- antennae
c:limb(P{ {27,27}, {24,24}, {22,22} })
c:limb(P{ {36,27}, {39,24}, {41,22} })
local body = c:ellipse(31.5, 45 + Y, 10.5, 11)
local head = c:ellipse(31.5, 30 + Y, 7, 6)
local pl = c:line(P{ {28,25}, {26,22}, {26,18}, {27,15}, {29,14} }, 3)
local pr = c:line(P{ {35,25}, {37,22}, {37,18}, {36,15}, {34,14} }, 3)
pl:cut(head); pr:cut(head)
local back = c:rect(31, 36 + Y, 32, 55 + Y):clip(body)
local p = c:build{
  { "clubL", c:rrect(19, 19 + Y, 22, 22 + Y, 1), "dusk", { flat = true } },
  { "clubR", c:rrect(41, 19 + Y, 44, 22 + Y, 1), "dusk", { flat = true } },
  { "body", body, GV.ramp("#a5663a") },
  { "back", back, "dusk", { flat = true, contour = false } },
  { "pincL", pl, "dusk", { gloss = false } },
  { "pincR", pr, "dusk", { gloss = false } },
  { "head", head, GV.ramp("#8c4a1a") },
}
c:seam(P{ {31, 37}, {31, 54} })
c:eye(27, 28 + Y, true); c:eye(34, 28 + Y, true)
-- grumpy brows
c:paint({ "aa.", "..a" }, 26, 26 + Y, { a = "#2a1a10" })
c:paint({ ".aa", "a.." }, 35, 26 + Y, { a = "#2a1a10" })
local t = c:save(O .. "aseprite/ph/creature-earwig.aseprite", O .. "png/ph/creature-earwig.png")
print(GV.report(t))
