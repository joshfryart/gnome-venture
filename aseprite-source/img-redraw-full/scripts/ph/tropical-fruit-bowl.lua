local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mound = c:ellipse(31.5, 29, 20, 11):cut(c:rect(0, 31, 63, 63))
local coco = c:ellipse(22.5, 21.5, 6, 6)
local lime = c:ellipse(33, 17, 5, 5)
local mango = c:ellipse(43, 22, 5, 4.5)
local bowl = c:ellipse(31.5, 29, 24, 21):cut(c:rect(0, 0, 63, 29))
bowl:add(c:rrect(14, 44, 49, 50, 3))
local rim = c:rrect(7, 28, 56, 31, 1)
c:build{
  { "mound", mound, GV.ramp("#dcb06a") },
  { "coco",  coco,  GV.ramp("#a5663a") },
  { "lime",  lime,  "moss" },
  { "mango", mango, "gold" },
  { "bowl",  bowl,  GV.ramp("#f4f0e0") },
  { "rim",   rim,   GV.ramp("#d6c9b6"), { gloss = false } },
}
-- coconut eyes, lime/mango leaf nubs
c:paint({ "u.u", "...", ".u." }, 21, 21, { u = "umber" })
c:paint({ "gg", ".g" }, 33, 11, { g = "#2f5a2a" })
c:seam({ {9, 29}, {54, 29} })
c:ground(31.5, 53, 15, 1.5)
local t = c:save(O .. "aseprite/ph/tropical-fruit-bowl.aseprite", O .. "png/ph/tropical-fruit-bowl.png")
print(GV.report(t))
