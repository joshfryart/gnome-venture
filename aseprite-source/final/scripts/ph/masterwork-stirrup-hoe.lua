local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local handle = c:poly({ {12,51},{16,54},{39,22},{35,20} })
local blade = c:poly({ {32,8},{56,8},{51,20},{37,20} })
local p = c:build{
  { "handle", handle, GV.ramp("#b07a45", { rim = "#d9a660", bounce = "#a8582f" }), { gloss = false } },
  { "knob",   c:ellipse(13, 53, 3, 3), GV.ramp("#a8582f"), { gloss = false } },
  { "blade",  blade, GV.ramp("#e8a317", { gloss = "#fff1c8", shade = "#b8661a" }), { gloss = { 36, 10 } } },
  { "collar", c:rrect(34, 19, 41, 22, 1), GV.ramp("#d0862a"), { gloss = false } },
}
c:fill(c:rect(39, 13, 49, 14), "#7a3a14")
c:ground(30, 57, 17, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/masterwork-stirrup-hoe.aseprite", D .. "img-redraw-full/png/ph/masterwork-stirrup-hoe.png")
print(GV.report(t))
