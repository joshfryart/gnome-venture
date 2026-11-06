-- ackee (final pass, Opus). One ripe ackee pod standing on its short stalk, split open at the top: two front
-- lobes of waxy scarlet-orange skin peel outward (their pale inner faces show along the curled lips), the back lobe
-- stands behind, and three creamy, wrinkled arils each carry a glossy black seed.
-- Material: pod per-pixel pear light (6 tones), waxy bloom on the lit shoulder, cool reflected light on the shade
-- flank, suture groove; inner pod face pink-yellow; arils folded (brain-like creases); seeds glossy with a glint
-- and a violet rim light; AO where arils sit in the pod and where seeds sit on arils.
-- History: Sonnet draft replaced.
-- quirk: a tiny ant is climbing the pod toward the seeds.
local NAME = "ackee"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR1_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local POD  = { "#5a1830", "#8c2232", "#c0302e", "#e24e2a", "#f67c34", "#ffb25a" }
local INR  = { "#8a3a3a", "#c0604a", "#e8906a", "#f6b884", "#ffd8a0", "#fff0c4" }
local ARL  = { "#7a5230", "#b08040", "#d8b050", "#f0d070", "#fae79a", "#fff6cc" }
local SEED = { "#1e1622", "#2e2234", "#403048", "#584466", "#7a6896", "#b0a4d0" }
local STM  = { "#3a3a24", "#5e5a2e", "#86803c", "#aaa452" }
local BLOOM, COOL = "#ffa08a", "#8a3a6a"
local CREAM = "#fff4d6"

local CX = 32
-- pod half-width along y (pear: wide shoulders, narrow base)
local Y0, Y1 = 27, 51
local function hw(y)
  local t = (y - Y0) / (Y1 - Y0)
  if t < 0 then return 12.6 end
  return max(0.6, 12.6 * (1 - t ^ 2.1) ^ 0.62)
end
local function pcx(y) return CX - 1.6 * max(0, (y - Y0) / (Y1 - Y0)) ^ 1.5 end
-- top edge of the front lobes: V notch at the centre, lips rising and flaring to the sides
local function lipTop(x)
  local d = abs(x - CX)
  return 33.5 - d * 0.62 - (d > 9 and (d - 9) * 0.5 or 0)
end

-- back lobe (inner face toward us)
local back = c:ellipse(CX, 22, 12, 9)
local btok = { r = { name = "back" } }
local bn = {}
back:each(function(x, y) local dx, dy = (x - CX) / 12.5, (y - 22) / 9.5
  bn[K(x, y)] = { A.norm(-dx * 0.7, -dy * 0.6 + 0.2, 0.7) } end)
local bb = {}
local bidx = X.tone(c, back, X.light(bn, { amb = 0.12, wrap = 0.3 }), INR, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bb, tok = btok })
-- back lobe's rim curls back: a band of red skin along its top edge
back:each(function(x, y)
  if not back:has(x, y - 1) or not back:has(x, y - 2) and y < 20 then
    c:put(x, y, (x < CX - 4) and POD[5] or (x < CX + 5 and POD[4] or POD[3]), btok) end end)

-- arils
local arils = { { 24.5, 25.5, 4.2, 5.4 }, { 32, 24.5, 4.4, 6.0 }, { 39.5, 26, 4.1, 5.2 } }
local seeds = { { 24, 18.5, 3.2 }, { 32, 16.5, 3.5 }, { 40, 19, 3.1 } }
for i, s in ipairs(seeds) do s.m = c:ellipse(s[1], s[2], s[3], s[3]) end
for i, a in ipairs(arils) do a.m = c:ellipse(a[1], a[2], a[3], a[4]) end
-- AO on the back lobe around the arils
local bb2 = {}
for _, a in ipairs(arils) do X.ao(bb2, back, a.m, 1, -2) end
for _, s in ipairs(seeds) do X.ao(bb2, back, s.m, 1, -1) end
for k, d in pairs(bb2) do local x, y = k % 1024 - 256, k // 1024 - 256 A.step(c, bidx, INR, x, y, d, btok) end

for i, a in ipairs(arils) do
  local vis = a.m:copy()
  local tok = { r = { name = "aril" .. i } }
  local n = X.sphere(a[1] - 0.5, a[2] - 0.8, a[4], vis)
  local ab = {}
  if i ~= 2 then X.ao(ab, vis, arils[2].m, 1, -1) end
  -- the middle aril sits in front of its neighbours
  if i == 2 then vis = a.m else vis:cut(arils[2].m) end
  local idx = X.tone(c, vis, X.light(n, { amb = 0.12, wrap = 0.3 }), ARL, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = ab, tok = tok })
  -- folds: wavy creases running down the aril
  vis:each(function(x, y)
    local f = (x - a[1]) + 1.3 * sin((y - a[2]) * 1.1 + i)
    if abs(f % 3.2 - 1.6) < 0.4 and abs(x - a[1]) < a[3] - 0.8 then A.step(c, idx, ARL, x, y, -1, tok) end
  end)
  a.idx, a.tok, a.vis = idx, tok, vis
end
-- seeds sit in the aril tops: AO ring on the aril right under each seed
for i, s in ipairs(seeds) do
  for _, a in ipairs(arils) do
    s.m:shift(0, 1):each(function(x, y) if a.vis:has(x, y) and not s.m:has(x, y) then A.step(c, a.idx, ARL, x, y, -2, a.tok) end end)
  end
