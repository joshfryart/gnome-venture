-- coconut-seed (batch2, final, Opus). The real seed: a whole coconut still in its dry husk, lying on its side on a
-- scrap of palm leaflet, sprouting from the stalk end the way coconuts do: a pale spear of a shoot through a little
-- star of dry calyx lobes, opening into the first pleated, two-lobed (fish-tail) palm leaf. Material: husk = 6-tone
-- greyed tan with fibre streaks along the long axis and a trigonal ridge; leaflet = 6-tone deep palm green, raised
-- pale midrib, V fold, torn base and a yellowing tip; young leaf = 6-tone bright green with plicate pleats; AO and
-- a hard contact shadow where the nut sits on the leaf; cool bounce on the husk underside; one 2x1 specular.
-- Draft (Sonnet, comb-like frond under a round nut) replaced.
-- quirk: a tiny barnacle is stuck to the husk, a souvenir of the nut's drift across the sea.
local NAME = "coconut-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_b2g4.lua")
local HP, X, c = G.new(NAME)
local K = G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local HUSK  = { "#2e2025", "#4b352f", "#6d523d", "#91714e", "#b59562", "#d8ba82" }
local PALM  = { "#163a34", "#1f5440", "#2c7047", "#418c4c", "#61a854", "#8fc76a" }
local RIB   = { "#6b7a3a", "#97a650", "#c3cd72", "#e3e59c" }
local YEL   = { "#8a7a2c", "#b8a23e", "#dcc65a" }
local YOUNG = { "#245338", "#33743f", "#4e9846", "#74b850", "#a2d462", "#cfec8c" }
local SHOOT = { "#6f8a4a", "#9db764", "#c8d98a", "#eaf0bc" }
local BOUNCE, SPEC = "#77769a", "#fff1cc"

-- ---------- nut (husk), lying, tilted up to the right
local NX, NY, NRX, NRY, NA = 27, 40, 14.5, 9.6, -0.26
local nut, nn = G.oval(NX, NY, NRX, NRY, NA, 1.0)
local ca, sa = cos(NA), sin(NA)
local function nutUV(x, y) local dx, dy = x - NX, y - NY return (dx * ca + dy * sa) / NRX, (-dx * sa + dy * ca) / NRY end
local function nutXY(u, v) return NX + u * NRX * ca - v * NRY * sa, NY + u * NRX * sa + v * NRY * ca end

