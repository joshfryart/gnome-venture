-- blood-lily-seed (final, Opus single pass). Three plump glossy scarlet blood-lily berries (seeds) on a torn scrap of a
-- broad strap leaf (wavy margin, parallel monocot veins, torn pale end on the right, AO + contact shadow under each berry).
-- The left berry has sprouted: a maroon-speckled stem and a broad wavy tongue leaf with a second leaf unrolling.
-- quirk: the sprout already carries a tiny scarlet pom-pom bud, the blood lily's ball of stamens in miniature.
local NAME = "blood-lily-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#173c34", "#1f5640", "#2c7446", "#43944e", "#68b45a", "#9cd274" }
local VEIN, COOL, TORN = "#b8e08a", "#36687a", "#d4ecae"
local RED = { "#5a1430", "#8e1c34", "#c42a36", "#e8473a", "#ff7a5a", "#ffb48a" }
local STEM = { "#3a6c48", "#5e9a5a", "#8cc070", "#c6e49a" }
local SPOT = "#7a2a3a"

local berries = { { 22, 44, 4.4 }, { 32, 47, 4.0 }, { 41, 42, 3.6 } }
for _, b in ipairs(berries) do b.m = c:ellipse(b[1], b[2], b[3], b[3] - 0.4) end

-- strap leaf scrap on a shallow diagonal, wavy edge, torn right end
local lm, ln, LT, LS, len = A.blade(6, 54, 30, 46, 60, 36, function(t)
  if t > 0.99 then return -1 end
  local w = 7.2 * min(1, (t + 0.04) * 4.5) ^ 0.6
  return max(0.6, w + 0.9 * sin(t * 26))
end, { fold = 0.22 })
local torn = A.tear(lm, LT, LS, 0.86, 0.1, 3, false)
local bias = {}
for _, b in ipairs(berries) do X.ao(bias, lm, b.m, 1, -1) A.cast(bias, lm, b.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.09 then c:put(x, y, VEIN, ltok) return end
  -- parallel veins running along the strap
  local a = abs(s)
  if (a > 0.36 and a < 0.44) or (a > 0.68 and a < 0.75) then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y) if not bias[k] and LS[k] > 0.6 then c:put(x, y, COOL, ltok) end end)
torn:each(function(x, y) c:put(x, y, LS[K(x, y)] < 0.3 and TORN or LEAF[5], ltok) end)

-- sprout out of berry 1
local stok = { r = { name = "stem" } }
local sp = { { 21, 41 }, { 20, 34 }, { 22, 28 }, { 21, 22 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return 1.3 - t * 0.3 end)
sm:cut(berries[1].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
sm:each(function(x, y) local k = K(x, y) if (x * 7 + y * 3) % 9 == 0 and ST[k] < 0.7 then c:put(x, y, SPOT, stok) end end)
-- broad wavy tongue leaf to the right
local function tongue(ax, ay, cx, cy, bx, by, W, wav)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, W * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.6 + wav * sin(t * 22))
  end, { fold = 0.35 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.12 and T[k] > 0.08 and T[k] < 0.88 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok)
    elseif abs(abs(S[k]) - 0.55) < 0.07 and T[k] > 0.15 and T[k] < 0.8 then c:put(x, y, S[k] < 0 and LEAF[5] or LEAF[2], ltok) end
  end)
  return m
end
local L1 = tongue(22, 30, 32, 18, 46, 16, 4.0, 0.5)
-- second, narrower leaf still unrolling to the left
local L2 = tongue(20, 27, 15, 19, 11, 12, 1.8, 0.2)
-- quirk: pom-pom bud on a short stalk at the top
local ptok = { r = { name = "pompom" } }
for y = 15, 21 do c:put(21, y, y > 18 and STEM[2] or STEM[3], stok) end
local pm = c:ellipse(21.5, 12, 3, 3)
-- spiky stamen fringe
for _, d in ipairs{ { -4, 0 }, { 4, -1 }, { 0, -4 }, { -3, -3 }, { 3, -3 }, { -3, 3 }, { 4, 2 } } do pm:set(21 + d[1] + (d[1] > 0 and 1 or 0), 12 + d[2]) end
local pidx = A.ball(c, 21.5, 12, 3, RED, ptok, { mask = pm })
for _, p in ipairs{ { 20, 10 }, { 22, 9 }, { 19, 12 }, { 23, 11 }, { 21, 13 } } do c:put(p[1], p[2], "#ffd27a", ptok) end

-- berries last: glossy scarlet, cool reflected rim, hilum scar, specular + one sparkle
for i, b in ipairs(berries) do
  local tok = { r = { name = "berry" .. i } }
  local bb = {}
  for j = i + 1, #berries do X.ao(bb, b.m, berries[j].m, 1, -1) end
  local vis = b.m:copy()
  for j = i + 1, #berries do vis:cut(berries[j].m) end
  local m, idx, n = A.ball(c, b[1], b[2], b[3], RED, tok, { mask = vis, bias = bb, rim = "#8a4a7a", amb = 0.04, wrap = 0.2 })
  local sx, sy = A.specAt(vis, n, 40)
  c:put(sx, sy, A.CREAM, tok) c:put(sx + 1, sy, RED[6], tok) c:put(sx, sy + 1, RED[6], tok)
  -- hilum scar lower right
  c:put(floor(b[1] + b[3] * 0.4), floor(b[2] + b[3] * 0.35), RED[1], tok)
end

A.save(c, NAME)
