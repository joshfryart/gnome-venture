local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glow = c:ellipse(31.5, 32, 21, 20)
c:part(glow, GV.ramp("#ffe08a"), { gloss = false, rim = false, bounce = false, cres = 0, deep = 0 })
c:bands(glow, { "#ffe08a", "#fff6c0" }, { dir = "radial", cx = 31.5, cy = 32, r = 21 })
local p = c:build{
  { "lL", c:poly({ {15, 52}, {18, 32}, {25, 26}, {22, 52} }), GV.ramp("#ffc861"), { gloss = false } },
  { "lR", c:poly({ {22, 52}, {25, 26}, {29, 52} }), GV.ramp("#f2a83a"), { gloss = false } },
  { "rL", c:poly({ {40, 52}, {42, 36}, {49, 32}, {46, 52} }), GV.ramp("#f7b44f"), { gloss = false } },
  { "rR", c:poly({ {46, 52}, {49, 32}, {52, 52} }), GV.ramp("#e8962c"), { gloss = false } },
  { "cL", c:poly({ {26, 52}, {27, 24}, {34, 10}, {34, 52} }), GV.ramp("#ffe08a"), { gloss = { 29, 30 } } },
  { "cR", c:poly({ {34, 52}, {34, 10}, {41, 24}, {42, 52} }), GV.ramp("#ffc447"), { gloss = false } },
}
c:fill(c:line({ {30, 21}, {33, 15} }, 2), "#fff1c8")
c:fill(c:line({ {19, 39}, {20, 35} }, 2), "#fff1c8")
-- sparkle crosses
c:paint({ "...s...", "...s...", "...s...", "sssssss", "...s...", "...s...", "...s..." }, 46, 9, { s = "#fff1c8" })
c:paint({ "..s..", "..s..", "sssss", "..s..", "..s.." }, 11, 17, { s = "#fff1c8" })
c:ground(32, 53, 15, 1.5)
local t = c:save(O .. "aseprite/gather/pick-glint.aseprite", O .. "png/gather/pick-glint.png")
print(GV.report(t))
