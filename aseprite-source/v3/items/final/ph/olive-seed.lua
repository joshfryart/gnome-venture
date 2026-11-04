-- olive-seed (final, Opus single pass, aC31_0). Olive pits (endocarps): slim, pointed-at-both-ends stones in pale
-- wood tan with deep longitudinal grooves and lit ridges, on a torn scrap of olive leaf (grey-green leathery top with
-- silvery scale specks, pale midrib, both ends ragged, the lower edge curling over to show the silver underside).
-- The right pit has cracked at its tip and sprouted: straight reddish-green stem, two oval cotyledons, then two
-- opposite pairs of narrow silver-backed olive leaves and a terminal bud.
-- AO + contact shadow under the pits and the sprout foot.
-- quirk: a ragged shred of purple olive flesh still clings to the lying pit.
local NAME = "olive-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF  = { "#1a3230", "#27463b", "#3a5f47", "#557c52", "#799a66", "#a5ba88" }
local UNDER = { "#4a5c5c", "#6c7e78", "#8fa298", "#b0c1b4", "#cfdacd", "#e8eee2" }
local PIT   = { "#4a2e24", "#6e4a34", "#94683f", "#b78a55", "#d6ae74", "#efd29e" }
local FLESH = { "#2a1834", "#432550", "#62356a", "#86508a" }
local STEM  = { "#4c4a34", "#6f6c44", "#97935a", "#c0bb7e" }
local VEIN, COOL = "#c2cfaa", "#4c6e78"

