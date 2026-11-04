-- scarab-shell (final, artist D14_3, Sonnet high). A whole scarab carapace seen from above: a shield-shaped pronotum
-- over a pair of long domed wing-cases that split along a centre seam. Slim, tapering oval; per-pixel lit dome in
-- four iridescent ramps (gold-lime sheen, emerald, teal-blue, violet rim), fine parallel striae, a small scutellum,
-- long glossy streak + pop, cool reflected light on the lower right rim.
-- quirk: a papery amber wing slipped out from under the right case and was left sticking out of the tail.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_aD14_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, sqrt, max, min = math.floor, math.abs, math.sin, math.cos, math.sqrt, math.max, math.min
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "scarab-shell" }

local LIME = A.ramp("#9fcf3a")
local EMER = A.ramp("#2fae78")
local TEAL = A.ramp("#2a86b8")
local VIOL = A.ramp("#6a4cc0")
local WING = A.ramp("#e8b574")
local CREAM, SPEC = "#fff4d6", "#f4ffe0"

-- elytra outline: x half-width by y (y 17..54)
local EY0, EY1 = 16, 48
local function ew(y)
  local t = (y - EY0) / (EY1 - EY0)
  return 14.2 * (1 - t ^ 2.2) ^ .55 * (1 - .05 * t) + .4
end
local el = HP.mask()
for y = EY0, EY1 do local w = ew(y) for x = floor(32 - w + .5), floor(32 + w - .5) do el:set(x, y) end end
-- pronotum (shield, wider at the base)
local PY0, PY1 = 5, 18
local function pw(y)
  local t = (y - PY0) / (PY1 - PY0)
  return 5.2 + 7.6 * sin(min(1, t * 1.1) * math.pi / 2) ^ 1.5
end
local pr = HP.mask()
for y = PY0, PY1 do local w = pw(y) for x = floor(32 - w + .5), floor(32 + w - .5) do pr:set(x, y) end end
-- soften the pronotum top corners
pr:cut(c:rect(0, PY0, 28, PY0)):cut(c:rect(36, PY0, 63, PY0))

---------------------------------------------------------------- wing sticking out of the tail (quirk), painted first
do
  local wm = A.rell(36, 49, .6, .8, 8.5, 3.8)
  wm:cut(el:copy():shrink(0))
  local full = A.rell(36, 49, .6, .8, 8.5, 3.8)
  local n = X.pillow(full, 3)
  local v = X.light(n, { amb = .12, wrap = .4 })
  A.tone(c, wm, v, WING, { .18, .34, .5, .68, .84 })
  -- veins radiating along the wing axis
  wm:each(function(x, y)
    local dx, dy = x - 36, y - 49
    local a = dx * .6 + dy * .8
    local b = -dx * .8 + dy * .6
    local vein = (floor(b * 1.15 + 20) % 3 == 0) and abs(b) < 3.3 and a > -3
    if vein then c:px(x, y, WING[2]) end
    if abs(b) < .6 and a > -4 then c:px(x, y, WING[1]) end
  end)
end

---------------------------------------------------------------- elytra dome
local function colourise(m, n, bandOf, lcuts, tok)
  local v = X.light(n, { amb = .05, wrap = .18 })
  local ramps, idx = {}, {}
  m:each(function(x, y)
    local k = K(x, y)
    local nn = n[k]
    local val = v[k]
    local i = 1
    for j, t in ipairs(lcuts) do if val >= t then i = j + 1 end end
    local rp = bandOf(x, y, nn)
    ramps[k], idx[k] = rp, i
  end)
  return v, ramps, idx
end

local elN = X.pillow(el, 12, 1.0)
local function bandEl(x, y, nn)
  -- iridescence: facing angle plus a diagonal drift toward the lower right
  local s = (1 - nn[3]) * 1.25 + .5 * ((x - 32) / 14 + (y - 32) / 16) * .5
  -- sheen near the lit shoulder
  local lit = nn[1] * X.L[1] + nn[2] * X.L[2] + nn[3] * X.L[3]
  if lit > .94 and s < .24 then return LIME end
  if s < .3 then return EMER end
  if s < .62 then return TEAL end
  return VIOL
end
local cuts = { .2, .36, .52, .68, .84 }
local v, ramps, idx = colourise(el, elN, bandEl, cuts)

