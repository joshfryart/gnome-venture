-- long-feather (final, Opus single pass). One long slim flight feather on a gentle S-curve: cream rachis with a lit
-- edge, asymmetric vane (narrow leading edge upper-left, broad trailing edge lower-right), barbs combed toward the
-- tip as fine grooves, cupped vane light (6-tone rose-magenta, cool violet shade), plum tip band, pale downy
-- afterfeather wisps at the base and a hollow translucent quill. quirk: the trailing vane has split open in one
-- place, a V gap where the barbs have unzipped, with a single loose barb curling out of it.
local NAME = "long-feather"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local VANE = { "#3e1440", "#6c1f5a", "#a03276", "#cf5394", "#ef84b4", "#ffbcd6" }
local TIP  = { "#2a1238", "#4a1a52", "#6e2668", "#93387e", "#b85898", "#d888b8" }
local DOWN = { "#8a5a7a", "#c088a8", "#e8b6cc", "#fbe0ea" }
local QUILL = { "#7a5a52", "#b08e7c", "#dcc4a8", "#f6e8cc", "#fff6e2" }
local RACH = { "#a8806e", "#e0c8a8", "#fff0d8" }

local P = { { 13, 57 }, { 20, 44 }, { 34, 22 }, { 53, 9 } }
local WMAX = 8
local m, n0, T, S, sm = A.tube(P, function() return WMAX end, 200)
-- path length
local len = 0
for i = 2, #sm do len = len + sqrt((sm[i].x - sm[i-1].x)^2 + (sm[i].y - sm[i-1].y)^2) end
local T0 = 0.17                       -- vane starts here (quill below)
local function wL(t) if t < T0 or t > 0.985 then return -1 end local u = (t - T0) / (1 - T0) return 0.6 + 3.2 * sin(pi * min(1, u * 0.9 + 0.1)) ^ 0.55 end
local function wR(t) if t < T0 or t > 0.985 then return -1 end local u = (t - T0) / (1 - T0) return 0.6 + 6.2 * sin(pi * min(1, u * 0.85 + 0.12)) ^ 0.7 end

local vane = HP.mask()
local SD = {}
m:each(function(x, y) local k = K(x, y)
  local t = T[k] local sd = S[k] * (WMAX + 0.5)
  local w = sd < 0 and wL(t) or wR(t)
  if w > 0 and abs(sd) <= w then vane:set(x, y) SD[k] = sd / w end
end)
-- quirk: unzipped V gap in the trailing vane (pixels along one barb line removed)
local function phase(t, a) return (t * len - a * 1.35) end
local gap = HP.mask()
vane:each(function(x, y) local k = K(x, y)
  local t, s = T[k], SD[k]
  if s > 0.08 then
    local ph = phase(t, s * wR(t))
    local g0 = 0.56 * len
    local wgap = 0.45 + 2.0 * s * s                    -- wider at the edge (V)
    if abs(ph - g0) < wgap then gap:set(x, y) end
  end
end)
vane:cut(gap)

-- vane light: cupped across the shaft, slight twist toward the tip
local n = {}
local px, py = 0.8, 0.6
vane:each(function(x, y) local k = K(x, y)
  local s = SD[k]
  local cup = s * 0.75
  local tw = -0.15 + 0.25 * T[k]
  local b = sm[floor(T[k] * 200) + 1]
  n[k] = { A.norm(b.px * (cup + tw), b.py * (cup + tw), 1) }
end)
local bias = {}
vane:each(function(x, y) local k = K(x, y)
  local t, s = T[k], SD[k]
  local w = s < 0 and wL(t) or wR(t)
  local ph = phase(t, abs(s) * w)
  local f = ph / 3 - floor(ph / 3)
  if abs(s) > 0.18 and f < 0.3 then bias[k] = -1 end              -- barb grooves
  if abs(s) > 0.18 and f > 0.55 and f < 0.75 and s < 0 then bias[k] = 1 end
  if gap:has(x + 1, y) or gap:has(x - 1, y) or gap:has(x, y + 1) or gap:has(x, y - 1) then bias[k] = (bias[k] or 0) - 1 end
end)
local vtok = { r = { name = "vane" } }
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
local idx = {}
vane:each(function(x, y) local k = K(x, y)
  local i = 1
  for j, ct in ipairs(A.CUTS6) do if v[k] >= ct then i = j + 1 end end
  i = max(1, min(6, i + (bias[k] or 0)))
  idx[k] = i
  local t = T[k]
  local ramp = VANE
  if t > 0.86 or (t > 0.82 and X.hash(x, y, 3) > 0.5) then ramp = TIP end
  c:put(x, y, ramp[i], vtok)
end)
-- translucent fringe on the lit leading edge, darker fringe on the trailing edge
vane:edge():each(function(x, y) local k = K(x, y)
  if T[k] > 0.86 then return end
  if SD[k] < -0.6 then c:put(x, y, VANE[min(6, idx[k] + 1)], vtok)
  elseif SD[k] > 0.7 and idx[k] > 2 then c:put(x, y, VANE[idx[k] - 1], vtok) end
end)

