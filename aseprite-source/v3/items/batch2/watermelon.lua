-- watermelon (batch2, Opus single pass). Slim oblong picnic melon lying on a gentle diagonal (rising to the right),
-- light green skin with jagged dark-green stripes that run stem to blossom end and converge at both ends.
-- Material: per-pixel ellipsoid light on two 6-tone greens (stripes share the light index), waxy bloom specks,
-- one 2x1 specular, cool reflected light on the lower-right rim, a pale yellow field spot on the underside,
-- AO where the stem meets the rind. Woody stem with a short corky ring, a curly tendril and one deeply lobed leaf.
-- History: replaces the Sonnet draft (round melon with a wedge).
-- quirk: a little triangular tasting plug has been cut from the top, showing red flesh and a seed.
local NAME = "watermelon"
local W = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_wm.lua")
local HP, X, c, P = W.new(NAME)
local K = W.K
local floor, sqrt, max, min, abs, sin, cos, pi, asin = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.asin

local SKIN  = { "#22513f", "#3a7a4a", "#5a9e55", "#82bf62", "#acd77a", "#d6eca6" }
local DARK  = { "#0c2229", "#11332f", "#174636", "#1f5a3c", "#2b7043", "#3f874b" }
local SPOT  = { "#8f8a46", "#b8a957", "#d6c46c", "#e9d98a" }
local RED   = { "#7e1c38", "#b52a43", "#e0434e", "#f56b66", "#ff9a8a" }
local RIND  = { "#b9cf8a", "#e6edc0", "#fbf6dc" }
local STEM  = { "#4a3a24", "#6e5a30", "#937c40", "#b9a35a" }
local BOUNCE = "#5e9aa0"
local SPEC = "#f6fbe2"

-- placement
local CX, CY, RX, RY, ANG = 30, 37, 20.5, 12, -0.32
local ca, sa = cos(ANG), sin(ANG)

-- ground contact shadow (melon lies on the ground)
c:groundShadow(31, 50, 16, 1.4)

-- leaf behind, up off the stem end (three deep lobes, watermelon style)
local lb = { 47, 24 }
local lt = { r = { name = "leaf" } }
W.lobe(c, lb[1], lb[2], 43, 20, 37, 18, 3.4, { veins = { 3, 6 }, tok = lt, lob = 2 })
W.lobe(c, lb[1], lb[2], 54, 19, 57, 13, 3.2, { veins = { 3, 6 }, tok = lt, lob = 2 })
W.lobe(c, lb[1], lb[2], 46, 16, 48, 9, 3.8, { veins = { 3, 6, 9 }, tok = lt, lob = 2.5 })

-- melon body
local m, n = W.oval(CX, CY, RX, RY, ANG, 0.72)
local bias = {}
local ul = {}
m:each(function(x, y)
  local dx, dy = x - CX, y - CY
  ul[K(x, y)] = { (dx * ca + dy * sa) / (RX + .45), (-dx * sa + dy * ca) / (RY + .45) }
end)
local cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local idx = W.toneN(c, m, n, SKIN, { cuts = cuts, amb = 0.07, wrap = 0.22, bias = bias })
-- stripes: longitude lines with jagged edges
m:each(function(x, y) local k = K(x, y)
  local u, v = ul[k][1], ul[k][2]
  local q = sqrt(max(1 - u * u, 0.04))
  local phi = asin(max(-1, min(1, v / q)))
  local z = u * RX / 4.2
  local tri = abs(z - floor(z) - 0.5) * 2 - 0.5
  local p = phi / pi * 4.6 + 0.3 + 0.22 * tri
  local f = p - floor(p)
  if f < 0.5 and abs(u) < 0.96 then c:put(x, y, DARK[idx[k]]) end
end)
-- field spot on the underside (pale, blotchy)
m:each(function(x, y) local k = K(x, y)
  local u, v = ul[k][1], ul[k][2]
  local d = ((u + 0.12) / 0.42) ^ 2 + ((v - 0.95) / 0.32) ^ 2
  if d < 1 and X.hash(x, y, 7) > 0.18 * d then c:put(x, y, SPOT[max(1, min(4, idx[k] - 1))]) end
end)
-- waxy bloom specks on the lit upper-left
m:shrink(2):each(function(x, y) local k = K(x, y)
  if idx[k] >= 4 and c:get(x, y) == SKIN[idx[k]] and X.hash(x, y, 3) > 0.93 then c:put(x, y, idx[k] >= 5 and SKIN[6] or SKIN[5]) end
end)
-- cool reflected light on the lower-right rim
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.72 and ul[k][2] > 0.1 and ul[k][1] > -0.2 then c:put(x, y, BOUNCE) end end)
-- specular 2x1 + glint
c:put(16, 33, SPEC) c:put(17, 33, SPEC) c:put(15, 34, SKIN[6])

