local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local paper = GV.ramp("#f4f0e0", { shade = "#e8d9b0", deep = "#c9a96e" })
local flapR = GV.ramp("#f1ece0", { shade = "#e8d9b0", deep = "#c9a96e" })
local sealR = GV.ramp("#e46a9b", { shade = "#a8241f", gloss = "#f6b8cf" })
local leaf  = GV.ramp("#58a03e")

local sprout = c:ellipse(37, 12, 2.5, 3.5)
sprout:add(c:rect(34, 14, 35, 17))

local env  = c:rrect(21, 16, 43, 54, 2)
local flap = c:poly({ {21, 16}, {44, 16}, {32.5, 31} })

c:build{
  { "sprout", sprout, leaf, { flat = true } },
  { "env",  env,  paper },
  { "flap", flap, flapR, { gloss = false } },
}

-- petal print above the seal
c:fill(c:rrect(24, 33, 26, 35, 1), "#f6b8cf")
c:fill(c:rrect(38, 33, 40, 35, 1), "#f6b8cf")
c:fill(c:rrect(31, 50, 33, 52, 1), "#f6b8cf")

-- pink seal / seed disc
c:part(c:ellipse(32, 42, 6.5, 6.5), sealR)

-- seam along the flap edges, button at the tip
c:seam({ {23, 18}, {31, 29} }); c:seam({ {42, 18}, {34, 29} })
c:button(31, 29)

local t = c:save(O .. "aseprite/ph/martagon-lily-seed.aseprite", O .. "png/ph/martagon-lily-seed.png")
print(GV.report(t))
