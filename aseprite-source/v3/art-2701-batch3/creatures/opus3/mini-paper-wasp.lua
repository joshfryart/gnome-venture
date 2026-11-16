-- mini-paper-wasp (75x56 still, side view, faces right). Opus third pass (richness).
-- Same creature as opus2: gold wasp, ink-violet bands, papery tan wings, wasp waist, five jointed legs,
-- elbowed antennae with the red bow, brown mandibles.
-- Richness: glossy chitin lit per pixel from the upper-left (6-tone hue-shifted gold, bands lit with the same
-- light so they wrap the round abdomen), a hard specular on each body part, fine pits on the thorax, a cool
-- bounce line under the body; the wings are chewed paper with wavy fibre layers (like a paper nest) and
-- veins; legs have a lit femur, a joint and a dark hooked foot.
-- Quirk (look closer): the red bow, plus one bite nibbled out of the fore wing edge (the wasp chews its own
-- wing for nest paper).
local NAME = "mini-paper-wasp"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local Q = dofile(DIR .. "/_rich.lua").init(HP)
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local GOLD6 = { "#9a4e2a", "#d0782c", "#efa232", "#ffd45a", "#ffe78e", "#fff4c4" }
local BAND6 = { "#1f1838", "#2c2350", "#3a2e68", "#4a3c84", "#6656a8", "#8d7ccc" }
local PAPER6 = { "#6e4a3c", "#9a6a4a", "#b88660", "#d6aa7a", "#e8c79a", "#f6e2bc" }
local LEGN6 = { "#56301f", "#844a24", "#b06a2a", "#d58a34", "#eaa94a", "#f6cc78" }
local LEGF6 = { "#3e2422", "#4e2c24", "#5e3626", "#74442a", "#8e5630", "#a46a3a" }
local BOUNCE = "#c99a7a"
local BOW = P.ember

local c = HP.canvas{ w = 75, h = 56, scale = 1, name = NAME }
c:groundShadow(38, 51, 27, 2.5)
for y = 0, c.h - 1 do for x = 0, c.w - 1 do local i = y * c.w + x
  if c.pix[i] and not c.pix[i - 1] and not c.pix[i + 1] then c.pix[i], c.own[i] = nil, nil end end end

local function leg(pts, r6, w1)
  local f = c:line({ pts[1], pts[2] }, w1)
  local tok = { r = { name = "leg" } }
  f:each(function(x, y) c:put(x, y, (f:has(x, y - 1) and f:has(x - 1, y)) and r6[3] or r6[5], tok) end)
  local s = c:line({ pts[2], pts[3] }, 1)
  s:each(function(x, y) c:put(x, y, r6[4], tok) end)
  c:put(pts[2][1], pts[2][2], r6[6]) -- lit knee
  c:put(pts[2][1] + 1, pts[2][2] + 1, r6[2]) -- joint shadow
  c:fillMask(c:line({ pts[3], pts[4] }, 1), r6[2])
  c:put(pts[4][1], pts[4][2], r6[1])
end
-- far legs (behind the body)
leg({ { 43, 36 }, { 51, 41 }, { 55, 49 }, { 57, 49 } }, LEGF6, 2)
leg({ { 37, 37 }, { 31, 42 }, { 29, 49 }, { 27, 49 } }, LEGF6, 2)

-- papery wings: wavy fibre layers in alternating tan tones (paper-nest stripes), veins, lit edge
local function paper(m, ax, ay, shift, tok)
  m:each(function(x, y)
    local u = (x - ax) * 0.55 - (y - ay) * 0.85             -- distance along the wing
    local wav = math.sin((x + y) * 0.7) * 0.8
    local layer = math.floor((u + wav) / 2.2) % 3
    local t = ({ 4, 5, 3 })[layer + 1] + shift
    if not m:has(x + 1, y + 1) then t = t - 1 end            -- cel shade lower-right
    if not m:has(x - 1, y) or not m:has(x, y - 1) then t = t + 1 end -- lit rim
    c:put(x, y, PAPER6[math.max(1, math.min(6, t))], tok)
  end)
end
local hw = c:poly{ { 30, 27 }, { 13, 19 }, { 9, 14 }, { 14, 12 }, { 27, 18 }, { 36, 26 } }
local hwTok = { r = { name = "hw" } }
paper(hw, 33, 26, -1, hwTok)
local fw = c:poly{ { 33, 27 }, { 18, 12 }, { 17, 5 }, { 24, 2 }, { 30, 4 }, { 41, 24 } }
-- quirk: a bite chewed out of the fore wing's front edge
fw:cut(c:ellipse(31, 8, 1.6, 1.6))
local fwTok = { r = { name = "fw" } }
paper(fw, 38, 25, 0, fwTok)
-- separation line where the fore wing overlaps the hind wing
Q.side(fw, 0, 1):add(Q.side(fw, -1, 0)):each(function(x, y)
  if hw:has(x, y + 1) and not fw:has(x, y + 1) or hw:has(x - 1, y) and not fw:has(x - 1, y) then c:put(x, y, PAPER6[1], fwTok) end end)
-- veins: dark line with a lit pixel on its upper-left
local function vein(m, a, b, tok)
  local v = c:line({ a, b }, 1):clip(m:copy():shrink(1))
  v:each(function(x, y) c:put(x, y, PAPER6[2], tok) if m:has(x - 1, y) and not v:has(x - 1, y) then c:put(x - 1, y, PAPER6[6], tok) end end)
