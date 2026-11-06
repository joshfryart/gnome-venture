-- hanging-planter (final pass, Opus aC10_5). A terracotta pot in a jute macrame hanger: brass hanging ring, two twisted
-- cords running down the pot's sides into a gathered wrap knot and a short tassel; rim seen from just above with dark
-- soil; three upright heart leaves and one trailing pothos vine spilling over the left. Terracotta per-pixel cylinder
-- light, rim bevel + AO row under the rim, pale mineral bloom near the base; leaves with midribs and veins.
-- quirk: a small snail is climbing the pot's right side.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.pi
local c = A.new("hanging-planter")

local TC    = { "#5a2430", "#8c3530", "#b8502f", "#d86c3a", "#ee9058", "#f8b884" }
local SOIL  = { "#2e1c22", "#4a2c28", "#6a4232" }
local ROPE  = { "#9a6a40", "#d2a66c", "#f0d8a4" }
local BRASS = { "#5e3420", "#c88a24", "#f8d866", "#fff1b0" }
local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#a6d470" }

-- leaf: curved blade A-C-B with midrib + veins
local function leaf(ax, ay, cx, cy, bx, by, w, tok)
  local wfn = function(t) if t > 0.985 then return -1 end
    local s = sin(pi * min(1, t * 0.9 + 0.12)) return max(0.4, w * s ^ 0.6) end
  local m, n, T, S, len = A.blade(ax, ay, cx, cy, bx, by, wfn, { fold = 0.45 })
  local idx = A.toneN(c, m, n, LEAF, { amb = 0.12, wrap = 0.28, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = tok })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.16 and t > 0.05 and t < 0.85 then c:put(x, y, s <= 0 and LEAF[min(6, (idx[k] or 3) + 2)] or LEAF[max(2, (idx[k] or 3) - 1)], tok)
    elseif t > 0.15 and t < 0.8 and abs(s) > 0.35 and abs(s) < 0.75 and ((t * len - abs(s) * w) % 3.2) < 0.9 then
      c:put(x, y, LEAF[max(1, (idx[k] or 3) - 1)], tok) end
  end)
  return m
end

-- ring + upper cords (behind leaves)
local tokB, tokR = A.tok("brass"), A.tok("rope")
for _, p in ipairs{ { 31, 5, 3 }, { 32, 5, 3 }, { 30, 6, 3 }, { 33, 6, 2 }, { 29, 7, 3 }, { 34, 7, 2 }, { 29, 8, 2 }, { 34, 8, 1 }, { 30, 9, 2 }, { 33, 9, 1 }, { 31, 10, 1 }, { 32, 10, 1 } } do
  c:put(p[1], p[2], BRASS[p[3]], tokB) end
c:put(31, 5, BRASS[4], tokB)
A.rope(c, { { 31, 11 }, { 31, 13 } }, 2, ROPE, tokR)                                 -- top wrap knot
for y = 11, 13 do c:put(30, y, ROPE[1], tokR) c:put(33, y, ROPE[1], tokR) end
for x = 30, 33 do c:put(x, 12, ROPE[3], tokR) end
A.rope(c, { { 30, 14 }, { 19, 29 } }, 2, ROPE, tokR)
A.rope(c, { { 33, 14 }, { 44, 29 } }, 2, ROPE, tokR)

-- pot body
local tokT, tokS = A.tok("terracotta"), A.tok("soil")
local function hw(y) return 12.5 - (y - 34) * 0.33 end
local body = A.maskF(10, 34, 54, 47, function(x, y) local w = hw(y) if y == 47 then w = w - 1.5 end return abs(x + 0.5 - 32) <= w end)
local nb, bb = {}, {}
body:each(function(x, y) local k = K(x, y) local t = max(-0.95, min(0.95, (x + 0.5 - 32) / (hw(y) + 0.5)))
  local ny = (y > 44) and 0.35 or 0.08
  nb[k] = { A.norm(t, ny, sqrt(1 - t * t)) }
  if y <= 35 then bb[k] = -1 end                    -- AO under the rim
end)
local ib = A.shade(c, body, nb, TC, { amb = 0.08, wrap = 0.25, bias = bb, tok = tokT })
-- mineral bloom: pale chalky flecks near the base, a faint throwing ring
body:each(function(x, y) if y >= 42 and X.hash(x, y, 4) > 0.86 then A.step(c, ib, TC, x, y, 1, tokT) end
  if y == 40 and X.hash(x, 1, 6) > 0.25 then A.step(c, ib, TC, x, y, -1, tokT) end end)
