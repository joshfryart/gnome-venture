-- trail-pack: Trail Pack, common cut a (Opus richness pass opus3, built on opus2). 64x64 Hearth Pop.
-- Same item as the game base: an oat canvas rucksack with a striped red bedroll strapped on top,
-- a leather carry loop, a flap with a leather strap and brass buckle, two side pockets, a sprig
-- of lavender tucked in at the top right.
-- Redraw: canvas weave lit per pixel (6-tone oat, cool deep), a shaped flap with a turned hem and a
-- contact shadow on the body, pocket seams with a canvas-tone running stitch, a bedroll that is a
-- real cylinder with a spiral end and cream wrap ties, a grained leather strap, a bevelled buckle.
-- quirk: a blue enamel camp mug hangs by its handle from the right pocket.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/_w.lua")
local HP, X, K = W.HP, W.X, W.K
local c = W.new("trail-pack")

local CAN = { "#463a34", "#6a5a48", "#8a7a60", "#a8987a", "#c4b694", "#ddd1ae" }
local ROLL = { "#561c2a", "#862a34", "#b4423a", "#d65e3e", "#ee844e", "#ffac74" }
local TIE = { "#6e5848", "#a08a70", "#c8b090", "#e2cca8", "#f2e2c0", "#fff4d6" }
local LEA = { "#3a2020", "#5e3428", "#80492c", "#a0603a", "#c07e4c", "#dca066" }
local GOLD = W.GOLD
local ENAM = { "#1e2c58", "#2c4a8e", "#3c6ab8", "#5a90d8", "#8ab8ee", "#c8e4ff" }

-- canvas weave: a calm plain-weave grid (2 px over/under), lightly slubbed; quieter than opus2
local function weave(b, m, seed)
  m:each(function(x, y)
    local h = X.hash(x, y, seed)
    if (x % 4 == 0 and y % 4 == 0) or (x % 4 == 2 and y % 4 == 2) then W.addBias(b, x, y, -1) end
    if h > 0.95 then W.addBias(b, x, y, 1) end
  end)
end

-- ===== side pockets (behind the body)
local pockets = {}
for i, p in ipairs{ { 10, 37, 17, 57, 1 }, { 46, 38, 53, 57, -1 } } do
  local m = c:rrect(p[1], p[2], p[3], p[4], 2)
  local n = W.mixN(W.vcylN(m, p[1], p[3]), X.pillow(m, 2), 0.6)
  local b = {}
  weave(b, m, 3 + i)
  m:each(function(x, y) if y == p[2] + 2 then W.addBias(b, x, y, -1) end if y == p[2] + 1 then W.addBias(b, x, y, 1) end end)
  if i == 2 then m:each(function(x, y) W.addBias(b, x, y, -1) end) end
  W.lit(c, m, n, CAN, { bias = b })
  pockets[i] = m
end

-- ===== body
local body = c:poly{ { 15, 22 }, { 48, 22 }, { 48, 54 }, { 46, 58 }, { 42, 60 }, { 21, 60 }, { 17, 58 }, { 15, 54 } }
local bn = W.mixN(W.vcylN(body, 15, 48), X.pillow(body, 4), 0.55)
local bb = {}
weave(bb, body, 9)
-- bottom panel seam and a scuffed base
body:each(function(x, y) if y == 56 then W.addBias(bb, x, y, -1) end if y >= 57 then W.addBias(bb, x, y, -1) end end)
W.lit(c, body, bn, CAN, { bias = bb })
for _, m in ipairs(pockets) do W.sep(c, m, body, CAN[2]) end
-- running stitch on the pocket seams (canvas thread, not gold)
for y = 40, 55, 2 do c:put(16, y, CAN[6]) c:put(47, y + 1, CAN[5]) end

-- ===== flap: shaped with a point, turned hem, casts a shadow on the body
local flap = c:poly{ { 15, 22 }, { 48, 22 }, { 48, 37 }, { 43, 42 }, { 20, 42 }, { 15, 37 } }
flap:shift(1, 2):cut(flap):clip(body):each(function(x, y) W.step(c, x, y, CAN, -2) end)
local fn = W.mixN(W.vcylN(flap, 15, 48, -0.2), X.pillow(flap, 3), 0.5)
local fb = {}
weave(fb, flap, 13)
flap:each(function(x, y)
  if not flap:has(x, y + 1) or not flap:has(x, y + 2) then W.addBias(fb, x, y, -1) end   -- turned hem
  if not flap:has(x, y + 3) and flap:has(x, y + 2) then W.addBias(fb, x, y, 1) end       -- hem fold catches light
end)
W.lit(c, flap, fn, CAN, { bias = fb })
-- hem stitch
flap:each(function(x, y) if not flap:has(x, y + 3) and flap:has(x, y + 2) and x % 3 == 0 then c:put(x, y, CAN[6]) end end)
-- a worn, paler rub on the lit corner of the flap
for _, p in ipairs{ { 19, 26 }, { 20, 26 }, { 19, 27 }, { 21, 25 } } do c:put(p[1], p[2], CAN[6]) end

