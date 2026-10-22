local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local outer = c:poly({ {32,8},{54,20},{50,46},{32,56},{14,46},{10,20} })
local inner = c:poly({ {32,15},{45,22},{42,40},{32,47},{22,40},{19,22} })
local p = c:build{
  { "outer", outer, GV.ramp("#e46a9b", { rim = "#f6b8cf" }), { gloss = { 17, 22 } } },
  { "inner", inner, "#c2405a", { light = outer, gloss = false } },
}
-- facet lines from inner corners to outer corners
local fl = "#a83a6a"
c:fill(c:line({ {19,22},{12,20} }, 1):clip(outer), fl)
c:fill(c:line({ {45,22},{52,20} }, 1):clip(outer), fl)
c:fill(c:line({ {22,40},{16,45} }, 1):clip(outer), fl)
c:fill(c:line({ {42,40},{48,45} }, 1):clip(outer), fl)
-- centre groove
c:fill(c:rect(31, 9, 32, 54):clip(outer), "#2a1a10")
-- pearl dots
c:px(26, 26, "#f0d49a"); c:px(37, 31, "#f0d49a"); c:px(28, 39, "#f0d49a")
c:ground(32, 58, 14, 1.5)
local t = c:save(O .. "aseprite/ph/tide-shell.aseprite", O .. "png/ph/tide-shell.png")
print(GV.report(t))
