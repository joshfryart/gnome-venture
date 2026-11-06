-- ico-bee (Opus single pass). Side profile, flying left: round gold face with a smile, fuzzy amber thorax,
-- slim tapered abdomen tilted down with three dark bands and a stinger; two glassy wings raised behind,
-- elbowed antennae, three dangling legs.
-- Material: per-pixel ellipsoid light (6 tones per material), fur flecks + fuzzy silhouette on the thorax,
-- wings as glass (bright rim, pale core, dark veins), AO where head/thorax/abdomen meet, cool bounce on belly.
-- quirk: the hind leg carries a fat orange pollen basket.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, abs, max, min, sqrt, pi = math.floor, math.sin, math.cos, math.abs, math.max, math.min, math.sqrt, math.pi
local c = A.new("ico-bee")
local FACE = { "#7a3a1e", "#b8601f", "#e08c22", "#f7b02e", "#ffd256", "#ffee9e" }
local FUR  = { "#6a321e", "#9e4e1e", "#cf7420", "#ec9a2a", "#fcc04a", "#ffe08a" }
local DARK = { "#1c1222", "#2c1d30", "#3f2c40", "#564054", "#74586a", "#94788a" }
local WING = { "#4a7aa6", "#78aed0", "#a6d6ea", "#cdeef6", "#e6f8fb", "#f6feff" }
local POL  = { "#8f3a1f", "#c8571f", "#f07a22", "#ff9e3a", "#ffc25e", "#ffe29a" }
local BOUNCE = "#9a7ab8"

-- wings first (behind the body)
local function wing(rx0, ry0, tx, ty, wid)
  local cx, cy = (rx0 + tx) / 2, (ry0 + ty) / 2
  local ang = math.atan(ty - ry0, tx - rx0)
  local len = sqrt((tx - rx0)^2 + (ty - ry0)^2) / 2
  local m, n = A.egg(cx, cy, len, wid, ang, 0.5)
  local idx = A.shade(m, n, WING, { amb = 0.35, wrap = 0.5, cuts = { 0.15, 0.3, 0.5, 0.7, 0.85 } })
  -- veins: from root along the wing, slightly fanned
  local ux, uy = cos(ang), sin(ang)
  for _, off in ipairs{ -0.35, 0.3 } do
    for i = 2, floor(len * 1.6) do
      local t = i / (len * 2)
      local x = rx0 + ux * i - uy * off * wid * t * 2
      local y = ry0 + uy * i + ux * off * wid * t * 2
      local xi, yi = floor(x + .5), floor(y + .5)
      if m:has(xi, yi) and not m:edge():has(xi, yi) then A.set(idx, WING, xi, yi, 1) end
    end
  end
  -- bright rim on the upper-left edge, darker rim lower-right
  m:edge():each(function(x, y) local nn = n[K(x, y)]
    if nn and nn[1] * -0.6 + nn[2] * -0.8 > 0.25 then A.set(idx, WING, x, y, 6)
    elseif nn and nn[1] * 0.6 + nn[2] * 0.8 > 0.3 then A.set(idx, WING, x, y, 2) end end)
  return m, idx
end
local hw, hidx = wing(28, 27, 44, 15, 3.6)
local fw, fidx = wing(25, 26, 35, 9, 4.4)
A.ao(hidx, WING, hw, fw, 1, -1)

-- legs (dark, 2 px), dangling forward
local legs = {
  { { 21, 37 }, { 19, 42 }, { 20, 46 } },
  { { 26, 38 }, { 26, 43 }, { 28, 47 } },
  { { 31, 40 }, { 34, 45 }, { 37, 48 } },
}
local legm = {}
for i, L in ipairs(legs) do
  local m = A.limb(L, 1.0)
  local n = {}
  m:each(function(x, y) n[K(x, y)] = { -0.4, -0.4, 0.8 } end)
  local idx = A.shade(m, n, DARK, { bias = setmetatable({}, { __index = function() return -2 end }) })
  m:each(function(x, y) if not m:has(x - 1, y) or not m:has(x, y - 1) then A.set(idx, DARK, x, y, 4) end end)
  -- knee joint highlight
  A.set(idx, DARK, L[2][1], L[2][2], 6)
  legm[i] = m
end

-- abdomen: tapered ellipsoid tilted down to the right, three dark bands, stinger
local AX, AY, AR, ARy, AA = 40, 37, 11, 7.6, 0.38
local am, an = A.egg(AX, AY, AR, ARy, AA, 0.9)
-- taper the tail end
local ca, sa = cos(AA), sin(AA)
am:each(function(x, y)
  local u = (x - AX) * ca + (y - AY) * sa
  local v = -(x - AX) * sa + (y - AY) * ca
  if u > 4 and abs(v) > ARy * (1 - ((u - 4) / (AR - 3))^1.6) then am.s[K(x, y)] = nil end
end)
-- stinger
local sx, sy = AX + ca * (AR + 0.5), AY + sa * (AR + 0.5)
for i = 0, 3 do
  local x, y = floor(sx + ca * i + .5), floor(sy + sa * i + .5)
  am:set(x, y) an[K(x, y)] = { 0.3, -0.3, 0.9 }
  if i < 2 then am:set(x, y - 1) an[K(x, y - 1)] = { -0.2, -0.6, 0.8 } end
