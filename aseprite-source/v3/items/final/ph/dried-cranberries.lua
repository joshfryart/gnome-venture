-- dried-cranberries (final, Opus single pass). A slim glass storage jar packed with shrivelled cranberries, corked,
-- a twisted twine tie round the neck. Material: glass (bright left rim, pale vertical core streak over the berries,
-- cool darker right wall, thick pale base), per-pixel lit berries (6-tone crimson, cool shade, one crease each,
-- dark gaps between = AO), cork cylinder with pitted grain and a paler end-grain top, twine twist. Ground shadow.
-- quirk: one cranberry has escaped and sits by the jar's foot.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("dried-cranberries")

local CR = { "#3a0c22", "#5e1230", "#8a1c38", "#b42a40", "#d4485a", "#f48a8a" }
local GL = { "#3e5a84", "#5a82aa", "#86b0d0", "#b4d8e6", "#daf2f4", "#f4fffc" }
local CK = { "#4a2c26", "#74482e", "#9c6a3e", "#c08e56", "#dcb27a", "#f2d4a0" }
local TW = { "#7a4a22", "#c08a3a", "#ecc070" }
local GAP = "#2e0e20"
local gtok, btok, ktok, ttok = { r = { name = "glass" } }, { r = { name = "berries" } }, { r = { name = "cork" } }, { r = { name = "twine" } }

-- ground shadow first (under everything)
c:groundShadow(33, 53, 11, 1)

-- jar silhouette
local body = HP.rrect(21, 26, 43, 52, 5)
local shoulder = HP.poly({ { 22, 28 }, { 25, 23 }, { 27, 22 }, { 37, 22 }, { 39, 23 }, { 42, 28 } })
local neck = HP.rect(26, 18, 38, 23)
local jar = body:copy():add(shoulder):add(neck)
-- glass base tone: pillow-lit, cool
local gn = X.pillow(jar, 4)
local gidx = A.shade(c, jar, gn, GL, { tok = gtok, amb = 0.1, wrap = 0.3, cuts = { 0.25, 0.42, 0.58, 0.74, 0.88 } })

-- berries inside: interior region
local inner = HP.rrect(23, 29, 41, 49, 3)
local fillTop = function(x) return 30 + floor(sin(x * 1.3) * 1.2 + 0.5) end
inner:each(function(x, y) if y >= fillTop(x) then c:put(x, y, GAP, btok) end end)
local bm = HP.mask()
local row = 0
for y = 31, 49, 3 do
  row = row + 1
  local off = (row % 2) * 2
  for x = 23 + off, 42, 4 do
    local jx = (X.hash(x, y, 3) - 0.5) * 1.2
    local jy = (X.hash(x, y, 7) - 0.5) * 1.0
    local cx, cy = x + jx, y + jy
    local m, n = A.oval(cx, cy, 1.9 + X.hash(x, y, 1) * 0.5, 1.5 + X.hash(x, y, 2) * 0.4, (X.hash(x, y, 5) - 0.5) * 1.2, 1.2)
    m:clip(inner)
    local keep = HP.mask()
    m:each(function(px, py) if py >= fillTop(px) then keep:set(px, py) end end)
    -- slightly darker deeper in the jar and toward the right wall
    local bias = {}
    keep:each(function(px, py) if px > 39 or py > 47 then bias[K(px, py)] = -1 end end)
    local idx = A.shade(c, keep, n, CR, { tok = btok, amb = 0.05, wrap = 0.2, bias = bias })
    -- crease
    local kx, ky = floor(cx + (X.hash(x, y, 9) > 0.5 and 1 or 0) + .5), floor(cy + .5)
    if keep:has(kx, ky) then c:put(kx, ky, CR[max(1, (idx[K(kx, ky)] or 3) - 2)], btok) end
    bm:add(keep)
  end
end

