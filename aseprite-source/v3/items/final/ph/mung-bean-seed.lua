-- mung-bean-seed (final, Opus). Three small glossy olive-green mung seeds (white hilum dash each) on a torn scrap of
-- an ovate mung leaflet (midrib, swept veins, V-fold light, pale torn edge on the right, AO + contact shadow under
-- each seed). The right seed has germinated: a thick pale bean-sprout stem rising in a soft S, a white radicle
-- over the leaf edge, and the first trifoliate leaf (three pointed ovate leaflets) that shows the mung plant.
-- quirk: the split green seed coat is still stuck on the tip of the middle leaflet like a little cap.
local NAME = "mung-bean-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)

local LEAF = { "#173f36", "#21593f", "#2f7745", "#46974c", "#6cb755", "#a2d370" }
local TORN = "#d4eca6"
local SEED = { "#14201a", "#1f3420", "#2f4a24", "#45622a", "#647e34", "#a2b45a" }
local SPR = { "#8c9a6a", "#bcc48e", "#dfe3b4", "#f6f4d8" }
local HIL = "#f4eed0"

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 17, 49, 3.0, 2.2, -0.15 }, { 26, 52, 2.9, 2.2, 0.25 }, { 35, 48, 3.0, 2.3, -0.4 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end

-- radicle: from the right seed down over the leaf's lower edge
local rm, rn, RT, RS = A.tube({ { 37, 50 }, { 40, 52 }, { 42, 54 }, { 46, 56 } }, function(t) return 1.5 * (1 - t) ^ 0.8 + 0.2 end)
rm:cut(seeds[3].m)
-- sprout stem
local sp = { { 35, 46 }, { 33, 38 }, { 37, 30 }, { 34, 22 } }
local sm, sn = A.tube(sp, function(t) return 1.35 - 0.3 * t end)
sm:cut(seeds[3].m)

-- leaf scrap with a ragged tear on the right
local bias = {}
local tear = HP.mask()
local jag = { 0, 2, -1, 3, 1, -2, 2, 0, -1, 1 }
for y = 30, 64 do for x = 40, 64 do if x > 47 + jag[y % 10 + 1] then tear:set(x, y) end end end
local lm0 = A.blade(5, 51, 26, 44, 56, 50, function(t)
  if t > 0.985 then return -1 end
  return max(0.4, 7.6 * sin(pi * min(1, t * 0.98 + 0.04)) ^ 0.7) end, {})
lm0:cut(tear)
for _, s in ipairs(seeds) do X.ao(bias, lm0, s.m, 1, -1) A.cast(bias, lm0, s.m, 1, 2, -1) end
X.ao(bias, lm0, sm, 1, -1)
A.cast(bias, lm0, rm, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
local lm = A.leaf(c, 5, 51, 26, 44, 56, 50, 7.6, LEAF, { cut = tear, bias = bias, tok = ltok, pw = 0.7, vs = 4.2, fold = 0.4 })
-- torn edge: pale exposed tissue on the right-most pixel of each row
lm:each(function(x, y) if x >= 42 and not lm:has(x + 1, y) then c:put(x, y, TORN, ltok) end end)
-- cool reflected light along the lower-right rim
lm:edge():each(function(x, y) if x < 42 and y > 51 and not bias[K(x, y)] and X.hash(x, y, 3) > 0.35 then c:put(x, y, "#3a6c72", ltok) end end)

-- radicle (white bean-sprout root)
A.shade(c, rm, rn, SPR, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "root" } } })
c:put(46, 56, SPR[2], { r = { name = "root" } })
-- stem
local stok = { r = { name = "stem" } }
A.shade(c, sm, sn, SPR, { amb = 0.15, wrap = 0.3, cuts = { 0.28, 0.52, 0.78 }, tok = stok })

-- trifoliate leaf: petiole tip at (34,22)
local L2 = { "#173f36", "#21593f", "#2f7745", "#46974c", "#6cb755", "#a2d370" }
local mid = A.leaf(c, 34, 21, 33, 14, 35, 8, 3.4, L2, { pw = 0.65, vs = 3.0, fold = 0.5, tok = { r = { name = "lmid" } } })
local lt = A.leaf(c, 33, 22, 27, 18, 20, 21, 3.0, L2, { pw = 0.65, vs = 3.0, fold = 0.5, cut = mid, tok = { r = { name = "lleft" } } })
local rt = A.leaf(c, 35, 22, 41, 18, 48, 20, 3.0, L2, { pw = 0.65, vs = 3.0, fold = 0.5, cut = mid, tok = { r = { name = "lright" } } })
-- AO where the leaflets join the petiole
for _, q in ipairs{ { 33, 21 }, { 35, 21 }, { 34, 20 } } do if c:get(q[1], q[2]) then c:put(q[1], q[2], L2[1], { r = { name = "joint" } }) end end
c:put(34, 22, SPR[2], stok)

-- quirk: seed-coat cap on the middle leaflet tip
local cap = { r = { name = "cap" } }
for _, q in ipairs{ { 34, 7, 4 }, { 35, 7, 5 }, { 36, 7, 3 }, { 33, 8, 3 }, { 34, 8, 2 }, { 35, 8, 2 }, { 36, 8, 1 }, { 35, 6, 4 } } do
  c:put(q[1], q[2], SEED[q[3]], cap) end
c:put(34, 7, SEED[6], cap)

-- seeds last
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  for j = i + 1, #seeds do X.ao(sb, s.m, seeds[j].m, 1, -1) end
  A.shade(c, s.m, s.n, SEED, { amb = 0.1, wrap = 0.3, bias = sb, tok = tok })
  local ca, sa = cos(s[5]), sin(s[5])
  for _, u in ipairs{ -0.7, 0.5 } do
    local hx, hy = floor(s[1] + u * ca + 1.0 * (-sa) + 0.5), floor(s[2] + u * sa + 1.0 * ca + 0.5)
    if s.m:has(hx, hy) then c:put(hx, hy, HIL, tok) end
  end
  local gx, gy = A.specAt(s.m, s.n, 40)
  if gx then c:put(gx, gy, "#e8f4b0", tok) end
end
-- the sprouting seed's coat is split: a dark seam where the stem comes out
c:put(35, 46, SEED[1], { r = { name = "seed3" } })
c:put(34, 46, SEED[2], { r = { name = "seed3" } })

A.save(c, NAME)
