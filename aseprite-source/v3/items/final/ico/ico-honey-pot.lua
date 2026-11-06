-- ico-honey-pot (final, Opus). A slim glass honey jar seen front-on: rounded shoulders, full of amber honey with an
-- air gap and a curved meniscus under the neck. Glass cues: a cream specular streak down the left, a pale cool rim
-- on the right edge, a thick pale glass base and glass showing above the honey. Honey cues: transmitted glow just
-- inside the shade edge (back-lit), deep amber core. A red gingham cloth cover over the lid (2x2 checks following
-- the shading, fold lines in the skirt, zigzag pinked hem) tied with a twisted twine band and a small bow.
-- A kraft label with a gold hexagon. AO under the skirt, contact shadow on the glass, 2-tone ground shadow.
-- quirk: one fat honey drip has escaped from under the cloth and hangs off the right shoulder.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-honey-pot")
local HON  = { "#6a2a12", "#9a4316", "#c8681a", "#e88f22", "#f7b636", "#ffdd78" }
local GLS  = { "#4f6680", "#7891ad", "#a3bfd2", "#cbe2ea", "#ecf8f4" }
local RED  = { "#5e1a30", "#8e243a", "#c0343d", "#e2523f", "#f57b58", "#ff9f78" }
local CHK  = { "#a87a88", "#c999a0", "#e6c0b8", "#f6dccc", "#fff0e0", "#fff8ee" }
local TW   = { "#5a3a22", "#8a6034", "#b98d52", "#e0bd80", "#f6deaa" }
local KR   = { "#7a5232", "#a87a4c", "#cfa46e", "#e9c88e", "#f8e2b0" }
local htok, gtok, ctok, ttok, ktok = A.tok("honey"), A.tok("glass"), A.tok("cloth"), A.tok("twine"), A.tok("label")

c:groundShadow(32, 57, 17, 2)
-- jar body (slim, shoulders round into the neck)
local body = HP.rrect(19, 25, 44, 56, 8)
body:add(HP.rect(22, 22, 41, 30))
local pn = X.pillow(body, 6)
local bn = {}
body:each(function(x, y) local k = K(x, y) local u = (x - 31.5) / 13.5
  local nx, ny = u * 0.98, pn[k][2] * 0.9 + 0.12
  bn[k] = { nx, ny, sqrt(max(0.03, 1 - nx * nx - ny * ny)) } end)
local LEV = 31  -- honey surface row
local honey, air = HP.mask(), HP.mask()
body:each(function(x, y)
  local men = (x < 21 or x > 42) and 1 or 0       -- meniscus climbs the glass wall
  if y >= LEV - men and y <= 54 then honey:set(x, y) else air:set(x, y) end
end)
local hidx = A.shade(c, honey, bn, HON, { tok = htok, amb = 0.05, wrap = 0.2, cuts = { 0.16, 0.34, 0.52, 0.7, 0.88 } })
-- transmitted glow: a warm band 2 px inside the lower-right edge (light through the honey)
local d = X.dist(body)
honey:each(function(x, y) local k = K(x, y) local n = bn[k]
  if d[k] and d[k] >= 1 and d[k] < 3 and n[1] + n[2] > 0.55 and y < 53 then A.step(c, hidx, HON, x, y, 2, htok) end end)
-- surface: lit meniscus row
for x = 20, 43 do if honey:has(x, LEV) then c:put(x, LEV, x < 34 and HON[6] or HON[5], htok) end end
-- glass parts: air above honey and the thick base
local base = body:copy():clip(HP.rect(0, 55, 63, 63))
air:add(base)
local gidx = A.shade(c, air, bn, GLS, { tok = gtok, amb = 0.25, wrap = 0.4, cuts = { 0.25, 0.45, 0.65, 0.82 } })
for x = 20, 43 do if base:has(x, 55) then c:put(x, 55, x < 30 and GLS[5] or GLS[4], gtok) end end
-- cool glass rim on the right edge, and a pale core streak on the left (specular)
body:edge():each(function(x, y) local k = K(x, y) if bn[k][1] > 0.45 and y > 26 and y < 55 then c:put(x, y, GLS[3], gtok) end end)
for y = 33, 49 do if y ~= 44 then c:put(21, y, "#fff4d6", gtok) if y < 42 then c:put(22, y, HON[6], htok) end end end
c:put(21, 51, HON[6], htok) c:put(21, 52, HON[6], htok)

