local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local red = GV.ramp("#9c2a1e")
local cream = GV.ramp("#f8eed2")

local pole = c:rect(9, 9, 13, 56)
local knob = c:ellipse(11, 9, 3, 3)
pole:add(knob)
local cord = c:rect(14, 18, 17, 20)
local seg1 = c:poly({ {17, 17}, {30, 20}, {30, 43}, {17, 46} })
local seg2 = c:poly({ {30, 20}, {41, 23}, {41, 40}, {30, 43} })
local seg3 = c:poly({ {41, 23}, {51, 26}, {51, 37}, {41, 40} })
local tail = c:poly({ {51, 26}, {58, 20}, {54, 31}, {58, 43}, {51, 37} })

local p = c:build{
  { "pole", pole, GV.ramp("#c4925f", { rim = "#d9a660" }) },
  { "seg3", seg3, red },
  { "tail", tail, red, { gloss = false } },
  { "seg2", seg2, cream },
  { "seg1", seg1, red, { light = seg1:copy():add(seg2):add(seg3) } },
}
-- dark open mouth ring at the head
local mouth = c:ellipse(18, 31.5, 3, 12)
c:part(mouth, GV.ramp("#3a2418"), { gloss = false, rim = false })
c:fill(c:ellipse(18.5, 31.5, 1, 9), "#2a1a10")

c:eye(23, 24)
c:seam({ {30, 21}, {30, 42} })
c:seam({ {41, 24}, {41, 39} })

local t = c:save(O .. "aseprite/ico/ico-carp-streamer.aseprite", O .. "png/ico/ico-carp-streamer.png")
print(GV.report(t))
