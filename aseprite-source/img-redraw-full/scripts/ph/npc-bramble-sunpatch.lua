local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local disc  = c:ellipse(40, 48, 33, 33)
local tunic = c:ellipse(39.5, 100, 34, 24):clip(c:rect(0, 0, 79, 99))
local shirt = c:poly({ {30, 77}, {50, 77}, {40, 88} })
local face  = c:ellipse(40, 54, 22, 20)
local dark  = face:copy():clip(c:rect(0, 0, 79, 47)):cut(c:ellipse(40, 53, 15, 7))
local cap   = c:ellipse(40, 41, 24, 15):cut(c:rect(0, 42, 79, 99))
local bud   = c:ellipse(40, 25, 3, 3)
local leaf  = c:poly({ {42, 27}, {47, 21}, {54, 20}, {51, 25}, {45, 28} })

local p = c:build{
  { "disc",  disc,  GV.ramp("#e6d2ae") },
  { "tunic", tunic, "gold" },
  { "shirt", shirt, "cream", { gloss = false } },
}
c:build{
  { "antL", c:line({ {31, 32}, {25, 24}, {20, 19} }, 2), "dusk", { flat = true } },
  { "antR", c:line({ {48, 32}, {54, 24}, {59, 19} }, 2), "dusk", { flat = true } },
  { "clubL", c:rrect(17, 15, 20, 18, 1), "dusk", { flat = true } },
  { "clubR", c:rrect(59, 15, 62, 18, 1), "dusk", { flat = true } },
  { "face",  face,  "red" },
  { "dark",  dark,  "dusk", { gloss = false } },
  { "leaf",  leaf,  GV.ramp("#2e5a2c"), { flat = true } },
  { "bud",   bud,   GV.ramp("#2e5a2c"), { gloss = false } },
  { "cap",   cap,   GV.ramp("#58a03e"), { stitch = { side = "lit" } } },
}
-- face details
c:eye(30, 49); c:eye(46, 49)
c:paint({ "u.........u", ".uuuuuuuuu." }, 35, 61, { u = "#2a1a10" })
c:spot(c:ascii({ ".x.", "xxx", ".x." }, 24, 63))
c:spot(c:ascii({ ".x.", "xxx", ".x." }, 53, 63))
c:spot(c:ascii({ ".x.", "xxx", ".x." }, 39, 67))
-- tunic joins
c:button(38, 88)
c:seam({ {40, 93}, {40, 99} })
c:seam({ {30, 78}, {39, 87} }); c:seam({ {50, 78}, {41, 87} })

local t = c:save(O .. "aseprite/ph/npc-bramble-sunpatch.aseprite", O .. "png/ph/npc-bramble-sunpatch.png")
print(GV.report(t))
