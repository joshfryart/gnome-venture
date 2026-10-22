local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tall lumpy sack, wider slumped bottom
local sack = c:poly({ {16,28}, {21,25}, {43,25}, {48,28}, {50,36}, {52,48}, {51,53}, {46,56}, {18,56}, {13,53}, {12,48}, {14,36} })
sack:add(c:ellipse(32, 52, 19, 4))
-- crimped ear-flap neck above the tie
local flapL = c:poly({ {19,26}, {20,17}, {23,14}, {26,18}, {29,26} })
local flapR = c:poly({ {35,26}, {38,18}, {41,14}, {44,17}, {45,26} })
local neck = c:rrect(24, 19, 40, 26, 2)
-- protea bud: pointed, with a couple of bracts
local bud = c:poly({ {32,6}, {37,11}, {40,16}, {39,21}, {25,21}, {24,16}, {27,11} })
local leafL = c:poly({ {21,12}, {27,15}, {29,21}, {24,21} })
local leafR = c:poly({ {43,12}, {37,15}, {35,21}, {40,21} })
local tie = c:rrect(18, 25, 46, 28, 1)

local tan = GV.ramp("#c9a96e")
local brn = GV.ramp("#9a6b3f")
local p = c:build{
  { "leaves", leafL:copy():add(leafR), "leaf", { flat = true } },
  { "bud",  bud,  "moss" },
  { "neck", neck, brn },
  { "flapL", flapL, brn, { light = flapL:copy():add(flapR) } },
  { "flapR", flapR, brn, { light = flapL:copy():add(flapR) } },
  { "sack", sack, tan, { stitch = { side = "lit" } } },
  { "tie",  tie,  "#d9a660", { gloss = false } },
}
-- bud bract lines (protea petals)
c:fill(c:line({ {32,9}, {32,19} }, 2), "#2f5a2a")
c:paint({ "v.......v", ".v.....v.", "..v...v.." }, 28, 13, { v = "#4a8a3e" })
-- twine knot + tails
local knot = c:rrect(30, 24, 34, 29, 1)
c:part(knot, "#b07a45", { flat = true })
-- re-fill tails with twine colour
c:fill(c:line({ {31,30}, {27,36} }, 2), "#b07a45")
c:fill(c:line({ {34,30}, {38,36} }, 2), "#b07a45")
c:px(26, 37, "#d9a660"); c:px(39, 37, "#d9a660")
-- label patch
local lab = c:rrect(24, 39, 40, 50, 2)
c:part(lab, "cream", { gloss = false, contact = false })
c:fill(c:ellipse(32, 44.5, 3, 3), "#6a9a3a")
c:fill(c:ellipse(31, 43.5, 1, 1), "#a4b86a")
c:seam({ {25,48}, {39,48} })
-- burlap weave marks
c:paint({ "w.w", ".w." }, 17, 36, { w = "#7a4a1f" })
c:paint({ "w.w", ".w." }, 43, 38, { w = "#7a4a1f" })
c:paint({ "w.w", ".w." }, 19, 50, { w = "#7a4a1f" })
c:paint({ "w.w", ".w." }, 42, 50, { w = "#7a4a1f" })
-- seam on twine
c:seam({ {19,26}, {45,26} })
c:ground(32, 57, 17, 1)
local t = c:save(O .. "aseprite/ph/king-protea-seed.aseprite", O .. "png/ph/king-protea-seed.png")
print(GV.report(t))