-- afterfeather: downy wisps splaying backward from the base of the vane
local dtok = { r = { name = "down" } }
local wisps = { { 0.15, -1, 5 }, { 0.17, 1, 6 }, { 0.12, 1, 5 }, { 0.13, -1, 4 }, { 0.20, 1, 4 }, { 0.10, 1, 3 } }
for wi, wq in ipairs(wisps) do
  local b = sm[floor(wq[1] * 200) + 1]
  local x, y = b.x, b.y
  local dx, dy = b.px * wq[2] - b.tx * 0.7, b.py * wq[2] - b.ty * 0.7
  local l = sqrt(dx*dx + dy*dy) dx, dy = dx / l, dy / l
  for s = 1, wq[3] do
    local xx, yy = floor(x + dx * s + 0.5), floor(y + dy * s + 0.5 + (s > 3 and 0.35 * (wi % 2) or 0))
    if not vane:has(xx, yy) then c:put(xx, yy, DOWN[wq[2] < 0 and (s > 3 and 4 or 3) or (s > 3 and 2 or 3)], dtok) end
  end
end

-- rachis: 2 px near the base (lit edge + shade edge), 1 px toward the tip
local rtok = { r = { name = "rachis" } }
for i = floor(T0 * 200) - 4, 196 do
  local b = sm[i + 1]
  local x, y = floor(b.x + 0.5), floor(b.y + 0.5)
  c:put(x, y, b.t < 0.6 and RACH[3] or (b.t < 0.85 and RACH[2] or TIP[5]), rtok)
  if b.t < 0.55 then c:put(floor(b.x + b.px + 0.5), floor(b.y + b.py + 0.5), RACH[1], rtok) end
end
-- quill (calamus): hollow, translucent, pale; shade side and a lit streak
local qm, qn = A.tube({ sm[1] and { P[1][1], P[1][2] } or P[1], { 14.5, 55 }, { 16, 52.5 }, { sm[floor(T0 * 200) + 1].x, sm[floor(T0 * 200) + 1].y } },
  function(t) return 1.05 + 0.25 * t end, 60)
local qtok = { r = { name = "quill" } }
X.tone(c, qm, X.light(qn, { amb = 0.15, wrap = 0.35 }), QUILL, { cuts = { 0.3, 0.5, 0.7, 0.86 }, tok = qtok })
c:put(13, 57, QUILL[2], qtok) c:put(14, 56, QUILL[1], qtok)     -- open hollow end
-- loose barb curling out of the gap
local g0b = sm[floor(0.53 * 200) + 1]
local lx, ly = g0b.x + g0b.px * 4.2, g0b.y + g0b.py * 4.2
local lb = { { 0, 0 }, { 1, 1 }, { 2, 1 }, { 3, 2 }, { 3, 3 } }
for _, q in ipairs(lb) do
  local xx, yy = floor(lx + q[1] + 0.5), floor(ly + q[2] + 0.5)
  if not vane:has(xx, yy) then c:put(xx, yy, VANE[4], vtok) end
end
-- one sheen highlight on the lit vane
local bx, by = A.specAt(vane, n, 30)
if bx then c:put(bx, by, "#fff0f4", vtok) end

A.save(c, NAME)
