local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local legR = GV.ramp("#3a404e")
local under = GV.ramp("#2f3440")
local dome = GV.ramp("#4a5160")
local head = GV.ramp("#959aa3")
local legs = c:rrect(11, 37, 14, 46, 1)
legs:add(c:rrect(18, 38, 21, 46, 1))
legs:add(c:rrect(28, 38, 31, 46, 1))
legs:add(c:rrect(35, 37, 38, 46, 1))
local crest = c:line({ {22, 12}, {24, 17} }, 2):add(c:line({ {27, 12}, {25, 17} }, 2))
local horns = c:line({ {47, 31}, {50, 27} }, 2):add(c:line({ {42, 31}, {42, 27} }, 2))
local shell = c:ellipse(24.5, 37, 14, 19):cut(c:rect(0, 37, 63, 63))
local hd = c:ellipse(45.5, 35.5, 6, 6):add(c:rrect(36, 34, 44, 41, 2))
c:build{
  { "legs", legs, legR, { flat = true } },
  { "crest", crest, "gold", { flat = true } },
  { "under", c:ellipse(24.5, 37.5, 15, 3.5), under },
  { "dome", shell, dome },
  { "horns", horns, head, { flat = true } },
  { "head", hd, head },
}
-- cracks
local cr = "#2f3440"
c:paint({ "x","x",".","x","x","x",".","x","x","x","x",".","x","x" }, 24, 20, { x = cr })
c:paint({ "x.", "x.", "x.", ".x", ".x", "x.", "x." }, 17, 25, { x = cr })
c:paint({ ".x", "x.", "x.", "x.", ".x", ".x" }, 31, 27, { x = cr })
-- violet veins
c:paint({ "vvv.....", "...vvvv." , ".......v"}, 12, 31, { v = "#8f7fc9" })
c:paint({ "vv....", "..vvv.", ".....v" }, 27, 25, { v = "#8f7fc9" })
c:paint({ "p..", ".p.", "..p" }, 19, 21, { p = "#d8d0f5" })
c:seam({ { 11, 37 }, { 38, 37 } })
c:eye(46, 33, true)
c:paint({ "mmm" }, 48, 38, { m = "#4a2c1a" })
c:ground(25, 47, 16, 1.5)
local t = c:save(O .. "aseprite/ph/creature-old-gneiss.aseprite", O .. "png/ph/creature-old-gneiss.png")
print(GV.report(t))
