-- apple (final pass, Opus single pass). Slightly tall dessert apple: two soft shoulders, a sunken stem cavity, a
-- narrower base with a calyx star. Material: height-field lit skin (6-tone red, cool-violet shade), yellow-orange
-- meridian streaks on the sunny side, pale lenticel dots, waxy bloom sheen on the upper rim, one window specular
-- + glint, cool reflected light lower-right, AO in the stem cavity. Thin woody stem with a lit edge, one veined leaf.
-- quirk: somebody has taken one bite out of the right side (scalloped tooth marks, pale juicy flesh).
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, exp, sin, atan = math.floor, math.sqrt, math.max, math.min, math.abs, math.exp, math.sin, math.atan
local c = A.new("apple")
local RED   = { "#561838", "#86203a", "#b42636", "#d83a38", "#f05e48", "#ff9373" }
local STRK  = { "#6a2632", "#a33c30", "#d0602e", "#eb8a3a", "#f8b052", "#ffd47c" }
local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local WOOD  = { "#3e2526", "#5e3a2e", "#86573a", "#b07c4e" }
local FLESH = { "#c8925a", "#e0b672", "#f0d390", "#f9e8b4", "#fff2cc" }
local BOUNCE, BLOOM, SPEC = "#9a3a62", "#f39a8c", "#fff1cf"

-- stem first (skin and leaf go over its foot)
local stok = { r = { name = "stem" } }
local stem = { { 32, 25 }, { 32, 21 }, { 33, 17 }, { 34, 13 } }
local sm = HP.mask()
for i = 0, 40 do local t = i / 40 local x, y = A.bez(stem, t)
  local xi, yi = floor(x + .5), floor(y + .5)
  sm:set(xi, yi) sm:set(xi + 1, yi) end
sm:each(function(x, y) local lit = not sm:has(x - 1, y)
  c:put(x, y, lit and WOOD[3] or WOOD[2], stok) end)
c:put(34, 13, WOOD[4], stok) c:put(35, 13, WOOD[3], stok) c:put(34, 14, WOOD[4], stok)

-- leaf from the stem, out to the upper right
local ltok = { r = { name = "leaf" } }
local lm, ln, LT, LS = A.blade(35, 17, 41, 9, 50, 11, function(t) return 4.6 * sin(math.pi * t) ^ 0.8 - 0.2 end, { fold = 0.5 })
local lbias = {}
lm:each(function(x, y) local k = K(x, y) if LT[k] < 0.12 then lbias[k] = -1 end end)
local lidx = A.shade(c, lm, ln, LEAF, { tok = ltok, bias = lbias, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  if abs(s) < 0.16 and t > 0.08 and t < 0.92 then c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok)
  else
    local ph = (t * 20 - abs(s) * 4.2) % 4
    if ph < 0.7 and abs(s) < 0.75 and t > 0.15 and t < 0.85 then A.step(c, lidx, LEAF, x, y, s < 0 and 1 or -1, ltok) end
  end
end)

-- skin: height field = soft max of two shoulder spheres and a body ellipsoid, minus the stem cavity
local function sph(x, y, cx, cy, rx, ry, r)
  local u, v = (x - cx) / rx, (y - cy) / ry
  local q = 1 - u*u - v*v
  if q <= 0 then return 0 end
  return r * sqrt(q)
end
local function H(x, y)
  local a, b, d = sph(x, y, 26.2, 30, 12.6, 12.3, 12), sph(x, y, 37.8, 30, 12.6, 12.3, 12), sph(x, y, 32, 37, 16.2, 14.6, 15)
  if max(a, b, d) <= 0 then return 0 end
  local kk = 2.5
  local h = kk * math.log(exp(a / kk) + exp(b / kk) + exp(d / kk)) - kk * math.log(3)
  h = max(h, 0.05)
  h = h - 4.2 * exp(-((x - 32.3)^2 / 14 + (y - 22.5)^2 / 12))
  return h
