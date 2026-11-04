-- coconut (batch2, final, Opus). A slim upright husked nut (egg leaning a touch left, eye end tipped to the viewer)
-- with a cracked-open half resting in front of it, cut face up: thin dark shell edge, thick cream flesh ring, a
-- cupped hollow that is lit on the far wall (concave). Material: per-pixel ellipsoid light on a 6-tone coir-brown
-- ramp, coarse fibre streaks that follow the meridians, one trigonal ridge, three sunken eyes with a lit lower
-- lip, short coir hairs breaking the silhouette, cool violet bounce lower right, AO + contact shadow where the half
-- sits against the nut, one 2x1 specular on the nut shoulder and a wet glint on the flesh.
-- Draft (Sonnet, fat cut-top with straw, sitting low-left) replaced.
-- quirk: a tuft of coir at the crown curls over into a little cowlick.
local NAME = "coconut"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_b2g4.lua")
local HP, X, c = G.new(NAME)
local K = G.K
local floor, abs, sin, cos, pi, max, min, sqrt, asin = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.asin

local BR    = { "#2a171d", "#43221f", "#622f24", "#83452c", "#a8633a", "#cf8f55" }
local CREAM = { "#6c5f80", "#978aa6", "#c3b8c7", "#e6ddda", "#f7efe3", "#fffaf0" }
local BOUNCE, SPEC = "#7e6a8c", "#fbe3b4"
local EYE  = { "#1d1117", "#3a2026" }
local tok, htok = { r = { name = "nut" } }, { r = { name = "half" } }

-- ---------- the cracked half (built first so the nut can take its shadow)
local HX, HY, HRX, HRY = 40, 43.5, 11.6, 5.6        -- opening ellipse
local open, bowl = HP.mask(), HP.mask()
for y = 20, 63 do for x = 20, 63 do
  local dx, dy = (x - HX) / (HRX + 0.4), (y - HY) / (HRY + 0.4)
  if dx * dx + dy * dy <= 1 then open:set(x, y) end
  local by = (y - HY) / 10.6
  if y >= HY and dx * dx + by * by <= 1 then bowl:set(x, y) end
end end
bowl:cut(open)
local half = open:copy():add(bowl)

-- ---------- nut
local AX, AY, BX, BY = 24, 11, 28, 50
local len = sqrt((BX - AX)^2 + (BY - AY)^2)
local function wfn(t)
  if t > 0.995 then return -1 end
  return max(0.6, 12.6 * sin(pi * min(1, (t + 0.02) ^ 0.92)) ^ 0.5)
end
local ux, uy = (BX - AX) / len, (BY - AY) / len
local PX, PY = -uy, ux if PX + PY < 0 then PX, PY = -PX, -PY end   -- +s = lower-right
local nut, T, S = HP.mask(), {}, {}
for y = 0, 63 do for x = 0, 63 do
  local rx, ry = x - AX, y - AY
  local t = (rx * ux + ry * uy) / len
  local s = rx * PX + ry * PY
  if t >= 0 and t <= 1 then
    local w = wfn(t)
    if w > 0 and abs(s) <= w then nut:set(x, y) T[K(x, y)], S[K(x, y)] = t, s / (w + 0.5) end
  end
end end
nut:cut(half)
local n = {}
nut:each(function(x, y) local k = K(x, y)
  local a = (T[k] - 0.47) / 0.62
  local sn = S[k]
  local nx, ny = PX * sn + ux * a, PY * sn + uy * a
  n[k] = { G.norm(nx, ny, sqrt(max(1 - nx * nx - ny * ny, 0.03))) }
end)
local v = X.light(n, { amb = 0.06, wrap = 0.22 })
local bias = {}
local function fibres(m, TT, SS, b, vv, seed)
  m:each(function(x, y) local k = K(x, y)
    local t, s = TT[k], SS[k]
    local phi = asin(max(-1, min(1, s))) / (pi / 2)
    local lane = floor((phi + 1) * 13)
    local seg = floor(t * 40 / (5 + X.hash(lane, 1, seed) * 6) + X.hash(lane, 2, seed) * 3)
    local h = X.hash(lane, seg, seed + 2)
    if t > 0.12 and t < 0.98 then
      if h > 0.72 then b[k] = -1 elseif h < 0.07 and vv[k] > 0.45 then b[k] = 1 end
    end
  end)
end
fibres(nut, T, S, bias, v, 3)
nut:each(function(x, y) local k = K(x, y)               -- ridge
  local d = S[k] - (-0.30 + 0.10 * sin(T[k] * pi))
  if T[k] > 0.2 and T[k] < 0.92 then
    if d > -0.07 and d <= 0 then bias[k] = 1 elseif d > 0 and d < 0.07 then bias[k] = -1 end
  end
end)
X.ao(bias, nut, half, 2, -1)
G.cast(bias, nut, half, -1, -1, -1)
X.tone(c, nut, v, BR, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bias, tok = tok })
local rim = X.rim(n)
nut:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.62 and T[k] > 0.3 and T[k] < 0.8 and not half:grow(2):has(x, y) then c:put(x, y, BOUNCE, tok) end
end)
-- eyes
local function pt(t, s) local w = wfn(t) return floor(AX + ux * t * len + PX * s * w + 0.5), floor(AY + uy * t * len + PY * s * w + 0.5) end
for _, e in ipairs{ { 0.15, -0.38 }, { 0.14, 0.2 }, { 0.25, -0.08 } } do
  local x, y = pt(e[1], e[2])
  c:put(x, y, EYE[1], tok) c:put(x + 1, y, EYE[1], tok) c:put(x, y + 1, EYE[2], tok) c:put(x + 1, y + 1, EYE[1], tok)
  c:put(x, y + 2, BR[5], tok) c:put(x + 1, y + 2, BR[5], tok) c:put(x + 2, y + 1, BR[4], tok) c:put(x - 1, y, BR[2], tok)
