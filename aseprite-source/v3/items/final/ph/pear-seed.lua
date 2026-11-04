-- pear-seed (final, Opus single pass). Three glossy pear pips (dark teardrops, blunt end round, tip pointed) on a
-- torn pear-leaf scrap (glossy ovate blade, finely serrated, midrib + arcing side veins, pale fibrous torn edge on
-- the right). The middle pip has germinated: a slim pale stem, two oval cotyledons and a first true pear leaf
-- (ovate, pointed, serrated) tilted up to the right.
-- Material: per-pixel light on pips (6-tone espresso brown, 2x1 cream specular each, lighter pointed tip),
-- leaf V-fold light, cool reflected edge, AO + contact shadow under each pip and where the stem meets its pip.
-- quirk: a dewdrop shaped like a tiny pear hangs from the true leaf's tip.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("pear-seed")

local LEAF = { "#15322e", "#1e4b3a", "#2b6842", "#43874a", "#69a852", "#a4cd6a" }
local PIP  = { "#231417", "#3c1f1c", "#5e3222", "#84492b", "#a8683a", "#cf9458" }
local STEM = { "#4b8250", "#7cb064", "#aed488", "#dcefb4" }
local TORN, COOL, SPEC = "#d8e6a0", "#3a6672", "#fff0d6"
local DEW = { "#5e8ec0", "#9cc8e8", "#e2f4fa" }
local ltok, stok = { r = { name = "leaf" } }, { r = { name = "stem" } }

-- pips: blunt end (bx,by) -> tip (tx,ty)
local pips = { { 15, 48, 23, 46 }, { 27, 49, 33, 43 }, { 41, 47, 47, 52 } }
for _, p in ipairs(pips) do
  local mx, my = (p[1] + p[3]) / 2, (p[2] + p[4]) / 2
  p.m, p.n, p.T, p.S = A.tube({ { p[1], p[2] }, { mx - (p[3] - p[1]) * 0.15, my - (p[4] - p[2]) * 0.15 }, { mx + (p[3] - p[1]) * 0.15, my + (p[4] - p[2]) * 0.15 }, { p[3], p[4] } },
    function(t) return 2.9 * sin(pi / 2 * min(1, t * 2.6 + 0.3)) ^ 0.5 * (1 - t) ^ 0.75 + 0.35 end)
  -- round the blunt end into a dome
  local d = HP.mask()
  for y = p[2] - 4, p[2] + 4 do for x = p[1] - 4, p[1] + 4 do if (x - p[1]) ^ 2 + (y - p[2]) ^ 2 <= 7.8 then d:set(x, y) end end end
  p.m:add(d)
  p.n = A.body(p.m, (p[1] * 2 + p[3]) / 3, (p[2] * 2 + p[4]) / 3, 4, 3, 0.5)
end
local pipAll = HP.mask() for _, p in ipairs(pips) do pipAll:add(p.m) end

-- leaf scrap: ovate pear leaf lying across, tip at left, torn at the right
local tear = HP.mask()
for y = 30, 62 do for x = 40, 62 do
  local j = 1.6 * sin(y * 1.9) + (X.hash(0, y, 4) - 0.5) * 2.4
  if x > 52 - (y - 46) * 0.35 + j then tear:set(x, y) end
end end
local lbias = {}
local lm0 = A.blade(6, 49, 30, 41, 58, 47, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 9.2 * sin(pi * min(1, t * 0.82 + 0.02)) ^ 0.62) end)
lm0:cut(tear)
for _, p in ipairs(pips) do X.ao(lbias, lm0, p.m, 1, -1) A.cast(lbias, lm0, p.m, 1, 2, -1) end
local lm, LT, LS, lidx = A.leaf(c, 6, 49, 30, 41, 58, 47, 9.2, LEAF, { cut = tear, bias = lbias, tok = ltok, vs = 4.2, fold = 0.4,
  wfn = function(t) if t > 0.99 then return -1 end return max(0.5, 9.2 * sin(pi * min(1, t * 0.82 + 0.02)) ^ 0.62) end })
