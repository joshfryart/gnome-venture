-- ico-orange (final pass, Opus single pass). Bold icon: a round, slightly squat orange with a shallow dimple at
-- the stem end. Per-pixel sphere light (6-tone orange, cool-violet shade), pitted peel (oil-gland pores: a dark pit
-- with a lit lip above-left), glossy specular patch + cream glint, cool reflected light lower-right, dark AO cup
-- round the calyx. Calyx: 5-point green star with a 3 px stub. Leaf: 6-tone blade, pale midrib, veins, dark base.
-- quirk: a little blue produce sticker is stuck on the shade side, its corner peeling up.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA7_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs, sin, pi = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin, math.pi
local c = A.new("ico-orange")
local ORG  = { "#6a2436", "#a83a2e", "#d8602a", "#f4882a", "#ffae40", "#ffd67c" }
local LEAF = { "#173f36", "#22593f", "#2f7646", "#45954c", "#6ab455", "#a4d46e" }
local STEM = { "#24443a", "#3f7048", "#6a9a52" }
local BOUNCE, SPEC = "#b24a5e", "#ffeab4"
local otok, ltok, stok = A.tok("orange"), A.tok("leaf"), A.tok("stem")

-- leaf first, up to the right off the calyx
local lm, ln, LT, LS = A.blade(34, 18, 42, 8, 53, 10, function(t) return 4.4 * sin(pi * min(1, t * 1.04)) ^ 0.75 - 0.2 end, { fold = 0.5 })
local lb = {}
lm:each(function(x, y) local k = K(x, y) if LT[k] < 0.14 then lb[k] = -1 end end)
local lidx = A.shade(c, lm, ln, LEAF, { amb = 0.1, wrap = 0.25, bias = lb, tok = ltok })
lm:each(function(x, y) local k = K(x, y)
  if abs(LS[k]) < 0.16 and LT[k] > 0.1 and LT[k] < 0.9 then c:put(x, y, LEAF[min(6, lidx[k] + 2)], ltok) end end)
for _, v in ipairs{ { 0.36, -1 }, { 0.58, -1 }, { 0.44, 1 }, { 0.68, 1 } } do
  lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
    if s * v[2] > 0.25 and s * v[2] < 0.8 and abs((t - v[1]) - abs(s) * 0.15) < 0.03 then
      c:put(x, y, LEAF[max(1, lidx[k] - 1)], ltok) end end)
end

-- body
local CX, CY = 32, 37
local m = c:ellipse(CX, CY, 17, 16)
m:cut(c:ellipse(CX, CY - 17.2, 3, 1.2))
local ns = X.sphere(CX - 0.5, CY - 0.5, 17, m)
local np = X.pillow(m, 5)
local n = A.blend(ns, np, 0.25)
local bias = {}
m:each(function(x, y) local k = K(x, y)
  local d = sqrt((x - CX) ^ 2 + ((y - (CY - 16)) * 1.6) ^ 2)
  if d < 3.5 then bias[k] = -2 elseif d < 6 then bias[k] = -1 end
end)
local idx = A.shade(c, m, n, ORG, { amb = 0.08, wrap = 0.3, bias = bias, tok = otok, cuts = { 0.1, 0.26, 0.46, 0.66, 0.86 } })
-- pitted peel: pore = one tone down, lit lip above-left one tone up
local pores = {}
m:shrink(2):each(function(x, y) local k = K(x, y)
  local i = idx[k]
  if i and i >= 3 and i <= 5 and X.hash(x, y, 5) > 0.86 and not pores[K(x - 1, y)] and not pores[K(x, y - 1)] and not pores[K(x - 1, y - 1)] then
    pores[k] = true
  end
end)
for k in pairs(pores) do local x, y = k % 1024 - 256, k // 1024 - 256
  A.step(c, idx, ORG, x, y, -1, otok)
  if idx[K(x - 1, y - 1)] and idx[K(x - 1, y - 1)] <= 5 and not pores[K(x - 1, y - 1)] and idx[K(x - 1, y - 1)] >= 4 then A.step(c, idx, ORG, x - 1, y - 1, 1, otok) end
end
-- cool reflected light lower-right
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.72 and y > CY + 2 and x > CX - 2 then c:put(x, y, BOUNCE, otok) end end)
-- glossy specular patch + glint
A.map(c, {
  "..hhh..",
  ".hsssh.",
  "hssh...",
  "hsh....",
  ".h.....",
}, 19, 25, { h = ORG[6], s = SPEC }, otok)
c:put(22, 27, A.CREAM, otok)
c:put(23, 26, A.CREAM, otok)

-- calyx: dark cup, 5-point star, stub stalk
A.map(c, {
  "..dS.Sd..",
  "dSSgSgSSd",
  ".dggSggd.",
  "dSgdgdgSd",
  ".d..d..d.",
}, CX - 4, CY - 17, { d = STEM[1], g = STEM[2], S = STEM[3] }, stok)
c:fillMask(c:rect(CX - 1, CY - 19, CX + 1, CY - 17), STEM[2])
c:put(CX - 1, CY - 19, STEM[3]) c:put(CX + 1, CY - 17, STEM[1]) c:put(CX + 1, CY - 18, STEM[1])
c:put(CX - 1, CY - 20, "#d8c48a") c:put(CX, CY - 20, "#b8a26a") -- pale cut end of the stalk
-- AO under the calyx
for x = CX - 4, CX + 4 do local y = CY - 13 if idx[K(x, y)] then A.step(c, idx, ORG, x, y, -1, otok) end end

-- quirk: produce sticker on the shade side, top-right corner peeling up
local sx, sy = 40, 41
A.map(c, {
  ".bbbbbP",
  "bBccCBbp",
  "bcBccCb.",
  "bBcBcBb.",
  ".bbbbb..",
}, sx, sy, { b = "#2a5a92", B = "#4a86c4", c = "#e4eef4", C = "#9cc6e8", P = "#d8e6f0", p = "#7a98b6" }, A.tok("sticker"))
A.save(c, "ico-orange")
