-- ico-duck (final pass, Opus single pass). Bold icon: a sleek yellow rubber duck in side view, facing left: a long
-- low hull with an upswept tail, a round head on a short neck, a two-part orange beak. Rubber material: per-pixel
-- light on an ellipsoid/pillow field, 6-tone yellow with violet-brown depth, a waxy pale bloom along the back,
-- soft broad specular + cream glint, a moulded wing (groove line + lit lip, two feather notches), AO where head and
-- hull meet, cool reflected light along the belly, ground shadow.
-- quirk: it wears a folded newspaper hat.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/../_helpers/_aA3_5.lua")
local HP, X, K = T.HP, T.X, T.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = T.new("ico-duck")
local Y  = { "#6e2c3e", "#b0582a", "#e0962a", "#f7c232", "#ffe066", "#fff4b0" }
local OR = { "#6a2236", "#a8382a", "#e0602a", "#fb8a34", "#ffb45a", "#ffd890" }
local PAP = { "#5a5670", "#8c8aa2", "#c4c0d0", "#e6e2ea", "#fff4d6" }
local tk = function(n) return { r = { name = n } } end
local CC = { 0.2, 0.36, 0.52, 0.7, 0.88 }

c:groundShadow(34, 52, 17, 1.6)

-- hull: long low ellipse with a flattened keel, upswept tail
local hull = c:ellipse(34, 42, 16, 8.5)
hull:add(T.rell(47.5, 36.5, 0.62, -0.78, 6.2, 3.2))
hull:cut(c:rect(0, 51, 63, 63))
local hn = T.blend(X.pillow(hull, 5), X.sphere(33, 39, 17, hull), 0.55)
-- head + neck
local head = c:ellipse(23.5, 26, 8.2, 8)
local neck = c:ellipse(25, 33, 6, 5)
local hm = head:copy():add(neck)
local hnn = T.blend(X.pillow(hm, 4), X.sphere(22.5, 25, 9, hm), 0.65)

local hb = {}
X.ao(hb, hull, hm, 1, -1)
-- waxy bloom: pale band along the upper back (raises the tone one step)
hull:each(function(x, y) local d = (y - 34) - (x - 34) ^ 2 / 48
  if d >= 0 and d < 2.2 and x > 28 and x < 46 then hb[K(x, y)] = (hb[K(x, y)] or 0) + 1 end end)
local bidx = T.shade(c, hull, hn, Y, { amb = 0.06, wrap = 0.25, bias = hb, tok = tk("hull"), cuts = CC })
-- moulded wing: groove on its outline, lit lip above, two feather notches at the back
local wing = T.rell(38, 41.5, 0.96, -0.28, 8.2, 4.4)
local wn = X.pillow(wing, 2.5)
local wb = {}
local widx = T.shade(c, wing, wn, Y, { amb = 0.1, wrap = 0.25, tok = tk("hull"), cuts = CC, bias = wb })
wing:edge():each(function(x, y) if x + y * 0.4 > 52 or y > 42 then c:put(x, y, Y[2]) else c:put(x, y, Y[3]) end end)
wing:edge():each(function(x, y) if not hull:has(x, y - 1) then return end
  if not wing:has(x, y - 1) and y < 41 then c:put(x, y - 1, Y[6]) end end)
for _, p in ipairs{ { 43, 40 }, { 44, 41 }, { 41, 42 }, { 42, 43 } } do c:put(p[1], p[2], Y[2]) end
-- cool bounce under the belly
local rim = X.rim(hn)
hull:edge():each(function(x, y) if rim[K(x, y)] > 0.55 and y > 46 then c:put(x, y, "#a85a6a") end end)
-- hull specular: broad soft streak on the back + one bright pair
for _, p in ipairs{ { 31, 36 }, { 32, 36 }, { 33, 35 }, { 34, 35 }, { 35, 35 } } do c:put(p[1], p[2], Y[6]) end

-- head on top
local hhb = {}
X.ao(hhb, hm, hull, 1, 0)
local hidx = T.shade(c, hm, hnn, Y, { amb = 0.06, wrap = 0.25, tok = tk("head"), cuts = CC })
-- dark seam where the neck sits into the hull
hm:each(function(x, y) if y > 33 and hull:has(x, y + 1) and not hm:has(x, y + 1) then c:put(x, y, Y[2]) end end)
hull:each(function(x, y) if hm:has(x, y - 1) and not hm:has(x, y) then c:put(x, y, Y[2]) end end)
-- head specular (rubber gloss): 2x2 hi + cream glint
T.map(c, { ".hh", "hss", "hs." }, 18, 20, { h = Y[6], s = "#fffbe0" }, tk("head"))
c:put(19, 21, T.CREAM)

-- beak: upper and lower mandible, dark mouth line, nostril
local up = T.rell(13.8, 28.4, 1, 0.12, 5.4, 2.3)
local upn = X.pillow(up, 2)
T.shade(c, up, upn, OR, { amb = 0.1, wrap = 0.3, tok = tk("beak"), cuts = CC })
local lo = T.rell(15, 31.2, 1, 0.1, 4.2, 1.5)
lo:cut(up)
T.shade(c, lo, X.pillow(lo, 1.5), OR, { amb = 0.03, wrap = 0.15, tok = tk("beakL"), cuts = CC })
for x = 11, 19 do if lo:has(x, 31) or lo:has(x, 30) then
  local y = lo:has(x, 30) and 30 or 31 c:put(x, y, OR[1]) end end
c:put(12, 27, OR[6]) c:put(13, 27, OR[6]) c:put(16, 27, OR[2])
-- AO under the beak root on the head
for _, p in ipairs{ { 19, 30 }, { 19, 31 }, { 20, 31 } } do if hm:has(p[1], p[2]) then c:put(p[1], p[2], Y[3]) end end

-- face
c:eyeSmall(21, 22)
c:cheek(24, 27)

-- quirk: folded newspaper hat, tilted back; folded brim band, a couple of printed lines
local hat = c:poly{ { 17, 19 }, { 25, 6 }, { 32, 20 } }
hat:cut(head:copy():shift(0, 1))
local hatN = {}
hat:each(function(x, y) hatN[K(x, y)] = { T.norm(x < 25 - (y - 6) * 0.05 and -0.5 or 0.45, -0.3, 0.8) } end)
T.shade(c, hat, hatN, PAP, { amb = 0.15, wrap = 0.3, tok = tk("hat"), cuts = { 0.25, 0.45, 0.65, 0.85 } })
local brim = c:poly{ { 16, 17 }, { 33, 18 }, { 33, 21 }, { 16, 20 } }
brim:cut(head:copy():shift(0, 2))
brim:each(function(x, y) local top = not brim:has(x, y - 1)
  c:put(x, y, top and PAP[5] or (x > 28 and PAP[3] or PAP[4]), tk("brim")) end)
-- printed type flecks on the hat
for _, p in ipairs{ { 22, 13 }, { 23, 13 }, { 21, 15 }, { 22, 15 }, { 24, 15 }, { 27, 14 }, { 28, 16 }, { 29, 16 } } do
  if hat:has(p[1], p[2]) then c:put(p[1], p[2], PAP[2]) end end
c:put(25, 7, PAP[5])
T.save(c, "ico-duck", "ico")
