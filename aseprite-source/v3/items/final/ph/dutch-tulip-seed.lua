-- dutch-tulip-seed (ph, Opus single pass). An upright tulip bulb (teardrop, rounded per pixel) in a papery copper
-- tunic with fine meridian ribs; on its lower right the tunic has torn back as a curled flap, showing the glossy
-- cream scale beneath. Root plate with short pale roots. Two flat papery tulip seeds (D-shaped, dark embryo line)
-- lie beside it on a torn scrap of tulip leaf (broad strap, glaucous blue-green with waxy bloom, PARALLEL veins).
-- Sprout: a broad, pointed, gently wavy tulip leaf curving out of the bulb neck plus a tight furled second leaf.
-- quirk: a tiny orange tulip bud is already peeking out of the furled leaf.
local NAME = "dutch-tulip-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB25_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, asin = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.asin
local c = G.new2(NAME)
local TUN = { "#4a2426", "#7a3a2a", "#a8582e", "#cc7a3c", "#e6a05a", "#f6c88a" }
local BULB = { "#7e5e6e", "#ae9096", "#d6bcb2", "#ecdcc8", "#f9efdc" }
local TL = { "#1d3546", "#285050", "#386c5e", "#52896a", "#77a87e", "#a9cba2" }
local BLOOM, COOL = "#c4dccb", "#3a5a78"
local SD = { "#5a3a2a", "#86603a", "#b48a54", "#d8b47a", "#f0d8a6" }
local ROOT = { "#9a7c62", "#d2bc9c", "#efe2c6" }
local BUD = { "#a2332e", "#e8562e", "#ff9a52" }
local CUTS = { 0.16, 0.32, 0.48, 0.64, 0.82 }

-- bulb: teardrop profile around a vertical axis
local BX, BY0, BY1 = 25, 28, 52          -- axis x, neck tip y, base y
local function bw(y)                     -- half width at row y
  local t = (y - BY0) / (BY1 - BY0)
  if t < 0 or t > 1 then return -1 end
  if t < 0.12 then return 1.1 + t * 6 end
  local a = (t - 0.12) / 0.88
  return 1.8 + 6.6 * sin(pi * min(1, a * 0.82 + 0.02)) ^ 0.7 * (a < 0.9 and 1 or (1 - (a - 0.9) * 4))
end
local bm, bnrm, BS, BT = HP.mask(), {}, {}, {}
for y = BY0, BY1 do
  local w = bw(y)
  local ax = BX + (y - 40) * -0.06
  for x = floor(ax - w - 1), floor(ax + w + 1) do
    if abs(x - ax) <= w then
      local k = K(x, y)
      bm:set(x, y)
      local s = max(-0.97, min(0.97, (x - ax) / (w + 0.5)))
      local t = (y - BY0) / (BY1 - BY0)
      local ny = (t < 0.35) and -0.45 or ((t > 0.8) and (t - 0.8) * 3.5 or 0)
      local nz = sqrt(1 - s * s)
      local l = sqrt(s * s + ny * ny + nz * nz)
      bnrm[k] = { s / l, ny / l, nz / l }
      BS[k], BT[k] = s, t
    end
  end
end

