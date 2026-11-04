-- mandarin-seed (ph, Opus final pass, replaces the Sonnet draft). Three plump ivory mandarin pips (teardrops with a
-- tan chalaza cap at the round end, a faint ridge, one glint each, AO + contact shadow) on a broad glossy citrus leaf
-- scrap whose tip is torn off (ragged pale torn edge, midrib, side veins, glossy streak, cool lower-right rim). The
-- right pip has germinated the citrus way, cotyledons staying inside: a pale root out of the tip, a hooked stem and two
-- glossy elliptic true leaves on winged petioles plus a bronze-green bud. quirk: one orange juice sac is still stuck to a pip.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("mandarin-seed")

local LEAF = { "#123a2e", "#1c5236", "#286c3c", "#3a8a42", "#58a84a", "#8ccc62" }
local SPR = { "#1a4630", "#26633a", "#368244", "#4ea24c", "#76c25a", "#b0e07c" }
local PIP = { "#8a774c", "#ae9c6c", "#cdbd8c", "#e4d8ae", "#f3ebcc", "#fffbe8" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local ROOT = { "#b49a72", "#d6c09a", "#efe2c2", "#fff6e0" }
local VEIN, COOL, TORN = "#a6d47a", "#3a6c72", "#cfe6a0"

-- pips: cx, cy, half length, half width, tip angle
local pips = { { 19, 45, 4.4, 2.8, 2.7 }, { 29.5, 50, 4.3, 2.7, 0.25 }, { 39, 41.5, 4.5, 2.9, 0.75 } }
local allP = HP.mask()
for _, p in ipairs(pips) do p.m, p.n, p.U, p.V = A.drop(p[1], p[2], p[3], p[4], p[5], 0.9, 0.55) allP:add(p.m) end
local p3 = pips[3]
local tipx, tipy = p3[1] + cos(p3[5]) * (p3[3] + 0.2), p3[2] + sin(p3[5]) * (p3[3] + 0.2)

-- leaf scrap: broad citrus blade on the diagonal, tip torn away
local lm, ln, LT, LS, len = A.blade(8, 53, 30, 36, 58, 44, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 10.5 * sin(pi * min(1, t * 0.9 + 0.07)) ^ 0.6)
end, { fold = 0.42 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.73 + LS[k] * 0.06 + (X.hash(floor((x - y) / 2), 3, 9) - 0.5) * 0.07
  if LT[k] > lim then cut[#cut + 1] = k end end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local torn = HP.mask()
lm:edge():each(function(x, y) if LT[K(x, y)] > 0.62 and not lm:has(x + 1, y) or (LT[K(x, y)] > 0.62 and not lm:has(x, y - 1) and not lm:has(x + 1, y - 1)) then torn:set(x, y) end end)

-- root + stem masks (needed for leaf shadows)
local rm, rn = A.tube({ { tipx, tipy }, { tipx + 3, tipy + 2 }, { tipx + 5, tipy + 5 }, { tipx + 4, tipy + 9 } }, function(t) return 1.1 * (1 - t) ^ 0.8 + 0.3 end)
rm:cut(p3.m)
local bias = {}
X.ao(bias, lm, allP, 1, -1) A.cast(bias, lm, allP, 1, 2, -1)
X.ao(bias, lm, rm, 1, -1)
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.02 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local d = (t * len - abs(s) * 10.5 * 0.9) % 4.6
  if d < 0.8 and abs(s) > 0.18 and abs(s) < 0.82 and t > 0.06 then c:put(x, y, s < 0 and LEAF[min(6, lidx[k] + 1)] or LEAF[max(1, lidx[k] - 1)], ltok) end
end)
-- glossy streak along the lit half
lm:each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] < -0.45 and LS[k] > -0.62 and LT[k] > 0.18 and LT[k] < 0.5 and (x + y) % 5 ~= 0 then c:put(x, y, "#c4ec8a", ltok) end end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.08 and LT[k] < 0.6 then c:put(x, y, COOL, ltok) end end)
torn:each(function(x, y) c:put(x, y, TORN, ltok) if lm:has(x - 1, y) and not torn:has(x - 1, y) then c:put(x - 1, y, LEAF[2], ltok) end end)
-- winged petiole stub at the base
for _, q in ipairs{ { 7, 54, 4 }, { 6, 55, 3 }, { 5, 56, 3 }, { 8, 55, 2 }, { 6, 54, 5 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- root (drawn over the leaf, with a contact shadow)
local rtok = { r = { name = "root" } }
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not allP:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
X.tone(c, rm, X.light(rn, { amb = 0.15, wrap = 0.3 }), ROOT, { cuts = { 0.3, 0.55, 0.8 }, tok = rtok })

-- stem: out of the pip's tip, hooking up
local stok = { r = { name = "stem" } }
local sm = A.stem(c, { { tipx - 1, tipy - 1 }, { tipx + 2, tipy - 8 }, { tipx - 2, tipy - 15 }, { tipx - 1, tipy - 23 } },
  function(t) return 1.15 - 0.2 * t end, STEM, { cut = p3.m, tok = stok, cuts = { 0.3, 0.55, 0.8 } })
local topx, topy = floor(tipx - 1 + 0.5), floor(tipy - 23 + 0.5)

-- true leaves: glossy elliptic, pointed tip; small wing on the petiole
local ttok = { r = { name = "trueleaf" } }
local function citrusLeaf(ax, ay, cx, cy, bx, by, w)
  local m, T, S, idx = A.leaf(c, ax, ay, cx, cy, bx, by, w, SPR, { vs = 2.4, fold = 0.5, tok = ttok,
    wfn = function(t) if t > 0.985 then return -1 end
      if t < 0.16 then return 0.6 + t * 6 end                     -- winged petiole
      return max(0.4, w * sin(pi * min(1, (t - 0.12) / 0.88 * 0.97 + 0.03)) ^ 0.65) end })
  local bx2, by2
  m:each(function(x, y) local k = K(x, y) if S[k] < -0.4 and T[k] > 0.35 and T[k] < 0.55 and (not bx2 or x + y < bx2 + by2) then bx2, by2 = x, y end end)
  if bx2 then c:put(bx2, by2, "#e6f8b8", ttok) end
  return m
end
local L1 = citrusLeaf(topx, topy + 3, topx - 7, topy - 4, topx - 15, topy - 1, 3.7)
local L2 = citrusLeaf(topx + 1, topy + 1, topx + 7, topy - 7, topx + 14, topy - 6, 3.4)
-- bud: young bronze-green tip
local BUD = { "#3a3a22", "#6a6a2a", "#9a9a3a", "#c8c060" }
for _, p in ipairs{ { topx, topy, 2 }, { topx, topy - 1, 3 }, { topx + 1, topy - 1, 2 }, { topx, topy - 2, 4 }, { topx, topy - 3, 3 } } do c:put(p[1], p[2], BUD[p[3]], stok) end

-- pips: lit teardrops, tan chalaza cap at the round end, faint ridge, glint
for i, p in ipairs(pips) do
  local tok = { r = { name = "pip" .. i } }
  local idx = A.shade(c, p.m, p.n, PIP, { amb = 0.1, wrap = 0.3, tok = tok })
  p.m:each(function(x, y) local k = K(x, y)
    if p.U[k] < -0.7 then c:put(x, y, PIP[max(1, idx[k] - 2)], tok)
    elseif abs(p.V[k] + 0.1) < 0.1 and p.U[k] > -0.5 and p.U[k] < 0.6 then c:put(x, y, PIP[max(1, idx[k] - 1)], tok) end
  end)
  local gx, gy = A.specAt(p.m:shrink(1), p.n, 30)
  if gx then c:put(gx, gy, "#fffef4", tok) end
end
-- re-draw the stem foot over pip 3's tip so the sprout clearly comes out of it
c:put(floor(tipx), floor(tipy - 1), STEM[2], stok)

-- quirk: a juice sac still stuck to pip 1 (round end)
local p1 = pips[1]
local jx, jy = floor(p1[1] - cos(p1[5]) * (p1[3] - 1) + 0.5), floor(p1[2] - sin(p1[5]) * (p1[3] - 1) + 0.5)
local JS = { { 0, -1, "#ffb64a" }, { 1, -1, "#f08a2a" }, { 0, -2, "#ffe0a0" }, { 1, -2, "#ffb64a" }, { 1, -3, "#f08a2a" }, { 2, -1, "#c2541e" } }
for _, q in ipairs(JS) do c:put(jx + q[1], jy + q[2], q[3], { r = { name = "sac" } }) end

A.save(c, "mandarin-seed")
