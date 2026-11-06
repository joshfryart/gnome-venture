-- almond-seed (final, Opus). A low, wide torn scrap of almond leaf (serrated margin, midrib + veins, ragged pale tear on
-- the left) carrying two almonds: on the right a whole almond in its pale pitted shell, cracked open along the seam so
-- the brown kernel shows; on the left a bare kernel (6-tone russet, long wrinkle lines, one specular) that has
-- germinated from its pointed tip: a pale radicle reaching over the leaf edge and a slim shoot with an opposite pair
-- of narrow serrated almond leaves plus a small lower leaf. AO + contact shadows on the leaf under every part.
-- quirk: a single pink-white almond-blossom petal has landed on the scrap.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "almond-seed"
local c = A.new(NAME)

local LEAF   = { "#1a3a38", "#255442", "#327048", "#4a8f4e", "#70ae58", "#a2cc72" }
local SHOOT  = { "#173f36", "#2a6a44", "#3f8c4c", "#5faa52", "#86c460", "#b4de7e" }
local SHELL  = { "#6e4a30", "#9a6c44", "#c09160", "#dbb37e", "#eccf9e", "#f8e6c0" }
local KERNEL = { "#3a1e1c", "#5e2f24", "#83452c", "#a65f36", "#c47f4c", "#e0a670" }
local STEM   = { "#5a6a3c", "#8aa25a", "#b8cf82", "#e2efb8" }
local ROOT   = { "#a08268", "#cdb494", "#eadbbe", "#fff4d6" }
local PETAL  = { "#c95f8a", "#f2a6c0", "#ffd6e2", "#fff0f2" }
local TEAR, COOL = "#d8e89a", "#3a6c72"

-- nut geometry
local hux, huy = A.norm(0.92, -0.38, 0)
local shell, shn, HU, HV = A.almond(42, 45, hux, huy, 9.0, 5.4, 0.8)
local kux, kuy = A.norm(-0.86, -0.5, 0)
local kern, kn, KU, KV = A.almond(25, 48, kux, kuy, 7.2, 4.0, 0.9)

-- leaf scrap
local wfn = function(t) if t > 0.985 then return -1 end return max(0.5, 8.0 * sin(pi * min(1, t * 0.95 + 0.06)) ^ 0.6) end
local tear = c:poly{ { 0, 38 }, { 12, 40 }, { 10, 44 }, { 14, 47 }, { 11, 50 }, { 15, 53 }, { 12, 56 }, { 14, 62 }, { 0, 62 } }
local lm0 = A.blade(8, 52, 30, 59, 56, 47, wfn, { fold = 0.35 })
lm0:cut(tear)
local lbias = {}
for _, m in ipairs{ shell, kern } do
  X.ao(lbias, lm0, m, 1, -1) A.cast(lbias, lm0, m, 1, 2, -1) A.cast(lbias, lm0, m, 2, 3, -1)
end
local ltok = { r = { name = "leaf" } }
local lm = A.leaf(c, 8, 52, 30, 59, 56, 47, 8.0, LEAF, { tok = ltok, teeth = 3.0, bias = lbias, wfn = wfn, cut = tear, fold = 0.35, vs = 4.4 })
lm:each(function(x, y) if tear:has(x - 1, y) or tear:has(x, y - 1) or tear:has(x, y + 1) then
  c:put(x, y, X.hash(x, y, 5) > 0.35 and TEAR or LEAF[5], ltok) end end)
