-- ico-arrow-left (final pass, Opus). A pressed enamel-on-steel sign arrow pointing left.
-- Structure: broad triangular head laid over a slim rounded-end shaft; an embossed groove runs 3 px inside the
-- rim of both parts like a stamped plate; a steel rivet with a dark hole near the tail.
-- Material: domed pillow bevel (enamel over pressed metal), bright lit bevel upper-left, specular streak along the
-- head's upper edge, deep separation + contact shadow where the head overlaps the shaft, cool bounce lower-right.
-- quirk: a tiny green inchworm loops up out of the rivet hole.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA0_4.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local E, ST, W = R.enamel, R.steel, R.worm
local max, min = math.max, math.min
local c = A.new("ico-arrow-left")

local head = A.poly{ { 6, 32.5 }, { 30, 8.5 }, { 30, 56.5 } }
local shaft = c:rrect(27, 26, 55, 38, 3)

-- groove + lip: groove pixels drop 2 tones, the pixel outside them (toward the rim) lifts 1 on lit sides
local function emboss(m, idx, avoid)
  local g = m:shrink(3):edge()
  local inner = m:shrink(4)
  g:each(function(x, y) if not (avoid and avoid:has(x, y)) then A.step(c, idx, E, x, y, -2) end end)
  g:each(function(x, y)
    if avoid and avoid:has(x, y) then return end
    for _, d in ipairs{ { 0, -1 }, { -1, 0 } } do
      local ux, uy = x + d[1], y + d[2]
      if m:has(ux, uy) and not g:has(ux, uy) and not inner:has(ux, uy) then A.step(c, idx, E, ux, uy, 1) end
    end
  end)
end

-- shaft: domed tube, AO near the head
local sb = {}
X.ao(sb, shaft, head, 2, -1)
local sIdx = A.face(c, shaft, E, { R = 4, bias = sb, nfn = function(x, y, n)
  return n[1], n[2] + (y - 32) / 10, n[3] end })
emboss(shaft, sIdx, head:grow(2))

-- head: pillow + dome tilt about its centroid
local hIdx = A.face(c, head, E, { R = 4, nfn = function(x, y, n)
  return n[1] + (x - 22) / 34, n[2] + (y - 32.5) / 30, n[3] end })
emboss(head, hIdx)
-- deep separation where the head's back edge sits on the shaft
head:edge():each(function(x, y) if shaft:has(x + 1, y) and not head:has(x + 1, y) then A.setI(c, hIdx, E, x, y, 2) end end)
-- contact shadow of the head on the shaft
head:shift(1, 1):each(function(x, y) if shaft:has(x, y) and not head:has(x, y) then A.setI(c, sIdx, E, x, y, 2) end end)

-- specular streak just inside the head's upper edge (x + y = const)
for i = 0, 7 do local x, y = 12 + i, 31 - i
  if head:has(x, y) then c:put(x, y, (i >= 2 and i <= 4) and A.CREAM or E[6]) end end
-- spec dash on the shaft top lip
for x = 35, 39 do c:put(x, 27, x == 36 and A.CREAM or E[6]) end
-- cool bounce on the head's lower-right rim
head:edge():each(function(x, y) if not head:has(x, y + 1) and x > 15 and x < 28 then A.step(c, hIdx, E, x, y - 1, 1) end end)

-- steel rivet near the tail: bevelled ring with a dark hole
A.map(c, {
  ".abb.",
  "abccd",
  "bcffd",
  "bcffd",
  ".dde.",
}, 47, 30, { a = ST[6], b = ST[5], c = ST[4], d = ST[3], e = ST[2], f = A.INK })

-- quirk: inchworm looping up out of the hole, head peering left
A.map(c, {
  "...abb..",
  "..ab.cc.",
  ".ec..cd.",
  "ee...cd.",
  "e....cd.",
  "......d.",
  ".....dd.",
}, 44, 25, { a = W[6], b = W[5], c = W[4], d = W[3], e = W[5] })
c:put(49, 31, W[2]) c:put(50, 31, W[3])
c:put(45, 28, A.INK)                       -- eye
c:put(51, 28, W[2]) c:put(50, 29, W[2])  -- segment creases

A.save(c, "ico-arrow-left")
