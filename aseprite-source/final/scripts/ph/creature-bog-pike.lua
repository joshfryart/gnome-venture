local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fin = GV.ramp("#58a03e")
local skin = GV.ramp("#b0bc66")
-- forked tail on the left
local tail = c:poly({ {8,24}, {19,33}, {19,38}, {8,47}, {11,35.5} })
-- dorsal fin, swept back
local dorsal = c:poly({ {22,28}, {28,20}, {33,19}, {36,22}, {38,28} })
-- long torpedo body, head tapering right
local body = c:ellipse(30.5, 35, 21, 9.5)
body:add(c:poly({ {40,27}, {50,29}, {52,33}, {52,41}, {40,44} }))
-- belly band
local belly = c:ellipse(30.5, 40, 16, 4):clip(body)
-- upper jaw (long flat snout)
local ujaw = c:poly({ {44,28}, {52,29}, {57,32}, {57,34}, {44,34} })
-- lower jaw, dropped open
local ljaw = c:poly({ {44,37}, {55,37}, {54,40}, {44,41} })
local p = c:build{
  { "tail", tail, fin, { cres = 3 } },
  { "dorsal", dorsal, fin, { cres = 2 } },
  { "body", body, skin, { stitch = { side = "lit" } } },
  { "belly", belly, "cream", { gloss = false } },
  { "ljaw", ljaw, skin, { flat = true } },
  { "ujaw", ujaw, skin, { gloss = false } },
}
-- open mouth gap and teeth
c:fill(c:rect(46, 34, 56, 36), GV.C.ol3)
c:paint({ "cc.cc.cc.c", ".c..c..c.." }, 47, 34, { c = "#f8eed2" })
c:paint({ "c..c..c.", }, 47, 36, { c = "#f8eed2" })
-- gill stripes
c:fill(c:rect(38, 32, 39, 39), fin.base)
c:fill(c:rect(35, 33, 36, 39), fin.base)
-- fin rays on dorsal
c:px(29, 23, fin.shade); c:px(30, 24, fin.shade); c:px(33, 23, fin.shade); c:px(34, 24, fin.shade)
-- belly seam
c:seam({ {16, 37}, {44, 37} })
c:eye(42, 29)
local t = c:save(O .. "aseprite/ph/creature-bog-pike.aseprite", O .. "png/ph/creature-bog-pike.png")
print(GV.report(t))
