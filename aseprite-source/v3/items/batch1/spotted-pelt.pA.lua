-- spotted-pelt (pass A). A slim tanned hide laid flat, top-down: tapered neck at the top, four narrow leg flaps
-- splayed out, thin tail. Realism: pillow light on the soft hide + one diagonal fold, darker spine stripe and
-- paler belly edges, short fur strokes running out from the spine, broken rosettes (ring + warmer core).
-- quirk: one rosette is a little heart.
local NAME = "spotted-pelt.pA"
local LIB = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local out = app.params.out or "./"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs

local FUR  = { "#5e2a33", "#8a3f33", "#b8613a", "#d9874a", "#ebab66", "#f7d08e" }
local SPOT = { "#2f1a24", "#4a2a2c" }
local CORE = "#b9592f"

-- silhouette: hide outline with concave edges between the leg flaps
local m = c:poly{ {28,8},{36,8},{38,12},{39,16},{45,13},{51,11},{53,13},{50,17},{42,22},{41,28},{41,34},{43,39},
  {49,46},{52,52},{49,54},{43,49},{37,45},{34,47},{33,56},{31,56},{30,47},{27,45},{21,49},{15,54},{12,52},{15,46},
  {21,39},{23,34},{23,28},{22,22},{14,17},{11,13},{13,11},{19,13},{25,16},{26,12} }
-- ragged neck edge and toe nicks
for _, p in ipairs{ {30,8},{33,8},{12,12},{52,12},{13,53},{51,53} } do m.s[K(p[1], p[2])] = nil end
-- light: pillow + one fold ridge running diagonally across the body
local n = X.pillow(m, 3.5)
m:each(function(x, y)
  local k = K(x, y)
  local d = (x - 32) * 0.55 + (y - 30) * 0.83         -- distance to the fold line
  local f = math.exp(-(d * d) / 6) * 0.7
  local nn = n[k]
  local nx, ny = nn[1] - 0.55 * f * (d > 0 and -1 or 1) * 0.0 + (d < 0 and -0.4 or 0.4) * f, nn[2] + (d < 0 and -0.6 or 0.6) * f
  local l = sqrt(nx * nx + ny * ny + nn[3] * nn[3])
  n[k] = { nx / l, ny / l, nn[3] / l }
end)
local v = X.light(n, { amb = 0.18, wrap = 0.3 })
local bias = {}
local dist = X.dist(m)
m:each(function(x, y)
  local k = K(x, y)
  if dist[k] < 1 then bias[k] = 1 end                                -- pale underfur fringe
  -- fur strokes: sparse 2 px dashes running out from the spine
  local dir = x < 32 and -1 or 1
  if X.hash(x, y, 5) > 0.88 and m:has(x + dir, y + 1) then
    bias[k] = (bias[k] or 0) + 1 bias[K(x + dir, y + 1)] = (bias[K(x + dir, y + 1)] or 0) + 1 end
end)
X.tone(c, m, v, FUR, { bias = bias, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = { r = { name = "fur" } } })

-- rosettes: broken dark ring + warmer core; small solid spots on the legs
local function rosette(cx, cy, r)
  local ring = c:ellipse(cx, cy, r, r):clip(m)
  local core = c:ellipse(cx, cy, r - 1, r - 1)
  ring:each(function(x, y)
    if core:has(x, y) then c:put(x, y, CORE)
    else
      local a = math.atan(y - cy, x - cx)
      if math.sin(a * 2 + cx) > -0.6 then c:put(x, y, (x + y > cx + cy) and SPOT[1] or SPOT[2]) end
    end
  end)
end
local function dot(x, y) c:put(x, y, SPOT[2]) c:put(x + 1, y, SPOT[1]) c:put(x, y + 1, SPOT[1]) end
rosette(28, 22, 2.5) rosette(37, 27, 2.5) rosette(29, 32, 2.5) rosette(32, 14, 1.5) rosette(29, 42, 2)
dot(18, 15) dot(46, 15) dot(19, 44) dot(45, 44) dot(26, 46) dot(36, 37) dot(32, 51) dot(38, 18)
-- quirk: heart rosette
c:paint({ "ab.ab", "acaca", ".aca.", "..a.." }, 34, 33, { a = SPOT[1], b = SPOT[2], c = CORE })

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png" }