-- ===== strap and buckle
local strap = c:rect(30, 31, 33, 52)
local sb = {}
strap:each(function(x, y) if (y * 3 + x) % 7 == 0 then W.addBias(sb, x, y, -1) end end)
W.lit(c, strap, W.vcylN(strap, 30, 33), LEA, { bias = sb })
strap:shift(1, 0):cut(strap):each(function(x, y) W.step(c, x, y, CAN, -2) end)
for x = 30, 33 do c:put(x, 52, LEA[2]) end
c:put(31, 51, LEA[1]) c:put(32, 51, LEA[1])   -- the punched hole at the strap end
W.paint(c, 27, 42, {
  "abbbbbbbc",
  "bd.ee.ddc",
  "bd.ee.ddc",
  "bd.ee.ddc",
  "cddddddde",
  ".eeeeeee.",
}, { a = GOLD[6], b = GOLD[5], c = GOLD[3], d = GOLD[4], e = GOLD[2] })
for y = 43, 45 do c:put(29, y, LEA[2]) c:put(32, y, LEA[3]) end   -- strap seen through the frame
c:put(28, 43, GOLD[6])

-- ===== bedroll: horizontal cylinder with ties, spiral end on the left
local roll = c:rrect(14, 11, 51, 22, 3)
local rn = W.hcylN(roll, 11, 22, -0.25)
local ties = HP.mask()
for _, x in ipairs{ 21, 22, 40, 41 } do ties:add(c:rect(x, 11, x, 22)) end
local stripes = HP.mask()
for _, x in ipairs{ 28, 29, 47, 48 } do stripes:add(c:rect(x, 11, x, 22)) end
local cloth = roll:copy():cut(ties)
local rb = {}
cloth:each(function(x, y) if stripes:has(x, y) then W.addBias(rb, x, y, 0) end if (x + y) % 6 == 0 then W.addBias(rb, x, y, -1) end end)
W.lit(c, cloth:copy():cut(stripes), rn, ROLL, { bias = rb })
W.lit(c, stripes, rn, TIE, { bias = {} })
for _, x in ipairs{ 28, 47 } do for y = 11, 22 do W.step(c, x, y, TIE, -1) end end
-- ties are cord: pinch the roll (darker either side), twist marks
local tb = {}
ties:each(function(x, y) if (x + y) % 2 == 0 then W.addBias(tb, x, y, -1) end end)
W.lit(c, ties, rn, LEA, { bias = tb })
for _, x in ipairs{ 20, 23, 39, 42 } do for y = 12, 21 do W.step(c, x, y, ROLL, -1) end end
-- contact shadow of the roll on the flap
roll:shift(0, 1):cut(roll):each(function(x, y) W.step(c, x, y, CAN, -2) end)
-- spiral end cap
local cap = W.oval(13, 16.5, 4, 6, 0)
cap:cut(c:rect(15, 0, 20, 30)):add(c:rect(14, 12, 14, 21))
local capB = {}
W.lit(c, cap, X.pillow(cap, 2), ROLL, { bias = capB, amb = 0.15 })
W.paint(c, 10, 13, {
  ".ccc.",
  "c...c",
  "c.c.c",
  "c.cc.",
  "c....",
  ".ccc.",
}, { c = ROLL[1] })
c:put(11, 12, ROLL[6]) c:put(10, 14, ROLL[5])

-- ===== carry loop (leather) on top
local loop = W.tube({ { 28, 12 }, { 28, 6 }, { 37, 6 }, { 37, 12 } }, function() return 1.1 end)
loop:cut(roll)
W.lit(c, loop, X.pillow(loop, 1), LEA, { amb = 0.15 })

-- ===== lavender sprig tucked behind the roll, top right
for y = 6, 11 do c:put(48 - (y < 8 and 1 or 0), y, (y % 2 == 0) and "#3f9150" or "#2c6a46") end
c:put(49, 9, "#7cc35a") c:put(50, 8, "#7cc35a")
W.paint(c, 45, 2, {
  ".a.",
  "bab",
  "cbc",
  "bcb",
  ".c.",
}, { a = "#d8c4f6", b = "#a688e0", c = "#6e54b4" })

-- ===== quirk: a blue enamel mug hanging by its handle off the right pocket
local mug = c:rect(50, 46, 55, 52)
W.lit(c, mug, W.vcylN(mug, 50, 55), ENAM, { amb = 0.12 })
for x = 50, 55 do c:put(x, 46, "#e8eef4") end            -- rolled white enamel rim (off-white)
for x = 51, 54 do c:put(x, 47, ENAM[2]) end              -- inside the mug
c:put(51, 50, "#e8eef4") c:put(53, 52, ENAM[1])          -- a chip in the enamel shows the dark iron
W.paint(c, 49, 42, { ".aaa.", "a...b", "a...b", "c...." }, { a = "#c8d0dc", b = "#6e7488", c = "#9aa0b4" })   -- wire handle hooked over the pocket top   -- wire handle hooked over the pocket top
c:put(51, 49, ENAM[6])
W.rimb(c, body, CAN, { rimMax = 6 })
W.rimb(c, roll, ROLL, { rimMax = 6 })
W.shift(c, 0, 1)
W.save(c, "trail-pack")
