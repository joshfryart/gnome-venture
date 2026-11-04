-- pluot-jam (final pass, Opus). A slim glass jar of dark plum-red pluot jam with amber flesh chunks suspended in it,
-- a linen cloth cap (radial folds, gold hem stitch) tied on with twisted twine, and a small cream paper label
-- showing a pluot (purple skin, apricot-orange cut face). Material: glass = bright rim walls, pale headspace,
-- broken vertical specular streak, cool reflected light down the shade side, thick darker base; jam lit per pixel on a
-- 6-tone lathe; cloth folds; twine twist; label paper with a curled corner. Ground shadow (the jar stands).
-- History: Sonnet draft (dC35) replaced.
-- quirk: one sticky jam drip has escaped from under the cloth and runs down the shoulder, ending in a bead.
local NAME = "pluot-jam"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local JAM   = { "#2a0c22", "#4a1434", "#701e40", "#982a48", "#c23e50", "#e46a62" }
local CHUNK = { "#a2401e", "#d0692a", "#f09a3e", "#ffc870" }
local GLASS = { "#5a6a8a", "#8aa6be", "#bcd8e2", "#e2f2f2" }
local CLOTH = { "#5e3e36", "#8a6450", "#b48c6c", "#d6b48c", "#ecd2a8", "#fff0cc" }
local TWINE = { "#5e3a22", "#8c5a30", "#c08848", "#e8b870" }
local PAPER = { "#a89070", "#d8c6a0", "#f2e6c4", "#fff4d6" }
local PLUOT = { "#35204e", "#5a3480", "#8a54b0" }
local INK = A.INK

local cx = 32
c:groundShadow(32, 55, 13, 2)

-- jar body: slim, rounded shoulders, 22 px wide
local function bodyR(y)
  if y < 22 then return 7.5 + (y - 19) * 1.2 end
  if y < 25 then return 10.5 + (y - 22) * 0.17 end
  if y > 51 then return 11 - (y - 51) * 0.9 end
  return 11
end
local body = HP.mask()
for y = 19, 54 do local r = bodyR(y)
  for x = floor(cx - r), floor(cx + r - 0.01) do if x + 0.5 >= cx - r and x + 0.5 <= cx + r then body:set(x, y) end end end
