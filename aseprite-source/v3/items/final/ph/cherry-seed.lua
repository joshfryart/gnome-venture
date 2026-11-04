-- cherry-seed (final pass, Opus single pass). Two cherry stones (round-oval, cream-tan, raised suture ridge with a
-- dark groove beside it, cool shade side, AO + contact shadow on the leaf) resting on a torn scrap of cherry leaf
-- (serrated margin, midrib + swept veins, V-fold light, ragged pale tear edge on the right). The right stone has
-- split along its suture and sprouted: pale stem, two fleshy oval cotyledons, and a first true leaf that shows the
-- cherry shape (ovate, pointed, serrated, veined).
-- quirk: a sliver of red cherry flesh still clings to the left stone.
local NAME = "cherry-seed"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB1r1_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = A.new(NAME)

local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local PIT  = { "#4e3226", "#7a5638", "#a87e52", "#cfa670", "#e8c890", "#fff0c4" }
local STEM = { "#5a7a4a", "#8ab86a", "#b8dc92", "#e2f2bc" }
local TEAR, COOL = "#d6ec9a", "#3a6c72"
local RED  = { "#7a1534", "#dc2f37", "#ff9a7a" }

local pits = { { 19, 47, 4.3, 3.5, -0.35 }, { 33, 44, 4.3, 3.5, -0.5 } }
for _, s in ipairs(pits) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end

-- leaf scrap on the diagonal, torn off on the right
local lm, ln, LT, LS, len = A.blade(6, 55, 28, 52, 58, 38, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 9.0 * sin(pi * min(1, t * 0.8 + 0.06)) ^ 0.6)
end, { fold = 0.4 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  -- ragged tear across the blade
  local jag = 0.74 + 0.05 * sin(s * 9.0)
  if t > jag then cut[#cut + 1] = k end
  -- serrated margin: forward-pointing teeth
  if abs(s) > 0.82 and ((t * len + (s > 0 and 1 or 0)) % 3) < 1.0 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(pits) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t > 0.03 then c:put(x, y, s <= 0 and "#c2e48c" or LEAF[3], ltok) return end
  local d = (t * len - abs(s) * 7.0) % 5.0
  if d < 0.8 and abs(s) > 0.18 and abs(s) < 0.75 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
-- tear edge: pale exposed tissue; cool reflected light on the lower edge
local e = lm:edge()
e:each(function(x, y) local k = K(x, y)
  if LT[k] > 0.66 and not lm:has(x + 1, y) or (LT[k] > 0.66 and not lm:has(x + 1, y - 1)) then c:put(x, y, TEAR, ltok)
  elseif not bias[k] and LS[k] > 0.6 and LT[k] > 0.12 then c:put(x, y, COOL, ltok) end end)
for _, q in ipairs{ { 5, 56, 3 }, { 4, 57, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end   -- petiole stub

-- sprout from the right stone: stem, cotyledons, true leaf
local stok = { r = { name = "stem" } }
local sm, sn = A.tube({ { 34, 41 }, { 33, 35 }, { 35, 29 }, { 34, 23 } }, function() return 1.05 end)
sm:cut(pits[2].m)
A.shade(c, sm, sn, STEM, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function coty(cx, cy, ang)
  local m, n = A.oval(cx, cy, 3.6, 1.9, ang, 0.7)
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.15, wrap = 0.3 })
  return m
end
local c1 = coty(29.5, 28, 0.35)
local c2 = coty(39, 27.5, -0.3)
-- true leaf: ovate, pointed tip, serrated, veined, up and right
local tl = A.leaf(c, 34, 23, 37, 15, 46, 11, 3.9, LEAF, { vs = 2.6, fold = 0.5, cut = HP.mask():add(c1):add(c2),
  wfn = function(t) if t > 0.985 then return -1 end return max(0.4, 3.9 * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.8) end })
tl:edge():each(function(x, y) if (x * 2 + y) % 3 == 0 and not tl:has(x - 1, y - 1) then c.pix[y * c.w + x] = nil end end)
c:put(34, 23, STEM[2], stok) c:put(34, 22, STEM[3], stok)

-- stones last
for i, s in ipairs(pits) do
  local tok = { r = { name = "pit" .. i } }
  local pb = {}
  if i == 1 then X.ao(pb, s.m, pits[2].m, 1, -1) end
  local idx = A.shade(c, s.m, s.n, PIT, { amb = 0.08, wrap = 0.3, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, bias = pb, tok = tok })
  -- suture ridge along the long axis: lit ridge with a dark groove on its shade side
  local ca, sa = cos(s[5]), sin(s[5])
  for u = -3, 3 do
    local x, y = floor(s[1] + u * ca + .5), floor(s[2] + u * sa - 0.5)
    if s.m:has(x, y) then
      c:put(x, y, PIT[min(6, (idx[K(x, y)] or 3) + 1)], tok)
      if s.m:has(x, y + 1) then c:put(x, y + 1, PIT[max(1, (idx[K(x, y + 1)] or 3) - 2)], tok) end
    end
  end
  -- pitted texture: two tiny dimples
  for _, p in ipairs{ { -2, 2 }, { 2, 2 } } do
    local x, y = floor(s[1] + p[1]), floor(s[2] + p[2])
    if s.m:has(x, y) then A.step(c, idx, PIT, x, y, -1, tok) end
  end
  local gx, gy = A.specAt(s.m, s.n, 30)
  c:put(gx, gy, PIT[6], tok)
end
-- the sprouting stone has split at the top: dark crack, pale stem foot
c:put(33, 40, PIT[1]) c:put(34, 40, STEM[2], stok) c:put(35, 40, PIT[1]) c:put(34, 41, PIT[1])
-- quirk: a sliver of cherry flesh on the left stone
for _, p in ipairs{ { 21, 48, 2 }, { 22, 48, 1 }, { 20, 49, 2 }, { 21, 49, 1 }, { 22, 47, 3 } } do c:put(p[1], p[2], RED[p[3]]) end
A.save(c, NAME)
