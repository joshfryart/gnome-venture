local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(32, 40, 19, 15)
local whole = body:copy(); whole:add(c:rrect(15, 22, 49, 28, 2))
c:build{
  { "knob", c:ellipse(32, 11, 4, 4), "gold" },
  { "lid",  c:ellipse(32, 19, 15, 6), GV.ramp("#8fcbd8") },
  { "body", body, "water", { light = whole } },
  { "rim",  c:rrect(15, 22, 49, 28, 2), GV.ramp("#5a86b8") },
}
local root = c:poly({ {27, 37}, {39, 37}, {32.5, 53} })
root:add(c:ellipse(32.5, 38, 6, 2.5))
c:part(c:line({ {31, 37}, {26, 31} }, 3), "#58a03e", { flat = true })
c:part(c:line({ {34, 37}, {39, 31} }, 3), "#58a03e", { flat = true })
c:part(root, GV.ramp("#f1ece0"), { contour = "#4a2c1a", gloss = { 29, 39 } })
c:paint({ "u..", ".u.", "..u" }, 33, 42, { u = "#c9a96e" })
c:paint({ "u.", ".u" }, 30, 47, { u = "#c9a96e" })
c:seam({ {16, 25}, {48, 25} })
c:button(30, 17)
c:ground(32, 57, 15, 1.5)
local t = c:save(O .. "aseprite/ph/daikon-seed.aseprite", O .. "png/ph/daikon-seed.png")
print(GV.report(t))
