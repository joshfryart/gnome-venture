-- pumpkin (batch2, Opus single pass, replaces the Sonnet draft). A taller-than-usual, upright pumpkin: five overlapping
-- ribs (centre front, inner pair, outer pair), each rib its own ellipsoid normal blended with the whole-body sphere so
-- the fruit reads round under upper-left light; deep grooves (AO) where ribs meet, a paler waxy streak along each rib
-- crest, cool reflected light lower-right, one glossy specular. A slim, ridged, curving woody stem with a pale cut end
-- grain, a sunken socket, one palmate pumpkin leaf and a curly tendril. Ground shadow (it stands).
-- quirk: a ladybird is out for a walk on the leaf.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_b2g2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, sqrt, max, min, abs, pi, cos, sin = math.floor, math.sqrt, math.max, math.min, math.abs, math.pi, math.cos, math.sin
local norm = G.norm
local c = G.new2("pumpkin")

local OR   = { "#6b2438", "#a8372e", "#d25a22", "#ee7d22", "#f9a23c", "#ffcf6e" }
local STEM = { "#2f3324", "#4c5530", "#6d7a3a", "#8f9a4a", "#b7b967", "#ddd796" }
local LEAF = { "#173f33", "#225a3d", "#2f7744", "#46954b", "#68b452", "#98d06a" }
local COOL, SPEC = "#94506a", "#fff4d6"

local CX, CY = 32, 41
c:groundShadow(32, 56, 15, 1.5)

-- ribs: back to front
local ribs = {
  { 20.0, 42.5, 4.6, 10.6 }, { 44.0, 42.5, 4.6, 10.6 },
  { 25.5, 41.5, 6.0, 12.6 }, { 38.5, 41.5, 6.0, 12.6 },
  { 32.0, 41, 6.6, 13.8 },
}
local body, own = HP.mask(), {}
for i, r in ipairs(ribs) do
  r.m = c:ellipse(r[1], r[2], r[3], r[4])
  r.m:each(function(x, y) own[K(x, y)] = i end)
  body:add(r.m)
end
local n, bias = {}, {}
local GRX, GRY = 13.5, 15
body:each(function(x, y)
  local k = K(x, y) local r = ribs[own[k]]
  local lx, ly = (x - r[1]) / (r[3] + .5), (y - r[2]) / (r[4] + .5)
  local lz = sqrt(max(0.03, 1 - lx * lx - ly * ly))
  local gx, gy = (x - CX + .6) / GRX, (y - CY + .6) / GRY
  gx, gy = max(-1, min(1, gx)), max(-1, min(1, gy))
  local gz = sqrt(max(0.03, 1 - min(0.97, gx * gx + gy * gy)))
  n[k] = { norm(lx * 0.8 + gx * 0.6, ly * 0.4 + gy * 0.8, lz * 0.5 + gz * 0.6) }
end)
-- grooves: the back rib darkens where a front rib overlaps it
for i, r in ipairs(ribs) do
  local front = HP.mask()
  for j = i + 1, #ribs do front:add(ribs[j].m) end
  r.m:each(function(x, y) local k = K(x, y)
    if own[k] ~= i then return end
    if front:has(x + 1, y) or front:has(x - 1, y) then bias[k] = (bias[k] or 0) - 2
    elseif front:has(x + 2, y) or front:has(x - 2, y) then bias[k] = (bias[k] or 0) - 1 end
  end)
  -- crease on the front rib's own edge where it lies over a back rib
  r.m:each(function(x, y) local k = K(x, y)
    if own[k] == i and i > 2 then for j = 1, i - 1 do
      if ribs[j].m:has(x - 1, y) and not r.m:has(x - 1, y) or ribs[j].m:has(x + 1, y) and not r.m:has(x + 1, y) then bias[k] = (bias[k] or 0) - 1 return end end end
  end)
end
-- socket: ring of AO around the stem foot
local socket = c:ellipse(33, 28.5, 3.2, 1.6)
X.ao(bias, body, socket, 2, -1)
local btok = { r = { name = "body" } }
local idx = G.toneN(c, body, n, OR, { bias = bias, tok = btok, amb = 0.12, wrap = 0.55, cuts = { 0.2, 0.36, 0.52, 0.67, 0.82 } })
socket:each(function(x, y) if body:has(x, y) then c:put(x, y, (y <= 28) and OR[1] or OR[2], btok) end end)
-- waxy streak along each rib crest (lit half only), broken every few px
for i, r in ipairs(ribs) do
  local sx = floor(r[1] - r[3] * 0.25 + .5)
  for y = floor(r[2] - r[4] * 0.62), floor(r[2] + r[4] * 0.35) do
    local k = K(sx, y)
    if own[k] == i and not bias[k] and (y % 5 ~= 0) and idx[k] and idx[k] >= 3 and idx[k] <= 5 then
      c:put(sx, y, OR[min(6, idx[k] + 1)], btok) end
  end
end
-- cool reflected light on the lower-right rim
local rim = X.rim(n)
body:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.62 and not bias[k] and y > 40 then c:put(x, y, COOL, btok) end end)
-- underside: deep row where the fruit sits
body:each(function(x, y) if not body:has(x, y + 1) and y > 50 then c:put(x, y, OR[1], btok) end end)
-- specular: one glossy 2x1 + bloom on the inner-left rib
c:put(23, 33, SPEC, btok) c:put(24, 33, SPEC, btok) c:put(23, 34, OR[6], btok) c:put(25, 33, OR[6], btok)

