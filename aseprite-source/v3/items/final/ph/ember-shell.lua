-- ember-shell (final, Opus single pass). The shed back-shell of an ember beetle, seen from above and tilted: a rounded
-- pronotum shield on top, then the two wing-cases (elytra) meeting on a straight suture and parting a little at the
-- tips. Lacquered charcoal-maroon chitin with per-pixel dome light per plate (6 tones), lengthwise striae with puncture
-- pits, and the grooves cracked open to show glowing ember (orange -> yellow, hottest mid-length) with a warm glow on
-- the chitin beside each crack. Bright bevel along the suture, cool reflected light on the right edge, AO row under the
-- pronotum where the plates meet, lacquer specular on the left shoulder.
-- quirk: a thin curl of smoke still rises off the shoulder.
local NAME = "ember-shell"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local CH  = { "#170d1a", "#2a1326", "#431a2e", "#632433", "#8c3639", "#bd5c4a" }
local EMB = { "#a8301f", "#e8621f", "#ff9d36", "#ffdc80" }
local GLOW, COOL, SPEC = "#7c2b2a", "#4b3c62", "#f3c2a6"
local SMOKE = { "#8d8299", "#b9afc2" }
local CUTS = { 0.3, 0.46, 0.6, 0.74, 0.88 }

local F = A.axis(29, 9, 35, 56)
local len = F.len
local T0 = 0.27                                   -- pronotum / elytra join
local function Wp(t) local u = t / T0 return 5.2 + 3.4 * sin(min(1, u * 1.05) * pi / 2) ^ 0.8 end
local function We(t) local u = (t - T0) / (1 - T0) return 10.2 * max(0, 1 - u ^ 2.4) ^ 0.5 * (1 - 0.08 * u) end

local pro, el, er = HP.mask(), HP.mask(), HP.mask()
local n, TT, SS = {}, {}, {}
for y = 0, 63 do for x = 0, 63 do
  local t, s = F.at(x, y)
  local k = K(x, y)
  if t >= 0.0 and t < T0 then
    -- front edge slightly concave (where the head sat)
    if abs(s) <= Wp(t) and t * len >= 0.6 + 1.6 * (1 - (s / 6) ^ 2) * (abs(s) < 6 and 1 or 0) then
      pro:set(x, y) TT[k], SS[k] = t, s
      local sn = max(-0.95, min(0.95, s / (Wp(t) + 0.8)))
      local a = ((t / T0) - 0.55) * 0.9
      n[k] = { A.norm(F.px * sn + F.ux * a, F.py * sn + F.uy * a, 0.9) }
    end
  elseif t >= T0 + 0.025 and t <= 1 then
    local W = We(t)
    local gap = t > 0.86 and (t - 0.86) * len * 0.45 or 0
    if abs(s) <= W and abs(s) >= gap and W > 0.6 then
      local side = s < 0 and -1 or 1
      local cen = side * W * 0.5
      local sn = max(-0.95, min(0.95, (s - cen) / (W * 0.5 + 0.9)))
      local a = ((t - T0) / (1 - T0) - 0.4) * 0.8
      n[k] = { A.norm(F.px * sn + F.ux * a, F.py * sn + F.uy * a, 0.85) }
      TT[k], SS[k] = t, s
      if side < 0 then el:set(x, y) else er:set(x, y) end
    end
  end
end end
local all = pro:copy():add(el):add(er)
local v = X.light(n, { amb = 0.1, wrap = 0.2 })

-- striae + pits as tone bias on the elytra; AO under the pronotum
local bias, groove = {}, HP.mask()
for _, m in ipairs{ el, er } do m:each(function(x, y) local k = K(x, y)
  local t, s = TT[k], SS[k]
  local W = We(t) local f = abs(s) / max(1, W)
  for _, g in ipairs{ 0.36, 0.7 } do
    local d = (f - g) * W
    if abs(d) < 0.5 and t > T0 + 0.05 and t < 0.92 then bias[k] = -2 groove:set(x, y)
    elseif d < -0.5 and d > -1.5 and t > T0 + 0.05 and t < 0.9 then bias[k] = (bias[k] or 0) + 1 end
  end
  if abs((f - 0.53) * W) < 0.5 and floor(t * len) % 3 == 1 and t < 0.86 then bias[k] = -1 end
end) end
X.ao(bias, el, pro, 2, -1) X.ao(bias, er, pro, 2, -1)
X.ao(bias, el, er, 1, -1)
local ptok, ltok, rtok = A.tok("pronotum"), A.tok("elytL"), A.tok("elytR")
local idxP = X.tone(c, pro, v, CH, { cuts = CUTS, bias = bias, tok = ptok })
local idxL = X.tone(c, el, v, CH, { cuts = CUTS, bias = bias, tok = ltok })
local idxR = X.tone(c, er, v, CH, { cuts = CUTS, bias = bias, tok = rtok })
local idx = {} for _, t in ipairs{ idxP, idxL, idxR } do for k, i in pairs(t) do idx[k] = i end end
local function tk(x, y) return pro:has(x, y) and ptok or el:has(x, y) and ltok or rtok end

