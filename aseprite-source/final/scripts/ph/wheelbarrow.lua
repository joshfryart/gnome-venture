local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- handles: long bar behind tray reaching right, plus a back leg
local handle = c:line({ {30, 27}, {54, 34} }, 4)
local leg = c:line({ {33, 38}, {40, 50} }, 3)
handle:add(leg)
-- tray: wide trapezoid, open top
local tray = c:poly({ {9, 19}, {46, 19}, {37, 41}, {17, 41} })
local rim = c:rrect(8, 17, 47, 21, 1)
-- wheel at lower left
local wheel = c:ellipse(18, 45, 7.5, 7.5)
local hub = c:ellipse(18, 45, 2.5, 2.5)

local p = c:build{
  { "handle", handle, "wood" },
  { "tray", tray, GV.ramp("#c9c5bc", { shade = "#8b8f96" }) },
  { "rim", rim, GV.ramp("#f1ece0"), { flat = true } },
  { "wheel", wheel, GV.ramp("#5b6470") },
  { "hub", hub, "stone", { flat = true } },
}
-- grip end lighter wrap
c:seam({ {48, 32}, {53, 33} })
-- rivet lines on the tray
c:paint({ "s", ".", ".", "s", ".", ".", "s" }, 20, 25, { s = "#8b8f96" })
c:paint({ "s", ".", ".", "s", ".", ".", "s" }, 32, 25, { s = "#8b8f96" })
c:button(42, 22)
c:ground(28, 54, 16, 1.5)
local t = c:save(O .. "aseprite/ph/wheelbarrow.aseprite", O .. "png/ph/wheelbarrow.png")
print(GV.report(t))