-- rim band (bevel: top row bright, lower row darker)
local rim = A.maskF(17, 29, 47, 33, function(x, y)
  if y >= 31 then return x >= 18 and x <= 46 end
  local dx = (x + 0.5 - 32) / 15 local dy = (y + 0.5 - 31) / 2.4
  return dx * dx + dy * dy <= 1 and x >= 18 and x <= 46 end)
local nr = {}
rim:each(function(x, y) local t = max(-0.95, min(0.95, (x + 0.5 - 32) / 15.5)) local ny = (y <= 31) and -0.6 or (y == 33 and 0.4 or 0)
  nr[K(x, y)] = { A.norm(t, ny, sqrt(1 - t * t)) } end)
local ir = A.shade(c, rim, nr, TC, { amb = 0.12, wrap = 0.3, tok = tokT })
-- soil opening
local soil = A.maskF(19, 29, 45, 31, function(x, y) local dx = (x + 0.5 - 32) / 12.6 local dy = (y + 0.5 - 30.6) / 1.6 return dx * dx + dy * dy <= 1 end)
soil:each(function(x, y) c:put(x, y, (y == 29 or X.hash(x, y, 3) > 0.7) and SOIL[1] or ((X.hash(x, y, 8) > 0.75) and SOIL[3] or SOIL[2]), tokS) end)
c:put(22, 32, TC[6], tokT) c:put(23, 32, TC[6], tokT)                                  -- rim pop

-- upright leaves (in front of the upper cords)
local tokL = A.tok("leaf")
c:put(31, 29, LEAF[2], tokL) c:put(33, 29, LEAF[2], tokL)
leaf(31, 29, 25, 24, 21, 17, 3.0, tokL)
leaf(33, 29, 37, 23, 41, 19, 2.7, tokL)
leaf(32, 30, 31, 22, 34, 14, 3.2, tokL)

-- side cords down the pot, into the gather knot and tassel
A.rope(c, { { 18, 33 }, { 21, 43 }, { 28, 49 } }, 2, ROPE, tokR)
A.rope(c, { { 45, 33 }, { 43, 43 }, { 36, 49 } }, 2, ROPE, tokR)
-- gather knot (wrapped bands) with AO under the pot
for y = 48, 51 do for x = 29, 35 do local p = (y % 2 == 0) and ((x % 3 == 0) and 2 or 3) or ((x % 3 == 0) and 1 or 2)
  if not ((y == 48 or y == 51) and (x == 29 or x == 35)) then c:put(x, y, ROPE[p], tokR) end end end
for x = 30, 34 do c:put(x, 47, TC[1], tokT) end
-- tassel strands
local tokF = A.tok("tassel")
for i, x in ipairs{ 29, 31, 33, 35 } do local L = 4 + (i % 2)
  for d = 0, L - 1 do c:put(x, 52 + d, (d == 0) and ROPE[1] or ((d + i) % 2 == 0 and ROPE[2] or ROPE[3]), tokF) end end
for _, x in ipairs{ 30, 32, 34 } do c:put(x, 52, ROPE[1], tokF) c:put(x, 53, ROPE[2], tokF) end

-- trailing pothos vine over the left rim
local vine = { { 20, 30 }, { 15, 33 }, { 13, 38 }, { 14, 43 }, { 12, 48 }, { 13, 52 } }
local vm = HP.line(vine, 1)
vm:each(function(x, y) c:put(x, y, LEAF[3], tokL) end)
leaf(15, 33, 12, 33, 9, 31, 1.9, tokL)
leaf(13, 39, 16, 40, 18, 42, 1.8, tokL)
leaf(13, 44, 10, 45, 8, 47, 1.8, tokL)
leaf(13, 51, 15, 53, 17, 55, 1.6, tokL)

-- quirk: snail on the pot's right flank
local tokN = A.tok("snail")
A.map(c, {
  ".k.k...",
  ".k.k...",
  "..ssPPp",
  "..sPhPd",
  "..sPPpd",
  "bbbbbdd",
}, 37, 36, { k = "#7a6a72", s = "#cdbcb4", P = "#f5809f", h = "#ffc4d8", p = "#c94f84", d = "#7d2c5e", b = "#e6d8c4" }, tokN)
c:put(39, 38, "#2b1c26", tokN)
A.save(c, "hanging-planter")
