-- banana-seed pass A. Four small, hard, glossy black wild-banana seeds on a pleated strip of banana leaf
-- (pale midrib along one edge, parallel veins, torn margin split along the veins).
-- quirk: the end of the leaf strip is still rolled up like a cigar, the way new banana leaves unfurl.
local NAME = "banana-seed.pA"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_g1.lua")
local HP, X, c, P = G.new(NAME)
local K = G.K
local LEAF = { "#1d4a3a", "#2a6644", "#3b854c", "#58a552", "#80c35c", "#acdc78" }
local RIB  = { "#5d7a3a", "#7f9a4a", "#a3b85e", "#c4d27a", "#e0e6a0", "#f0f2c0" }
local SEED = { "#1b1320", "#2a1d2e", "#3b2a3e", "#503b52", "#6a536a", "#8a748a" }

local AX, AY, TH = 7, 41, -0.44
local eu = { math.cos(TH), math.sin(TH) }
local ev = { -math.sin(TH), math.cos(TH) }
local function UV(x, y) local dx, dy = x - AX, y - AY return dx * eu[1] + dy * eu[2], dx * ev[1] + dy * ev[2] end
local function XY(u, v) return AX + u * eu[1] + v * ev[1], AY + u * eu[2] + v * ev[2] end
local L, TC, TR, TV = 37, 41.6, 4.8, 15          -- strip length, tube centre (u), tube radius, tube length (v)
local FING = { 15.5, 18.5, 14.5, 17.5 }            -- torn ribbon lengths

local strip, rib, tube, cap = HP.mask(), HP.mask(), HP.mask(), HP.mask()
local U, V = {}, {}
for y = 0, 63 do for x = 0, 63 do
  local u, v = UV(x, y)
  local k = K(x, y)
  U[k], V[k] = u, v
  local umin = 0.5 + X.hash(math.floor(v / 1.5), 3, 7) * 3
  local f, slit = 1, false
  for _, u0 in ipairs{ 6, 15, 25 } do
    local d = u - (u0 + 0.6 * v)
    if d > 0 then f = f + 1 end
    if math.abs(d) < 0.5 + math.max(0, v - 8) * 0.1 and v > 7 then slit = true end
  end
  local vmax = FING[f] - X.hash(math.floor(u), 1, 9) * 0.9
  if u >= umin and u <= L and v >= 0 and v <= vmax and not slit then
    if v < 2.4 then rib:set(x, y) else strip:set(x, y) end
  end
  if math.abs(u - TC) <= TR and v >= -0.8 and v <= TV then tube:set(x, y) end
  local cu, cv = (u - TC) / (TR + 0.4), (v - TV) / 3.2
  if cu * cu + cv * cv <= 1 then cap:set(x, y) end
end end
tube:cut(cap) strip:cut(tube):cut(cap) rib:cut(tube)

-- seeds: small irregular angular pebbles
local seeds = { { 12.5, 7.5, 3.9, 1 }, { 22.5, 10.5, 3.5, 2 }, { 31, 7, 3.8, 3 } }
local seedAll = HP.mask()
for i, s in ipairs(seeds) do
  local x, y = XY(s[1], s[2])
  local pts = {}
  for j = 0, 5 do
    local a = j / 6 * 2 * math.pi + s[4]
    local r = s[3] * (0.88 + X.hash(j, s[4], 5) * 0.2)
    pts[#pts + 1] = { x + math.cos(a) * r * 1.1, y + math.sin(a) * r * 0.9 }
  end
  local m = c:poly(pts)
  local n = X.pillow(m, 3.2)
  s.m, s.n, s.x, s.y = m, n, x, y
  seedAll:add(m)
end

-- blade: pleats across the parallel veins
local bias = {}
X.ao(bias, strip, seedAll, 1, -1) G.cast(bias, strip, seedAll, 1, 2, -1) G.cast(bias, strip, seedAll, 2, 2, -1)
X.ao(bias, strip, tube, 1, -1) X.ao(bias, strip, cap, 1, -1)
local n = {}
strip:each(function(x, y) local k = K(x, y)
  local ph = (U[k] - 0.6 * V[k]) / 2.2 * math.pi
  local a = math.sin(ph) * 0.55
  n[k] = { G.norm(eu[1] * a + ev[1] * 0.12, eu[2] * a + ev[2] * 0.12, 1) }
end)
local ltok = { r = { name = "leaf" } }
G.toneN(c, strip, n, LEAF, { bias = bias, tok = ltok, amb = 0.15, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
-- midrib: rounded rod
local rn = {}
rib:each(function(x, y) local k = K(x, y) local s = (V[k] - 1.2) / 1.7 rn[k] = { G.norm(ev[1] * s, ev[2] * s, math.sqrt(math.max(0.05, 1 - s * s))) } end)
local rb = {} X.ao(rb, rib, tube, 1, -1)
G.toneN(c, rib, rn, RIB, { tok = { r = { name = "rib" } }, bias = rb })
-- tube (rolled end)
local tn = {}
tube:each(function(x, y) local k = K(x, y) local s = (U[k] - TC) / (TR + 0.5) tn[k] = { G.norm(eu[1] * s, eu[2] * s, math.sqrt(math.max(0.05, 1 - s * s))) } end)
local ttok = { r = { name = "tube" } }
local tb = {} X.ao(tb, tube, cap, 1, -1)
G.toneN(c, tube, tn, LEAF, { tok = ttok, amb = 0.1, bias = tb })
tube:each(function(x, y) local k = K(x, y)
  if V[k] < 2.2 then c:put(x, y, (U[k] - TC) < 0 and RIB[5] or RIB[3], ttok) end      -- midrib wraps round the roll
end)
-- end cap: the spiral of rolled leaf seen end-on
cap:each(function(x, y) local k = K(x, y)
  local cu, cv = (U[k] - TC) / (TR + 0.4), (V[k] - TV) / 3.2
  local r = math.sqrt(cu * cu + cv * cv)
  local ang = math.atan(cv, cu)
  local col = r > 0.72 and (cu < 0 and LEAF[5] or LEAF[3]) or LEAF[1]
  if r > 0.3 and r < 0.52 and cu + cv * 0.3 < 0.25 then col = LEAF[4] end
  c:put(x, y, col, ttok)
end)

-- seeds
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  G.toneN(c, s.m, s.n, SEED, { tok = tok, amb = 0.05, wrap = 0.15, cuts = { 0.3, 0.48, 0.62, 0.74, 0.86 } })
  local rim = X.rim(s.n)
  s.m:edge():each(function(x, y) if rim[K(x, y)] > 0.75 then c:put(x, y, "#4a4f80", tok) end end)
  local bx, by = G.specAt(s.m, s.n, 50)
  c:put(bx, by, "#f4ecf6", tok) c:put(bx + 1, by, SEED[6], tok)
end
G.save(c, NAME)