-- leaf (palmate, five pointed lobes), petiole tucked behind the stem
local LB = { 17, 20 }
local leaf, ln, inf = G.palm(LB[1], LB[2], {
  { -2.2, 10.5 }, { -1.4, 11 }, { -0.65, 7.5 }, { -2.95, 9.5 }, { 2.6, 7 },
}, { sharp = 4, floor = 0.4, serr = true })
leaf:cut(body)
local lbias = {}
local ltok = { r = { name = "leaf" } }
G.toneN(c, leaf, ln, LEAF, { bias = lbias, tok = ltok, amb = 0.12, wrap = 0.25, cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
-- palmate veins: midrib of each lobe from the base, pale on lit side
leaf:each(function(x, y) local k = K(x, y) local f = inf[k]
  if abs(f.da) * f.r < 0.55 and f.r > 1.2 and f.r < f.R - 1.2 then c:put(x, y, LEAF[6], ltok)
  elseif f.r > 1.5 and abs(abs(f.da) * f.r - 3.2) < 0.45 and f.r > 4 and f.r < f.R - 2 and (floor(f.r) % 3 == 0) then
    c:put(x, y, f.da < 0 and LEAF[5] or LEAF[2], ltok) end
end)
-- petiole: from the leaf base to behind the stem
local pm, pn = G.tube({ { 17, 21 }, { 21, 25 }, { 26, 26 }, { 31, 27 } }, function(t) return 0.85 end)
pm:cut(body) pm:cut(leaf)
G.toneN(c, pm, pn, LEAF, { tok = { r = { name = "pet" } }, amb = 0.15, cuts = { 0.25, 0.45, 0.62, 0.78, 0.9 } })

-- stem: slim, curving to the right, ridged, pale cut end
local stm, sn, ST, SS = G.tube({ { 33, 29 }, { 32.5, 22 }, { 33.5, 16 }, { 38, 12.5 } }, function(t) return 2.4 - 0.7 * t + (t < 0.12 and (0.12 - t) * 9 or 0) end)
local sb = {}
stm:each(function(x, y) local k = K(x, y) if ST[k] < 0.08 then sb[k] = -1 end end)
local stok = { r = { name = "stem" } }
local sidx = G.toneN(c, stm, sn, STEM, { tok = stok, bias = sb, amb = 0.12, wrap = 0.3 })
stm:each(function(x, y) local k = K(x, y)            -- ridges (woody, fibrous): two dark grooves along the stem
  if abs(SS[k] - 0.25) < 0.14 and ST[k] > 0.12 and ST[k] < 0.92 then c:put(x, y, STEM[max(1, sidx[k] - 2)], stok) end
  if abs(SS[k] + 0.45) < 0.12 and ST[k] > 0.15 and ST[k] < 0.85 then c:put(x, y, STEM[min(6, sidx[k] + 1)], stok) end
end)
-- cut end grain: pale oval cap with a darker core
for _, p in ipairs{ { 38, 11, 6 }, { 39, 11, 6 }, { 38, 12, 5 }, { 39, 12, 4 }, { 40, 12, 5 }, { 39, 13, 3 }, { 40, 13, 4 } } do
  c:put(p[1], p[2], STEM[p[3]], stok) end

-- tendril: thin corkscrew curling off the stem foot to the right
local tp = { { 35, 23 }, { 37, 22.5 } }
for i = 0, 40 do
  local t = i / 40
  local a = pi + t * pi * 3.1               -- clockwise from the left side of the coil
  local r = 4.3 - t * 2.9
  tp[#tp + 1] = { 43.3 + t * 1.5 + cos(a) * r * 1.1, 21 - t * 1 + sin(a) * r }
end
local ttok = { r = { name = "tendril" } }
local tm = G.path(tp)
tm:cut(stm)
tm:each(function(x, y) c:put(x, y, (tm:has(x, y - 1) or not tm:has(x, y + 1)) and LEAF[5] or LEAF[3], ttok) end)
c:put(35, 23, LEAF[4], ttok) c:put(36, 23, LEAF[4], ttok)

-- quirk: ladybird on the leaf (red dome, ink head, spot, glint)
local lady = { r = { name = "lady" } }
local LX, LY = 11, 13
for _, p in ipairs{ { 1, 0, "#e8493b" }, { 2, 0, "#e8493b" }, { 3, 0, "#b52e3f" }, { 1, 1, "#e8493b" }, { 2, 1, "#2b1c26" }, { 3, 1, "#b52e3f" },
  { 1, -1, "#ffb08a" }, { 2, -1, "#e8493b" }, { 0, 0, "#2b1c26" }, { 0, -1, "#2b1c26" }, { 2, 2, "#6e2038" }, { 1, 2, "#b52e3f" } } do
  c:put(LX + p[1], LY + p[2], p[3], lady) end

-- centre the drawing (bbox incl. the outline-to-be)
do local x0, y0, x1, y1 = 99, 99, -1, -1
  for i in pairs(c.pix) do local x, y = i % 64, i // 64 x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  x0, y0, x1, y1 = x0 - 1, y0 - 1, x1 + 1, y1 + 1
  G.shift(c, floor((64 - (x1 - x0 + 1)) / 2) - x0, floor((64 - (y1 - y0 + 1)) / 2) - y0)
end
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = G.out .. "pumpkin.aseprite", png = G.out .. "pumpkin.png", scale = 1 }
