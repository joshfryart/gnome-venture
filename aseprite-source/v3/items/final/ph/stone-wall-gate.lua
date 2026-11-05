-- stone-wall-gate (lean E2_15)
-- Gateway in the wall: two tall stone posts with overhanging caps and a plank double gate with iron straps and a ring pull.
-- quirk: a yellow flower grows at the foot of the left post, the right gate leaf stands slightly ajar.
local NAME = "stone-wall-gate"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan2 or math.atan
local function clamp(v,a,b) return max(a,min(b,v)) end

local MORT = "#2e2536"
local RAMPS = {
  { "#2f2a3a", "#4e4a60", "#6b6a82", "#8e8ea4", "#b9b9c9" },
  { "#3a2f36", "#5c4d54", "#7e7078", "#a2949a", "#cdc1c4" },
  { "#4a3a34", "#74604f", "#9a8266", "#bda47e", "#e0cba0" },
}
local CAP = { "#4e4458", "#7a6f86", "#a39bb0", "#cbc4d4", "#eee9f2" }
local MOSS = { "#24502e", "#3a7a3c", "#68a84a", "#a2d062" }
local WOOD = { "#3a2218", "#5c3a24", "#7e5232", "#a06c40", "#c48c58" }
local IRON = { "#26232e", "#3e3b4c", "#5c586e", "#8a869c", "#c4c0d0" }
local function stone(x0, y0, x1, y1, ramp, seed)
  for y = y0, y1 do for x = x0, x1 do
    local ex, ey = (x == x0 or x == x1), (y == y0 or y == y1)
    if not (ex and ey) then
      local i = 3
      if y == y0 or x == x0 then i = 4 end
      if y == y0 and x > x0 and x <= x0 + (x1 - x0) * 0.6 then i = 5 end
      if y == y1 or x == x1 then i = 2 end
      if y == y1 and x > x0 + (x1 - x0) * 0.45 then i = 1 end
      local h = X.hash(x, y, seed)
      if i == 3 then if h > 0.88 then i = 4 elseif h < 0.1 then i = 2 end end
      c:put(x, y, ramp[i])
    end
  end end
end
local function face(x0, y0, x1, y1, rowH, seed, wmin, wmax)
  for y = y0, y1 do for x = x0, x1 do c:put(x, y, MORT) end end
  local r, y = 0, y0
  while y <= y1 do
    local ye = min(y + rowH - 2, y1)
    local sx = x0 - floor(X.hash(r, 1, seed) * (wmax - 1))
    while sx <= x1 do
      local w = wmin + floor(X.hash(sx, r, seed + 3) * (wmax - wmin + 1))
      local a, b = max(x0, sx), min(x1, sx + w - 2)
      if b - a >= 2 and ye - y >= 2 then stone(a, y, b, ye, RAMPS[1 + floor(X.hash(sx, r, seed + 7) * 3)], seed + sx + r * 13) end
      sx = sx + w
    end
    y = y + rowH; r = r + 1
  end
end
-- flat top slab of the wall; horiz=true seams are vertical ticks, else horizontal
local function slab(x0, y0, x1, y1, seed, horiz)
  for y = y0, y1 do for x = x0, x1 do
    local i = 3
    if y == y0 then i = 5 elseif y == y0 + 1 then i = 4 end
    if x == x0 then i = max(i, 4) end
    if x == x1 then i = min(i, 2) end
    if y == y1 then i = 2 elseif y == y1 - 1 and i == 3 then i = 3 end
    local h = X.hash(x, y, seed)
    if i == 3 then if h > 0.9 then i = 4 elseif h < 0.12 then i = 2 end end
    c:put(x, y, CAP[i])
  end end
  if horiz then
    local sx = x0 + 6 + floor(X.hash(1, 1, seed) * 5)
    while sx < x1 - 3 do
      for y = y0 + 1, y1 - 1 do c:put(sx, y, CAP[2]) end
      c:put(sx + 1, y0, CAP[4])
      sx = sx + 9 + floor(X.hash(sx, 2, seed) * 5)
    end
  else
    local sy = y0 + 6 + floor(X.hash(2, 2, seed) * 4)
    while sy < y1 - 3 do
      for x = x0 + 1, x1 - 1 do c:put(x, sy, CAP[2]) end
      for x = x0 + 1, x1 - 1 do if X.hash(x, sy, seed) > 0.5 then c:put(x, sy + 1, CAP[4]) end end
      sy = sy + 8 + floor(X.hash(sy, 2, seed) * 4)
    end
  end
