-- stone-wall-straight (lean E2_15)
-- Low dry-stone wall, long straight run: pale capstone slab on top, three courses of mixed grey/tan stones.
-- quirk: a pink wildflower growing out of a crack, moss on the cap.
local NAME = "stone-wall-straight"
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

c:groundShadow(32, 53, 27, 3)
face(5, 28, 58, 50, 7, 11, 7, 12)
slab(5, 17, 58, 27, 21, true)
for x = 5, 58 do c:put(x, 28, MORT) end
moss(18, 27, 4, 3); moss(50, 29, 3, 8); moss(12, 50, 3, 12); moss(40, 50, 3, 9)
flower(30, 42, "#f07aa8", "#fff0a0")
c:put(29, 40, MORT); c:put(31, 41, MORT)
G.save(c, NAME)