end
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  if i ~= 2 then vis:cut(seeds[2].m) end
  local tok = { r = { name = "seed" .. i } }
  local n = X.sphere(s[1] - 0.3, s[2] - 0.3, s[3] + 0.3, vis)
  local idx = X.tone(c, vis, X.light(n, { amb = 0.02, wrap = 0.15 }), SEED, { cuts = { 0.36, 0.56, 0.72, 0.84, 0.93 }, tok = tok })
  -- violet rim light lower-right
  vis:edge():each(function(x, y) if x - s[1] + y - s[2] > s[3] * 0.9 then c:put(x, y, SEED[4], tok) end end)
  local gx, gy = floor(s[1] - s[3] * 0.45 + 0.5), floor(s[2] - s[3] * 0.5 + 0.5)
  c:put(gx, gy, CREAM, tok) c:put(gx + 1, gy, SEED[6], tok)
  if i == 2 then c:put(gx, gy + 1, SEED[5], tok) end
end

-- pod front (two lobes)
local pod = HP.mask()
for y = 18, Y1 + 1 do
  local w = hw(y) local cx = pcx(y)
  for x = floor(cx - w - 4), math.ceil(cx + w + 4) do
    local d = abs(x - cx)
    local wl = w
    if y < Y0 + 6 then wl = w + (Y0 + 6 - y) * 0.42 end       -- lips flare outward at the top
    if d <= wl and y >= lipTop(x) then pod:set(x, y) end
  end
end
local ptok = { r = { name = "pod" } }
local pn = {}
pod:each(function(x, y)
  local w = hw(y) local cx = pcx(y)
  local u = max(-0.97, min(0.97, (x - cx) / (w + 1.5)))
  local t = (y - Y0) / (Y1 - Y0)
  pn[K(x, y)] = { A.norm(u, 0.25 + 0.55 * max(0, t) ^ 1.4, sqrt(1 - u * u)) }
end)
local pb = {}
local lipK = {}
pod:each(function(x, y) local k = K(x, y)
  local lt = lipTop(x)
  local d = abs(x - CX)
  -- inner face of the curled lips: first 1-2 rows below the top edge
  if y - lt < (d > 5 and 2.2 or 1.2) then lipK[k] = true end
  -- suture groove down the front, offset with the tilt
  local cx = pcx(y)
  if y > lipTop(CX) + 1 and abs(x - (cx + 0.5)) < 0.6 and y < Y1 - 2 then pb[k] = -2 end
  if y > lipTop(CX) + 1 and abs(x - (cx + 1.5)) < 0.6 and y < Y1 - 3 then pb[k] = 1 end
end)
local pidx = X.tone(c, pod, X.light(pn, { amb = 0.1, wrap = 0.3 }), POD, { cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, bias = pb, tok = ptok })
-- lips: pale inner face, darker where it turns
pod:each(function(x, y) local k = K(x, y)
  if lipK[k] then
    local lt = lipTop(x)
    local i = (y - lt < 1) and 5 or 3
    if x > CX + 4 then i = i - 1 end
    c:put(x, y, INR[i], ptok)
  end
end)
-- AO on arils just above the front lips (they sink into the pod)
for _, a in ipairs(arils) do
  pod:shift(0, -1):each(function(x, y) if a.vis:has(x, y) and not pod:has(x, y) then A.step(c, a.idx, ARL, x, y, -2, a.tok) end end)
end
-- waxy bloom on the lit shoulder (sparse pale-pink pixels), cool reflected light on the shade flank
pod:each(function(x, y) local k = K(x, y)
  if not lipK[k] and (pidx[k] or 0) >= 5 and X.hash(x, y, 5) > 0.72 then c:put(x, y, BLOOM, ptok) end
end)
pod:edge():each(function(x, y) local k = K(x, y)
  if not lipK[k] and x > pcx(y) + 3 and y > 33 and y < Y1 - 1 then c:put(x, y, COOL, ptok) end end)
-- specular on the left shoulder
c:put(22, 34, CREAM, ptok) c:put(23, 34, POD[6], ptok) c:put(22, 35, POD[6], ptok)

-- stalk under the pod
local stok = { r = { name = "stalk" } }
local sm, sn = A.tube({ { 30, 50 }, { 30, 53 }, { 29, 55 }, { 28, 57 } }, function(t) return 1.3 end)
sm:cut(pod)
A.shade(c, sm, sn, STM, { amb = 0.1, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- AO where the pod base meets the stalk
pod:each(function(x, y) if sm:has(x, y + 1) then A.step(c, pidx, POD, x, y, -1, ptok) end end)

-- quirk: an ant on the right flank, heading up toward the seeds
local ink = "#2b1c26"
local ant = { { 24, 44 }, { 25, 44 }, { 25, 43 }, { 26, 42 }, { 27, 41 }, { 27, 40 }, { 28, 40 } }
for _, p in ipairs(ant) do c:put(p[1], p[2], ink, ptok) end
c:put(23, 43, ink, ptok) c:put(26, 44, ink, ptok) c:put(24, 41, ink, ptok) c:put(29, 42, ink, ptok) c:put(28, 38, ink, ptok)
c:put(28, 39, POD[6], ptok) c:put(24, 45, POD[3], ptok) c:put(25, 45, POD[3], ptok)

A.save(c, "ph", NAME)
