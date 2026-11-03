-- pineapple (batch2, single pass, Opus). Slim upright barrel of diamond-set fruitlet "eyes" under a stiff,
-- glaucous sword-leaf crown. Body: per-pixel light from a pillow normal field plus a bump per eye (eyes laid on a
-- diamond lattice wrapped round the barrel, so they foreshorten at the sides), dark grooves between eyes, a brown
-- bract spine at the top of each eye, top rows still green-gold (pineapples ripen from the bottom up), cool
-- reflected light lower-right, AO under the crown. Crown: V-folded blades with a pale bloom stripe, back blades a
-- tone darker, dark contact line where blades overlap. Draft by Sonnet replaced.
-- quirk: one late violet pineapple flower still pokes out of an eye on the shade side.
local NAME = "pineapple"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../batch1/_g1.lua")
local HP, X, c, P = G.new(NAME)
local K = G.K
local floor, abs, sqrt, max, min, asin, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.asin, math.pi

local GOLD  = { "#5c2c2c", "#94481f", "#c9711f", "#e89a2c", "#f6c64c", "#fde88e" }
local OLIVE = { "#2c3a2c", "#4a5e26", "#79872a", "#a8aa34", "#d0c656", "#ece48e" }
local LEAF  = { "#173634", "#22524b", "#2f6f58", "#4a8e64", "#72ae78", "#a6d0a0" }
local BLOOM, SPINE, BOUNCE = "#c8e2c0", "#4a2418", "#9c8aa8"
local FLOWER = { "#4a2a78", "#7a4fb8", "#b48ae6" }

------------------------------------------------------------------ crown (back blades first)
local drawn = HP.mask()
local function blade(ax, ay, cx, cy, bx, by, w, dark)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.98 then return -1 end
    return max(0.45, w * (1 - t) ^ 0.75 * min(1, 0.55 + t * 4))
  end, { fold = 0.5 })
  local tok = { r = { name = "leaf" } }
  local bias = {}
  if dark then m:each(function(x, y) bias[K(x, y)] = -1 end) end
  G.toneN(c, m, n, LEAF, { tok = tok, bias = bias, amb = 0.12, wrap = 0.25, cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 } })
  -- pale bloom stripe on the lit half
  m:each(function(x, y) local k = K(x, y)
    if S[k] < -0.25 and S[k] > -0.6 and T[k] > 0.12 and T[k] < 0.75 then c:put(x, y, dark and LEAF[5] or BLOOM, tok) end
  end)
  -- contact line on what is already drawn behind it
  m:grow(1):cut(m):each(function(x, y) if drawn:has(x, y) then c:put(x, y, LEAF[1], { r = { name = "leaf" } }) end end)
  drawn:add(m)
  return m
end
blade(30, 31, 27, 20, 25, 9, 2.0, true)
blade(33, 31, 36, 20, 39, 9, 2.0, true)
blade(30, 32, 22, 25, 14, 19, 2.1)
blade(33, 32, 41, 25, 49, 18, 2.1)
blade(31, 31, 26, 19, 20, 10, 2.3)
blade(32, 31, 37, 19, 43, 10, 2.3)
blade(31, 31, 31, 17, 32, 6, 2.5)

------------------------------------------------------------------ body
local Y0, Y1, CX = 30, 57, 31.5
local YC, HH, W = (Y0 + Y1) / 2, (Y1 - Y0) / 2 + 0.5, 8.7
local function hw(y)
  local t = abs(y - YC + 1) / HH
  return W * max(0, 1 - t ^ 2.8) ^ (1 / 2.8)
end
local body = HP.mask()
for y = Y0, Y1 do for x = 18, 46 do if abs(x - CX) <= hw(y) then body:set(x, y) end end end
local bn = X.pillow(body, 6.5)
-- fruitlet lattice in wrapped (u, v) coords
local SU, SV = 3.5, 2.6
local cell, groove, du_, dv_ = {}, {}, {}, {}
local function AB(x, y)
  local h = hw(min(Y1, max(Y0, y))) + 0.5
  local u = asin(max(-0.985, min(0.985, (x - CX) / h))) * 9.5
  local v = y - Y0 - 1.2
  return u / SU + v / SV, u / SU - v / SV                -- eye centres at even (a, b)
