-- ico-porridge (Opus single pass). A glazed blue bowl on a narrow foot, heaped with oat porridge, a pat of butter
-- melting on top and a slim wooden spoon standing in it. Material: bowl lit per pixel as a sphere section (6-tone
-- glaze, tall gloss streak, cream rim lip, gold glaze band, AO under the rim, contact dark at the foot); porridge
-- 6-tone oat ramp with flake texture and a dark seam where it meets the rim; butter with a bevelled lit top and
-- a melt pool; spoon handle with grain lines and a pale end grain cap.
-- quirk: a drip of honey has run over the rim and hangs off the bowl in a fat drop.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = A.new("ico-porridge")
local GL = { "#1f2c58", "#284a84", "#3170ac", "#4796c8", "#76bedb", "#bfeaf0" }
local BAND = { "#5a5a86", "#8a8cb4", "#b8bcd8", "#dcdeee", "#f2f0f4", "#fff4d6" }
local OAT = { "#6e4a3c", "#a07a5a", "#c6a27a", "#e0c497", "#f1dcb3", "#fbefd2" }
local BUT = { "#b8862a", "#e0b23c", "#f6d45e", "#ffe88e", "#fff4c2" }
local WD = { "#3e2326", "#5e3428", "#864c33", "#b07444", "#d49a62", "#f0c890" }
local HON = { "#7a3a1c", "#b8601c", "#e08a22", "#f7b23a", "#ffd878" }
local SPEC = "#fff6e0"
c:groundShadow(32, 53, 13, 2)

local cx, ry0 = 32, 30            -- rim centre line
local RX, RY = 21, 7              -- rim ellipse
-- bowl body: lower half of an ellipse, slightly flared, plus a short foot
local bowl = A.fmask(cx - RX - 1, ry0 - RY, cx + RX + 1, 52, function(x, y)
  local u = (x - cx) / (RX + 0.4)
  if abs(u) > 1 then return false end
  local top = ry0 + RY * sqrt(1 - u*u) * 0.0   -- rim front edge handled by the rim
  local bot = ry0 + 18 * (1 - u*u) ^ 0.62
  return y >= ry0 and y <= bot
end)
local foot = A.fmask(cx - 9, 45, cx + 9, 50, function(x, y)
  local u = (x - cx) / 9.4
  return abs(u) <= 1 and y <= 48 + 1.5 * sqrt(1 - u*u)
end)
bowl:add(foot)
local bn = {}
bowl:each(function(x, y)
  local u = (x - cx) / (RX + 1)
  local v = (y - (ry0 - 4)) / 22
  bn[K(x, y)] = { A.norm(u, v * 0.9, sqrt(max(0.05, 1 - u*u - v*v * 0.6))) }
end)
local bias = {}
bowl:each(function(x, y) local k = K(x, y)
  local u = (x - cx) / RX
  local rimBot = ry0 + RY * sqrt(max(0, 1 - u*u))
  if y <= rimBot + 1 then bias[k] = -1 end                  -- AO under the rim lip
  if foot:has(x, y) and y <= 46 then bias[k] = (bias[k] or 0) - 1 end   -- tuck where the foot joins
end)
local btok = { r = { name = "bowl" } }
local bidx = A.shade(bowl, bn, GL, { amb = 0.06, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bias, tok = btok })
-- gold glaze band following the bowl's curve
bowl:each(function(x, y) local k = K(x, y)
  local u = (x - cx) / RX
  local yb = ry0 + 5 + 6.2 * sqrt(max(0, 1 - u*u))
  if y >= floor(yb) and y <= floor(yb) + 1 and not foot:has(x, y) then
    c:put(x, y, BAND[max(1, min(6, bidx[k]))], btok) end
end)
-- tall gloss streak on the lit flank + spec glint
for y = 37, 42 do c:put(cx - 15 + floor((y - 37) / 3), y, GL[6], btok) end
c:put(cx - 15, 36, SPEC, btok)

-- porridge heap (dome above the rim)
local heap = A.fmask(cx - 20, ry0 - 12, cx + 20, ry0 + 4, function(x, y)
  local u = (x - cx) / 19.5
  if abs(u) > 1 then return false end
  local h = 9.5 * (1 - u*u) ^ 0.75 + 1.2 * math.sin(x * 0.9) * (1 - u*u)
  return y >= ry0 - 1 - h and y <= ry0 + (RY - 1.4) * sqrt(1 - u*u)
end)
local hn = X.pillow(heap, 6, 1.1)
local hb = {}
heap:each(function(x, y) local k = K(x, y)
  local u = (x - cx) / 19.5
  if y >= ry0 + (RY - 1.4) * sqrt(max(0, 1 - u*u)) - 1 then hb[k] = -2 end   -- seam against the rim
end)
local otok = { r = { name = "oats" } }
local oidx = A.shade(heap, hn, OAT, { amb = 0.12, wrap = 0.35, cuts = { 0.2, 0.36, 0.5, 0.64, 0.8 }, bias = hb, tok = otok })
-- oat flakes: 2x1 flecks, darker one tone with a lit pixel beside
heap:shrink(1):each(function(x, y) local k = K(x, y) local i = oidx[k]
  local h = X.hash(x, y, 11)
  if i and i >= 2 and h < 0.1 then
    c:put(x, y, OAT[i - 1], otok)
    if heap:has(x + 1, y) then c:put(x + 1, y, OAT[min(6, i + 1)], otok) end
  end
end)