-- serration: every 3rd edge pixel on the margin knocked out, keep torn side intact
local serr = {}
lm:edge():each(function(x, y) local k = K(x, y)
  if not tear:grow(1):has(x, y) and LT[k] > 0.05 and (x + y * 2) % 4 == 0 and abs(LS[k]) > 0.8 then serr[#serr + 1] = { x, y } end end)
for _, q in ipairs(serr) do c.pix[q[2] * c.w + q[1]] = nil c.own[q[2] * c.w + q[1]] = nil lm.s[K(q[1], q[2])] = nil end
-- torn edge: pale exposed fibres
tear:grow(1):each(function(x, y) if lm:has(x, y) and not tear:has(x, y) then c:put(x, y, (y % 3 == 0) and LEAF[5] or TORN, ltok) end end)
-- cool reflected light on the lower margin
lm:edge():each(function(x, y) local k = K(x, y) if not lbias[k] and LS[k] > 0.7 and LT[k] > 0.15 and not tear:grow(1):has(x, y) then c:put(x, y, COOL, ltok) end end)
-- re-darken the shadow pixels (A.leaf veins may have overdrawn)
for k, b in pairs(lbias) do if lm.s[k] and lidx[k] then local x, y = k % 1024 - 256, k // 1024 - 256 c:put(x, y, LEAF[max(1, lidx[k])], ltok) end end

-- sprout from the middle pip's tip region
local stem = { { 31, 45 }, { 30, 38 }, { 33, 31 }, { 32, 24 } }
local smk = A.stem(c, stem, function(t) return 1.05 end, STEM, { cut = pipAll, tok = stok })
local cot1 = A.leaf(c, 32, 26, 27, 22, 21, 23, 2.8, LEAF, { cut = smk, tok = ltok, pw = 0.45, vs = 9 })
local cot2 = A.leaf(c, 33, 26, 38, 23, 43, 25, 2.7, LEAF, { cut = smk, tok = ltok, pw = 0.45, vs = 9 })
-- true leaf: ovate, pointed, up-right on a short petiole
local pet = { { 32, 24 }, { 32, 21 }, { 33, 19 }, { 35, 17 } }
local pm = A.stem(c, pet, function(t) return 0.7 end, STEM, { cut = cot1:copy():add(cot2), tok = stok })
local tl, TT, TS, tidx = A.leaf(c, 35, 17, 40, 9, 50, 7, 4.6, LEAF, { tok = ltok, pw = 0.7, vs = 3.0, fold = 0.5,
  wfn = function(t) if t > 0.985 then return -1 end return max(0.4, 4.6 * sin(pi * min(1, t * 0.78 + 0.06)) ^ 0.7) end })
-- serrated margin on the true leaf
tl:edge():each(function(x, y) local k = K(x, y) if TT[k] > 0.2 and TT[k] < 0.9 and (x + y) % 3 == 0 then c:put(x, y, LEAF[max(1, (tidx[k] or 3) - 1)], ltok) end end)
-- AO where the stem enters the pip and where cotyledons meet the stem
c:put(31, 44, STEM[1], stok) c:put(32, 25, STEM[1], stok)

-- quirk: pear-shaped dewdrop under the leaf tip
local dtok = { r = { name = "dew" } }
for _, p in ipairs{ { 50, 8, 2 }, { 50, 9, 2 }, { 49, 10, 2 }, { 50, 10, 2 }, { 51, 10, 1 }, { 49, 11, 2 }, { 50, 11, 1 }, { 51, 11, 1 } } do c:put(p[1], p[2], DEW[p[3]], dtok) end
c:put(49, 10, DEW[3], dtok)

-- pips last
for i, p in ipairs(pips) do
  local tok = { r = { name = "pip" .. i } }
  local idx = A.shade(c, p.m, p.n, PIP, { amb = 0.08, wrap = 0.22, tok = tok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.84 } })
  -- paler pointed tip (the micropyle end) and a dark hilum line
  p.m:each(function(x, y) local k = K(x, y) if p.T[k] and p.T[k] > 0.78 then A.step(c, idx, PIP, x, y, 1, tok) end end)
  local rim = X.rim(p.n)
  p.m:edge():each(function(x, y) local k = K(x, y) if rim[k] and rim[k] > 0.62 then c:put(x, y, PIP[4], tok) end end)
  -- 2x1 specular on the blunt shoulder
  local sx, sy = A.specAt(p.m, p.n, 30)
  c:put(sx, sy, SPEC, tok) c:put(sx + 1, sy, PIP[6], tok)
end

A.save(c, "pear-seed")
