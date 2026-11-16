-- mini-basalt-borer (81x49 still, side view, faces right). Opus third pass (richness).
-- Same creature as opus2 / the game picture: violet basalt grub, plates growing toward the head, two swept
-- horns, a darker head capsule with two eyes, a pale boring jaw, stubby claw legs, the ember crack (quirk).
-- Richness: every plate is a columnar basalt block with three facets (lit top, front, shaded right), a value
-- step between neighbouring plates, contact shade where plates overlap, vesicle pits and hairline fractures;
-- 6-tone hue-shifted ramps; a mauve bounce line under the plates; the ember crack now lights the rock around
-- it, with a spark rising out of it (look closer). Horns are thicker (opus2 weakness) and ringed.
local NAME = "mini-basalt-borer"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local Q = dofile(DIR .. "/_rich.lua").init(HP)
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
-- 6-tone ramps, dark -> light (cool indigo darks, warm lavender lights)
local ROCK = { "#221a44", "#30265f", "#433682", "#5d4ca6", "#7d69c6", "#ab97e4" }
local HEADR = { "#1d1739", "#2a2152", "#3a2d6c", "#4f3f8c", "#6b58b0", "#9580d0" }
local HORNR = { "#3d2f6c", "#5a479a", "#7a62bc", "#9d84da", "#c2acee", "#e8dcf6" }
local BOUNCE = "#7b5a9e"
local GLOW = { "#7a3f78", "#a24a6a" } -- basalt lit by the ember crack
local JAW = R("#f4e8d0", "#d4c4b4", "#a2949c", "#6c6278")
local LEG = R("#7a64b8", "#4e3e86", "#382c64", "#281f48")

local c = HP.canvas{ w = 81, h = 49, scale = 1, name = NAME }
c:groundShadow(40, 45, 36, 2.5)
for y = 0, c.h - 1 do for x = 0, c.w - 1 do local i = y * c.w + x
  if c.pix[i] and not c.pix[i - 1] and not c.pix[i + 1] then c.pix[i], c.own[i] = nil, nil end end end

-- stubby far legs (behind the plates)
for _, x in ipairs{ 33, 44, 54 } do
  c:part(c:poly{ { x, 38 }, { x + 4, 38 }, { x + 3, 43 }, { x + 5, 44 }, { x - 1, 44 } }, LEG, { band = 1, nopop = true })
end

