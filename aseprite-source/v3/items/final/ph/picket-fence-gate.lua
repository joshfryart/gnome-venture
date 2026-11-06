-- picket-fence-gate (final, Opus single pass). Front view of a garden gate between two tall square posts with ball
-- finials: five white-painted pickets whose tips follow an arch, natural-wood ledgers and a Z brace nailed on the
-- front, black iron strap hinges with rivets on the left, a brass thumb latch on the right.
-- Material: bevelled grained boards, chipped paint, iron bevel + bright edge, brass specular, contact shadow under the
-- brace and ledgers, AO at the post feet, sphere-lit finials. Ground shadow.
-- quirk: a tiny brass bell hangs from the latch on a red string.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, abs = math.floor, math.sqrt, math.abs
local c = A.new("picket-fence-gate")
local P, W, I, B = A.PAINT, A.WOOD, A.IRON, A.BRASS

c:groundShadow(31, 52, 25, 2)

-- posts
local function post(x0, seed)
  local pm = c:rect(x0, 12, x0 + 4, 52)
  A.board(c, pm, W, { R = 1.8, dir = "v", seed = seed, name = "post", knot = { x0 + 2, 40 } })
  local cm = c:rect(x0 - 1, 10, x0 + 5, 11)
  A.cast(c, cm, 1, 1, -1)
  A.board(c, cm, W, { R = 1, grain = false, name = "cap" })
  c:put(x0 - 1, 10, W[6]) c:put(x0 - 1, 11, W[5])
  -- neck + ball finial
  local nm = c:rect(x0 + 1, 8, x0 + 3, 9)
  A.board(c, nm, W, { R = 1, grain = false })
  local bm, bn = A.oval(x0 + 2, 5, 2.4, 2.4, 0)
  local tok = { r = { name = "finial" } }
  local idx = A.toneN(c, bm, bn, W, { tok = tok, cuts = A.CUTS, amb = 0.08, wrap = 0.2 })
  A.reg(idx, W, tok)
  c:put(x0 + 1, 4, A.CREAM)
  for x = x0, x0 + 4 do A.step(c, x, 52, -1) A.step(c, x, 51, -1) end
end
post(8, 2) post(50, 6)

-- pickets with arched tips
local xs = { 15, 22, 29, 36, 43 }
for i, x in ipairs(xs) do
  local cx = x + 1.5
  local d = (cx - 30.5) / 14
  local top = floor(15 + 7 * d * d + 0.5)
  local m = HP.mask()
  m:set(x + 1, top) m:set(x + 2, top)
  for y = top + 1, 49 do for xx = x, x + 3 do m:set(xx, y) end end
  A.cast(c, m, 1, 1, -1)
  A.board(c, m, P, { R = 1.4, dir = "v", seed = i * 5, dens = 0.22, name = "picket" })
end
-- ledgers and Z brace on the front (natural wood)
local L1, L2 = c:rect(14, 24, 47, 26), c:rect(14, 43, 47, 45)
local br = c:line({ { 17, 42 }, { 44, 27 } }, 3)
br:cut(L1):cut(L2)
A.cast(c, br, 1, 1, -1) A.cast(c, br, 1, 2, -1)
A.board(c, br, W, { R = 1.2, dir = "h", seed = 4, name = "brace", dens = 0.3 })
for i, L in ipairs{ L1, L2 } do
  A.cast(c, L, 0, 1, -2) A.cast(c, L, 1, 2, -1)
  A.board(c, L, W, { R = 1.2, dir = "h", seed = 10 + i, name = "ledger" })
  c:put(14, L == L1 and 24 or 43, W[6]) c:put(14, L == L1 and 25 or 44, W[5]) -- paler end grain
end
-- AO where brace butts the ledgers
for x = 17, 44 do
  if A.idxAt(x, 27) and br:has(x, 27) then A.step(c, x, 27, -1) end
  if A.idxAt(x, 42) and br:has(x, 42) then A.step(c, x, 42, -1) end
end
-- nail heads
for _, x in ipairs{ 15, 22, 29, 36, 43 } do c:put(x + 1, 25, I[2]) c:put(x + 1, 44, I[2]) end

-- iron strap hinges (left), knuckle on the post
local tokI = { r = { name = "iron" } }
for _, hy in ipairs{ 24, 43 } do
  local hm = c:rect(10, hy, 21, hy + 2)
  hm:cut(c:rect(20, hy, 21, hy)):cut(c:rect(20, hy + 2, 21, hy + 2))
  A.cast(c, hm, 1, 1, -1)
  local idx = A.toneN(c, hm, A.X.pillow(hm, 1.2), I, { tok = tokI, cuts = A.CUTS, amb = 0.15, wrap = 0.35 })
  A.reg(idx, I, tokI)
  for x = 10, 21 do if hm:has(x, hy) then c:put(x, hy, I[5], tokI) end end
  c:put(12, hy, I[6], tokI) c:put(13, hy, I[6], tokI)
  -- knuckle
  local km = c:rect(10, hy - 1, 11, hy + 3)
  local kidx = A.toneN(c, km, A.X.pillow(km, 1), I, { tok = tokI, cuts = A.CUTS })
  A.reg(kidx, I, tokI)
  c:put(10, hy - 1, I[5], tokI)
  -- rivets
  for _, rx in ipairs{ 15, 19 } do c:put(rx, hy + 1, I[1], tokI) c:put(rx - 1, hy + 1, I[5], tokI) end
end

-- brass thumb latch (right): bar across the gap onto the post, keeper on the post
local tokB = { r = { name = "brass" } }
local lm = c:rect(43, 33, 53, 34)
A.cast(c, lm, 1, 1, -1)
local lidx = A.toneN(c, lm, A.X.pillow(lm, 1), B, { tok = tokB, cuts = A.CUTS })
A.reg(lidx, B, tokB)
for x = 43, 53 do c:put(x, 33, B[5], tokB) end
c:put(45, 33, B[6], tokB)
local km = c:rect(52, 31, 54, 36)
km:cut(c:rect(53, 33, 53, 34))
local kidx = A.toneN(c, km, A.X.pillow(km, 1), B, { tok = tokB, cuts = A.CUTS })
A.reg(kidx, B, tokB)
c:put(53, 33, B[2], tokB) c:put(53, 34, B[1], tokB)
-- thumb plate + ring
A.map(c, { ".bb.", "bBHb", "bBBb", ".bb." }, 42, 29, { b = B[2], B = B[4], H = B[6] }, tokB)

-- chipped paint
for _, p in ipairs{ { 30, 20 }, { 31, 20 }, { 31, 21 }, { 23, 36 }, { 24, 36 }, { 44, 39 } } do c:put(p[1], p[2], W[4]) end
c:put(30, 21, W[3])
c:put(30, 17, A.CREAM)

-- quirk: tiny brass bell on a red string under the latch bar
A.map(c, {
  "r....",
  "r....",
  "r....",
  "obo..",
  "bBHb.",
  "bBBdb",
  "dddd.",
  ".k...",
}, 48, 35, { r = "#c13a3a", o = B[3], b = B[3], B = B[5], H = B[6], d = B[2], k = B[1] }, tokB)
A.save(c, "picket-fence-gate")