-- quirk: triangular tasting plug cut from the top
local plug = HP.poly{ { 22, 28.5 }, { 31, 25.5 }, { 27.5, 34.5 } }
plug:clip(m)
plug:each(function(x, y)
  local col = RED[3]
  if not plug:has(x - 1, y) or not plug:has(x, y - 1) then col = RED[1]           -- far wall in shadow
  elseif not plug:has(x - 1, y - 1) then col = RED[2] end
  if not plug:has(x + 1, y) or not plug:has(x, y + 1) then col = RIND[2] end      -- lit near wall: white rind
  c:put(x, y, col)
end)
-- rind lip outside the lit walls (thin green-white)
plug:grow(1):cut(plug):each(function(x, y)
  if m:has(x, y) and (plug:has(x - 1, y) or plug:has(x, y - 1)) then c:put(x, y, RIND[1]) end end)
c:put(26, 28, RED[5]) c:put(27, 28, RED[4]) c:put(26, 29, RED[4])
c:put(27, 30, "#2b1c26") c:put(27, 31, RED[2])                     -- a seed in the flesh

-- stem on the right end: woody, corky ring, AO on the rind under it
local se = { floor(CX + ca * RX + .5) - 1, floor(CY + sa * RX + .5) }
local stem = W.path(c, { { se[1], se[2] }, { se[1] + 1, se[2] - 2 }, { se[1] + 1, se[2] - 4 }, { lb[1] + 1, lb[2] + 1 } }, STEM[3])
W.path(c, { { se[1] + 1, se[2] }, { se[1] + 2, se[2] - 2 }, { se[1] + 2, se[2] - 3 } }, STEM[2])
c:put(se[1], se[2], STEM[1]) c:put(se[1] - 1, se[2] + 1, DARK[1]) c:put(se[1] - 1, se[2], STEM[2])
c:put(se[1] + 1, se[2] - 4, STEM[4])
-- tendril: corkscrew curl off the stem
local tx, ty = se[1] + 2, se[2] - 4
local tp = {}
for _, o in ipairs{ {0,0},{2,-1},{4,-1},{5,-2},{5,-4},{4,-5},{2,-5},{1,-4},{1,-3},{2,-2},{3,-3} } do tp[#tp + 1] = { tx + o[1], ty + o[2] } end
W.path(c, tp, { "#5f9f52", "#6fae5a", "#8cc46a", "#a7d47c", "#a7d47c", "#8cc46a", "#8cc46a", "#6fae5a", "#6fae5a", "#5f9f52" })

-- centre the drawing (bbox incl. 1px outline) in the canvas
local x0, y0, x1, y1 = 99, 99, -1, -1
for k in pairs(c.pix) do local x, y = k % 64, k // 64 x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
local dx, dy = floor((63 - (x1 + x0)) / 2 + .5), floor((63 - (y1 + y0)) / 2 + .5)
local np, no = {}, {}
for k, v in pairs(c.pix) do np[(k // 64 + dy) * 64 + k % 64 + dx] = v no[(k // 64 + dy) * 64 + k % 64 + dx] = c.own[k] end
c.pix, c.own = np, no
W.save(c, NAME)
