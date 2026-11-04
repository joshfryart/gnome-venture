-- mackerel (final pass, Opus aC21_5). A slim, torpedo-shaped Atlantic mackerel swimming left on a gentle upward
-- tilt: blue-green back with dark wavy tiger bars, a thin iridescent gold-green flank line, a silver belly with a pale
-- sheen, pointed snout with a mouth line, gill-cover arc, large eye (gold ring, ink pupil, cream glint), two dorsal
-- fins, the row of little finlets in front of the deeply forked tail, a pectoral fin with ray lines.
-- Material: per-pixel cylinder + pillow light on 6-tone back and belly ramps, specular streak along the back, cool
-- reflected light on the belly rim, AO under the pectoral fin and where the tail meets the narrow peduncle.
-- History: Sonnet draft (dC21) replaced.
-- quirk: one small air bubble rising from its mouth.
local NAME = "mackerel"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local BACK  = { "#16223e", "#1e3a5e", "#26587a", "#2f7a92", "#4ea0a8", "#86ccc2" }
local BELLY = { "#4e5674", "#7c86a2", "#a6b0c4", "#c8d0dc", "#e2e8ea", "#f6f6ee" }
local FIN   = { "#1c2c4a", "#2e4c6c", "#4c7490", "#7aa2b2", "#a8ccd0" }
local BAR, IRI, IRI2 = "#121a32", "#c8d890", "#8cbc8a"
local CREAM, GOLD = "#fff4d6", "#e8c060"
local SEA = { "#3a86b0", "#b6f0e0", "#e4f6ff" }

local X0, X1 = 7, 47
local function cy(x) return 36 - 0.13 * (x - X0) end
local function hh(x)
  local t = (x - X0) / (X1 - X0)
  if t < 0 or t > 1 then return -1 end
  local h = 6.4 * sin(pi * min(1, t ^ 0.62)) ^ 0.75
  if t > 0.85 then h = max(1.4, h) end
  return max(0.6, h)
end
local body, S = HP.mask(), {}
for x = X0, X1 do local h = hh(x) local y0 = cy(x)
  for y = floor(y0 - h - 1), floor(y0 + h + 1) do
    if abs(y - y0) <= h then body:set(x, y) S[K(x, y)] = (y - y0) / (h + 0.5) end end end

-- tail fork
local tcx, tcy = X1 + 1, cy(X1)
local tail = c:poly{ { tcx - 2, tcy - 1 }, { tcx + 4, tcy - 5 }, { tcx + 9, tcy - 10 }, { tcx + 10, tcy - 9 },
  { tcx + 6, tcy - 2 }, { tcx + 5, tcy }, { tcx + 6, tcy + 2 }, { tcx + 10, tcy + 9 }, { tcx + 9, tcy + 10 },
  { tcx + 4, tcy + 5 }, { tcx - 2, tcy + 1 } }
tail:cut(body)
-- fins
local d1 = c:poly{ { 22, cy(22) - 5 }, { 25, cy(25) - 10 }, { 27, cy(27) - 10 }, { 31, cy(31) - 6 } }
local d2 = c:poly{ { 33, cy(33) - 4 }, { 35, cy(35) - 7 }, { 37, cy(37) - 4 } }
local an = c:poly{ { 33, cy(33) + 4 }, { 35, cy(35) + 7 }, { 37, cy(37) + 4 } }
local finlets = HP.mask()
for _, x in ipairs{ 40, 43 } do
  local h = hh(x)
  finlets:set(x, floor(cy(x) - h - 1 + .5)) finlets:set(x + 1, floor(cy(x) - h - 1 + .5))
  finlets:set(x, floor(cy(x) + h + 1 + .5)) finlets:set(x + 1, floor(cy(x) + h + 1 + .5))
end
for _, m in ipairs{ d1, d2, an, finlets } do m:cut(body) end

