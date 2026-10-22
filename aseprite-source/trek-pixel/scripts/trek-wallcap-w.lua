-- trek-wallcap-w: vertical moss ridge half on the LEFT edge of the right tile; seam column x0 (5x42 overlay)
local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(R .. "gvlib/gvlib.lua")
local M8, MSH, MB, M6, MRIM, TH, TH2 = "#2f5a2a", "#4a8a3e", "#7ab55c", "#4f9a45", "#a4b86a", "#f5cf6a", "#e8a317"
local function st(t) return t >= 8 and t <= 33 and (t - 8) % 3 ~= 2 end   -- 2 on / 1 off from 8 (8-9, 11-12, ... 32-33)
local c = GV.canvas{ w = 5, h = 42, mode = "scene" }
for y = 7, 34 do
  c:px(0, y, st(y) and TH or MSH)             -- seam column (lit side): thread
  c:px(1, y, MSH); c:px(2, y, M8); c:px(3, y, M8); c:px(4, y, MSH)
end
for _, y in ipairs({ 6, 35 }) do c:px(1, y, MSH); c:px(2, y, M8); c:px(3, y, MSH) end   -- round ends
for _, p in ipairs({ {2,17},{2,29} }) do for j = 0, 1 do for i = 0, 1 do c:px(p[1]+i, p[2]+j, M6) end end end
c:px(3, 10, MB); c:px(1, 9, MRIM)
local P = R .. "trek-pixel/"
print(GV.report(c:save(P .. "aseprite/trek-wallcap-w.aseprite", P .. "png/trek-wallcap-w.png")))