-- neck + thread band (under the cloth)
local neck = c:rect(25, 15, 38, 19)
local bn = A.lathe(body, cx, function(y) return bodyR(y) end, 2, 0.35)
local tok = { r = { name = "jam" } }
local jamTop = 27
local jam = body:copy()
jam:each(function(x, y) if y < jamTop then jam.s[K(x, y)] = nil end end)
local jidx = A.shade(c, jam, bn, JAM, { amb = 0.05, wrap = 0.2, tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
-- meniscus: a lighter row on the jam top, darker under it
for x = 22, 41 do if jam:has(x, jamTop) then A.step(c, jidx, JAM, x, jamTop, 1, tok) end
  if jam:has(x, jamTop + 1) then A.step(c, jidx, JAM, x, jamTop + 1, -1, tok) end end
-- amber flesh chunks suspended in the jam
local chunks = { { 26, 31, 2 }, { 35, 29, 1 }, { 30, 47, 2 }, { 38, 44, 1 }, { 24, 41, 1 }, { 36, 36, 1 } }
for _, q in ipairs(chunks) do
  local x, y, s = q[1], q[2], q[3]
  local side = x > cx + 3 and -1 or 0
  c:put(x, y, CHUNK[3 + side], tok) c:put(x + 1, y, CHUNK[2 + side + 1], tok)
  if s > 1 then c:put(x, y + 1, CHUNK[2 + side], tok) c:put(x + 1, y + 1, CHUNK[1], tok) c:put(x, y - 1, CHUNK[4 + side], tok) end
end
-- headspace glass (empty glass above the jam)
local gtok = { r = { name = "glass" } }
body:each(function(x, y) if y < jamTop then
  local u = (x + 0.5 - cx) / bodyR(y)
  c:put(x, y, u < -0.45 and GLASS[4] or (u > 0.55 and GLASS[2] or GLASS[3]), gtok) end end)
-- glass walls: bright left rim, cool right rim, thick base
body:edge():each(function(x, y)
  if y >= jamTop and y < 52 then
    if x < cx then c:put(x, y, GLASS[3], gtok) else c:put(x, y, GLASS[1], gtok) end
  end end)
for x = 21, 43 do for y = 51, 54 do if body:has(x, y) then
  local u = (x + 0.5 - cx) / 11
  c:put(x, y, (y == 51) and JAM[1] or (u < -0.4 and GLASS[3] or (u > 0.4 and GLASS[1] or GLASS[2])), gtok) end end end
-- cool reflected light one px in from the shade wall
for y = 28, 49 do local r = bodyR(y) local x = floor(cx + r - 2) if jam:has(x, y) then c:put(x, y, "#5a3a72", tok) end end
-- specular streak (broken), plus a short second line
for y = 23, 47 do if not (y >= 33 and y <= 35) and not (y > 41 and y < 44) then c:put(24, y, GLASS[4], gtok) end end
for y = 29, 33 do c:put(25, y, "#f6c0b8", gtok) end
c:put(24, 33, GLASS[4], gtok)

-- label: cream paper, 13x10, with a pluot, lower-right corner curled
local ltok = { r = { name = "label" } }
local lab = c:rect(27, 34, 39, 43)
lab:each(function(x, y)
  local col = PAPER[3]
  if x == 27 or y == 34 then col = PAPER[4] end
  if x == 39 or y == 43 then col = PAPER[2] end
  c:put(x, y, col, ltok) end)
-- curl
c:put(39, 43, JAM[2], tok) c:put(38, 43, PAPER[1], ltok) c:put(39, 42, PAPER[1], ltok) c:put(38, 42, PAPER[4], ltok)
-- pluot on the label: round purple fruit, half cut face apricot, leaf
local pl = { "..gg.", ".ppaa", "ppPao", "ppPoo", ".pPo." }
local map = { p = PLUOT[2], P = PLUOT[1], a = CHUNK[4], o = CHUNK[3], g = "#6ab455" }
for j, row in ipairs(pl) do for i = 1, #row do local ch = row:sub(i, i)
  if map[ch] then c:put(30 + i, 35 + j, map[ch], ltok) end end end
c:put(31, 37, PLUOT[3], ltok)
-- two ruled lines under the drawing
for x = 29, 36 do c:put(x, 42, x % 3 == 2 and PAPER[3] or PAPER[2], ltok) end

-- cloth cap: dome over the lid, frilled skirt to y 21
local ctok = { r = { name = "cloth" } }
local cap = HP.mask()
cap:add(c:ellipse(31.5, 13, 9, 4))
for y = 13, 20 do
  local r = 9 + (y - 13) * 0.55
  for x = floor(cx - r), floor(cx + r - 0.01) do cap:set(x, y) end
end
-- scalloped hem
for x = 18, 46 do local d = (x - 19) % 4
  if d == 0 then cap.s[K(x, 20)] = nil end
  if d == 3 then cap:set(x, 21) end
end
cap:each(function(x, y) if x < 19 or x > 44 then cap.s[K(x, y)] = nil end end)
local cn = A.lathe(cap, cx, function(y) return y < 13 and 9 or 9 + (y - 13) * 0.55 end, 2, 0.5)
local cidx = A.shade(c, cap, cn, CLOTH, { amb = 0.08, wrap = 0.25, tok = ctok })
-- radial folds below the twine
for _, fx in ipairs{ -6, -2, 3, 7 } do
  for y = 18, 21 do local x = floor(cx + fx * (1 + (y - 18) * 0.12))
    if cap:has(x, y) then A.step(c, cidx, CLOTH, x, y, -1, ctok) end
    if cap:has(x - 1, y) and fx < 0 then A.step(c, cidx, CLOTH, x - 1, y, 1, ctok) end end
end
-- dome folds
for _, q in ipairs{ { 27, 10 }, { 27, 11 }, { 36, 10 }, { 37, 11 } } do if cap:has(q[1], q[2]) then A.step(c, cidx, CLOTH, q[1], q[2], -1, ctok) end end
-- gold hem stitch (2 on 1 off) one row above the scallops
do local n = 0 for x = 20, 44 do n = n + 1 if n % 3 ~= 0 and cap:has(x, 19) then c:put(x, 19, "#f5b82e", ctok) end end end
-- AO under the cloth on the glass
for x = 20, 44 do for y = 20, 22 do if body:has(x, y) and not cap:has(x, y) and cap:has(x, y - 1) then c:put(x, y, GLASS[1], gtok) end end end

-- twisted twine around the neck, bow knot on the left
local ttok = { r = { name = "twine" } }
for x = 21, 42 do
  local y = 16
  local u = (x + 0.5 - cx) / 11
  local i = ((x % 3) == 0) and 4 or (((x % 3) == 1) and 3 or 2)
  if u > 0.5 then i = i - 1 end
  c:put(x, y, TWINE[max(1, i)], ttok)
  c:put(x, y + 1, TWINE[max(1, i - 1 - ((x % 3 == 2) and 1 or 0))], ttok)
end
-- knot + two tails
for _, p in ipairs{ { 20, 16, 3 }, { 20, 17, 2 }, { 19, 18, 3 }, { 19, 19, 2 }, { 18, 20, 3 }, { 18, 21, 2 },
  { 21, 18, 3 }, { 21, 19, 2 }, { 21, 20, 1 }, { 19, 15, 4 }, { 18, 14, 3 } } do c:put(p[1], p[2], TWINE[p[3]], ttok) end

-- quirk: a drip escaped from the cloth, down the right shoulder, ending in a bead with a glint
local dtok = { r = { name = "drip" } }
for _, p in ipairs{ { 38, 21, 3 }, { 38, 22, 4 }, { 39, 22, 3 }, { 38, 23, 4 }, { 38, 24, 3 } } do c:put(p[1], p[2], JAM[p[3]], dtok) end
c:put(37, 25, JAM[5], dtok) c:put(38, 25, JAM[4], dtok) c:put(37, 26, JAM[3], dtok) c:put(38, 26, JAM[2], dtok)
c:put(37, 23, JAM[6], dtok)

A.save(c, "ph", NAME)