-- body light
local np = X.pillow(body, 3)
local n = {}
body:each(function(x, y) local k = K(x, y) local s = S[k] local p = np[k]
  n[k] = { A.norm(p[1] * 0.7, s * 0.85 + p[2] * 0.2, sqrt(max(0.05, 1 - s * s))) } end)
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
local pec = c:poly{ { 18, cy(18) + 1 }, { 25, cy(25) + 3 }, { 26, cy(26) + 4 }, { 19, cy(19) + 3 } }
local bias = {}
X.ao(bias, body, pec, 1, -1) A.cast(bias, body, pec, 1, 1, -1)
local bt = { r = { name = "body" } }
local CUT = { 0.18, 0.34, 0.5, 0.66, 0.82 }
body:each(function(x, y) local k = K(x, y) local s = S[k]
  local i = A.q(v[k], CUT) + (bias[k] or 0)
  if x > X1 - 3 then i = i - 1 end
  i = max(1, min(6, i))
  local col
  if s < -0.08 then
    col = BACK[i]
    -- wavy tiger bars on the back (not on the head)
    local w = sin(x * 1.05 + 2.4 * sin(y * 0.75 + x * 0.2))
    if x > 19 and x < X1 - 1 and w > 0.62 and s < -0.25 then col = (i >= 5) and BACK[2] or BAR end
  elseif s < 0.1 then
    col = (x > 15 and x < X1 - 2) and ((i >= 4) and IRI or IRI2) or BELLY[i]
  else
    col = BELLY[min(6, i + 1)]
  end
  c:put(x, y, col, bt)
end)
-- specular streak along the back
for x = 21, 38 do local y = floor(cy(x) - hh(x) * 0.55 + .5)
  if (x % 4 ~= 0) and body:has(x, y) then c:put(x, y, BACK[6], bt) end end
-- cool reflected belly rim
body:edge():each(function(x, y) local k = K(x, y) if S[k] > 0.6 and x > 12 and x < X1 - 3 then c:put(x, y, "#7c8cb8", bt) end end)
-- head: gill arc, mouth, eye
for y = floor(cy(18) - 5), floor(cy(18) + 5) do
  local dy = y - cy(18)
  local x = floor(18 - 0.09 * dy * dy + .5)
  if body:has(x, y) then c:put(x, y, (dy < 0) and BACK[2] or BELLY[2], bt) end
  if body:has(x - 1, y) and dy > -2 and dy < 3 then c:put(x - 1, y, BELLY[5], bt) end
end
for x = X0, X0 + 4 do c:put(x, floor(cy(x) + 1.5), BELLY[1], bt) end
local ex, ey = 13, floor(cy(13) - 1 + .5)
for _, q in ipairs{ { -1, -1 }, { 0, -1 }, { 1, -1 }, { -1, 0 }, { 2, 0 }, { -1, 1 }, { 2, 1 }, { 0, 2 }, { 1, 2 }, { 2, -1 }, { -1, 2 }, { 2, 2 } } do
  c:put(ex + q[1], ey + q[2], GOLD, bt) end
c:put(ex, ey, "#2b1c26", bt) c:put(ex + 1, ey, "#2b1c26", bt) c:put(ex, ey + 1, "#2b1c26", bt) c:put(ex + 1, ey + 1, "#2b1c26", bt)
c:put(ex, ey, CREAM, bt)
c:put(ex + 2, ey - 1, "#c09048", bt) c:put(ex + 2, ey + 2, "#c09048", bt)

-- fins
local function fin(m, name, rays)
  local tok = { r = { name = name } }
  local fn = X.pillow(m, 1.5)
  local idx = A.shade(c, m, fn, FIN, { tok = tok, cuts = { 0.25, 0.45, 0.65, 0.85 }, amb = 0.15, wrap = 0.3 })
  if rays then m:each(function(x, y) if (x + y) % 2 == 0 and not m:edge():has(x, y) then A.step(c, idx, FIN, x, y, -1, tok) end end) end
  return idx, tok
end
fin(d1, "d1", true) fin(d2, "d2") fin(an, "an") fin(finlets, "finlets")
local tidx, ttok = fin(tail, "tail", false)
-- tail rays + AO at the peduncle joint
tail:each(function(x, y) local dx, dy = x - tcx, y - tcy
  if abs(dy) > 1 and (abs(dy) - dx * 0.95) % 3 < 1 and not tail:edge():has(x, y) then A.step(c, tidx, FIN, x, y, -1, ttok) end
  if dx <= 0 then A.step(c, tidx, FIN, x, y, -1, ttok) end end)
-- pectoral fin over the body
local pidx, ptok = fin(pec, "pec", false)
pec:each(function(x, y) if (x - 2 * (y - cy(x))) % 3 == 0 then A.step(c, pidx, FIN, x, y, 1, ptok) end end)

-- quirk: bubble above the mouth
local bb = { r = { name = "bubble" } }
for _, q in ipairs{ { 0, -1 }, { -1, 0 }, { 1, 0 }, { 0, 1 } } do c:put(8 + q[1], 27 + q[2], SEA[1], bb) end
c:put(8, 27, SEA[2], bb) c:put(7, 26, SEA[3], bb)

A.save(c, "ph", NAME)
