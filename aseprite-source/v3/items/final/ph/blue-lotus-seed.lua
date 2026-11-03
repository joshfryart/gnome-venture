-- blue-lotus-seed (final, Opus single pass). Three glossy olive-black lotus nuts (apical nub, bright specular,
-- cool reflected light) on a torn wedge of lily pad seen in perspective: radial veins from the notch, ragged torn
-- side curling up to show the purple underside, AO + contact shadow under each nut. The right nut has sent up a
-- thin curving stalk carrying a first round, notched floating leaf and a rolled young leaf.
-- quirk: one fallen pale-blue petal rests on the pad edge.
local NAME = "blue-lotus-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR21_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local PAD = { "#1d4638", "#285f41", "#3a7d48", "#57a051", "#82c160", "#b6de88" }
local UNDER = { "#4a2340", "#6e3358", "#955078", "#b8729a" }
local NUT = { "#1e1e1c", "#2f3026", "#454632", "#62623e", "#8a8650", "#c8c07a" }
local STALK = { "#3d6c48", "#62965a", "#8fbe72", "#c0e09a" }
local PET = { "#2e3f86", "#4462b2", "#6a8ed6", "#98bdf0", "#c8e2ff" }
local COOL, VEIN = "#4a7f8c", "#2c6a44"

-- pad wedge: ellipse with a V notch toward the front-right; torn left side
local pcx, pcy = 31, 47
local pm = HP.mask()
for y = pcy - 12, pcy + 12 do for x = pcx - 26, pcx + 26 do
  local u, v = (x - pcx) / 23.5, (y - pcy) / 10.5
  if u * u + v * v <= 1 then pm:set(x, y) end
