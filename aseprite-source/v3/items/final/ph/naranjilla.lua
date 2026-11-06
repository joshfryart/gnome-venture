-- naranjilla (final, Opus single pass). A whole round naranjilla (lulo) with fine orange fuzz, a five-pointed hairy
-- green calyx with purple-tinged tips and a short stem; in front, a cut half tilted toward the viewer showing the
-- green jelly flesh in four chambers, pale septa, a cream core and tiny seeds, its skin dome visible as a crescent.
-- Material: per-pixel sphere light (6-tone orange), fuzz speckle + backlit pale hairs on the lit rim, cool bounce on
-- the shade side, AO + cast shadow under the calyx and where the half overlaps, wet glints on the cut face.
-- quirk: a drop of green juice is about to fall from the cut half.
local NAME = "naranjilla"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local OR   = { "#5e1f2e", "#9a3328", "#cf5a1e", "#ee8420", "#fbaa38", "#ffd36e" }
local LEAF = { "#1d3f30", "#2a5a3a", "#3f7a40", "#5d9a46", "#86ba58", "#b6d67a" }
local STEM = { "#2e2a22", "#46462c", "#626a36", "#828c46", "#a6b062", "#cad488" }
local FL   = { "#2e5a2e", "#4a7c32", "#6e9e3a", "#94bc4c", "#bcd86e", "#e2f0a0" }
local FUZZ, BOUNCE, PURP = "#ffe6a0", "#a8506e", "#6e4a7e"

