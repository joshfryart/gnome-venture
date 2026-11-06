-- meyer-lemon-seed (aC23_2, Opus single pass). Three plump ivory lemon pips (teardrops with a pointed beak, a lit
-- lengthwise ridge, a darker chalaza cap on the round end, faint wrinkles) on a torn scrap of glossy citrus leaf lying on
-- a shallow diagonal (tip lower-left, ragged pale tear upper-right; midrib, fine arched veins, long wet specular streak,
-- cool reflected edge, AO + contact shadow under each pip). The right pip has germinated the citrus way (cotyledons stay
-- inside the seed): a slim green stem rising straight to three alternate glossy elliptic true leaves.
-- quirk: a single golden juice vesicle is still stuck to the front pip, glistening.
local NAME = "meyer-lemon-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local LEAF = { "#123a2e", "#1c5236", "#28703e", "#3c8e44", "#62ae4e", "#a4d670" }
local PIP  = { "#6a4a48", "#a0826c", "#c8ae8a", "#e2cea6", "#f2e6c4", "#fff6e0" }
local STEM = { "#3c7646", "#6aa458", "#a4d07a", "#d8eeb0" }
local JUICE = { "#c86a1e", "#f6b623", "#ffe070", "#fffbe6" }
local WET, TORN, COOL = "#dcf4b0", "#cfe6a0", "#3e7a7a"

-- leaf scrap: glossy elliptic citrus blade, tip lower-left, torn upper-right
local lm, ln, LT, LS, len = A.blade(56, 40, 36, 52, 8, 52, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 8.4 * sin(pi * min(1, t * 0.82 + 0.16)) ^ 0.7)
end, { fold = 0.46 })
local torn = A.tear(lm, LT, LS, len, true, 2.0, 5)

-- pips: u=0 beak, u=1 round end
local function prof(u)
  if u < 0.18 then return 0.35 + u * 7 end
  return 2.6 * sqrt(max(0, 1 - ((u - 0.58) / 0.44) ^ 2)) + 0.2
end
local pips = {
  { 21, 48, 10, 2.85 },     -- beak to the right
  { 31, 51, 10.5, 0.2 },
  { 42, 44, 10, 1.45 },     -- upright, beak up: the sprouting one
}
for _, s in ipairs(pips) do s.m, s.U, s.V = A.seed(s[1], s[2], s[3], prof, s[4]) end

-- sprout: shoot emerges from the beak (micropyle) of the right pip
local sp = { { 42, 39 }, { 43, 32 }, { 41, 25 }, { 42, 18 } }
local sm, sn = A.tube(sp, function(t) return 1.1 - 0.2 * t end)

local bias = {}
for _, s in ipairs(pips) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.28, 0.44, 0.62, 0.82 }, amb = 0.14, wrap = 0.28 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.04 and t < 0.94 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 6.5) / 5.0
  local f = ph - floor(ph)
  if f < 0.13 and abs(s) > 0.18 and abs(s) < 0.72 and t > 0.08 and t < 0.86 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) return end
  -- long wet specular streak on the lit half
  if s < -0.42 and s > -0.6 and t > 0.32 and t < 0.7 then c:put(x, y, WET, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.12 and LT[k] < 0.86 then c:put(x, y, COOL, ltok) end end)
torn:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, TORN, ltok) end end)

-- sprout stem
local stok = { r = { name = "stem" } }
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- true leaves: alternate, glossy elliptic, short winged petioles
local function tleaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    if t < 0.14 then return 0.5 + t * 3 end
    return max(0.45, w * sin(pi * min(1, (t - 0.1) * 1.05)) ^ 0.7)
  end, { fold = 0.42 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.16, 0.3, 0.46, 0.64, 0.84 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.86 then c:put(x, y, S[k] <= 0 and LEAF[5] or LEAF[3], ltok)
    elseif S[k] < -0.4 and S[k] > -0.66 and T[k] > 0.35 and T[k] < 0.6 then c:put(x, y, WET, ltok) end
  end)
  return m
end
tleaf(42, 32, 35, 30, 27, 25, 3.3)
tleaf(42, 25, 49, 24, 56, 18, 3.1)
tleaf(42, 19, 44, 13, 47, 8, 2.4)

-- pips last
for i, s in ipairs(pips) do
  local tok = { r = { name = "pip" .. i } }
  local sb = {}
  for j = i + 1, #pips do X.ao(sb, s.m, pips[j].m, 1, -1) end
  if i == 3 then X.ao(sb, s.m, sm, 1, -1) end
  local n = X.pillow(s.m, 2.4)
  local idx = A.toneN(c, s.m, n, PIP, { tok = tok, bias = sb, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.1, wrap = 0.3 })
  s.m:each(function(x, y) local k = K(x, y)
    local u, v = s.U[k], s.V[k]
    if v < -0.15 and v > -0.45 and u > 0.25 and u < 0.8 and not sb[k] then c:put(x, y, PIP[6], tok) end -- lit ridge
    if u > 0.9 and (idx[k] or 3) >= 3 then c:put(x, y, PIP[3], tok) end                                    -- chalaza cap
    if v > 0.25 and v < 0.5 and u > 0.3 and u < 0.75 and (floor(u * 20) % 3 == 0) then c:put(x, y, PIP[max(1, (idx[k] or 3) - 1)], tok) end -- wrinkles
    if u < 0.1 then c:put(x, y, PIP[2], tok) end                                                             -- beak tip
  end)
end

-- quirk: juice vesicle stuck to the front pip
local jx, jy = 30, 49
A.dots(c, { { jx, jy, JUICE[2] }, { jx + 1, jy, JUICE[3] }, { jx + 2, jy, JUICE[2] }, { jx + 1, jy + 1, JUICE[1] },
  { jx + 2, jy + 1, JUICE[1] }, { jx, jy + 1, JUICE[2] }, { jx + 1, jy - 1, JUICE[3] } }, { r = { name = "juice" } })
c:put(jx + 1, jy, JUICE[4])

A.save2(c, NAME)