lm:edge():each(function(x, y) local k = K(x, y) if not lbias[k] and not lm:has(x, y + 1) and x > 16 and x < 52 then c:put(x, y, COOL, ltok) end end)
-- petiole on the right end
for _, q in ipairs{ { 56, 47, 3 }, { 57, 46, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- radicle from the kernel tip, over the lower-left leaf edge
local rtok = { r = { name = "root" } }
local rm = A.stem(c, { { 19, 45 }, { 15, 47 }, { 13, 52 }, { 14, 58 } }, function(t) return 1.4 * (1 - t) ^ 0.8 + 0.35 end, ROOT, { tok = rtok, cut = kern })
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
c:put(12, 51, ROOT[2], rtok) c:put(16, 55, ROOT[2], rtok)

-- shoot from the tip: arching stem, opposite pair at the top, small lower leaf
local stok, shtok = { r = { name = "stem" } }, { r = { name = "shoot" } }
local stm = A.stem(c, { { 19, 44 }, { 15, 36 }, { 22, 29 }, { 21, 20 } }, function(t) return 1.15 - 0.35 * t end, STEM, { tok = stok, cut = kern })
local la = A.leaf(c, 21, 21, 15, 15, 9, 16, 2.6, SHOOT, { tok = shtok, teeth = 2.2, cut = stm, amb = 0.2 })
local lb = A.leaf(c, 22, 21, 29, 14, 35, 15, 2.7, SHOOT, { tok = shtok, teeth = 2.2, cut = stm, amb = 0.2 })
local lc = A.leaf(c, 19, 33, 25, 29, 30, 31, 2.0, SHOOT, { tok = shtok, teeth = 2.2, cut = stm, amb = 0.22 })
c:put(21, 22, SHOOT[1], shtok) c:put(20, 33, SHOOT[2], shtok)
c:put(21, 19, SHOOT[6], shtok) c:put(21, 18, SHOOT[4], shtok)

-- bare kernel: russet, long wrinkle lines, AO where root/stem leave the tip
local kb = {}
kern:each(function(x, y) local k = K(x, y)
  local u, v = KU[k], KV[k]
  local w = (v * 4.6 + sin(u * 4) * 0.6 + X.hash(x, y, 4) * 0.5) % 1.9
  if abs(v) < 0.88 and w < 0.45 then kb[k] = -1 end
  if u > 0.72 then kb[k] = (kb[k] or 0) - 1 end
end)
local ktok = { r = { name = "kernel" } }
A.shade(c, kern, kn, KERNEL, { amb = 0.08, wrap = 0.25, bias = kb, tok = ktok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
c:put(23, 46, A.CREAM, ktok) c:put(24, 46, KERNEL[6], ktok)

-- shell: pale, pitted, keel on the seam, cracked open showing the kernel
local hb = {}
shell:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 13)
  if h > 0.82 then hb[k] = -2 elseif h > 0.7 then hb[k] = 1 end
end)
local htok = { r = { name = "shell" } }
local hidx = A.shade(c, shell, shn, SHELL, { amb = 0.1, wrap = 0.28, bias = hb, tok = htok, cuts = { 0.14, 0.28, 0.44, 0.6, 0.78 } })
-- the crack: a lens along the upper seam (v ~ -0.25), kernel brown inside, lit shell lip above
local crack = HP.mask()
shell:each(function(x, y) local k = K(x, y)
  local u, v = HU[k], HV[k]
  local o = 0.3 * sin(pi * (u + 0.7) / 1.45) ^ 0.7
  if u > -0.7 and u < 0.75 and v > -0.12 - o and v < -0.12 + o * 0.6 then crack:set(x, y) end
end)
crack:each(function(x, y)
  local i = crack:has(x, y - 1) and (crack:has(x, y + 1) and 4 or 3) or 2
  if X.hash(x, y, 2) > 0.7 then i = i + 1 end
  c:put(x, y, KERNEL[i], htok)
end)
crack:shift(0, -1):each(function(x, y) if shell:has(x, y) and not crack:has(x, y) then c:put(x, y, SHELL[6], htok) end end)
crack:shift(0, 1):each(function(x, y) if shell:has(x, y) and not crack:has(x, y) then c:put(x, y, SHELL[1], htok) end end)
-- cool bounce on the shell's lower-right rim
local rim = X.rim(shn)
shell:edge():each(function(x, y) if rim[K(x, y)] > 0.75 then c:put(x, y, "#a2a6c0", htok) end end)

-- quirk: almond-blossom petal resting on the scrap
local ptok = { r = { name = "petal" } }
local pet = { "..23.", ".2343", "12334", ".122." }
local map = { ["1"] = PETAL[1], ["2"] = PETAL[2], ["3"] = PETAL[3], ["4"] = PETAL[4] }
A.map(c, pet, 31, 52, map, ptok)
-- petal contact shadow
for _, p in ipairs{ { 32, 56 }, { 33, 56 }, { 36, 55 } } do if lm:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[1], ltok) end end

A.save(c, NAME)
