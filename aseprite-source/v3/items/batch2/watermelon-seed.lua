-- watermelon-seed (batch2, Opus single pass). Three flat glossy watermelon seeds (dark brown-black teardrops with a
-- raised paler margin, a hilum notch at the pointed end and one wet specular) on a torn scrap of deeply lobed
-- watermelon leaf (two lobes, V-fold, pale midrib, angled veins, serrated margin, cool reflected light, AO and contact
-- shadow under each seed). The middle seed has sprouted: a pale, slightly pink hypocotyl hook, two smooth oval seed
-- leaves and, between them, the first true leaf already showing the melon's three-lobed shape.
-- History: replaces the Sonnet draft (four seeds on a blob leaf).
-- quirk: the empty seed coat still sits on the tip of the left seed leaf like a little helmet.
local NAME = "watermelon-seed"
local W = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_wm.lua")
local HP, X, c, P = W.new(NAME)
local K = W.K
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi

local SEED = { "#120b12", "#1f1418", "#2e1e20", "#3f2a28", "#5a3e34", "#86644c" }
local MARGIN = { "#3a2822", "#6a4c38", "#9a7856" }
local SPEC = "#f4ead6"
local COT = { "#2c5e3e", "#3f7d45", "#5e9e4e", "#84bd5c", "#aed674", "#d6ec9c" }
local HYPO = { "#7e8a5a", "#a9b878", "#d2dd9c", "#e8c2b0" }

-- seeds: cx, cy, length r, width r, angle (towards point)
local seeds = { { 20, 51, 4.6, 3.2, -0.5 }, { 31, 49, 4.6, 3.2, 0.35 }, { 44, 46, 4.4, 3.0, -1.0 } }
for _, s in ipairs(seeds) do
  s.m = W.drop(s[1], s[2], s[3], s[4], s[5], 0.4)
  s.n = X.pillow(s.m, 2.6)
end

-- leaf scrap: two lobes from a torn base on the lower left
local bias = {}
local all = HP.mask()
for _, s in ipairs(seeds) do all:add(s.m) end
-- precompute lobe masks for AO by painting twice: first pass masks, then tone with bias
local lt = { r = { name = "leaf" } }
local lobeA = { 9, 55, 33, 51, 57, 45, 6.4, { veins = { 6, 12, 18, 24, 30, 36, 42 }, tok = lt, lob = 3, lamp = 0.42, bias = bias } }
local lobeB = { 9, 55, 9, 46, 15, 37, 4.0, { veins = { 5, 10, 15 }, tok = lt, lob = 2, lamp = 0.35, bias = bias } }
-- AO/contact shadow need the lobe mask: build a coarse union first
local lm = HP.mask()
for _, L in ipairs{ lobeA, lobeB } do
  local m = W.blade(L[1], L[2], L[3], L[4], L[5], L[6], function(t) if t > 0.985 then return -1 end return max(0.45, L[7] * sin(pi * min(1, t * 0.95 + 0.05) ^ 1.1) ^ 0.75) end)
  lm:add(m)
end
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) W.cast(bias, lm, s.m, 1, 2, -1) W.cast(bias, lm, s.m, 2, 2, -1) end
W.lobe(c, table.unpack(lobeB))
W.lobe(c, table.unpack(lobeA))
-- torn base: ragged bite out of the stem end
for _, p in ipairs{ { 9, 55 }, { 10, 56 }, { 8, 56 }, { 9, 56 } } do c.pix[p[2] * 64 + p[1]] = nil c.own[p[2] * 64 + p[1]] = nil end

-- sprout from the middle seed: hypocotyl hook up to the seed leaves
local stemPts = { { 32, 47 }, { 33, 44 }, { 34, 40 }, { 34, 35 }, { 33, 31 }, { 32, 28 } }
local hm = HP.line(stemPts, 2)
local hn = X.pillow(hm, 1.2)
W.toneN(c, hm, hn, { HYPO[1], HYPO[2], HYPO[3] }, { cuts = { 0.35, 0.7 } })
c:put(33, 45, HYPO[4]) c:put(34, 43, HYPO[4])                       -- blush near the soil end
-- seed leaves (cotyledons): smooth ovals on short petioles
local function cot(cx, cy, ang, tok)
  local m, n = W.oval(cx, cy, 6.6, 3.2, ang, 0.7)
  local idx = W.toneN(c, m, n, COT, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.1, tok = tok })
  -- midrib: faint, along the long axis
  local ca, sa = cos(ang), sin(ang)
  for i = -4, 4 do
    local x, y = floor(cx + ca * i + .5), floor(cy + sa * i + .5)
    if m:has(x, y) then c:put(x, y, COT[max(1, idx[K(x, y)] - 1)], tok) end
  end
  return m, n, idx
