-- ico-leaf (final pass, Opus). One slim lanceolate leaf on a diagonal, stalk lower left, tip curving up right,
-- softly toothed edge. Material: per-pixel V-fold light across the midrib (6-tone green, cool blue-green shade),
-- lit midrib on the upper half / dark on the lower, paired side veins, a waxy specular glint on the lit half, cool
-- reflected light on the lower-right edge, 2-tone stalk with a dark collar where it meets the blade (AO).
-- quirk: a caterpillar has taken a round bite out of the lower edge, its rim dried brown.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.pi
local c = A.new("ico-leaf")
local LEAF  = { "#173f3a", "#215a44", "#2e784a", "#47984f", "#6cb757", "#a2d470" }
local STALK = { "#24503e", "#3f7c4a", "#6aa65a" }
local DRY   = { "#7a5a2a", "#b48a44" }
local BOUNCE, SPEC = "#5ea08e", "#e8f6b0"
local ltok = { r = { name = "leaf" } }

-- stalk
local sm, sn, ST, SS, sidx = A.stem(c, { { 10, 57 }, { 13, 53 }, { 16, 50 }, { 19, 46 } },
  function(t) return 1.6 - t * 0.2 end, { STALK[1], STALK[2], STALK[3] }, { cuts = { 0.4, 0.7 } })

-- blade: V-fold normals blended with a pillow so each half rounds off toward its edge
local AX, AY, CX, CY, BX, BY, W = 19, 45, 29, 25, 51, 10, 9
local wfn = function(t)
  if t > 0.99 then return -1 end
  return max(0.4, W * sin(pi * min(1, t ^ 0.85 * 0.97 + 0.03)) ^ 0.9)
end
local m, n0, T, S, len = A.blade(AX, AY, CX, CY, BX, BY, wfn, { fold = 0.4 })
-- soft teeth: 1 px notches along both edges
local notch = HP.mask()
m:edge():each(function(x, y) local k = K(x, y)
  if T[k] > 0.15 and T[k] < 0.88 and (T[k] * len) % 4.5 < 0.9 then notch:set(x, y) end end)
m:cut(notch)
-- the bite: a round hole taken out of the lower-right edge
local bx, by
m:edge():each(function(x, y) local k = K(x, y)
  if not bx and S[k] > 0.8 and abs(T[k] - 0.52) < 0.03 then bx, by = x, y end end)
local bite = A.ell(bx + 2.2, by + 1.6, 4.2, 4.2)
m:cut(bite)
local pn = X.pillow(m, 3)
local n = {}
m:each(function(x, y) local k = K(x, y)
  local a, b = n0[k], pn[k]
  n[k] = { A.norm(a[1] + b[1] * 0.9, a[2] + b[2] * 0.9, a[3] + b[3] * 0.6) }
end)
local bias = {}
m:each(function(x, y) local k = K(x, y) if T[k] < 0.08 then bias[k] = -1 end end)    -- AO at the stalk end
local idx = A.shade(c, m, n, LEAF, { amb = 0.08, wrap = 0.3, tok = ltok, bias = bias, cuts = { 0.2, 0.36, 0.52, 0.68, 0.85 } })
-- side veins: lighter lines angled toward the tip; darker on the brightest tones
m:each(function(x, y) local k = K(x, y)
  local s, t = S[k], T[k]
  if t > 0.1 and t < 0.86 and abs(s) > 0.22 and abs(s) < 0.82 then
    local d = (t * len - abs(s) * wfn(t) * 1.15) % 6
    if d < 0.8 then A.step(c, idx, LEAF, x, y, (idx[k] or 3) >= 5 and -1 or 1, ltok) end
  end
end)
-- midrib: pale line, dark groove just below it
m:each(function(x, y) local k = K(x, y)
  local s, t = S[k], T[k]
  local d = s * (wfn(t) + 0.6)
  if t < 0.9 and d > -0.55 and d <= 0.5 then c:put(x, y, t < 0.6 and "#b8dc84" or LEAF[5], ltok)
  elseif t < 0.8 and d > 0.5 and d <= 1.5 then c:put(x, y, LEAF[max(1, (idx[k] or 3) - 2)], ltok) end
end)
-- dark collar where the stalk enters the blade
for _, p in ipairs{ { 19, 45 }, { 20, 45 }, { 19, 44 }, { 20, 44 } } do
  if m:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[1], ltok) end end
-- cool reflected light along the lower-right edge
m:edge():each(function(x, y) local k = K(x, y)
  if S[k] > 0.7 and T[k] > 0.2 and T[k] < 0.85 and (idx[k] or 3) <= 3 then c:put(x, y, BOUNCE, ltok) end end)
-- waxy glint on the lit half (brightest specular pixel)
local gx, gy = A.specAt(m, n, 60)
c:put(gx, gy, SPEC) c:put(gx + 1, gy - 1, LEAF[6], ltok) c:put(gx - 1, gy + 1, LEAF[6], ltok)

-- quirk: bite rim dried brown
bite:grow(1):cut(bite):each(function(x, y)
  if m:has(x, y) then c:put(x, y, (x + y) % 3 == 0 and DRY[1] or DRY[2], ltok) end end)

A.save(c, "ico-leaf")
