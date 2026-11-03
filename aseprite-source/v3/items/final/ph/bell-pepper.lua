-- bell-pepper (final pass, Opus). A glossy purple bell pepper, a little taller than wide: three front lobes (each its
-- own ellipsoid, the middle one forward) with dark AO grooves between them, rounded shoulders dipping into a sunken
-- calyx pit, knobbly lobed base. Waxy skin: 6-tone violet ramp, long vertical specular streaks on each lobe, pale
-- waxy bloom near the shoulder, cool reflected light on the shade side. Green five-point calyx and a curved, ridged
-- stem with a pale cut end.
-- quirk: a single water drop sliding down the left lobe, leaving a tiny wet trail.
local NAME = "bell-pepper"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR4_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, sin, cos, pi, atan = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi, math.atan
local c = A.new(NAME)
local PUR = { "#2a1236", "#461e5c", "#672a82", "#8c3aa8", "#b25ec8", "#da9ae8" }
local BLOOM, COOL, SPEC = "#c8a6dc", "#5a4ca0", "#fbeeff"
local GRN = { "#173f36", "#245c3c", "#357a42", "#4e9a48", "#79bc58", "#b4dc80" }
local STEMC = { "#2a4a2e", "#3e6a36", "#5a8c40", "#82ac52", "#b6cc7a", "#e2e6a8" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- lobes: cx, cy, rx, ry
local lobes = { { 23.5, 40.5, 7.6, 12.8 }, { 40.5, 40.5, 7.6, 12.8 }, { 32, 42, 6.9, 12.6 } }
local body = HP.mask()
for _, l in ipairs(lobes) do l.m = HP.ellipse(l[1], l[2], l[3], l[4]) body:add(l.m) end
-- shoulders: flatten the top and dip toward the calyx
local function topY(x) local d = abs(x - 32) return 28.5 + (d < 6 and (6 - d) * 0.3 or 0) end
for _, l in ipairs(lobes) do
  local cut = HP.mask()
  l.m:each(function(x, y) if y < topY(x) then cut:set(x, y) end end)
  l.m:cut(cut)
end
-- small notches between the base knobs
for _, l in ipairs(lobes) do l.m:cut(HP.rect(28, 53, 28, 56)) l.m:cut(HP.rect(36, 53, 36, 56)) end

local ptok = { r = { name = "pepper" } }
for i, l in ipairs(lobes) do
  local n = A.ellN(l.m, l[1] - 0.4, l[2] - 1, l[3], l[4])
  -- pillow the top shoulder so it rolls over
  local np = X.pillow(l.m, 2.5)
  for k, v in pairs(n) do local q = np[k] n[k] = { A.norm(v[1] * 0.7 + q[1] * 0.3, v[2] * 0.7 + q[2] * 0.5, v[3] * 0.7 + q[3] * 0.3) } end
  local bias = {}
  if i < 3 then X.ao(bias, l.m, lobes[3].m, 2, -1) end
  local vis = l.m:copy()
  if i < 3 then vis:cut(lobes[3].m) end
  local idx = A.shade(c, vis, n, PUR, { amb = 0.08, wrap = 0.32, cuts = CUTS, bias = bias, tok = ptok })
  l.idx, l.n, l.vis = idx, n, vis
  -- cool reflected light on the shade edge of the right lobe and front lobe
  local rv = X.rim(n)
  vis:edge():each(function(x, y) local k = K(x, y)
    if rv[k] and rv[k] > 0.5 and idx[k] <= 2 and y > 34 and (i == 2 or i == 3) then c:put(x, y, COOL, ptok) end end)
end
-- grooves where the front lobe overlaps the side lobes: deep line on the seam, AO row on the side lobe
local F = lobes[3]
F.m:edge():each(function(x, y)
  local onL = lobes[1].m:has(x - 1, y) and not F.m:has(x - 1, y)
  local onR = lobes[2].m:has(x + 1, y) and not F.m:has(x + 1, y)
  if (onL or onR) and y > 30 and y < 54 then
    c:put(x, y, onL and PUR[3] or PUR[1], ptok)
    local sx = onL and x - 1 or x + 1
    local L = onL and lobes[1] or lobes[2]
    if L.idx[K(sx, y)] then c:put(sx, y, PUR[onL and 2 or 1], ptok) end
  end end)
-- waxy bloom: pale haze on the upper lit shoulder of the side lobes
for _, p in ipairs{ { 21, 31 }, { 22, 30 }, { 23, 30 }, { 20, 32 }, { 36, 30 }, { 37, 30 } } do
  local k = K(p[1], p[2]) if body:has(p[1], p[2]) then c:put(p[1], p[2], BLOOM, ptok) end end
-- specular streaks: long vertical glints following each lobe
local function streak(x, y0, y1, hot)
  for y = y0, y1 do c:put(x, y, PUR[6], ptok) end
  if hot then c:put(x, hot, SPEC, ptok) c:put(x, hot + 1, SPEC, ptok) end
end
streak(20, 35, 42, 36) streak(21, 33, 35)
streak(28, 34, 44, 35) streak(29, 32, 34)
streak(36, 33, 38)

-- quirk: water drop on the left lobe, with a wet trail above it
local dx, dy = 24, 47
for _, p in ipairs{ { 24, 41 }, { 24, 42 }, { 24, 44 } } do c:put(p[1], p[2], PUR[5], ptok) end
c:paint({ ".a.", "abc", "bcd", ".d." }, dx - 1, dy - 1, { a = SPEC, b = "#b9a2e6", c = PUR[4], d = PUR[1] })

-- calyx pit (sunken, dark) and five-point calyx
local pit = HP.ellipse(32, 28, 6, 1.6)
pit:each(function(x, y) c:put(x, y, PUR[1], ptok) end)
local calyx = HP.ellipse(32, 28, 3, 1.5)
for _, a in ipairs{ 0.35, 1.15, 1.95, 2.8 } do
  local ux, uy = cos(a), sin(a) * 0.55
  local l = sqrt(ux*ux + uy*uy) ux, uy = ux / l, uy / l
  calyx:add(A.rell(32 + ux * 4.2, 28.4 + uy * 2.6, ux, uy, 3.6, 1.3))
end
calyx:add(A.rell(32, 25.8, 0, 1, 1.8, 2.6))
local cn = X.pillow(calyx, 1.4)
local ctok = { r = { name = "calyx" } }
local cidx = A.shade(c, calyx, cn, GRN, { amb = 0.1, wrap = 0.3, cuts = CUTS, tok = ctok })
-- contact shadow under the calyx points
calyx:shift(0, 1):each(function(x, y) if not calyx:has(x, y) and body:has(x, y) then
  local k = K(x, y)
  for _, l in ipairs(lobes) do if l.idx[k] then A.step(c, l.idx, PUR, x, y, -2, ptok) end end end end)

-- stem: curved, ridged, cut end
local sp = { { 32, 27 }, { 31.5, 21 }, { 33, 16 }, { 37.5, 13.5 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return 2.4 - t * 0.7 end)
sm:cut(calyx)
local stok = { r = { name = "stem" } }
local sidx = A.shade(c, sm, sn, STEMC, { amb = 0.12, wrap = 0.3, cuts = CUTS, tok = stok })
-- ridges (fibrous lines along the stem)
sm:each(function(x, y) local k = K(x, y) if abs(SS[k] - 0.1) < 0.18 and ST[k] > 0.1 and ST[k] < 0.92 then A.step(c, sidx, STEMC, x, y, -1, stok) end end)
-- AO where the stem leaves the calyx
calyx:grow(1):each(function(x, y) if sm:has(x, y) then A.step(c, sidx, STEMC, x, y, -1, stok) end end)
-- cut end: pale fibrous face
for _, p in ipairs{ { 38, 12, 6 }, { 39, 13, 6 }, { 39, 14, 5 }, { 38, 13, 5 }, { 39, 12, 5 } } do
  c:put(p[1], p[2], STEMC[p[3]], stok) end
c:put(38, 14, STEMC[3], stok)

A.save(c, NAME)
