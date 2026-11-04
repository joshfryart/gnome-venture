-- cacao (crop, single pass, Opus). A slim ripe cacao pod hanging from a short woody stalk off a twig: blunt
-- shoulder, long tapering slightly hooked tip. Material: per-pixel light on a ribbed surface of revolution (10 ribs,
-- 5 visible; deep and shallow furrows alternate), a sparse warty texture, one waxy specular on the shoulder, cool
-- reflected light lower-right, AO where the stalk meets the shoulder. Twig with bark; one drooping drip-tip leaf
-- behind (midrib + veins); auto-centred. Draft by Sonnet replaced.
-- quirk: a tiny pink cacao flower still blooms on the twig beside the ripe pod (cacao flowers on its bark).
local NAME = "cacao"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_b2g7.lua")
local HP, X, c = G.new(NAME)
local K = G.K
local floor, abs, sin, cos, pi, max, min, sqrt, asin = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.asin

local POD  = { "#5c1d2e", "#8f3131", "#c2532b", "#e47f2c", "#f5aa3c", "#ffd667" }
local COOL = "#9a5c86"
local LEAF = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" }
local VEIN = "#bfe28a"
local WOOD = { "#341f24", "#523126", "#744830", "#966540", "#b88758", "#d9ad7a" }
local PET  = { "#fff3e4", "#f9cfd6", "#e897ae", "#b8406a", "#7a2348" }

-- 1. leaf (behind): from the twig, drooping to the left, drip tip
local lm, ln, LT, LS, llen = G.blade(27, 12, 14, 12, 7, 31, function(t)
  if t > 0.985 then return -1 end
  if t > 0.86 then return max(0.45, 1.2 * (1 - (t - 0.86) / 0.13)) end      -- drip tip
  return max(0.6, 5.0 * sin(pi * min(1, (t * 0.86 + 0.06))) ^ 0.75)
end, { fold = 0.4 })

-- 2. pod mask: curved axis A (shoulder) -> C -> B (tip)
local AX, AY, CX, CY, BX, BY = 33, 21, 37, 40, 29, 58
local W = 9.4
local function wf(t)
  if t > 0.985 then return -1 end
  local u = t ^ 0.78
  local e = t < 0.36 and 0.42 or 0.95
  local base = W * sin(pi * min(1, u * 0.97 + 0.03)) ^ e
  return max(0.5, base + (t > 0.12 and t < 0.85 and 0.3 * sin(t * 46) or 0))
end
local function wraw(t) local u = t ^ 0.78 local e = t < 0.36 and 0.42 or 0.95 return W * sin(pi * min(1, u * 0.97 + 0.03)) ^ e end
local pm, _, PT, PS, plen = G.blade(AX, AY, CX, CY, BX, BY, wf, { fold = 0 })

-- 3. stalk (peduncle) + twig
local sm = X.cyl(34, 22, 36, 11, function(t) return t > 0.75 and 1.9 or 1.4 end)
local tw, twn, TT, TS = X.cyl(22, 11, 49, 8, function(t) return 1.7 - 0.5 * t end)

-- leaf tone (AO under the pod and twig)
local lb = {}
X.ao(lb, lm, pm, 1, -1) G.cast(lb, lm, pm, 1, 2, -1)
X.ao(lb, lm, tw, 1, -1)
lm:cut(pm):cut(tw)
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = lb, tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.2 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if lb[k] then return end
  if abs(s) < 0.14 and t > 0.03 and t < 0.9 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  for _, vt in ipairs{ 5, 9.5, 14, 18.5, 23 } do
    local d = t * llen - (vt + abs(s) * 4.5)
    if d > -0.55 and d < 0.55 and abs(s) > 0.2 and abs(s) < 0.75 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) return end
  end
end)

-- twig: bark with paler cut end on the right, grain flecks
local twb = {}
X.ao(twb, tw, sm, 1, -1)
local ttok = { r = { name = "twig" } }
G.toneN(c, tw, twn, WOOD, { bias = twb, tok = ttok, amb = 0.1, wrap = 0.3 })
tw:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 7) > 0.8 and abs(TS[k]) < 0.5 and not twb[k] then c:put(x, y, WOOD[2], ttok) end
end)
-- cut end (pale end grain) at the right tip
c:put(49, 8, WOOD[6], ttok) c:put(49, 7, WOOD[5], ttok) c:put(48, 8, WOOD[5], ttok)
c:put(48, 9, WOOD[4], ttok)