end
local cl, cln = cot(25, 26, 0.3, { r = { name = "cotL" } })
local cr, crn = cot(39, 25, -0.3, { r = { name = "cotR" } })
for _, p in ipairs{ { 31, 28 }, { 31, 27 }, { 33, 27 }, { 32, 27 } } do c:put(p[1], p[2], HYPO[2]) end
-- first true leaf: three small lobes rising between the seed leaves
local tl = { r = { name = "true" } }
local TL = { "#143430", "#1b4a3c", "#256342", "#367f48", "#4f9a4f", "#74b45c" }
local t1 = W.lobe(c, 32, 26, 29, 21, 25, 18, 2.3, { tok = tl, nocool = true, ramp = TL })
local t2 = W.lobe(c, 32, 26, 35, 21, 39, 18, 2.3, { tok = tl, nocool = true, ramp = TL })
local t3 = W.lobe(c, 32, 26, 32, 19, 32, 11, 3.0, { tok = tl, veins = { 5 }, ramp = TL })
local tm = t1:copy():add(t2):add(t3)
cl:copy():add(cr):each(function(x, y)              -- seam: seed-leaf pixels touching the true leaf go deep
  if not tm:has(x, y) and (tm:has(x + 1, y) or tm:has(x - 1, y) or tm:has(x, y + 1) or tm:has(x, y - 1)) then c:put(x, y, COT[1]) end end)
-- AO where the leaves meet the stem top
c:put(32, 26, W.LEAF[1]) c:put(31, 26, W.LEAF[2])

-- seeds on top of the leaf
local function drawSeed(s, i)
  local tok = { r = { name = "seed" .. i } }
  local idx = W.toneN(c, s.m, s.n, SEED, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.05, wrap = 0.15, tok = tok })
  -- raised margin: inner ring one step lighter on the lit side, darker on the shade side
  local ring = s.m:shrink(1):edge()
  ring:each(function(x, y) local nn = s.n[K(x, y)] local d = nn[1] + nn[2]
    if d < -0.15 then c:put(x, y, MARGIN[3], tok) elseif d < 0.15 then c:put(x, y, MARGIN[2], tok) end end)
  s.m:edge():each(function(x, y) local nn = s.n[K(x, y)]
    if nn[1] + nn[2] > 0.2 then c:put(x, y, SEED[1], tok) else c:put(x, y, MARGIN[1], tok) end end)
  -- hilum notch at the point
  local ca, sa = cos(s[5]), sin(s[5])
  local hx, hy = floor(s[1] + ca * (s[3] - 0.6) + .5), floor(s[2] + sa * (s[3] - 0.6) + .5)
  if s.m:has(hx, hy) then c:put(hx, hy, SEED[2], tok) end
  local bx, by = W.specAt(s.m:shrink(1), s.n, 30)
  if bx then c:put(bx, by, SPEC, tok) c:put(bx + 1, by, SEED[6], tok) end
end
for i, s in ipairs(seeds) do if i ~= 2 then drawSeed(s, i) end end
drawSeed(seeds[2], 2)
-- split seed coat at the sprout's base: the hypocotyl pokes out of the middle seed's point
c:put(31, 48, HYPO[2]) c:put(32, 47, HYPO[3])

-- quirk: empty seed coat perched on the tip of the left seed leaf
local cap = W.drop(18.6, 22.6, 3.0, 2.2, -2.5, 0.4)
local capn = X.pillow(cap, 1.8)
local ctok = { r = { name = "cap" } }
W.toneN(c, cap, capn, SEED, { cuts = { 0.22, 0.4, 0.58, 0.76, 0.9 }, amb = 0.05, tok = ctok })
cap:edge():each(function(x, y) local nn = capn[K(x, y)] if nn[1] + nn[2] < -0.2 then c:put(x, y, MARGIN[2], ctok) end end)
local sx, sy = W.specAt(cap:shrink(1), capn, 30)
if sx then c:put(sx, sy, SPEC, ctok) end

-- centre the drawing in the canvas
local x0, y0, x1, y1 = 99, 99, -1, -1
for k in pairs(c.pix) do local x, y = k % 64, k // 64 x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
local dx, dy = floor((63 - (x1 + x0)) / 2 + .5), floor((63 - (y1 + y0)) / 2 + .5)
local np, no = {}, {}
for k, v in pairs(c.pix) do np[(k // 64 + dy) * 64 + k % 64 + dx] = v no[(k // 64 + dy) * 64 + k % 64 + dx] = c.own[k] end
c.pix, c.own = np, no
W.save(c, NAME)
