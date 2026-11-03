-- ico-wizard (final pass, Opus single pass). Bold icon: a wizard's head and shoulders-free bust. A tall, slim
-- crooked felt hat whose tip bends over to the right, a wide brim with a gold band, a kindly face in the brim's
-- shadow (2x3 pill eyes, bushy brows, a round lit nose with a dark underside), curling moustache and a long
-- tapering beard. Material: per-pixel cone light on the hat (6-tone dusk, felt fold creases), contact shadow of
-- the brim on the brow, AO where the beard meets the face, beard strands (wavy darker lines, lit tips),
-- two little gold stars stitched on the hat.
-- quirk: the beard ends in a braid tied with a red ribbon bow.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/../_helpers/_aR1_1.lua")
local HP, X, K = T.HP, T.X, T.K
local floor, max, min, sqrt, abs, sin, cos, pi = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin, math.cos, math.pi
local c = T.new("ico-wizard")
local HAT   = { "#2a1f4e", "#3d2d73", "#5a439e", "#7a60c4", "#a187e0", "#cbb8f4" }
local SKIN  = { "#7a4036", "#b06a52", "#d99474", "#f0b98d", "#ffd6ad", "#ffe9cc" }
local NOSE  = { "#7a3a34", "#b8604e", "#e48c72", "#ffb28e", "#ffd2b4" }
local BEARD = { "#5e5a78", "#8a879e", "#b4b2c4", "#d8d6e2", "#efebf2", "#fff4d6" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local RED   = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }

-- face first (brim, beard paint over)
local ftok = { r = { name = "face" } }
local face = HP.ellipse(32, 35, 7.6, 6.4)
face:add(HP.ellipse(24.3, 35, 1.6, 2.2)):add(HP.ellipse(39.7, 35, 1.6, 2.2)) -- ears
local fbias = {}
face:each(function(x, y) if y <= 29 then fbias[K(x, y)] = -2 elseif y == 30 then fbias[K(x, y)] = -1 end end) -- brim shadow
local fn = T.blend(X.pillow(face, 3), X.sphere(32, 35, 7.5, face), 0.5)
local fidx = T.shade(c, face, fn, SKIN, { amb = 0.12, wrap = 0.3, bias = fbias, tok = ftok })
-- ear inner shade
c:put(24, 35, SKIN[2], ftok) c:put(40, 35, SKIN[2], ftok)

-- beard: long tapering wedge from the cheeks to a braid
local btok = { r = { name = "beard" } }
local beard = HP.poly{ { 23.5, 36 }, { 26, 35 }, { 38, 35 }, { 40.5, 36 }, { 40, 41 }, { 37, 46 }, { 34, 50 }, { 32, 51 }, { 30, 50 }, { 27, 46 }, { 24, 41 } }
beard:add(HP.ellipse(32, 42, 7.6, 5))
beard:cut(HP.ellipse(32, 36.2, 3.6, 2.6)) -- mouth/cheek window (skin shows above the moustache)
local bn = T.blend(X.pillow(beard, 3.5), X.sphere(32, 41, 10, beard), 0.45)
local bbias = {}
-- AO where the beard meets the face (top rows)
beard:each(function(x, y) if y <= 37 then bbias[K(x, y)] = -1 end end)
local bidx = T.shade(c, beard, bn, BEARD, { amb = 0.1, wrap = 0.28, bias = bbias, tok = btok })
-- wavy strand lines down the beard
beard:each(function(x, y) local k = K(x, y)
  if y > 40 then
    local u = x + 0.5 - 32 - sin((y) * 0.55) * 0.8
    local ph = (u + (y - 40) * (u / 14)) % 4
    if ph < 0.9 and abs(u) < 7 then T.step(c, bidx, BEARD, x, y, -1, btok) end
  end
end)

-- moustache: two curling lobes under the nose
local mtok = { r = { name = "tache" } }
local tache = HP.ellipse(28.5, 38.4, 4.2, 1.7):add(HP.ellipse(35.5, 38.4, 4.2, 1.7))
tache:add(HP.rect(23, 37, 24, 37)):add(HP.rect(40, 37, 41, 37)) -- upturned tips
local tn = X.pillow(tache, 1.6)
local tidx = T.shade(c, tache, tn, BEARD, { amb = 0.18, wrap = 0.3, tok = mtok, cuts = { 0.16, 0.3, 0.46, 0.62, 0.8 } })
c:put(32, 38, BEARD[2], mtok) c:put(32, 39, BEARD[2], mtok) -- parting
-- contact shadow under the moustache on the beard
for x = 25, 39 do local y = 40 if beard:has(x, y) and not tache:has(x, y) then T.step(c, bidx, BEARD, x, y, -2, btok) end end

-- nose: round, warmer, lit tip, dark underside, nostril shadow
local ntok = { r = { name = "nose" } }
local nose = HP.ellipse(32, 35.4, 2.3, 2.0)
local nn = X.sphere(32, 35.4, 2.3, nose)
T.shade(c, nose, nn, NOSE, { amb = 0.18, wrap = 0.35, tok = ntok, cuts = { 0.18, 0.4, 0.62, 0.84 } })
c:put(31, 34, NOSE[5], ntok)
c:put(31, 37, NOSE[1], ntok) c:put(33, 37, NOSE[1], ntok) c:put(32, 37, NOSE[2], ntok)

