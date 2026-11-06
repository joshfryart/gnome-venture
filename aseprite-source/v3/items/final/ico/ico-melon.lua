-- ico-melon (final pass, Opus single pass). Bold icon: a whole striped watermelon-style melon, slightly oval, with a
-- half-moon slice leaning in front of it lower-right. Melon: per-pixel sphere light (6-tone green, cool teal bounce),
-- dark jagged meridian stripes converging on the stalk, waxy bloom freckles on the lit shoulder, one specular + cream
-- glint, AO where the slice touches. Slice: cut face facing us, dark rind band, pale green rind, honey flesh that
-- deepens toward the rind, a row of glossy seeds, bright cut edge along the chord, juicy glint.
-- Stalk: 3 px twig with pale end grain. quirk: a curly vine tendril springs off the stalk.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA7_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, asin = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.asin
local c = A.new("ico-melon")
local GR  = { "#24503a", "#356f42", "#4f8f4a", "#72ae58", "#9ccc6a", "#c8e690" }
local STR = { "#0e2629", "#12342d", "#174631", "#1d5a35", "#286e3a", "#3a8442" }
local FL  = { "#d27a3a", "#e89a48", "#f5b95a", "#fbd274", "#fee59a", "#fff2c4" }
local RIND = { "#173a31", "#265e3c", "#8fc874", "#c4e49a" }
local WOOD = { "#4a2a26", "#7a4a30", "#a8703e", "#d39e62" }
local mtok, stok, wtok = { r = { name = "melon" } }, { r = { name = "slice" } }, { r = { name = "stalk" } }

-- masks
local MX, MY, RX, RY = 27, 28, 15, 13.5
local body, bn = A.oval(MX, MY, RX, RY, 0)
local SX, SY, SR, SA = 40, 39, 13.5, -0.2
local ca, sa = cos(SA), sin(SA)
local slice, SU, SV = HP.mask(), {}, {}
for y = floor(SY - 2), floor(SY + SR + 2) do for x = floor(SX - SR - 2), floor(SX + SR + 2) do
  local dx, dy = x - SX, y - SY
  local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
  if v >= 0 and u*u + v*v <= SR * SR then slice:set(x, y) SU[K(x, y)], SV[K(x, y)] = u, v end
end end

-- melon body with AO near the slice and at the stalk
local bias = {}
X.ao(bias, body, slice, 2, -1)
body:each(function(x, y) if (x - MX)^2 + (y - (MY - RY + 1))^2 < 5 then local k = K(x, y) bias[k] = (bias[k] or 0) - 1 end end)
local idx = A.shade(c, body, bn, GR, { bias = bias, tok = mtok, amb = 0.08, wrap = 0.25 })
-- meridian stripes: longitude bands with jagged edges
body:each(function(x, y)
  local k = K(x, y)
  local q = (y - MY) / (RY + 0.5)
  local w = (RX + 0.5) * sqrt(max(0.02, 1 - q*q))
  local u = max(-1, min(1, (x - MX) / w))
  local lon = asin(u)
  local j = 0.22 * sin(y * 1.1) + (X.hash(x, y, 3) > 0.85 and 0.25 or 0)
  if sin(lon * 8.5 + 0.4 + j) > 0.25 then c:put(x, y, STR[idx[k]], mtok) idx[k] = -idx[k] end
end)
-- waxy bloom freckles on the lit shoulder (stripe-free pixels only)
body:each(function(x, y) local k = K(x, y)
  local i = idx[k]
  if i and i >= 4 and X.hash(x, y, 11) < 0.1 then c:put(x, y, "#b6d6a0", mtok) end
end)
-- cool reflected light on the lower-right rim
local rim = X.rim(bn)
body:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.72 and not slice:has(x, y) then c:put(x, y, (idx[k] or 1) < 0 and "#23584e" or "#2f7a68", mtok) end end)
-- specular
local sx, sy = A.specAt(body, bn, 30)
c:put(sx, sy, GR[6], mtok) c:put(sx + 1, sy, GR[6], mtok) c:put(sx, sy + 1, GR[6], mtok)
c:put(sx - 1, sy + 1, "#c6e6a2", mtok) c:put(sx, sy, A.CREAM, mtok)

-- slice: rind bands by distance to the arc, flesh deepens toward the rind and toward the lower-right
local seeds = {}
for i = 0, 4 do
  local a = 0.45 + i * 0.56
  seeds[#seeds + 1] = { cos(a) * 6.2, sin(a) * 6.2, a }
end
slice:each(function(x, y)
  local k = K(x, y)
  local u, v = SU[k], SV[k]
  local r = sqrt(u*u + v*v)
  local d = SR - r
  local col
  if d < 1.6 then col = (u > 4 or v > 9) and RIND[1] or RIND[2]
  elseif d < 2.6 then col = (u > 3) and RIND[3] or RIND[4]
  else
    local t = 1 - d / (SR - 2.6)               -- 0 at core, 1 near rind
    local lit = 0.32 - t * 0.55 - (u / SR) * 0.18 - (v / SR) * 0.2
    local i = floor(lit * 6 + 3.2)
    if v < 1 then i = 6 end                   -- cut edge on the chord catches light
    col = FL[max(1, min(6, i))]
  end
  c:put(x, y, col, stok)
end)
-- glossy seeds (teardrops pointing to the centre)
for _, s in ipairs(seeds) do
  local u, v = s[1], s[2]
  local x, y = floor(SX + u * ca - v * sa + .5), floor(SY + u * sa + v * ca + .5)
  c:put(x, y, "#3a1e1c", stok)
  local ox, oy = floor(SX + (u * 0.8) * ca - (v * 0.8) * sa + .5), floor(SY + (u * 0.8) * sa + (v * 0.8) * ca + .5)
  if ox ~= x or oy ~= y then c:put(ox, oy, "#6a3a2a", stok) else c:put(x + 1, y, "#6a3a2a", stok) end
end
-- juicy glint on the flesh
c:put(SX - 4, SY + 2, A.CREAM, stok) c:put(SX - 3, SY + 2, FL[6], stok)

-- stalk + tendril (quirk)
local sm, _, _, _, sidx = A.stem(c, { { MX, MY - RY + 1.5 }, { MX, MY - RY - 1 }, { MX + 0.5, MY - RY - 3 }, { MX + 2, MY - RY - 5 } },
  function(t) return 1.5 - t * 0.3 end, WOOD, { tok = wtok })
c:put(MX + 2, floor(MY - RY - 5), WOOD[4], wtok) c:put(MX + 1, floor(MY - RY - 5), WOOD[4], wtok)
local TY = floor(MY - RY - 2)
local TEN = { "#3f8a46", "#7cc35a" }
A.map(c, {
  ".....ggg",
  "....g...g",
  "ggg.g..Gg",
  "...Gg.g.",
  "....GG..",
}, MX + 2, TY - 3, { g = TEN[2], G = TEN[1] }, wtok)
A.save(c, "ico-melon")
