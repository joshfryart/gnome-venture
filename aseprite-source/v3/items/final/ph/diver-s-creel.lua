-- diver-s-creel (final, Opus single pass). A lidded wicker fish creel: tapered body in brick basket weave
-- (lit top row per weaver, shade row, dark gap at each stake), domed lid with a twisted cane binding round the rim
-- and a dark fish-feeding hole, slim leather shoulder strap with a brass buckle and riveted tabs, wooden toggle latch
-- on a leather loop, ambient row under the lid overhang, ground shadow.
-- quirk: a little orange starfish has hitched a ride on the lower corner.
local NAME = "diver-s-creel"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi, sqrt = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi, math.sqrt
local c = A.new(NAME)

local WICK = { "#5a3420", "#7e4c28", "#a86e34", "#c8924a", "#e2b468", "#f6d896" }
local LEA  = { "#3a1e1a", "#5a2e22", "#7e4430", "#a2603c", "#c4844e", "#e0aa70" }
local BRASS = { "#6a4a1c", "#a8782a", "#e0b040", "#fff0a8" }
local WOOD = { "#4a2a1e", "#6e4028", "#965a34", "#b97a4a", "#d89c64", "#f0c48c" }
local STAR = { "#7a2a2a", "#b0402e", "#e0642e", "#f58c3c", "#ffb860", "#ffe0a0" }

c:groundShadow(32, 54, 15, 1.5)

-- strap (behind everything)
local strok = { r = { name = "strap" } }
local sp = { { 18, 30 }, { 15, 3 }, { 49, 3 }, { 46, 30 } }
local sm, sn, ST, SS = A.tube(sp, function() return 1.25 end)
local sidx = A.shade(c, sm, sn, LEA, { tok = strok, amb = 0.12, wrap = 0.3 })
sm:each(function(x, y) local k = K(x, y) if abs(SS[k]) < 0.2 and (floor(ST[k] * 60) % 3 == 0) then A.step(c, sidx, LEA, x, y, -1, strok) end end)
-- buckle on the left run of the strap
do
  local bx, by = A.bez(sp, 0.18) bx, by = floor(bx + .5), floor(by + .5)
  local btok = { r = { name = "buckle" } }
  for y = by - 2, by + 2 do for x = bx - 2, bx + 2 do
    local e = (x == bx - 2 or x == bx + 2 or y == by - 2 or y == by + 2)
    if e then c:put(x, y, (x + y < bx + by) and BRASS[4] or ((x == bx + 2 or y == by + 2) and BRASS[1] or BRASS[3]), btok) end
  end end
  c:put(bx, by, BRASS[2], btok) c:put(bx, by - 1, BRASS[2], btok)
end

-- body: tapered box, rounded bottom corners
local function bw(y)
  if y >= 53 then return 9.5 elseif y == 52 then return 11.2 elseif y == 51 then return 12.0 end
  return 14.2 - (y - 27) * 0.06
end
local bm, bn, BU = A.rev(32, 27, 53, bw)
local btok = { r = { name = "body" } }
local bias = {}
for x = 16, 48 do bias[K(x, 28)] = -2 bias[K(x, 29)] = -1 end      -- ambient under the lid overhang
local bidx = A.shade(c, bm, bn, WICK, { tok = btok, bias = bias, amb = 0.1, wrap = 0.35 })
bm:each(function(x, y)
  if y < 29 or y > 52 then return end
  local b = (y - 29) // 3
  local r = (y - 29) % 3
  local cx = (x - 17 + (b % 2) * 2) % 4
  local d = 0
  if r == 0 then d = 1 elseif r == 2 then d = -1 end
  if cx == 3 then d = -2 elseif cx == 0 and r == 0 then d = 2 end
  A.step(c, bidx, WICK, x, y, d, btok)
end)

