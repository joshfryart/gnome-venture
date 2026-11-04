-- carob (final, Opus single pass). Two slim, gently curved carob pods hanging in a V from one short woody stalk.
-- Material: per-pixel strap light (6-tone glossy chocolate brown, cool-violet shade), thick rounded margins with a
-- groove + lit lip, seed bumps along the middle with narrow constrictions between them (the silhouette pinches too),
-- fine leathery wrinkles, waxy specular streak on the lit margin, cool reflected light lower-right, AO where the pods
-- meet the stalk and a contact shadow where the back pod tucks under. Stalk: 4-tone bark with a pale cut end.
-- quirk: someone has taken a bite out of the front pod's tip, showing the pale sweet pulp and one seed.
local NAME = "carob"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local POD = { "#1f0f18", "#341619", "#4e2020", "#6c3026", "#8e4a30", "#b46e44" }
local BARK = { "#3a2a2a", "#5e4636", "#86684c", "#b09470" }
local PULP = { "#9c6a3e", "#c99560", "#e8c48a" }
local SPEC, BOUNCE = "#ffe2b8", "#7c4c66"
local PER = 5.6

local function pod(p, L0, wmax, tokname, bite)
  local function hw(t)
    local u = min(1, t / 0.12)
    local base = wmax * (0.45 + 0.55 * sqrt(u)) * (t > 0.86 and (1 - (t - 0.86) / 0.14 * 0.55) or 1)
    return base + 0.3 * cos(t * L0 / PER * 2 * pi)
  end
  local m, n, T, S, samp = A.tube(p, hw)
  local LEN = 0
  for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
  local bitten = HP.mask()
  if bite then
    for _, b in ipairs(bite) do
      local s = samp[floor(b[1] * 160) + 1]
      local cx, cy = s.x + s.px * s.w * b[2], s.y + s.py * s.w * b[2]
      local e = HP.mask()
      for y = floor(cy) - 4, floor(cy) + 4 do for x = floor(cx) - 4, floor(cx) + 4 do
        if (x - cx)^2 + (y - cy)^2 <= b[3]^2 then e:set(x, y) end end end
      bitten:add(e)
    end
    m:cut(bitten)
  end
  local bias = {}
  local v = X.light(n, { amb = 0.06, wrap = 0.22 })
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    local ph = t * LEN / PER
    local f = ph - floor(ph)
    local b = 0
    if abs(s) < 0.52 and t > 0.08 and t < 0.9 then
      if f > 0.9 or f < 0.06 then b = -1                       -- constriction between seeds
      elseif s < -0.05 and f > 0.2 and f < 0.65 then b = 1     -- lit face of the seed bump
      elseif s > 0.3 and f > 0.3 and f < 0.75 then b = -1 end  -- shade side of the bump
    elseif s < -0.55 and s > -0.68 then b = -1                  -- groove inside the lit margin
    elseif s > 0.55 and s < 0.66 then b = -1 end
    bias[k] = b
  end)
  local tok = A.tok(tokname)
  local idx = X.tone(c, m, v, POD, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = bias, tok = tok })
  -- leathery wrinkles: short dark dashes along the length in the middle band
  m:each(function(x, y) local k = K(x, y)
    local t, s = T[k], S[k]
    if abs(s) < 0.45 and t > 0.1 and t < 0.88 and X.hash(x, y, 7) > 0.9 and (bias[k] or 0) == 0 then
      c:put(x, y, POD[max(1, idx[k] - 1)], tok) end end)
  -- cool reflected light on the lower-right edge
  m:edge():each(function(x, y) local k = K(x, y)
    if S[k] > 0.8 and T[k] > 0.12 and T[k] < 0.85 and not bitten:grow(1):has(x, y) then c:put(x, y, BOUNCE, tok) end end)
  -- waxy specular streak on the lit margin
  for i, t in ipairs{ 0.3, 0.33, 0.36, 0.4, 0.43 } do
    local s = samp[floor(t * 160) + 1]
    local x, y = floor(s.x - s.px * s.w * 0.78 + .5), floor(s.y - s.py * s.w * 0.78 + .5)
    if m:has(x, y) then c:put(x, y, i == 3 and SPEC or POD[6], tok) end
  end
  return m, T, S, samp, bitten, tok
end

-- back pod (hangs more steeply, shorter)
local bp = { { 49, 15 }, { 50, 27 }, { 47, 39 }, { 40, 51 } }
local bm, bT, bS = pod(bp, 38, 3.0, "pod2")
-- front pod
local fp = { { 47, 14 }, { 34, 18 }, { 18, 30 }, { 11, 50 } }
local fm, fT, fS, fs, bitten, ftok = pod(fp, 46, 3.3, "pod1", { { 0.03, 0.55, 2.6 }, { 0.075, 0.9, 2.3 } })
-- AO on the back pod where the front pod's root overlaps it
local btok = A.tok("pod2")
bm:each(function(x, y)
  if fm:has(x, y) then return end
  if fm:has(x - 1, y) or fm:has(x, y - 1) or fm:has(x - 1, y - 1) then c:put(x, y, POD[1], btok) end end)
-- bite: pulp rim and one seed
local rim = HP.mask()
bitten:grow(1):each(function(x, y) if fm:has(x, y) then rim:set(x, y) end end)
rim:each(function(x, y)
  local inner = bitten:grow(1):has(x, y) and not bitten:grow(1):shrink(1):has(x, y)
  c:put(x, y, (x + y) % 3 == 0 and PULP[1] or PULP[3], ftok)
end)
-- second ring of pulp, slightly darker, then a seed peeking out
bitten:grow(2):each(function(x, y) if fm:has(x, y) and not rim:has(x, y) then c:put(x, y, PULP[2], ftok) end end)
do local s = fs[floor(0.07 * 160) + 1]
  local sx, sy = floor(s.x + s.px * s.w * -0.1 + .5), floor(s.y + s.py * s.w * -0.1 + .5)
  for _, q in ipairs{ { 0, 0, "#3a1a18" }, { 1, 0, "#6a3424" }, { 0, 1, "#2a1420" }, { 1, 1, "#4a2420" } } do
    if fm:has(sx + q[1], sy + q[2]) then c:put(sx + q[1], sy + q[2], q[3], ftok) end end
  if fm:has(sx, sy) then c:put(sx, sy, "#a8603a", ftok) end
end

-- stalk: short woody twig with a pale cut end, AO on the pods under it
local stok = A.tok("stalk")
local sm, sn = A.tube({ { 48, 15 }, { 49, 12 }, { 51, 9 }, { 53, 7 } }, function(t) return 1.25 - t * 0.2 end)
A.shade(c, sm, sn, BARK, { tok = stok, cuts = { 0.3, 0.55, 0.8 } })
for _, q in ipairs{ { 53, 7, BARK[4] }, { 54, 7, BARK[3] }, { 53, 6, BARK[4] } } do c:put(q[1], q[2], q[3], stok) end
c:put(52, 9, BARK[1], stok)
for _, q in ipairs{ { 47, 16 }, { 48, 17 }, { 49, 16 }, { 46, 16 } } do
  if fm:has(q[1], q[2]) then c:put(q[1], q[2], POD[1], ftok) elseif bm:has(q[1], q[2]) then c:put(q[1], q[2], POD[1], btok) end end
A.save(c, NAME)
