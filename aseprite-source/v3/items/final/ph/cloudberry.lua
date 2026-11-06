-- cloudberry (final, Opus single pass). One ripe amber cloudberry built from fat hex-packed drupelets (bumpy
-- silhouette, dark seams, a glossy glint on every lit bead, cool reflected light lower-right), sitting in a star of
-- five reflexed papery sepals; slim stem bending down to one crinkly five-lobed leaf (palmate veins, toothed rim,
-- AO where the petiole meets). quirk: a single dewdrop rests on the leaf.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi
local NAME = "cloudberry"
local c = A.new(NAME)
local AMB  = { "#6a2421", "#a63f1d", "#d4691c", "#ef9628", "#fbbf47", "#ffe28e" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local SEP  = { "#3b3424", "#5f5530", "#88793d", "#b3a457", "#d6c97c" }
local STEM = { "#2e5a3a", "#4f8a55", "#86b86c", "#b8dc92" }
local VEIN, COOL, BOUNCE = "#b9dc86", "#3a6c72", "#b0587a"

-- leaf (lower right), drawn first
local ltok = A.tok("leaf")
local lm, ln, vein, LA, LR = A.palmLeaf(46, 50, 12.5, 8.5, 2.35, 5, { R = 3 })
local bias = {}
-- AO near the petiole notch
lm:each(function(x, y) local k = K(x, y) if LR[k] < 0.22 then bias[k] = -1 end end)
local lidx = A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, amb = 0.12, wrap = 0.3 })
vein:each(function(x, y) local k = K(x, y) c:put(x, y, (lidx[k] or 3) >= 4 and VEIN or LEAF[2], ltok) end)
-- teeth: dark notch every few px on the rim, cool rim on the shade side
lm:edge():each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 11) < 0.22 then c:put(x, y, LEAF[2], ltok)
  elseif ln[k][1] + ln[k][2] > 0.5 then c:put(x, y, COOL, ltok) end end)
-- quirk: dewdrop (glass cue: dark rim lower right, pale core, cream glint)
local dew = { "....", ".ab.", "acbd", ".dd." }
local DC = { a = "#cfe9e4", b = "#fff4d6", c = "#9fd0c8", d = "#3f8a7e" }
for j, row in ipairs(dew) do for i = 1, #row do local ch = row:sub(i, i)
  if DC[ch] then c:put(50 + i, 49 + j, DC[ch], A.tok("dew")) end end end
c:put(51, 54, LEAF[1], ltok) c:put(52, 54, LEAF[1], ltok)

-- stem: from berry base down-right, then petiole to the leaf notch
local stok = A.tok("stem")
local spts = { { 31, 42 }, { 30, 51 }, { 33, 56 }, { 38, 56 } }
local sm, sn = A.tube(spts, function(t) return 1.15 - t * 0.2 end)
A.shade(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.1 })

-- sepals: five reflexed pointed sepals in a star behind the berry
local setok = A.tok("sepal")
local sepm = HP.mask()
for i, a in ipairs{ 2.0, 2.85, 1.25, 0.35, -0.7 + 0.05 } do
  local ux, uy = cos(a), sin(a)
  local L = (i == 5) and 18 or 18.5
  local m, n = A.blade(31, 31, 31 + ux * L * 0.5, 31 + uy * L * 0.5 + 1, 31 + ux * L, 31 + uy * L,
    function(t) if t > 0.98 then return -1 end return max(0.3, 2.9 * sin(pi * min(1, t * 0.8 + 0.25)) ^ 0.8) end, { fold = 0.45 })
  m:cut(sepm)
  local b = {}
  A.cast(b, m, sepm, 1, 1, -1)
  A.shade(c, m, n, SEP, { tok = setok, cuts = { 0.25, 0.45, 0.65, 0.82 }, bias = b, amb = 0.1 })
  sepm:add(m)
end

-- berry: drupelet cluster
local btok = A.tok("berry")
local bb = {}
-- contact shadow from berry onto sepals
local body = A.ell(31, 26, 13, 12.5)
A.cast({}, sepm, body, 1, 2, -1)
body:shift(1, 2):each(function(x, y) if sepm:has(x, y) and not body:has(x, y) then c:put(x, y, SEP[1], setok) end end)
local bm, cs, bn, bidx, lit = A.drupes(c, 31, 26, 13, 12.5, 3.1, AMB, { tok = btok, amb = 0.05, wrap = 0.18 })
-- cool reflected light on the lower-right rim beads
local rim = X.rim(bn)
bm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.72 and (x - 31) + (y - 26) > 11 then c:put(x, y, BOUNCE, btok) end end)
-- one big cream glint on the top-left bead
if lit[1] then c:put(lit[1][1], lit[1][2], A.CREAM, btok) c:put(lit[1][1] + 1, lit[1][2], AMB[6], btok) end
-- tiny dried style dots (pistil remnants) on a few beads: a 1 px dark fleck
for i, p in ipairs(cs) do if i % 3 == 1 then
  local x, y = floor(p[1] + 0.6), floor(p[2] + 0.8)
  if bm:has(x, y) and (bidx[K(x, y)] or 0) >= 3 then c:put(x, y, AMB[2], btok) end end end

A.save(c, NAME)
