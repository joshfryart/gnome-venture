-- gull-feather (final, Opus single pass). A slim, gently curved gull primary on the diagonal: narrow leading vane,
-- broad trailing vane, pale grey-white with a slate-black tip holding a white "mirror" spot, ivory rachis that
-- ends in a bare translucent quill with a dark hollow end, and wispy down at the base.
-- Material: barb lines swept toward the tip, soft V-light across the vane, a split where barbs have parted,
-- glossy rachis bevel. Draft by Sonnet replaced.
-- quirk: a single bead of seawater sits on the vane, with its own glint and tiny shadow.
local NAME = "gull-feather"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_4.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local VANE  = { "#4a4d68", "#6e7290", "#9a9db4", "#c4c6d4", "#e4e4ea", "#fbf8f0" }
local TIP   = { "#26222e", "#34303f", "#46435a", "#5c5a72", "#7a7a92", "#a2a4b8" }
local SHAFT = { "#8a7a60", "#bca984", "#e2d4b0", "#fbf2dc" }
local QUILL = { "#7a6450", "#b49a74", "#dcc7a0", "#f4e6c4" }
local SEA   = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }

local P = { { 13, 55 }, { 22, 40 }, { 34, 22 }, { 52, 9 } }
local WMAX = 8
local tm, tn, T, S = G.tube(P, function(t) return WMAX end)
local vane = HP.mask()
local SD = {}
local T0 = 0.17                                    -- bare quill below this
local function prof(t)
  if t < T0 then return 0 end
  local u = (t - T0) / (1 - T0)
  local rise = min(1, u / 0.22) ^ 0.6
  local tip = (u > 0.8) and sqrt(max(0, 1 - ((u - 0.8) / 0.2) ^ 2)) or 1
  return rise * tip
end
tm:each(function(x, y) local k = K(x, y)
  local sd = S[k] * (WMAX + 0.5)
  SD[k] = sd
  local p = prof(T[k])
  local wl, wr = 2.8 * p, 6.6 * p
  if (sd < 0 and -sd <= wl) or (sd >= 0 and sd <= wr) then vane:set(x, y) end
end)
-- split: barbs parted in the trailing vane (thin wedge gap)
local split = HP.mask()
vane:each(function(x, y) local k = K(x, y)
  local tt = T[k] - SD[k] * 0.012
  if SD[k] > 1.8 and abs(tt - 0.5) < 0.012 + SD[k] * 0.0035 then split:set(x, y) end end)
vane:cut(split)

local vtok = { r = { name = "vane" } }
local vtip = { r = { name = "tip" } }
-- light: V-fold across the rachis (vane tilts up away from shaft on the leading side)
local n = {}
vane:each(function(x, y) local k = K(x, y)
  local s = SD[k] local p = prof(T[k])
  local w = (s < 0) and 2.8 * p or 6.6 * p
  local u = s / max(1, w)                          -- -1..1
  local px, py = 0.76, 0.65                        -- across direction (+ = lower-right)
  local tilt = (s < 0) and -0.35 or (0.15 + 0.35 * u)
  n[k] = { A.norm(px * tilt, py * tilt, 1) }
end)
local v = X.light(n, { amb = 0.15, wrap = 0.3 })
local len = 46
local idx = {}
vane:each(function(x, y) local k = K(x, y)
  local i = 1
  for j, t in ipairs{ 0.16, 0.28, 0.4, 0.52, 0.66 } do if v[k] >= t then i = j + 1 end end
  -- barb lines swept toward the tip
  local ph = (T[k] * len - abs(SD[k]) * 0.9) / 2.6
  if ph - floor(ph) < 0.28 and abs(SD[k]) > 1.2 then i = i - 1 end
  -- frayed edge: outermost row slightly darker on the trailing side
  if SD[k] > 0 and SD[k] > 6.6 * prof(T[k]) - 1 then i = i - 1 end
  i = max(1, min(6, i)) idx[k] = i
  -- slate tip region, edge follows the barbs; mirror spot on the trailing side
  local tipEdge = 0.73 + SD[k] * 0.012
  if T[k] > tipEdge then
    local mx, my = (T[k] - 0.86) * 46, SD[k] - 3.2
    if mx * mx / 6 + my * my / 2.6 < 1 then c:put(x, y, VANE[min(6, i + 1)], vtok)
    else c:put(x, y, TIP[i], vtip) end
  else c:put(x, y, VANE[i], vtok) end
end)
-- contact darkening along the split's lower lip
split:shift(1, 1):each(function(x, y) if vane:has(x, y) and not split:has(x, y) then
  local k = K(x, y) c:put(x, y, (T[k] > 0.73) and TIP[1] or VANE[2], vtok) end end)

-- rachis: tapered ivory shaft along the curve, lit side brighter; bare quill at the base
local stok = { r = { name = "shaft" } }
local rm, rn, RT, RS = G.tube(P, function(t) return (t < T0) and 1.3 or max(0.35, 1.0 * (1 - t) + 0.3) end)
rm:each(function(x, y) local k = K(x, y)
  local t, s = RT[k], RS[k]
  if t < T0 then
    local i = (s < -0.3) and 4 or ((s < 0.35) and 3 or 2)
    if t < 0.03 then i = 1 end
    c:put(x, y, QUILL[i], stok)
  else
    local i = (s < -0.1) and 4 or 3
    if t > 0.75 then i = i - 1 end
    if s > 0.5 then i = 2 end
    c:put(x, y, (T[k] and t > 0.73) and TIP[min(6, i + 2)] or SHAFT[i], stok)
  end
end)
-- hollow quill end + translucent core line
c:put(13, 56, QUILL[1], stok)
for _, p in ipairs{ { 15, 52 }, { 16, 50 }, { 17, 49 } } do c:put(p[1], p[2], QUILL[4], stok) end
-- afterfeather down: wispy tufts at the base, pale, a few loose barbs
local dtok = { r = { name = "down" } }
for _, p in ipairs{ {16,46,5},{15,45,4},{14,45,5},{13,44,4},{19,48,4},{20,49,5},{21,50,3},{22,50,4},{12,43,3},{23,51,3} } do
  c:put(p[1], p[2], VANE[p[3]], dtok) end
-- quirk: seawater bead on the broad vane, with a cast shadow
local bx, by = 33, 31
c:put(bx + 1, by + 2, VANE[2], vtok) c:put(bx + 2, by + 1, VANE[2], vtok) c:put(bx + 2, by + 2, VANE[2], vtok)
local bm = c:ellipse(bx, by, 1.5, 1.5)
local btok = { r = { name = "bead" } }
A.shade(c, bm, X.sphere(bx, by, 2, bm), SEA, { tok = btok, cuts = { 0.25, 0.5, 0.75 } })
c:put(bx - 1, by - 1, "#fff4d6", btok) c:put(bx + 1, by + 1, SEA[4], btok)

A.save(c, NAME)
