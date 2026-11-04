-- pomegranate (D10 final, Sonnet high). A round leathery fruit with a six-point crown calyx; a wedge is cut out of the lower
-- right showing the pale rind section, membrane-white pith and a packed grid of glossy ruby arils (own highlight each).
-- Material: per-pixel ellipsoid light on a 6-tone crimson ramp, golden blush patch near the shoulder (orange ramp),
-- leathery mottle, cool violet bounce on the lower-left rim, waxy specular, AO + cast shadow under the crown, contact
-- shadow of the upper wall on the cut face. quirk: one aril has rolled out of the wound (and a second is about to).
local NAME = "pomegranate"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aD10_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local SK = { "#4a0f26", "#7c1632", "#aa2036", "#d03340", "#ea524c", "#fb8a70" }
local BL = { "#5a1c22", "#8a2e22", "#bc4a26", "#de6a2c", "#f59a40", "#ffcb74" }
local CAL = { "#4a1426", "#7c2230", "#a83a36", "#cc5a40", "#e68050", "#f8b078" }
local ARIL = { "#4e0820", "#86102e", "#bc1e3c", "#e03450", "#fb6470", "#ffc4b4" }
local CX, CY, RX, RY = 27.5, 38.5, 15, 14
local ctok = { r = { name = "crown" } }

-- crown first (for the cast shadow): six tapered sepals fanning from the calyx cup
local BASEX, BASEY = 27.5, 25
local sep = {  -- ax,ay, cx,cy, bx,by  (drawn back to front: outer, mid, centre)
  { 25.5, 26, 21, 20, 17.5, 13 },
  { 29.5, 26, 34, 20, 37.5, 13.5 },
  { 26, 26, 23.5, 17, 22.5, 9.5 },
  { 29, 26, 31.5, 17, 33, 9.5 },
  { 27.5, 26, 27.5, 17, 27.5, 7 },
}
local crown = HP.mask()
local smasks = {}
for i, s in ipairs(sep) do
  local m, n, T, S = A.blade(s[1], s[2], s[3], s[4], s[5], s[6], function(t)
    if t > 0.985 then return -1 end
    return max(0.4, 3.2 * (1 - t) ^ 0.75)
  end, { fold = 0.4 })
  smasks[i] = { m = m, n = n, T = T, S = S }
  crown:add(m)
end

-- body: ellipsoid + shoulder neck
local body = c:ellipse(CX, CY, RX, RY)
body:add(c:ellipse(CX, 27, 7, 3))
local n = {}
body:each(function(x, y)
  local nx, ny = (x - CX) / (RX + 0.5), (y - CY) / (RY + 0.5)
  local q = 1 - nx * nx - ny * ny
  if q > 0.04 then n[K(x, y)] = { A.norm(nx, ny, sqrt(q)) }
  else n[K(x, y)] = { A.norm(nx * 0.4, -0.35, 0.9) } end
end)
local v = X.light(n, { amb = 0.06, wrap = 0.28 })
local bias = {}
-- AO under crown, cast shadow of the sepals
local cup = c:ellipse(BASEX, 25.5, 5, 2)
X.ao(bias, body, cup, 2, -1)
A.cast(bias, body, crown, 1, 2, -1)
-- mottle + scuffs
body:each(function(x, y)
  local h = X.hash(x, y, 3)
  local k = K(x, y)
  if h < 0.07 then bias[k] = (bias[k] or 0) - 1 elseif h > 0.95 then bias[k] = (bias[k] or 0) + 1 end
end)
local idx = X.tone(c, body, v, SK, { cuts = { 0.28, 0.45, 0.62, 0.78, 0.92 }, bias = bias, tok = { r = { name = "skin" } } })
-- golden blush patch on the shoulder (hard-edged, noisy border)
body:each(function(x, y)
  local k = K(x, y)
  local t = (x - CX) * 0.8 + (y - CY) * 0.9 + (X.hash(x, y, 7) - 0.5) * 7
  if t < -16.5 and idx[k] then c:put(x, y, BL[idx[k]], { r = { name = "blush" } }) end
end)
-- two leathery creases running down from the crown
local function crease(pts, d)
  for _, p in ipairs(pts) do
    local k = K(p[1], p[2])
    if idx[k] then c:put(p[1], p[2], SK[max(1, idx[k] - 1)], { r = { name = "skin" } }) end
  end
end
crease({ { 18, 33 }, { 18, 34 }, { 19, 35 }, { 19, 36 }, { 19, 37 }, { 20, 38 } })
crease({ { 35, 28 }, { 35, 29 }, { 36, 30 }, { 36, 31 } })

