-- ico-lightning (final, Opus). A slim three-stroke lightning bolt leaning on the diagonal: a tapered top bar, a
-- sharp step notch and a long blade that narrows to a needle tip, lower-left.
-- Material: per-pixel lit enamel-gold (6 tones, cool-violet shade side lower-right), a rounded bevel from the
-- distance field, a raised bright energy core running down the spine, a specular streak on the upper-left bevel,
-- cool reflected light on the lower-right rim and AO in the inside corners of the notch.
-- quirk: one stray spark has jumped off the tip and fizzes beside it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_3.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, abs, floor, max, min = math.sqrt, math.abs, math.floor, math.max, math.min
local c = A.new("ico-lightning")
local GOLD = { "#6e2a2a", "#a8481f", "#db7a1c", "#f5ad22", "#ffd447", "#fff09a" }
local SPEC, CORE, BOUNCE = "#fffbe0", "#fff7c4", "#c0607a"
local tok = { r = { name = "bolt" } }

local outline = {
  { 33.5, 7 }, { 47.5, 7 },          -- top bar
  { 38.5, 25.5 }, { 46.5, 25 },      -- right notch shoulder
  { 19, 58 },                        -- tip
  { 27.5, 35 }, { 19.5, 35.5 },      -- left notch shoulder
}
local m = c:poly(outline)
local n, d = X.pillow(m, 3.2)
local bias = {}
-- AO in the two inside corners of the notch
local corners = { { 38.5, 25.5 }, { 27.5, 35 } }
m:each(function(x, y)
  for _, q in ipairs(corners) do
    local dd = sqrt((x + .5 - q[1])^2 + (y + .5 - q[2])^2)
    if dd < 2.6 then bias[K(x, y)] = (bias[K(x, y)] or 0) - 1 end
  end
end)
local idx = A.shade(c, m, n, GOLD, { amb = 0.1, wrap = 0.3, bias = bias, tok = tok, cuts = { 0.25, 0.42, 0.58, 0.72, 0.86 } })

-- spine: polyline through the middle of the bolt; raised energy core = 1 px bright line with a lit lip
local spine = { { 40.5, 9 }, { 33, 27.5 }, { 33.5, 31 }, { 22, 54 } }
local function segd(px, py, a, b)
  local vx, vy = b[1] - a[1], b[2] - a[2]
  local t = max(0, min(1, ((px - a[1]) * vx + (py - a[2]) * vy) / (vx * vx + vy * vy)))
  local qx, qy = a[1] + vx * t - px, a[2] + vy * t - py
  return sqrt(qx * qx + qy * qy), vx * (py - a[2]) - vy * (px - a[1])
end
m:each(function(x, y)
  local best, side = 1e9, 0
  for i = 1, #spine - 1 do
    local dd, s = segd(x + .5, y + .5, spine[i], spine[i + 1])
    if dd < best then best, side = dd, s end
  end
  local k = K(x, y)
  if best < 0.75 and d[k] > 1.8 then c:put(x, y, CORE, tok)
  elseif best < 1.7 and side > 0 and d[k] > 1.5 then A.step(c, idx, GOLD, x, y, 1, tok)   -- lit lip (left of spine)
  elseif side < 0 and d[k] > 0.9 then A.step(c, idx, GOLD, x, y, best < 1.9 and -2 or -1, tok) end -- shade facet (right), groove by the core
end)

-- specular streak on the upper-left bevel of the top bar + glint
for _, p in ipairs{ { 35, 9 }, { 36, 9 }, { 37, 9 }, { 34, 11 }, { 34, 10 } } do c:put(p[1], p[2], GOLD[6], tok) end
c:put(35, 9, SPEC, tok) c:put(36, 9, SPEC, tok)
-- cool reflected light on the lower-right rim of the blade
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.55 and y > 30 and y < 52 and x > 24 then c:put(x, y, BOUNCE, tok) end end)

-- quirk: a stray spark beside the tip (tiny zig, ink-outlined by finish)
local stok = { r = { name = "spark" } }
for _, p in ipairs{ { 37, 44, GOLD[6] }, { 38, 44, GOLD[6] }, { 36, 45, GOLD[6] }, { 37, 45, GOLD[5] }, { 35, 46, GOLD[5] }, { 36, 46, GOLD[5] },
                    { 37, 46, GOLD[5] }, { 38, 46, GOLD[5] }, { 37, 47, GOLD[4] }, { 36, 48, GOLD[4] }, { 37, 48, GOLD[4] }, { 35, 49, GOLD[3] }, { 36, 49, GOLD[3] } } do c:put(p[1], p[2], p[3], stok) end
A.save(c, "ico-lightning")