end
local A_, B_ = {}, {}
body:each(function(x, y) local k = K(x, y)
  local a, b = AB(x, y)
  A_[k], B_[k] = a, b
  local p, q = floor((a + 1) / 2), floor((b + 1) / 2)
  local ao, bo = a - 2 * p, b - 2 * q                    -- -1..1 inside the eye
  cell[k] = { p, q, p + q, p - q }                       -- [4] = row index (vertical)
  du_[k], dv_[k] = (ao + bo) / 2, (ao - bo) / 2
end)
-- grooves: per column, the pixel nearest each odd-a / odd-b line (1 px wide, 8-connected)
local function off(v) local r = (v - 1) % 2 return min(r, 2 - r) end
body:each(function(x, y) local k = K(x, y)
  for _, F in ipairs{ A_, B_ } do
    local d = off(F[k])
    local up, dn = F[K(x, y - 1)], F[K(x, y + 1)]
    if d < 0.75 and (not up or off(up) > d) and (not dn or off(dn) >= d) then groove[k] = true end
  end
end)
local n = {}
body:each(function(x, y) local k = K(x, y)
  local b = bn[k]
  n[k] = { G.norm(b[1] + du_[k] * 0.05, b[2] + dv_[k] * 0.05, b[3]) }
end)
local bias = {}
-- AO under the crown
local crownBase = c:rect(24, Y0 - 3, 39, Y0 - 1)
X.ao(bias, body, crownBase, 2, -1)
body:each(function(x, y) local k = K(x, y)
  if groove[k] then bias[k] = (bias[k] or 0) - 2
  else
    local a = A_[k] - 2 * cell[k][1]
    if a < -0.35 then bias[k] = (bias[k] or 0) + 1                  -- lit lip on the upper-left face of each eye
    end
  end
end)
local gold, olive = HP.mask(), HP.mask()
body:each(function(x, y) local k = K(x, y)
  local j = cell[k][4]
  local g = j <= 0 or (j == 1 and X.hash(cell[k][3], j, 3) > 0.45) or (j == 2 and X.hash(cell[k][3], j, 3) > 0.85)
  if g then olive:set(x, y) else gold:set(x, y) end
end)
local cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }
-- light each eye as one facet (cell-average light, a little per-pixel left in) so the lattice reads cleanly
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
local sum, cnt = {}, {}
body:each(function(x, y) local k = K(x, y) local id = cell[k][1] .. ":" .. cell[k][2]
  sum[id] = (sum[id] or 0) + v[k] cnt[id] = (cnt[id] or 0) + 1 end)
local vf = {}
body:each(function(x, y) local k = K(x, y) local id = cell[k][1] .. ":" .. cell[k][2]
  vf[k] = 0.75 * sum[id] / cnt[id] + 0.25 * v[k] end)
X.tone(c, gold, vf, GOLD, { cuts = cuts, bias = bias, tok = { r = { name = "gold" } } })
X.tone(c, olive, vf, OLIVE, { cuts = cuts, bias = bias, tok = { r = { name = "olive" } } })
-- bract spine: 1 px at the top of each eye (skip rim eyes and the ones in AO)
local inner = body:copy():shrink(2)
local best = {}
inner:each(function(x, y) local k = K(x, y)
  if groove[k] or (bias[k] and bias[k] < 0) then return end
  local d = abs(du_[k]) * 1.5 + abs(dv_[k] + 0.45)
  local id = cell[k][1] .. ":" .. cell[k][2]
  if not best[id] or d < best[id][1] then best[id] = { d, x, y } end
end)
for _, b in pairs(best) do if b[1] < 0.5 then c:px(b[2], b[3], SPINE) end end
-- cool reflected light lower-right
local rim = X.rim(bn)
body:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.72 and y > YC - 4 and y < Y1 - 1 then c:px(x, y, BOUNCE) end end)
-- specular: 2x1 cream + a hi pixel on an upper-left eye
c:px(26, 37, P.cream) c:px(27, 37, P.cream) c:px(26, 38, GOLD[6])
-- crown seat: short dark collar where leaves meet the fruit
for x = 28, 35 do if body:has(x, Y0) then c:px(x, Y0, OLIVE[1]) end end
c:px(27, Y0 + 1, OLIVE[2]) c:px(36, Y0 + 1, OLIVE[2])

------------------------------------------------------------------ front crown leaves (short, lying over the shoulder)
local function front(ax, ay, cx, cy, bx, by, w)
  local m = blade(ax, ay, cx, cy, bx, by, w)
  return m
end
drawn:add(body)
front(31, 30, 26, 29, 22, 31, 1.7)
front(32, 30, 37, 29, 41, 31, 1.7)
front(31, 30, 30, 24, 28, 18, 1.8)

------------------------------------------------------------------ quirk: a late violet flower on a shade-side eye
local fx, fy = 41, 45                                     -- flower centre, just off the right rim
c:px(fx, fy, "#ffe9a8")
c:px(fx - 1, fy, FLOWER[2]) c:px(fx + 1, fy, FLOWER[2]) c:px(fx, fy - 1, FLOWER[3]) c:px(fx, fy + 1, FLOWER[1])
c:px(fx - 1, fy + 1, FLOWER[1])

G.save(c, NAME)
