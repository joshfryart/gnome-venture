local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dark = GV.ramp("#58a03e")
local p = c:build{
  { "top",   c:ellipse(32, 21, 10, 10), dark },
  { "left",  c:ellipse(21, 39, 11, 11), dark },
  { "right", c:ellipse(43, 39, 11, 11), "moss" },
}
-- leaf-wrap arcs: each sprout gets a curved fold line plus a short side leaf
local L = "#2f5a2a"
local function arc(pts) for _, q in ipairs(pts) do c:px(q[1], q[2], L) end end
-- top sprout
arc({ {33,12},{34,13},{35,14},{35,15},{36,16},{36,17},{36,18},{36,19},{36,20},{36,21},{36,22},{35,23},{35,24},{34,25},{33,26},{32,27} })
arc({ {27,14},{26,15},{25,16},{25,17},{24,18},{24,19} })
arc({ {28,25},{29,26},{30,27} })
-- left sprout
arc({ {22,29},{23,30},{24,31},{25,32},{25,33},{26,34},{26,35},{26,36},{26,37},{26,38},{26,39},{26,40},{26,41},{25,42},{25,43},{24,44},{23,45},{22,46},{21,47} })
arc({ {15,33},{14,34},{13,35},{13,36},{12,37},{12,38} })
arc({ {16,44},{17,45},{18,46} })
-- right sprout
arc({ {44,29},{45,30},{46,31},{47,32},{47,33},{48,34},{48,35},{48,36},{48,37},{48,38},{48,39},{48,40},{48,41},{47,42},{47,43},{46,44},{45,45},{44,46},{43,47} })
arc({ {37,33},{36,34},{35,35},{35,36},{34,37},{34,38} })
arc({ {38,44},{39,45},{40,46} })
-- pale stem nubs
c:paint({ "sss", "sss" }, 20, 49, { s = "#a4b86a" })
c:paint({ "sss", "sss" }, 42, 49, { s = "#a4b86a" })
local t = c:save(O .. "aseprite/ph/brussels-sprouts.aseprite", O .. "png/ph/brussels-sprouts.png")
print(GV.report(t))
