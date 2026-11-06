-- apricot (final, Opus). One velvety apricot, slightly taller than wide, with a deep suture crease running from the
-- sunken stem cup down the front. Per-pixel light (6-tone orange + 6-tone red blush on the right shoulder), freckles
-- at the blush edge, velvet sheen (pale grazing rim on the lit edge, matte soft specular), cool violet bounce light
-- lower-right, AO in the stem cup. Short woody twig, two ovate apricot leaves (finely toothed, drip tip, reddish
-- petiole, midrib + veins) casting a shadow on the shoulder.
-- quirk: a neat bite out of the lower right, golden flesh with a thin skin line, and one bead of juice about to drop.
local NAME = "apricot"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, cos, pi, exp = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi, math.exp
local c = A.new(NAME)

local ORG   = { "#6a2738", "#a8452e", "#d86a2a", "#f28e2e", "#fbb247", "#ffd27a" }
local BLUSH = { "#561c34", "#8c2a34", "#bd3e36", "#dc5c38", "#ef7d44", "#fba45e" }
local FLESH = { "#c4682a", "#e48e34", "#f6b04a", "#ffcd6a", "#ffe49a" }
local LEAF  = { "#173d3a", "#215842", "#2f7548", "#47944e", "#6cb258", "#9fcf70" }
local TWIG  = { "#3e2524", "#5e3a2c", "#875838", "#b07e52" }
local PET   = "#a3463a"
local BOUNCE, SHEEN, SPEC = "#9a5f86", "#ffcf88", "#fff0c4"

-- fruit geometry
local CX, CY, RX, RY = 31, 39, 13.6, 14.2
local function dip(x) return 1.8 * exp(-((x - 30.5) / 3.2) ^ 2) end
local function suture(y) return 30.5 + 4.2 * sin(pi * min(1, max(0, (y - 26) / 30)) * 0.9) end
local fm, fn = HP.mask(), {}
for y = floor(CY - RY) - 1, floor(CY + RY) + 1 do for x = floor(CX - RX) - 1, floor(CX + RX) + 1 do
  local u, v = (x - CX) / (RX + 0.45), (y - CY) / (RY + 0.45)
  local q = u * u + v * v
  local top = CY - RY * sqrt(max(0, 1 - u * u)) + dip(x)
  if q <= 1 and y >= top then
    fm:set(x, y)
    local nx, ny, nz = u, v, sqrt(max(0.03, 1 - q)) * 0.9
    -- suture crease: surface folds in, left wall faces right (dark), right wall faces left (lit)
    local d = x - suture(y)
    local g = max(0, 1 - (y - 26) / 34)
    if abs(d) < 3 then nx = nx - 0.85 * g * (d < 0 and -1 or 1) * (1 - abs(d) / 3) end
    -- stem cup: rows near the top centre face up-inward
    local cd = sqrt((x - 30.5) ^ 2 + (y - 26) ^ 2)
    if cd < 4 then ny = ny + 0.5 * (1 - cd / 4) end
    fn[K(x, y)] = { A.norm(nx, ny, nz) }
  end
end end

-- bite (quirk): circle removed off the lower-right, flesh ring inside it
local BX, BY, BR = 44.2, 45.4, 4.8
local bite = HP.mask()
fm:each(function(x, y) if (x - BX) ^ 2 + (y - BY) ^ 2 <= BR * BR then bite:set(x, y) end end)
-- two teeth scallops on the inner wall
for _, t in ipairs{ { 39.6, 43.6 }, { 40.4, 48.2 } } do
  fm:each(function(x, y) if (x - t[1]) ^ 2 + (y - t[2]) ^ 2 <= 2.2 then bite:set(x, y) end end)
end
fm:cut(bite)
local flesh = HP.mask()
fm:each(function(x, y)
  for dy = -2, 2 do for dx = -2, 2 do
    if dx * dx + dy * dy <= 10 and bite:has(x + dx, y + dy) then flesh:set(x, y) return end
  end end
end)
local skin = fm:copy():cut(flesh)

-- leaves (masks first, so the fruit can take their cast shadow)
local function leafW(w) return function(t)
  if t > 0.985 then return -1 end
  if t < 0.16 then return 0.55 end
  local u = (t - 0.16) / 0.84
  return max(0.5, w * sin(pi * min(1, u * 0.92 + 0.05) ^ 0.8) ^ 0.7)
end end
local L1 = { 33, 24, 42, 13, 54, 12, 5.2 }
local L2 = { 29, 24, 22, 14, 12, 15, 3.6 }
local lm1 = select(1, A.blade(L1[1], L1[2], L1[3], L1[4], L1[5], L1[6], leafW(L1[7]), { fold = 0.42 }))
local lm2 = select(1, A.blade(L2[1], L2[2], L2[3], L2[4], L2[5], L2[6], leafW(L2[7]), { fold = 0.42 }))

