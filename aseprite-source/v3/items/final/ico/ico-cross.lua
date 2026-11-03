-- ico-cross (final, Opus). A bold "X" (close / no): two slim lacquered bars with rounded ends crossing on the
-- diagonals, the "/" bar lying over the "\" bar.
-- Material: glossy red enamel; per-pixel pillow normals (flat crown, rounded bevel) snapped to a 6-tone ramp,
-- bright bevel edge + cream specular streak along the upper-left of each bar, cool reflected light on the lower-right
-- edge, contact shadow + AO where the top bar lies across the lower one.
-- quirk: a loop of gold twine is tied round the upper-right arm (a reminder knot), its loose end dangling.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-cross")
local RED  = { "#5a1830", "#8c2236", "#c0303a", "#e4483b", "#fb7352", "#ffad84" }
local SPEC, BOUNCE = "#fff4d6", "#a8506c"
local TW   = { "#7a3e1c", "#c27a24", "#efb43a", "#ffe08a" }
local tA, tB, tT = A.tok("barA"), A.tok("barB"), A.tok("twine")

local W = 4.6
-- under bar "\" and over bar "/"
local mA, TA, SA = A.capsule(13, 13, 50, 50, W)
local mB, TB, SB = A.capsule(13, 50, 50, 13, W)

local function bar(m, T, S, tok, bias)
  local n = X.pillow(m, 3.2)
  -- hard enamel bevel: shade facet on the lower-right side, lit facet upper-left, one tone each
  m:each(function(x, y) local k = K(x, y) local sv = S[k]
    if sv > W - 2.2 then bias[k] = (bias[k] or 0) - 1 end
    if sv > W - 1.0 then bias[k] = (bias[k] or 0) - 1 end
    if sv < -W + 1.6 then bias[k] = (bias[k] or 0) + 1 end
  end)
  local idx = A.shade(c, m, n, RED, { bias = bias, tok = tok, amb = 0.1, wrap = 0.3, cuts = { 0.2, 0.38, 0.55, 0.76, 0.9 } })
  -- specular streak on the upper-left crown edge, broken into two dashes
  m:each(function(x, y) local k = K(x, y) local t, s = T[k], S[k]
    if s > -W + 1.3 and s < -W + 2.3 and ((t > 0.12 and t < 0.3) or (t > 0.36 and t < 0.42)) then c:put(x, y, RED[6], tok) end
  end)
  -- cool bounce light on the lower-right edge
  m:edge():each(function(x, y) local k = K(x, y) local s = S[k]
    if s > W - 0.9 and T[k] > 0.08 and T[k] < 0.92 and (bias[k] or 0) >= -2 and not (tok == tA and mB:grow(2):has(x, y)) then c:put(x, y, BOUNCE, tok) end
  end)
  return idx, n
end

-- under bar: contact shadow from the over bar (light upper-left -> shadow falls lower-right), AO ring at the crossing
local bA = {}
A.cast(bA, mA, mB, 1, 1, -1)
A.cast(bA, mA, mB, 2, 2, -1)
X.ao(bA, mA, mB, 1, -1)
local idxA = bar(mA, TA, SA, tA, bA)
-- over bar
local bB = {}
local idxB = bar(mB, TB, SB, tB, bB)
-- glint: one cream 2x1 on the over bar's upper arm
for _, p in ipairs{ { 39, 19 }, { 40, 18 } } do c:put(p[1], p[2], SPEC, tB) end
c:put(17, 22, SPEC, tA)

-- quirk: gold twine wrapped round the upper-right arm of the over bar, three twisted turns, tail dangling
local LB = sqrt(37 * 37 * 2)
local T0, T1 = 0.73, 0.86
local tw = HP.mask()
for y = 8, 34 do for x = 30, 56 do
  local t = ((x - 13) * 37 + (y - 50) * -37) / (LB * LB)
  local s = ((x - 13) + (y - 50)) / sqrt(2)
  if t > T0 and t < T1 and abs(s) <= W + 1.0 then tw:set(x, y) end
end end
tw:each(function(x, y)
  local t = ((x - 13) * 37 + (y - 50) * -37) / (LB * LB)
  local s = ((x - 13) + (y - 50)) / sqrt(2)
  local d = (t - T0) * LB + s * 0.28
  local i
  if d % 2.3 < 0.75 then i = 1
  elseif s < -1.6 then i = 4
  elseif s > 2.2 then i = 2
  else i = 3 end
  c:put(x, y, TW[i], tT)
end)
-- AO on the enamel right beside the wrap
mB:each(function(x, y) if not tw:has(x, y) and (tw:has(x + 1, y) or tw:has(x, y - 1)) then A.step(c, idxB, RED, x, y, -1, tB) end end)
-- loose tail hanging from the lower-right side of the wrap (2 px wide, flicks out at the end)
local tail = { { 46, 25 }, { 46, 26 }, { 47, 27 }, { 47, 28 }, { 47, 29 } }
for _, p in ipairs(tail) do c:put(p[1], p[2], TW[3], tT) c:put(p[1] + 1, p[2], TW[2], tT) end
c:put(48, 30, TW[2], tT) c:put(49, 30, TW[1], tT) c:put(46, 25, TW[4], tT)
A.save(c, "ico-cross")
