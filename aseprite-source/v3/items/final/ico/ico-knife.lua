-- ico-knife (final, Opus). Kitchen paring knife on the BL->TR diagonal: slim steel blade with a straight spine and a
-- curved belly to the point, a steel bolster, a turned wooden handle with two brass rivets and a rounded butt.
-- Material: steel 6 tones (bright spine line, flat face, darker bevel band, honed hi edge, slanted polish streak, glint),
-- bolster cylinder with a groove, wood cylinder with wavy grain + pale end grain on the butt, rivets with a hi dot,
-- AO where the blade/handle meet the bolster.
-- quirk: a curl of green apple peel still hangs off the edge.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_1.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local sqrt, abs, floor, max, min, pi, sin = math.sqrt, math.abs, math.floor, math.max, math.min, math.pi, math.sin
local c = A.new("ico-knife")
local ST = { "#3a3c58", "#585b7e", "#8085a3", "#aaaec6", "#d0d3e2", "#eef0f6" }
local WD = { "#3e2220", "#5e3428", "#864c33", "#a8693f", "#c98c56", "#e6b47c" }
local BR = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local PEEL = { "#24544a", "#3f9150", "#6cbc4e", "#b4dc6a" }
local FLESH = { "#d9c48a", "#f2e6b0", "#fff4d6" }
local SPEC = "#fbfbff"
local OX, OY, ANG = 27, 37, -pi / 4      -- bolster centre; u toward the tip (upper-right), +v toward lower-right (edge)
local stok, wtok, btok, ptok = { r = { name = "steel" } }, { r = { name = "wood" } }, { r = { name = "brass" } }, { r = { name = "peel" } }

local TIP = 33
local function edgeW(u) if u < 17 then return 5.2 end local q = (u - 17) / (TIP - 17) return 5.2 * sqrt(max(0, 1 - q*q)) end
local function spineV(u) return -2.2 + max(0, u - 25) * 0.24 end
local blade, U, V = A.local_mask(OX, OY, ANG, 40, function(u, v)
  if u < 2 or u > TIP then return false end
  return v >= spineV(u) and v <= edgeW(u) - 0.1 + (u < 3 and -0.5 or 0)
end)
local bol, BU, BV = A.local_mask(OX, OY, ANG, 10, function(u, v) return u >= -2.3 and u <= 2.2 and abs(v) <= 3.3 - (u > 1.2 and 0.6 or 0) end)
local handle, HU, HV = A.local_mask(OX, OY, ANG, 30, function(u, v)
  if u > -2 or u < -22 then return false end
  local w = 2.5 + 0.35 * sin(pi * (-u - 2) / 20)
  if u < -20 then local q = (-20 - u) / 2.2 w = w * sqrt(max(0, 1 - q*q)) end
  return abs(v) <= w
end)

-- handle: wood cylinder (lit on the -v / upper-left side) + grain
local hIdx = {}
handle:each(function(x, y) local k = K(x, y)
  local v, u = HV[k], HU[k]
  local i = v < -1.6 and 5 or v < -0.6 and 4 or v < 0.6 and 4 or v < 1.6 and 3 or 2
  local g = (v * 1.3 + sin(u * 0.55) * 0.9) % 2.6
  if g < 0.6 and abs(v) < 2.3 then i = i - 2 end
  if u < -20.4 then i = (v < 0) and 6 or 5 end          -- pale end grain on the butt
  if u > -3.4 then i = i - 1 end                       -- AO under the bolster
  i = max(1, min(6, i)) hIdx[k] = i c:put(x, y, WD[i], wtok)
end)
c:put(floor(OX + 0.7071 * -18.5 + 0.7071 * -1.6 + 0.5), floor(OY + 0.7071 * 18.5 + 0.7071 * -1.6 + 0.5), WD[6], wtok)
-- rivets (3x3 brass, hi dot upper-left)
for _, ru in ipairs{ -7.5, -15.5 } do
  local cx, cy = floor(OX + 0.7071 * ru + 0.5), floor(OY - 0.7071 * ru + 0.5)
  A.map(c, { "hbm", "bmd", "mdd" }, cx - 1, cy - 1, { b = BR[3], h = BR[4], m = BR[2], d = BR[1] }, btok)
end

-- blade
local bIdx = {}
blade:each(function(x, y) local k = K(x, y)
  local u, v = U[k], V[k]
  local ew, sv = edgeW(u), spineV(u)
  local i
  if v < sv + 1 then i = 5                  -- spine bevel catches the light
  elseif v > ew - 1.1 then i = (u > 4 and u < TIP - 3) and 6 or 5   -- honed edge
  elseif v > ew - 2.6 then i = 2            -- primary bevel in shade
  elseif v > ew - 3.6 then i = 3
  else i = 4 end
  if u < 3.6 and i > 2 then i = i - 1 end   -- AO at the heel against the bolster
  bIdx[k] = i c:put(x, y, ST[i], stok)
end)
-- slanted polish streak across the face + glint
blade:each(function(x, y) local k = K(x, y)
  local u, v = U[k], V[k]
  local d = u - 15 + v * 0.9
  if d > -0.7 and d < 0.7 and bIdx[k] >= 3 and bIdx[k] < 6 then c:put(x, y, ST[5], stok) end
  if d > 0.7 and d < 1.6 and bIdx[k] == 4 then c:put(x, y, ST[5], stok) end
end)
do local u, v = 24, -0.6 c:put(floor(OX + 0.7071 * u + 0.7071 * v + 0.5), floor(OY - 0.7071 * u + 0.7071 * v + 0.5), SPEC, stok) end

-- bolster: short steel cylinder with a groove
local boIdx = {}
bol:each(function(x, y) local k = K(x, y)
  local v, u = BV[k], BU[k]
  local i = v < -1.8 and 6 or v < -0.6 and 5 or v < 0.8 and 4 or v < 2 and 3 or 2
  if abs(u - 0) < 0.5 then i = max(1, i - 2) end
  if u < -1.7 then i = max(1, i - 1) end
  boIdx[k] = i c:put(x, y, ST[i], stok)
end)

-- quirk: apple peel curl hanging off the edge (red skin outside, cream flesh inside)
local ax, ay = OX + 0.7071 * 12 + 0.7071 * 5.4, OY - 0.7071 * 12 + 0.7071 * 5.4
local pts = { { ax - 0.5, ay }, { ax + 7, ay + 2 }, { ax + 3, ay + 11 }, { ax + 9, ay + 12.5 } }
local pm, pn, PT, PS = G.tube(pts, function(t) return 1.85 - t * 0.45 end)
pm:cut(blade)
pm:each(function(x, y) local k = K(x, y)
  local s, t = PS[k], PT[k]
  local front = (t < 0.33 or t > 0.72)
  if (s < 0) == front then
    local i = s < -0.55 and 4 or s < 0.3 and 3 or 2
    if not front then i = (abs(s) > 0.55) and 2 or 3 end
    if t < 0.08 then i = 1 end
    c:put(x, y, PEEL[i], ptok)
  else
    c:put(x, y, (abs(s) > 0.6) and FLESH[1] or (t > 0.85 and FLESH[3] or FLESH[2]), ptok)
  end
end)
A.save(c, "ico-knife")