end
vein(fw, { 38, 25 }, { 22, 6 }, fwTok)
vein(fw, { 37, 24 }, { 28, 6 }, fwTok)
vein(hw, { 33, 26 }, { 14, 15 }, hwTok)
-- the chewed edge shows torn fibres
c:put(29, 9, PAPER6[2]) c:put(31, 10, PAPER6[2])

-- body parts lit per pixel; band pixels take the same light index on the violet ramp
local ab = c:ellipse(19.5, 34, 14, 8)
ab:add(c:poly{ { 8, 31 }, { 2, 39 }, { 9, 39 } })
local bands = HP.mask()
for _, b in ipairs{ { 11, 13 }, { 18, 20 }, { 25, 27 } } do
  bands:add(c:poly{ { b[1] + 1, 25 }, { b[2] + 2, 25 }, { b[2], 43 }, { b[1] - 1, 43 } }:clip(ab))
end
local function chitin(m, cx, cy, r, tok, bandM)
  local idx = Q.body(c, m, GOLD6, { sphere = { cx, cy, r }, amb = 0.34, wrap = 0.55, tok = tok, bounce = BOUNCE })
  if bandM then bandM:each(function(x, y) local i = idx[Q.X.K(x, y)] if i then c:put(x, y, BAND6[i], tok) end end) end
  -- one hard specular near the upper-left
  local best, bx, by
  m:each(function(x, y) local s = (x - cx) + (y - cy) * 1.3 if m:has(x - 1, y - 1) and m:has(x + 1, y + 1) and (not best or s < best) then best, bx, by = s, x, y end end)
  return idx
end
local abTok = { r = { name = "ab" } }
chitin(ab, 17, 31, 16, abTok, bands)
-- band edges: the leading edge of each band catches a thin lit line on top
bands:each(function(x, y) if not bands:has(x - 1, y) and ab:has(x - 1, y) and y < 31 then c:put(x - 1, y, GOLD6[6], abTok) end end)
c:put(14, 29, GOLD6[6]) c:put(15, 29, GOLD6[6]) c:put(13, 30, GOLD6[6]) -- abdomen specular
c:fillMask(c:line({ { 2, 39 }, { 5, 38 } }, 1), BAND6[1]) -- stinger tip
local pet = c:rect(33, 32, 35, 35)
c:fillMask(pet, GOLD6[3]) c:put(33, 32, GOLD6[5]) c:put(34, 32, GOLD6[4]) c:fillMask(c:rect(33, 35, 35, 35), GOLD6[2])
local th = c:ellipse(40, 32, 5.5, 6)
local thTok = { r = { name = "th" } }
chitin(th, 38, 30, 6.5, thTok)
-- thorax stripe (lit on its left), fine pits in the chitin
local st = c:line({ { 38, 27 }, { 37, 37 } }, 2):clip(th)
st:each(function(x, y) c:put(x, y, st:has(x - 1, y) and BAND6[2] or BAND6[4], thTok) end)
c:put(38, 28, BAND6[6])
for _, q in ipairs{ { 42, 29 }, { 43, 33 }, { 41, 35 }, { 44, 31 } } do c:put(q[1], q[2], GOLD6[3], thTok) end
c:put(41, 28, GOLD6[6]) c:put(42, 28, GOLD6[6])
local hd = c:ellipse(51.5, 31, 7, 6.5)
local hdTok = { r = { name = "hd" } }
chitin(hd, 49.5, 29, 7.5, hdTok)
c:put(47, 27, GOLD6[6]) c:put(48, 27, GOLD6[6]) c:put(47, 28, GOLD6[6])
-- inner lines between body parts
for _, pair in ipairs{ { th, hd }, { pet, th }, { ab, pet } } do
  Q.side(pair[2], -1, 0):each(function(x, y) if pair[1]:has(x - 1, y) then c:put(x, y, GOLD6[1]) end end)
end
-- mandibles (the mouth), brown with an ink gap
local MAND = R("#c98a52", "#8a5234", "#5e3428", "#3e2426")
c:paint({ "mmh.", "mmmm", "dmmd", ".d.m" }, 57, 34, { m = MAND.base, h = MAND.hi, d = MAND.shade })
c:put(58, 37, MAND.deep)
c:eyeSmall(53, 28)
c:put(52, 33, P.petal.base) c:put(53, 33, P.petal.base) -- cheek
-- near legs (in front of the body): front, mid, hind
leg({ { 45, 36 }, { 52, 41 }, { 54, 49 }, { 56, 49 } }, LEGN6, 2)
leg({ { 40, 37 }, { 41, 43 }, { 39, 49 }, { 41, 49 } }, LEGN6, 2)
leg({ { 35, 36 }, { 26, 41 }, { 22, 49 }, { 20, 49 } }, LEGN6, 2)

-- elbowed antennae (dark scape, lighter club tip); the near one wears the red bow
local function ant(pts)
  c:fillMask(c:line({ pts[1], pts[2] }, 1), GOLD6[1])
  c:fillMask(c:line({ pts[2], pts[3] }, 1), LEGF6[3])
  c:put(pts[2][1], pts[2][2], GOLD6[3])
  c:put(pts[3][1], pts[3][2], GOLD6[4])
end
ant{ { 48, 25 }, { 48, 15 }, { 52, 11 } }
ant{ { 52, 25 }, { 56, 15 }, { 62, 12 } }
c:paint({ "r..r", "rkkr", "r..r" }, 54, 14, { r = "ember.base", k = "ember.deep" })
c:put(54, 14, BOW.hi) c:put(57, 16, BOW.shade) c:put(54, 16, BOW.shade)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