-- rim lip: cream-glazed ring in front of the heap (front half only; the heap hides the back)
local rim = A.fmask(cx - RX - 1, ry0 - RY - 1, cx + RX + 1, ry0 + RY + 2, function(x, y)
  local u = (x - cx) / (RX + 0.5)
  if abs(u) > 1 then return false end
  local yo = ry0 + (RY + 0.5) * sqrt(1 - u*u)
  local yi = ry0 + (RY - 1.6) * sqrt(max(0, 1 - ((x - cx) / (RX - 2)) ^ 2))
  if abs(x - cx) > RX - 2 then yi = ry0 - 1 end
  return y <= yo and y >= yi and y >= ry0 - 1
end)
local rn = {}
rim:each(function(x, y) local u = (x - cx) / (RX + 1) rn[K(x, y)] = { A.norm(u * 0.8, -0.6, 0.6) } end)
A.shade(rim, rn, GL, { amb = 0.2, wrap = 0.4, cuts = { 0.15, 0.3, 0.45, 0.62, 0.78 }, tok = btok })
c:put(cx - 13, ry0 + 6, SPEC, btok) c:put(cx - 12, ry0 + 6, GL[6], btok)

-- butter pat: bevelled block sitting slightly left of centre, melt pool round it
local bx, by = 25, 20
local pool = A.oval(bx + 3, by + 5.5, 6, 2, 0.1)
pool:each(function(x, y) if heap:has(x, y) then c:put(x, y, (x + y) % 5 == 0 and BUT[3] or BUT[2], otok) end end)
A.bmp({
  ".hhhhh.",
  "hHHHHHm",
  "lbbbbbm",
  "lbbbbbd",
  ".mmmmd.",
}, bx, by, { H = BUT[5], h = BUT[4], b = BUT[3], l = BUT[4], m = BUT[2], d = BUT[1] }, otok)
c:put(bx + 1, by + 1, SPEC, otok)

-- spoon: slim wooden handle rising out of the heap to the upper right
local sm, sn = A.capsule(37, 22, 50, 7, 1.7)
local swtok = { r = { name = "spoon" } }
local sbias = {}
sm:each(function(x, y) if y >= 20 then sbias[K(x, y)] = -1 end end)
local sidx = A.shade(sm, sn, WD, { amb = 0.08, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = sbias, tok = swtok })
-- grain: a dark line along the shade side, broken
for t = 0, 14 do local x, y = floor(38.6 + t * 0.87), floor(22.5 - t) if t % 5 ~= 3 and sm:has(x, y) then c:put(x, y, WD[3], swtok) end end
-- pale end grain cap
for _, p in ipairs{ { 49, 6 }, { 50, 6 }, { 50, 7 }, { 51, 7 } } do if sm:has(p[1], p[2]) then c:put(p[1], p[2], WD[6], swtok) end end
c:put(50, 7, WD[5], swtok)
-- AO on the porridge round the spoon's entry
heap:each(function(x, y) local k = K(x, y)
  if not sm:has(x, y) and (sm:has(x - 1, y) or sm:has(x + 1, y) or sm:has(x, y - 1)) and y >= 18 then c:put(x, y, OAT[max(1, (oidx[k] or 3) - 2)], otok) end end)

-- quirk: honey drip over the rim on the right, hanging in a fat drop
local htok = { r = { name = "honey" } }
local dx0 = 19
local drip = A.fmask(dx0 - 4, 32, dx0 + 4, 50, function(x, y)
  if y <= 43 then
    local w = y < 39 and 1 or 1.6
    return y >= 34 and abs(x - dx0) <= w
  end
  return (x - dx0)^2 / 5.5 + (y - 45)^2 / 5.2 <= 1
end)
drip:add(A.fmask(dx0 - 5, 31, dx0 + 5, 37, function(x, y) return (x - dx0)^2 / 14 + (y - 35)^2 / 2.0 <= 1 end))
local dn = X.pillow(drip, 2.2)
A.shade(drip, dn, HON, { amb = 0.12, wrap = 0.35, cuts = { 0.22, 0.42, 0.62, 0.8 }, tok = htok })
c:put(dx0 - 1, 44, SPEC, htok) c:put(dx0 - 1, 45, HON[5], htok) c:put(dx0 - 1, 37, HON[5], htok) c:put(dx0 - 1, 38, HON[5], htok)
-- tiny honey puddle where it was poured on the heap
for _, p in ipairs{ { dx0, 30 }, { dx0 + 1, 30 }, { dx0 + 2, 31 }, { dx0 - 1, 31 }, { dx0 + 1, 29 } } do if heap:has(p[1], p[2]) then c:put(p[1], p[2], HON[4], htok) end end
A.done()