end end
local cutl = {}
pm:each(function(x, y)
  local a = atan(y - pcy, (x - pcx) * 0.45)
  -- notch: wedge around angle 0.55 rad (front right)
  if abs(a - 0.62) < 0.2 and (x - pcx) > 0 then cutl[#cutl + 1] = K(x, y) end
  -- torn left edge, ragged
  if x < pcx - 15 + floor(X.hash(0, y, 5) * 4) - (y > pcy and 2 or 0) then cutl[#cutl + 1] = K(x, y) end
end)
for _, k in ipairs(cutl) do pm.s[k] = nil end
-- curled-up torn rim on the left: a strip showing the purple underside
local curl = HP.mask()
pm:each(function(x, y) if not pm:has(x - 1, y) and not pm:has(x - 2, y) and y < pcy + 6 then curl:set(x, y) curl:set(x + 1, y) end end)

-- nuts
local nuts = { { 19, 43, 3.6, 2.8, -0.35 }, { 28, 47, 3.8, 2.9, 0.15 }, { 38, 43, 3.5, 2.8, -0.5 } }
for _, s in ipairs(nuts) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

-- stalk + leaves (drawn before nuts)
local sp = { { 39, 41 }, { 41, 33 }, { 37, 26 }, { 40, 20 } }
local sm, sn = A.tube(sp, function(t) return 0.95 end)
local leafc = { 41, 15 }
local lm = HP.mask()
for y = 7, 23 do for x = 28, 56 do
  local u, v = (x - leafc[1]) / 9.5, (y - leafc[2]) / 5.2
  if u * u + v * v <= 1 then lm:set(x, y) end end end
local lcut = {}
lm:each(function(x, y) local a = atan(y - leafc[2], (x - leafc[1]) * 0.55)
  if abs(a - 1.75) < 0.24 and y > leafc[2] then lcut[#lcut + 1] = K(x, y) end end)
for _, k in ipairs(lcut) do lm.s[k] = nil end
sm:cut(lm)
-- rolled young leaf on a short side stalk
local yp = { { 40, 33 }, { 44, 31 }, { 47, 29 }, { 49, 26 } }
local ym, yn, YT, YS = A.tube(yp, function(t) if t < 0.45 then return 0.6 end return 0.6 + 1.6 * sin(pi * (t - 0.45) / 0.55) ^ 0.6 end)
ym:cut(sm)

-- pad shading
local pbias = {}
for _, s in ipairs(nuts) do X.ao(pbias, pm, s.m, 1, -1) A.cast(pbias, pm, s.m, 1, 2, -1) end
X.ao(pbias, pm, sm, 1, -1)
local pn = X.pillow(pm, 3.5, 0.7)
local ptok = { r = { name = "pad" } }
local pidx = A.shade(c, pm, pn, PAD, { bias = pbias, tok = ptok, amb = 0.3, wrap = 0.4, cuts = { 0.18, 0.36, 0.55, 0.72, 0.88 } })
-- radial veins from the notch apex
local ax, ay = pcx + 1, pcy
pm:each(function(x, y) local k = K(x, y)
  if pbias[k] then return end
  local dx, dy = (x - ax) * 0.45, y - ay
  local r = sqrt(dx * dx + dy * dy)
  if r < 2 then return end
  local a = atan(dy, dx)
  local ph = (a / (2 * pi) * 13) % 1
  if ph < 0.09 then c:put(x, y, r < 6 and PAD[2] or VEIN, ptok) end
  if ph > 0.09 and ph < 0.15 and dy < 0 then c:put(x, y, PAD[min(6, pidx[k] + 1)], ptok) end
end)
pm:edge():each(function(x, y) if y > pcy + 6 and not pbias[K(x, y)] then c:put(x, y, COOL, ptok) end end)
-- underside curl
local utok = { r = { name = "under" } }
curl:each(function(x, y)
  local left = not pm:has(x - 1, y)
  c:put(x, y, left and (y < pcy - 4 and UNDER[4] or UNDER[3]) or UNDER[2], utok)
end)
curl:edge():each(function(x, y) if pm:has(x + 1, y) and not curl:has(x + 1, y) then c:put(x, y, UNDER[1], utok) end end)

-- quirk: fallen petal on the front-left pad edge
local qm, qn = A.oval(20, 53, 4.6, 1.8, -0.25, 0.6)
local qtok = { r = { name = "petal" } }
local qidx = A.shade(c, qm, qn, PET, { tok = qtok, cuts = { 0.15, 0.35, 0.58, 0.8 }, amb = 0.25, wrap = 0.35 })
qm:each(function(x, y) local dx, dy = x - 20, y - 53
  if abs(dy * cos(-0.25) - dx * sin(-0.25)) < 0.5 and abs(dx) < 3 then A.step(c, qidx, PET, x, y, -1, qtok) end end)
A.sep(c, qm, pm, PET[1], qtok)

-- stalk
local stok = { r = { name = "stalk" } }
A.shade(c, sm, sn, STALK, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
-- young rolled leaf: tightly furled, dark seam spiral
local ytok = { r = { name = "young" } }
local yidx = A.shade(c, ym, yn, PAD, { tok = ytok, amb = 0.12, wrap = 0.3, cuts = { 0.16, 0.34, 0.52, 0.7, 0.86 } })
ym:each(function(x, y) local k = K(x, y)
  if YT[k] > 0.5 and abs(YS[k] - (YT[k] - 0.75) * 2.4) < 0.18 then A.step(c, yidx, PAD, x, y, -2, ytok) end end)
-- floating leaf: flat disc tilted toward us, rim catching light, radial veins, red-tinged margin
local ltok = { r = { name = "leaf" } }
local ln = {}
lm:each(function(x, y) local u, v = (x - leafc[1]) / 10, (y - leafc[2]) / 5.6
  local r = sqrt(u * u + v * v)
  local e = max(0, r - 0.6) / 0.4
  ln[K(x, y)] = { A.norm(u * e * 0.8 - 0.1, v * e * 0.6 + 0.15, 1) } end)
local lb = {}
X.ao(lb, lm, sm, 1, -1)
local lidx = A.shade(c, lm, ln, PAD, { tok = ltok, bias = lb, amb = 0.25, wrap = 0.35, cuts = { 0.16, 0.34, 0.52, 0.7, 0.86 } })
lm:each(function(x, y) local k = K(x, y)
  local dx, dy = (x - leafc[1]) * 0.55, y - leafc[2]
  local r = sqrt(dx * dx + dy * dy)
  if r < 1 then return end
  local ph = (atan(dy, dx) / (2 * pi) * 9) % 1
  if ph < 0.1 then A.step(c, lidx, PAD, x, y, -1, ltok) end
end)
lm:edge():each(function(x, y) if y > leafc[2] + 1 then c:put(x, y, UNDER[2], ltok) end end)
c:put(36, 11, PAD[6], ltok) c:put(37, 11, PAD[6], ltok)

-- nuts last: glossy, nub on top, cool bounce lower right, AO between neighbours
for i, s in ipairs(nuts) do
  local vis = s.m:copy()
  local sb = {}
  for j = 1, #nuts do if j ~= i and j > i then vis:cut(nuts[j].m) X.ao(sb, s.m, nuts[j].m, 1, -1) end end
  local tok = { r = { name = "nut" .. i } }
  local idx = A.shade(c, vis, s.n, NUT, { bias = sb, tok = tok, amb = 0.06, wrap = 0.2, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 } })
  local rim = X.rim(s.n)
  vis:edge():each(function(x, y) local k = K(x, y) if (rim[k] or 0) > 0.55 and not sb[k] then c:put(x, y, "#4f6a6a", tok) end end)
  local gx, gy = A.specAt(vis, s.n, 50)
  if gx then c:put(gx, gy, NUT[6], tok) c:put(gx + 1, gy, NUT[5], tok) end
  -- apical nub: small raised point at the far end of the long axis
  local nx, ny = floor(s[1] + cos(s[5]) * (s[3] + 0.6) + 0.5), floor(s[2] + sin(s[5]) * (s[3] + 0.6) + 0.5)
  if not vis:has(nx, ny) then c:put(nx, ny, NUT[3], tok) end
  if i > 1 then A.sep(c, vis, nuts[i - 1].m, NUT[1], tok) end
end
-- the sprouting nut is cracked at its nub
c:put(39, 40, STALK[2], { r = { name = "crack" } })

A.save(c, NAME)
