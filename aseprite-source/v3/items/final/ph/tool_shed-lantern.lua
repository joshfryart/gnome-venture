-- tool_shed-lantern (lean P1b_O21)
local NAME = "tool_shed-lantern"
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

local W = { "#3a2a1c", "#6e5230", "#a07c44", "#cfa65c", "#ecca7c", "#fbeaa8" }
local R = { "#12373a", "#1c5a58", "#2f8077", "#52a592", "#82c9ad", "#bfe8c9" }
local T = { "#3b2a1a", "#6a4c2a", "#a47a3c", "#d6a95a", "#f1d086", "#fff0b8" }
shed{ W = W, R = R, T = T, seed = 11, glow = { 48, 41, 4, 9 } }
-- stovepipe on the right roof slope
local P = { "#2e2a3c", "#4d4a66", "#7b7a98", "#b4b8cc" }
for y = 9, 18 do for x = 41, 44 do
  local ix = (x == 41) and 4 or ((x == 42) and 3 or ((x == 43) and 2 or 1))
  c:put(x, y, P[ix])
end end
for x = 40, 45 do c:put(x, 8, P[3]) c:put(x, 9, P[1]) end
c:put(41, 8, P[4])
c:put(41, 12, P[1]) c:put(42, 12, P[1]) c:put(43, 12, P[1]) c:put(44, 12, P[1])
-- smoke puff
local SM = { "#8e8aa8", "#bdbcd2", "#e4e4ee" }
for _, p in ipairs{ {42,4,2},{44,3,2},{45,5,1},{43,6,1} } do disc(p[1], p[2], p[3] + 0.4, { SM[1], SM[1], SM[3], SM[3] }) end
-- single door with round-top window
local D = { "#241a12", "#4a3622", "#76593a", "#a07c4a", "#c4a068" }
doorPlanks(24, 36, 35, 51, D, 3)
for y = 35, 51 do c:put(23, y, T[4]) c:put(36, y, T[2]) end
for x = 23, 36 do c:put(x, 35, T[4]) end
for y = 38, 42 do for x = 27, 32 do c:put(x, y, GLASS[(y < 40 and x < 30) and 3 or 2]) end end
for x = 27, 32 do c:put(x, 37, T[3]) c:put(x, 43, T[2]) end
for y = 38, 42 do c:put(26, y, T[3]) c:put(33, y, T[2]) end
c:put(29, 40, T[3]) c:put(30, 40, T[3]) c:put(29, 39, T[3]) c:put(30, 41, T[3])
c:put(27, 38, GLASS[4]) c:put(28, 38, GLASS[4])
c:put(33, 45, "#e8c070") c:put(33, 46, "#a07c3a")
-- step
for x = 22, 37 do c:put(x, 52, "#8a8aa4") end
-- iron bracket + hanging lantern
for x = 44, 48 do c:put(x, 33, IRON[3]) end
c:put(44, 34, IRON[3]) c:put(44, 32, IRON[3]) c:put(44, 35, IRON[2]) c:put(45, 34, IRON[2])
for y = 34, 36 do c:put(48, y, IRON[3]) end
for x = 46, 50 do c:put(x, 37, IRON[2]) end
for x = 45, 51 do c:put(x, 38, IRON[3]) end
for y = 39, 45 do
  c:put(45, y, IRON[3]) c:put(51, y, IRON[1])
  for x = 46, 50 do
    local ix = "#ffe27a"
    if x == 46 or x == 50 then ix = "#f0a32a" end
    if (y == 41 or y == 42) and x >= 47 and x <= 49 then ix = "#fff4c0" end
    c:put(x, y, ix)
  end
end
for x = 45, 51 do c:put(x, 46, IRON[2]) end
for x = 46, 50 do c:put(x, 47, IRON[1]) end
c:put(48, 40, "#fff4c0")
-- quirk: a moth drawn to the light
local MO = "#ece6d6"
c:put(41, 38, MO) c:put(42, 38, MO) c:put(43, 38, MO) c:put(42, 37, "#a89c86") c:put(42, 39, "#a89c86") c:put(41, 37, MO) c:put(43, 37, MO)

G.save(c, NAME)