-- kraft label with a gold hexagon
local lab = HP.rrect(27, 39, 38, 48, 1)
local lidx = A.pill(c, lab, 1.6, KR, { tok = ktok, amb = 0.2, wrap = 0.4 })
A.map(c, {
  "..aaaa..",
  ".abbbba.",
  "abbccbba",
  "abbccbba",
  ".abbbba.",
  "..aaaa..",
}, 29, 41, { a = "#a8521a", b = "#f5b82e", c = "#ffe38a" }, ktok)
for x = 27, 38 do if lab:has(x, 48) then c:put(x, 48, KR[1], ktok) end end
-- label casts a 1px shadow on the honey right and below
for y = 40, 49 do A.step(c, hidx, HON, 39, y, -1, htok) end
for x = 28, 39 do A.step(c, hidx, HON, x, 49, -1, htok) end

-- gingham cloth cover: dome over the lid + skirt with a pinked hem
local cloth = A.ell(31.5, 21, 15, 7):clip(HP.rect(0, 13, 63, 21))
cloth:add(HP.poly{ { 16.5, 19.5 }, { 46.5, 19.5 }, { 48, 27 }, { 15, 27 } })
for x = 14, 49 do local hb = 26 + ((x % 4 < 2) and 1 or 0) for y = hb + 1, 28 do cloth.s[K(x, y)] = nil end end
local cn = X.pillow(cloth, 4)
local cv = A.val(cn, { amb = 0.1, wrap = 0.3 })
-- skirt folds: alternate lit/shaded vertical pleats
cloth:each(function(x, y) local k = K(x, y)
  if y >= 21 then local f = (x - 15) % 6 cv[k] = max(0, min(1, cv[k] + (f < 2 and 0.12 or (f == 4 and -0.14 or 0)))) end end)
local cidx = X.tone(c, cloth, cv, RED, { cuts = { 0.22, 0.42, 0.6, 0.78, 0.93 }, tok = ctok })
cloth:each(function(x, y) local k = K(x, y)
  if (floor((x + 1) / 2) + floor(y / 2)) % 2 == 0 and floor(y / 2) % 2 == 0 then c:put(x, y, CHK[cidx[k]], ctok)
  elseif (floor((x + 1) / 2) % 2 == 0) or (floor(y / 2) % 2 == 0) then
    -- half-tone stripes of gingham: lighter red on crossing bands
    if (floor((x + 1) / 2) % 2 == 0) ~= (floor(y / 2) % 2 == 0) then c:put(x, y, RED[min(6, cidx[k] + 1)], ctok) end
  end end)
-- AO on the glass under the skirt hem
for x = 18, 45 do for y = 27, 28 do if air:has(x, y) and not cloth:has(x, y) then A.step(c, gidx, GLS, x, y, y == 27 and -2 or -1, gtok) end end end
-- twisted twine band + bow
local tw = HP.rect(16, 21, 47, 22)
tw:each(function(x, y) local ph = (x + (y == 22 and 1 or 0)) % 3
  local i = ph == 0 and 1 or (ph == 1 and (x < 32 and 5 or 4) or 3)
  c:put(x, y, TW[i], ttok) end)
-- bow: two loops and two tails around a dark knot (front, right of centre)
A.map(c, {
  ".eee...eee.",
  "eddce.ecdde",
  "edcbeaebcde",
  "ecbbbabbbce",
  ".eee.a.eee.",
  "....eae....",
  "...ece.ece.",
  "...eb...be.",
  "....e...e..",
}, 34, 18, { a = TW[1], b = TW[2], c = TW[3], d = TW[5], e = "#3a2416" }, ttok)
-- dome sheen 2x1 + cream glint
c:put(23, 15, RED[6], ctok) c:put(24, 15, RED[6], ctok) c:put(22, 16, "#fff4d6", ctok)

-- quirk: honey drip hanging off the right shoulder, over the glass edge
A.map(c, {
  "abc.",
  "abc.",
  "abbc",
  ".abc",
  ".abc",
  ".abc",
  ".abbc",
  ".wabc",
  "abbbc",
  "abbcd",
  ".ccd.",
}, 43, 27, { w = "#fff4d6", a = HON[6], b = HON[5], c = HON[3], d = HON[2] }, htok)
A.save(c, "ico-honey-pot")
