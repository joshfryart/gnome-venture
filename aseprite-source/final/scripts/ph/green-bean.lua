local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- centreline of the crescent pod (lower-left to upper-right, bowing up-left)
local pts = { {16,46,3}, {17,41,4}, {20,36,5}, {24,31,5.5}, {29,27,6}, {35,24,6}, {41,22,5.5}, {46,21,5}, {50,21,4}, {53,22,3} }
local pod = c:mask()
for i = 1, #pts - 1 do
  local a, b = pts[i], pts[i+1]
  for s = 0, 4 do
    local t = s / 4
    local x = a[1] + (b[1]-a[1])*t; local y = a[2] + (b[2]-a[2])*t; local r = a[3] + (b[3]-a[3])*t
    pod:add(c:ellipse(x, y, r, r))
  end
end
-- three bean bumps on the back (upper-left side)
local bumps = c:ellipse(20, 29, 4.5, 4):add(c:ellipse(28, 22, 4.5, 4)):add(c:ellipse(38, 18, 4.5, 4))
pod:add(bumps)
local tail = c:line({ {16, 49}, {14, 52}, {11, 53}, {9, 51}, {9, 49} }, 2)
local cap = c:rrect(52, 18, 56, 22, 1)
local P = c:build{
  { "tail", tail, GV.ramp("#4a8a3e"), { flat = true } },
  { "pod", pod, GV.ramp("#7ab55c", { rim = "#a4b86a", shade = "#4a8a3e", deep = "#2f5a2a" }), { gloss = { 22, 25 } } },
  { "cap", cap, "wood", { gloss = false } },
}
-- bean bump outlines: subtle shade arcs on lower-right of each bump
for _, b in ipairs({ {20,29}, {28,22}, {38,18} }) do
  local e = c:ellipse(b[1], b[2], 4.5, 4)
  local inner = c:ellipse(b[1]-1, b[2]-1, 4.5, 4)
  e:cut(inner):each(function(x, y) if P.pod.m:has(x, y) and P.pod.m:has(x+1,y+1) then c:px(x, y, "#6a9a3a") end end)
end
-- ridge along the inner (belly) curve
for _, q in ipairs({ {19,44},{20,42},{21,40},{22,38},{24,36},{25,35},{27,33},{28,32},{30,31},{32,30},{34,29},{36,28},{38,27},{40,27},{42,26},{44,26},{46,26},{48,26} }) do
  c:px(q[1], q[2], "#a4b86a")
end
c:seam({ {20, 41}, {23, 36}, {29, 31}, {37, 27}, {48, 25} })
local t = c:save(O .. "aseprite/ph/green-bean.aseprite", O .. "png/ph/green-bean.png")
print(GV.report(t))
