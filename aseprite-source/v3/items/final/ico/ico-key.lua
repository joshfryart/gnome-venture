-- ico-key (final, Opus). Old brass door key on the TL->BR diagonal: a thick bevelled ring bow with a heart-shaped
-- eye, a turned collar with two grooves, a slim round shank and a two-step bit hanging off the lower-left side.
-- Material: per-pixel lit brass (6 tones, cool-violet shade), torus bevel on the bow, cylinder shank with a
-- specular streak, dark grooves + lit lips on the collar, AO where the shank meets collar and bit, worn notch in a ward.
-- quirk: the bow's eye is cut as a little heart.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_1.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, abs, floor, max, min, pi = math.sqrt, math.abs, math.floor, math.max, math.min, math.pi
local c = A.new("ico-key")
local BR = { "#5a2a22", "#8f4a1f", "#c27224", "#e49a2e", "#f8c64c", "#ffe9a2" }
local SPEC = "#fff6dc"
local tok = { r = { name = "brass" } }
local OX, OY, ANG = 19, 19, pi / 4
local VX, VY = -0.7071, 0.7071          -- +v points lower-left

-- bow: ring with a heart eye
local bow = A.ell(OX, OY, 10.5, 10.5)
local heart = HP.mask()
for yy, row in ipairs{ ".XX.XX.", "XXXXXXX", "XXXXXXX", ".XXXXX.", "..XXX..", "...X..." } do
  for xx = 1, 7 do if row:sub(xx, xx) == "X" then heart:set(OX - 4 + xx, OY - 3 + yy) end end
end
bow:cut(heart)

-- shank, collar, bit in the key frame
local shank, U, V = A.local_mask(OX, OY, ANG, 46, function(u, v)
  if u < 8 or u > 44 then return false end
  if u > 42.5 then return abs(v) <= 2.2 - (u - 42.5) * 0.9 end
  return abs(v) <= 2.2
end)
local collar, CU, CV = A.local_mask(OX, OY, ANG, 30, function(u, v) return u >= 10.5 and u <= 14.5 and abs(v) <= 3.7 end)
local bit, BU, BV = A.local_mask(OX, OY, ANG, 50, function(u, v)
  if v < 1.5 then return false end
  if u >= 31 and u <= 35.5 and v <= 8.6 then return not (v > 6.6 and u > 33.4 and u < 34.6) end  -- worn notch
  if u >= 38.2 and u <= 43 and v <= 6.6 then return true end
  return false
end)

-- paint: bit first (behind shank), then shank, collar, bow
local bitIdx, bn = A.pill(c, bit, 1.6, BR, { tok = tok, amb = 0.04, cuts = { 0.28, 0.46, 0.62, 0.76, 0.9 } })
local shIdx = {}
shank:each(function(x, y) local k = K(x, y)
  local v = V[k]
  local i = v < -1.5 and 4 or v < -0.5 and 5 or v < 0.5 and 4 or v < 1.5 and 3 or 2
  if U[k] > 42.5 then i = i - 1 end
  shIdx[k] = i c:put(x, y, BR[i], tok)
end)
-- AO on the bit where it tucks under the shank
bit:each(function(x, y) local k = K(x, y) if BV[k] < 3.2 then A.step(c, bitIdx, BR, x, y, -2, tok) end end)
-- specular streak along the lit (upper-right, v<0) side of the shank
shank:each(function(x, y) local k = K(x, y)
  if V[k] > -1.5 and V[k] <= -0.5 and U[k] > 16 and U[k] < 30 then c:put(x, y, BR[6], tok) end
end)
c:put(floor(OX + 0.7071 * 19.5 + 0.7071 * 1 + 0.5), floor(OY + 0.7071 * 19.5 - 0.7071 * 1 + 0.5), SPEC, tok)

local cn = {}
collar:each(function(x, y) local k = K(x, y)
  local s = max(-0.95, min(0.95, CV[k] / 4.2))
  cn[k] = { VX * s, VY * s, sqrt(1 - s*s) }
end)
local coIdx = A.shade(c, collar, cn, BR, { tok = tok, amb = 0.1, wrap = 0.3 })
-- collar grooves + AO on shank meeting collar
collar:each(function(x, y) local k = K(x, y)
  local u = CU[k]
  if abs(u - 12.5) < 0.5 then A.step(c, coIdx, BR, x, y, -3, tok)
  elseif abs(u - 11.5) < 0.5 then A.step(c, coIdx, BR, x, y, 1, tok) end
end)
shank:each(function(x, y) local k = K(x, y)
  if U[k] > 14.5 and U[k] < 16 and not collar:has(x, y) then A.step(c, shIdx, BR, x, y, -2, tok) end
end)

-- bow: torus bevel from the distance field
local bowIdx, bwn, bd = A.pill(c, bow, 3.6, BR, { tok = tok, amb = 0.02, wrap = 0.12, cuts = { 0.28, 0.46, 0.62, 0.76, 0.9 } })
-- dark inner wall of the heart eye (lower-right inner rim catches no light)
local hg = heart:grow(1)
bow:each(function(x, y)
  if hg:has(x, y) then
    local dx, dy = x - OX, y - OY
    if dx + dy < 1 then A.step(c, bowIdx, BR, x, y, -2, tok) else A.step(c, bowIdx, BR, x, y, 1, tok) end
  end
end)
-- AO where the bow meets the collar/shank
bow:each(function(x, y) local k = K(x, y)
  local u = (x - OX) * 0.7071 + (y - OY) * 0.7071
  if u > 8.3 and abs((x - OX) * -0.7071 + (y - OY) * 0.7071) < 3.5 then A.step(c, bowIdx, BR, x, y, -1, tok) end
end)
-- specular glint + hot edge on the bow's upper-left
c:put(OX - 5, OY - 7, SPEC, tok) c:put(OX - 4, OY - 7, BR[6], tok) c:put(OX - 6, OY - 6, BR[6], tok)
A.save(c, "ico-key")
