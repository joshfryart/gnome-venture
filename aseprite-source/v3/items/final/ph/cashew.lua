-- cashew (final, Opus single pass). A slim, glossy cashew apple (yellow shoulder blushing to red, waxy bloom,
-- cream specular, cool reflected light on the shade side) with the kidney nut hanging under it (olive-khaki shell,
-- raised suture seam, AO where it meets the apple), a short woody stem and one leathery obovate leaf with veins.
-- quirk: a tiny ant marches along the leaf midrib.
local NAME = "cashew"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_5.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = A.new(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local RED = { "#5e1832", "#962238", "#c8332f", "#e8542c", "#fb8a3a", "#ffc46a" }
local YEL = { "#6e3a26", "#a65c26", "#d68a24", "#f2b42c", "#ffd850", "#fff09a" }
local NUT = { "#2e2a26", "#4c4434", "#6c6246", "#8e8456", "#b4aa78", "#dcd4a2" }
local WOOD = { "#3e2622", "#5e3c2c", "#86583a", "#ad7c52" }
local COOL = "#a0457a"

-- nut first (it hangs behind the apple base)
local nm, nn, NT, NS = A.kidney(31, 40, 9.5, 3.4, 0.1, 3.5, 2.9)
local apm, _an0, apT, apS = G.tube({ { 31, 13 }, { 30, 19 }, { 31, 26 }, { 32, 31 } },
  function(t) return 2.8 + 4.5 * min(1, t * 1.15) ^ 0.85 end)
local nb = {}
X.ao(nb, nm, apm, 2, -1)
G.cast(nb, nm, apm, 1, 2, -1)
local ntok = { r = { name = "nut" } }
local nidx = A.shade(c, nm, nn, NUT, { amb = 0.1, wrap = 0.3, bias = nb, tok = ntok })
-- suture seam along the outer (lower) curve + matte speckle
nm:each(function(x, y) local k = K(x, y)
  local s, t = NS[k], NT[k]
  if s > 0.38 and s < 0.62 and t > 0.12 and t < 0.88 then c:put(x, y, NUT[max(1, nidx[k] - 2)], ntok)
  elseif s > 0.62 and s < 0.8 and t > 0.15 and t < 0.85 then c:put(x, y, NUT[min(6, nidx[k] + 1)], ntok)
  elseif X.hash(x, y, 3) < 0.07 and nidx[k] >= 3 then c:put(x, y, NUT[nidx[k] - 1], ntok) end
end)
do local bx, by = G.specAt(nm:copy():cut(apm), nn, 30) c:put(bx, by, NUT[6], ntok) c:put(bx + 1, by, NUT[6], ntok) end

-- apple
local an = A.body(apm, 30, 27, 13, 6, 0.55)
local atok = { r = { name = "apple" } }
local v = X.light(an, { amb = 0.06, wrap = 0.24 })
local aidx = X.tone(c, apm, v, RED, { cuts = A.CUTS, tok = atok })
local rim = X.rim(an)
apm:each(function(x, y) local k = K(x, y)
  local t = apT[k]
  local i = aidx[k]
  local yel = t < 0.3 + 0.07 * sin(x * 1.3) + 0.05 * sin(y * 0.9)
  local ramp = yel and YEL or RED
  -- waxy bloom: pale freckles on the mid tones
  if i >= 3 and i <= 4 and X.hash(x, y, 11) < 0.08 then i = i + 1 end
  c:put(x, y, ramp[i], atok)
end)
-- reflected light on the shade edge
apm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] and rim[k] > 0.62 and aidx[k] <= 3 and apT[k] > 0.35 then c:put(x, y, COOL, atok) end end)
-- specular
do local bx, by = G.specAt(apm, an, 40)
  c:put(bx, by, A.CREAM, atok) c:put(bx + 1, by, A.CREAM, atok) c:put(bx, by + 1, YEL[6], atok) end
-- small brown scar where the apple meets the nut (calyx end)
for _, p in ipairs{ { 33, 38 }, { 34, 38 }, { 34, 37 } } do if apm:has(p[1], p[2]) then c:put(p[1], p[2], RED[1], atok) end end

-- stem
local stok = { r = { name = "stem" } }
local sm = A.stem(c, { { 31, 11 }, { 31, 8 }, { 32, 6 }, { 33, 4 } }, function(t) return 1.15 - t * 0.2 end, WOOD, { cut = apm, tok = stok })
c:put(33, 4, WOOD[4], stok)
-- leaf (obovate, rounded tip) off the stem to the upper right
local lm, lT, lS = A.leaf(c, 33, 7, 42, 4, 53, 8, 4.2, LEAF, {
  wfn = function(t) if t > 0.99 then return -1 end return max(0.5, 4.4 * sin(pi * min(1, t ^ 1.35 * 0.96 + 0.04)) ^ 0.6) end,
  vs = 3.4, cut = sm })
-- quirk: ant on the midrib
local INK = A.INK
for _, p in ipairs{ { 42, 5 }, { 43, 5 }, { 42, 6 }, { 43, 6 }, { 45, 6 }, { 46, 6 }, { 47, 6 }, { 44, 7 }, { 46, 7 }, { 45, 5 }, { 48, 5 } } do
  if lm:has(p[1], p[2]) then c:put(p[1], p[2], INK, { r = { name = "ant" } }) end
end
c:put(47, 6, "#8a4a52", { r = { name = "ant" } })

A.save(c, NAME)