-- glass over contents: walls, core streak, right wall, base
jar:edge():each(function(x, y)
  local col
  if x <= 23 and y > 24 then col = GL[6] elseif x >= 42 then col = GL[2] elseif y >= 51 then col = GL[3] else col = GL[4] end
  c:put(x, y, col, gtok)
end)
-- inner wall line (second px) pale on the lit side, cool on the shade side
for y = 29, 49 do c:put(22, y, GL[5], gtok) c:put(42, y, y % 4 == 0 and GL[3] or GL[2], gtok) end
-- pale core streak over the berries (broken)
for y = 31, 47 do if y % 7 ~= 3 then c:put(25, y, y < 36 and GL[6] or GL[5], gtok) end if y > 33 and y < 42 then c:put(26, y, GL[4], gtok) end end
-- short secondary reflection on the right
for y = 34, 38 do c:put(40, y, GL[3], gtok) end
-- thick base: two rows of pale glass with a lit lip
for x = 23, 41 do c:put(x, 50, GL[4], gtok) c:put(x, 51, x < 29 and GL[5] or GL[3], gtok) end
-- shoulder glint + one sparkle
c:put(24, 25, GL[6], gtok) c:put(25, 24, GL[6], gtok)
c:put(27, 27, "#fff4d6", gtok)
-- neck lip: raised rim ring
for x = 26, 38 do c:put(x, 18, x < 31 and GL[6] or GL[4], gtok) c:put(x, 19, GL[2], gtok) end

-- cork: slightly tapered cylinder poking above the lip
local cork = HP.mask()
for y = 9, 18 do local w = 5 + (y < 12 and 1 or 0) - (y > 16 and 0 or 0) for x = 32 - w, 32 + w - 1 do cork:set(x, y) end end
local cn = {}
cork:each(function(x, y) local s = (x - 31.5) / 6.5 cn[K(x, y)] = { s, y < 11 and -0.6 or 0, sqrt(max(0.05, 1 - s * s)) } end)
local cidx = A.shade(c, cork, cn, CK, { tok = ktok, amb = 0.08, wrap = 0.25 })
-- end grain top (paler oval with a ring)
for x = 27, 36 do c:put(x, 9, x < 31 and CK[6] or CK[5], ktok) end
for x = 28, 35 do c:put(x, 10, CK[5], ktok) end
c:put(31, 10, CK[4], ktok) c:put(32, 10, CK[4], ktok)
-- pitted grain flecks
cork:each(function(x, y) if y > 11 and X.hash(x, y, 11) > 0.82 then A.step(c, cidx, CK, x, y, -2, ktok) end end)
-- AO where cork enters the neck
for x = 27, 37 do c:put(x, 17, CK[1], ktok) end

-- twine tie round the neck: two twisted rows + a dangling tail with a knot
for x = 26, 38 do
  for _, y in ipairs{ 20, 21 } do
    local q = (x + y) % 3
    c:put(x, y, TW[q + 1], ttok)
  end
end
for i, p in ipairs{ { 39, 21 }, { 40, 22 }, { 40, 23 }, { 41, 24 }, { 41, 25 } } do c:put(p[1], p[2], TW[(i % 2) + 2], ttok) end
for i, p in ipairs{ { 39, 22 }, { 39, 23 }, { 39, 24 } } do c:put(p[1], p[2], TW[(i % 2) + 1], ttok) end
c:put(39, 20, TW[3], ttok) c:put(40, 20, TW[2], ttok)

-- quirk: an escaped cranberry by the foot
local em, en = A.oval(48, 51, 2.2, 1.8, 0.3, 1.2)
c:groundShadow(48, 53, 2, 0)
local eidx = A.shade(c, em, en, CR, { tok = { r = { name = "escapee" } }, amb = 0.05, wrap = 0.22 })
c:put(47, 50, CR[6], { r = { name = "escapee" } })
c:put(49, 51, CR[2], { r = { name = "escapee" } })
A.save(c, "dried-cranberries")
