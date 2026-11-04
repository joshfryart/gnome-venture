-- raspberry-seed (final, Sonnet high). A slim arched scrap of raspberry leaf, torn along the upper left (pale fibre rim), margin
-- sharply toothed, strongly parallel impressed side veins and a pale midrib. Six tiny tan raspberry pips (pointed hilum end,
-- net of pits, specular glint, contact shadow on the leaf). One pip has sprouted: bronze-rose stem with a couple of prickles,
-- two oval cotyledons, then the first true leaf, a toothed trifoliate (three leaflets with parallel veins).
-- quirk: one pip still wears a crimson scrap of dried pulp, like a tiny hat.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_5.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("raspberry-seed")
local SC = { "#1a3932", "#26543c", "#357241", "#4c9050", "#74b05e", "#a2cc80" }
local TL = { "#1d4033", "#2a5f40", "#3d8149", "#5aa352", "#86c363", "#b8e08c" }
local CO = { "#25503a", "#357245", "#4d9650", "#72b85a", "#9cd274", "#c8ec9c" }
local BR = { "#3c1f2e", "#6a3340", "#9a5148", "#c47a58", "#e2a56c", "#f6cf92" }
local SEED = { "#4a3016", "#76501f", "#a07836", "#c49c52", "#e0bc78", "#f6dea6" }
local PULP = { "#43102e", "#7a1840", "#aa1f49", "#d02d52", "#ee5b6c", "#ff9aa0" }
local ltok = { r = { name = "leaf" } }