end
local function moss(x, y, n, seed)
  for i = 1, n do
    local dx = floor((X.hash(i, 5, seed) - 0.5) * 6)
    local dy = floor((X.hash(i, 6, seed) - 0.5) * 3)
    local k = 1 + floor(X.hash(i, 7, seed) * 3)
    c:put(x + dx, y + dy, MOSS[k])
  end
  c:put(x, y, MOSS[3]); c:put(x - 1, y, MOSS[2]); c:put(x + 1, y, MOSS[2]); c:put(x, y - 1, MOSS[4])
end
local function flower(x, y, col, hi)
  c:put(x, y + 1, MOSS[2]); c:put(x, y + 2, MOSS[1])
  c:put(x - 1, y, col); c:put(x + 1, y, col); c:put(x, y - 1, col); c:put(x, y + 1, col)
  c:put(x, y, hi)
end

c:groundShadow(32, 55, 28, 3)
-- dirt threshold
for y = 52, 55 do for x = 20, 44 do c:put(x, y, X.hash(x, y, 3) > 0.6 and "#a88a5e" or "#8a6e48") end end
-- posts
local function post(x0, x1, seed)
  face(x0, 17, x1, 55, 7, seed, 6, 10)
  slab(x0 - 1, 8, x1 + 1, 16, seed + 5, true)
  for x = x0 - 1, x1 + 1 do c:put(x, 16, CAP[1]) end
  for x = x0, x1 do c:put(x, 17, RAMPS[1][1]) end
end
post(6, 19, 23)
post(44, 57, 47)
-- gate leaves with arched top
local function topy(x) local t = (x - 32) / 12 return 27 + floor(t * t * 4) end
for x = 20, 43 do
  local y0 = topy(x)
  local pl = floor((x - 20) / 4)
  local px = (x - 20) % 4
  for y = y0, 54 do
    local i = 3
    if px == 0 then i = 4 elseif px == 3 then i = 2 end
    if y == y0 then i = 5 end
    if X.hash(pl, y, 5) > 0.82 and px > 0 and px < 3 then i = 2 end
    if X.hash(x, y, 9) > 0.93 then i = min(5, i + 1) end
    c:put(x, y, WOOD[i])
  end
end
-- centre seam (right leaf ajar: dark gap)
for y = 28, 54 do c:put(31, y, WOOD[1]); c:put(32, y, WOOD[1]) end
for y = 29, 54 do c:put(33, y, WOOD[2]) end
-- shade under the posts onto the gate
for y = 28, 54 do c:put(20, y, WOOD[1]); c:put(43, y, WOOD[1]) end
-- iron straps with rivets and hinge tips
for _, sy in ipairs{ 34, 46 } do
  for x = 20, 43 do
    if x ~= 31 and x ~= 32 then
      c:put(x, sy, IRON[4]); c:put(x, sy + 1, IRON[3]); c:put(x, sy + 2, IRON[1])
      if (x - 20) % 5 == 2 then c:put(x, sy + 1, IRON[5]) end
    end
  end
end
-- ring pull on the right leaf
c:put(35, 39, IRON[5]); c:put(36, 39, IRON[4]); c:put(34, 40, IRON[4]); c:put(37, 40, IRON[3]); c:put(34, 41, IRON[3]); c:put(37, 41, IRON[2]); c:put(35, 42, IRON[2]); c:put(36, 42, IRON[1])
c:put(35, 38, IRON[2]); c:put(36, 38, IRON[2])
-- quirk flower + moss
flower(9, 52, "#ffd23a", "#fff4b0")
moss(16, 54, 3, 2); moss(47, 54, 3, 4); moss(12, 17, 3, 6)
G.save(c, NAME)