-- pronotum: raised rim along the front edge + midline keel
local E = all:edge()
pro:each(function(x, y) local k = K(x, y)
  if abs(SS[k]) < 0.5 and TT[k] > 0.08 then c:put(x, y, idx[k] >= 4 and CH[5] or CH[3], ptok) end end)
-- suture bevel: bright lip on the left elytron's inner edge, dark seam on the right
el:each(function(x, y) local k = K(x, y) if not E:has(x, y) and SS[k] > -1.5 and TT[k] < 0.86 then c:put(x, y, TT[k] < 0.6 and CH[6] or CH[5], ltok) end end)
er:each(function(x, y) local k = K(x, y) if SS[k] < 1 and TT[k] < 0.86 then c:put(x, y, CH[1], rtok) end end)
-- cool bounce on the right outer edge
E:each(function(x, y) local k = K(x, y) if SS[k] and SS[k] > 3 and TT[k] > 0.4 and TT[k] < 0.9 then c:put(x, y, COOL, tk(x, y)) end end)

-- ember cracks in the striae (broken runs) + a forked crack across the pronotum
local hot = HP.mask()
groove:each(function(x, y) local k = K(x, y)
  local t, s = TT[k], SS[k]
  local gi = (s < 0 and 1 or 3) + ((abs(s) / We(t)) > 0.53 and 1 or 0)
  local run = sin(t * len * 0.38 + gi * 2.3) + 0.4 * sin(t * len * 1.1 + gi * 0.7)
  if run > -0.15 then
    hot:set(x, y)
    local heat = 1.05 - abs(t - 0.58) * 2.6 + (run > 0.9 and 0.25 or 0) + (X.hash(x, y, 7) > 0.85 and 0.3 or 0)
    c:put(x, y, heat > 0.85 and EMB[4] or heat > 0.45 and EMB[3] or heat > 0.0 and EMB[2] or EMB[1], tk(x, y))
  end
end)
local function crack(pts, col)
  HP.line(pts, 1):each(function(x, y) if all:has(x, y) and not E:has(x, y) then hot:set(x, y) c:put(x, y, col, tk(x, y)) end end)
end
local function P(t, s) local x, y = F.pt(t, s) return { x, y } end
crack({ P(0.07, 2.2), P(0.13, 1.2), P(0.19, 2.6), P(0.24, 1.8) }, EMB[2])
crack({ P(0.13, 1.2), P(0.17, -1.6) }, EMB[3])
crack({ P(0.55, 2.6), P(0.6, 5.2) }, EMB[2])
crack({ P(0.48, -2.4), P(0.52, -4.8) }, EMB[3])
hot:grow(1):cut(hot):each(function(x, y) local k = K(x, y)
  if all:has(x, y) and not E:has(x, y) and (idx[k] or 6) <= 4 then c:put(x, y, GLOW, tk(x, y)) end end)

-- lacquer specular on the left shoulder (+1 px glint on the pronotum)
local sx, sy = F.pt(T0 + 0.07, -6.4) sx, sy = floor(sx + .5), floor(sy + .5)
c:put(sx, sy, SPEC, ltok) c:put(sx + 1, sy, SPEC, ltok) c:put(sx, sy + 1, CH[6], ltok)
local gx, gy = F.pt(0.12, -4.2) c:put(floor(gx + .5), floor(gy + .5), CH[6], ptok)

-- quirk: smoke curl rising off the right shoulder
local wx, wy = F.pt(0.1, Wp(0.1) + 1.2) wx, wy = floor(wx + .5), floor(wy + .5)
local stok = A.tok("smoke")
for i, p in ipairs{ { 0, 0 }, { 1, -1 }, { 1, -2 }, { 0, -3 }, { 0, -4 }, { 1, -5 }, { 2, -6 }, { 3, -6 } } do
  c:put(wx + p[1], wy + p[2], i > 4 and SMOKE[2] or SMOKE[1], stok) end
A.save(c, NAME)
