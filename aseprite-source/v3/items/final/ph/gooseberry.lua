-- gooseberry (B3, Opus single pass). One slim-oval ruby gooseberry hanging from a thorny woody twig: translucent
-- skin with pale meridian veins pole to pole, a fine fuzz on the rim, waxy bloom, cool reflected light, a dried
-- calyx tail at the bottom, a three-lobed toothed leaf with midribs.
-- quirk: a ladybird is walking across the leaf.
local NAME = "gooseberry"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local RED = { "#4e1530", "#7e1e36", "#ad2c3a", "#d6443e", "#f2715a", "#ffae86" }
local LEAF = { "#1c3f30", "#27593a", "#367844", "#4f9a4c", "#7cbc5c", "#b4da82" }
local TW = { "#3e2622", "#5c3a2a", "#80563a", "#a87a52" }
local COOL, BLOOM = "#8a4c7e", "#e48c84"

-- twig + petiole (curved, woody), thorn
local twm, twn = A.HP.mask(), nil
local tw, twn2 = A.tube({ { 31, 26 }, { 31, 20 }, { 33, 15 }, { 37, 11 } }, function(t) return 0.95 + 0.3 * t end)
twm = tw
-- berry: slim vertical oval
local CX, CY, RX, RY = 30, 38.5, 11.5, 12.5
local bm, bn = A.oval(CX, CY, RX, RY, 0, 0.9)
local bias = {}
X.ao(bias, bm, twm, 1, -1)
local btok = { r = { name = "berry" } }
local bidx = A.shade(c, bm, bn, RED, { amb = 0.1, wrap = 0.32, bias = bias, tok = btok })
-- cool reflected light on lower-right rim
local rim = X.rim(bn)
bm:each(function(x, y) local k = K(x, y) if rim[k] > 0.62 and bidx[k] <= 2 and bm:edge():has(x, y) then c:put(x, y, COOL, btok) end end)
-- meridian veins (translucent, paler than the flesh on the lit side, deeper on the shade side)
for _, f in ipairs{ -0.66, -0.33, 0, 0.33, 0.66 } do
  for y = floor(CY - RY) + 2, floor(CY + RY) - 2 do
    local t = (y - CY) / (RY + 0.45)
    local w = sqrt(max(0, 1 - t * t)) * (RX + 0.45)
    local x = floor(CX + f * w * 0.98 + 0.5)
    local k = K(x, y)
    if bm:has(x, y) and bidx[k] then
      local i = bidx[k]
      c:put(x, y, (f < 0.2 and i >= 3) and RED[min(6, i + 1)] or RED[max(1, i - 1)], btok)
    end
  end
end
-- waxy bloom: a few dusty pixels on the lit shoulder
for _, p in ipairs{ { 24, 31 }, { 22, 35 }, { 26, 29 }, { 21, 39 }, { 25, 44 } } do
  if bm:has(p[1], p[2]) then c:put(p[1], p[2], BLOOM, btok) end end
-- fuzz: pale hairs on the rim pixels
for _, p in ipairs{ { 19, 33 }, { 18, 41 }, { 22, 49 }, { 41, 34 }, { 40, 45 }, { 25, 27 }, { 36, 27 } } do
  local best, bx, by
  bm:edge():each(function(x, y) local q = (x - p[1])^2 + (y - p[2])^2 if not best or q < best then best, bx, by = q, x, y end end)
  c:put(bx, by, (bx < CX) and RED[6] or RED[4], btok)
end
-- specular
local sx, sy = A.specAt(bm, bn, 60)
c:put(sx, sy, "#fff4d6", btok) c:put(sx + 1, sy, RED[6], btok) c:put(sx, sy + 1, RED[6], btok)
-- calyx: dried tail at the bottom pole
local ktok = { r = { name = "calyx" } }
for _, q in ipairs{ { 30, 52, 3 }, { 29, 52, 2 }, { 31, 52, 2 }, { 30, 53, 3 }, { 28, 54, 2 }, { 30, 54, 4 }, { 32, 54, 2 }, { 27, 55, 1 }, { 30, 55, 2 }, { 33, 55, 3 } } do
  c:put(q[1], q[2], TW[q[3]], ktok) end
-- twig tone + thorn
local ttok = { r = { name = "twig" } }
A.shade(c, twm, twn2, TW, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = ttok })
for _, q in ipairs{ { 30, 18, 3 }, { 29, 18, 4 }, { 28, 17, 4 } } do c:put(q[1], q[2], TW[q[3]], ttok) end
-- leaf: three toothed lobes from the petiole tip
local ltok = { r = { name = "leaf" } }
local lobes = {
  { 37, 11, 44, 9, 52, 12, 4.4 },   -- right
  { 37, 11, 41, 7, 46, 4, 3.6 },    -- top
  { 37, 11, 45, 13, 50, 20, 3.4 },  -- lower
}
local lm, ln, LS, LT = HP.mask(), {}, {}, {}
for i, L in ipairs(lobes) do
  local m, n, T, S = A.blade(L[1], L[2], L[3], L[4], L[5], L[6], function(t)
    if t > 0.97 then return -1 end
    return max(0.5, L[7] * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.7)
  end, { fold = 0.4 })
  m:each(function(x, y) local k = K(x, y) if not lm:has(x, y) then n[k].i = i ln[k] = n[k] LS[k] = S[k] LT[k] = T[k] end end)
  lm:add(m)
end
-- teeth: nick the margin
local cut = {}
lm:edge():each(function(x, y) if (x * 3 + y * 5) % 4 == 0 and abs(LS[K(x, y)]) > 0.7 then cut[#cut + 1] = K(x, y) end end)
for _, k in ipairs(cut) do lm.s[k] = nil ln[k] = nil end
lm:cut(twm)
local lidx = A.shade(c, lm, ln, LEAF, { amb = 0.12, wrap = 0.3, tok = ltok })
lm:each(function(x, y) local k = K(x, y)
  if abs(LS[k]) < 0.17 and LT[k] < 0.88 then c:put(x, y, LS[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
-- quirk: ladybird on the right lobe
local lb = { r = { name = "ladybird" } }
for _, q in ipairs{ { 46, 10, "#e8493b" }, { 47, 10, "#ff8a5c" }, { 48, 10, "#e8493b" }, { 46, 11, "#b52e3f" }, { 47, 11, "#2b1c26" }, { 48, 11, "#b52e3f" }, { 49, 10, "#2b1c26" }, { 49, 11, "#2b1c26" }, { 46, 9, "#b52e3f" }, { 47, 9, "#ff8a5c" } } do
  c:put(q[1], q[2], q[3], lb) end
c:put(48, 9, "#e8493b", lb)
A.save(c, NAME)
