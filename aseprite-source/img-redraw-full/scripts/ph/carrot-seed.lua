local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local glass = GV.ramp("#a9d6ea", { rim = "#c8ecdc" })
local p = c:build{
  { "jar",   c:rrect(17, 21, 46, 54, 7), glass, { gloss = false } },
  { "neck",  c:rrect(22, 15, 41, 23, 2), glass, { gloss = false } },
  { "cork",  c:rrect(23, 6, 40, 16, 3), "wood" },
  { "topL",  c:line({ {31, 29}, {28, 25}, {26, 21} }, 3), "#58a03e", { flat = true } },
  { "topR",  c:line({ {32, 29}, {35, 25}, {37, 21} }, 3), "#58a03e", { flat = true } },
  { "carrot", c:poly({ {25, 28}, {39, 28}, {35, 45}, {32, 51}, {29, 45} }), "#f08a24" },
}
-- carrot ridges
c:fill(c:rect(27, 34, 30, 34), "#e0501f")
c:fill(c:rect(33, 39, 36, 39), "#e0501f")
c:fill(c:rect(29, 44, 31, 44), "#e0501f")
-- cork speckles
c:px(27, 9, "#a8582f"); c:px(34, 8, "#a8582f"); c:px(30, 12, "#a8582f"); c:px(37, 12, "#a8582f")
-- seeds at the jar bottom
c:paint({ ".s.", "sss", ".s." }, 21, 48, { s = "#8c4a1a" })
c:paint({ ".s.", "sss", ".s." }, 38, 48, { s = "#8c4a1a" })
c:paint({ ".s.", "sss" }, 24, 50, { s = "#8c4a1a" })
-- glass highlight stripe
c:fill(c:rect(20, 26, 21, 36), "#e6f7f0")
c:fill(c:rect(20, 39, 21, 40), "#e6f7f0")
c:seam({ {23, 18}, {40, 18} })
c:ground(31.5, 55, 15, 1.5)
local t = c:save(O .. "aseprite/ph/carrot-seed.aseprite", O .. "png/ph/carrot-seed.png")
print(GV.report(t))
