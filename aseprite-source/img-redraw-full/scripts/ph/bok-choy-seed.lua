local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local burlap = GV.ramp("#d9a660")
local neckR  = GV.ramp("#b07a45")
local twine  = GV.ramp("#a8582f")

-- frill lobes
local frill = c:poly({ {20,9}, {28,13}, {32,19}, {25,20} })
frill:add(c:poly({ {44,9}, {36,13}, {32,19}, {39,20} }))
frill:add(c:ellipse(24, 13, 4, 3.5)):add(c:ellipse(40, 13, 4, 3.5))
frill:add(c:ellipse(32, 14, 3, 4))
-- neck
local neck = c:poly({ {26,17}, {38,17}, {36,27}, {28,27} })
-- sack body
local sack = c:ellipse(32, 40, 19, 16)

c:build{
  { "frill", frill, burlap },
  { "neck",  neck,  neckR },
  { "sack",  sack,  burlap, { stitch = { side = "lit" } } },
}

-- twine band + knot + tails
local tw = c:rect(26, 21, 38, 22)
c:part(tw, twine, { flat = true })
c:part(c:rrect(30, 20, 34, 24, 1), twine, { flat = true })
c:part(c:line({ {31,25}, {28,30} }, 2), twine, { flat = true })
c:part(c:line({ {34,25}, {37,30} }, 2), twine, { flat = true })

-- leaf emblem
local leaf = c:poly({ {32,28}, {39,34}, {40,41}, {35,49}, {32,51}, {29,49}, {24,41}, {25,34} })
c:part(leaf, "leaf", { gloss = {28,35}, contact = false })
c:line({ {32,31}, {32,52} }, 2):each(function(x, y) c:px(x, y, "#2f5a2a") end)
c:line({ {31,38}, {27,35} }, 1):each(function(x, y) c:px(x, y, "#4a8a3e") end)
c:line({ {34,40}, {37,37} }, 1):each(function(x, y) c:px(x, y, "#4a8a3e") end)
c:line({ {31,44}, {27,42} }, 1):each(function(x, y) c:px(x, y, "#4a8a3e") end)
c:line({ {34,46}, {37,44} }, 1):each(function(x, y) c:px(x, y, "#4a8a3e") end)

c:ground(32, 56, 15, 1.5)

local t = c:save(O .. "aseprite/ph/bok-choy-seed.aseprite", O .. "png/ph/bok-choy-seed.png")
print(GV.report(t))