-- masks
local FX, FY, FR = 25, 31, 14.5
local fm = HP.ellipse(FX, FY, FR, FR - 0.5)
local HX, HY = 44, 44
local skin = HP.ellipse(HX + 0.8, HY + 0.9, 10, 10)
local face = HP.ellipse(HX, HY, 9.2, 9.2)
local half = skin:copy():add(face)
-- calyx: five sepals radiating from the top, foreshortened
local CX, CY = FX + 1, FY - 12
local cal, calT, calS = HP.mask(), {}, {}
local seps = {}
for i = 0, 4 do
  local a = -pi / 2 + i * 2 * pi / 5 + 0.25
  local L = 9.5
  local ca, sa = cos(a), sin(a)
  local tx, ty = CX + ca * L, CY + sa * L * 0.5 + (sa > 0 and 2.5 * sa or 0)
  local mx, my = CX + ca * L * 0.5, CY + sa * L * 0.25 - 0.6
  local m, n, T, S = A.blade(CX, CY, mx, my, tx, ty, function(t)
    if t > 0.97 then return -1 end
    return 2.5 * (1 - t) ^ 0.9 + 0.25
  end, { fold = 0.35 })
  seps[#seps + 1] = { m = m, n = n, T = T, S = S, back = sa < -0.3 }
end
for _, s in ipairs(seps) do cal:add(s.m) end
local stem, sn, ST, SS = A.tube({ { CX, CY + 1 }, { CX, CY - 3 }, { CX + 2, CY - 6 }, { CX + 4, CY - 8 } }, function(t) return 1.45 - 0.2 * t end)

-- whole fruit
local fn = X.sphere(FX - 0.4, FY - 0.4, FR, fm)
local bias = {}
X.ao(bias, fm, cal, 1, -1) A.cast(bias, fm, cal, 1, 2, -1)
X.ao(bias, fm, half, 2, -1) A.cast(bias, fm, half, -1, -1, 0)
local ftok = { r = { name = "fruit" } }
local fidx = A.shade(c, fm, fn, OR, { bias = bias, tok = ftok, amb = 0.05, wrap = 0.2, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
-- fuzz: sparse speckle one tone up, backlit pale hairs on the lit rim, cool bounce lower right
fm:each(function(x, y) local k = K(x, y) local i = fidx[k]
  local h = X.hash(x, y, 7)
  if i >= 3 and i <= 5 and h > 0.86 then A.at(c, x, y, OR, i + 1, ftok) end
  if i >= 2 and i <= 4 and h < 0.06 then A.at(c, x, y, OR, i - 1, ftok) end
end)
local rimv = X.rim(fn)
fm:edge():each(function(x, y) local k = K(x, y) local nn = fn[k]
  if nn[1] + nn[2] < -0.9 and X.hash(x, y, 3) > 0.45 and not bias[k] then c:put(x, y, FUZZ, ftok) end
  if rimv[k] > 0.62 and not bias[k] then c:put(x, y, BOUNCE, ftok) end
end)
-- soft specular on the fuzz: 2x1 hi + one cream
c:put(FX - 7, FY - 6, OR[6], ftok) c:put(FX - 6, FY - 6, OR[6], ftok) c:put(FX - 7, FY - 5, OR[6], ftok)
c:put(FX - 6, FY - 7, A.CREAM, ftok)

-- calyx (back sepals first, stem, then front sepals)
local ctok = { r = { name = "calyx" } }
local function sepal(s)
  local idx = A.shade(c, s.m, s.n, LEAF, { tok = ctok, amb = 0.14, wrap = 0.3 })
  s.m:each(function(x, y) local k = K(x, y) local t, ss = s.T[k], s.S[k]
    if t > 0.78 then c:put(x, y, (idx[k] or 3) >= 4 and "#8a6a98" or PURP, ctok)
    elseif abs(ss) < 0.18 and t > 0.12 then A.at(c, x, y, LEAF, (idx[k] or 3) + (ss <= 0 and 1 or -1), ctok) end
  end)
end
for _, s in ipairs(seps) do if s.back then sepal(s) end end
local stok = { r = { name = "stem" } }
local sidx = A.shade(c, stem, sn, STEM, { tok = stok, amb = 0.12, wrap = 0.3 })
-- fine hairs on the stem and cut end
for _, q in ipairs{ { CX - 2, CY - 3 }, { CX + 4, CY - 4 } } do if not stem:has(q[1], q[2]) and not fm:has(q[1], q[2]) then c:put(q[1], q[2], STEM[5], stok) end end
c:put(CX + 4, CY - 8, STEM[6], stok) c:put(CX + 5, CY - 8, STEM[5], stok)
for _, s in ipairs(seps) do if not s.back then sepal(s) end end
-- dark sunken centre where sepals meet
c:put(CX, CY + 1, LEAF[1], ctok) c:put(CX + 1, CY + 1, LEAF[2], ctok)

-- cut half: skin dome first, then the face
local hn = X.sphere(HX + 0.4, HY + 0.4, 10, skin)
local htok = { r = { name = "half" } }
A.shade(c, skin, hn, OR, { tok = htok, amb = 0.05, wrap = 0.2 })
skin:each(function(x, y) if not face:has(x, y) and face:grow(1):has(x, y) then c:put(x, y, OR[1], htok) end end)
local rimh = X.rim(hn)
skin:edge():each(function(x, y) if not face:has(x, y) and rimh[K(x, y)] > 0.55 then c:put(x, y, BOUNCE, htok) end end)
local seedpos = {}
for q = 0, 3 do
  local a0 = q * pi / 2
  for _, sd in ipairs{ { 3.7, -0.32 }, { 3.7, 0.32 }, { 5.6, -0.42 }, { 5.6, 0.0 }, { 5.6, 0.42 } } do
    local a = a0 + sd[2]
    seedpos[K(floor(HX + cos(a) * sd[1] + .5), floor(HY + sin(a) * sd[1] + .5))] = true
  end
end
face:each(function(x, y)
  local dx, dy = x - HX, y - HY
  local r = sqrt(dx*dx + dy*dy)
  local th = atan(dy, dx)
  local lit = (dx + dy < -6) and 1 or ((dx + dy > 6) and -1 or 0)
  local col
  if r > 8.4 then col = (dx + dy < 0) and OR[5] or OR[4]
  elseif r > 7.3 then col = FL[5 + (lit > 0 and 1 or 0)]
  elseif r < 1.9 then col = (dx + dy <= 0) and "#f4f0c4" or "#d8d89a"
  else
    -- septa on the diagonals
    local ph = (th - pi / 4) % (pi / 2)
    local dd = min(ph, pi / 2 - ph) * r
    if dd < 0.62 then col = FL[5]
    elseif seedpos[K(x, y)] then col = "#f6eec4"
    elseif seedpos[K(x - 1, y - 1)] or seedpos[K(x, y - 1)] then col = FL[2]
    else col = FL[3 + lit + ((r > 6.3) and 1 or 0)] end
  end
  c:put(x, y, col, htok)
end)
-- wet glints on the jelly
c:put(HX - 3, HY - 5, A.CREAM, htok) c:put(HX - 5, HY - 2, FL[6], htok) c:put(HX + 4, HY + 3, FL[5], htok)

-- quirk: juice drop hanging from the bottom of the half
local jtok = { r = { name = "drop" } }
local by = select(4, half:bbox())
local jx = HX - 2
for yy = by + 1, by + 4 do
  local w = (yy == by + 1) and 0 or ((yy == by + 4) and 0 or 1)
  for xx = jx - w, jx + w do c:put(xx, yy, FL[4], jtok) end
end
c:put(jx + 1, by + 3, FL[2], jtok) c:put(jx, by + 4, FL[2], jtok) c:put(jx - 1, by + 2, A.CREAM, jtok)
c:put(jx, by, FL[4], jtok)

A.save(c, NAME)
