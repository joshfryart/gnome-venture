-- spotted-pelt (pass B, final; pass A = spotted-pelt.pA). A slim tanned hide laid flat, top-down: tapered neck at the top, four narrow leg flaps
-- splayed out, thin tail. Realism: pillow light on the soft hide + one diagonal fold, darker spine stripe and
-- paler belly edges, short fur strokes running out from the spine, broken rosettes (ring + warmer core).
-- Pass B: deeper ramp + lower ambient (pA was washed out), short soft wrinkle (lit lip + shadow), fur strokes
-- both ways, hand-cut leopard rosettes, hind-right flap tip folded back to show the pale suede back with a contact shadow,
-- re-cut neck (ear points) and toes.
-- quirk: one rosette is a little heart.
local NAME = "spotted-pelt"
local LIB = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local out = app.params.out or "./"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs

local FUR  = { "#4e2232", "#7d3533", "#b0552f", "#d97a35", "#eea24f", "#fbcf7e" }
local SPOT = { "#2f1a24", "#4a2a2c" }
local CORE = "#93402c"
local SUEDE = { "#7e5350", "#b07f6a", "#d7ab8e", "#f0d2b8" }

-- silhouette: hide outline with concave edges between the leg flaps
local m = c:poly{ {27,9},{29,7},{32,9},{35,7},{37,9},{38,12},{39,16},{45,13},{51,11},{53,13},{50,17},{42,22},{41,28},{41,34},{43,39},
  {49,46},{52,52},{49,54},{43,49},{37,45},{34,47},{33,56},{31,56},{30,47},{27,45},{21,49},{15,54},{12,52},{15,46},
  {21,39},{23,34},{23,28},{22,22},{14,17},{11,13},{13,11},{19,13},{25,16},{26,12} }
-- ragged neck edge and toe nicks
for _, p in ipairs{ {12,12},{52,12},{13,53} } do m.s[K(p[1], p[2])] = nil end
-- light: pillow + one fold ridge running diagonally across the body
local n = X.pillow(m, 3.5)
m:each(function(x, y)
  local k = K(x, y)
  local d = (x - 28) * 0.55 + (y - 37) * 0.83         -- distance to the wrinkle line
  local f = (x > 22 and x < 35) and math.exp(-(d * d) / 4) * 0.5 or 0
  local nn = n[k]
  local nx, ny = nn[1] - 0.55 * f * (d > 0 and -1 or 1) * 0.0 + (d < 0 and -0.4 or 0.4) * f, nn[2] + (d < 0 and -0.6 or 0.6) * f
  local l = sqrt(nx * nx + ny * ny + nn[3] * nn[3])
  n[k] = { nx / l, ny / l, nn[3] / l }
end)
local v = X.light(n, { amb = 0.04, wrap = 0.35 })
local bias = {}
local dist = X.dist(m)
local function fold(x, y) return (x - 28) * 0.55 + (y - 37) * 0.83 end
m:each(function(x, y)
  local k = K(x, y)
  if dist[k] < 1 and x + y < 66 then bias[k] = 1 end                 -- pale underfur fringe on the lit edges
  local d = fold(x, y)
  if x > 24 and x < 33 then                                         -- short soft wrinkle, lower-left of the body
    if d > -1.2 and d <= 0 then bias[k] = (bias[k] or 0) + 1 end
    if d > 0.6 and d <= 1.6 then bias[k] = (bias[k] or 0) - 1 end
  end
  -- fur strokes: sparse 2 px dashes running out from the spine, light ones and dark ones
  local dir = x < 32 and -1 or 1
  local h = X.hash(x, y, 5)
  if (h > 0.9 or h < 0.05) and m:has(x + dir, y + 1) and abs(d) > 2 then
    local a = h > 0.9 and 1 or -1
    bias[k] = (bias[k] or 0) + a bias[K(x + dir, y + 1)] = (bias[K(x + dir, y + 1)] or 0) + a end
end)
X.tone(c, m, v, FUR, { bias = bias, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = { r = { name = "fur" } } })

-- rosettes: hand-cut broken rings (a dark, b deep) around a darker-orange core (c)
local ROS = {
  { ".aab..", "a.cc.b", "bcccc.", "acccca", ".cc..b", "..bba." },
  { "..aa..", ".bccb.", "acc.ca", "bcccc.", ".a.cb.", "..bb.." },
  { ".ab.", "acca", "bcc.", ".ab." },
}
local map = { a = SPOT[2], b = SPOT[1], c = CORE }
local function ros(i, x, y)
  for r, row in ipairs(ROS[i]) do for col = 1, #row do
    local ch = row:sub(col, col)
    if map[ch] and m:has(x + col - 1, y + r - 1) then c:put(x + col - 1, y + r - 1, map[ch]) end
  end end
end
local function dot(x, y) c:put(x, y, SPOT[2]) c:put(x + 1, y, SPOT[1]) c:put(x, y + 1, SPOT[1]) c:put(x + 1, y + 1, SPOT[1]) end
ros(1, 25, 17) ros(2, 34, 21) ros(3, 25, 27) ros(2, 32, 39) ros(3, 25, 41) ros(3, 31, 10)
dot(17, 14) dot(46, 14) dot(19, 46) dot(42, 44) dot(31, 50) dot(30, 34) dot(14, 50)
-- quirk: heart rosette
c:paint({ ".ab.ba.", "accacca", "acccccb", ".acccb.", "..aca..", "...b..." }, 33, 30, { a = SPOT[1], b = SPOT[2], c = CORE })

-- hind-right flap tip folds back over itself: pale suede underside on top, contact shadow along its edge
local FL = 97                                                        -- fold line x + y = FL
local tip, back = HP.mask(), HP.mask()
m:each(function(x, y) if x + y > FL and x > 40 then tip:set(x, y) end end)
tip:each(function(x, y) back:set(FL - y, FL - x) end)
tip:each(function(x, y) c.pix[y * 64 + x], c.own[y * 64 + x] = nil, nil end)
m:cut(tip)
back:clip(m)
back:shift(1, 1):clip(m):cut(back):each(function(x, y) c:put(x, y, FUR[1]) end)   -- contact shadow
back:each(function(x, y)
  local i = 3
  if x + y >= FL - 1 then i = 4 end                                 -- rolled crease catches the light
  if not back:has(x + 1, y) or not back:has(x, y + 1) then i = 2 end
  if X.hash(x, y, 11) > 0.8 and i == 3 then i = 2 end                -- suede nap
  c:put(x, y, SUEDE[i])
end)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png" }
