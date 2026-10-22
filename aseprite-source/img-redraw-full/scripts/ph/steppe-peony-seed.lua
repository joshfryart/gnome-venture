local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local p = c:build{
  { "foot",  c:rrect(22, 50, 42, 55, 1), GV.ramp("#b8661a"), { gloss = false } },
  { "belly", c:ellipse(32, 38, 18, 15), "gold", { gloss = { 21, 30 } } },
  { "neck",  c:rect(21, 20, 43, 26), GV.ramp("#d0862a"), { gloss = false } },
  { "lid",   c:rrect(16, 15, 48, 22, 3), GV.ramp("#f5cf6a"), { gloss = false } },
  { "knob",  c:ellipse(32, 10.5, 4, 3.5), "gold" },
  { "bud",   c:ellipse(32, 40, 5, 4.5):add(c:poly({ {29, 37}, {35, 37}, {32, 33} })), "petal", { gloss = { 30, 38 } } },
}
-- leaves either side of the bud
c:part(c:ellipse(24.5, 43, 3, 1.5), "moss", { flat = true })
c:part(c:ellipse(39.5, 43, 3, 1.5), "moss", { flat = true })
c:paint({ "s...s", ".s.s." }, 30, 43, { s = "#6a9a3a" }); c:px(32, 39, "#b8452f"); c:px(32, 40, "#b8452f")
-- lid seam with button
c:seam({ {22, 23}, {44, 23} }, { free = true })
c:ground(32, 57, 16, 2)
local t = c:save(O .. "aseprite/ph/steppe-peony-seed.aseprite", O .. "png/ph/steppe-peony-seed.png")
print(GV.report(t))
