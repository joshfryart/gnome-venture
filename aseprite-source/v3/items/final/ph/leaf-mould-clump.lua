-- leaf-mould-clump (final, Opus single pass). A single broken-off clump of leaf mould: rounded crumbly top with a
-- pressed, half-rotted orange leaf (veins, nibbled edge) and white mycelium threads, and a snapped-off front face that
-- shows the pressed leaf layers as wavy strata with rusty flecks. Two crumbs have fallen off the right end.
-- quirk: a tiny pink mushroom has come up out of the top.
local NAME = "leaf-mould-clump"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local MO = { "#24150f", "#3a2216", "#55331e", "#714728", "#8f5f34", "#ad7b46" }
local FACE = { "#2a1810", "#43281a", "#5f3b22", "#7c522c", "#9b6c3a" }
local LEAF = { "#6a2a1a", "#9a4222", "#c4652c", "#e08c3c", "#f5b462" }
local MYC = { "#c9bfae", "#efe6d2" }
local PINK = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }
local STALK = { "#b7a294", "#e6d8c8", "#fff4d6" }

c:groundShadow(31, 46, 22, 2)

-- clump outline: lumpy, wider than tall
local clump = HP.mask()
clump:add(A.rell(30, 37, 1, 0.12, 20, 8.5)):add(A.rell(22, 33, 1, 0, 9, 6.5)):add(A.rell(37, 32, 1, 0.1, 10, 6))
-- bite out of the lower right (where crumbs broke off) and a lumpy top
clump:cut(A.rell(51, 42, 1, 0, 4, 3.5))
for x = 8, 54 do if X.hash(x, 0, 5) > 0.7 then local top for y = 20, 50 do if clump:has(x, y) then top = y break end end
  if top then clump.s[K(x, top)] = nil end end end
-- front broken face: lower band below a wavy break line
local face = HP.mask()
clump:each(function(x, y) if y > 37 + 1.6 * sin(x * 0.35) - (x - 30) * 0.08 then face:set(x, y) end end)
local top = clump:copy():cut(face)

-- top: pillow + sphere blend, crumbly noise
local tok = { r = { name = "clump" } }
local bias = {}
X.ao(bias, top, face, 1, -1)
local n = A.body(top, 26, 30, 20, 5, 0.4)
local idx = A.shade(c, top, n, MO, { bias = bias, tok = tok, amb = 0.1, wrap = 0.3 })
top:each(function(x, y) local h = X.hash(x, y, 11)
  if h < 0.17 then A.step(c, idx, MO, x, y, -1, tok) elseif h > 0.88 then A.step(c, idx, MO, x, y, 1, tok) end end)

-- face: strata (pressed leaf layers), darker overall, lit band at the top lip
local ftok = { r = { name = "face" } }
face:each(function(x, y)
  local d = y + 0.9 * sin(x * 0.5) + 0.5 * sin(x * 0.17 + 1)
  local band = floor(d / 2.2) % 3
  local i = ({ 3, 4, 2 })[band + 1]
  if x > 42 then i = i - 1 end            -- shade side
  if x < 16 then i = i + 1 end
  if not face:has(x, y - 1) then i = 5 end  -- broken lip catches light
  if not face:has(x, y + 1) then i = 1 end  -- underside
  if X.hash(x, y, 4) > 0.9 then i = i + 1 end
  c:put(x, y, FACE[max(1, min(5, i))], ftok)
end)
for _, p in ipairs{ { 18, 42 }, { 27, 41 }, { 34, 44 }, { 23, 45 }, { 40, 41 }, { 14, 40 } } do
  if face:has(p[1], p[2]) and face:has(p[1] + 1, p[2]) then c:put(p[1], p[2], LEAF[2], ftok) c:put(p[1] + 1, p[2], LEAF[3], ftok) end end

-- pressed leaf on top: half-rotted, nibbled, veins
local ltok = { r = { name = "leaf" } }
local lm, ln, LT, LS = A.blade(13, 33, 21, 26, 33, 27, function(t)
  if t > 0.97 then return -1 end
  return max(0.5, 4.2 * sin(pi * min(1, t * 0.95 + 0.04)) ^ 0.7)
end, { fold = 0.15 })
lm:clip(top)
-- rotted holes
lm:cut(A.rell(25, 25, 1, 0, 1.6, 1.1)):cut(A.rell(29, 30, 1, 0, 1.2, 0.8))
local lidx = A.toneN(c, lm, ln, LEAF, { tok = ltok, cuts = { 0.2, 0.4, 0.6, 0.8 }, amb = 0.2, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y)
  if abs(LS[k]) < 0.14 and LT[k] < 0.9 then c:put(x, y, LEAF[5], ltok)
  elseif abs(LS[k]) > 0.25 and (LT[k] * 7 - abs(LS[k])) % 1.3 < 0.3 then c:put(x, y, LEAF[max(1, (lidx[k] or 3) - 1)], ltok) end
end)
-- contact shadow under the leaf onto the mould
lm:shift(1, 1):each(function(x, y) if top:has(x, y) and not lm:has(x, y) then A.step(c, idx, MO, x, y, -1, tok) end end)

-- mycelium threads: thin pale lines wandering over the top
local mtok = { r = { name = "myc" } }
for _, th in ipairs{ { { 34, 33 }, { 36, 32 }, { 38, 32 }, { 39, 31 }, { 41, 31 }, { 42, 32 }, { 44, 31 } },
                    { { 36, 27 }, { 38, 28 }, { 40, 27 }, { 41, 26 } },
                    { { 11, 36 }, { 12, 35 }, { 14, 35 } } } do
  for i, p in ipairs(th) do if top:has(p[1], p[2]) and not lm:has(p[1], p[2]) then c:put(p[1], p[2], MYC[(i % 3 == 0) and 2 or 1], mtok) end end
end

-- quirk: tiny pink mushroom
local ktok = { r = { name = "mushroom" } }
for y = 23, 27 do c:put(44, y, STALK[2], ktok) c:put(45, y, STALK[1], ktok) end
c:put(44, 25, STALK[3], ktok)
A.map(c, {
  ".bbbb.",
  "bcccbb",
  "cddcca",
  "aaaaaa",
}, 42, 19, { a = PINK[1], b = PINK[3], c = PINK[2], d = PINK[4] }, ktok)
c:put(44, 20, "#fff4d6", ktok)
c:put(43, 28, MO[2], tok) c:put(46, 28, MO[2], tok)  -- AO at the stalk foot

-- fallen crumbs, 1-2 px of air from the clump
local crtok = { r = { name = "crumb" } }
for _, cr in ipairs{ { 52, 43, 2.2, 1.7 }, { 56, 45, 1.5, 1.2 } } do
  local m = A.rell(cr[1], cr[2], 1, 0, cr[3], cr[4])
  m:cut(clump:grow(1))
  local cn = X.sphere(cr[1], cr[2], cr[3] + 0.5, m)
  A.shade(c, m, cn, MO, { tok = crtok, amb = 0.1, wrap = 0.3 })
end

A.save(c, NAME)
