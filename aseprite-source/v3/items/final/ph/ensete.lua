-- ensete (final, Opus single pass). An enset stem (the "false banana" pseudostem, the part that is eaten): a slim
-- length of pseudostem lying on the diagonal, cut clean at the lower-left end to show the concentric rings of packed leaf
-- sheaths, maroon outer sheath peeling over a pale green inner one, long fibre lines and waxy bloom. At the top it opens
-- into a rolled young leaf and one broad paddle leaf with a red midrib, parallel side veins and a natural tear.
-- Per-pixel tube light (6-tone green + 6-tone maroon), AO where leaf and rolled leaf leave the stem.
-- quirk: two pale fibres are already peeling off the cut end and curl down.
local NAME = "ensete"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local STEM = { "#2b4734", "#3e6542", "#5a874d", "#83aa5e", "#b2cd7e", "#dbe8a8" }
local RED  = { "#3a1828", "#5a1f33", "#80283c", "#a83a45", "#cb5f55", "#e8907a" }
local LEAF = { "#173a3a", "#1f5446", "#2c714d", "#459052", "#6eb05c", "#a3cf78" }
local FACE = { "#f4ecc6", "#dfe0a6", "#c2cf88", "#a5bd70" }
local FIB = { "#efe2b2", "#c9bb8a" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- paddle leaf (drawn first, stem overlaps its base)
local ltok = A.tok("leaf")
local lm, ln, LT, LS, llen = A.blade(31, 29, 36, 16, 50, 12, function(t)
  if t < 0.14 then return 1.1 end
  local u = (t - 0.14) / 0.86
  local w = 5.0 * min(1, u / 0.22) ^ 0.6
  if u > 0.86 then w = w * sqrt(max(0, (1 - u) / 0.14)) end
  return u > 0.995 and -1 or max(1.1, w)
end, { fold = 0.3 })
-- a natural tear between two veins on the outer half
lm:each(function(x, y) local k = K(x, y)
  local d = LT[k] * llen - LS[k] * 3.0
  if LS[k] > 0.35 and abs(d - 21.5) < 0.5 then lm.s[k] = nil end end)
-- rolled young leaf (cigar)
local rtok = A.tok("roll")
local rm, rn = A.tube({ { 31, 30 }, { 31, 24 }, { 29, 19 }, { 27, 15 } }, function(t) return 1.5 * (1 - t) + 0.6 end)
-- stem
local stok, redtok = A.tok("stem"), A.tok("sheath")
local SP = { { 17, 53 }, { 21, 45 }, { 26, 37 }, { 31, 29 } }
local sm, sn, ST, SS, samp = A.tube(SP, function(t) return 4.7 - 1.1 * t end)
rm:cut(sm) lm:cut(sm) lm:cut(rm)

local lb = {}
X.ao(lb, lm, sm, 2, -1) X.ao(lb, lm, rm, 1, -1)
A.toneN(c, lm, ln, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3, bias = lb })
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  if lb[k] then return end
  if abs(s) < 0.13 and t > 0.1 then c:put(x, y, s <= 0 and RED[5] or RED[3], ltok) return end
  if t < 0.15 then c:put(x, y, s <= 0 and STEM[4] or STEM[3], ltok) return end
  local d = (t * llen - abs(s) * 3.0) / 2.3
  if d - floor(d) < 0.32 and abs(s) > 0.18 and abs(s) < 0.9 and t < 0.95 then c:put(x, y, s < 0 and LEAF[4] or LEAF[2], ltok) end
end)
local rb = {} X.ao(rb, rm, sm, 1, -1)
local ridx = X.tone(c, rm, X.light(rn, { amb = 0.15, wrap = 0.3 }), { STEM[2], STEM[3], STEM[4], STEM[5], STEM[6] }, { cuts = { 0.25, 0.45, 0.65, 0.82 }, bias = rb, tok = rtok })
-- roll spiral: diagonal wrap lines
rm:each(function(x, y) if (x + y * 2) % 5 == 0 and (ridx[K(x, y)] or 1) > 1 then c:put(x, y, STEM[2], rtok) end end)

