local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- smooth smile curve: (10,44) -> (22,52) -> (40,44) -> (52,20)
local function bez(t)
  local u = 1 - t
  local P = { {10,43}, {20,56}, {42,52}, {51,19} }
  local x = u*u*u*P[1][1] + 3*u*u*t*P[2][1] + 3*u*t*t*P[3][1] + t*t*t*P[4][1]
  local y = u*u*u*P[1][2] + 3*u*u*t*P[2][2] + 3*u*t*t*P[3][2] + t*t*t*P[4][2]
  return x, y
end
local body = c:mask()
local N = 40
for i = 0, N do
  local t = i / N
  local x, y = bez(t)
  -- fatter in the middle, tapering to the ends
  local r = 2.5 + 3.5 * math.sin(math.pi * t)
  body:add(c:ellipse(x, y, r, r))
end

local stem = c:poly({ {48,22}, {51,10}, {56,11}, {54,24} })
local tip = c:ellipse(10.5, 43.5, 2.5, 2.5)

local p = c:build{
  { "stem", stem, "moss" },
  { "body", body, "gold", { gloss = { 17, 45 } } },
  { "tip", tip, GV.ramp("#5e2f1e"), { flat = true } },
}
-- dark cap on stem top
c:fill(c:poly({ {50,9}, {57,10}, {56,13}, {50,12} }), "#2f5a2a")

-- lengthwise umber ridge along the belly
for i = 6, 34 do
  local t = i / N
  local x, y = bez(t)
  local r = 2.5 + 3.5 * math.sin(math.pi * t)
  -- normal pointing down-right (outer belly)
  local x2, y2 = bez(t + 0.01)
  local dx, dy = x2 - x, y2 - y
  local l = math.sqrt(dx*dx + dy*dy)
  local nx, ny = dy / l, -dx / l
  if ny < 0 then nx, ny = -nx, -ny end
  local px, py = math.floor(x + nx * (r * 0.45) + 0.5), math.floor(y + ny * (r * 0.45) + 0.5)
  if p.body.m:has(px, py) then c:px(px, py, "#8a4f2a") end
end

c:ground(31.5, 56, 12, 1.5)
local t = c:save(O .. "aseprite/ph/banana.aseprite", O .. "png/ph/banana.png")
print(GV.report(t))
