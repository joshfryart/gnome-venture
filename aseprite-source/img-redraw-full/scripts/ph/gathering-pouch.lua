local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- belly: round-bottomed sack, wider than neck
local belly = c:ellipse(31.5, 44, 20, 13)
belly:add(c:poly({ {21, 29}, {43, 29}, {50, 38}, {14, 38} }))
-- ruffle neck: three puckered lobes
local neck = c:ellipse(24, 23, 4.5, 4):add(c:ellipse(31.5, 21, 4.5, 4.5)):add(c:ellipse(39, 23, 4.5, 4))
neck:add(c:rect(21, 24, 42, 30))
local band = c:rect(19, 28, 44, 30)
local p = c:build{
  { "belly", belly, GV.ramp("#c08a3a"), { stitch = { side = "lit" } } },
  { "neck",  neck,  GV.ramp("#c4925f") },
  { "band",  band,  "gold", { flat = true } },
}
-- puckers on ruffle
c:paint({ "d", "d", "d" }, 28, 23, { d = "#8a4f2a" })
c:paint({ "d", "d", "d" }, 35, 23, { d = "#8a4f2a" })
c:seam({ {20, 29}, {44, 29} })
-- bow: two loops + tails
local bow = c:mask()
bow:add(c:rrect(21, 21, 28, 28, 2)):add(c:rrect(35, 21, 42, 28, 2))
bow:cut(c:rect(24, 24, 26, 25)):cut(c:rect(37, 24, 39, 25))
bow:add(c:line({ {30, 31}, {27, 37} }, 2)):add(c:line({ {33, 31}, {36, 37} }, 2))
c:part(bow, "gold", { flat = true, contact = false })
c:outline(bow)
c:button(30, 27)
-- fold lines on belly
c:paint({ "d...", ".dd.", "...d" }, 20, 44, { d = "#5e2f1e" })
c:paint({ "...d", ".dd.", "d..." }, 40, 46, { d = "#5e2f1e" })
c:paint({ "d.d", ".d." }, 30, 51, { d = "#5e2f1e" })
c:ground(31.5, 57, 16, 1.5)
local t = c:save(O .. "aseprite/ph/gathering-pouch.aseprite", O .. "png/ph/gathering-pouch.png")
print(GV.report(t))
