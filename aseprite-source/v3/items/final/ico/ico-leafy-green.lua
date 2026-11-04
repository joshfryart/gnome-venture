-- ico-leafy-green (final, Opus). A slim chard / romaine leaf on the diagonal (cut stem lower-left, tip upper-right)
-- with a second, darker leaf tucked behind it on the left. Ruffled, wavy edges; a pale rounded midrib that runs out
-- past the blade as a short stalk with a paler cut end.
-- Material: per-pixel lit leaf (6 greens, cool shade), puckered blade (bulges between the side veins), raised pale
-- side veins with a dark groove on their shade side, cylinder-lit midrib with a waxy streak, AO where the blade meets
-- the rib and where the front leaf overlaps the back one, plus a contact shadow.
-- quirk: a caterpillar has taken one neat bite out of the edge.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_3.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, abs, floor, max, min, pi, sin, cos = math.sqrt, math.abs, math.floor, math.max, math.min, math.pi, math.sin, math.cos
local c = A.new("ico-leafy-green")
local LEAF = { "#173c36", "#1f5a40", "#2d7b46", "#49a04e", "#78c25a", "#b2df7a" }
local BACK = { "#132f30", "#1a4a3c", "#256942", "#3a8a48", "#5fac52", "#8fcb66" }
local RIB = { "#3f6a46", "#6e9e62", "#a3cc86", "#cfe9ad", "#eef7d2" }
local SPEC = "#fbffe6"
local norm = A.norm

local function leaf(p, t0, wmax, ruff, ramp, tok, bias0)
  local function wfn(t)
    if t < t0 then return 0 end
    local q = (t - t0) / (1 - t0)
    local w = wmax * sin(pi * q ^ 0.75) ^ 0.9
    if q > 0.05 and q < 0.96 then w = w + ruff * sin(q * 27) end
    return max(0, w)
  end
  local m, n, T, S, samp = A.tube(p, wfn)
  -- flatten (leaves are not cylinders) and pucker between side veins
  local LEN = 0
  for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
  local Q = {}
  m:each(function(x, y) local k = K(x, y)
    local s = samp[floor(T[k] * 160) + 1]
    local q = (T[k] * LEN - abs(S[k]) * s.w * 0.75) / 5.2      -- veins sweep toward the tip
    Q[k] = q
    local b = sin(2 * pi * q) * 0.45
    local nn = n[k]
    n[k] = { norm(nn[1] * 0.55 - s.tx * b, nn[2] * 0.55 - s.ty * b, nn[3] + 0.3) }
  end)
  local bias = bias0 or {}
  local idx = A.shade(c, m, n, ramp, { tok = tok, bias = bias, amb = 0.06, wrap = 0.2, cuts = { 0.28, 0.43, 0.57, 0.71, 0.85 } })
  return m, n, T, S, samp, Q, idx, LEN
end

-- back leaf (left, darker)
local tokB = { r = { name = "backleaf" } }
local pB = { { 17, 55 }, { 12, 42 }, { 8, 28 }, { 15, 14 } }
local mB, nB, TB, SB, sB, QB, iB = leaf(pB, 0.2, 7.2, 0.8, BACK, tokB)
-- back leaf veins (simple: groove lines only)
mB:each(function(x, y) local k = K(x, y) local f = QB[k] % 1
  if abs(SB[k]) > 0.25 and abs(SB[k]) < 0.8 and f < 0.12 and TB[k] > 0.3 and TB[k] < 0.9 then A.step(c, iB, BACK, x, y, 1, tokB) end end)
local ribB = A.tube(pB, function(t) return t < 0.88 and (1.3 - t * 0.9) or 0 end)
ribB:each(function(x, y) c:put(x, y, (x + y) % 9 == 0 and RIB[3] or RIB[2], tokB) end)

