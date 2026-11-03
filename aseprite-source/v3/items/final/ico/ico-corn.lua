-- ico-corn (final, Opus). One slim ear of sweetcorn leaning to the right: straight rows of plump kernels running the
-- length of the cob, three husk leaves peeled back from the base (two flaring out, one wrapping the front), a short
-- cut stalk with pale end grain below, and a little tuft of silk curling off the tip.
-- Material: cylinder normals perturbed per kernel (each kernel its own dome) snapped to a 6-tone gold ramp, dark
-- grooves between rows, waxy specular streak down the lit side + one cream glint, AO where the husks wrap the cob;
-- husks have a midrib and parallel veins; silk is twisted two-tone strands.
-- quirk: one kernel has just popped and the popcorn is flying off to the left.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi, asin = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi, math.asin
local c = A.new("ico-corn")
local KER  = { "#8a4418", "#c46e1e", "#e9a22a", "#f7c63c", "#ffe27a", "#fff4c0" }
local GROOVE = "#7a3a1c"
local HUSK = { "#24543f", "#2f7446", "#4c9a4c", "#7cbf5a", "#b0d97a", "#e0f0a8" }
local SILK = { "#8f4a1f", "#c27a30", "#e8b060" }
local STK  = { "#4a5a2a", "#6e8a3a", "#a0b85a", "#e6dca0", "#c8b878" }
local POP  = { "#b59a8a", "#e8d8c0", "#fff4d6" }
local tK, tH, tS, tP = A.tok("kernel"), A.tok("husk"), A.tok("silk"), A.tok("pop")

-- cob
local P = { { 20, 46 }, { 27, 39 }, { 34, 32 }, { 42, 24 } }
local function hw(t)
  if t < 0.08 then return 5.0 + t / 0.08 * 0.9 end
  if t < 0.6 then return 5.9 end
  return 5.9 - ((t - 0.6) / 0.4) ^ 1.7 * 3.4
end
local cm, cn, CT, CS, samp = A.tube(P, hw)
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i - 1].x) ^ 2 + (samp[i].y - samp[i - 1].y) ^ 2) end
-- per-kernel perturbation
local DPHI, DL = 0.56, 3.3
local groove, klit, kdark = HP.mask(), HP.mask(), HP.mask()
local kn = cn
local function frac(v) return v - floor(v) end
cm:each(function(x, y)
  local k = K(x, y)
  local t, s = CT[k], CS[k]
  local phi = asin(max(-0.99, min(0.99, s)))
  local col = floor(phi / DPHI + 0.5)
  local fu = frac(phi / DPHI + 0.5) - 0.5            -- across (+ = shade side)
  local fv = frac(t * LEN / DL + (col % 2) * 0.5) - 0.5   -- along (+ = toward the tip); rows stagger slightly
  local gw = 0.5 - 0.5 / max(1, DPHI * 6 * cos(phi))  -- groove ~1px whatever the foreshortening
  if fu > gw or fv < -0.36 then groove:set(x, y)
  elseif fv > 0.0 and fu < 0.0 then klit:set(x, y)
  elseif fv < -0.18 or fu > 0.22 then kdark:set(x, y) end
end)
-- husks have a midrib and parallel veins; silk is twisted two-tone strands.
-- quirk: one kernel has just popped and the popcorn is flying off to the left.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi, asin = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi, math.asin
local c = A.new("ico-corn")
local KER  = { "#8a4418", "#c46e1e", "#e9a22a", "#f7c63c", "#ffe27a", "#fff4c0" }
local GROOVE = "#7a3a1c"
local HUSK = { "#24543f", "#2f7446", "#4c9a4c", "#7cbf5a", "#b0d97a", "#e0f0a8" }
local SILK = { "#8f4a1f", "#c27a30", "#e8b060" }
local STK  = { "#4a5a2a", "#6e8a3a", "#a0b85a", "#e6dca0", "#c8b878" }
local POP  = { "#b59a8a", "#e8d8c0", "#fff4d6" }
local tK, tH, tS, tP = A.tok("kernel"), A.tok("husk"), A.tok("silk"), A.tok("pop")

