local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local pink = GV.ramp("#f6b8cf")
local hatR = GV.ramp("#d6322b")
local brimR = GV.ramp("#9c2a1e")
local fur = "gold"
local coat = c:ellipse(39.5, 100, 34, 24):cut(c:rect(0, 0, 79, 75))
local cone = c:poly({ {17, 43}, {22, 34}, {32, 20}, {41, 11}, {48, 7}, {50, 12}, {54, 24}, {59, 34}, {64, 43} })
local p = c:build{
  { "back", c:ellipse(40, 50, 36), pink, { gloss = false, stitch = { side = "lit" } } },
  { "coat", coat, GV.ramp("#d0862a") },
  { "earL", c:ellipse(23, 37, 11), fur },
  { "earR", c:ellipse(57, 37, 11), fur },
  { "head", c:ellipse(40, 54, 21, 18), fur },
  { "muz",  c:ellipse(40, 62, 12, 8.5), GV.ramp("#f5cf6a"), { gloss = false } },
  { "brim", c:ellipse(40, 43, 28, 4.5), brimR, { gloss = false } },
  { "cone", cone, hatR },
}
-- inner ears (visible outside the cone)
c:fill(c:ellipse(20, 36, 6):clip(p.earL.m):cut(p.cone.m:grow(1)):cut(p.brim.m:grow(1)), "#f6b8cf")
c:fill(c:ellipse(60, 36, 6):clip(p.earR.m):cut(p.cone.m:grow(1)):cut(p.brim.m:grow(1)), "#f6b8cf")
-- collar V
c:paint({
  "s.........s",
  ".s.......s.",
  "..s.....s..",
  "...s...s...",
  "....s.s....",
  ".....s.....",
}, 35, 77, { s = "#b8661a" })
-- tip notch
c:px(48, 8, "#5e1a14"); c:px(48, 9, "#5e1a14")
-- lit stripe on cone
c:fill(c:line({ {24, 38}, {32, 25} }, 1):clip(p.cone.m), "#ff9158")
-- brim hem
c:seam({ {14, 43}, {66, 43} })
-- eyes
c:eye(29, 49); c:eye(47, 49)
-- nose & smile
c:paint({ ".nnn.", "nnnnn", ".nnn." }, 38, 57, { n = "#d9667f" })
c:px(38, 57, "#f0a0b0")
c:paint({ "u.....u", ".uu.uu.", "...u..." }, 37, 62, { u = "umber" })
-- whiskers
c:paint({ "wwwwwww" }, 18, 61, { w = "#74462a" })
c:paint({ "wwwwwww" }, 55, 61, { w = "#74462a" })
c:paint({ "..www", "ww..." }, 21, 64, { w = "#74462a" })
c:paint({ "www..", "...ww" }, 55, 64, { w = "#74462a" })
local t = c:save(O .. "aseprite/ph/npc-kestrel-petalwing.aseprite", O .. "png/ph/npc-kestrel-petalwing.png")
print(GV.report(t))
