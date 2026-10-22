local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tapered hook: discs along a cubic bezier, radius shrinking
local function bez(t, p0, p1, p2, p3)
  local u = 1 - t
  return u*u*u*p0 + 3*u*u*t*p1 + 3*u*t*t*p2 + t*t*t*p3
end
local hook = c:mask()
local P = { {26,42}, {16,22}, {30,6}, {47,14} }
for i = 0, 60 do
  local t = i / 60
  local x = bez(t, P[1][1], P[2][1], P[3][1], P[4][1])
  local y = bez(t, P[1][2], P[2][2], P[3][2], P[4][2])
  local r = 4.6 - 2.6 * t
  hook:add(c:ellipse(x, y, r, r))
end
-- sharp barb pointing down
local barb = c:poly({ {43,15}, {51,16}, {48,30} })
hook:add(barb)

-- segmented bulb base
local bulb = c:ellipse(28, 47, 12, 8.5)

local p = c:build{
  { "hook", hook, GV.ramp("#b07a45") },
  { "bulb", bulb, GV.ramp("#a5663a") },
}
-- segment rings on bulb (arcs)
for _, yy in ipairs({ 43, 50 }) do
  local arc = c:ellipse(28, yy + 6, 11, 6):cut(c:ellipse(28, yy + 8, 11, 6)):clip(bulb:shrink(1))
  c:fill(arc, "#5e2f1e")
end
-- segment bands on the hook shaft
for _, t in ipairs({ 0.18, 0.38, 0.58 }) do
  local x = bez(t, P[1][1], P[2][1], P[3][1], P[4][1])
  local y = bez(t, P[1][2], P[2][2], P[3][2], P[4][2])
  local x2 = bez(t + 0.02, P[1][1], P[2][1], P[3][1], P[4][1])
  local y2 = bez(t + 0.02, P[1][2], P[2][2], P[3][2], P[4][2])
  local dx, dy = x2 - x, y2 - y
  local l = math.sqrt(dx*dx + dy*dy); dx, dy = dx / l, dy / l
  local r = 4.6 - 2.6 * t
  local seg = c:line({ { math.floor(x - dy*r + 0.5), math.floor(y + dx*r + 0.5) },
                       { math.floor(x + dy*r + 0.5), math.floor(y - dx*r + 0.5) } }, 1):clip(hook:shrink(1))
  c:fill(seg, "#8a4f2a")
end
-- dark barb tip
c:fill(c:poly({ {45,22}, {50,22}, {48,30} }):clip(hook), "#5e2f1e")

-- venom bead dripping from the tip
local bead = c:ellipse(48, 35, 3.5, 3.5)
bead:add(c:rect(48, 30, 48, 31))
c:part(bead, "moss", { gloss = { 47, 34 } })
c:px(46, 33, "#c8d77a")

local t = c:save(O .. "aseprite/ph/scorpion-stinger.aseprite", O .. "png/ph/scorpion-stinger.png")
print(GV.report(t))
