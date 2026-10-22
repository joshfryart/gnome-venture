local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dark = GV.ramp("#4a8a3e")
local soilTop = c:ellipse(31.5, 43, 16, 4.5)
local floor = c:rect(0, 44, 63, 63)
local function clump(cx, cy, r)
  return c:ellipse(cx, cy, r, r):cut(floor)
end
local p = c:build{
  { "mound", c:ellipse(31.5, 46, 20, 7), GV.ramp("#8c4a1a") },
  { "top", soilTop, GV.ramp("#a5663a"), { gloss = false } },
  { "c1", clump(17, 39.5, 5.5), "moss" },
  { "c5", clump(46, 39.5, 5.5), "moss" },
  { "c2", clump(24, 36.5, 5.5), dark },
  { "c4", clump(39, 36.5, 5.5), dark },
  { "c3", clump(31.5, 33, 6), "moss" },
}
-- leaf veins (small v ticks) on each clump
local V = { v = "#2f5a2a" }
c:paint({ "v.v", ".v." }, 16, 40, V)
c:paint({ "v.v", ".v." }, 45, 40, V)
c:paint({ "v.v", ".v." }, 23, 36, V)
c:paint({ "v.v", ".v." }, 38, 36, V)
c:paint({ "v.v", ".v." }, 31, 34, V)
-- soil pebbles
c:px(19, 49, "#5e2f1e"); c:px(42, 50, "#5e2f1e"); c:px(29, 51, "#5e2f1e")
local t = c:save(O .. "aseprite/ph/stage-herb-3.aseprite", O .. "png/ph/stage-herb-3.png")
print(GV.report(t))
