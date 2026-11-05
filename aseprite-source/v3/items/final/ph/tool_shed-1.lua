-- tool_shed-1 (lean P1b_O21)
local NAME = "tool_shed-1"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sqrt, sin, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.pi
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local GLASS = { "#2f3f6e", "#4f7ab0", "#86bfdc", "#d2f1f2" }
local IRON  = { "#2e2a3c", "#4d4a66", "#7b7a98", "#b4b8cc" }
local function clampi(i) return max(1, min(6, i)) end
-- plank shed: walls x11..52 y29..52, gabled shingle roof x7..57 y7..29. cfg: W,R,T ramps, seed, glow={cx,cy,r1,r2}
local function shed(cfg)
  local W, R, T, sd = cfg.W, cfg.R, cfg.T, cfg.seed
  c:groundShadow(32, 54, 26, 3)
  local widx = {}
  for y = 29, 52 do for x = 11, 52 do
    local pk = floor((x - 11) / 4)
    local i = (x - 11) % 4
    local ix = 3
    if X.hash(pk, 0, sd) > 0.55 then ix = 2 end
    if i == 0 then ix = 5 elseif i == 3 then ix = 1 end
    if y == floor(33 + X.hash(pk, 1, sd) * 15) and i ~= 3 then ix = 1 end
    if i == 1 and X.hash(x, y, sd + 3) > 0.9 then ix = ix + 1 end
    if x >= 51 and i ~= 3 then ix = min(ix, 2) end
    if y >= 51 then ix = min(ix, 2) end
    if y == 29 then ix = 1 elseif y == 30 then ix = min(ix, 2) elseif y == 31 and ix > 3 then ix = 3 end
    if cfg.glow then
      local g = cfg.glow
      local d = sqrt((x - g[1])^2 + ((y - g[2]) * 1.1)^2)
      if y > 31 then
        if d < g[3] then ix = ix + 2 elseif d < g[4] then ix = ix + 1 end
      end
    end
    widx[K(x, y)] = clampi(ix)
    c:put(x, y, W[clampi(ix)])
  end end
  -- roof
  local roof = HP.mask()
  for y = 7, 29 do
    local hw = (y - 7) / 22 * 25.5
    local xl, xr = floor(32 - hw + 0.5), floor(32 + hw + 0.5)
    local s = floor((y - 7) / 3)
    local off = (s % 2) * 2
    for x = xl, xr do
      roof:set(x, y)
      local r = (y - 7) % 3
      local ix = (x < 32) and 4 or 3
      if X.hash(floor((x + off) / 4), s, sd + 9) > 0.7 then ix = ix - 1 end
      if r == 0 then ix = ix + 1 end
      if r == 2 then ix = 1 end
      if (x + off) % 4 == 0 and r ~= 2 then ix = 2 end
      if x - xl <= 1 or xr - x <= 1 then ix = (x < 32) and 5 or 3 end   -- rake boards
      if y >= 28 then ix = (y == 28) and 5 or 2 end                      -- fascia
      local ramp = R
      if x - xl <= 1 or xr - x <= 1 or y >= 28 then ramp = T end
      c:put(x, y, ramp[clampi(ix)])
    end
  end
  -- roof shadow onto wall under eave handled by wall rows 29-31
  return widx, roof
end
local function doorPlanks(x0, y0, x1, y1, D, sd)
  for y = y0, y1 do for x = x0, x1 do
    local i = (x - x0) % 3
    local ix = (i == 0) and 4 or ((i == 2) and 2 or 3)
    if X.hash(floor((x - x0) / 3), 2, sd) > 0.6 then ix = ix - 1 end
    if y == y0 then ix = 1 end
    if x == x1 then ix = 1 end
    if y == y1 then ix = 2 end
    c:put(x, y, D[max(1, ix)])
  end end
end
local function frame(x0, y0, x1, y1, T)
  for y = y0, y1 do for x = x0, x1 do
    if x == x0 or y == y0 then c:put(x, y, T[4]) elseif x == x1 or y == y1 then c:put(x, y, T[2]) end
  end end
