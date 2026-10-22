local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leaf = function(x, y, rx, ry) return c:ellipse(x, y, rx or 4, ry or 2.5) end
local dark = GV.ramp("#4a8a3e")
local mid  = GV.ramp("#5e9e44")
local pod  = GV.ramp("#8cc85e")
local p = c:build{
  { "mound", c:ellipse(31.5, 50, 18, 5.5), GV.ramp("#7a4a1f") },
  { "stake", c:rect(43, 11, 44, 46), GV.ramp("#4a2c1a"), { flat = true } },
  { "vine",  c:line({ {30,47}, {33,42}, {37,36}, {40,29}, {42,22}, {43,14} }, 2), "leaf", { flat = true } },
  { "l1",    leaf(24, 43, 4.5, 2.5), mid },
  { "l2",    leaf(32, 34, 4.5, 2.5), dark },
  { "l3",    leaf(49, 27), mid },
  { "l4",    leaf(36, 20), dark },
  { "l5",    leaf(48, 14, 3.5, 2.5), mid },
  { "pod1",  c:line({ {37,38}, {39,47} }, 5), pod },
  { "pod2",  c:line({ {49,33}, {50,43} }, 5), pod },
  { "pod3",  c:line({ {36,23}, {37,32} }, 5), pod },
}
c:fill(c:ellipse(31.5, 46.5, 13, 1.5):clip(p.mound.m), "#9a6b3f")
-- pea bumps along each pod
for _, q in ipairs({ {38,41}, {38,45}, {50,36}, {50,40}, {37,26}, {37,30} }) do c:px(q[1]+1, q[2], pod.shade) end
local t = c:save(O .. "aseprite/ph/stage-legume-4.aseprite", O .. "png/ph/stage-legume-4.png")
print(GV.report(t))
