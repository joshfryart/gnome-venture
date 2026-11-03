-- ico-pencil (final, Opus single pass). Slim hexagonal pencil on the diagonal, tip lower-left, eraser upper-right.
-- Parts: graphite point with a glint, sharpened cedar cone with grain and the scalloped paint line where the
-- facets were cut, three flat yellow facets (lit / top with a specular streak / shade, dark ridge between them,
-- cool bounce on the far edge), crimped tin ferrule (grooved rings, lit lip, bright specular, AO onto the
-- paint), rounded pink eraser.
-- quirk: someone has been chewing it: two little tooth dents near the ferrule, bare wood showing.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = A.new("ico-pencil")
local YEL  = { "#7a3d22", "#bb6a1e", "#e3931f", "#f5b82e", "#ffd65e", "#fff0a6" }
local WOOD = { "#5a3428", "#8a5636", "#b67e4e", "#d8a46e", "#eec691", "#fbe3b6" }
local LEAD = { "#35344a", "#4c4c64", "#6c6d88", "#a3a5bf" }
local TIN  = { "#3f4160", "#64667e", "#8d8fa4", "#b4b4c4", "#d8d8e2", "#f3f1f6" }
local PINK = { "#6e2650", "#a23e6a", "#cf5d86", "#ee86a4", "#ffb2c6", "#ffd8e2" }
local BOUNCE = "#a8706c"

local f, L, ux, uy, px, py = A.axis(11, 53, 53, 11)
local D_LEAD, D_CONE, D_FER, D_ERA, D_END = 5, 15.5, 44, 50.5, 57.5
local function hw(d)
  if d < D_LEAD then return 0.35 + d * 0.27 end
  if d < D_CONE then return 1.7 + (d - D_LEAD) / (D_CONE - D_LEAD) * 2.3 end
  if d < D_FER then return 4.0 end
  if d < D_ERA then return 4.35 end
  return 3.95
end
-- tooth dents (silhouette notches on the lit edge)
local function dent(d, s) return (d - 36.2)^2 + (s + 4.5)^2 < 2.4^2 or (d - 41.4)^2 + (s + 4.5)^2 < 2.4^2 end
local m, Dd, S = HP.mask(), {}, {}
for y = 2, 62 do for x = 2, 62 do
  local t, s = f(x, y)
  local d = t * L
  if d >= -0.3 and d <= D_END then
    local w = hw(d)
    local ok = abs(s) <= w
    if d > D_END - 3.95 then ok = (d - (D_END - 3.95))^2 + s * s <= 3.95^2 + 0.3 end
    if ok and dent(d, s) then ok = false end
    if ok then m:set(x, y) Dd[K(x, y)], S[K(x, y)] = d, s end
  end
end end
local function scallop(s) -- paint boundary distance: each facet bulges toward the tip
  local cs = s < -1.35 and -2.7 or (s > 1.35 and 2.7 or 0)
  local u = (s - cs) / 1.35
  return D_CONE + 0.6 - 2.2 * (1 - min(1, u * u))
end
local L3 = X.L
local function lam(sn, amb)
  local nz = sqrt(max(0, 1 - sn * sn))
  local dl = (px * sn) * L3[1] + (py * sn) * L3[2] + nz * L3[3]
  return max(0, min(1, (amb or 0.08) + 0.92 * max(0, (dl + 0.25) / 1.25)))
