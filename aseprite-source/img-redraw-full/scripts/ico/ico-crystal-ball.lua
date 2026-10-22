local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local foot = c:poly({ {14, 57}, {50, 57}, {44, 46}, {20, 46} })
local rim = c:rrect(19, 42, 45, 49, 2)
local orb = c:ellipse(32, 26, 18, 18)

c:build{
  { "foot", foot, GV.ramp("#b8893f") },
  { "rim",  rim,  GV.ramp("#e8a317") },
  { "orb",  orb,  GV.ramp("#a9d6ea"), { gloss = { 21, 15 } } },
}

-- mist swirl inside the orb
local mist = c:line({ {20, 29}, {24, 26}, {28, 25}, {32, 28}, {36, 31}, {40, 29}, {43, 26} }, 3)
mist:clip(orb:shrink(3))
c:fill(mist, "#c8ecdc")
local mist2 = c:line({ {24, 35}, {28, 33}, {32, 35}, {36, 37} }, 2)
mist2:clip(orb:shrink(3))
c:fill(mist2, "#8fcbd8")

-- star sparkle (5x5 plus)
c:paint({
  "..s..",
  "..s..",
  "sssss",
  "..s..",
  "..s..",
}, 36, 15, { s = "#fff1c8" })

c:seam({ {22, 47}, {43, 47} })

local t = c:save(O .. "aseprite/ico/ico-crystal-ball.aseprite", O .. "png/ico/ico-crystal-ball.png")
print(GV.report(t))