end
-- coir hairs on the silhouette
local hair = HP.mask()
for _, sp in ipairs{ { 0.10, -1, 2 }, { 0.33, -1, 2 }, { 0.58, -1, 1 }, { 0.30, 1, 2 }, { 0.12, 1, 1 } } do
  local t, side, L = sp[1], sp[2], sp[3]
  local w = wfn(t)
  for j = 1, L do
    local x = floor(AX + ux * (t * len - j * 0.7) + PX * side * (w + j - 0.4) + 0.5)
    local y = floor(AY + uy * (t * len - j * 0.7) + PY * side * (w + j - 0.4) + 0.5)
    local touch = nut:has(x+1,y) or nut:has(x-1,y) or nut:has(x,y+1) or nut:has(x,y-1) or (j > 1 and hair:has(x+1,y) or hair:has(x-1,y) or hair:has(x,y+1) or hair:has(x,y-1))
    if not nut:has(x, y) and not half:has(x, y) and touch then c:put(x, y, side < 0 and BR[4] or BR[2], tok) hair:set(x, y) end
  end
end
-- crown tuft + cowlick (quirk)
local tt = { r = { name = "tuft" } }
local cx, cy = pt(0.0, 0)
G.pl(c, { { cx - 2, cy }, { cx - 4, cy - 3 }, { cx - 5, cy - 5 } }, BR[4], tt)
G.pl(c, { { cx + 2, cy }, { cx + 4, cy - 3 }, { cx + 6, cy - 4 } }, BR[3], tt)
G.pl(c, { { cx, cy }, { cx, cy - 4 }, { cx + 1, cy - 7 }, { cx + 3, cy - 8 }, { cx + 5, cy - 7 }, { cx + 5, cy - 5 }, { cx + 3, cy - 4 } }, BR[5], tt)
c:put(cx, cy - 2, BR[6], tt) c:put(cx + 1, cy - 7, BR[6], tt) c:put(cx + 5, cy - 6, BR[3], tt) c:put(cx + 4, cy - 5, BR[3], tt)
local sx, sy = G.specAt(nut, n, 30)
c:put(sx, sy, SPEC, tok) c:put(sx + 1, sy, BR[6], tok) c:put(sx, sy + 1, BR[6], tok)

-- ---------- half: outer bowl (convex), shell lip, flesh ring, hollow (concave)
local bn, bt, bs = {}, {}, {}
bowl:each(function(x, y) local k = K(x, y)
  local dx, dy = (x - HX) / (HRX + 0.5), (y - HY) / 11
  bn[k] = { G.norm(dx, dy * 0.8 + 0.15, sqrt(max(0.05, 1 - dx * dx - dy * dy))) }
  bt[k], bs[k] = 0.15 + dy * 0.8, dx
end)
local bv = X.light(bn, { amb = 0.06, wrap = 0.22 })
local bb = {}
fibres(bowl, bt, bs, bb, bv, 9)
X.tone(c, bowl, bv, BR, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bb, tok = htok })
local brim = X.rim(bn)
bowl:edge():each(function(x, y) if brim[K(x, y)] > 0.55 and y > HY + 3 then c:put(x, y, BOUNCE, htok) end end)
-- opening rings
local function q(x, y, sh) local dx, dy = (x - HX) / (HRX + 0.4 - sh), (y - HY) / (HRY + 0.4 - sh * 0.62) return dx * dx + dy * dy end
open:each(function(x, y)
  local col
  if q(x, y, 1) > 1 then col = (y < HY) and BR[3] or BR[4]                   -- hard shell edge
  elseif q(x, y, 3.2) > 1 then                                              -- flesh ring, cut face lit flat
    col = (y < HY - 2) and CREAM[6] or ((x > HX + 6 or y > HY + 2) and CREAM[4] or CREAM[5])
  else                                                                       -- hollow: concave, far (lower-right) wall lit
    local dx, dy = (x - HX) / (HRX - 3), (y - HY) / (HRY - 2)
    local val = 0.5 + 0.5 * (dx * 0.45 + dy * 0.75)
    col = val < 0.22 and CREAM[1] or val < 0.42 and CREAM[2] or val < 0.62 and CREAM[3] or val < 0.8 and CREAM[4] or CREAM[5]
  end
  c:put(x, y, col, htok)
end)
-- inner shadow line under the near rim and a wet glint on the far wall
open:each(function(x, y) if q(x, y, 3.2) <= 1 and q(x, y - 1, 3.2) > 1 and y < HY then c:put(x, y, CREAM[1], htok) end end)
c:put(HX + 5, 46, CREAM[6], htok) c:put(HX + 6, 46, CREAM[6], htok)
G.save(c, NAME)