-- leaf scrap
local lm, ln, LT, LS, len = A.blade(7, 49, 31, 54, 57, 46, function(t)
  if t > 0.995 then return -1 end
  return 6.6 * (0.8 + 0.2 * sin(pi * t))
end, { fold = 0.4 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local s, d = LS[k], LT[k] * len
  local a = 1.0 + 1.7 * abs(sin(s * 6.1 + 1.1))
  local b = 1.0 + 1.9 * abs(sin(s * 5.3 + 0.2))
  if d < a or d > len - b then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- pointed endocarp: mask, normals, u/v maps
local function pit(cx, cy, rx, ry, ang)
  local ca, sa = cos(ang), sin(ang)
  local m, n, U, V = HP.mask(), {}, {}, {}
  for y = floor(cy - rx - 2), floor(cy + rx + 2) do for x = floor(cx - rx - 2), floor(cx + rx + 2) do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (rx + 0.4)
    local v = (-dx * sa + dy * ca)
    if abs(u) < 1 then
      local hw = (ry + 0.45) * (1 - u * u) ^ 0.7
      if abs(v) <= hw then
        local k = K(x, y)
        m:set(x, y)
        local vn = v / hw
        local nu = u * 0.7
        local wx, wy = nu * ca - vn * 0.9 * sa, nu * sa + vn * 0.9 * ca
        n[k] = { A.norm(wx, wy, sqrt(max(0.05, 1 - vn * vn)) * 0.9) }
        U[k], V[k] = u, vn
      end
    end
  end end
  return m, n, U, V
end
local P1 = { 21, 48, 8.4, 3.6, -0.22 }
local P2 = { 41, 47, 6.6, 3.2, -0.75 }
P1.m, P1.n, P1.U, P1.V = pit(P1[1], P1[2], P1[3], P1[4], P1[5])
P2.m, P2.n, P2.U, P2.V = pit(P2[1], P2[2], P2[3], P2[4], P2[5])

-- leaf tone with AO and contact shadows
local bias = {}
for _, p in ipairs{ P1, P2 } do X.ao(bias, lm, p.m, 1, -1) A.cast(bias, lm, p.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local utok = { r = { name = "under" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y)
  local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 then c:put(x, y, s <= 0 and VEIN or LEAF[4], ltok) return end
  local d = (t * len - abs(s) * 5) % 5.5
  if d < 0.7 and abs(s) > 0.2 and abs(s) < 0.7 then c:put(x, y, LEAF[max(1, (lidx[k] or 3) - 1)], ltok) return end
  if s < 0 and X.hash(x, y, 21) > 0.88 then c:put(x, y, UNDER[5], ltok) end     -- silvery scales
end)
-- curled lower edge: silver underside rolled over (2 px), cool edge elsewhere
lm:each(function(x, y) local k = K(x, y)
  local s, t = LS[k], LT[k]
  if s > 0.7 and t > 0.48 and t < 0.86 and not bias[k] then
    c:put(x, y, s > 0.86 and UNDER[3] or UNDER[5], utok)
  elseif s > 0.55 and s <= 0.7 and t > 0.5 and t < 0.84 then c:put(x, y, LEAF[1], ltok) end   -- shadow under the curl
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and (LT[k] < 0.46 or LT[k] > 0.88) then c:put(x, y, COOL, ltok) end end)

-- sprout (behind pit 2): stem out of the cracked tip
local stok = { r = { name = "stem" } }
local sp = { { 37, 43 }, { 36, 34 }, { 39, 24 }, { 38, 12 } }
local sm = A.stem(c, sp, function(t) return 1.05 - 0.25 * t end, STEM, { tok = stok, cut = P2.m })
local cot1 = A.leaf(c, 36, 33, 32, 34, 28, 31, 2.1, LEAF, { tok = ltok, cut = sm, pw = 0.5, fold = 0.3, vs = 9 })
local cot2 = A.leaf(c, 38, 33, 42, 34, 46, 32, 2.1, LEAF, { tok = ltok, cut = sm, pw = 0.5, fold = 0.3, vs = 9 })
local cc = sm:copy():add(cot1):add(cot2)
-- first pair: long narrow; the right one twisted to show its silver underside
local a1 = A.leaf(c, 38, 23, 32, 19, 25, 20, 1.8, LEAF, { tok = ltok, cut = cc, vs = 3.0, fold = 0.5 })
local a2 = A.leaf(c, 39, 23, 46, 19, 53, 21, 1.8, UNDER, { tok = utok, cut = cc, vs = 3.0, fold = 0.4 })
cc:add(a1):add(a2)
-- second, smaller pair + bud
local b1 = A.leaf(c, 38, 14, 34, 11, 30, 11, 1.4, LEAF, { tok = ltok, cut = cc, vs = 2.6, fold = 0.5 })
local b2 = A.leaf(c, 39, 14, 43, 11, 47, 12, 1.4, LEAF, { tok = ltok, cut = cc, vs = 2.6, fold = 0.5 })
for _, p in ipairs{ { 38, 11, 3 }, { 38, 10, 4 }, { 38, 9, 3 }, { 39, 11, 2 } } do c:put(p[1], p[2], STEM[p[3]], stok) end
-- nodes: darker rings where the leaf pairs leave the stem
for _, p in ipairs{ { 38, 23 }, { 38, 14 }, { 37, 33 } } do c:put(p[1], p[2], STEM[1], stok) end

-- pits
local function paintPit(P, tok, nr)
  local idx = A.shade(c, P.m, P.n, PIT, { amb = 0.08, wrap = 0.22, tok = tok, cuts = { 0.16, 0.32, 0.5, 0.67, 0.84 } })
  P.m:each(function(x, y) local k = K(x, y)
    local u, v = P.U[k], P.V[k]
    -- longitudinal grooves: narrow along u at fixed v, deep groove + lit ridge on its upper-left side
    for j = 1, nr do
      local g = -1 + 2 * j / (nr + 1)
      local d = v - g * (1 - 0.2 * u * u)
      if abs(d) < 0.12 and abs(u) < 0.86 then c:put(x, y, PIT[max(1, idx[k] - 2)], tok)
      elseif d < -0.12 and d > -0.3 and abs(u) < 0.75 then c:put(x, y, PIT[min(6, idx[k] + 1)], tok) end
    end
  end)
  -- tips: darker pointed ends
  local hx, hy = A.specAt(P.m, P.n, 30)
  c:put(hx, hy, PIT[6], tok) c:put(hx + 1, hy, PIT[6], tok)
  return idx
end
local i1 = paintPit(P1, { r = { name = "pit1" } }, 3)
local i2 = paintPit(P2, { r = { name = "pit2" } }, 2)
-- cracked tip of pit 2 around the stem foot: dark slit + pale broken lip
for _, p in ipairs{ { 36, 43, 1 }, { 37, 44, 1 }, { 38, 43, 6 }, { 35, 44, 2 } } do
  if P2.m:has(p[1], p[2]) then c:put(p[1], p[2], PIT[p[3]], { r = { name = "pit2" } }) end end
-- radicle out the lower end
for _, p in ipairs{ { 46, 51, 3 }, { 47, 52, 2 } } do c:put(p[1], p[2], STEM[p[3]], stok) end

-- quirk: shred of purple flesh on pit 1 (upper right of the stone)
local ftok = { r = { name = "flesh" } }
local fm = HP.mask()
for _, p in ipairs{ { 24, 44 }, { 25, 44 }, { 26, 44 }, { 23, 45 }, { 24, 45 }, { 25, 45 }, { 26, 45 }, { 27, 45 }, { 25, 46 }, { 26, 46 }, { 27, 43 } } do fm:set(p[1], p[2]) end
fm:each(function(x, y) local t = (y == 44 or y == 43) and 4 or (y == 45 and 3 or 2) c:put(x, y, FLESH[t], ftok) end)
c:put(25, 47, FLESH[1], ftok) c:put(24, 44, "#c493b8", ftok)

A.save(c, NAME)