-- front leaf
local tokF = { r = { name = "leaf" } }
local p = { { 15, 57 }, { 22, 41 }, { 35, 22 }, { 50, 8 } }
-- caterpillar bite: a scalloped notch on the right edge
local mF, nF, TF, SF, sF, QF, iF, LEN = leaf(p, 0.13, 9.2, 0.9, LEAF, tokF)
local sb = sF[floor(0.6 * 160) + 1]
local bcx, bcy = sb.x + sb.px * (sb.w + 0.6), sb.y + sb.py * (sb.w + 0.6)
local bite = A.ell(bcx, bcy, 3.1, 3.1):add(A.ell(bcx + sb.tx * 3.2 - sb.px * 0.6, bcy + sb.ty * 3.2 - sb.py * 0.6, 2.3, 2.3))
-- remove bite pixels (re-paint the back leaf/nothing there)
bite:each(function(x, y) if mF:has(x, y) then mF.s[K(x, y)] = nil c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end end)
-- AO on back leaf where the front leaf overlaps (contact shadow down-right of the front leaf edge)
mF:shift(1, 1):add(mF:shift(2, 1)):each(function(x, y) if mB:has(x, y) and not mF:has(x, y) then A.step(c, iB, BACK, x, y, -2, tokB) end end)
-- separation line on the front leaf where it lies over the back leaf
mF:edge():each(function(x, y)
  for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do
    if mB:has(x + d[1], y + d[2]) and not mF:has(x + d[1], y + d[2]) then c:put(x, y, LEAF[2], tokF) break end
  end
end)
-- dark rim of the bite (fresh cut edge, slightly brown-green)
bite:grow(1):cut(bite):each(function(x, y) if mF:has(x, y) then c:put(x, y, "#6b7a3a", tokF) end end)

-- side veins on the front leaf: raised pale line + groove on its shade side
mF:each(function(x, y) local k = K(x, y)
  local f, as = QF[k] % 1, abs(SF[k])
  if as > 0.2 and as < 0.86 and TF[k] > 0.2 and TF[k] < 0.93 then
    if f < 0.16 then c:put(x, y, LEAF[min(6, (iF[k] or 4) + 2)], tokF)
    elseif f < 0.3 then A.step(c, iF, LEAF, x, y, -1, tokF) end
  end
end)
-- shade half (lower-right of the rib) one step darker so the blade folds
mF:each(function(x, y) local k = K(x, y) if SF[k] > 0.4 then A.step(c, iF, LEAF, x, y, -1, tokF) end end)
-- AO beside the midrib
mF:each(function(x, y) local k = K(x, y) if abs(SF[k]) < 0.32 and TF[k] > 0.18 then A.step(c, iF, LEAF, x, y, -1, tokF) end end)

-- midrib: pale cylinder from the cut end to near the tip, 4 px at the base, tapering
local tokR = { r = { name = "rib" } }
local mR, nR, TR, SR, sR = A.tube(p, function(t) if t > 0.9 then return 0 end return 2.1 - t * 1.6 end)
local iR = A.shade(c, mR, nR, RIB, { tok = tokR, amb = 0.12, wrap = 0.35, cuts = { 0.3, 0.5, 0.68, 0.86 } })
-- ambient where the stalk enters the blade
mR:each(function(x, y) local k = K(x, y) if TR[k] > 0.11 and TR[k] < 0.15 then A.step(c, iR, RIB, x, y, -1, tokR) end end)
-- waxy streak along the lit side of the stalk
for i = 18, 70, 4 do local s = sR[i] local x, y = floor(s.x - s.px * s.w * 0.5 + .5), floor(s.y - s.py * s.w * 0.5 + .5)
  if mR:has(x, y) then c:put(x, y, RIB[5], tokR) end end
-- pale cut end of the stalk (cross-section ring)
mR:each(function(x, y) local k = K(x, y) if TR[k] < 0.03 then c:put(x, y, SR[k] < 0.2 and RIB[5] or RIB[4], tokR) end end)
c:put(floor(sR[1].x + .5), floor(sR[1].y + .5), RIB[3], tokR)

-- one bright specular on the bulge of the front blade
local bx, by = A.specAt(mF, nF, 40)
if bx then c:put(bx, by, SPEC, tokF) c:put(bx + 1, by, LEAF[6], tokF) end
A.save(c, "ico-leafy-green")