-- cob
local P = { { 20, 46 }, { 27, 39 }, { 34, 32 }, { 42, 24 } }
local function hw(t)
  if t < 0.08 then return 5.0 + t / 0.08 * 0.9 end
  if t < 0.6 then return 5.9 end
  return 5.9 - ((t - 0.6) / 0.4) ^ 1.7 * 3.4
end
local cm, cn, CT, CS, samp = A.tube(P, hw)
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i - 1].x) ^ 2 + (samp[i].y - samp[i - 1].y) ^ 2) end
-- per-kernel perturbation
local DPHI, DL = 0.62, 3.1
local groove = HP.mask()
local kn = {}
local function frac(v) return v - floor(v) end
cm:each(function(x, y)
  local k = K(x, y)
  local t, s = CT[k], CS[k]
  local phi = asin(max(-0.99, min(0.99, s)))
  local d = t * LEN
  local fu = frac(phi / DPHI + 0.5) - 0.5
  local row = floor(phi / DPHI + 0.5)
  local fv = frac(d / DL + (row % 2) * 0.0) - 0.5
  local si = floor(t * 160) + 1
  local sm = samp[si]
  local n = cn[k]
  local a, b = fv * 0.9, fu * 0.7 / max(0.35, cos(phi))
  kn[k] = { A.norm(n[1] + sm.tx * a + sm.px * b, n[2] + sm.ty * a + sm.py * b, n[3]) }
  local edgeU = abs(fu) * DPHI * 5.2 * cos(phi)
  if abs(fu) > 0.40 or abs(fv) > 0.36 then groove:set(x, y) end
end)
-- husks
local function husk(ax, ay, cx, cy, bx, by, wmax, fold)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t < 0.12 then return 1.4 + t / 0.12 * (wmax - 1.4) end
    return wmax * (1 - ((t - 0.12) / 0.88) ^ 1.5) + 0.3
  end, { fold = fold or 0.5 })
  return { m = m, n = n, T = T, S = S }
end
local hL = husk(19, 49, 9, 42, 10, 29, 3.4, 0.55)
local hR = husk(22, 50, 30, 55, 40, 50, 3.2, 0.55)
local hF = husk(19, 51, 26, 47, 30, 39, 3.0, 0.45)
local huskAll = A.union{ hL.m, hR.m, hF.m }
-- stalk stub under the husks
local stM, stN = A.seg(19, 50, 15, 54, 2.3, 2.2)

