-- trek-wallcap-n: moss ridge half on the TOP edge of the lower tile; seam row y0 (42x5 overlay)
local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(R .. "gvlib/gvlib.lua")
local M8, MSH, MB, M6, MRIM, TH, TH2 = "#2f5a2a", "#4a8a3e", "#7ab55c", "#4f9a45", "#a4b86a", "#f5cf6a", "#e8a317"
local function st(t) return t >= 8 and t <= 33 and (t - 8) % 3 ~= 2 end   -- 2 on / 1 off from 8 (8-9, 11-12, ... 32-33)
local c = GV.canvas{ w = 42, h = 5, mode = "scene" }
for x = 7, 34 do
  c:px(x, 0, st(x) and TH or MSH)             -- seam row: thread stitch, mo_shade between
  c:px(x, 1, MSH); c:px(x, 2, M8); c:px(x, 3, M8); c:px(x, 4, MSH)
end
for _, x in ipairs({ 6, 35 }) do c:px(x, 1, MSH); c:px(x, 2, M8); c:px(x, 3, MSH) end   -- round ends (y1..3)
for _, p in ipairs({ {12,2},{22,2} }) do for j = 0, 1 do for i = 0, 1 do c:px(p[1]+i, p[2]+j, M6) end end end
c:px(28, 1, MB); c:px(9, 1, MRIM)
local P = R .. "trek-pixel/"
print(GV.report(c:save(P .. "aseprite/trek-wallcap-n.aseprite", P .. "png/trek-wallcap-n.png")))