-- stalk: thick flared cushion at the twig, green-brown
local STK = { "#2d2a22", "#4a4029", "#6a5a32", "#8a7a3e", "#ab9a52", "#cbbb72" }
local _, sn = X.cyl(34, 22, 36, 11, function(t) return t > 0.75 and 1.9 or 1.4 end)
local sb = {}
X.ao(sb, sm, pm, 1, -1)
sm:cut(pm)
G.toneN(c, sm, sn, STK, { bias = sb, tok = { r = { name = "stalk" } }, amb = 0.12, wrap = 0.3 })

-- 4. pod normals: ribbed surface of revolution around the curved axis
local n, bias, groove = {}, {}, {}
local function wslope(t) local e = 0.01 return (wraw(min(0.98, t + e)) - wraw(max(0, t - e))) / (2 * e * plen) end
local GTH = {}
for j = -3, 3 do local th = (pi * (2 * j + 1) - 0.5) / 10 if abs(th) < 1.4 then GTH[#GTH + 1] = { th, j } end end
pm:each(function(x, y) local k = K(x, y)
  local t, s = PT[k], PS[k]
  local _, _, tx, ty = G.qb(AX, AY, CX, CY, BX, BY, t)
  local px, py = -ty, tx
  if px + py < 0 then px, py = -px, -py end
  local th = asin(max(-0.97, min(0.97, s)))
  local ph = 10 * th + 0.5
  local rib = 0.2 * sin(ph)                       -- tilt the normal toward the nearer rib crest
  local a = th + rib
  local sl = wslope(t)
  local nx = px * sin(a) - tx * sl * 1.4
  local ny = py * sin(a) - ty * sl * 1.4
  n[k] = { G.norm(nx, ny, cos(a)) }
  -- furrows: 1 px lines at fixed rib angles; deep and shallow alternate; lit crest beside each
  local w = max(1, wraw(t))
  if t > 0.05 and t < 0.95 then
    for _, g in ipairs(GTH) do
      local d = (s - sin(g[1])) * (w + 0.6)
      if abs(d) < 0.5 then groove[k] = (g[2] % 2 == 0) and 2 or 1 bias[k] = -groove[k]
      elseif d > -1.5 and d <= -0.5 and t > 0.1 and t < 0.9 and s < 0.3 then bias[k] = 1 end
    end
  end
end)
X.ao(bias, pm, sm, 2, -1)
-- warts: sparse bumps, lit-side up, shade-side down
local v = X.light(n, { amb = 0.08, wrap = 0.22 })
pm:each(function(x, y) local k = K(x, y)
  if not groove[k] and X.hash(x, y, 3) > 0.93 and PT[k] > 0.08 and PT[k] < 0.9 then
    bias[k] = (bias[k] or 0) + (v[k] > 0.55 and 1 or -1)
  end
end)
local ptok = { r = { name = "pod" } }
X.tone(c, pm, v, POD, { cuts = { 0.2, 0.37, 0.53, 0.68, 0.84 }, bias = bias, tok = ptok })
for k, g in pairs(groove) do local x, y = k % 1024 - 256, k // 1024 - 256
  if g == 2 then c:put(x, y, v[k] > 0.45 and POD[2] or POD[1], ptok) end end
-- cool reflected light on the lower-right edge
local rim = X.rim(n)
pm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.55 and PT[k] > 0.3 and PT[k] < 0.9 and not groove[k] then c:put(x, y, COOL, ptok) end end)
-- specular: 2x1 cream on the shoulder + a soft hi pixel under it
local bx, by = G.specAt(pm, n, 40)
c:put(bx, by, "#fff4d6", ptok) c:put(bx + 1, by, "#fff4d6", ptok) c:put(bx, by + 1, POD[6], ptok)

-- 5. quirk: tiny cacao flower on the twig (5 pale petals, pink staminodes, maroon eye) + a bud
local ftok = { r = { name = "flower" } }
local FL = {
  "...a...",
  "aa.a.bb",
  ".abdcb.",
  "..ded..",
  "..bdc..",
  ".bc.cc.",
  ".b...c.",
}
local fmap = { a = PET[1], b = PET[2], c = PET[3], d = PET[4], e = PET[5] }
for yy, row in ipairs(FL) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if fmap[ch] then c:put(40 + xx, 11 + yy, fmap[ch], ftok) end end end
c:put(44, 11, PET[5], ftok) c:put(44, 10, PET[5], ftok)              -- pedicel
-- bud on its own little stalk
c:put(39, 10, PET[5], ftok) c:put(39, 11, PET[4], ftok) c:put(38, 12, PET[3], ftok) c:put(39, 12, PET[3], ftok) c:put(38, 13, PET[2], ftok) c:put(39, 13, PET[3], ftok)

G.centre(c)
G.save(c, NAME)