-- striae: grooves that follow the outline parallel to the seam
local groove = {}
el:each(function(x, y)
  local w = ew(y)
  local f = abs(x - 32 + .0) / w
  -- groove centres at fractions
  for _, g in ipairs{ .24, .47, .70, .90 } do
    if abs(f - g) < .5 / w * 1.0 and y > EY0 + 6 and y < EY1 - 5 then groove[K(x, y)] = true end
  end
end)
-- seam
for y = EY0 + 2, EY1 - 2 do groove[K(32, y)] = "seam" end
el:each(function(x, y)
  local k = K(x, y)
  local i = idx[k]
  if groove[k] == "seam" then i = 1
  elseif groove[k] then
    if A.hash(x, y, 3) > .12 then i = max(1, i - 2) end
  elseif groove[K(x - 1, y)] and groove[K(x - 1, y)] ~= "seam" then i = min(6, i + 1)   -- lit lip right of a groove
  end
  c:put(x, y, ramps[k][i], { r = { name = "el" } })
end)
-- seam: lit lip on the right, soft shade on the left
for y = EY0 + 2, EY1 - 2 do
  local k = K(33, y)
  if el:has(33, y) then c:put(33, y, ramps[k][min(6, idx[k] + 1)], { r = { name = "el" } }) end
end
-- seam ends in a tiny notch at the top
c:px(32, EY0 + 1, EMER[1]) c:px(32, EY0, EMER[1])

---------------------------------------------------------------- pronotum
local prN = X.pillow(pr, 6, 1.0)
local function bandPr(x, y, nn)
  local s = (1 - nn[3]) * 1.15 + .3 * ((x - 32) / 14 + (y - 12) / 10) * .5
  local lit = nn[1] * X.L[1] + nn[2] * X.L[2] + nn[3] * X.L[3]
  if lit > .93 and s < .3 then return LIME end
  if s < .32 then return EMER end
  if s < .66 then return TEAL end
  return VIOL
end
local pbias = {}
-- ambient shading where the pronotum overlaps the dome: dark row under its lower edge
local pv, pramps, pidx = colourise(pr, prN, bandPr, cuts)
pr:each(function(x, y)
  local k = K(x, y)
  local i = pidx[k]
  -- fine punctures on the pronotum
  if (x * 5 + y * 3) % 9 == 0 and y > PY0 + 2 and y < PY1 - 3 and abs(x - 32) < pw(y) - 3 then i = max(1, i - 1) end
  -- darker rim row along the bottom (ambient where it meets the wing cases)
  if y >= PY1 - 1 and not pr:has(x, y + 1) or (y == PY1 and true) then i = max(1, i - 2) end
  c:put(x, y, pramps[k][i], { r = { name = "pr" } })
end)
-- pronotum midline
for y = PY0 + 2, PY1 - 3 do
  if (y % 3) ~= 0 then local k = K(32, y) c:put(32, y, pramps[k][max(1, pidx[k] - 2)], { r = { name = "pr" } }) end
end
-- contact shadow cast on the wing cases right below the pronotum
for x = 17, 47 do
  if el:has(x, PY1 + 1) and not pr:has(x, PY1 + 1) then local k = K(x, PY1 + 1) c:put(x, PY1 + 1, ramps[k][1], { r = { name = "el" } }) end
  if el:has(x, PY1 + 2) and not pr:has(x, PY1 + 2) and (x % 2 == 0) then local k = K(x, PY1 + 2) c:put(x, PY1 + 2, ramps[k][2], { r = { name = "el" } }) end
end
-- scutellum: little triangle between the cases
local sc = c:poly{ { 29, PY1 + 1 }, { 35, PY1 + 1 }, { 32, PY1 + 5 } }
local scN = X.pillow(sc, 2)
A.tone(c, sc, X.light(scN, { amb = .1, wrap = .3 }), TEAL, { .2, .38, .55, .72, .88 })
sc:each(function(x, y) if not sc:has(x, y + 1) then c:px(x, y, TEAL[1]) end end)

---------------------------------------------------------------- reflected light + glints
local rim = X.rim(elN)
el:edge():each(function(x, y)
  if rim[K(x, y)] and rim[K(x, y)] > .68 and y > 30 and x > 32 then c:px(x, y, "#9fb2f0") end
end)
-- long glossy streak on the left case, 1 px, bending with the dome
for y = 26, 40 do
  local x = 22 + floor((y - 26) * -.18 + .5) + floor(sin((y - 28) / 14 * 1.4) * 1.5)
  if el:has(x, y) then c:px(x, y, (y < 32) and CREAM or SPEC) end
end
c:px(22, 24, CREAM) c:px(23, 24, CREAM) c:px(21, 25, SPEC)
-- cool-white pop on the pronotum shoulder
c:px(28, 8, CREAM) c:px(29, 8, CREAM) c:px(27, 9, SPEC)
-- small secondary sheen on the right case
c:px(38, 32, "#d6f6ff") c:px(38, 33, "#d6f6ff")
-- cream sparkle top-right (the one allowed)
c:sparkle(44, 11)

A.fin(c, "scarab-shell")
