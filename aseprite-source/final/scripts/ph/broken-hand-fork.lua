local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wood = GV.ramp("#b6814d")
local bar = c:ellipse(34.5, 22, 17.5, 13):cut(c:ellipse(34.5, 20, 11.5, 8)):cut(c:rect(0,0,63,22))
local lt = c:rrect(17,8,22,27,2); lt:add(c:poly({{17,7},{19,4},{22,7}}))
local rt = c:rrect(47,8,52,27,2); rt:add(c:poly({{47,7},{50,4},{52,7}}))
local mt = c:poly({{32,16},{34,14},{35,17},{37,15},{37,33},{32,33}})
local whole = c:mask():add(bar):add(lt):add(rt):add(mt):add(c:rrect(30,30,39,57,4))
local p = c:build{
  { "handle", c:rrect(30,32,39,57,4), wood, { cres = 2, deep = 1 } },
  { "bar", bar, wood, { cres = 2, deep = 1 } },
  { "lt", lt, wood, { cres = 2, deep = 1 } },
  { "rt", rt, wood, { cres = 2, deep = 1 } },
  { "mt", mt, wood, { cres = 2, deep = 1, gloss = false } },
  { "chip", c:poly({{44,45},{51,47},{50,54},{43,52}}), wood, { flat = true } },
  { "splinter", c:poly({{11,40},{16,38},{17,40},{12,42}}), wood, { flat = true } },
}
c:fill(c:line({{36,38},{34,41},{36,44},{33,47},{35,50}}, 1), "#2a1a10")
c:fill(c:line({{35,39},{33,41},{35,44},{32,47}}, 1), "#4a2c1a")
c:px(33,16,"#2a1a10"); c:px(35,17,"#2a1a10")
local t = c:save(O.."aseprite/ph/broken-hand-fork.aseprite", O.."png/ph/broken-hand-fork.png")
print(GV.report(t))