-- basalt plates, tail to head; each overlaps the one behind it
local plates = {
  { 2, 31, 14, 43 }, { 10, 26, 24, 43 }, { 20, 22, 35, 42 }, { 31, 19, 47, 42 }, { 43, 18, 57, 41 },
}
local valueStep = { -1, 0, -1, 0, -1 } -- alternate plate value so neighbours separate
local masks = {}
for i, p in ipairs(plates) do masks[i] = c:rrect(p[1], p[2], p[3], p[4], 4) end
local tok = { r = { name = "rock" } }
for i, p in ipairs(plates) do
  local m = masks[i]
  local nxt = masks[i + 1]
  local near = nxt and nxt:grow(2) or HP.mask()
  local touch = nxt and nxt:grow(1) or HP.mask()
  local hgt, wid = p[4] - p[2], p[3] - p[1]
  local crease = p[1] + math.floor(wid * 0.55)
  local crease2 = p[1] + math.floor(wid * 0.22)
  local idx = {}
  m:each(function(x, y)
    local t
    if y <= p[2] + 2 then t = (x < p[1] + wid * 0.6) and 6 or 5          -- lit top facet
    elseif y == p[2] + 3 then t = 3                                          -- facet edge
    elseif y >= p[4] - math.floor(hgt * 0.32) then t = 2                     -- underside
    elseif x > crease then t = 3                                             -- shaded right column face
    else t = 4 end                                                           -- front column face
    if t >= 3 and t <= 4 and y > p[2] + 3 then t = t + valueStep[i] + 1 end  -- plate value step
    if x == crease and y > p[2] + 4 and y < p[4] - 1 then t = 2 end          -- column joint
    if x == crease2 and y > p[2] + 5 and y < p[4] - math.floor(hgt * 0.32) then t = math.max(2, t - 1) end
    if not m:has(x + 1, y) or not m:has(x + 1, y + 1) then t = math.min(t, 2) end -- cel shade edge, lower right
    if not m:has(x - 1, y) and y > p[2] + 3 and y < p[4] - 3 then t = math.max(t, 5) end -- rim light, left edge
    if near:has(x, y) then t = t - 1 end                                     -- contact shade under next plate
    if touch:has(x, y) then t = 1 end
    idx[#idx + 1] = { x, y, math.max(1, math.min(6, t)) }
  end)
  for _, q in ipairs(idx) do c:put(q[1], q[2], ROCK[q[3]], tok) end
  -- bounce line on the underside
  Q.side(m, 0, 1):each(function(x, y) if x > p[1] + 1 and x < p[3] - 1 and not (nxt and nxt:has(x, y)) then c:put(x, y, BOUNCE, tok) end end)
  -- vesicle pits: a dark hole with a lit lower-right lip
  m:each(function(x, y)
    if y > p[2] + 4 and y < p[4] - 4 and x > p[1] + 1 and x < crease - 1 and not near:has(x + 1, y)
      and Q.hash(x, y, i * 7) < 0.035 and c:get(x - 1, y - 1) ~= ROCK[1] and c:get(x - 1, y) ~= ROCK[1] and c:get(x, y - 1) ~= ROCK[1] and c:get(x - 2, y) ~= ROCK[1] then
      c:put(x, y, ROCK[1], tok) c:put(x + 1, y + 1, ROCK[5], tok)
    end
  end)
  -- hairline fracture across the front face
  local fx, fy = p[1] + 2 + (i * 3) % 4, p[2] + 6
  for k = 0, 1 do local xx, yy = fx + k, fy + k
    if m:has(xx, yy) and not near:has(xx, yy) and xx < crease then c:put(xx, yy, ROCK[2], tok) end end
  -- crystal stud on the top edge (3 tones and a glint)
  if i >= 2 then
    local sx = p[1] + 4
    local st = c:poly{ { sx, p[2] + 1 }, { sx + 2, p[2] - 3 }, { sx + 4, p[2] + 1 } }
    st:each(function(x, y) c:put(x, y, (x < sx + 2) and HORNR[5] or HORNR[3], { r = { name = "stud" .. i } }) end)
    c:put(sx + 2, p[2] - 2, HORNR[6]) c:put(sx + 3, p[2], HORNR[2])
  end
end

-- stubby near claw legs in front of the lower plates
for _, x in ipairs{ 24, 36, 48 } do
  local lg = c:poly{ { x, 40 }, { x + 3, 40 }, { x + 4, 43 }, { x + 7, 45 }, { x, 45 } }
  Q.body(c, lg, HEADR, { R = 1.5 })
  c:put(x + 1, 41, HEADR[6]) c:put(x + 5, 44, JAW.base) c:put(x + 6, 45, JAW.shade) c:put(x + 1, 45, JAW.shade)
end

-- ember crack glowing through two plates (quirk); the rock beside it catches the glow
local crack = c:line({ { 26, 25 }, { 28, 30 }, { 26, 34 }, { 29, 39 } }, 1):clip(masks[3])
local crack2 = c:line({ { 37, 26 }, { 39, 31 } }, 1):clip(masks[4])
crack:grow(1):cut(crack):clip(masks[3]):each(function(x, y) c:put(x, y, (x > 27 or y > 33) and GLOW[1] or GLOW[2]) end)
crack2:grow(1):cut(crack2):clip(masks[4]):cut(masks[5]):each(function(x, y) c:put(x, y, GLOW[1]) end)
c:fillMask(crack, P.ember.base)
c:put(28, 30, P.gold.hi) c:put(27, 31, P.gold.base) c:put(26, 34, P.ember.hi) c:put(27, 26, P.ember.hi)
c:fillMask(crack2, P.ember.shade) c:put(38, 28, P.ember.base)
-- a spark drifting up out of the crack
c:put(21, 16, P.gold.hi)

-- head capsule, its own darker shell, faceted like a cut stone
local hd = c:ellipse(64, 30, 12, 11)
hd:clip(c:rect(0, 0, 80, 42))
Q.body(c, hd, HEADR, { R = 6, amb = 0.12, bounce = BOUNCE, bounceMinX = 56,
  ao = { { masks[5], 2, -1 } },
  tex = function(x, y) return -1 end })
-- facet seams on the crown
c:fillMask(c:line({ { 59, 21 }, { 62, 24 }, { 66, 24 } }, 1):clip(hd), HEADR[3])
c:put(60, 22, HEADR[6]) c:put(61, 22, HEADR[6]) c:put(62, 23, HEADR[5]) c:put(59, 23, HEADR[5])
-- brow ridge with a lit upper lip
c:fillMask(c:line({ { 58, 26 }, { 74, 26 } }, 1):clip(hd), HEADR[1])
c:fillMask(c:line({ { 58, 25 }, { 70, 25 } }, 1):clip(hd), HEADR[5])

-- swept horns: thick ringed base, lit front edge, pale tip
local function horn(pts, chip)
  local m = c:line({ pts[1], pts[2] }, 6)
  m:add(c:line({ pts[2], pts[3] }, 4))
  m:add(c:line({ pts[3], pts[4] }, 2))
  m:clip(c:rect(0, 0, 80, pts[1][2]))
  local n = Q.X.pillow(m, 2)
  Q.body(c, m, HORNR, { normals = n, amb = 0.2,
    tex = function(x, y) if y <= pts[4][2] + 2 then return 1 end end })
  c:fillMask(c:line({ pts[1], pts[2], pts[3] }, 1):shift(-1, 0):clip(m), HORNR[6])
  for k = 1, 3 do local y = pts[1][2] - 3 * k
    m:each(function(x, yy) if yy == y and c:get(x, yy) ~= HORNR[6] then c:put(x, yy, HORNR[2]) end end)
    m:each(function(x, yy) if yy == y - 1 and c:get(x, yy) ~= HORNR[6] and Q.hash(x, yy, 3) < 0.5 then c:put(x, yy, HORNR[4]) end end)
  end
  if chip then c.pix[chip[2] * c.w + chip[1]], c.own[chip[2] * c.w + chip[1]] = nil, nil end
end
horn({ { 58, 22 }, { 56, 14 }, { 53, 8 }, { 50, 4 } })
horn({ { 68, 21 }, { 72, 13 }, { 76, 8 }, { 79, 6 } })
-- boring jaw: pale beak with a notch, a wear groove and a grit fleck
c:part(c:poly{ { 70, 31 }, { 77, 32 }, { 80, 36 }, { 76, 35 }, { 70, 35 } }, JAW, { band = 1, pop = { x = 72, y = 32 } })
c:part(c:poly{ { 70, 37 }, { 75, 37 }, { 78, 39 }, { 74, 41 }, { 70, 40 } }, JAW, { band = 1, nopop = true })
c:fillMask(c:line({ { 70, 36 }, { 76, 36 } }, 1), HEADR[1])
c:put(74, 33, JAW.shade) c:put(75, 34, JAW.shade) c:put(72, 39, JAW.shade)
c:put(73, 38, JAW.hi)
-- two eyes (3/4 view)
c:eyeSmall(63, 28)
c:eyeSmall(70, 28)
c:put(61, 33, P.petal.base) c:put(62, 33, P.petal.base)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
