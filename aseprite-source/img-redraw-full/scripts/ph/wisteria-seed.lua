local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local purple = GV.ramp("#7b66b4", { shade = "#5a4890", deep = "#3e2f66" })
-- pear-shaped pouch body
local body = c:ellipse(30.5, 41, 17, 13)
body:add(c:poly({ {22, 26}, {39, 26}, {44, 36}, {17, 36} }))
-- ruffled top above the cinch
local ruffle = c:poly({ {22, 13}, {39, 13}, {35, 24}, {26, 24} })
ruffle:add(c:ellipse(23.5, 15, 3, 3)); ruffle:add(c:ellipse(30.5, 13.5, 3, 3)); ruffle:add(c:ellipse(37.5, 15, 3, 3))
local band = c:rrect(23, 23, 38, 26, 1)
local p = c:build{
  { "body", body, purple, { stitch = { side = "lit" } } },
  { "ruffle", ruffle, purple },
  { "band", band, "cream", { flat = true } },
}
-- drawstring tails
c:part(c:line({ {28, 27}, {25, 35} }, 2), "cream", { flat = true })
c:part(c:line({ {33, 27}, {37, 35} }, 2), "cream", { flat = true })
c:part(c:ellipse(24.5, 36.5, 1.5, 1.5), "cream", { flat = true })
c:part(c:ellipse(37.5, 36.5, 1.5, 1.5), "cream", { flat = true })
c:button(29, 23)
-- hanging wisteria sprig
c:part(c:line({ {41, 28}, {45, 31} }, 2), "leaf", { flat = true })
local bl = GV.ramp("#a894dc")
c:part(c:ellipse(45.5, 33, 2.5, 2.5), bl, { flat = true })
c:part(c:ellipse(47, 38.5, 2.5, 2.5), bl, { flat = true })
c:part(c:ellipse(44.5, 43.5, 2, 2), bl, { flat = true })
c:part(c:ellipse(48.5, 44, 2, 2), bl, { flat = true })
c:part(c:ellipse(46.5, 48.5, 1.5, 1.5), bl, { flat = true })
c:seam({ {31, 38}, {31, 52} })
c:ground(31.5, 55, 15, 1.5)
local t = c:save(O .. "aseprite/ph/wisteria-seed.aseprite", O .. "png/ph/wisteria-seed.png")
print(GV.report(t))
