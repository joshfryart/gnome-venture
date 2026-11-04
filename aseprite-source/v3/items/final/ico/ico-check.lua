-- ico-check (final, Opus). A bold tick: short stroke down-right into a sharp elbow, long stroke rising to the upper right,
-- rounded ends, glossy green enamel with a raised bevel.
-- Material: pillow bevel (R 3) per-pixel light snapped to 6 greens, a flat inset face, bright lit bevel edge upper-left,
-- long specular streak on the rising stroke + one glint, cool reflected light along the lower-right edge, AO in the
-- inner crook of the elbow.
-- quirk: the fresh paint is still wet: one fat drip runs off the underside of the long stroke and hangs below it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA2_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt = math.floor, math.max, math.min, math.sqrt
local c = A.new("ico-check")
local GR = { "#123f38", "#1d5c42", "#2a7c48", "#3f9d4e", "#68c05a", "#a6e07c", "#e0f7b0" }
local BOUNCE = "#4fa6a0"
local SPEC = "#fff4d6"

local P1, P2, P3 = { 12, 33 }, { 25, 46 }, { 51, 16 }
local m = A.stroke({ P1, P2, P3 }, 4.4)
-- drip: a thin run from under the elbow ending in a round drop
local drip = A.stroke({ { 40, 34 }, { 40, 40 } }, 1.1):add(A.ell(40, 42.5, 1.9, 2.1))
m:add(drip)
local tok = A.tok("tick")
local n, d = X.pillow(m, 3.2)
local bias = {}
-- AO in the inner crook (upper side of the elbow)
local crook = A.ell(25, 39, 3.5, 3)
crook:each(function(x, y) if m:has(x, y) then local k = K(x, y) bias[k] = (bias[k] or 0) - 1 end end)
local idx = A.shade(c, m, n, GR, { tok = tok, bias = bias, amb = 0.04, wrap = 0.2, cuts = { 0.3, 0.46, 0.6, 0.73, 0.86, 0.97 } })
-- lit bevel lip on the upper-left edges
m:edge():each(function(x, y)
  local k = K(x, y)
  local nn = n[k]
  if nn and nn[1] * X.L[1] + nn[2] * X.L[2] > 0.62 then c:put(x, y, GR[6], tok) end
end)
-- cool reflected light on the lower-right edge of the long stroke
m:edge():each(function(x, y)
  local nn = n[K(x, y)]
  if nn and nn[1] > 0.35 and nn[2] > 0.35 and x > 28 and x < 50 then c:put(x, y, BOUNCE, tok) end
end)
-- specular streak along the rising stroke (offset to the lit side)
for t = 0.18, 0.72, 0.04 do
  local x = P2[1] + (P3[1] - P2[1]) * t - 1.6
  local y = P2[2] + (P3[2] - P2[2]) * t - 1.6
  c:put(floor(x + .5), floor(y + .5), GR[7], tok)
end
c:put(floor(P2[1] + 26 * 0.76 - 1.1), floor(P2[2] - 30 * 0.76 - 1.1), SPEC, tok)
c:put(floor(P2[1] + 26 * 0.76 - 0.1), floor(P2[2] - 30 * 0.76 - 2.1), SPEC, tok)
-- short stroke: small 2px highlight
c:put(14, 31, GR[7], tok) c:put(15, 31, GR[7], tok)
-- drip: glossy drop
c:put(39, 42, GR[6], tok) c:put(39, 41, SPEC, tok) c:put(41, 44, GR[2], tok)
A.save(c, "ico-check")