local bias = {}
X.ao(bias, skin, A.HP.mask():add(HP.ellipse(30.5, 25, 2.5, 1.5)), 2, -1)
A.cast(bias, skin, lm1, 1, 2, -1)
A.cast(bias, skin, lm2, 1, 2, -1)
local ftok = { r = { name = "fruit" } }
local v = X.light(fn, { amb = 0.05, wrap = 0.24 })
local CUT = { 0.2, 0.36, 0.52, 0.68, 0.86 }
-- blush weight: smooth blob on the right shoulder
local function blush(x, y) return exp(-(((x - 37) / 7.5) ^ 2 + ((y - 34) / 8) ^ 2)) end
local idx = {}
skin:each(function(x, y) local k = K(x, y)
  local i = 1
  for j, t in ipairs(CUT) do if v[k] >= t then i = j + 1 end end
  i = max(1, min(6, i + (bias[k] or 0)))
  idx[k] = i
  local b = blush(x, y)
  local red = b > 0.55 or (b > 0.3 and X.hash(x, y, 7) > 0.78)
  c:put(x, y, (red and BLUSH or ORG)[i], ftok)
end)
-- freckles on the blush edge
skin:each(function(x, y) local b = blush(x, y)
  if b > 0.12 and b < 0.3 and X.hash(x, y, 19) > 0.9 then c:put(x, y, BLUSH[max(2, idx[K(x, y)] - 1)], ftok) end
end)
-- suture line: one dark pixel down the fold, fading toward the bottom
for y = 27, 50 do
  local x = floor(suture(y) + 0.5)
  if skin:has(x, y) and not (bias[K(x, y)]) then
    local i = idx[K(x, y)]
    local col = (blush(x, y) > 0.55) and BLUSH or ORG
    c:put(x, y, col[max(1, i - (y < 44 and 2 or 1))], ftok)
  end
end
-- velvet sheen on the lit edge, cool bounce on the shade edge
local rim = X.rim(fn)
skin:edge():each(function(x, y) local k = K(x, y)
  local nn = fn[k]
  if nn[1] < -0.45 and nn[2] < 0.35 and idx[k] >= 4 and not bias[k] then c:put(x, y, SHEEN, ftok) end
  if rim[k] > 0.55 and y > 40 and not flesh:has(x, y) then c:put(x, y, BOUNCE, ftok) end
end)
-- fuzz specks on the lit cheek (velvet), matte soft specular
skin:shrink(2):each(function(x, y) local k = K(x, y)
  if idx[k] >= 5 and X.hash(x, y, 31) > 0.9 then c:put(x, y, ORG[6], ftok) end
end)
c:put(23, 31, SPEC, ftok) c:put(24, 31, SPEC, ftok) c:put(23, 32, ORG[6], ftok) c:put(25, 30, ORG[6], ftok)

-- bite flesh: concave pocket (upper-left wall in shade, lower-right wall lit), skin line, fibres
local etok = { r = { name = "flesh" } }
flesh:each(function(x, y)
  local dx, dy = x - BX, y - BY
  local d = sqrt(dx * dx + dy * dy)
  local f = (dx * 0.6 + dy * 0.75) / max(d, 0.1)   -- facing: + = lower-right of pocket = faces upper-left light
  local i = f > 0.55 and 4 or (f > 0.0 and 3 or (f > -0.6 and 2 or 1))
  if d > BR + 1.6 then i = max(1, i - 1) end          -- deep inside near the skin
  c:put(x, y, FLESH[i], etok)
end)
-- thin skin line where the cut meets the skin
flesh:each(function(x, y)
  for _, q in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
    if skin:has(x + q[1], y + q[2]) then c:put(x, y, ORG[2], etok) return end
  end
end)
-- flesh fibres radiating from the pit
for _, p in ipairs{ { 41, 42 }, { 42, 45 }, { 39, 47 } } do if flesh:has(p[1], p[2]) then c:put(p[1], p[2], FLESH[5], etok) end end
-- juice bead (glossy, below the bite)
local bx, by = nil, -1
flesh:each(function(x, y) if y > by or (y == by and x < bx) then bx, by = x, y end end)
A.map(c, { ".a.", "aca", "aba", ".b." }, bx - 1, by + 1, { a = FLESH[3], b = FLESH[2], c = SPEC }, etok)

-- twig: short, woody, a little bark ring and a pale cut end
local tm = A.stem(c, { { 30.5, 27 }, { 30.3, 24 }, { 30, 22 }, { 29, 19 } }, function(t) return 1.25 - 0.25 * t end, TWIG, { tok = { r = { name = "twig" } } })
c:put(29, 18, TWIG[4], { r = { name = "twig" } }) c:put(30, 18, TWIG[3], { r = { name = "twig" } })
c:put(29, 22, TWIG[1], { r = { name = "twig" } })

-- leaves on top, with reddish petioles
local ltok = { r = { name = "leaf" } }
local lb = {}
local _, T1 = A.leaf(c, L1[1], L1[2], L1[3], L1[4], L1[5], L1[6], L1[7], LEAF, { tok = ltok, wfn = leafW(L1[7]), teeth = 2.2, vs = 3.0 })
local _, T2 = A.leaf(c, L2[1], L2[2], L2[3], L2[4], L2[5], L2[6], L2[7], LEAF, { tok = ltok, wfn = leafW(L2[7]), teeth = 2.2, vs = 3.0, cut = lm1 })
lm1:each(function(x, y) if T1[K(x, y)] < 0.16 then c:put(x, y, PET, ltok) end end)
lm2:each(function(x, y) if T2[K(x, y)] < 0.16 and not lm1:has(x, y) then c:put(x, y, PET, ltok) end end)
-- cool edge on the shade side of the big leaf
A.save(c, NAME)