end
local function q6(v) return max(1, min(6, floor(v * 6) + 1)) end
local tokY, tokW, tokM, tokE = { r = { name = "paint" } }, { r = { name = "wood" } }, { r = { name = "tin" } }, { r = { name = "eraser" } }
m:each(function(x, y) local k = K(x, y)
  local d, s = Dd[k], S[k]
  local w = hw(d)
  local sn = max(-0.97, min(0.97, s / (w + 0.5)))
  if d < D_LEAD then
    local i = sn < -0.2 and 3 or (sn < 0.45 and 2 or 1)
    c:put(x, y, LEAD[i], tokW)
  elseif d < scallop(s) then
    local i = q6(lam(sn, 0.1))
    -- grain: fine lines running toward the tip
    local g = (s / w * 2.6 + 10) % 1
    if g < 0.22 and d > D_LEAD + 1 then i = max(1, i - 1) end
    if d < D_LEAD + 1.2 then i = max(1, i - 2) end   -- AO where lead meets wood
    c:put(x, y, WOOD[i], tokW)
  elseif d < D_FER then
    local i
    if s < -3.3 then i = 4
    elseif s < -1.75 then i = 5
    elseif s < -1.2 then i = 6                      -- lit ridge
    elseif s < 1.25 then i = 4
    elseif s < 1.8 then i = 2                       -- dark ridge
    elseif s < 3.1 then i = 3
    else i = 2 end
    if s > -0.9 and s < -0.15 and d > 20 and d < 36 then i = 5 end -- specular streak on the top facet
    if d > D_FER - 1.4 then i = max(1, i - 1) end  -- AO under the ferrule
    if d < scallop(s) + 1.1 then i = max(1, i - 1) end -- paint lip edge
    c:put(x, y, (s >= 3.1 and d > D_CONE + 2 and d < D_FER - 2) and BOUNCE or YEL[i], tokY)
  elseif d < D_ERA then
    local i = q6(lam(sn, 0.05))
    local r = d - D_FER
    if (r > 1.6 and r < 2.6) or (r > 4.0 and r < 5.0) then i = max(1, i - 2)      -- crimp grooves
    elseif (r > 2.6 and r < 3.4) and i >= 3 then i = min(6, i + 1) end              -- lit lip
    if sn > -0.62 and sn < -0.28 and not ((r > 1.6 and r < 2.6) or (r > 4.0 and r < 5.0)) then i = 6 end
    if r < 0.8 then i = max(1, i - 1) end
    c:put(x, y, TIN[i], tokM)
  else
    -- eraser: cylinder light, rounded cap
    local r = d - (D_END - 3.95)
    local nr = max(0, r) / 4.2
    local snn = sn * sqrt(max(0.05, 1 - nr * nr))
    local nz = sqrt(max(0.02, 1 - snn * snn - nr * nr))
    local nx, ny = px * snn + ux * nr, py * snn + uy * nr
    local dl = nx * L3[1] + ny * L3[2] + nz * L3[3]
    local i = q6(max(0, min(1, 0.06 + 0.94 * max(0, (dl + 0.25) / 1.25))))
    if d < D_ERA + 1.1 then i = max(1, i - 2) end   -- AO where it plugs into the ferrule
    c:put(x, y, PINK[i], tokE)
  end
end)
-- graphite glint
do local t = 3.2 / L c:put(floor(11 + ux * 3.2 - px * 0.6 + .5), floor(53 + uy * 3.2 - py * 0.6 + .5), LEAD[4], tokW) end
-- tooth dents: bare wood showing in the bite, dark lip beyond
m:each(function(x, y) local k = K(x, y) local d, s = Dd[k], S[k]
  if s < -1.2 and d > 33 and d < 44.5 then
    local near = false
    for _, o in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do local t2, s2 = f(x + o[1], y + o[2])
      if not m:has(x + o[1], y + o[2]) and dent(t2 * L, s2) then near = true end end
    if near then c:put(x, y, WOOD[3], tokW) end
  end end)
-- eraser highlight pop
do local best, bx, by
  m:each(function(x, y) local k = K(x, y) if Dd[k] > D_ERA + 1.5 and S[k] < -1.2 and S[k] > -2.6 then
    if not best or Dd[k] > best then best, bx, by = Dd[k], x, y end end end)
  if bx then c:put(bx, by, PINK[6], tokE) c:put(bx - 1, by + 1, PINK[6], tokE) end end
A.save(c, "ico-pencil")
