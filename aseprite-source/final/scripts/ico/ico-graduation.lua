local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-hybrid/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- cap base (skullcap) with rounded V bottom
local base = c:poly({ {18,28}, {47,28}, {47,44}, {40,49}, {32,52}, {25,49}, {18,44} })
base:add(c:ellipse(32, 46, 13, 5))
base:cut(c:rect(0, 0, 63, 27))
local board = c:poly({ {32,11}, {56,23}, {32,35}, {8,23} })
local edge = board:shift(0, 3)
local cord = c:line({ {49,24}, {49,39} }, 3)
local knot = c:ellipse(49, 40, 3, 2.5)
local fringe = c:poly({ {46,42}, {53,42}, {56,54}, {43,54} })
local p = c:build{
  { "base",   base,   GV.ramp("#44506a", { rim = "#7b66b4" }) },
  { "edge",   edge,   GV.ramp("#291d4a", { rim = "#3e2f66" }), { gloss = false } },
  { "board",  board,  "dusk", { light = board:copy():add(edge) } },
  { "cord",   cord,   GV.ramp("#f5cf6a"), { flat = true } },
  { "knot",   knot,   "gold", { gloss = false } },
  { "fringe", fringe, "gold" },
}
-- cord running across the board from the button to the corner
c:fill(c:line({ {33,23}, {41,23}, {48,24} }, 2), "#f5cf6a")
c:fill(c:line({ {34,25}, {47,25} }, 1), "#e8a317")
-- fringe strands
for _, x in ipairs({ 46, 49, 52 }) do
  c:fill(c:line({ {x,45}, {x + (x-49)//3, 52} }, 1), "#b8661a")
end
c:button(30, 21)
-- seam along the base hem
c:seam({ {20,42}, {44,42} })
local t = c:save(O .. "aseprite/ico/ico-graduation.aseprite", O .. "png/ico/ico-graduation.png")
print(GV.report(t))
