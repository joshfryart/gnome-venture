-- kowhai-seed (run3, Opus single pass). Three hard, glossy golden-ochre kowhai seeds (oblong, dark hilum notch, waxy
-- glint) on a torn olive leaf scrap tilted down to the right (midrib, veins, both ends ragged, AO + contact shadow).
-- The right seed has split its coat and sprouted: two round cotyledons low on the stem and a first true kowhai leaf,
-- a slim arching rachis with alternate pairs of tiny oval leaflets (the fern-like kowhai frond).
-- quirk: one tiny golden kowhai flower, the curved claw-shaped bell, already dangles from the seedling.
local NAME = "kowhai-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new5(NAME)
local LEAF = { "#243c26", "#35562c", "#4c7432", "#6c943c", "#98b450", "#c8d67a" }
local FROND = { "#1a4232", "#235c3c", "#317a44", "#4c9a4a", "#78ba58", "#aed874" }
local SEED = { "#4a2a14", "#7a4818", "#ab6e1c", "#d39a2a", "#efc24a", "#fde28a" }
local GOLD = { "#9a5a12", "#d98a1a", "#f5b82e", "#ffe070" }
local STEM = { "#4a5a2c", "#6e8a3a", "#9cb85a", "#cfe08e" }
local TORN, COOL = "#e2e6a8", "#3c6468"

-- scrap: broad olive leaf piece, torn both ends
local lm, ln, LT, LS, len = G.blade(8, 44, 31, 46, 56, 53, function(t)
  return max(0.6, 6.6 * sin(pi * min(1, 0.2 + t * 0.62)) ^ 0.5)
end, { fold = 0.32 })
G.tear(lm, function(x, y) local t = LT[K(x, y)] return t < 0.12 or t > 0.86 end, 5, 2)
-- seeds: cx, cy, rx, ry, ang
local seeds = { { 17, 45, 3.6, 2.4, 0.3 }, { 27, 46, 3.5, 2.3, -0.25 }, { 40, 48, 3.7, 2.5, 0.45 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.75) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 then c:put(x, y, s <= 0 and "#dbe49a" or LEAF[3], ltok) return end
  local ph = (t * len + abs(s) * 4.5) / 5.5
  if ph - floor(ph) < 0.14 and abs(s) < 0.78 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LT[k] < 0.14 or LT[k] > 0.84 then c:put(x, y, TORN, ltok) elseif LS[k] > 0.6 then c:put(x, y, COOL, ltok) end end)

-- sprout stem from the right seed
local stok = { r = { name = "stem" } }
local sp = { { 41, 46 }, { 43, 38 }, { 40, 30 }, { 41, 20 } }
local sm, sn = G.tube(sp, function(t) return 1.05 - 0.15 * t end)
sm:cut(seeds[3].m)
G.toneN(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3, tok = stok })
-- cotyledons: two round fleshy seed leaves
local ftok = { r = { name = "frond" } }
for _, q in ipairs{ { 38.5, 35, 2.6, 1.7, -0.35 }, { 46, 34, 2.6, 1.7, 0.35 } } do
  local m, n = G.oval(q[1], q[2], q[3], q[4], q[5], 0.9) m:cut(sm)
  G.toneN(c, m, n, { "#3c6a30", "#5e8a3a", "#88ac4a", "#b8d06a" }, { tok = ftok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
end
-- true leaf: rachis arching left from the stem top, alternate tiny oval leaflets
local rp = { { 41, 21 }, { 37, 15 }, { 28, 13 }, { 19, 16 } }
local fm = HP.mask()
local lfs = {}
for i = 1, 6 do
  local t = 0.12 + (i - 1) * 0.165
  local x, y = G.bez(rp, t)
  local x2, y2 = G.bez(rp, min(1, t + 0.02))
  local tx, ty = x2 - x, y2 - y local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  for _, side in ipairs{ -1, 1 } do
    local nx, ny = -ty * side, tx * side
    local ux, uy = G.rot(nx, ny, side * -0.55)
    local cx, cy = x + ux * 2.4, y + uy * 2.4
    local m, n = G.oval(cx, cy, 2.1, 1.25, math.atan(uy, ux), 0.8)
    lfs[#lfs + 1] = { m = m, n = n }
    fm:add(m)
  end
end
-- terminal leaflet
do local m, n = G.oval(17.5, 16.8, 2.2, 1.3, 2.9, 0.8) lfs[#lfs + 1] = { m = m, n = n } fm:add(m) end
for _, f in ipairs(lfs) do
  G.toneN(c, f.m, f.n, FROND, { tok = ftok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
end
for i = 0, 40 do local x, y = G.bez(rp, i / 40) c:put(floor(x + .5), floor(y + .5), i < 20 and STEM[2] or STEM[1], stok) end

-- quirk: tiny golden kowhai flower dangling from under the rachis (curved claw bell)
local fl = { { 34, 15 }, { 35, 18 }, { 34, 21 }, { 31, 23 } }
local gm, gn2 = G.tube(fl, function(t) return 0.4 + 1.3 * sin(pi * min(1, 0.25 + t * 0.7)) end)
G.toneN(c, gm, gn2, GOLD, { tok = { r = { name = "flower" } }, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
c:px(34, 15, STEM[1]) c:px(31, 23, GOLD[1])

-- seeds last: glossy oblong, hilum notch on the lower edge, split coat on the sprouting one
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local idx = G.toneN(c, s.m, s.n, SEED, { tok = tok, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, amb = 0.1, wrap = 0.3 })
  local ca, sa = cos(s[5]), sin(s[5])
  -- hilum: small dark notch below centre
  local hx, hy = floor(s[1] + sa * 1.4 + .5), floor(s[2] + ca * 1.4 + .5)
  c:put(hx, hy, SEED[1], tok) c:put(hx - 1, hy, SEED[2], tok)
  local px, py = G.specAt(s.m, s.n, 50) if px then c:px(px, py, "#fff4d6") c:px(px + 1, py, SEED[6]) end
  -- cool reflected rim on the shade side
  local rim = X.rim(s.n)
  s.m:edge():each(function(x, y) if (rim[K(x, y)] or 0) > 0.62 then c:put(x, y, "#7c6a6a", tok) end end)
end
-- split seed coat where the stem leaves seed 3
c:put(41, 46, SEED[1]) c:put(42, 46, SEED[5]) c:put(41, 45, STEM[2])
G.save2(c, NAME)