end
local am, an = A.hfield(H, 10, 12, 54, 56, 1.0)
-- bite notch (scalloped)
local BX, BY, BR = 51.5, 36, 7.2
local function brad(x, y) local th = atan(y - BY, x - BX) return BR + 0.9 * abs(sin(th * 3.2)) end
local notch, band = HP.mask(), HP.mask()
am:each(function(x, y) local d = sqrt((x - BX)^2 + (y - BY)^2)
  local r = brad(x, y)
  if d <= r then notch:set(x, y) elseif d <= r + 3.4 then band:set(x, y) end end)
am:cut(notch)
local stokS = { r = { name = "skin" } }
local bias = {}
am:each(function(x, y) local k = K(x, y)
  if (x - 32.5)^2 / 12 + (y - 24)^2 / 4 <= 1 then bias[k] = -1 end end)
local sidx = A.shade(c, am, an, RED, { tok = stokS, bias = bias, amb = 0.06, wrap = 0.18, cuts = { 0.24, 0.42, 0.6, 0.77, 0.91 } })
local e = am:edge()
-- meridian streaks on the lit side: thin lines that follow the bulge (u = position across the row)
local rowx = {}
am:each(function(x, y) local r = rowx[y] or { 99, -99 } rowx[y] = { min(r[1], x), max(r[2], x) } end)
am:each(function(x, y) local k = K(x, y)
  local i = sidx[k]
  local r = rowx[y]
  local u = ((x - r[1]) / (r[2] - r[1] + 1)) * 2 - 1
  local ang = math.asin(max(-1, min(1, u)))
  local f = (ang * 4.2 + 3.1) % 1
  if i >= 4 and f < 0.2 and y > 22 and y < 46 and u < 0.35 and X.hash(floor(ang * 4.2), y > 34 and 1 or 0, 3) > 0.25 then
    c:put(x, y, STRK[i], stokS)
  end
end)
-- lenticels: sparse pale dots
am:each(function(x, y) local k = K(x, y) local i = sidx[k]
  if i >= 3 and i <= 4 and X.hash(x, y, 11) < 0.018 and not e:has(x, y) then c:put(x, y, RED[i + 2], stokS) end end)
-- waxy bloom sheen: a thin pale band just inside the upper-left rim
local e2 = am:copy():shrink(1):edge()
e2:each(function(x, y) local k = K(x, y)
  if (x + y) < 52 and (x - 32) < -3 and sidx[k] and sidx[k] >= 4 then c:put(x, y, BLOOM, stokS) end end)
-- cool reflected light on the lower-right rim
local rim = X.rim(an)
e:each(function(x, y) local k = K(x, y)
  if rim[k] and rim[k] > 0.55 and y > 38 and x > 30 and not band:has(x, y) then c:put(x, y, BOUNCE, stokS) end end)
-- window specular + glint on the left shoulder
A.map(c, { ".sss", "sSSs", "sSs.", ".s.." }, 20, 25, { s = RED[6], S = SPEC }, stokS)
-- stem cavity crease
A.map(c, { "d....dd", ".dd.dd.", "...d..." }, 29, 23, { d = RED[2] }, stokS)
c:put(25, 29, RED[6], stokS) c:put(19, 33, RED[6], stokS) c:put(19, 34, RED[6], stokS)
-- calyx star at the base
A.map(c, { ".d.d.", "..D..", ".dDd.", "d.d.d" }, 31, 47, { d = RED[2], D = RED[1] }, stokS)

-- bite: concave scoop flesh, lit where it faces up-left
local ftok = { r = { name = "flesh" } }
band:clip(am)
local bn = {}
band:each(function(x, y) local dx, dy = BX - x, BY - y local l = sqrt(dx*dx + dy*dy)
  bn[K(x, y)] = { A.norm(dx / l * 0.8, dy / l * 0.8, 0.6) } end)
A.shade(c, band, bn, FLESH, { tok = ftok, amb = 0.25, wrap = 0.4, cuts = { 0.3, 0.5, 0.68, 0.84 } })
-- rind: outer ring of the band = red skin where it was cut
band:each(function(x, y)
  local d = sqrt((x - BX)^2 + (y - BY)^2)
  if d > brad(x, y) + 2.6 then c:put(x, y, RED[3], ftok) end
end)
c:put(45, 39, SPEC, ftok)
c:put(33, 25, WOOD[1], stok)

A.save(c, "apple")
