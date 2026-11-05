-- tool_shed-mossy (lean P1b_O21)
local NAME = "tool_shed-mossy"
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

local W = { "#222c28", "#3e4a3e", "#65705a", "#8d9477", "#b3b595", "#d5d3b2" }
local R = { "#1e2a2e", "#34484e", "#52707a", "#7596a0", "#9fbcc2", "#c6dadb" }
local T = { "#242a22", "#454e3a", "#6b7556", "#929b74", "#b8bf94", "#dadbb2" }
shed{ W = W, R = R, T = T, seed = 21 }
local M = { "#17432b", "#1f6636", "#2f8f3f", "#58b648", "#8ad35c", "#c4ee86" }
local S = { "#383448", "#5d5a70", "#8683a0", "#aeadc4", "#d2d2e0" }
-- stone foundation
for y = 48, 52 do for x = 11, 52 do
  local row = (y - 48) // 2
  local off = (row % 2) * 4
  local ix = 3
  if (x + off) % 8 == 0 or y % 2 == 1 and y ~= 48 and false then ix = 1 end
  if (x + off) % 8 == 0 then ix = 1 end
  if y == 48 then ix = 4 end
  if (y - 48) % 2 == 1 and y < 52 then ix = 2 end
  if y == 52 then ix = 2 end
  if (x + off) % 8 == 1 and y ~= 48 and (y - 48) % 2 == 0 then ix = 4 end
  c:put(x, y, S[ix])
end end
-- dark ajar door
local D = { "#161a16", "#2a3028", "#46513a", "#6c7852" }
for y = 36, 47 do for x = 22, 31 do
  local ix = 2
  if x >= 22 and x <= 24 then ix = 1 end
  if y == 36 then ix = 1 end
  c:put(x, y, D[ix])
end end
for y = 36, 47 do for x = 27, 31 do c:put(x, y, D[(x - 27) % 2 == 0 and 3 or 2]) if y == 36 then c:put(x, y, D[1]) end end end
for y = 35, 47 do c:put(21, y, T[4]) c:put(32, y, T[2]) end
for x = 21, 32 do c:put(x, 35, T[4]) end
c:put(24, 42, "#e3c46a") c:put(24, 43, "#9a7a30")
for x = 21, 31 do c:put(x, 48, S[5]) end
-- window with two panes
for y = 34, 43 do for x = 37, 46 do
  local lit = (x < 41) and (y < 38) 
  c:put(x, y, GLASS[lit and 3 or 2])
end end
for x = 36, 47 do c:put(x, 33, T[4]) c:put(x, 44, T[2]) end
for y = 33, 44 do c:put(36, y, T[4]) c:put(47, y, T[2]) end
for y = 34, 43 do c:put(41, y, T[3]) c:put(42, y, T[2]) end
for x = 37, 46 do c:put(x, 38, T[3]) c:put(x, 39, T[2]) end
c:put(38, 35, GLASS[4]) c:put(39, 35, GLASS[4]) c:put(38, 36, GLASS[4])
c:put(44, 41, GLASS[3]) c:put(45, 42, GLASS[3])
-- window box with flowers? ivy on right wall
local function leaf(x, y)
  c:put(x, y, M[4]) c:put(x + 1, y, M[3]) c:put(x, y + 1, M[3]) c:put(x + 1, y + 1, M[2]) c:put(x - 1, y, M[5])
end
for y = 30, 47 do c:put(50 + ((y // 3) % 2), y, M[2]) end
for _, p in ipairs{ {49,45},{51,41},{49,37},{51,33},{49,31},{50,47} } do leaf(p[1], p[2]) end
-- moss clumps on roof, hanging past the edge
local function blob(cx, cy, rx, ry)
  for y = floor(cy - ry - 1), floor(cy + ry + 1) do for x = floor(cx - rx - 1), floor(cx + rx + 1) do
    local d = ((x - cx) / rx)^2 + ((y - cy) / ry)^2
    d = d + (X.hash(x, y, 13) - 0.5) * 0.35
    if d <= 1 then
      local ix = 3
      local dd = (x - cx) / rx + (y - cy) / ry
      if dd < -0.7 then ix = 5 elseif dd < -0.1 then ix = 4 elseif dd > 0.8 then ix = 1 elseif dd > 0.3 then ix = 2 end
      if X.hash(x, y, 31) > 0.9 then ix = min(6, ix + 1) end
      c:put(x, y, M[ix])
    end
  end end
end
blob(11, 26, 5, 3) blob(20, 20, 6, 3) blob(31, 9, 4, 2.4) blob(26, 14, 3, 2) blob(55, 27, 4, 2.6) blob(8, 30, 2.5, 2.2) blob(46, 24, 4, 2)
for _, p in ipairs{ {7,32},{7,33},{12,30},{13,31},{52,29},{55,30} } do c:put(p[1], p[2], M[2]) end
-- quirk: red toadstool on the roof
for y = 14, 16 do c:put(42, y, "#e8dcc0") c:put(43, y, "#c9bb9c") end
local RD = { "#7a1e3a", "#b02a44", "#da4a4a", "#f58a6c" }
for x = 39, 46 do c:put(x, 12, RD[2]) end
for x = 38, 47 do c:put(x, 13, RD[3]) c:put(x, 14, RD[2]) end
for x = 40, 45 do c:put(x, 11, RD[3]) end
c:put(41, 11, RD[4]) c:put(40, 12, RD[4])
for x = 38, 47 do c:put(x, 14, RD[2]) end
c:put(47, 13, RD[1]) c:put(46, 12, RD[1]) c:put(45, 11, RD[2])
c:put(44, 12, "#f4ead2") c:put(41, 13, "#f4ead2") c:put(45, 13, "#f4ead2")

G.save(c, NAME)
