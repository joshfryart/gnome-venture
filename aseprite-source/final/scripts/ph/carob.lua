local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- pod: tapered banana curve along a quadratic bezier
local P0, P1, P2 = {12,44}, {24,16}, {54,20}
local function bz(t)
  local a, b, d = (1-t)^2, 2*(1-t)*t, t^2
  return a*P0[1]+b*P1[1]+d*P2[1], a*P0[2]+b*P1[2]+d*P2[2]
end
local pod = c:mask()
for i = 0, 40 do
  local t = i / 40
  local x, y = bz(t)
  local r = 2.5 + 4.5 * math.sin(math.pi * (0.1 + 0.85 * t))
  pod:add(c:ellipse(x, y, r, r))
end
-- bean bumps along the top edge
local bumps = c:mask()
local seam = {}
for _, t in ipairs({0.3, 0.47, 0.64, 0.8}) do
  local x, y = bz(t)
  bumps:add(c:ellipse(x - 1, y - 4, 3.5, 3))
end
for i = 2, 20 do local x, y = bz(i/22); seam[#seam+1] = {math.floor(x+1.5), math.floor(y+2.5)} end
pod:add(bumps)
local stem = c:line({{13,44},{10,48},{7,49}}, 3)
local p = c:build{
  { "stem", stem, "moss", { flat = true } },
  { "pod",  pod,  GV.ramp("#8a4f2a", { rim = "#d9a660", deep = "#5e2f1e" }), { gloss = {22,25} } },
}
-- bean bulges as soft lighter ovals inside
for _, t in ipairs({0.3, 0.47, 0.64, 0.8}) do
  local x, y = bz(t)
  c:fill(c:ellipse(x - 1, y - 2.5, 2.5, 2):clip(p.pod.m:shrink(2)), "#a8582f")
end
-- seam line along the belly
c:fill(c:line(seam, 1):clip(p.pod.m:shrink(1)), "#2a1a10")
local t = c:save(O .. "aseprite/ph/carob.aseprite", O .. "png/ph/carob.png")
print(GV.report(t))
