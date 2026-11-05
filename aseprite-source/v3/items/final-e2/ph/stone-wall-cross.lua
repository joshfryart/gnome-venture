-- stone-wall-cross (lean E2_15)
-- Four-way crossing: wall runs left-right and front-back, plus-shaped silhouette, capstone slabs meet in the middle.
-- quirk: an ivy sprig with a blue flower climbs the front end face.
local NAME = "stone-wall-cross"
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

c:groundShadow(32, 57, 18, 3)
face(5, 31, 58, 41, 6, 51, 7, 12)
-- front branch face + top
face(25, 51, 38, 58, 7, 83, 6, 9)
slab(25, 31, 38, 50, 91, false)
-- back branch top
slab(25, 5, 38, 21, 97, false)
slab(5, 22, 58, 30, 25, true)
-- crossing seam hint: dark seams around the central square
for x = 25, 38 do c:put(x, 22, CAP[2]); c:put(x, 30, CAP[2]) end
for y = 22, 30 do c:put(25, y, CAP[2]); c:put(38, y, CAP[2]) end
for x = 26, 37 do c:put(x, 23, CAP[4]) end
for x = 25, 38 do c:put(x, 50, CAP[1]) end
for y = 31, 50 do c:put(25, y, CAP[4]); c:put(38, y, CAP[2]) end
for y = 31, 41 do c:put(24, y, RAMPS[1][1]); c:put(39, y, RAMPS[1][1]) end
for x = 5, 58 do c:put(x, 31, MORT) end
for x = 25, 38 do c:put(x, 31, CAP[3]) end
for x = 25, 38 do c:put(x, 31, CAP[4]) end
-- ivy on the front face
local IV = { "#1f4a2c", "#2f7a3c", "#58a84a", "#96d062" }
local vine = { {31,58},{31,56},{32,54},{33,53},{34,53} }
for _, p in ipairs(vine) do c:put(p[1], p[2], IV[1]) end
local function ivy(x, y) c:put(x, y, IV[3]); c:put(x - 1, y, IV[2]); c:put(x + 1, y, IV[2]); c:put(x, y - 1, IV[4]); c:put(x, y + 1, IV[2]) end
ivy(29, 55); ivy(35, 55); ivy(33, 52)
c:put(36, 54, "#6ea0f0"); c:put(37, 54, "#a8c8ff"); c:put(37, 53, "#6ea0f0"); c:put(37, 55, "#6ea0f0"); c:put(38, 54, "#6ea0f0")
moss(10, 40, 4, 5); moss(53, 40, 4, 6); moss(31, 6, 3, 10)
G.save(c, NAME)
