local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local paper = GV.ramp("#f1ece0")
local flapR = GV.ramp("#f4f0e0")
local bud = GV.ramp("#7a5cc0", { shade = "#4e3a8a" })
local p = c:build{
  { "env", c:rrect(21, 11, 43, 53, 2), paper },
  { "flap", c:poly({ {21, 11}, {44, 11}, {32.5, 27} }), flapR, { gloss = false } },
}
c:seam({ {22, 12}, {32, 26} }); c:seam({ {43, 12}, {33, 26} })
c:part(c:ellipse(32.5, 27.5, 3, 3), "red", { gloss = { 31, 26 } })
-- bud with stem and leaf
c:part(c:line({ {32, 44}, {32, 50} }, 2), "#2f5a2a", { flat = true })
c:part(c:poly({ {34, 45}, {37, 42}, {41, 42}, {38, 46}, {35, 47} }), "#7ab55c", { gloss = false })
c:part(c:ellipse(32.5, 39, 5, 5.5), bud)
c:paint({ "v.v", ".v." }, 31, 34, { v = bud.shade })

local t = c:save(O .. "aseprite/ph/tiare-seed.aseprite", O .. "png/ph/tiare-seed.png")
print(GV.report(t))