-- ===== seeds (planned first so the leaf can take their contact shadow)
local seeds = {
  { 33, 49, 0.3 }, { 39, 52.5, -0.5 }, { 45.5, 48.5, 0.9 }, { 48.5, 52, 0.2 }, { 28, 52.5, -0.2 }, { 40, 46, -0.9 },
}
local sprout = { 22, 50, 0.15 }
local all = {}
for _, s in ipairs(seeds) do all[#all + 1] = s end
all[#all + 1] = sprout
for _, s in ipairs(all) do
  s.m = A.wedge(s[1], s[2], 6.2, 4.0, s[3], 0.3)
  s.n = X.pillow(s.m, 1.8)
end
local rect = HP.mask():add(c:rect(0, 0, 63, 63))
local bias = {}
for _, s in ipairs(all) do X.ao(bias, rect, s.m, 1, -1) G.cast(bias, rect, s.m, 1, 2, -1) end

-- ===== leaf scrap
local lw = A.sawW(48, 7.4, { saw = 3.7, amp = 1.3, s0 = 0.1, s1 = 0.96, off = 0.04, k = 0.96, pw = 0.6 })
local lm, ln, LT, LS, llen, torn = A.tornBlade(c, 9, 54, 29, 46, 55, 51, lw, {
  ramp = SC, veins = { 0.11, 0.18, 0.25, 0.32, 0.39, 0.46, 0.53, 0.6, 0.67, 0.74, 0.81, 0.88 }, sweep = 3.4, rib = 0.1, ribEnd = 0.97,
  ribHi = SC[6], fibre = "#dcead2", cool = "#386f7a", bias = bias, veinMax = 0.9, fold = 0.5,
  tear = { [-1] = { depth = 0.5, t0 = 0.04, t1 = 0.5 } } })

-- boosted impressed veins: bright lit edge, dark groove below-right
local veinsT = { 0.11, 0.18, 0.25, 0.32, 0.39, 0.46, 0.53, 0.6, 0.67, 0.74, 0.81, 0.88 }
local vm = HP.mask()
lm:each(function(x, y) local k = K(x, y)
  if bias[k] or not LS[k] or abs(LS[k]) < 0.22 or abs(LS[k]) > 0.8 or LT[k] < 0.06 then return end
  for _, vt in ipairs(veinsT) do
    local d = (LT[k] - vt) * llen - abs(LS[k]) * 3.4
    if d > -0.5 and d < 0.5 then vm:set(x, y) end
  end
end)
vm:each(function(x, y) local k = K(x, y) c:put(x, y, LS[k] < 0 and SC[6] or SC[5], ltok) end)
vm:shift(1, 1):each(function(x, y) local k = K(x, y) if lm:has(x, y) and not vm:has(x, y) and not bias[k] then c:put(x, y, SC[1], ltok) end end)

-- ===== sprout (stem first, then the seed hides its foot)
local function pip(s, withTok)
  local tok = { r = { name = "pip" } }
  G.toneN(c, s.m, s.n, SEED, { cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = tok, amb = 0.06, wrap = 0.2 })
  local ca, sa = cos(s[3]), sin(s[3])
  s.m:each(function(x, y) local k = K(x, y)
    local i = nil
    -- net of pits
    if (x * 2 + y) % 4 == 0 and not s.m:edge():has(x, y) then
      local u = ((x - s[1]) * ca + (y - s[2]) * sa)
      if u > -2 then c:put(x, y, SEED[((x - s[1]) + (y - s[2]) < 0) and 3 or 2], tok) end
    end
  end)
  -- pointed hilum end
  c:put(floor(s[1] - ca * 3 + 0.5), floor(s[2] - sa * 3 + 0.5), SEED[1], tok)
  local sx, sy = G.specAt(s.m, s.n, 30)
  if sx then c:put(sx, sy, SEED[6], tok) c:put(sx + 1, sy, SEED[5], tok) end
end
-- pulp scrap behind pip #2, then the pip over it
A.bead(c, 42.4, 51, 2.0, PULP, { spec = "#ffd8d4" })
for i, s in ipairs(seeds) do if i ~= 5 or true then pip(s) end end
pip(sprout)

local node = { 22, 38 }
local sm, sT, sS = A.stem(c, { { 22, 49 }, { 21, 41 }, { 23, 31 }, { 22, 23 } }, 1.3, 0.95, BR, { 0.22, 0.4, 0.58, 0.78, 0.9 })
-- split coat where the stem emerges
c:put(20, 48, SEED[1]) c:put(24, 48, SEED[1]) c:put(21, 49, BR[2]) c:put(23, 49, BR[1])
-- prickles
for _, p in ipairs{ { 24, 43 }, { 20, 36 }, { 24, 29 } } do c:put(p[1], p[2], BR[5]) end
c:put(23, 44, BR[5])
local function cot(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.tornBlade(c, ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, w * sin(pi * min(1, t * 0.88 + 0.12)) ^ 0.5)
  end, { ramp = CO, veins = {}, rib = 0.14, cool = "#3a7a6a", fold = 0.4 })
  m:each(function(x, y) local k = K(x, y) if T[k] < 0.14 and abs(S[k]) < 0.5 then c:put(x, y, S[k] < 0 and BR[4] or BR[3], ltok) end end)
  return m
end
cot(22, 38, 15, 34, 8, 36.5, 2.7)
cot(22, 38, 29, 33.5, 37, 34.5, 2.7)
-- upper stem to the first true leaf
A.stem(c, { { 22, 31 }, { 22, 28 }, { 22, 25 }, { 22, 22 } }, 0.95, 0.8, BR, { 0.3, 0.55, 0.8 })
c:put(21, 27, BR[5])
local function leaflet(ax, ay, cx, cy, bx, by, w, len)
  local W = A.sawW(len, w, { saw = 2.8, amp = 1.0, s0 = 0.2, s1 = 0.93, off = 0.12, k = 0.88, pw = 0.62 })
  local m, n, T, S = A.tornBlade(c, ax, ay, cx, cy, bx, by, W, {
    ramp = TL, veins = { 0.26, 0.4, 0.54, 0.68, 0.8 }, sweep = 1.8, rib = 0.14, ribEnd = 0.95, cool = "#3a7a6a", fold = 0.45 })
  return m
end
leaflet(22, 24, 11, 21, 7, 13, 3.1, 14)
leaflet(22, 24, 33, 20, 38, 12, 3.1, 15)
leaflet(22, 23, 21, 15, 24, 6, 4.2, 18)
A.save(c, "raspberry-seed")
