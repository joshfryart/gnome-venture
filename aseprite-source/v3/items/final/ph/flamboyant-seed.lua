-- flamboyant-seed (final, Opus aB32_0). Two long slim flamboyant (Delonix) seeds, tan with dark mottled bands and a pale
-- hilum, lying across a torn strip of bipinnate frond (paired oblong leaflets on a pale rachis, one leaflet bitten, ragged
-- broken rachis end). The front seed has sprouted: blush-red stem, two thick oblong cotyledons and a first feathery leaf
-- of serrated pinnae (the fern-like flamboyant leaf). AO + contact shadow under each seed.
-- quirk: one fallen scarlet flamboyant petal, the white-and-gold-streaked "standard" petal, lies curled on the frond.
local NAME = "flamboyant-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos, pi, atan = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi, math.atan
local c = A.new(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local RACH = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local SEED = { "#2e1a1c", "#4e2c24", "#734328", "#9a6236", "#c08c52", "#e4bc80" }
local STEM = { "#6e2a3a", "#a8484a", "#cf7a64", "#f0b090" }
local PET = { "#6e1630", "#a8202e", "#d83a2c", "#f2603a", "#ff9060", "#ffc49a" }
local GOLD = "#ffe38a"

-- seeds
local seeds = { { 22, 45, 6.2, 2.1, -0.32 }, { 34, 42, 6.0, 2.1, -0.12 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7) end
local allS = seeds[1].m:copy():add(seeds[2].m)

-- frond strip: leaflets along a rachis
local ax, ay, bx, by = 7, 50, 53, 37
local L = sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
local ux, uy = (bx - ax) / L, (by - ay) / L
local px, py = -uy, ux
if px + py < 0 then px, py = -px, -py end
local lm, ln = HP.mask(), {}
for j = 0, 13 do
  local t = 0.06 + j * 0.068
  local rx, ry = ax + (bx - ax) * t, ay + (by - ay) * t
  for _, s in ipairs{ -1, 1 } do
    if not (j == 0 and s == 1) and not (j == 13 and s == -1) then
      local dx, dy = s * px + ux * 0.4, s * py + uy * 0.4
      local d = sqrt(dx * dx + dy * dy) dx, dy = dx / d, dy / d
      local len = (j == 0 or j == 13) and 2.2 or 3.0
      local m, n = A.oval(rx + dx * (len + 0.6), ry + dy * (len + 0.6), len, 1.15, atan(dy, dx), 0.9)
      if j == 4 and s == 1 then m:cut(HP.ellipse(rx + dx * 5, ry + dy * 5 + 1, 2, 2)) end   -- bite
      m:cut(lm)
      lm:add(m) for k, v in pairs(n) do if m.s[k] then ln[k] = v end end
    end
  end
end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.shade(c, lm, ln, LEAF, { amb = 0.16, wrap = 0.3, bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
-- separate neighbouring leaflets: darken pixels whose leaflet differs from the one before along the rachis
lm:edge():each(function(x, y) local k = K(x, y)
  local s = (x - ax) * px + (y - ay) * py
  if s > 2.6 and not bias[k] then c:put(x, y, "#2f6a6e", ltok) end   -- cool reflected edge on the shade side
end)
-- rachis (pale), broken ragged at the left
local rtok = { r = { name = "rachis" } }
for i = 0, 60 do local t = i / 60
  local x, y = floor(ax - 2 * ux + (bx - ax + 2 * ux) * t + .5), floor(ay - 2 * uy + (by - ay + 2 * uy) * t + .5)
  if not allS:has(x, y) then c:put(x, y, (i % 9 == 0) and RACH[2] or RACH[3], rtok) end
end
c:put(4, 51, RACH[2], rtok) c:put(4, 52, RACH[1], rtok) c:put(5, 52, RACH[2], rtok)   -- torn fibres

-- quirk: scarlet standard petal, spoon shaped, white/gold streaks, wavy rim
local pm, pn = A.oval(13, 42, 4.2, 3.0, -0.6, 0.6)
pm:add(HP.line({ { 13, 44 }, { 16, 48 } }, 1))
pm:cut(HP.mask():set(9, 41):set(11, 39))
local ptok = { r = { name = "petal" } }
local pidx = A.shade(c, pm, (function() local n = X.pillow(pm, 2.2) return n end)(), PET, { amb = 0.12, wrap = 0.3, tok = ptok })
for _, p in ipairs{ {12, 42}, {13, 42}, {11, 41}, {14, 43}, {12, 40}, {15, 44}, {16, 47} } do c:put(p[1], p[2], (p[1] < 13) and A.CREAM or GOLD, ptok) end
c:put(14, 41, GOLD, ptok) c:put(15, 41, PET[5], ptok)
A.cast(bias, lm, pm, 1, 1, -1)
pm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not pm:has(x, y) and not allS:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- sprout stem (blush red), from the front seed's upper end
local stok = { r = { name = "stem" } }
local sm = A.stem(c, { { 38, 40 }, { 40, 33 }, { 35, 27 }, { 36, 17 } }, function(t) return 1.05 end, STEM, { cut = allS, tok = stok })
-- cotyledons: thick oblong
local ctok = { r = { name = "coty" } }
local cl = A.leaf(c, 35, 25, 31, 22, 26, 24, 2.3, LEAF, { pw = 0.45, fold = 0.3, novein = true, cut = sm, tok = ctok })
local cr = A.leaf(c, 37, 25, 42, 22, 47, 24, 2.3, LEAF, { pw = 0.45, fold = 0.3, novein = true, cut = sm, tok = ctok })
for _, p in ipairs{ {31, 23}, {32, 23}, {42, 22}, {43, 22} } do c:put(p[1], p[2], LEAF[6], ctok) end
for x = 28, 34 do if cl:has(x, 24) then c:put(x, 24, LEAF[2], ctok) end end
for x = 38, 45 do if cr:has(x, 24) then c:put(x, 24, LEAF[2], ctok) end end
-- first true leaf: rachis + 3 pairs of serrated pinnae (feather)
local tl = HP.mask()
local trach = { { 36, 18 }, { 36, 14 }, { 37, 10 }, { 38, 7 } }
local function pinna(x, y, dx, dy, len)
  local m = HP.mask()
  for i = 1, len do
    local cx, cy = x + dx * i, y + dy * i - i * 0.18
    m:set(floor(cx + .5), floor(cy + .5))
    -- leaflet teeth both sides, alternating
    if i % 2 == 0 then m:set(floor(cx + .5), floor(cy - 0.5)) else m:set(floor(cx + .5), floor(cy + 1.5)) end
  end
  return m
end
for _, q in ipairs{ { 0.15, 6 }, { 0.5, 5 }, { 0.8, 3 } } do
  local x, y = A.bez(trach, q[1])
  tl:add(pinna(x, y, -1, -0.15, q[2])):add(pinna(x, y, 1, -0.15, q[2]))
end
do local x, y = A.bez(trach, 1) tl:add(HP.ellipse(x, y - 1, 1, 1.4)) end
tl:cut(cl):cut(cr)
local tltok = { r = { name = "tl" } }
tl:each(function(x, y)
  local i = 4
  if not tl:has(x, y - 1) then i = 5 end
  if not tl:has(x, y + 1) then i = 3 end
  if x > 40 and i < 5 then i = i - 1 end
  c:put(x, y, LEAF[i], tltok)
end)
c:put(31, 13, LEAF[6], tltok)
for i = 0, 20 do local x, y = A.bez(trach, i / 20) c:put(floor(x + .5), floor(y + .5), i > 17 and LEAF[4] or RACH[2], tltok) end

-- seeds: slim, mottled bands, pale hilum at one end, glossy specular
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, vis, s.n, SEED, { amb = 0.08, wrap = 0.2, tok = tok, bias = sb, cuts = { 0.15, 0.3, 0.48, 0.66, 0.84 } })
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / s[3]
    local m = X.hash(floor(u * 4.2 + 9), floor((-dx * sa + dy * ca) * 1.2 + 9), i)
    if m > 0.62 and abs(u) < 0.85 then A.step(c, idx, SEED, x, y, -2, tok) end
  end)
  -- hilum
  local hx, hy = floor(s[1] - ca * (s[3] - 1) + .5), floor(s[2] - sa * (s[3] - 1) + 1.5)
  c:put(hx, hy, SEED[6], tok)
  -- specular
  local bx2, by2 = A.specAt(vis, s.n, 30)
  c:put(bx2, by2, A.CREAM, tok) c:put(bx2 + 1, by2, SEED[6], tok)
end

A.save(c, NAME)
