-- jostaberry-seed (final pass, Opus aC13_2). A scatter of tiny glossy jostaberry seeds (dark plum-brown ovals, each
-- with its own glint and contact shadow) on a torn, three-lobed currant-type leaf scrap (palmate veins from the
-- base, toothed margin, cool bounce light on the shade edges). One seed has germinated: a slim stem, two round
-- cotyledons and a first true leaf that is already three-lobed like the parent.
-- quirk: a single drop of purple jostaberry juice has pooled on the leaf, catching the light.
local NAME = "jostaberry-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF = { "#173a34", "#22543e", "#30704a", "#468e52", "#68ac5c", "#9ccc74" }
local SEED = { "#1e1222", "#34202e", "#4e2e3a", "#6c4246", "#946052", "#c49070" }
local JUICE = { "#2a1440", "#46205e", "#6a2e80", "#9446a0", "#c070c4", "#ecc2ee" }
local STEM = { "#3c6a42", "#5e9050", "#8cbc6c", "#c0de98" }
local COOL = "#3a6676"

-- seeds
local seeds = { { 18, 45, 2.6, 1.7, 0.4 }, { 25, 49, 2.6, 1.7, -0.2 }, { 26, 42, 2.5, 1.6, 0.9 }, { 34, 46, 2.6, 1.7, -0.6 }, { 41, 50, 2.5, 1.6, 0.2 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7) end
local juice = A.rell(19.5, 38.5, 1, 0, 2.6, 2.2)
local jn = X.sphere(19.2, 38.2, 2.6, juice)

-- leaf scrap: three toothed lobes fanning from a base point
local ltok = { r = { name = "leaf" } }
local bx, by = 30, 56
local lobes = { { 18, 46, 8, 33, 7.0 }, { 27, 40, 28, 31, 7.6 }, { 44, 44, 54, 34, 7.0 } }
local lm = HP.mask()
local bias = {}
local lobeMasks = {}
for i, L in ipairs(lobes) do
  local m = A.blade(bx, by, L[1], L[2], L[3], L[4], function(t)
    if t > 0.985 then return -1 end
    return max(0.5, L[5] * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.8)
  end, { fold = 0.3 })
  lobeMasks[i] = m
  lm:add(m)
end
-- torn bite out of the right lobe's margin (scrap, not a whole leaf)
local tearM = HP.mask()
tearM:add(A.rell(52.5, 43.5, 1, 0, 3.0, 2.6))
local allSeed = HP.mask() for _, s in ipairs(seeds) do allSeed:add(s.m) end
X.ao(bias, lm, allSeed, 1, -1) A.cast(bias, lm, allSeed, 1, 1, -1)
X.ao(bias, lm, juice, 1, -1)
-- paint each lobe (centre last so it overlaps)
for _, i in ipairs{ 1, 3, 2 } do
  local L = lobes[i]
  local cut = tearM:copy()
  if i ~= 2 then cut:add(lobeMasks[2]) end
  local m, T, S = A.leaf(c, bx, by, L[1], L[2], L[3], L[4], L[5], LEAF, {
    wfn = function(t) if t > 0.985 then return -1 end return max(0.5, L[5] * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.8) end,
    fold = 0.3, serr = 3.0, vs = 3.4, cut = cut, bias = bias, tok = ltok, cool = COOL, cuts = { 0.22, 0.38, 0.54, 0.7, 0.86 } })
  -- a dark seam where the side lobes tuck under the centre lobe
  if i ~= 2 then m:each(function(x, y) if lobeMasks[2]:grow(1):has(x, y) then c:put(x, y, LEAF[2], ltok) end end) end
end
-- torn edge: pale fibre
lm:cut(tearM)
lm:edge():each(function(x, y) if tearM:grow(1):has(x, y) and y < 44 then c:put(x, y, "#c8dc90", ltok) end end)
-- petiole stub
for _, q in ipairs{ { 30, 57, 4 }, { 30, 58, 3 }, { 29, 59, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout from seed 4 (drawn before the seeds)
local s4 = seeds[4]
local stok = { r = { name = "stem" } }
local sp = { { s4[1] + 1, s4[2] - 1 }, { s4[1] + 5, s4[2] - 8 }, { s4[1] + 5, s4[2] - 15 }, { s4[1] + 6, s4[2] - 22 } }
local sm = A.stem(c, sp, function(t) return 1.0 end, { STEM[2], STEM[3], STEM[4], "#e4f2c4" }, { tok = stok, cut = s4.m })
local tx, ty = A.bez(sp, 1)
local cot = HP.mask()
for _, q in ipairs{ { tx - 4.6, ty + 0.6, -0.25 }, { tx + 4.8, ty + 0.9, 0.3 } } do
  local m, n = A.oval(q[1], q[2], 3.4, 2.3, q[3], 0.6)
  m:cut(sm)
  A.shade(c, m, n, LEAF, { amb = 0.12, wrap = 0.3, tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
  c:put(floor(q[1] - 1 + .5), floor(q[2] - 0.5 + .5), LEAF[6], ltok)
  cot:add(m)
end
-- first true leaf: three small lobes on a short petiole
local tl = HP.mask()
tl:add(A.rell(tx + 0.5, ty - 5.5, 0, 1, 2.6, 1.9)):add(A.rell(tx - 2.6, ty - 3.4, 0.7, 0.7, 2.0, 1.6)):add(A.rell(tx + 3.4, ty - 3.2, -0.7, 0.7, 2.0, 1.6))
tl:cut(cot)
A.shade(c, tl, X.pillow(tl, 1.6), LEAF, { amb = 0.12, wrap = 0.28, tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
for i = 0, 3 do c:put(floor(tx + .5), floor(ty + .5) - i, i < 1 and STEM[3] or LEAF[4], ltok) end
c:put(floor(tx - 2 + .5), floor(ty - 3.4 + .5), LEAF[4], ltok) c:put(floor(tx + 3 + .5), floor(ty - 3.2 + .5), LEAF[3], ltok)
-- seed-coat cap still riding on the left cotyledon tip
c:put(floor(tx - 7.6 + .5), floor(ty + 0.2 + .5), SEED[3], stok) c:put(floor(tx - 7.6 + .5), floor(ty + 1.2 + .5), SEED[2], stok)

-- seeds: glossy, each with its own glint
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, s.m, s.n, SEED, { amb = 0.06, wrap = 0.2, tok = tok, cuts = { 0.3, 0.48, 0.64, 0.8, 0.92 } })
  local gx, gy = A.specAt(s.m, s.n, 40)
  c:put(gx, gy, SEED[6], tok)
  -- tiny pale hilum on the lower-right end
  local ex, ey = floor(s[1] + cos(s[5]) * (s[3] - 0.6) + .5), floor(s[2] + sin(s[5]) * (s[3] - 0.6) + .5)
  if s.m:has(ex, ey) then c:put(ex, ey, SEED[5], tok) end
end
-- juice drop: deep purple glass bead with bright rim highlight and pale core
local jtok = { r = { name = "juice" } }
A.shade(c, juice, jn, JUICE, { amb = 0.1, wrap = 0.1, tok = jtok, cuts = { 0.2, 0.4, 0.58, 0.74, 0.9 } })
juice:edge():each(function(x, y) if x > 19 and y > 38 then c:put(x, y, JUICE[5], jtok) end end)
c:put(18, 37, A.CREAM, jtok) c:put(19, 37, JUICE[6], jtok)
-- stain trailing from the drop
for _, q in ipairs{ { 17, 41 }, { 16, 42 } } do c:put(q[1], q[2], JUICE[3], jtok) end
A.save(c, NAME)
