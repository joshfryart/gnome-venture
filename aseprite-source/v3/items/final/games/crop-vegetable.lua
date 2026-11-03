-- crop-vegetable (final, Opus single pass). A slim cucumber lying on the diagonal (blossom end lower-left,
-- stem end upper-right), gently bowed, blunt rounded ends; a ridged woody stem stub, one lobed cucumber leaf
-- and a coiled tendril.
-- Material: per-pixel tube light (6-tone green, cool-violet shade), pale lengthwise stripes that fade toward the
-- stem, raised warts (lit tip + dark underside + pale spine), waxy bloom specks, one specular streak + glint,
-- cool reflected light lower-right, AO cup where the stem meets. Leaf: palmate veins from the petiole. Stem: ridges +
-- paler snapped end grain. Tendril: 1px coil.
-- quirk: the dried yellow blossom is still clinging to the tip, one petal curling off.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA0_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, pi, max, min, sqrt, abs, atan = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.abs, math.atan
local c = A.new("crop-vegetable")
local GRN   = { "#11302a", "#1a4832", "#235e37", "#30783c", "#479446", "#74b65a" }
local STRP  = { "#2c5c40", "#42804a", "#5e9e56", "#80bc68", "#a6d47c", "#c8e898" }
local LEAF  = { "#1a3f39", "#255a44", "#33794a", "#4c9a50", "#74ba5a", "#a6d670" }
local STEM  = { "#2f3324", "#4a5230", "#6a7038", "#94904a", "#c8bc78" }
local PET   = { "#8f4a1f", "#c97a22", "#f0b02e", "#ffd862", "#fff0a0" }
local SPEC, BOUNCE, BLOOM = "#f2fbe0", "#4f7a8a", "#a9c8b8"
local tokL, tokB, tokS = { r = { name = "leaf" } }, { r = { name = "body" } }, { r = { name = "stem" } }

-- leaf (behind): three pointed lobes fanning from the petiole base B
local BX, BY = 47, 17
local lobes = { { -2.3, 13.5, 7.0 }, { -1.55, 10.5, 5.6 }, { -3.0, 10.0, 5.4 } }
local lm, ln = HP.mask(), {}
for _, L in ipairs(lobes) do
  local a, len, w = L[1], L[2], L[3]
  local ux, uy = cos(a), sin(a)
  local m = A.rell(BX + ux * (len * 0.5 + 1), BY + uy * (len * 0.5 + 1), ux, uy, len * 0.55, w * 0.5)
  -- pointed tip
  for i = 0, 3 do local f = len * 0.55 + len * 0.5 + i * 0.6 + 1
    m:set(floor(BX + ux * (f - 1.2) + .5), floor(BY + uy * (f - 1.2) + .5)) end
  lm:add(m)
end
lm:cut(c:ellipse(BX + 0.5, BY + 0.5, 1.5, 1.5))
-- serrated edge: nick a few edge pixels
lm:edge():each(function(x, y) if A.hash(x, y, 3) < 0.06 then lm.s[K(x, y)] = nil end end)
local nL = X.pillow(lm, 2.6)
local vL = X.light(nL, { amb = 0.12, wrap = 0.3 })
local idxL = X.tone(c, lm, vL, LEAF, { cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = tokL })
-- veins: along each lobe axis + side veins
lm:each(function(x, y)
  local dx, dy = x - BX, y - BY
  local r = sqrt(dx*dx + dy*dy)
  if r < 1.5 then return end
  local ang = atan(dy, dx)
  for _, L in ipairs(lobes) do
    local d = ang - L[1]
    while d > pi do d = d - 2*pi end while d < -pi do d = d + 2*pi end
    local off = d * r
    if abs(off) < 0.5 and r < L[2] * 0.95 then
      c:put(x, y, LEAF[max(1, (idxL[K(x, y)] or 3) - 2)], tokL)
    elseif r > 4 and r < L[2] * 0.75 and abs(abs(off) - (r - 4) * 0.7) < 0.4 and abs(off) < L[3] * 0.35 and A.hash(x, y, 2) < 0.8 then
      c:put(x, y, LEAF[max(1, (idxL[K(x, y)] or 3) - 1)], tokL)
    end
  end
end)

-- stem stub (ridged, woody), from body end up-right
local sm, sn, ST, SS, sidx = A.stem(c, { {48, 21}, {50, 18}, {52, 16}, {54, 14} }, function(t) return 1.7 - 0.3 * t end, STEM)
sm:each(function(x, y) local k = K(x, y) if abs(SS[k]) < 0.25 and ST[k] > 0.2 then c:put(x, y, STEM[max(1, sidx[k] - 1)], tokS) end end)
c:put(54, 13, STEM[5], tokS) c:put(55, 13, STEM[4], tokS) c:put(55, 14, STEM[3], tokS)  -- snapped end grain
-- petiole from stem to leaf base
A.ln(c, 47, 19, BX, BY, LEAF[3], nil, tokL)

