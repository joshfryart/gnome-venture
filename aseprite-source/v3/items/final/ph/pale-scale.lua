-- pale-scale (final pass, Opus). One large shed scale, tilted: a broad scalloped fan on top narrowing to a short
-- rosy root at the lower-left, gently domed.
-- Material: per-pixel pillow light on a 6-tone pearl ramp (lilac shade, warm cream light), concentric growth ridges
-- around the root (dark groove + lit lip), a thin translucent free edge along the scallops, fine radial striations
-- near the root, a hard-pixel nacre sheen (mint + pink flecks) across the lit shoulder, cool reflected light on the
-- lower-right rim, one bright specular.
-- quirk: a single dewdrop has beaded on the scale and catches the light.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_4.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local NAME = "pale-scale"
local c = A.new(NAME)
local PR   = { "#5e4a7a", "#8774a2", "#b1a0c4", "#d6c8da", "#efe2e0", "#fff6ea" }
local ROOT = { "#6e2c48", "#a2486a", "#cf7890", "#eea6b2" }
local MINT, PINK, COOL, SPEC = "#c8f0e2", "#ffd0e0", "#9a9cd0", "#fffaf0"
local tok = { r = { name = "scale" } }
local rtok = { r = { name = "root" } }

local ANG = 0.5          -- tilt (root to lower-left)
local CX, CY = 33, 31    -- centre of the local frame
local ca, sa = cos(ANG), sin(ANG)
local function loc(x, y) local dx, dy = x - CX, y - CY return dx * ca + dy * sa, -dx * sa + dy * ca end
-- local frame: u across, v down toward the root
local function inside(u, v)
  if v <= -6 then
    local r = sqrt(u*u + (v + 6)^2)
    local th = atan(u, -(v + 6))
    local R = 14.2 + 0.85 * cos(th * 6.2)
    return r <= R
  end
  if v > 19 then return false end
  local f = (v + 6) / 25
  local hw = 14.2 * (1 - f) ^ 0.85 + 3.0 * f
  return abs(u) <= hw
end
local m = HP.mask()
local U, V = {}, {}
for y = 0, 63 do for x = 0, 63 do
  local u, v = loc(x, y)
  if inside(u, v) then m:set(x, y) U[K(x, y)], V[K(x, y)] = u, v end
end end
local n = X.pillow(m, 9, 0.8)
-- overall cupping across u
local nn = {}
m:each(function(x, y) local k = K(x, y) local a = n[k]
  local cu = U[k] / 16 * 0.35
  nn[k] = { A.norm(a[1] + cu * ca, a[2] + cu * sa, a[3]) } end)
local rootd = function(k) local u, v = U[k], V[k] return sqrt(u*u + (v - 19)^2) end
local bias = {}
local idx = A.shade(c, m, nn, PR, { amb = 0.1, wrap = 0.3, bias = bias, tok = tok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.84 } })

-- growth ridges around the root
local edge = m:edge()
m:each(function(x, y) local k = K(x, y)
  local d = rootd(k)
  if d > 9 and not edge:has(x, y) then
    local ph = (d - 9) % 4.6
    local i = idx[k]
    if ph < 0.85 then A.step(c, idx, PR, x, y, -1, tok)
    elseif ph < 1.8 and i >= 3 then A.step(c, idx, PR, x, y, 1, tok) end
  end
end)
-- radial striations near the root
m:each(function(x, y) local k = K(x, y)
  local d = rootd(k)
  if d > 4 and d < 14 then
    local th = atan(U[k], 19 - V[k])
    if (th * 9) % 1 < 0.16 then A.step(c, idx, PR, x, y, -1, tok) end
  end
end)
-- translucent free edge: palest tone 1 px inside the scalloped top, darker line just within it
edge:each(function(x, y) local k = K(x, y) if V[k] < -8 and U[k] < 8 then c:put(x, y, PR[6], tok) end end)
-- nacre sheen across the lit shoulder
m:each(function(x, y) local k = K(x, y)
  local u, v = U[k], V[k]
  local band = (u * 0.8 + v * 0.6)
  if band > -15 and band < -10 and idx[k] >= 4 and not edge:has(x, y) then
    local h = X.hash(x, y, 11)
    if h < 0.22 then c:put(x, y, MINT, tok) elseif h > 0.8 then c:put(x, y, PINK, tok) end
  end
end)
-- root: rosy attachment
m:each(function(x, y) local k = K(x, y)
  local d = rootd(k)
  if V[k] > 13 and d < 5.2 then
    local i = idx[k]
    local r = i >= 5 and 4 or i >= 3 and 3 or i >= 2 and 2 or 1
    if d > 4.2 then r = max(1, r - 1) end
    c:put(x, y, ROOT[r], rtok)
  end
end)
-- cool reflected light on lower-right rim
local rim = X.rim(nn)
edge:each(function(x, y) local k = K(x, y) if rim[k] > 0.6 and V[k] < 14 then c:put(x, y, COOL, tok) end end)
-- specular
local sx, sy = G.specAt(m:shrink(2), nn, 30)
c:put(sx, sy, SPEC, tok) c:put(sx + 1, sy, PR[6], tok)

-- quirk: a dewdrop beaded on the lower body
local DW = { "#3a86b0", "#8fd4e0", "#d8f6f2", "#fffaf0" }
A.map(c, {
  ".aaa.",
  "abcca",
  "abbcd",
  ".add.",
}, 36, 33, { a = DW[1], b = DW[3], c = DW[2], d = DW[2] }, { r = { name = "dew" } })
c:put(37, 34, DW[4])
-- contact shadow under the drop
for x = 37, 39 do if m:has(x, 37) then A.step(c, idx, PR, x, 37, -2, tok) end end
A.save(c, NAME)