-- stem body: green inner sheath, maroon outer sheath on the shade side, fibre lines, bloom
local v = X.light(sn, { amb = 0.08, wrap = 0.25 })
local green, red = HP.mask(), HP.mask()
sm:each(function(x, y) local k = K(x, y) local t, s = ST[k], SS[k]
  local edge = 0.05 + 0.25 * sin(t * 9 + 0.6)          -- outer sheath margin wanders a little
  if s > edge and t < 0.93 then red:set(x, y) else green:set(x, y) end
end)
local gb = {}
sm:each(function(x, y) local k = K(x, y)
  if floor(SS[k] * 7 + 20) % 3 == 0 and X.hash(x, y, 3) > 0.35 then gb[k] = -1 end   -- long fibre lines
end)
X.ao(gb, green, red, 1, -1)
local gi = X.tone(c, green, v, STEM, { cuts = CUTS, bias = gb, tok = stok })
local ri = X.tone(c, red, v, RED, { cuts = { 0.1, 0.24, 0.4, 0.58, 0.78 }, bias = gb, tok = redtok })
-- lit lip on the maroon sheath margin
red:each(function(x, y) if green:has(x - 1, y) or green:has(x, y - 1) then c:put(x, y, RED[5], redtok) end end)
-- waxy bloom on the lit green
green:shrink(1):each(function(x, y) local k = K(x, y) if (gi[k] or 0) >= 4 and X.hash(x, y, 9) > 0.86 then c:put(x, y, STEM[6], stok) end end)
-- specular streak along the lit side
for _, t in ipairs{ 0.52, 0.56, 0.6 } do
  local x, y = A.bez(SP, t) local s = samp[floor(t * 160) + 1]
  local px, py = floor(x - s.px * 3.2 + .5), floor(y - s.py * 3.2 + .5)
  if sm:has(px, py) then c:put(px, py, "#f2f6d2", stok) end
end
-- crown where leaf + roll leave the stem: dark collar
for _, p in ipairs{ { 29, 31 }, { 30, 31 }, { 31, 31 }, { 32, 30 } } do if sm:has(p[1], p[2]) then c:put(p[1], p[2], STEM[1], stok) end end

-- cut face: concentric sheath rings
local s0 = samp[1]
local fx, fy = 17, 53
local ux, uy = s0.px, s0.py      -- across the stem
local face = A.rell(fx, fy, ux, uy, 5.0, 2.2)
local ftok = A.tok("face")
face:each(function(x, y)
  local dx, dy = x - fx, y - fy
  local a = (dx * ux + dy * uy) / 5.0
  local b = (-dx * uy + dy * ux) / 2.2
  local q = sqrt(a * a + b * b)
  local col
  if q > 0.82 then col = RED[3]
  elseif q > 0.66 then col = FACE[3]
  elseif q > 0.5 then col = FACE[2]
  elseif q > 0.34 then col = FACE[4]
  elseif q > 0.18 then col = FACE[1]
  else col = FACE[3] end
  if q <= 0.82 and a > 0.25 and b > -0.2 then -- lower-right of the face a touch darker
    col = (col == FACE[1]) and FACE[2] or (col == FACE[2]) and FACE[3] or (col == FACE[3]) and FACE[4] or col
  end
  c:put(x, y, col, ftok)
end)
-- quirk: two peeling fibres curling down from the cut face
local fib = A.tok("fibre")
for i, p in ipairs{ { 20, 56 }, { 21, 57 }, { 22, 58 }, { 23, 58 }, { 24, 57 } } do c:put(p[1], p[2], FIB[i > 3 and 2 or 1], fib) end
for i, p in ipairs{ { 18, 57 }, { 18, 58 }, { 19, 59 }, { 20, 59 } } do c:put(p[1], p[2], FIB[i > 2 and 2 or 1], fib) end
A.save(c, NAME)
