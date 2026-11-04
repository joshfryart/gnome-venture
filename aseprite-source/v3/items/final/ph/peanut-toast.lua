-- peanut-toast (final pass, Opus, aC32_5). One slice of toast standing as a slab: domed bread top with two shoulders,
-- a 3 px crust thickness showing on the lower right (AO at the fold), bevelled golden-brown crust ring, toasted crumb with
-- pores, a glossy peanut-butter spread with wavy edge and diagonal knife ridges (lit crest + shade trough), chopped
-- roasted peanut bits, one specular. A bite out of the top right corner exposes pale crumb and tooth scallops.
-- quirk: a fat drip of peanut butter has slid over the left crust edge.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("peanut-toast")

local CRUST = { "#3e2018", "#62341e", "#8a4e24", "#ae6c2e", "#c88a3c", "#e0aa54" }
local SIDE  = { "#3a1e18", "#5a301e", "#7a4626", "#9a5e30" }
local CRUMB = { "#a86e2e", "#c88c3e", "#deaa56", "#eec476", "#f8da98", "#fff0c4" }
local RAW   = { "#c8a46a", "#e2c48a", "#f2dcaa", "#fdf0d0" }
local PB    = { "#4e2a14", "#76421e", "#a0622c", "#c4843c", "#dea454", "#f2c87a" }
local NUT   = { "#6a4424", "#a07040", "#d4a86a", "#f2d6a0" }
local SPEC  = "#fff6dc"

-- slice face: rounded rect + two domed shoulders
local face = HP.mask():add(c:rrect(15, 20, 44, 52, 3)):add(c:ellipse(22, 19, 7.5, 6)):add(c:ellipse(37, 19, 7.5, 6))
  :add(c:rect(17, 17, 42, 22))
-- bite: three tooth scallops at the top right shoulder
local bite = HP.mask():add(c:ellipse(45, 21, 5, 5)):add(c:ellipse(42, 14.5, 3.5, 3)):add(c:ellipse(47.5, 28, 3, 3))
-- slab thickness: face shifted down-right
local slab = face:shift(3, 3)
slab:cut(bite:shift(1, 1)):cut(face:copy():cut(bite))
face:cut(bite)

-- side (crust thickness), darker, with AO row along the fold
local stok = { r = { name = "side" } }
slab:each(function(x, y)
  local i = 3
  if not face:has(x - 1, y - 1) then i = 4 end
  if face:has(x - 1, y) or face:has(x, y - 1) then i = 2 end
  if y > 50 or x > 45 then i = i - 1 end
  c:put(x, y, SIDE[max(1, i)], stok)
end)

-- crust ring (bevelled) + toasted crumb interior
local ftok = { r = { name = "face" } }
A.shade(c, face, X.pillow(face, 2.5), CRUST, { tok = ftok, amb = 0.12, wrap = 0.3 })
local crumb = face:shrink(2)
local fullCrumb = crumb:copy()
local ci = A.shade(c, crumb, X.pillow(crumb, 2), CRUMB, { tok = ftok, amb = 0.25, wrap = 0.4 })
crumb:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 21) > 0.9 then c:put(x, y, CRUMB[max(1, ci[k] - 2)], ftok)
    if crumb:has(x - 1, y - 1) then c:put(x - 1, y - 1, CRUMB[min(6, ci[k] + 1)], ftok) end end
end)
-- bite edge: pale untoasted crumb + pores, crust cut through
local bring = bite:grow(1):cut(bite):clip(face)
bring:each(function(x, y)
  local onCrust = not fullCrumb:has(x, y)
  c:put(x, y, onCrust and CRUST[2] or RAW[(X.hash(x, y, 5) > 0.75) and 1 or ((x + y) % 2 == 0 and 3 or 2)], ftok)
end)
bite:grow(2):cut(bite):cut(bring):clip(fullCrumb):each(function(x, y) c:put(x, y, X.hash(x, y, 6) > 0.7 and RAW[1] or RAW[2], ftok) end)

-- peanut butter spread: wavy edge inside the crust, kept off the bite
local pb = HP.mask()
fullCrumb:each(function(x, y)
  local e = 2 + floor(1.5 + 1.4 * sin(x * 0.7) + 1.2 * sin(y * 0.55 + 1))
  local ok = true
  for d = 1, e do if not fullCrumb:has(x - d, y) or not fullCrumb:has(x + d, y) or not fullCrumb:has(x, y - d) or not fullCrumb:has(x, y + d) then ok = false break end end
  if ok then pb:set(x, y) end
end)
pb:cut(bite:grow(3))
-- drip over the left crust edge (quirk)
local drip = HP.mask():add(c:rect(13, 30, 17, 34)):add(c:rrect(13, 33, 16, 39, 1)):add(c:ellipse(14.5, 40, 1.6, 1.6))
drip:add(c:rect(16, 29, 19, 35))
pb:add(drip)
local ptok = { r = { name = "pb" } }
local pn = X.pillow(pb, 3)
-- knife ridges: diagonal crests across the spread bend the normals
for k, nn in pairs(pn) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  if x > 18 then
    local ph = (x * 0.42 + y) / 5.5
    local s = sin(ph * 2 * pi)
    nn[1], nn[2], nn[3] = A.norm(nn[1] + 0.25 * s, nn[2] + 0.55 * s, nn[3])
  end
end
local pi_, pv = A.shade(c, pb, pn, PB, { tok = ptok, amb = 0.1, wrap = 0.3 })
-- shade under the drip where it hangs over the crust/side
drip:shift(1, 1):each(function(x, y) if face:has(x, y) and not pb:has(x, y) then c:put(x, y, CRUST[1], ftok) end end)
-- chopped roasted peanut bits on the spread
for _, p in ipairs{ {24, 27}, {33, 31}, {27, 40}, {37, 44}, {22, 47}, {35, 24} } do
  local x, y = p[1], p[2]
  if pb:has(x, y) and pb:has(x + 1, y + 1) then
    c:put(x, y, NUT[4], ptok) c:put(x + 1, y, NUT[3], ptok) c:put(x, y + 1, NUT[3], ptok) c:put(x + 1, y + 1, NUT[2], ptok)
    if pb:has(x + 2, y + 1) then c:put(x + 2, y + 1, PB[1], ptok) end
    if pb:has(x + 1, y + 2) then c:put(x + 1, y + 2, PB[1], ptok) end
  end
end
-- specular on the spread + glint on the drip
c:put(21, 23, SPEC, ptok) c:put(22, 23, SPEC, ptok) c:put(21, 24, PB[6], ptok)
c:put(14, 39, PB[6], ptok) c:put(14, 38, SPEC, ptok)
-- two crumbs fallen by the slab
c:px(50, 55, CRUMB[3]) c:px(51, 55, CRUMB[2]) c:px(53, 53, CRUMB[4])
A.save(c, "peanut-toast")