-- leaf scrap: broad tulip strap, torn at the left, pointed apex right
local lm, ln, LT, LS, len = G.blade(6, 50, 30, 57, 58, 49, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 5.6 * (1 - t ^ 3) ^ 0.8 + 0.4)
end, { fold = 0.22 })
local torn = {}
lm:each(function(x, y) local k = K(x, y)
  if LT[k] * len < 1.5 + 3.0 * X.hash(3, floor(LS[k] * 5 + 9), 11) - LS[k] * 1.5 then torn[#torn + 1] = k end end)
for _, k in ipairs(torn) do lm.s[k] = nil end

-- seeds on the leaf: cx, cy, rx, ry, ang
local seeds = { { 45, 51, 3.8, 2.6, -0.5 }, { 52, 47, 3.4, 2.4, 0.6 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.4) end
-- roots
local roots = HP.mask()
for _, r in ipairs{ { { 22, 51 }, { 20, 53 }, { 18, 54 }, { 15, 54 } }, { { 25, 52 }, { 25, 54 }, { 26, 56 }, { 27, 57 } },
                    { { 28, 51 }, { 30, 53 }, { 32, 54 }, { 34, 54 } } } do
  for i = 0, 20 do local x, y = G.bez(r, i / 20) roots:set(floor(x + .5), floor(y + .5)) end
end
roots:cut(bm)

local bias = {}
X.ao(bias, lm, bm, 1, -1) G.cast(bias, lm, bm, 2, 2, -1)
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 1, -1) end
G.cast(bias, lm, roots, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, TL, { bias = bias, tok = ltok, cuts = { 0.12, 0.26, 0.42, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- parallel veins along the strap + waxy bloom flecks + cool rim
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s = LS[k]
  local f = (s + 1) * 3.5
  if abs(f - floor(f + 0.5)) < 0.16 and abs(s) < 0.85 then c:put(x, y, s < 0.05 and TL[5] or TL[3], ltok) end
  if s < -0.3 and X.hash(x, y, 3) > 0.9 then c:put(x, y, BLOOM, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LT[k] * len < 5.5 then c:put(x, y, "#bcd2b4", ltok)
  elseif LS[k] > 0.7 then c:put(x, y, COOL, ltok) end end)

-- roots
local rtok = { r = { name = "roots" } }
roots:each(function(x, y) c:put(x, y, (y >= 54) and ROOT[1] or ROOT[2], rtok) end)
c:put(15, 54, ROOT[3], rtok) c:put(34, 54, ROOT[1], rtok)

-- seeds: flat papery discs with a darker embryo line and pale wing rim
for i, s in ipairs(seeds) do
  local tok = { r = { name = "tseed" .. i } }
  local v = X.light(s.n, { amb = 0.2, wrap = 0.3 })
  local id = X.tone(c, s.m, v, SD, { cuts = { 0.2, 0.42, 0.62, 0.82 }, tok = tok })
  local ca, sa = cos(s[5]), sin(s[5])
  s.m:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    local w = (-dx * sa + dy * ca) / (s[4] + .45)
    if abs(w) < 0.22 and abs(u) < 0.55 then c:put(x, y, SD[2], tok) end
  end)
  s.m:edge():each(function(x, y) if (x - s[1]) + (y - s[2]) < 0 then c:put(x, y, SD[5], tok) end end)
end

-- bulb: tunic with meridian ribs, peeled window lower right
local btok = { r = { name = "tunic" } }
local ptok = { r = { name = "scale" } }
local v = X.light(bnrm, { amb = 0.06, wrap = 0.22 })
local bidx = X.tone(c, bm, v, TUN, { cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, tok = btok })
local peel = G.rell(29.5, 45.5, 0.6, 0.8, 4.4, 2.6):clip(bm)
bm:each(function(x, y) local k = K(x, y)
  if peel:has(x, y) then return end
  local s, t = BS[k], BT[k]
  local a = asin(s) / (pi / 2)
  local f = (a + 1) * 4.5
  if abs(f - floor(f + 0.5)) < 0.13 and t > 0.06 and t < 0.94 then c:put(x, y, TUN[max(1, bidx[k] - 1)], btok) end
end)
-- glossy cream scale in the peeled window
local pv = X.light(bnrm, { amb = 0.25, wrap = 0.35 })
X.tone(c, peel, pv, BULB, { cuts = { 0.25, 0.45, 0.62, 0.8 }, tok = ptok })
peel:grow(1):clip(bm):cut(peel):each(function(x, y) if y <= 45 or x <= 28 then c:put(x, y, TUN[2], btok) end end)
c:put(28, 44, BULB[5], ptok) c:put(29, 44, BULB[5], ptok)
-- curled tunic flap lifting off the window's lower edge, pale inner face
local flap = HP.poly{ { 31, 48 }, { 35, 47 }, { 37, 50 }, { 34, 50 } }:cut(bm)
local ftok = { r = { name = "flap" } }
flap:each(function(x, y) c:put(x, y, (y <= 48) and TUN[6] or TUN[4], ftok) end)
c:put(36, 49, TUN[3], ftok)
-- root plate: dark band
for x = 18, 33 do if bm:has(x, 51) and not bm:has(x, 53) then c:put(x, 51, TUN[2], btok) end end
for x = 18, 33 do if bm:has(x, 52) then c:put(x, 52, TUN[1], btok) end end
-- tunic gloss
c:put(21, 36, TUN[6], btok) c:put(21, 37, "#fff4d6", btok) c:put(20, 38, TUN[6], btok)

-- sprout: broad wavy tulip leaf out of the neck + a furled leaf
local stok = { r = { name = "sprout" } }
local fm, fn, FT, FS = G.tube({ { 27, 30 }, { 28, 23 }, { 30, 17 }, { 32, 12 } }, function(t) return 1.5 - t * 0.6 end)
fm:cut(bm)
local m, n, T, S, L = G.blade(25, 30, 15, 20, 13, 8, function(t)
  if t > 0.985 then return -1 end
  local w = 3.9 * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.75
  return max(0.4, w + 0.45 * sin(t * 16))
end, { fold = 0.42 })
m:cut(bm)
local sb = {}
X.ao(sb, m, fm, 1, -1)
G.toneN(c, m, n, TL, { tok = stok, cuts = CUTS, amb = 0.14, wrap = 0.3, bias = sb })
m:each(function(x, y) local k = K(x, y)
  if abs(S[k]) < 0.14 and T[k] > 0.05 and T[k] < 0.9 then c:put(x, y, S[k] <= 0 and TL[6] or TL[3], stok)
  elseif abs(abs(S[k]) - 0.52) < 0.1 and T[k] > 0.15 and T[k] < 0.8 then c:put(x, y, S[k] < 0 and TL[5] or TL[2], stok)
  elseif S[k] < -0.4 and X.hash(x, y, 9) > 0.88 then c:put(x, y, BLOOM, stok) end
end)
-- furled leaf (rolled tube) on top, with spiral edge line
local fidx = X.tone(c, fm, X.light(fn, { amb = 0.12, wrap = 0.3 }), TL, { cuts = CUTS, tok = stok })
fm:each(function(x, y) local k = K(x, y)
  local ph = FT[k] * 6 + FS[k] * 0.9
  if abs(ph - floor(ph + 0.5)) < 0.12 then c:put(x, y, TL[max(1, fidx[k] - 2)], stok) end end)
-- neck: papery frayed tunic collar over the leaf bases
for _, q in ipairs{ { 24, 29, 5 }, { 25, 28, 6 }, { 27, 28, 4 }, { 28, 29, 3 }, { 23, 30, 4 } } do c:put(q[1], q[2], TUN[q[3]], btok) end

-- quirk: tiny orange bud peeking from the furled leaf tip
local btok2 = { r = { name = "bud" } }
for _, q in ipairs{ { 32, 10, 2 }, { 33, 10, 2 }, { 32, 9, 3 }, { 33, 9, 2 }, { 33, 8, 1 }, { 32, 8, 3 }, { 34, 10, 1 } } do
  c:put(q[1], q[2], BUD[q[3]], btok2) end
G.save2(c, NAME)