-- strap tabs + rivets
for _, s in ipairs{ { 18, -1 }, { 46, 1 } } do
  local x0 = s[1]
  for y = 29, 33 do for x = x0 - 1, x0 + 1 do c:put(x, y, LEA[(x == x0 - 1) and 5 or (x == x0 + 1 and 2 or 4)], strok) end end
  c:put(x0, 31, BRASS[4], strok) c:put(x0, 32, BRASS[2], strok)
  c:put(x0 - 1, 34, LEA[2], strok) c:put(x0, 34, LEA[2], strok) c:put(x0 + 1, 34, LEA[1], strok)
end

-- lid: domed top, overhanging rim with twisted cane binding
local ltok = { r = { name = "lid" } }
local function lw(y) if y == 19 then return 11.5 elseif y == 20 then return 13.6 end return 15.3 end
local lm, ln = A.rev(32, 19, 27, lw)
for k, n in pairs(ln) do local y = k // 1024 - 256 ln[k] = { A.norm(n[1] * 0.8, (y < 24) and -0.55 or 0.1, n[3]) } end
local lidx = A.shade(c, lm, ln, WICK, { tok = ltok, amb = 0.12, wrap = 0.35 })
lm:each(function(x, y)
  if y >= 24 then   -- binding: diagonal twist
    local q = (x + y * 2) % 4
    A.step(c, lidx, WICK, x, y, q == 0 and -2 or (q == 1 and 1 or 0), ltok)
    if y == 27 then A.step(c, lidx, WICK, x, y, -1, ltok) end
  elseif y >= 20 then -- top weave, finer, radiating stakes
    if (x - 32) % 3 == 0 then A.step(c, lidx, WICK, x, y, -1, ltok) elseif y % 2 == 0 then A.step(c, lidx, WICK, x, y, 1, ltok) end
  end
end)
for x = 22, 40 do c:put(x, 19, x < 30 and WICK[6] or WICK[5], ltok) end
-- feeding hole (left of centre) with a lit lower lip
local htok = { r = { name = "hole" } }
for x = 24, 30 do c:put(x, 21, "#3a2420", htok) c:put(x, 22, "#3a2420", htok) end
c:put(25, 21, "#4a3028", htok)
for x = 24, 30 do c:put(x, 23, WICK[6], ltok) end
for x = 25, 29 do c:put(x, 20, WICK[2], ltok) end

-- toggle latch: leather loop + wooden peg
local ttok = { r = { name = "latch" } }
for y = 25, 31 do c:put(36, y, LEA[4], ttok) c:put(37, y, LEA[3], ttok) c:put(38, y, LEA[2], ttok) end
local pm = c:rrect(33, 31, 41, 32, 1)
local pidx = A.shade(c, pm, X.pillow(pm, 1.5), WOOD, { tok = ttok, amb = 0.15, wrap = 0.3 })
c:put(34, 31, WOOD[6], ttok) c:put(35, 31, A.CREAM, ttok)
for x = 34, 41 do if bm:has(x, 33) then A.step(c, bidx, WICK, x, 33, -2, btok) end end

-- quirk: starfish clinging to the lower right
local stk = { r = { name = "starfish" } }
local cx, cy = 42, 45
local pts = {}
for i = 0, 9 do
  local a = -pi / 2 + i * pi / 5 + 0.25
  local r = (i % 2 == 0) and 6.2 or 2.4
  pts[#pts + 1] = { cx + cos(a) * r, cy + sin(a) * r }
end
local fm = c:poly(pts)
local fn = X.pillow(fm, 2)
local fidx = A.shade(c, fm, fn, STAR, { tok = stk, amb = 0.12, wrap = 0.3 })
fm:each(function(x, y) if X.hash(x, y, 21) > 0.72 then A.step(c, fidx, STAR, x, y, 1, stk) end end)
c:put(cx - 1, cy - 1, STAR[6], stk) c:put(cx, cy - 1, A.CREAM, stk)
-- contact shadow of the starfish on the weave
fm:shift(1, 1):each(function(x, y) if bm:has(x, y) and not fm:has(x, y) then A.step(c, bidx, WICK, x, y, -2, btok) end end)

A.save(c, NAME)
