-- hat-rootwarden (final, Opus single pass). Low round felt dome (no point) on a wide flat brim; slim gnarled roots
-- hang from the brim's underside; a two-leaf sprout grows out of the crown. Woven straw band.
-- Material: per-pixel dome light (6-tone earthy felt), felt nap, pinched dent crease on top; straw band with
-- diagonal over-under weave; roots as lit tubes with twist marks and root hairs, AO where they leave the brim;
-- sprout leaves with midrib + veins, dark base where stem meets felt; brim bevel, AO ring and cast shadow.
-- quirk: a pink earthworm peeks out from under the brim among the roots.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_1.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, max, min, abs, floor = math.sqrt, math.max, math.min, math.abs, math.floor
local c = A.new("hat-rootwarden")
local FELT  = { "#2a1718", "#43261f", "#623a2a", "#835437", "#a6744d", "#cf9e6c" }
local STRAW = { "#5a3418", "#8f5a1f", "#c0832a", "#e0a83a", "#f4cd62", "#ffe9a0" }
local ROOT  = { "#2a1a17", "#4a2f24", "#6e4836", "#94694e", "#b98d6a", "#ddb790" }
local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }

-- roots first (brim paints over their tops)
local rtok = { r = { name = "root" } }
local roots = {
  { { 15, 43 }, { 11, 48 }, { 16, 51 }, { 12, 56 }, 1.4 },
  { { 23, 45 }, { 25, 50 }, { 19, 53 }, { 21, 58 }, 1.7 },
  { { 33, 46 }, { 36, 51 }, { 31, 54 }, { 34, 58 }, 1.6 },
  { { 43, 45 }, { 42, 50 }, { 48, 52 }, { 46, 57 }, 1.5 },
  { { 50, 44 }, { 54, 47 }, { 51, 50 }, { 54, 53 }, 1.2 },
}
for ri, r in ipairs(roots) do
  local w0 = r[5]
  local m, n, T, S, samp = A.tube({ r[1], r[2], r[3], r[4] }, function(t) return w0 * (1 - t) ^ 0.7 + 0.45 end)
  local bias = {}
  m:each(function(x, y) if y <= r[1][2] + 3 then bias[K(x, y)] = -1 end end)
  local idx = A.shade(c, m, n, ROOT, { bias = bias, tok = rtok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
  -- twist marks
  local L = A.tubeLen(samp)
  m:each(function(x, y) local k = K(x, y)
    local d = (T[k] * L + S[k] * 1.6) % 3.2
    if d < 0.7 and T[k] > 0.12 and T[k] < 0.85 then A.step(c, idx, ROOT, x, y, -1, rtok) end end)
  -- a root hair off one side
  local s = samp[floor(0.55 * #samp)]
  local side = (ri % 2 == 0) and 1 or -1
  local hx, hy = floor(s.x + side * (s.w + 1.2) + 0.5), floor(s.y + 0.5)
  c:put(hx, hy, ROOT[3], rtok) c:put(hx + side, hy + 1, ROOT[3], rtok)
end

-- dome crown mask
local CX, BY, RW, RY = 32, 38, 12, 2.6
local dm = HP.mask()
local DCY, DRX, DRY = 37, 12.4, 14
for y = 20, 42 do for x = 18, 46 do
  local u, v = (x - CX) / (DRX + 0.45), (y - DCY) / (DRY + 0.45)
  if u*u + v*v <= 1 then dm:set(x, y) end end end
A.arcClip(dm, CX, BY, RW + 0.6, RY)
local dn = {}
dm:each(function(x, y)
  local u, v = (x - CX) / (DRX + 0.8), (y - DCY) / (DRY + 0.8)
  dn[K(x, y)] = { A.norm(u, v, sqrt(max(0.03, 1 - u*u - v*v))) } end)

-- brim
local bias = {}
local tmp = HP.mask()
for y = 30, 50 do for x = 6, 58 do
  local u, v = (x - 32) / 22.45, (y - 41) / 5.95
  if u*u + v*v <= 1 then tmp:set(x, y) end end end
X.ao(bias, tmp, dm, 2, -1)
A.cast(bias, tmp, dm, 3, 2, -1)
local top, under, bidx, btok = A.brim(c, 32, 41, 22, 5.5, 2, FELT, { bias = bias, R = 3 })
A.felt(c, top, bidx, FELT, btok, 11, 0.05)
-- dark undersides where roots leave the brim
for _, r in ipairs(roots) do for dx = -1, 1 do
  local x = floor(r[1][1] + 0.5) + dx
  for y = 40, 52 do if under:has(x, y) and not under:has(x, y + 1) then c:put(x, y + 1, ROOT[1], rtok) end end
end end

-- dome paint
local ctok = { r = { name = "crown" } }
local cidx = A.shade(c, dm, dn, FELT, { tok = ctok })
A.felt(c, dm, cidx, FELT, ctok, 5, 0.07)
-- pinched dent: a short curved crease on the crown, lit lip on its upper-left
for _, p in ipairs{ { 27, 28 }, { 28, 27 }, { 29, 27 }, { 30, 26 }, { 31, 26 } } do
  A.step(c, cidx, FELT, p[1], p[2], -2, ctok)
  A.step(c, cidx, FELT, p[1], p[2] - 1, 1, ctok)
end
c:put(25, 27, FELT[6], ctok) c:put(26, 26, FELT[6], ctok)

-- quirk: earthworm rising out of the brim
A.map(c, {
  ".WW.",
  "wPKp",
  "wPpw",
  ".wp.",
  ".wP.",
  "wwpw",
}, 47, 36, { W = "#ffc4d8", w = "#a83a6e", P = "#f5809f", p = "#d8608c", K = "#2b1c26" })
c:put(46, 42, FELT[1], btok) c:put(51, 42, FELT[1], btok)
-- straw band (weave)
local bm = A.bandMask(dm, CX, BY, RW + 0.6, RY, 5)
local stok = { r = { name = "band" } }
local sidx = A.shade(c, bm, dn, STRAW, { tok = stok, bias = {} })
bm:each(function(x, y)
  local a = A.arcY(x, CX, BY, RW + 0.6, RY)
  local row = floor(a - y + 0.5)
  if row >= 5 then A.step(c, sidx, STRAW, x, y, -2, stok)
  elseif (x + (row < 2 and 0 or 2)) % 4 < 2 then A.step(c, sidx, STRAW, x, y, -1, stok)
  elseif (x + y) % 4 == 0 then A.step(c, sidx, STRAW, x, y, 1, stok) end
end)

-- sprout: stem + two leaves
local ltok = { r = { name = "leaf" } }
local sm, sn = A.tube({ { 33, 25 }, { 33, 21 }, { 32, 18 }, { 34, 14 } }, function(t) return 1.1 - 0.3 * t end)
A.shade(c, sm, sn, { LEAF[2], LEAF[3], LEAF[4], LEAF[5], LEAF[5], LEAF[6] }, { tok = ltok })
local function leaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, len = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.98 then return -1 end return max(0.4, w * math.sin(math.pi * min(1, t * 0.95 + 0.05)) ^ 0.7) end, { fold = 0.45 })
  local idx = A.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.18 and T[k] > 0.05 and T[k] < 0.88 then c:put(x, y, LEAF[max(2, (idx[k] or 3) - 1)], ltok)
    elseif abs(S[k]) > 0.35 and abs(S[k]) < 0.8 and ((T[k] * len - abs(S[k]) * w) % 3) < 0.8 then c:put(x, y, LEAF[min(6, (idx[k] or 3) + 1)], ltok) end
  end)
  return m
end
leaf(33, 16, 27, 11, 22, 14, 3.0)
leaf(34, 15, 39, 9, 44, 11, 2.8)
c:put(33, 25, FELT[1], ctok) c:put(34, 25, FELT[1], ctok)   -- dark socket where the stem meets felt
c:put(24, 13, LEAF[6], ltok)
A.save(c, "hat-rootwarden")