-- cut wedge, lower right
local C = c:poly{ { 28, 37 }, { 53, 28 }, { 53, 62 }, { 33, 62 } }:clip(body)
local dist = X.dist(body)
local inner = HP.mask()
C:each(function(x, y) local d = dist[K(x, y)] if d and d > 2.6 then inner:set(x, y) end end)
local ftok = { r = { name = "face" } }
local PITH, RING = "#f8e2bc", { "#c43a44", "#f9e0cc", "#efc2ac" }
C:each(function(x, y)
  local d = dist[K(x, y)]
  if d < 0.7 then c:put(x, y, RING[1], ftok)
  elseif d < 1.7 then c:put(x, y, RING[2], ftok)
  elseif d < 2.7 then c:put(x, y, RING[3], ftok)
  else c:put(x, y, PITH, ftok) end
end)
-- membranes: thin rose lines radiating from the core
for _, ln in ipairs{ { { 31, 40 }, { 42, 33 } }, { { 31, 41 }, { 46, 43 } }, { { 31, 42 }, { 38, 52 } } } do
  A.pline(c, ln, "#e8b79e", ftok)
end
-- the upper wall casts a shadow on the face; left wall too
local wallA = HP.mask()
C:each(function(x, y)
  -- distance below the upper boundary line (28,37)-(53,28): y - (37 - 0.36*(x-28))
  local ly = 37 - 0.36 * (x - 28)
  if y - ly < 2.2 and dist[K(x, y)] > 1.7 then wallA:set(x, y) end
end)
wallA:each(function(x, y) c:put(x, y, "#d9a07e", ftok) end)
local wallB = HP.mask()
C:each(function(x, y)
  -- left wall: line (28,37)-(33,62): x - (28 + 0.2*(y-37))
  local lx = 28 + 0.2 * (y - 37)
  if x - lx < 2.2 and dist[K(x, y)] > 1.7 then wallB:set(x, y) end
end)
wallB:each(function(x, y) if not wallA:has(x, y) then c:put(x, y, "#e2b090", ftok) end end)
-- arils on a packed grid
local ar = {}
local row = 0
local ringc = C:copy()
for gy = 36, 56, 4.4 do
  row = row + 1
  for gx = 31 + (row % 2) * 2.4, 54, 4.7 do
    local cx, cy = floor(gx + 0.5), floor(gy + 0.5)
    local cnt = 0
    for dy = -2, 2 do for dx = -2, 2 do if inner:has(cx + dx, cy + dy) and abs(dx) + abs(dy) <= 3 then cnt = cnt + 1 end end end
    if cnt >= 19 and not wallA:has(cx, cy - 2) then ar[#ar + 1] = { cx, cy } end
  end
end
local function aril(cx, cy, r, tag)
  local m = c:ellipse(cx, cy, r, r)
  local nn = X.sphere(cx - 0.4, cy - 0.4, r + 0.1, m)
  local b = {}
  X.tone(c, m, X.light(nn, { amb = 0.06, wrap = 0.3 }), ARIL, { cuts = A.CUTS6, bias = b, tok = { r = { name = tag } } })
  -- lit rim, specular, dark seed hint
  c:put(cx - 1, cy - 1, ARIL[6], { r = { name = tag } })
  c:put(cx, cy - 1, ARIL[5], { r = { name = tag } })
  c:put(cx - 1, cy, ARIL[5], { r = { name = tag } })
  return m
end
for i, a in ipairs(ar) do aril(a[1], a[2], 2, "aril" .. i) end
-- cut-face rind lip shadow under the skin edge
-- reflected cool light, lower-left rim of the skin
local rim = X.rim(n, { A.norm(-0.5, 0.75, -0.1) })
body:edge():each(function(x, y) if not C:has(x, y) and rim[K(x, y)] > 0.7 and idx[K(x, y)] and idx[K(x, y)] < 5 then c:put(x, y, "#8e3c70", { r = { name = "skin" } }) end end)
-- specular + waxy bloom
for _, p in ipairs{ { 21, 31 }, { 22, 31 } } do c:put(p[1], p[2], "#fff0e6", { r = { name = "skin" } }) end
c:put(21, 32, SK[6], { r = { name = "skin" } }) c:put(23, 31, SK[6], { r = { name = "skin" } })
c:put(25, 29, "#ffd8c8", { r = { name = "skin" } })

-- calyx cup + crown drawn over
local cupm = c:ellipse(BASEX, 25.5, 4, 1.6)
c:fillMask(cupm, CAL[1])
c:put(26, 25, CAL[2], ctok) c:put(27, 25, CAL[2], ctok)
local prev = HP.mask()
for _, i in ipairs{ 1, 2, 3, 4, 5 } do
  local s = smasks[i]
  local idx2 = X.tone(c, s.m, X.light(s.n, { amb = 0.1, wrap = 0.3 }), CAL, { cuts = A.CUTS6, tok = ctok })
  -- leathery central ridge
  s.m:each(function(x, y) local k = K(x, y) if abs(s.S[k]) < 0.18 and s.T[k] > 0.1 and s.T[k] < 0.8 then c:put(x, y, CAL[min(6, (idx2[k] or 3) + 1)], ctok) end end)
  A.touch(s.m, prev):each(function(x, y) c:put(x, y, CAL[1], ctok) end)
  prev:add(s.m)
end
-- ring of tiny calyx teeth around the cup (a nub each side)
c:put(23, 25, CAL[3], ctok) c:put(32, 25, CAL[2], ctok)

-- quirk: a dropped aril, and one hanging at the edge of the cut
aril(46, 54, 2, "drop1")
aril(51, 49, 2, "drop2")
c:sparkle(53, 45)

A.save(c, NAME)
