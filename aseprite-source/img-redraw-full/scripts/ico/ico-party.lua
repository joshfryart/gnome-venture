local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local tip = { 12, 52 }
local cone = c:poly({ tip, { 21, 29 }, { 35, 43 } })
local whole = cone:copy()
c:build{
  { "red",    c:poly({ tip, { 21, 29 }, { 26, 34 } }), GV.ramp("#9c2a1e"), { light = whole } },
  { "orange", c:poly({ tip, { 26, 34 }, { 31, 39 } }), GV.ramp("#e8892a"), { light = whole, gloss = false } },
  { "yellow", c:poly({ tip, { 31, 39 }, { 35, 43 } }), GV.ramp("#f2cf4a"), { light = whole, gloss = false } },
  { "rim",    c:line({ { 21, 29 }, { 34, 42 } }, 4), GV.ramp("#b6814d"), { gloss = false } },
}
c:fill(c:line({ { 21, 29 }, { 33, 41 } }, 1), "#f0d49a")
c:part(c:line({ { 29, 26 }, { 33, 19 }, { 36, 15 }, { 40, 15 }, { 44, 18 }, { 48, 16 }, { 53, 12 } }, 3), GV.ramp("#d9667f"), { flat = true })
c:part(c:line({ { 38, 35 }, { 44, 32 }, { 50, 31 }, { 53, 34 }, { 53, 38 }, { 55, 42 } }, 3), GV.ramp("#3f93b2"), { flat = true })
c:part(c:ellipse(35, 10, 2.5), GV.ramp("#f2cf4a"), { flat = true })
c:part(c:ellipse(46, 8, 2.5), GV.ramp("#3f93b2"), { flat = true })
c:part(c:ellipse(51.5, 23.5, 2.5), GV.ramp("#7ab55c"), { flat = true })
c:part(c:ellipse(48, 44, 2.5), GV.ramp("#e46a9b"), { flat = true })
c:part(c:ellipse(27, 15, 2.5), GV.ramp("#dd3a2a"), { flat = true })
c:part(c:poly({ { 42, 21 }, { 46, 25 }, { 42, 29 }, { 38, 25 } }), GV.ramp("#f2cf4a"), { flat = true })
local t = c:save(O .. "aseprite/ico/ico-party.aseprite", O .. "png/ico/ico-party.png")
print(GV.report(t))