end
local av = X.light(an, { amb = 0.08, wrap = 0.25 })
local band = {}
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.87 }
local aidx = {}
am:each(function(x, y)
  local k = K(x, y)
  local u = (x - AX) * ca + (y - AY) * sa - 0.25 * ((x - AX) * -sa + (y - AY) * ca)
  local dark = (u > -4.5 and u < -1.5) or (u > 1.5 and u < 4.5) or (u > 7.5 and u < 9.5) or u >= AR + 0.3
  band[k] = dark
  local i = 1 for j, t in ipairs(CUTS) do if (av[k] or 0) >= t then i = j + 1 end end
  aidx[k] = i
  c:px(x, y, (dark and DARK or FACE)[i])
end)
-- bounce light on the belly edge
am:edge():each(function(x, y) local nn = an[K(x, y)]
  if nn and nn[1] * 0.3 + nn[2] * 0.95 > 0.55 and not band[K(x, y)] then c:px(x, y, BOUNCE) end end)
-- waxy gloss streak on top of the abdomen
for _, p in ipairs{ { 35, 31 }, { 36, 31 }, { 37, 31 }, { 41, 33 }, { 42, 33 } } do
  if am:has(p[1], p[2]) then c:px(p[1], p[2], band[K(p[1], p[2])] and DARK[6] or FACE[6]) end end

-- thorax: fuzzy amber ball
local tm, tn = A.egg(26, 31, 6.4, 6.8, 0, 0.95)
-- fuzzy silhouette: 1px tufts on the top/back
for _, p in ipairs{ { 22, 24 }, { 25, 23 }, { 28, 24 }, { 31, 26 }, { 33, 29 } } do tm:set(p[1], p[2]) tn[K(p[1], p[2])] = { -0.2, -0.9, 0.4 } end
local tbias = {}
tm:each(function(x, y) local h = X.hash(x, y, 11)
  if h < 0.14 then tbias[K(x, y)] = -1 elseif h > 0.88 then tbias[K(x, y)] = 1 end end)
local tidx = A.shade(tm, tn, FUR, { bias = tbias })
A.ao(aidx, FACE, am, tm, 1, -1)
-- repaint abdomen pixels next to the thorax a tone darker (keep band colours)
tm:grow(1):copy():cut(tm):each(function(x, y) local k = K(x, y)
  if am:has(x, y) and aidx[k] then c:px(x, y, (band[k] and DARK or FACE)[max(1, aidx[k] - 1)]) end end)
-- thorax shadow where it meets the wing roots
for _, p in ipairs{ { 24, 25 }, { 25, 25 }, { 27, 25 } } do A.sh(tidx, FUR, p[1], p[2], -1) end

-- head: round gold face, profile to the left
local hm, hn = A.egg(15, 33, 6.2, 6.4, 0, 0.95)
local hidx2 = A.shade(hm, hn, FACE)
A.ao(tidx, FUR, tm, hm, 1, -1)
A.ao(hidx2, FACE, hm, tm, 1, -1)
-- neck seam: deep line where the face meets the fur
hm:each(function(x, y) if tm:has(x + 1, y) or tm:has(x, y + 1) then A.set(hidx2, FACE, x, y, 1) end end)
-- antennae: elbowed, dark, clubbed
for _, a in ipairs{ { { 15, 27 }, { 12, 21 }, { 7, 18 } }, { { 18, 27 }, { 18, 21 }, { 14, 16 } } } do
  for i = 1, 2 do A.ln(a[i][1], a[i][2], a[i+1][1], a[i+1][2], DARK[3]) end
  c:px(a[2][1], a[2][2], DARK[5])
  c:px(a[3][1], a[3][2], DARK[2]) c:px(a[3][1] - 1, a[3][2], DARK[2]) c:px(a[3][1], a[3][2] - 1, DARK[4]) c:px(a[3][1] - 1, a[3][2] - 1, DARK[3])
end
-- face: eye, smile, cheek
c:eyeSmall(12, 30)
c:px(9, 36, A.INK) c:px(10, 37, A.INK) c:px(11, 37, A.INK) c:px(12, 36, A.INK)
c:cheek(14, 35)
-- head gloss
c:px(14, 28, FACE[6]) c:px(15, 28, FACE[6])

-- quirk: pollen basket on the hind leg
local pm = c:ellipse(35.5, 46, 2.4, 2.2)
local pn = X.sphere(35, 45.5, 2.6, pm)
local pidx = A.shade(pm, pn, POL)
pm:each(function(x, y) if X.hash(x, y, 5) > 0.75 then A.sh(pidx, POL, x, y, 1) end end)
c:px(34, 44, "#fff4d6")

A.save("ico-bee")