-- eyes (2x3 pill, glint) + bushy brows
c:eyeSmall(27, 32) c:eyeSmall(35, 32)
local brow = { r = { name = "brow" } }
for _, bx in ipairs{ 25, 34 } do
  c:put(bx, 31, BEARD[4], brow) c:put(bx + 1, 31, BEARD[5], brow) c:put(bx + 2, 31, BEARD[6], brow)
  c:put(bx + 3, 31, BEARD[5], brow) c:put(bx + 4, 31, BEARD[4], brow)
end
c:put(25, 32, BEARD[3], brow) c:put(38, 32, BEARD[3], brow) -- shaggy ends dip
-- cheeks
c:put(26, 35, "#f08a8a") c:put(27, 35, "#f08a8a") c:put(37, 35, "#f08a8a") c:put(38, 35, "#f08a8a")

-- hat cone: crooked, tip bends right and droops
local htok = { r = { name = "hat" } }
local P = { { 32, 24 }, { 30.5, 14 }, { 37, 4.5 }, { 48, 7 } }
local function bz(t) return T.bez(P, t) end
local cone, hn, HT, HS = T.sweep(bz, function(t)
  if t > 0.985 then return 1.4 end
  return 1.4 + 8.6 * (1 - t) ^ 1.25
end, 260)
cone:cut(HP.rect(0, 25, 63, 63))
local hbias = {}
-- felt creases: two folds where the cone bends
cone:each(function(x, y) local k = K(x, y)
  local t, s = HT[k], HS[k]
  if abs(t - 0.52 - s * 0.05) < 0.018 and s > -0.6 then hbias[k] = -2 end
  if abs(t - 0.66 + s * 0.04) < 0.016 and s > -0.4 then hbias[k] = -2 end
  if t > 0.5 and t < 0.535 and s < -0.2 then hbias[k] = (hbias[k] or 0) + 1 end
end)
local hidx = T.shade(c, cone, hn, HAT, { amb = 0.04, wrap = 0.15, bias = hbias, tok = htok, cuts = { 0.24, 0.42, 0.6, 0.78, 0.93 } })

-- gold band (cloth, 3 rows) with a dark row above (AO) and a buckle-less wrap
local gtok = { r = { name = "band" } }
for y = 20, 22 do for x = 0, 63 do
  if cone:has(x, y) then
    local k = K(x, y)
    local i = hidx[k] or 3
    local g = (i >= 5) and 4 or (i >= 3 and 3 or 2)
    if y == 22 then g = max(1, g - 1) end
    c:put(x, y, GOLD[g], gtok)
  end
end end
for x = 0, 63 do if cone:has(x, 19) then T.step(c, hidx, HAT, x, 19, -1, htok) end end

-- brim: wide flat ellipse, lit top, dark underside front edge
local brim = HP.ellipse(32, 25.2, 17.5, 3.2)
local brn = {}
brim:each(function(x, y)
  local dy = (y + 0.5 - 25.7) / 3.7
  local dx = (x + 0.5 - 32.5) / 18
  brn[K(x, y)] = { T.norm(dx * 0.5, dy * 0.9 - 0.25, 0.8) }
end)
local brtok = { r = { name = "brim" } }
local bridx = T.shade(c, brim, brn, HAT, { amb = 0.04, wrap = 0.15, tok = brtok, cuts = { 0.24, 0.42, 0.6, 0.78, 0.93 } })
-- crown seam: a dark row where the cone stands on the brim
for x = 0, 63 do if cone:has(x, 22) and brim:has(x, 23) then c:put(x, 23, HAT[2], brtok) end end
-- front lip highlight
for x = 20, 30 do if brim:has(x, 27) and not brim:has(x, 29) then c:put(x, 26, HAT[5], brtok) end end

-- gold stars on the hat (5 px plus with a lit core)
local stok = { r = { name = "star" } }
local function star(x, y)
  c:put(x, y - 1, GOLD[3], stok) c:put(x - 1, y, GOLD[3], stok) c:put(x, y, GOLD[4], stok)
  c:put(x + 1, y, GOLD[2], stok) c:put(x, y + 1, GOLD[2], stok)
end
star(28, 15) star(35, 10)

-- quirk: braid at the beard tip tied with a red ribbon bow
local qtok = { r = { name = "braid" } }
T.map(c, {
  "..ab..",
  "rRRrRr",
  ".rdRr.",
  "rRr.rr",
  "..bc..",
  "..cb..",
  "...c..",
}, 30, 49, { a = BEARD[3], b = BEARD[3], c = BEARD[5], r = RED[2], R = RED[3], d = RED[1] }, qtok)
c:put(31, 50, RED[4], qtok)

c:sparkle(51, 13)
T.save(c, "ico-wizard")
