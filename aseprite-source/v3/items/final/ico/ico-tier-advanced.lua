-- ico-tier-advanced (Opus single pass). Tier 2 of the puzzle-piece set (easy = 1 piece, advanced = 2, expert = 3):
-- a gold piece and a teal piece clicked together side by side, each with a knob on top; the gold knob locks into
-- the teal piece's socket.
-- Material: die-cut card. Printed glossy top face (pillow bevel, 6 tones, crisp lit/dark cut lip, specular),
-- 3 px side wall showing a thin printed lip over pale-to-dark card stock, deep seam + AO where the pieces meet,
-- contact shadow from the locked knob.
-- quirk: one corner of the teal piece is dog-eared, its printed skin folded back to show the pale card.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_aR0_2.lua")
local HP, X, K = D.HP, D.X, D.K
local c = D.new("ico-tier-advanced")
local A, B, CD = D.GOLD, D.TEAL, D.CARD

-- top faces
local knobA = c:ellipse(19, 17, 5, 5)
local lockA = c:ellipse(36, 35, 4.5, 4.5):add(c:rect(30, 33, 33, 37))
local pa = c:rect(8, 22, 31, 49):add(knobA):add(c:rect(17, 20, 21, 23)):add(lockA)
local knobB = c:ellipse(44, 17, 5, 5)
local pb = c:rect(32, 22, 55, 49):add(knobB):add(c:rect(42, 20, 46, 23)):cut(lockA)
-- dog-ear: the corner beyond the fold line x - y = 29 is folded over onto the face
local ear = HP.mask()
pb:each(function(x, y) if x - y >= 30 and y <= 25 and y >= 22 and x >= 51 then ear:set(x, y) end end)
pb:cut(ear)
-- side wall: 3 px below the faces
local top = pa:copy():add(pb)
local wall = HP.mask()
for d = 1, 3 do top:shift(0, d):each(function(x, y) if not top:has(x, y) then wall:set(x, y) end end) end
wall:each(function(x, y)
  local d = 0
  for j = 1, 3 do if top:has(x, y - j) then d = j break end end
  local R = pa:has(x, y - d) and A or B
  local lit = x < 32
  if d == 1 then c:put(x, y, R[2])
  elseif d == 2 then c:put(x, y, lit and CD[4] or CD[3])
  else c:put(x, y, lit and CD[2] or CD[1]) end
end)

-- faces
D.lit(c, pa, A, { R = 3 })
local bbm = {}
X.ao(bbm, pb, pa, 2, -1)
D.lit(c, pb, B, { R = 3, bias = bbm })
-- crisp die-cut lip: lit top/left edge, dark bottom/right edge
for _, pr in ipairs{ { pa, A }, { pb, B } } do
  local m, R = pr[1], pr[2]
  m:edge():each(function(x, y)
    if not m:has(x, y - 1) or not m:has(x - 1, y) then c:put(x, y, R[5])
    elseif not m:has(x, y + 1) or not m:has(x + 1, y) then c:put(x, y, R[2]) end
  end)
end
-- seam on the teal side + contact shadow from the locked gold knob
D.seam(c, pb, pa, B[1])
lockA:shift(1, 1):each(function(x, y) if pb:has(x, y) and not lockA:has(x, y) then c:put(x, y, B[1]) end end)
pa:each(function(x, y) if pb:has(x + 1, y) and not lockA:has(x, y) then c:put(x, y, A[2]) end end)

-- speculars (glossy print) + bright knob caps
D.put(c, { {11, 25}, {12, 25}, {11, 26} }, A[6]) c:put(11, 25, D.CREAM)
D.put(c, { {16, 15}, {17, 14} }, A[6])
D.put(c, { {36, 25}, {37, 25} }, B[6]) c:put(41, 14, B[6]) c:put(42, 13, B[6])

-- quirk: dog-eared corner: the printed skin folds back on the teal piece, showing the pale card back
ear:each(function(x, y) local fx, fy = y + 29, x - 29
  c:put(fx + 1, fy + 1, B[1]) end)                       -- shadow under the flap
ear:each(function(x, y) c:put(y + 29, x - 29, CD[5]) end)
for i = 0, 4 do c:put(51 + i, 22 + i, CD[4]) end          -- fold crease
c:put(51, 26, CD[3]) c:put(52, 26, CD[4])
D.save(c)
