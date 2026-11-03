-- ico-brain (final, Opus). Side view: lumpy cerebrum (frontal lobe left), the lateral fissure sweeping up toward
-- the back, a ribbed cerebellum tucked under the rear and a slim brainstem.
-- Material: per-pixel light from a height field (dome + meandering gyri), so every fold is lit upper-left and
-- shaded lower-right; groove pixels dark with a lit lip, wet gloss speculars on the crown, AO where the cerebrum
-- overhangs the cerebellum and stem, cool reflected light on the lower rim. Cerebellum folia as fine stripes.
-- quirk: a little sticking plaster on the crown, as if it had bumped into something.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new("ico-brain")
local PINK = { "#5a1d42", "#8a2d5c", "#bb4c78", "#e07599", "#f5a0b8", "#ffd2dc" }
local STEM = { "#5a2440", "#86405a", "#b46a7c", "#d8949e", "#f0bcc0" }
local BOUNCE = "#9a5a8e"

local CX, CY, RX, RY = 31, 27, 21, 15.5
-- lumpy silhouette, flatter underside of the temporal lobe
local cer = HP.mask()
for y = 6, 50 do for x = 4, 60 do
  local dx, dy = (x - CX) / RX, (y - CY) / RY
  local th = atan(dy, dx)
  local r = 1 + 0.045 * sin(7 * th + 0.6) + 0.03 * sin(11 * th + 2)
  if dy > 0.35 then dy = dy * (1 + (dy - 0.35) * 0.55) end
  if dx * dx + dy * dy <= r * r then cer:set(x, y) end
end end
-- notch under the back where the cerebellum sits
cer:cut(A.ellM(41, 42.5, 8.5, 4.2))

-- cerebellum + stem first (cerebrum overlaps them)
local stem = A.stroke({ { 37, 38 }, { 36, 44 }, { 34.5, 49 } }, 2.4)
local stok = { r = { name = "stem" } }
local sn = X.pillow(stem, 2)
local sbias = {}
X.ao(sbias, stem, cer, 2, -1)
local sidx = A.shade(c, stem, sn, STEM, { tok = stok, bias = sbias, amb = 0.06, wrap = 0.25 })
local cb = A.ellM(44, 40, 8.6, 5.4)
cb:cut(stem:copy():cut(A.ellM(44, 40, 8.6, 5.4)))
local cbtok = { r = { name = "cbm" } }
local cbn = X.pillow(cb, 3)
local cbb = {}
X.ao(cbb, cb, cer, 2, -1)
local cbidx = A.shade(c, cb, cbn, PINK, { tok = cbtok, bias = cbb, amb = 0.05, wrap = 0.25 })
-- folia: curved fine stripes
cb:each(function(x, y) local q = (y - 40) + 0.04 * (x - 44) ^ 2
  if floor(q + 10) % 2 == 0 and cb:has(x, y - 1) then A.step(c, cbidx, PINK, x, y, -1, cbtok) end end)

-- cerebrum height field: dome + gyri
local d = X.dist(cer)
-- sulci drawn as hand-placed meandering grooves; gyri bulge between them
local SUL = {
  { { 13, 36 }, { 20, 33 }, { 27, 31 }, { 33, 28 }, { 39, 27 } },           -- lateral fissure
  { { 33, 12 }, { 31, 17 }, { 34, 21 }, { 32, 26 } },                       -- central sulcus
  { { 13, 22 }, { 18, 20 }, { 22, 24 }, { 27, 21 }, { 28, 15 } },
  { { 11, 29 }, { 16, 26 }, { 21, 29 }, { 27, 26 } },
  { { 19, 12 }, { 22, 16 }, { 25, 13 } },
  { { 37, 13 }, { 39, 18 }, { 44, 17 }, { 48, 21 } },
  { { 36, 22 }, { 40, 24 }, { 45, 23 }, { 51, 28 } },
  { { 41, 29 }, { 45, 32 }, { 50, 31 } },
  { { 17, 40 }, { 23, 37 }, { 28, 39 }, { 34, 35 } },
  { { 37, 32 }, { 40, 36 } },
}
local fis = A.stroke(SUL[1], 0.7)
local cen = A.stroke(SUL[2], 0.55)
local grooves = HP.mask()
for i, l in ipairs(SUL) do A.stroke(l, i == 1 and 0.7 or 0.5, grooves) end
grooves:clip(cer:shrink(1))
local dg = X.dist(cer:copy():cut(grooves))
local G2 = {}
cer:each(function(x, y) local k = K(x, y) G2[k] = grooves:has(x, y) and 0 or min(1, (dg[k] or 0) / 2.2) end)
local function H(x, y)
  local v = d[K(x, y)]
  if not v then return 0 end
  local R = 7
  local t = min(v + 0.5, R) / R
  local dome = R * sqrt(1 - (1 - t) ^ 2)
  local g = G2[K(x, y)]
  return dome + 2.2 * sqrt(g)
end
local n = {}
cer:each(function(x, y)
  local gx = (H(x + 1, y) - H(x - 1, y)) / 2
  local gy = (H(x, y + 1) - H(x, y - 1)) / 2
  n[K(x, y)] = { A.norm(-gx, -gy, 1.1) }
end)
local bias = {}
local ctok = { r = { name = "cerebrum" } }
local idx = A.shade(c, cer, n, PINK, { tok = ctok, amb = 0.1, wrap = 0.3, cuts = { 0.14, 0.32, 0.5, 0.68, 0.86 } })
-- grooves: darkest at the bottom of each fold
cer:each(function(x, y) local k = K(x, y)
  if fis:has(x, y) and grooves:has(x, y) then A.step(c, idx, PINK, x, y, -3, ctok)
  elseif grooves:has(x, y) then A.step(c, idx, PINK, x, y, -2, ctok) end end)
-- overall form: lower-right of the cerebrum one step darker (shade side), crown kept
cer:each(function(x, y) local k = K(x, y)
  local dx, dy = (x - CX) / RX, (y - CY) / RY
  if dx * 0.5 + dy > 0.62 then A.step(c, idx, PINK, x, y, -1, ctok) end end)
-- cool bounce on the lower rim
cer:each(function(x, y) if not cer:has(x, y + 1) and not cer:has(x + 1, y + 1) and x < 34 and x > 15 then c:put(x, y, BOUNCE, ctok) end end)
-- wet gloss: brightest gyri tops on the crown get the hi; one cream glint
local sp = X.spec(n, 30)
cer:each(function(x, y) local k = K(x, y)
  if sp[k] > 0.5 and y < 26 and x < 34 and G2[k] > 0.8 then c:put(x, y, PINK[6], ctok) end end)
c:put(19, 17, A.SPEC, ctok) c:put(20, 17, PINK[6], ctok)

-- quirk: sticking plaster on the crown (diagonal, two dotted pads)
A.map(c, {
  "......pP.",
  ".....PPPp",
  "...qQqPPs",
  ".pPqQqs..",
  "pPPPs....",
  "pPPs.....",
  ".ss......",
}, 37, 11, { P = "#f2d6b0", p = "#d8b088", q = "#e4c098", Q = "#c99a72", s = "#b48866" }, ctok)

A.save(c, "ico-brain")