-- tendril coil (1px), from stem down-right
local tx, ty = 52, 18
local prev
for i = 0, 70 do
  local t = i / 70
  local x, y
  if t < 0.35 then local u = t / 0.35 x, y = tx + u * 3, ty + u * 4
  else local u = (t - 0.35) / 0.65 local a = -pi * 0.5 + u * pi * 2.6 local r = 3.2 * (1 - u * 0.65)
    x, y = 56 + cos(a + pi) * r * -1, 25 + sin(a) * r end
  local xi, yi = floor(x + .5), floor(y + .5)
  c:put(xi, yi, (t < 0.5) and LEAF[4] or LEAF[5], tokL)
end

-- body
local P = { {14, 49}, {22, 39}, {36, 29}, {48, 21} }
local function hw(t)
  local e = t < 0.5 and (t / 0.08) or ((1 - t) / 0.07)
  local r = min(1, e) r = sqrt(1 - (1 - r) ^ 2)
  return (6.1 - 0.7 * t) * r + 0.2
end
local bm, bn, BT, BS, samp = A.tube(P, hw)
local bias = {}
-- AO near stem cup and under leaf/stem contact
bm:each(function(x, y) local k = K(x, y) if BT[k] > 0.95 then bias[k] = -1 end end)
local idx = A.shade(c, bm, bn, GRN, { amb = 0.06, wrap = 0.24, bias = bias, tok = tokB })
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
-- pale stripes lengthwise, broken, fading toward stem
local stripes = { -0.62, -0.2, 0.22, 0.6 }
bm:each(function(x, y) local k = K(x, y)
  local t, s = BT[k], BS[k]
  if t < 0.07 or t > 0.93 then return end
  for _, sv in ipairs(stripes) do
    if abs(s - sv) < 0.09 then
      local fade = t + A.hash(floor(t * LEN / 3), floor(sv * 10), 7) * 0.35
      if fade < 0.85 then c:put(x, y, STRP[idx[k]], tokB) end
    end
  end
end)
-- warts: raised bump (lit pixel, dark underside, pale spine tip)
local warts = { {0.18,-0.45}, {0.27,0.3}, {0.34,-0.1}, {0.42,-0.6}, {0.48,0.45}, {0.56,-0.3}, {0.64,0.15}, {0.71,-0.55}, {0.79,0.4}, {0.86,-0.2}, {0.23,0.75}, {0.6,0.7} }
for _, w in ipairs(warts) do
  local s = samp[floor(w[1] * 160) + 1]
  local x, y = floor(s.x + s.px * s.w * w[2] + .5), floor(s.y + s.py * s.w * w[2] + .5)
  if bm:has(x, y) then
    local i = idx[K(x, y)] or 3
    c:put(x, y, GRN[min(6, i + 1)], tokB)
    if bm:has(x + 1, y + 1) then c:put(x + 1, y + 1, GRN[max(1, i - 2)], tokB) end
    if w[2] < 0 and i >= 4 then c:put(x, y, BLOOM, tokB) end
  end
end
-- cool reflected light lower-right edge
local rim = X.rim(bn)
bm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.6 and BS[k] > 0.75 and BT[k] > 0.15 and BT[k] < 0.85 then c:put(x, y, BOUNCE, tokB) end end)
-- specular streak on the lit flank + glint
for _, q in ipairs{ {0.5, -0.58}, {0.54, -0.58}, {0.58, -0.56}, {0.62, -0.55}, {0.66, -0.55} } do
  local s = samp[floor(q[1] * 160) + 1]
  c:put(floor(s.x + s.px * s.w * q[2] + .5), floor(s.y + s.py * s.w * q[2] + .5), GRN[6], tokB)
end
do local s = samp[floor(0.57 * 160) + 1]
  c:put(floor(s.x + s.px * s.w * -0.58 + .5), floor(s.y + s.py * s.w * -0.58 + .5), SPEC, tokB) end
-- sunken stem cup
local cup = A.rell(47.6, 21.4, 0.8, -0.6, 1.8, 1.2)
cup:each(function(x, y) if bm:has(x, y) then c:put(x, y, GRN[1], tokB) end end)
c:put(48, 20, STEM[2], tokS) c:put(49, 20, STEM[3], tokS)

-- quirk: dried blossom clinging to the blossom end (five crumpled petals, one curling off)
local fx, fy = 12, 51
local flower = {
  "..aa.....",
  ".abba.d..",
  "aBbbcaed.",
  "abYyBcdd.",
  ".aybkcc..",
  "dacckca..",
  ".dda.cd..",
  "...d..d..",
}
local FP = { a = PET[2], b = PET[3], B = PET[4], Y = PET[5], y = PET[4], c = PET[1], k = "#5e3a2e", d = "#9a6a3a", e = "#c8955a" }
A.map(c, flower, fx - 3, fy - 4, FP)
A.save(c, "crop-vegetable")
