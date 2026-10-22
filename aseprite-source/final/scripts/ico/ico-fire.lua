local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/"
local GV = dofile(D .. "gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local R = GV.R
local outer = c:ellipse(32, 42, 15, 13):add(c:poly({ {17,40},{17,30},{19,22},{22,15},{24,20},{27,26},{28,18},{31,11},{34,7},{37,11},{41,18},{45,26},{48,34},{48,42} }))
local inner = c:ellipse(32, 47.5, 8, 7.5):add(c:poly({ {25,45},{28,40},{32,33},{36,40},{40,45} }))
c:build{
  { "outer", outer, GV.ramp("#e86a1f", { shade = "#dd3a2a", deep = "#ae2a2a", bounce = "#c8452f" }), { gloss = { 23, 32 } } },
  { "inner", inner, GV.ramp("#f2b830", { rim = "#f5cf6a" }), { contact = false } },
}
c:fill(c:ellipse(30, 47, 1.5, 2.5):add(c:rect(30, 43, 30, 44)), "#fff1c8")
local t = c:save(O .. "aseprite/ico/ico-fire.aseprite", O .. "png/ico/ico-fire.png")
print("ico-fire " .. GV.report(t))
