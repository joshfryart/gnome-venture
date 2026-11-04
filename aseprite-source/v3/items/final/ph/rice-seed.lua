-- rice-seed (final, artist aD12_4). Three slim golden rice grains (pointed husk with lengthwise ridges, lit centre strip,
-- dark base nub, fine awn) lying on a torn scrap of a long paddy-grass leaf (midrib + parallel veins, V-fold light, torn
-- fibrous left end, cool reflected lower edge, AO + contact shadow under each grain). The right grain has germinated:
-- pale root hairs dangle off the scrap and a pale coleoptile sheath carries three narrow arching grass blades, which show
-- rice's long thin parallel-veined leaf. quirk: a dewdrop hangs from the tip of the longest blade.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_4.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("rice-seed")

local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local LIME = { "#24634a", "#37814a", "#58a24c", "#82c058", "#b0dc72", "#dcf2a4" }
local STEM = { "#5d9558", "#8fbf74", "#bfe09a", "#e8f5c4" }
local GR   = { "#5a3f26", "#9a7436", "#c9a048", "#e8c668", "#f6e298", "#fff2c4" }
local GLS  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#8fe0e8", "#c6f2f4", "#f0fcff" }
local COOL = "#3a6c72"

-- grains: cx, cy, half length, half width, angle (tip direction)
local grains = {
  { 14, 51, 5.8, 2.9, -0.2 },
  { 30, 47, 5.8, 2.9, pi - 0.35 },
  { 44, 43.5, 5.8, 2.9, pi + 0.2 },
}
local allG = HP.mask()
for _, g in ipairs(grains) do g.m = A.spind(g[1], g[2], g[3], g[4], g[5]) allG:add(g.m) end

-- leaf scrap
local lm, ln, LT, LS, len = G.blade(8, 52, 28, 51, 56, 43, function(t)
  if t > 0.985 then return -1 end
  local w = 5.6
  if t > 0.68 then w = 5.6 * (1 - (t - 0.68) / 0.32) ^ 0.85 end
  return max(0.5, w)
end, { fold = 0.38 })
local torn = {}
lm:each(function(x, y) local k = K(x, y)
  if LT[k] * len < 1.4 + 3.6 * X.hash(floor(y / 2), 3, 5) then torn[#torn + 1] = k end end)
for _, k in ipairs(torn) do lm.s[k] = nil end
lm:cut(A.ell(21, 57.5, 2.6, 1.7, 0))                       -- bite out of the lower margin
local bias = {}
X.ao(bias, lm, allG, 1, -1) G.cast(bias, lm, allG, 1, 2, -1) G.cast(bias, lm, allG, 2, 2, -1)
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, amb = 0.16, wrap = 0.3, cuts = { 0.16, 0.32, 0.5, 0.67, 0.84 } })
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s, t = LS[k], LT[k]
  if abs(s) < 0.1 and t > 0.04 then c:put(x, y, LEAF[6], ltok) return end
  for _, v in ipairs{ -0.62, -0.34, 0.34, 0.62 } do
    if abs(s - v) < 0.075 and t > 0.03 and t < 0.93 then c:put(x, y, v < 0 and LEAF[5] or LEAF[2], ltok) end
  end
end)
-- fibrous torn end: pale fibres
lm:each(function(x, y) local k = K(x, y)
  if LT[k] * len < 5 and not bias[k] and X.hash(x, y, 9) > 0.62 then c:put(x, y, "#cfe090", ltok) end end)
-- cool reflected edge, lower right
lm:edge():each(function(x, y) local k = K(x, y) if not bias[k] and LS[k] > 0.62 and LT[k] > 0.1 then c:put(x, y, COOL, ltok) end end)

-- sprout (behind the grain): blades, sheath, roots
local function sblade(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.45, w * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.45)
  end, { fold = 0.3 })
  local tok = { r = { name = "sb" } }
  G.toneN(c, m, n, LIME, { tok = tok, amb = 0.14, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.68, 0.84 } })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.22 and T[k] > 0.06 and T[k] < 0.92 then c:put(x, y, S[k] <= 0 and LIME[6] or LIME[3], tok) end end)
  return m
