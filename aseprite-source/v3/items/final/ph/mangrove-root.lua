-- mangrove-root (final, Opus single pass). A slim red-mangrove trunk stub (sawn top: pale end grain with growth
-- rings and a dark pith) standing on five arching prop roots that splay out and plunge into a thin strip of brackish
-- water. Bark: cylinder-lit 6-tone grey-brown, twisting fissure lines along each root, pale lenticel dots, AO where
-- roots leave the trunk and where they cross; waterline rings where roots enter the water.
-- quirk: a long green propagule (the mangrove's pencil-shaped seedling) dangles from a twig on the trunk.
local NAME = "mangrove-root"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, max, min = math.floor, math.abs, math.sin, math.max, math.min
local c = A.new(NAME)

local BARK = { "#2e1e22", "#4a3030", "#6a4636", "#8a6044", "#ab7f5c", "#cfa47c" }
local FAR = { "#261a20", "#3c2a2c", "#563c34", "#72523e", "#8e6a50", "#ae8a68" }
local END = { "#7a5034", "#b07e50", "#d8ac74", "#f0d29a" }
local SEA = { "#28466e", "#326c96", "#4b98b8", "#7cc4cc", "#b6ead8" }
local PROP = { "#1f3e2c", "#2e5c36", "#457c3e", "#64a04a", "#92c464", "#c8e48c" }
local CAP = { "#4a2a24", "#74422c", "#a0643a" }

-- water strip (drawn first; roots overlap, then a front lip of water is re-laid over the root feet)
local wm = HP.ellipse(32, 53, 23, 2.6)
local wtok = { r = { name = "water" } }
wm:each(function(x, y)
  local i = 3
  if y <= 51 then i = 4 end
  if y >= 55 then i = 2 end
  if y == 53 and (x % 7 == 2 or x % 7 == 3) then i = 4 end
  if y == 54 and x % 9 == 5 then i = 4 end
  c:put(x, y, SEA[i], wtok)
end)
c:put(14, 52, SEA[5], wtok) c:put(15, 52, SEA[5], wtok)

-- roots: back pair (darker ramp), then trunk, then front roots
local roots = {
  { p = { { 31, 27 }, { 24, 23 }, { 15, 31 }, { 12, 53 } }, w = 1.6, back = true },
  { p = { { 33, 26 }, { 41, 21 }, { 50, 32 }, { 53, 52 } }, w = 1.6, back = true },
  { p = { { 31, 33 }, { 25, 33 }, { 20, 43 }, { 20, 54 } }, w = 1.9 },
  { p = { { 33, 33 }, { 40, 34 }, { 43, 44 }, { 43, 54 } }, w = 1.9 },
  { p = { { 32, 36 }, { 33, 42 }, { 30, 48 }, { 31, 55 } }, w = 1.8 },
}
local trunkP = { { 32, 11 }, { 32, 19 }, { 31.5, 28 }, { 32, 36 } }
local tm, tn, TT, TS = A.tube(trunkP, function(t) return 3.2 + t * 0.6 end)

local all = HP.mask()
local function drawRoot(r, ramp, aoMasks)
  local m, n, T, S = A.tube(r.p, function(t) return r.w + (1 - t) * 0.5 - t * 0.2 end)
  local b = {}
  for _, o in ipairs(aoMasks) do X.ao(b, m, o, 2, -1) end
  local tok = { r = { name = "root" } }
  local idx = A.tone(c, m, n, ramp, { bias = b, tok = tok, amb = 0.08, wrap = 0.22, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
  -- twisting fissure lines (spiral across the root) + lenticels
  m:each(function(x, y) local k = K(x, y)
    local ph = T[k] * 9 + S[k] * 0.9
    if ph - floor(ph) < 0.14 and abs(S[k]) < 0.8 then A.step(c, idx, ramp, x, y, -1, tok) end
    if X.hash(x, y, 11) > 0.93 and S[k] < 0.2 and idx[k] and idx[k] >= 3 then c:put(x, y, ramp[6], tok) end
  end)
  -- waterline ring at the foot
  m:each(function(x, y) if y == 51 or y == 52 then c:put(x, y, ramp[2], tok) end end)
  all:add(m)
  return m
end
local rb1 = drawRoot(roots[1], FAR, { tm })
local rb2 = drawRoot(roots[2], FAR, { tm })

-- trunk
local ttok = { r = { name = "trunk" } }
local tb = {}
local tidx = A.tone(c, tm, tn, BARK, { tok = ttok, bias = tb, amb = 0.08, wrap = 0.22, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
-- vertical bark fissures with a slight twist
tm:each(function(x, y) local k = K(x, y)
  local s = TS[k] + TT[k] * 0.6
  local ph = s * 2.4 + 0.1 * sin(y * 0.9)
  if ph - floor(ph) < 0.18 and abs(TS[k]) < 0.85 then A.step(c, tidx, BARK, x, y, -1, ttok) end
  if X.hash(x, y, 4) > 0.94 and TS[k] < 0 then c:put(x, y, BARK[6], ttok) end
end)
-- sawn top: elliptic end grain cap with rings and pith
local em = HP.ellipse(32, 11, 3.3, 1.6)
em:each(function(x, y)
  local d = ((x - 32) / 3.8) ^ 2 + ((y - 11) / 2.0) ^ 2
  local i = d > 0.62 and 2 or (d > 0.3 and 3 or 4)
  if d > 0.85 then i = 1 end
  c:put(x, y, END[i], ttok)
end)
c:put(32, 11, END[1], ttok) c:put(30, 11, END[4], ttok)
-- bark rim just under the cap (bevel)
for x = 29, 35 do if tm:has(x, 13) then A.step(c, tidx, BARK, x, 13, -1, ttok) end end

-- front roots with AO against the trunk
for i = 3, 5 do drawRoot(roots[i], BARK, { tm, rb1, rb2 }) end
-- contact darkening where front roots leave the trunk
for _, p in ipairs{ { 30, 33 }, { 34, 33 }, { 32, 37 }, { 31, 34 }, { 33, 34 } } do
  if tm:has(p[1], p[2]) then A.step(c, tidx, BARK, p[1], p[2], -2, ttok) end end

-- water lip in front of the root feet (roots go INTO the water)
wm:each(function(x, y)
  if y >= 54 and all:has(x, y) then c:put(x, y, SEA[3], wtok) end
end)
-- ripple rings around root feet
for _, fx in ipairs{ 12, 20, 31, 43, 53 } do
  for _, dx in ipairs{ -3, 3 } do if wm:has(fx + dx, 53) and not all:has(fx + dx, 53) then c:put(fx + dx, 53, SEA[5], wtok) end end
end

-- quirk: propagule hanging from a short twig on the trunk's right
local twm, twn = A.tube({ { 35, 17 }, { 37, 16 }, { 39, 16 }, { 40, 17 } }, function() return 0.6 end)
twm:cut(tm)
A.tone(c, twm, twn, BARK, { tok = ttok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
local pm, pn = A.tube({ { 40, 19 }, { 40.5, 23 }, { 40.5, 27 }, { 41, 31 } }, function(t) return 1.1 - t * 0.55 end)
local ptok = { r = { name = "propagule" } }
local pidx = A.tone(c, pm, pn, PROP, { tok = ptok, amb = 0.1, wrap = 0.3, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
-- brown cap (the old fruit) at the top
for _, q in ipairs{ { 39, 18, 2 }, { 40, 18, 3 }, { 41, 18, 2 }, { 40, 17, 1 }, { 39, 19, 1 }, { 41, 19, 1 } } do c:put(q[1], q[2], CAP[q[3]], ptok) end
c:put(40, 21, PROP[6], ptok)

A.fin(c, NAME)