-- ---------- leaflet scrap under the nut
local AX, AY, CX, CY, BX, BY = 6, 51, 30, 57, 57, 46
local lm, ln, LT, LS, llen = G.blade(AX, AY, CX, CY, BX, BY, function(t)
  if t > 0.985 then return -1 end
  local w = 3.9
  if t > 0.68 then w = 3.9 * ((1 - t) / 0.32) ^ 0.7 + 0.4 end
  return w
end, { fold = 0.5 })
-- torn base: ragged diagonal
lm:each(function(x, y) local k = K(x, y)
  local u = LT[k] * llen
  if u < 2.5 + LS[k] * 2.2 + X.hash(floor(LS[k] * 4), 1, 3) * 1.4 then lm.s[k] = nil end
end)
lm:cut(nut)
local lb = {}
X.ao(lb, lm, nut, 1, -1) G.cast(lb, lm, nut, 1, 2, -1) G.cast(lb, lm, nut, 2, 3, -1)
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, PALM, { bias = lb, tok = ltok, amb = 0.12, wrap = 0.25, cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
lm:each(function(x, y) local k = K(x, y)
  local s, t = LS[k], LT[k]
  if lb[k] then return end
  if abs(s) < 0.16 and t < 0.94 then c:put(x, y, s <= 0 and RIB[4] or RIB[2], ltok)       -- raised midrib
  elseif abs(abs(s) - 0.56) < 0.1 then c:put(x, y, s < 0 and PALM[5] or PALM[3], ltok) end -- parallel vein
  if t > 0.86 then                                                                          -- yellowing tip
    c:put(x, y, (s < -0.1) and YEL[3] or (s > 0.3 and YEL[1] or YEL[2]), ltok)
  end
end)

-- ---------- nut lighting, fibres, ridge
local nb = {}
nut:each(function(x, y) local k = K(x, y)
  local u, v = nutUV(x, y)
  local lane = floor((v + 1.2) * 8.5)
  local seg = floor((u + 1) * 16 / (5 + X.hash(lane, 1, 4) * 7) + X.hash(lane, 2, 4) * 3)
  local h = X.hash(lane, seg, 6)
  if h > 0.68 then nb[k] = -1 elseif h < 0.1 then nb[k] = 1 end
  local rv = -0.18 - 0.12 * (1 - u * u)                 -- trigonal ridge along the top
  if abs(u) < 0.86 then
    if v - rv > -0.12 and v - rv <= 0 then nb[k] = 1 elseif v - rv > 0 and v - rv < 0.12 then nb[k] = -1 end
  end
end)
local ntok = { r = { name = "husk" } }
G.toneN(c, nut, nn, HUSK, { bias = nb, tok = ntok, amb = 0.06, wrap = 0.22, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
local rim = X.rim(nn)
nut:edge():each(function(x, y) local u, v = nutUV(x, y) if rim[K(x, y)] > 0.6 and v > 0.2 then c:put(x, y, BOUNCE, ntok) end end)
local sx, sy = G.specAt(nut, nn, 30)
c:put(sx, sy, SPEC, ntok) c:put(sx + 1, sy, HUSK[6], ntok)

-- ---------- barnacle (quirk), lower-left on the husk
local bx, by = nutXY(-0.5, 0.42) bx, by = floor(bx + 0.5), floor(by + 0.5)
local BAR = { "#5d5a72", "#9a97a8", "#d2cfd4", "#f2ede4" }
for _, p in ipairs{ {-1,0,3}, {0,0,1}, {1,0,2}, {-2,1,3}, {-1,1,4}, {0,1,3}, {1,1,2}, {2,1,1}, {-1,-1,4}, {0,-1,3}, {1,-1,2} } do
  c:put(bx + p[1], by + p[2], BAR[p[3]], ntok)
end
c:put(bx, by - 1, BAR[2], ntok) c:put(bx, by, "#2b1c26", ntok)

-- ---------- calyx + shoot from the stalk end (upper right)
local ex, ey = nutXY(0.9, -0.3) ex, ey = floor(ex + 0.5), floor(ey + 0.5)
local stok = { r = { name = "shoot" } }
local sm, sT = G.sweep({ { ex, ey + 1 }, { ex + 1, ey - 4 }, { ex - 1, ey - 7 }, { ex, ey - 11 } }, function(t) return 1.7 - t * 0.5 end, 60)
local snm = {}
sm:each(function(x, y) local k = K(x, y) snm[k] = 1 end)
local sn = X.pillow(sm, 1.6)
local sb = {} X.ao(sb, sm, nut, 1, -1)
G.toneN(c, sm, sn, SHOOT, { tok = stok, bias = sb, amb = 0.12, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
-- calyx: three dry pointed lobes around the shoot base
local CAL = { "#3b2a26", "#6a4a34", "#9b7246" }
for _, L in ipairs{ { -4, 0 }, { 4, -1 }, { 1, 3 } } do
  G.pl(c, { { ex, ey }, { ex + L[1], ey + L[2] } }, CAL[2], ntok)
  G.pl(c, { { ex, ey + 1 }, { ex + L[1] * 0.6, ey + L[2] * 0.6 + 1 } }, CAL[1], ntok)
  c:put(ex + L[1], ey + L[2], CAL[3], ntok)
end
c:put(ex - 1, ey - 1, CAL[3], ntok) c:put(ex - 2, ey - 1, CAL[3], ntok)

-- ---------- first leaf: bifid (two lobes in a V), pleated
local tx, ty = ex, ey - 11
local ytok = { r = { name = "young" } }
local function lobe(bx2, by2, w)
  local m, n, T, S = X.cyl(tx, ty, bx2, by2, function(t)
    if t > 0.97 then return -1 end
    return max(0.6, w * sin(pi * min(1, t * 0.95 + 0.08)) ^ 0.8)
  end)
  m:cut(sm)
  local b = {}
  local pleat = {}
  m:each(function(x, y) local k = K(x, y)
    local p = (S[k] + 1) * 2.5                            -- plicate pleats parallel to the lobe
    if abs(S[k]) > 0.25 and p % 1 < 0.3 and T[k] > 0.12 and T[k] < 0.9 then pleat[k] = true end
  end)
  G.toneN(c, m, n, YOUNG, { bias = b, tok = ytok, amb = 0.14, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.12 and T[k] < 0.9 then c:put(x, y, S[k] <= 0 and YOUNG[6] or YOUNG[3], ytok)
    elseif pleat[k] then c:put(x, y, YOUNG[2], ytok) end
  end)
  return m
end
lobe(tx - 12, ty - 17, 3.9)
lobe(tx + 12, ty - 15, 3.6)
G.save(c, NAME)
