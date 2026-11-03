-- ico-fire (final, Opus single pass). A slim campfire icon: one tall S-curved flame with two side tongues rising
-- out of two crossed logs. Flame toned by "heat" (distance from its edge + lift toward the base) on a 9-step
-- crimson -> cream ramp, so the core is a low teardrop; the shade side (lower right) drops a step.
-- Logs: per-pixel cylinder light (6-tone wood), bark grain streaks, pale end grain with rings on the front ends,
-- fire glow on the tops, AO where the front log crosses the back one and where the flame meets the wood.
-- quirk: one ember has floated off as a tiny heart.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("ico-fire")

local FIRE = { "#8e1d36", "#c42b33", "#e64a2e", "#f56e2a", "#fb9230", "#ffb43c", "#ffd25a", "#ffe98e", "#fff6cf" }
local WOOD = { "#3a2226", "#5a3328", "#7f4a31", "#a5683f", "#c98d58", "#e8b982" }
local ENDG = { "#a5683f", "#d9a46c", "#f0c890", "#f8dcae" }

-- flame silhouette: main S-curved tongue + base bulb + two side tongues
local main = A.tube({ { 32, 44 }, { 23, 34 }, { 41, 22 }, { 33, 9 } }, function(t) return 11.5 * (1 - t) ^ 0.95 + 0.4 end)
local fl = main:copy():add(A.ell(32, 41, 11.5, 8.5))
fl:add((A.tube({ { 24, 42 }, { 17, 36 }, { 19, 27 }, { 14, 21 } }, function(t) return 5.2 * (1 - t) ^ 0.9 + 0.35 end)))
fl:add((A.tube({ { 40, 41 }, { 47, 35 }, { 44, 28 }, { 49, 23 } }, function(t) return 4.6 * (1 - t) ^ 0.9 + 0.35 end)))
-- a notch of air between the main tongue and each side tongue (keeps them reading as separate licks)
fl:cut(A.ell(21.5, 27, 1.2, 3.2)):cut(A.ell(43.5, 27.5, 1.0, 3.0)):cut(HP.mask():add(A.ell(32, 54, 14, 6)))
local d = X.dist(fl)
local ftok = A.tok("flame")
local fidx = {}
fl:each(function(x, y)
  local k = K(x, y)
  local lift = max(0, (y - 14) / 30)
  local v = d[k] * 0.55 + lift ^ 1.6 * 2.2 + 0.6
  -- inner tongue streaks: hotter ridge along the main tongue's spine
  local i = floor(v) + 1
  if x + y > 70 and d[k] < 1.2 then i = i - 1 end           -- shade edge lower right
  if x + y < 46 and d[k] < 1.2 and i < 3 then i = 3 end      -- lit upper-left rim stays warm
  i = max(1, min(#FIRE, i))
  fidx[k] = i
  c:put(x, y, FIRE[i], ftok)
end)

-- logs (painted over the flame base)
local function log(ax, ay, bx, by, hw, bias, front)
  local m, n, T, S = X.cyl(ax, ay, bx, by, function() return hw end)
  local v = A.val(n, { amb = 0.1, wrap = 0.25 })
  bias = bias or {}
  m:each(function(x, y) local k = K(x, y)
    -- warm fire glow on the top facing side under the flame
    if S[k] < -0.5 and fl:has(x, y - 1) then bias[k] = (bias[k] or 0) + 1 end
  end)
  local tok = A.tok("log")
  local idx = X.tone(c, m, v, WOOD, { cuts = { 0.24, 0.42, 0.58, 0.74, 0.9 }, bias = bias, tok = tok })
  -- bark grain: broken streaks along the length
  m:each(function(x, y) local k = K(x, y)
    local s = S[k]
    for _, g in ipairs{ -0.45, 0.05, 0.55 } do
      if abs(s - g) < 0.17 and X.hash(floor(T[k] * 14), floor(g * 10), 3) > 0.3 then
        A.step(c, idx, WOOD, x, y, -1, tok) end
    end
  end)
  return m, idx, tok, T, S
end
-- back log: lower-left -> upper-right
local bm = X.cyl(12, 53, 51, 42, function() return 3.6 end)
local fm = X.cyl(13, 42, 52, 53, function() return 3.6 end)
local bbias = {}
X.ao(bbias, bm, fm, 2, -1)
local bmask = log(12, 53, 51, 42, 3.6, bbias)
local fbias = {}
local fmask, fidx2, ftok2 = log(13, 42, 52, 53, 3.6, fbias)
-- end grain on the two near ends (pale disc, a darker ring, a pith dot)
local function endgrain(cx, cy)
  local e = A.ell(cx, cy, 2.6, 3.4)
  local tok = A.tok("endgrain")
  e:each(function(x, y)
    local r = sqrt(((x - cx) / 2.6) ^ 2 + ((y - cy) / 3.4) ^ 2)
    local col = ENDG[3]
    if r > 0.82 then col = ENDG[1] elseif r > 0.62 then col = ENDG[2] elseif r < 0.3 then col = ENDG[2] end
    if r <= 0.62 and r >= 0.3 and x - cx < 0 and y - cy < 0 then col = ENDG[4] end
    c:put(x, y, col, tok)
  end)
end
endgrain(11.5, 53)
endgrain(52.5, 53)
-- ambient shade on the flame where it sinks behind the logs
fl:each(function(x, y)
  local k = K(x, y)
  if not bmask:has(x, y) and not fmask:has(x, y) and (bmask:has(x, y + 1) or fmask:has(x, y + 1)) then
    c:put(x, y, FIRE[max(2, fidx[k] - 2)], ftok) end
end)

-- quirk: a little heart-shaped ember drifting up and right
A.map(c, {
  "rr.rr",
  "ryorr",
  "rooor",
  ".ror.",
  "..r..",
}, 51, 12, { r = FIRE[3], o = FIRE[5], y = FIRE[8] }, A.tok("ember"))

A.save(c, "ico-fire")
