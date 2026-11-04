-- ico-arrow-up (final pass, Opus). A sewn denim patch arrow pointing up.
-- Structure: plump triangular head stitched over a slim stem; one gold running stitch follows the hem 3 px in;
-- the stem tucks under the head with a fold, a soft crease runs down the head.
-- Material: quilted pillow (thick cloth puff), diagonal twill weave, gold thread with a lit top and a dark needle
-- hole after each dash, ambient shadow under the head's hem, cool bounce on the lower-right.
-- quirk: the stitch has come loose at the bottom corner and a gold thread dangles in a curl.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA0_4.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local D, TW = R.denim, R.twine
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new("ico-arrow-up")

local head = A.poly{ { 32, 7 }, { 57, 30.5 }, { 7, 30.5 } }
local stem = c:rrect(26, 26, 38, 56, 2)

local function twill(m, idx)
  m:shrink(1):each(function(x, y) if (x + y) % 3 == 0 and idx[K(x, y)] and idx[K(x, y)] >= 3 then
    A.step(c, idx, D, x, y, -1) end end)
end

-- stem
local sb = {}
X.ao(sb, stem, head, 3, -1)
local sIdx = A.face(c, stem, D, { R = 4, bias = sb, nfn = function(x, y, n) return n[1] + (x - 32) / 12, n[2], n[3] end })
twill(stem, sIdx)
-- small wrinkle near the bottom
for i = 0, 3 do A.step(c, sIdx, D, 29 + i, 50 - i, -1) A.step(c, sIdx, D, 29 + i, 49 - i, 1) end

-- head
local hIdx = A.face(c, head, D, { R = 5, nfn = function(x, y, n) return n[1] + (x - 32) / 60, n[2] + (y - 21) / 50, n[3] end })
twill(head, hIdx)
-- crease from the tip down the right-hand slope (fold), lit lip beside it
for i = 0, 9 do local x, y = 34 + floor(i * 0.7), 13 + i
  A.step(c, hIdx, D, x, y, -2) A.step(c, hIdx, D, x - 1, y, 1) end
-- hem: deep line on the head's lower edge over the stem, contact shadow
head:edge():each(function(x, y) if not head:has(x, y + 1) and stem:has(x, y + 1) then A.setI(c, hIdx, D, x, y, 2) end end)
for x = 26, 38 do A.setI(c, sIdx, D, x, 31, 1) end
-- cool bounce on the head's lower rim (right half)
for x = 36, 54 do if head:has(x, 29) then A.step(c, hIdx, D, x, 29, 1) end end

-- gold running stitch, 2 on 1 off, lit top + needle hole
local pts = { { 26, 27 }, { 15, 27 }, { 32, 11 }, { 49, 27 }, { 38, 27 } }
local function run(p, i)
  for s = 1, #p - 1 do
    local a, b = p[s], p[s + 1]
    local n = max(abs(b[1] - a[1]), abs(b[2] - a[2]), 1)
    for t = (s == 1 and 0 or 1), n do
      local x, y = floor(a[1] + (b[1] - a[1]) * t / n + 0.5), floor(a[2] + (b[2] - a[2]) * t / n + 0.5)
      local ph = i % 3
      if ph < 2 then c:put(x, y, (ph == 0) and TW[6] or TW[4]) else c:put(x, y, D[2]) end
      i = i + 1
    end
  end
  return i
end
run(pts, 0)
-- the stem stitch stops short at the bottom-right corner: it has come undone there
run({ { 29, 32 }, { 29, 53 }, { 33, 53 } }, 0)
run({ { 35, 32 }, { 35, 46 } }, 0)

-- quirk: loose thread dangling from the bottom-right corner in a curl
A.map(c, {
  "a....",
  ".b...",
  ".bb..",
  "..bc.",
  "...c.",
  "..cd.",
  ".dd..",
}, 35, 47, { a = TW[5], b = TW[4], c = TW[3], d = TW[2] })
-- the thread exits over the hem to hang outside the stem
A.map(c, {
  "aa..",
  ".bb.",
  "..c.",
  ".cc.",
  ".d..",
}, 38, 54, { a = TW[5], b = TW[4], c = TW[3], d = TW[2] })

A.save(c, "ico-arrow-up")
