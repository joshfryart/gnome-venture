-- broken-hand-fork (aB11_4, Opus single pass). Garden hand fork on the diagonal: turned ash handle (knob end with pale
-- end grain, hang hole, turned rings, grain lines), a steel ferrule with a groove, a short neck and a bowed yoke
-- feeding three slim, fanned, tapering tines.
-- Material: per-pixel cylinder light on wood and steel, steel bevel + specular streaks, AO where ferrule meets wood.
-- broken: the right tine is snapped mid-way (bright fracture), its tip flies off to the lower right; the handle is
-- split along the grain with a lifted splinter and a wood chip. quirk: an earthworm is draped over the middle tine.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_4.lua")
local HP, X, c = A.new("broken-hand-fork")
local K = A.K
local W, S = A.ASH, A.STEEL
local floor, max, min, sin, abs = math.floor, math.max, math.min, math.sin, math.abs

-- tines (painted first; yoke + neck overlap their roots)
local function tineW(t) return 1.2 - 0.62 * t end
local tines = {
  { { 35.2, 25.2 }, { 37.2, 20 }, { 40, 14.5 }, { 43, 10 } },
  { { 38.2, 27.8 }, { 42.5, 22.5 }, { 46.5, 17.5 }, { 50.5, 13 } },
  { { 41, 30.6 }, { 45.5, 27.5 }, { 50, 24 }, { 54.5, 19.5 } },
}
local BREAK = 0.48
for i, p in ipairs(tines) do
  local wf = tineW
  if i == 3 then wf = function(t) if t > BREAK then return 0 end return tineW(t) end end
  local m, n, T, Sg, idx = A.tube(c, p, wf, S, { amb = 0.12 })
  m:each(function(x, y) local k = K(x, y)
    if Sg[k] < -0.45 and T[k] > 0.12 and T[k] < 0.8 then c:put(x, y, S[6]) end  -- specular streak
    if Sg[k] > 0.6 then A.bump(c, idx, S, x, y, -1) end                          -- shade-side bevel
  end)
end
-- snapped stub: jagged bright fracture
c:put(47, 26, S[6]) c:put(48, 26, S[5]) c:put(48, 25, S[3])
-- yoke
local yoke = { { 35, 25 }, { 37, 26.2 }, { 39.6, 28.8 }, { 41, 31 } }
local ym, yn, yT, yS, yidx = A.tube(c, yoke, function() return 1.35 end, S, { amb = 0.12 })
-- neck + ferrule
local nm, _, _, _, nidx = A.tube(c, A.seg(34.5, 32.5, 38.5, 28.5), function() return 1.45 end, S, { amb = 0.12 })
local fm, fn, fT, fS, fidx = A.tube(c, A.seg(29.5, 37.5, 35, 32), function(t) return 2.75 - 0.4 * t end, S, { amb = 0.1 })
fm:each(function(x, y) local k = K(x, y)
  if fT[k] > 0.45 and fT[k] < 0.62 then A.bump(c, fidx, S, x, y, -2) end           -- groove
  if fS[k] < -0.5 and (fT[k] < 0.4 or fT[k] > 0.66) then c:put(x, y, S[6]) end     -- bright bevel
end)

-- turned ash handle
local hp = A.seg(12.5, 54.5, 30, 37)
local prof = { { 0, 2.6 }, { 0.06, 3.1 }, { 0.14, 2.9 }, { 0.2, 2.25 }, { 0.26, 2.5 }, { 0.55, 3.0 }, { 0.85, 2.55 }, { 1, 2.4 } }
local function hw(t)
  for i = 2, #prof do if t <= prof[i][1] then
    local a, b = prof[i - 1], prof[i]
    return a[2] + (b[2] - a[2]) * (t - a[1]) / (b[1] - a[1]) end end
  return 2.4
end
local hm, hn, hT, hS = A.G.tube(hp, hw)
local bias = {}
A.X.ao(bias, hm, fm, 2, -1)
local hidx = A.shade(c, hm, hn, W, { bias = bias, amb = 0.08 })
local LEN = 24.7
hm:each(function(x, y) local k = K(x, y)
  local t, s = hT[k], hS[k]
  -- grain lines along the length
  for gi, g in ipairs{ -0.42, 0.08, 0.52 } do
    local gg = g + 0.07 * sin(t * LEN / 2.3 + gi * 1.7)
    if abs(s - gg) < 0.09 and t > 0.04 then A.bump(c, hidx, W, x, y, -1) end
  end
  -- turned rings: dark groove + lit lip
  for _, r in ipairs{ 0.2, 0.9 } do
    local d = (t - r) * LEN
    if d > -0.5 and d < 0.5 then A.bump(c, hidx, W, x, y, -2)
    elseif d >= 0.5 and d < 1.5 and s < 0.3 then A.bump(c, hidx, W, x, y, 1) end
  end
  if t < 0.025 then c:put(x, y, s < 0 and W[6] or W[5]) end   -- pale end grain
end)
c:put(12, 54, W[4])
-- hang hole: dark eye with a lit lower lip
local hx, hy = 16, 51
c:put(hx, hy, W[1]) c:put(hx + 1, hy, W[1]) c:put(hx, hy + 1, W[1]) c:put(hx + 1, hy - 1, W[2])
c:put(hx + 1, hy + 1, W[5])
-- pop on the handle shoulder
c:put(24, 40, W[6]) c:put(25, 39, W[6])

-- damage: split along the grain + lifted splinter + chip
for _, p in ipairs{ { 20, 47 }, { 21, 46 }, { 21, 45 }, { 22, 44 }, { 23, 44 }, { 24, 43 } } do
  c:put(p[1], p[2], W[1])
  if hm:has(p[1] + 1, p[2] + 1) then c:put(p[1] + 1, p[2] + 1, W[5]) end
end
for _, p in ipairs{ { 26, 45 }, { 27, 46 }, { 28, 46 } } do c:put(p[1], p[2], W[5]) end   -- splinter lifting off
c:put(27, 45, W[3])
c:put(31, 49, W[5]) c:put(32, 49, W[4]) c:put(32, 50, W[2])                               -- wood chip
-- the snapped tine tip flying off
local tip = tines[3]
local off = { 5, 8 }
local tp = {}
for i, q in ipairs(tip) do tp[i] = { q[1] + off[1], q[2] + off[2] } end
local pm, pn, pT, pS, pidx = A.G.tube(tp, function(t) if t < 0.56 then return 0 end return tineW(t) end)
local pid = A.shade(c, pm, pn, S, { amb = 0.12 })
pm:each(function(x, y) local k = K(x, y) if pS[k] < -0.4 and pT[k] < 0.8 then c:put(x, y, S[6]) end end)
local bx, by = floor(tp[1][1] + (tp[4][1] - tp[1][1]) * 0.56 + 0.5), floor(tp[1][2] + (tp[4][2] - tp[1][2]) * 0.56 + 0.5)
c:put(bx, by, S[6])
c:sparkle(57, 33)

-- quirk: earthworm draped over the middle tine
local worm = { { 41, 18, 2 }, { 42, 18, 1 }, { 43, 19, 1 }, { 44, 20, 3 }, { 45, 21, 3 }, { 46, 21, 1 }, { 47, 22, 2 }, { 47, 23, 2 }, { 46, 24, 1 } }
local WP = { "#f2a0a6", "#d5737f", "#a9485e" }
for _, w in ipairs(worm) do c:put(w[1], w[2], WP[w[3]]) end
c:put(40, 19, "#d5737f")
A.fin(c)
