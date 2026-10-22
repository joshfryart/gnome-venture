local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- hooked fang: wide base bottom, curving up and leaning left to a tip; built from tapering stamps
local fang = c:mask()
local pts = {}
for i = 0, 40 do
  local t = i / 40
  -- bezier base(24,52) -> ctrl(40,30) -> tip(22,9)
  local x = (1-t)^2*24 + 2*(1-t)*t*40 + t*t*22
  local y = (1-t)^2*52 + 2*(1-t)*t*30 + t*t*9
  local r = 6.5 * (1 - t) + 1.0 * t
  fang:add(c:ellipse(x, y, r, r))
  pts[#pts+1] = {x, y, r}
end
fang:cut(c:rect(0, 54, 63, 63))
local root = c:rrect(16, 50, 32, 56, 2)
local ivory = GV.ramp("#f1ece0")
local p = c:build{
  { "root", root, GV.ramp("#a5663a"), { gloss = false } },
  { "fang", fang, ivory, { light = fang, gloss = false } },
  { "drop", c:ellipse(28, 16, 2.5, 3), GV.ramp("#7ab55c"), { flat = true } },
}
-- venom groove along inner (left/concave? inner curve = right side) curve
local g = {}
for i = 6, 28 do local q = pts[i]; g[#g+1] = { math.floor(q[1] + q[3]*0.35 + 0.5), math.floor(q[2] + 0.5) } end
c:fill(c:line(g, 1), "#5e2f1e")
-- highlight streak on left
local h = {}
for i = 4, 24 do local q = pts[i]; h[#h+1] = { math.floor(q[1] - q[3]*0.45 + 0.5), math.floor(q[2] + 0.5) } end
c:fill(c:line(h, 1), "#fff3c8")
c:px(h[4][1], h[4][2], "#ffffff")
-- venom drop at tip
c:px(27, 15, "#c8d77a"); c:px(29, 18, "#4a8a3e"); c:px(28, 19, "#4a8a3e")
local t = c:save(O .. "aseprite/ph/snake-fang.aseprite", O .. "png/ph/snake-fang.png")
print(GV.report(t))
