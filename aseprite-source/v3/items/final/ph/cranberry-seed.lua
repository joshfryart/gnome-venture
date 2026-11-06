-- cranberry-seed (final, Opus single pass). Three small glossy amber cranberry seeds (plump teardrops, darker
-- hilum at the pointed end, one bright glint each) on a torn scrap of leathery cranberry leaf (glossy dark green,
-- wine-red rolled rim, midrib + faint veins, ragged torn end, AO + contact shadow under each seed). The right seed
-- has sprouted: a white root curling over the leaf edge and a thin red wiry vine with small alternate oval leaves.
-- quirk: the vine tip already nods a pink "crane-head" cranberry flower (reflexed petals, gold beak).
local NAME = "cranberry-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new(NAME)
local LEAF = { "#14302c", "#1d4a3a", "#286a46", "#3a8a4c", "#5ead55", "#93cf6c" }
local RIM = { "#4a1630", "#7a2238", "#a8344a" }
local SEED = { "#4a2418", "#7a4224", "#a8682e", "#cf9443", "#ecbf6a", "#fbe3a2" }
local VINE = { "#5a1f2c", "#8e2f36", "#c4514a", "#e88a6e" }
local PET = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }
local ROOT = { "#b8a68c", "#e8dcc0", "#fff4d6" }

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 18, 47, 3.4, 2.3, 0.5 }, { 27, 44, 3.5, 2.3, -0.25 }, { 37, 46, 3.4, 2.3, 0.2 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end

-- leaf scrap: elliptic leathery leaf, tip torn away in a ragged edge
local lm, ln, LT, LS, len = A.blade(8, 50, 28, 40, 58, 47, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 8.2 * sin(pi * min(1, t * 0.92 + 0.06)) ^ 0.6)
end, { fold = 0.3 })
local torn = {}
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.8 + 0.035 * ((floor(LS[k] * 4.5 + 9) % 3) - 1) + 0.02 * X.hash(x, y, 3)
  if LT[k] > lim then torn[#torn + 1] = k end
end)
for _, k in ipairs(torn) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  local d = (t * len - abs(s) * 6) % 6.5
  if d < 0.8 and abs(s) > 0.2 and abs(s) < 0.72 and t > 0.08 then c:put(x, y, LEAF[max(1, min(6, (lidx[k] or 3) + (s < 0 and 1 or -1)))], ltok) end
end)
-- wine-red rolled rim on the lower (shade) edge, darker toward the torn end; pale fibres on the tear
lm:edge():each(function(x, y) local k = K(x, y)
  if LT[k] > 0.76 then c:put(x, y, (x + y) % 2 == 0 and "#d8e6a8" or LEAF[4], ltok)
  elseif LS[k] > 0.5 and not bias[k] then c:put(x, y, LT[k] > 0.5 and RIM[1] or RIM[2], ltok)
  elseif LS[k] < -0.6 and LT[k] > 0.2 and LT[k] < 0.7 and not bias[k] then c:put(x, y, RIM[3], ltok) end
end)
-- glossy leaf glints
c:put(19, 40, LEAF[6], ltok) c:put(20, 40, A.CREAM, ltok) c:put(44, 41, LEAF[6], ltok)
-- petiole stub
for _, q in ipairs{ { 7, 51, RIM[2] }, { 6, 52, RIM[1] }, { 5, 52, RIM[1] } } do c:put(q[1], q[2], q[3], ltok) end

-- root out of the sprouting seed, curling over the lower leaf edge
local rp = { { 39, 48 }, { 42, 51 }, { 43, 55 }, { 40, 57 } }
local rm, rn = A.tube(rp, function(t) return 0.95 * (1 - t) ^ 0.6 + 0.25 end)
rm:cut(seeds[3].m)
local rtok = { r = { name = "root" } }
A.shade(c, rm, rn, ROOT, { tok = rtok, cuts = { 0.4, 0.7 } })
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not seeds[3].m:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- vine: thin red wiry stem from the right seed, leaning up and nodding right at the top
local vp = { { 37, 44 }, { 34, 32 }, { 38, 20 }, { 44, 14 } }
local vm, vn = A.tube(vp, function(t) return 0.95 end)
vm:cut(seeds[3].m)
local vtok = { r = { name = "vine" } }
A.shade(c, vm, vn, VINE, { tok = vtok, cuts = { 0.3, 0.55, 0.8 } })
-- small alternate oval leaves on short stalks
local lv = HP.mask()
local lvs = {}
for i, q in ipairs{ { 0.2, -1, 4.6 }, { 0.38, 1, 4.4 }, { 0.56, -1, 4.0 }, { 0.72, 1, 3.4 } } do
  local x, y = A.bez(vp, q[1])
  local x2, y2 = A.bez(vp, q[1] + 0.01)
  local tx, ty = x2 - x, y2 - y local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
  local ux, uy = A.rot(tx, ty, q[2] * 1.05)
  local L = q[3]
  local cx, cy = x + ux * (L * 0.5 + 1.0), y + uy * (L * 0.5 + 1.0)
  local m = A.rell(cx, cy, ux, uy, L * 0.55 + 0.4, 1.55)
  m:cut(vm)
  lvs[#lvs + 1] = { m = m, cx = cx, cy = cy, ux = ux, uy = uy }
  lv:add(m)
end
for _, L in ipairs(lvs) do
  local idx = A.shade(c, L.m, A.body(L.m, L.cx - 0.8, L.cy - 0.8, 2.6, 1.2, 0.6), LEAF, { tok = ltok, amb = 0.14, cuts = { 0.16, 0.32, 0.5, 0.66, 0.82 } })
  -- midrib dot line
  for j = -1, 1 do local xi, yi = floor(L.cx + L.ux * j + .5), floor(L.cy + L.uy * j + .5)
    if L.m:has(xi, yi) then c:put(xi, yi, LEAF[max(1, (idx[K(xi, yi)] or 3) - 1)], ltok) end end
end
-- quirk: nodding crane-head flower at the vine tip
local ftok = { r = { name = "flower" } }
local fc = { 46, 17 }
local fl = A.rell(fc[1], fc[2], 0.3, 1, 2.6, 2.0)
fl:add(A.rell(47.5, 13.6, 1, -0.4, 2.3, 1.1))   -- reflexed petals swept back
fl:cut(vm)
A.shade(c, fl, A.body(fl, 45.5, 15.5, 2.6, 1.2, 0.7), PET, { tok = ftok, cuts = { 0.3, 0.55, 0.8 } })
c:put(45, 15, PET[4], ftok)
for _, q in ipairs{ { 46, 20, "#d98322" }, { 46, 21, "#f5b82e" }, { 47, 22, "#8f4a1f" } } do c:put(q[1], q[2], q[3], ftok) end

-- seeds last: glossy amber teardrops
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = A.toneN(c, vis, s.n, SEED, { bias = sb, tok = tok, cuts = { 0.12, 0.3, 0.5, 0.68, 0.86 }, amb = 0.1, wrap = 0.25 })
  -- hilum at the pointed (right) end, and a warm bounce on the shade side
  local ca, sa = cos(s[5]), sin(s[5])
  local hx, hy = floor(s[1] + ca * (s[3] - 0.3) + .5), floor(s[2] + sa * (s[3] - 0.3) + .5)
  if vis:has(hx, hy) then c:put(hx, hy, SEED[1], tok) end
  local gx, gy = A.specAt(vis, s.n, 30)
  if gx then c:put(gx, gy, A.CREAM, tok) end
end

A.save(c, NAME)