end
local function disc(cx, cy, r, ramp, ixmap)
  for y = floor(cy - r), floor(cy + r) do for x = floor(cx - r), floor(cx + r) do
    local d = sqrt((x - cx)^2 + (y - cy)^2)
    if d <= r then
      local ix = 2
      if d > r - 1.2 then ix = 1 elseif (x - cx) + (y - cy) < -r * 0.6 then ix = 4 elseif (x - cx) + (y - cy) < 0 then ix = 3 end
      c:put(x, y, ramp[ix])
    end
  end end
end

local W = { "#2f1a14", "#5b3320", "#8c5430", "#b87a44", "#dba062", "#f3c88a" }
local R = { "#232846", "#3a4670", "#566a9a", "#7b92c0", "#a4bce0", "#cfe0f4" }
local T = { "#3b2616", "#6a4326", "#a06a3a", "#d79a5a", "#f1c486", "#fbe4b4" }
shed{ W = W, R = R, T = T, seed = 5 }
-- round gable window
disc(32, 19, 4, GLASS)
for i = -3, 3 do c:put(32 + i, 19, T[3]) c:put(32, 19 + i, T[3]) end
c:put(30, 17, GLASS[4]) c:put(29, 18, GLASS[4])
for _, p in ipairs{ {32,14},{31,14},{33,14},{28,15},{36,15},{27,17},{37,17},{27,21},{37,21},{28,23},{36,23},{31,24},{33,24},{32,24} } do end
-- double doors with X braces
local D = { "#24120e", "#4a2a1a", "#7a4a2a", "#a86a3a", "#c88c52" }
doorPlanks(22, 36, 31, 51, D, 7)
doorPlanks(32, 36, 41, 51, D, 8)
frame(21, 35, 42, 35, T)
for y = 35, 51 do c:put(21, y, T[4]) c:put(42, y, T[2]) end
for i = 0, 11 do
  local y = 38 + i
  c:put(23 + floor(i * 0.7), y, T[4]) c:put(24 + floor(i * 0.7), y, T[3])
  c:put(40 - floor(i * 0.7), y, T[4]) c:put(39 - floor(i * 0.7), y, T[3])
  c:put(30 - floor(i * 0.7), y, T[4]) c:put(29 - floor(i * 0.7), y, T[3])
  c:put(33 + floor(i * 0.7), y, T[4]) c:put(34 + floor(i * 0.7), y, T[3])
end
c:put(30, 44, IRON[4]) c:put(30, 45, IRON[2]) c:put(33, 44, IRON[4]) c:put(33, 45, IRON[2])
c:put(31, 35, IRON[2]) c:put(32, 35, IRON[2])
-- spade leaning on the wall
local WD = { "#5a3a1c", "#8c6030", "#bd8c4a", "#e0b574" }
for i = 0, 13 do c:put(48 - floor(i * 0.2), 34 + i, WD[(i % 5 == 0) and 2 or 3]) c:put(49 - floor(i * 0.2), 34 + i, WD[2]) end
for x = 46, 51 do c:put(x, 33, IRON[2]) end
c:put(46, 32, IRON[3]) c:put(51, 32, IRON[2]) c:put(46, 34, IRON[2]) c:put(51, 34, IRON[1])
for y = 47, 52 do
  for x = 45 + floor((y - 47) * 0.2), 50 - floor((y - 47) * 0.1) do
    local ix = 3
    if x == 45 + floor((y - 47) * 0.2) then ix = 4 end
    if y >= 51 then ix = 2 end
    if x >= 49 then ix = 2 end
    c:put(x, y, IRON[ix])
  end
end
c:put(46, 48, IRON[4]) c:put(46, 49, IRON[4])
-- weathervane (quirk): arrow on a pole
for y = 2, 6 do c:put(32, y, IRON[2]) end
for x = 28, 36 do c:put(x, 3, IRON[3]) end
c:put(37, 3, "#d9473f") c:put(36, 2, "#d9473f") c:put(36, 4, "#a8283a") c:put(35, 3, "#a8283a")
c:put(28, 2, IRON[3]) c:put(28, 4, IRON[2]) c:put(29, 2, IRON[3]) c:put(29, 4, IRON[2])
c:put(32, 7, T[5])

G.save(c, NAME)
