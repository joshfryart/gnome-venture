local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:ellipse(31.5, 40, 20, 16)
local ears = c:ellipse(25, 15, 4, 3.5):add(c:ellipse(38, 15, 4, 3.5))
ears:add(c:poly({ {27, 13}, {37, 13}, {35, 21}, {29, 21} }))
local neck = c:poly({ {23, 28}, {41, 28}, {36, 19}, {28, 19} })

local p = c:build{
  { "ears", ears, GV.ramp("#f4f0e0") },
  { "neck", neck, GV.ramp("#e8d8b0"), { gloss = false } },
  { "body", body, GV.ramp("#f4f0e0"), { stitch = { side = "lit" } } },
  { "tie", c:rect(25, 23, 39, 24), GV.ramp("#8c4a1a"), { flat = true } },
  { "ends", c:line({ {30, 25}, {28, 31} }, 2):add(c:line({ {33, 25}, {35, 31} }, 2)), GV.ramp("#8c4a1a"), { flat = true } },
  { "knob", c:rrect(30, 22, 33, 25, 1), GV.ramp("#8c4a1a"), { flat = true } },
  { "patch", c:rrect(20, 34, 43, 50, 6), GV.ramp("#3f93b2"), { gloss = false, contact = false } },
  { "patchin", c:rrect(22, 36, 41, 48, 5), GV.ramp("#f4f0e0"), { gloss = false, contact = false, rim = false } },
  { "seed", c:ellipse(31.5, 42, 5.5, 5.5), GV.ramp("#3f93b2", { shade = "#256a80" }), { gloss = { 29, 39 } } },
}
c:part(c:ascii({ ".gg.", "gggg", ".gg." }, 34, 35), GV.ramp("#58a03e"), { flat = true })
c:paint({ "f..", ".f.", ".f.", "..f" }, 20, 30, { f = "#dcb06a" })
c:paint({ "..f", ".f.", ".f.", "f.." }, 41, 30, { f = "#dcb06a" })
c:seam({ {24, 50}, {40, 50} })
local t = c:save(O .. "aseprite/ph/goldenrod-seed.aseprite", O .. "png/ph/goldenrod-seed.png")
print(GV.report(t))
