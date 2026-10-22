local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- back leaves: two curled leaves spreading out left and right
local backL = c:poly({ {30,36}, {16,30}, {8,34}, {10,42}, {18,50}, {30,52} })
local backR = c:poly({ {34,36}, {48,30}, {56,34}, {54,42}, {46,50}, {34,52} })
-- curd: cloud of scallop bumps
local bumps = { {20,22,7}, {27,15,7}, {37,15,7}, {44,22,7}, {32,24,9}, {22,32,7}, {42,32,7}, {32,34,9} }
local curd = c:mask()
for _, b in ipairs(bumps) do curd:add(c:ellipse(b[1], b[2], b[3], b[3] - 0.5)) end
local frontL = c:poly({ {11,37}, {20,40}, {29,44}, {33,54}, {24,55}, {15,49} })
local frontR = c:poly({ {53,37}, {44,40}, {35,44}, {31,54}, {40,55}, {49,49} })
local stalk = c:rrect(28, 51, 36, 56, 1)
local p = c:build{
  { "backL", backL, "#6a9a3a", { gloss = false } },
  { "backR", backR, "#6a9a3a", { gloss = false } },
  { "curd", curd, GV.ramp("#f1ece0", { shade = "#c9a96e" }) },
  { "stalk", stalk, "#a4b86a", { flat = true } },
  { "frontL", frontL, "#7ab55c", { gloss = false } },
  { "frontR", frontR, "#4a8a3e", { gloss = false } },
}
-- curd contours: small arcs inside each bump (lower-right of each floret)
local arcs = {
  { {22,26},{23,26},{24,25},{25,24} },
  { {29,19},{30,19},{31,18} },
  { {39,19},{40,19},{41,18} },
  { {45,26},{46,25},{47,24} },
  { {33,29},{34,29},{35,28},{36,27} },
  { {24,36},{25,36},{26,35} },
  { {43,36},{44,36},{45,35} },
}
for _, a in ipairs(arcs) do for _, q in ipairs(a) do if p.curd.m:has(q[1], q[2]) then c:px(q[1], q[2], "#c9a96e") end end end
-- veins
for _, q in ipairs({ {15,41},{17,42},{19,43},{21,45},{23,47},{25,49},{27,51} }) do c:px(q[1], q[2], "#2f5a2a") end
for _, q in ipairs({ {49,41},{47,42},{45,43},{43,45},{41,47},{39,49},{37,51} }) do c:px(q[1], q[2], "#2f5a2a") end
local t = c:save(O .. "aseprite/ph/cauliflower.aseprite", O .. "png/ph/cauliflower.png")
print(GV.report(t))