-- paint: stalk, back husks, cob, front husk
local sidx = A.shade(c, stM, stN, { STK[1], STK[2], STK[3] }, { tok = tS, cuts = { 0.35, 0.6 } })
-- pale cut end grain at the bottom of the stalk (an ellipse face with a ring)
local eb = HP.mask()
for _, p in ipairs{ { 13, 54 }, { 14, 55 }, { 14, 54 }, { 13, 55 }, { 12, 55 }, { 13, 56 }, { 14, 53 }, { 15, 55 } } do eb:set(p[1], p[2]) end
eb:each(function(x, y) c:put(x, y, STK[4], tS) end)
c:put(13, 55, STK[5], tS) c:put(14, 54, STK[5], tS)
for _, h in ipairs{ hL, hR } do
  local hb = {}
  X.ao(hb, h.m, stM, 1, -1)
  local idx = A.shade(c, h.m, h.n, HUSK, { tok = tH, bias = hb, amb = 0.12, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  h.idx = idx
end
local kb = {}
X.ao(kb, cm, huskAll, 2, -1)
groove:each(function(x, y) kb[K(x, y)] = (kb[K(x, y)] or 0) - 2 end)
klit:each(function(x, y) kb[K(x, y)] = (kb[K(x, y)] or 0) + 1 end)
kdark:each(function(x, y) kb[K(x, y)] = (kb[K(x, y)] or 0) - 1 end)
-- tip kernels smaller and paler (immature)
local kidx = A.shade(c, cm, kn, KER, { tok = tK, bias = kb, amb = 0.14, wrap = 0.3, cuts = { 0.14, 0.28, 0.43, 0.6, 0.8 } })
groove:each(function(x, y) local k = K(x, y) if (kidx[k] or 1) <= 1 then c:put(x, y, GROOVE, tK) end end)
-- waxy specular streak on the lit side + cream glint
cm:each(function(x, y) local k = K(x, y)
  local t, s = CT[k], CS[k]
  if t > 0.2 and t < 0.66 and s > -0.66 and s < -0.36 and klit:has(x, y) then c:put(x, y, KER[6], tK) end
end)
do local s = samp[floor(0.42 * 160) + 1]
  local gx, gy = floor(s.x + s.px * s.w * -0.5 + 0.5), floor(s.y + s.py * s.w * -0.5 + 0.5)
  c:put(gx, gy, A.CREAM, tK) end
-- front husk over the cob, with contact shadow onto the cob
local fb = {}
local fidx = A.shade(c, hF.m, hF.n, HUSK, { tok = tH, bias = fb, amb = 0.12, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
hF.idx = fidx
hF.m:shift(1, 1):each(function(x, y) if cm:has(x, y) and not hF.m:has(x, y) then A.step(c, kidx, KER, x, y, -1, tK) end end)
-- veins: midrib (one tone darker) and a lit parallel vein on the lit half
for _, h in ipairs{ hL, hR, hF } do
  h.m:each(function(x, y) local k = K(x, y)
    local t, s = h.T[k], h.S[k]
    if t > 0.1 and t < 0.92 then
      if abs(s) < 0.16 then A.step(c, h.idx, HUSK, x, y, -1, tH)
      elseif abs(s + 0.6) < 0.12 and t < 0.8 then A.step(c, h.idx, HUSK, x, y, 1, tH) end
    end
  end)
end

-- silk: three twisted strands curling out of the tip
local tipx, tipy = 39, 11
local strands = {
  { { 42, 24 }, { 45, 19 }, { 49, 17 }, { 51, 20 } },
  { { 41, 23 }, { 42, 18 }, { 45, 15 }, { 48, 15 } },
  { { 43, 25 }, { 48, 24 }, { 51, 25 }, { 52, 29 } },
}
for si, sp in ipairs(strands) do
  local last
  for i = 0, 60 do
    local t = i / 60
    local x, y = A.bez(sp, t)
    local xi, yi = floor(x + 0.5), floor(y + 0.5)
    if not last or last ~= xi .. "," .. yi then
      local col = (floor(t * 7) % 2 == 0) and SILK[3] or SILK[2]
      if t < 0.2 then col = SILK[1] end
      c:put(xi, yi, col, tS)
      last = xi .. "," .. yi
    end
  end
end
c:put(42, 24, SILK[1], tS) c:put(43, 24, SILK[2], tS) c:put(42, 23, SILK[1], tS)
-- quirk: popcorn flying off to the upper left (puffy cream, with its little gold hull + motion pip)
local PX, PY = 22, 26
local pm = A.ell(PX, PY, 2.2, 1.8):add(A.ell(PX - 2, PY - 2, 1.6, 1.6)):add(A.ell(PX + 1.5, PY - 2.5, 1.7, 1.6)):add(A.ell(PX - 2.5, PY + 0.5, 1.4, 1.4))
local pn = X.pillow(pm, 2)
A.shade(c, pm, pn, POP, { tok = tP, amb = 0.3, wrap = 0.4, cuts = { 0.4, 0.7 } })
c:put(PX, PY + 2, KER[3], tP) c:put(PX + 1, PY + 2, KER[2], tP) c:put(PX + 2, PY + 1, KER[2], tP)
c:put(PX - 2, PY - 3, A.CREAM, tP)
-- motion pips toward the cob
c:put(PX + 5, PY + 2, POP[2], tP) c:put(PX + 4, PY + 4, POP[2], tP)
-- a tiny empty socket on the cob where the kernel was
do local s = samp[floor(0.55 * 160) + 1]
  local gx, gy = floor(s.x + s.px * s.w * -0.85 + 0.5), floor(s.y + s.py * s.w * -0.85 + 0.5)
  c:put(gx, gy, GROOVE, tK) c:put(gx + 1, gy, KER[1], tK) end

A.save(c, "ico-corn")