end
local b3 = sblade(49.5, 34, 49, 27, 46.5, 20, 1.5)
local b2 = sblade(50, 34, 57, 25, 57.5, 14.5, 1.7)
local b1 = sblade(49.5, 34, 40, 20, 32, 11.5, 1.9)
local sm, sn = G.tube({ { 50, 44 }, { 51, 40 }, { 50, 37 }, { 49.5, 33 } }, function(t) return 1.7 - 0.45 * t end)
G.toneN(c, sm, sn, STEM, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
for y = 36, 40 do c:px(49, y, STEM[4]) end
c:px(51, 38, STEM[1]) c:px(51, 40, STEM[1])
-- root hairs dangling off the scrap
local ROOT, ROOT2 = "#f2ecd2", "#c9c8a8"
A.pl(c, { {51,46},{52,48},{52,50},{53,52} }, ROOT)
A.pl(c, { {50,47},{49,49},{49,51} }, ROOT)
A.pl(c, { {52,47},{54,48},{55,50} }, ROOT2)
c:px(53, 53, ROOT2) c:px(49, 52, ROOT2)

-- grains
local function grain(g, awn, nub)
  local cx, cy, L, W, ang = g[1], g[2], g[3], g[4], g[5]
  local m = g.m
  -- contact shadow on the leaf, down-right
  m:shift(1, 1):each(function(x, y) if lm:has(x, y) and not allG:has(x, y) then c:px(x, y, LEAF[1]) end end)
  local n = X.pillow(m, 2.8)
  local tok = { r = { name = "g" } }
  local idx = G.toneN(c, m, n, GR, { tok = tok, amb = 0.1, wrap = 0.3 })
  local ca, sa = cos(ang), sin(ang)
  m:each(function(x, y)
    local dx, dy = x - cx, y - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    local flip = (-sa + ca) > 0 and 1 or -1            -- so v<0 is the lit side
    local vv = v * flip
    local t = idx[K(x, y)] or 3
    local au = abs(u)
    local s = (u + L) / (2 * L)
    local p = sin(pi * s ^ 0.72) ^ 0.8
    local vn = vv / max(0.5, W * p)
    if au < 0.78 * L then
      if abs(abs(vn) - 0.58) < 0.16 then t = t - 1
      elseif abs(vn) < 0.26 then t = t + 1 end
    end
    if u > 0.8 * L then t = t - 1 end
    if u < -0.82 * L then t = 2 end
    c:put(x, y, GR[max(1, min(6, t))], tok)
  end)
  do local flip = (-sa + ca) > 0 and 1 or -1
    local u, v = -0.3 * L, -1.3 * flip
    c:px(floor(cx + u * ca - v * sa + 0.5), floor(cy + u * sa + v * ca + 0.5), "#fff2c4") end
  if awn then
    local tx, ty = cx + (L + 0.4) * ca, cy + (L + 0.4) * sa
    A.pl(c, { {floor(tx + .5), floor(ty + .5)}, {floor(tx + awn[1] * 0.5 + .5), floor(ty + awn[2] * 0.4 + .5)}, {floor(tx + awn[1] + .5), floor(ty + awn[2] + .5)} }, GR[3])
  end
end
grain(grains[1], { 3, -3 })
grain(grains[2])
grain(grains[3], { -3, -1 })

-- quirk: dewdrop hanging from the longest blade tip
local dr = A.ell(33.5, 16.5, 1.9, 2.1, 0)
dr:add(c:rect(33, 14, 33, 14))
local dn = X.sphere(33.2, 16.5, 2.0, dr)
G.toneN(c, dr, dn, GLS, { amb = 0.15, wrap = 0.2, cuts = { 0.2, 0.36, 0.55, 0.72, 0.88 } })
c:px(32, 15, GLS[6]) c:px(34, 18, "#7fd0e0")

A.save(c, "rice-seed")
