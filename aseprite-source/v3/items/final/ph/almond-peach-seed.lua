-- almond-peach-seed (final, Opus). One big almond-shaped peach stone lying on a torn, serrated peach-leaf scrap.
-- Stone: per-pixel light (6-tone rosy brown), a raised keel along the suture with a dark seam beside it, deep winding
-- furrows and pits (dark groove + lit ridge edge), AO and a contact shadow on the leaf. The stone has cracked at its
-- pointed tip: a pale radicle curls down over the leaf edge and a slim shoot rises with three lanceolate, finely
-- serrated peach leaves (midrib + veins). The leaf scrap is torn off at the tip with pale fibres on the tear.
-- quirk: a last scrap of orange peach flesh is still stuck to the stone.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "almond-peach-seed"
local c = A.new(NAME)

local LEAF  = { "#163c36", "#205640", "#2c7446", "#43934c", "#68b356", "#9ccf6c" }
local SHOOT = { "#173f36", "#2a6a44", "#3f8c4c", "#5faa52", "#86c460", "#b4de7e" }
local STONE = { "#3c1f22", "#62312c", "#8a4a36", "#ad6844", "#cc8c5e", "#e8b486" }
local STEM  = { "#5a6a3c", "#8aa25a", "#b8cf82", "#e2efb8" }
local ROOT  = { "#a08268", "#cdb494", "#eadbbe", "#fff4d6" }
local FLESH = { "#c25a2c", "#ee8a3a", "#ffbc62" }
local TEAR, COOL = "#d8e89a", "#3a6c72"

-- stone geometry first (needed for leaf shadows)
local sux, suy = A.norm(0.86, -0.5, 0)
local stone, sn, SU, SV = A.almond(26, 45, sux, suy, 10.5, 6.2, 0.75)

-- leaf scrap: a peach leaf on the diagonal, torn off near the tip
local lbias = {}
local ltok = { r = { name = "leaf" } }
local lm0 = HP.mask()
do
  local m = A.blade(7, 56, 30, 52, 58, 40, function(t) if t > 0.985 then return -1 end
    return max(0.5, 9.0 * sin(pi * min(1, t * 0.97 + 0.05)) ^ 0.75) end, { fold = 0.4 })
  lm0 = m
end
-- tear: jagged cut across the tip end + a nibble from the upper edge
local tear = c:poly{ { 50, 30 }, { 52, 36 }, { 49, 39 }, { 53, 42 }, { 51, 45 }, { 55, 48 }, { 63, 48 }, { 63, 30 } }
local nib = c:ellipse(16, 46, 2.5, 2)
lm0:cut(tear):cut(nib)
X.ao(lbias, lm0, stone, 1, -1)
A.cast(lbias, lm0, stone, 1, 2, -1)
A.cast(lbias, lm0, stone, 2, 3, -1)
local lm = A.leaf(c, 7, 56, 30, 52, 58, 40, 9.0, LEAF, { tok = ltok, teeth = 2.8, bias = lbias, wfn = function(t) if t > 0.985 then return -1 end
  return max(0.5, 9.0 * sin(pi * min(1, t * 0.97 + 0.05)) ^ 0.75) end, cut = tear:copy():add(nib), fold = 0.4, vs = 4.2 })
-- torn edge: pale fibres
lm:each(function(x, y) if (tear:has(x + 1, y) or tear:has(x, y - 1) or nib:has(x, y - 1) or nib:has(x + 1, y) or nib:has(x - 1, y)) then
  c:put(x, y, X.hash(x, y, 5) > 0.4 and TEAR or LEAF[5], ltok) end end)
-- cool reflected edge on the lower leaf margin
lm:edge():each(function(x, y) local k = K(x, y) if not lbias[k] and not lm:has(x + 1, y + 1) and not lm:has(x, y + 1) and x > 12 and x < 46 then c:put(x, y, COOL, ltok) end end)
-- petiole stub
for _, q in ipairs{ { 6, 57, 3 }, { 5, 58, 2 }, { 4, 59, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- radicle: out of the cracked tip, over the leaf edge (drawn before the stone)
local rtok = { r = { name = "root" } }
local rm = A.stem(c, { { 35, 41 }, { 41, 44 }, { 44, 49 }, { 45, 55 } }, function(t) return 1.5 * (1 - t) ^ 0.8 + 0.35 end, ROOT, { tok = rtok, cut = stone })
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
c:put(47, 50, ROOT[2], rtok) c:put(42, 49, ROOT[2], rtok)   -- root hairs

-- shoot: stem rising from the crack, three serrated lanceolate leaves
local stok = { r = { name = "stem" } }
local sp = { { 35, 40 }, { 37, 32 }, { 35, 24 }, { 36, 15 } }
local stm = A.stem(c, sp, function(t) return 1.15 - 0.35 * t end, STEM, { tok = stok, cut = stone })
local shtok = { r = { name = "shoot" } }
local l1 = A.leaf(c, 36, 31, 29, 25, 19, 27, 2.7, SHOOT, { tok = shtok, teeth = 2.2, cut = stm, amb = 0.2 })
local l2 = A.leaf(c, 36, 25, 44, 18, 53, 21, 2.8, SHOOT, { tok = shtok, teeth = 2.2, cut = stm, amb = 0.2 })
local l3 = A.leaf(c, 36, 17, 31, 13, 26, 14, 1.8, SHOOT, { tok = shtok, teeth = 2.2, cut = stm:copy():add(l1), amb = 0.22, serrate = false })
-- leaf bases: AO dot where blade meets stem
c:put(35, 30, SHOOT[1], shtok) c:put(37, 24, SHOOT[1], shtok)
-- terminal bud
c:put(36, 15, SHOOT[6], shtok) c:put(37, 14, SHOOT[5], shtok) c:put(36, 14, SHOOT[4], shtok)

-- stone: pitted, furrowed, keeled
local sb = {}
stone:each(function(x, y) local k = K(x, y)
  local u, v = SU[k], SV[k]
  local w = (u * 9.6 + sin(v * 3.1 + u * 2) * 1.6 + X.hash(x, y, 2) * 0.9) % 3.3
  if abs(v) < 0.16 and u > -0.85 and u < 0.85 then sb[k] = 1           -- keel along the suture
  elseif abs(v) < 0.3 and u > -0.8 and u < 0.8 then sb[k] = -2        -- seam beside the keel
  elseif abs(v) < 0.9 and w < 0.95 then sb[k] = -2                    -- furrow
  elseif abs(v) < 0.9 and w < 1.7 then sb[k] = 1                      -- lit ridge edge after the furrow
  elseif X.hash(x, y, 8) > 0.9 then sb[k] = -2 end                    -- pit
end)
local stk = { r = { name = "stone" } }
local sidx = A.shade(c, stone, sn, STONE, { amb = 0.08, wrap = 0.25, bias = sb, tok = stk, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
-- crack at the tip where the shoot came out
for _, p in ipairs{ { 34, 41 }, { 33, 42 }, { 34, 40 }, { 33, 41 } } do c:put(p[1], p[2], STONE[1], stk) end
-- specular on the keel shoulder
c:put(20, 43, A.CREAM, stk) c:put(21, 42, STONE[6], stk)

-- quirk: a scrap of peach flesh clinging to the stone
local fl = { { 23, 49, 2 }, { 24, 49, 2 }, { 25, 49, 1 }, { 22, 48, 3 }, { 23, 48, 2 }, { 24, 50, 1 }, { 22, 49, 2 } }
for _, p in ipairs(fl) do c:put(p[1], p[2], FLESH[p[3]], stk) end

A.save(c, NAME)
