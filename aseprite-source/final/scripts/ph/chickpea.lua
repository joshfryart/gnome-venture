local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- pod: curved boat from low-left tip to high-right tip
local pod = c:poly({ {10, 40}, {16, 36}, {26, 30}, {38, 24}, {48, 19}, {54, 18},
  {54, 22}, {50, 30}, {42, 38}, {32, 43}, {22, 45}, {14, 44} })
local p = c:build{
  { "stem", c:line({ {8, 41}, {6, 45} }, 3), "#4a8a3e", { flat = true } },
  { "pod", pod, GV.ramp("#f5cf6a", { shade = "#e8a317" }), { gloss = false } },
  { "pea1", c:ellipse(24, 34, 4), "#dcb06a", { gloss = { 22, 32 } } },
  { "pea2", c:ellipse(33.5, 29.5, 4.5), "#dcb06a", { gloss = { 31, 27 } } },
  { "pea3", c:ellipse(43, 25, 4), "#dcb06a", { gloss = { 41, 23 } } },
}
-- groove along the lower lip
c:line({ {15, 41}, {26, 39}, {38, 34}, {48, 27} }, 1)
local g = "#d0862a"
for _, q in ipairs({ {16,41},{17,41},{19,41},{20,40},{22,40},{23,40},{25,39},{26,39},{28,38},{29,38},{31,37},{32,37},{34,36},{35,35},{37,35},{38,34},{40,33},{41,32},{43,31},{44,30},{46,29},{47,28} }) do
  if not p.pea1.m:has(q[1], q[2]) and not p.pea2.m:has(q[1], q[2]) and not p.pea3.m:has(q[1], q[2]) then c:px(q[1], q[2], g) end
end

local t = c:save(O .. "aseprite/ph/chickpea.aseprite", O .. "png/ph/chickpea.png")
print(GV.report(t))
