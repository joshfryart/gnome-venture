-- sun-dried-tomatoes (lean E2_15)
-- Wooden drying board with three big wrinkled, curled-rim tomato halves in deep red-orange, flecked with sea salt,
-- plus a basil leaf. Reads as dried tomatoes by the leathery ridged halves.
-- quirk: a tiny ladybird crawling over the front tomato.
local NAME = "sun-dried-tomatoes"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan2 or math.atan
local function clamp(v,a,b) return max(a,min(b,v)) end

local WOOD = { "#3a2218", "#5c3a24", "#7e5232", "#a06c40", "#c48c58" }
local TOM = { "#3a0f1a", "#6a1a22", "#962a26", "#c04a2c", "#e0703a", "#f6a65e" }
local LF = { "#1c3d2a", "#2a5e36", "#3f8a3e", "#68b04a", "#9ad45e", "#c8ee8c" }
c:groundShadow(32, 54, 26, 3)
-- board
for y = 25, 49 do for x = 5, 58 do
  local i = 3
  local row = floor((y - 25) / 6)
  local ry = (y - 25) % 6
  if ry == 0 then i = 4 elseif ry == 5 then i = 2 end
  if y == 25 then i = 5 end
  if X.hash(floor(x / 5), row, 4) > 0.75 and ry > 0 and ry < 5 then i = 2 end
  if X.hash(x, y, 2) > 0.93 then i = min(5, i + 1) end
  if x == 5 then i = max(i, 4) end
  if x == 58 then i = 2 end
  c:put(x, y, WOOD[i])
end end
for y = 25, 49 do c:put(58, y, WOOD[1]) end
for x = 5, 58 do c:put(x, 50, WOOD[1]); c:put(x, 51, WOOD[2]); for y = 52, 53 do c:put(x, y, (x % 17 == 8) and WOOD[1] or WOOD[2]) end end
for x = 5, 58 do c:put(x, 52, (x % 17 == 8) and WOOD[1] or WOOD[3]) end
for y = 25, 53 do c:put(5, y, WOOD[4]) end
local function tomato(cx, cy, rx, ry, rot, seed)
  local cr, sr = cos(rot), sin(rot)
  local pts = {}
  for y = floor(cy - rx - 3), floor(cy + rx + 3) do for x = floor(cx - rx - 3), floor(cx + rx + 3) do
    local dx, dy = x - cx, y - cy
    local u, v = (dx * cr + dy * sr) / rx, (-dx * sr + dy * cr) / ry
    local ang = atan2(v, u)
    local wob = 1 + 0.1 * sin(ang * 3 + seed) + 0.06 * sin(ang * 5 + seed * 2)
    local d = sqrt(u * u + v * v) / wob
    if d <= 1 then pts[#pts + 1] = { x, y, d, ang, u, v } end
  end end
  -- shadow on board
  for _, p in ipairs(pts) do c:put(p[1] + 2, p[2] + 2, WOOD[1]) end
  for _, p in ipairs(pts) do
    local x, y, d, ang, u, v = p[1], p[2], p[3], p[4], p[5], p[6]
    local l = -0.55 * u - 0.7 * v
    local i
    if d > 0.74 then
      -- curled leathery rim: lit upper left
      i = clamp(floor((l + 0.5) * 2.6) + 3, 3, 6)
      if d > 0.93 then i = max(2, i - 1) end
    else
      -- dark wrinkled hollow with ridges
      local rg = sin(d * 17 + ang * 3 + seed)
      i = 2
      if rg > 0.55 then i = 3 elseif rg < -0.75 then i = 1 end
      if l > 0.25 and rg > 0.1 then i = i + 1 end
      if d > 0.6 and l > 0.1 then i = max(i, 3) end
    end
    if X.hash(x, y, seed + 40) > 0.95 then i = min(6, i + 1) end
    c:put(x, y, TOM[clamp(i, 1, 6)])
  end
  -- salt crystals
  for _, p in ipairs(pts) do
    if p[3] < 0.85 and X.hash(p[1], p[2], seed + 7) > 0.965 then c:put(p[1], p[2], "#f8f2e6"); end
  end
  -- glint on the rim
  for _, p in ipairs(pts) do
    if p[3] > 0.8 and p[3] < 0.95 and -0.55 * p[5] - 0.7 * p[6] > 0.62 and X.hash(p[1], p[2], 3) > 0.35 then c:put(p[1], p[2], "#ffd29a") end
  end
end
tomato(19, 35, 11, 8.5, 0.25, 1.3)
tomato(42, 32, 11.5, 8, -0.2, 2.7)
tomato(33, 44, 9.5, 6, 0.1, 4.1)
-- basil leaf
local bm = HP.mask()
local bcx, bcy, brx, bry, ba = 53, 43, 5.6, 3.2, -0.7
for y = 36, 52 do for x = 46, 58 do
  local dx, dy = x - bcx, y - bcy
  local u, v = (dx * cos(ba) + dy * sin(ba)) / brx, (-dx * sin(ba) + dy * cos(ba)) / bry
  local sh = 1 - 0.0
  if u * u + v * v * (1 + 0.5 * max(0, u)) <= 1 then
    local l = -0.5 * u - 0.6 * v
    local i = clamp(floor((l + 0.5) * 3.2) + 2, 2, 5)
    if abs(v) < 0.2 and u > -0.9 then i = 6 end
    c:put(x, y, LF[i])
  end
end end
-- ladybird on the front tomato
c:put(30, 41, "#2a1c26"); c:put(31, 41, "#2a1c26")
c:put(29, 42, "#e63a2c"); c:put(30, 42, "#ff6a4a"); c:put(31, 42, "#e63a2c"); c:put(32, 42, "#a8201c")
c:put(29, 43, "#c82a24"); c:put(30, 43, "#2a1c26"); c:put(31, 43, "#e63a2c"); c:put(32, 43, "#a8201c")
c:put(30, 44, "#a8201c"); c:put(31, 44, "#8a1818")
G.save(c, NAME)
