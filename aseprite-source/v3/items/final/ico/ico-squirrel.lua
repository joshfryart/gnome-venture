-- ico-squirrel (final, Opus). A red squirrel sitting up in profile, facing left, nibbling an acorn held in both
-- forepaws. Big round head with a short muzzle (ink nose tip + glint), a 2x3 eye pill, a tall ear with a dark tuft,
-- slim body with a cream bib, a round haunch and a long hind foot. The tail sweeps up behind in an S and curls over
-- at the top: per-pixel tube light with fur strands (dark grooves + lit tips) and a ragged tufted outer edge.
-- AO where the body sits on the tail and the head on the body; acorn has a cross-hatched cap and a waxy nut.
-- quirk: a little oak leaf is caught in the tail fur.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA10_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = A.new("ico-squirrel")
local FR = { "#4a1f22", "#7a2f26", "#a8462a", "#cf6531", "#ec8a44", "#ffb56a" }   -- rust fur
local TL = { "#3e1a22", "#62242a", "#8a342c", "#b04a2e", "#d26a36", "#ee9450" }   -- tail (deeper chestnut than the body)
local FRG = { "#c8785a", "#eaa070", "#ffd09a" }                                  -- frosted guard-hair tips
local CR = { "#a8785e", "#d4a77e", "#f2d2a6", "#fff0d2" }                         -- bib
local NUT = { "#4a2a1e", "#7a4626", "#a8662e", "#cf8a3c", "#efb460", "#ffe0a0" }
local CAP = { "#4a2e22", "#74502e", "#a07a44", "#cca468" }
local OAK = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local tt, bt, nt = { r = { name = "tail" } }, { r = { name = "body" } }, { r = { name = "nut" } }

-- tail: S-curve tube up the right, curling over at the top toward the head
local p = { { 32, 51 }, { 52, 54 }, { 55, 19 }, { 43, 12 } }
local function tw(t)
  if t < 0.1 then return 3.0 + t / 0.1 * 3.0 end
  return 5.6 + sin(pi * min(1, (t - 0.1) / 0.8)) * 1.2 - max(0, t - 0.9) * 10
end
local tm, tn, TT, TS, samp = A.tube(p, tw)
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
-- the tip hooks over and down toward the head (separate roll, dark crease where it lies on the tail)
local hk, hkn, HT, HS = A.tube({ { 44, 12 }, { 37.5, 9 }, { 33, 12.5 }, { 34.5, 19 } }, function(t) return 4.0 - t * 1.4 end)
local crease = A.touch(tm:copy():cut(hk), hk)
hk:each(function(x, y) local k = K(x, y) tm:set(x, y) tn[k] = hkn[k] TT[k] = 1 + HT[k] TS[k] = HS[k] end)
-- scalloped tufts along the outer side
for i = 52, #samp - 12, 14 do
  local s = samp[i]
  local bx, by = s.x + s.px * (s.w + 0.6) - s.tx * 1.2, s.y + s.py * (s.w + 0.6) - s.ty * 1.2
  local bm2, bn2 = A.oval(bx, by, 2.1, 1.6, math.atan(s.ty, s.tx), 1)
  bm2:each(function(x, y) local k = K(x, y) if not tm:has(x, y) then tm:set(x, y) tn[k] = bn2[k] TT[k] = s.t TS[k] = 1 end end)
end
local tb = {}
-- fur clumps: chevron grooves across the tail
tm:each(function(x, y) local k = K(x, y)
  local s, t = TS[k] or 0, TT[k] or 0
  local g = (t * LEN + abs(s) * 2.6) / 3.4
  local f = g - floor(g)
  if f < 0.3 and abs(s) < 0.9 and abs(s) > 0.1 then tb[k] = -1 end
end)
local tidx = A.shade(c, tm, tn, TL, { amb = 0.08, wrap = 0.3, bias = tb, tok = tt })
-- frosted guard-hair fringe all round the outer side (lit tips top-left, dim tips in the shade)
tm:edge():each(function(x, y) local k = K(x, y) local i = tidx[k] or 3
  local outer = (TS[k] or 0) > 0.25 or not tm:has(x, y - 1) or (TT[k] or 0) > 1
  if outer then
    if i >= 4 then c:put(x, y, FRG[3], tt) elseif i >= 2 then c:put(x, y, FRG[2], tt) else c:put(x, y, FRG[1], tt) end
  end end)
-- crease under the hooked tip
crease:each(function(x, y) A.step(c, tidx, TL, x, y, -2, tt) end)

-- haunch + body
local hm, hn = A.oval(30, 46, 7, 6.5, 0, 1)
local bm, bn = A.oval(24.5, 39, 7, 10.5, 0.22, 1)
local body = bm:copy():add(hm)
local bodyn = {}
for k, v in pairs(bn) do bodyn[k] = v end
for k, v in pairs(hn) do if not bm:has(k % 1024 - 256, k // 1024 - 256) or v[3] > 0.6 then bodyn[k] = v end end
local bb = {}
-- seam where haunch meets body (darker crease on the front of the haunch)
hm:each(function(x, y) local d = sqrt(((x - 30) / 7) ^ 2 + ((y - 46) / 6.5) ^ 2)
  if d > 0.78 and d < 0.98 and x < 30 and y < 47 and bm:has(x, y) then bb[K(x, y)] = -1 end end)
local bidx = A.shade(c, body, bodyn, FR, { amb = 0.08, wrap = 0.3, bias = bb, tok = bt })
-- AO on tail where the body sits on it
A.touch(tm:copy():cut(body), body):each(function(x, y) A.step(c, tidx, TL, x, y, -2, tt) end)
-- cream bib on the chest
local bib = A.oval(21, 38, 3.4, 8, 0.25, 1):clip(bm):cut(c:rect(0, 47, 63, 63))
bib:each(function(x, y) local k = K(x, y) local i = bidx[k] or 3
  c:put(x, y, CR[max(1, min(4, i - 1))], bt) end)
-- hind foot: long, flat, toes forward
local fm, fn = A.oval(24, 53, 6, 2, 0, 1)
local fidx = A.shade(c, fm, fn, FR, { amb = 0.1, tok = bt, bias = {} })
A.touch(fm, body):each(function(x, y) if not body:has(x, y) then A.step(c, fidx, FR, x, y, -1, bt) end end)
for x = 19, 28 do if fm:has(x, 54) and not fm:has(x, 55) then end end
c:put(19, 54, FR[2], bt)
-- head
local hd, hdn = A.oval(20, 24, 7, 6.5, 0, 1)
local hb = {}
local hidx = A.shade(c, hd, hdn, FR, { amb = 0.08, wrap = 0.28, bias = hb, tok = bt })
-- AO on body under the head
A.touch(body:copy():cut(hd), hd):each(function(x, y) A.step(c, bidx, FR, x, y, -2, bt) end)
-- ear with dark tuft
local ear = c:poly{ { 21, 19 }, { 24, 11 }, { 27, 20 } }
local en = A.slab(ear, 1.5)
local eidx = A.shade(c, ear, en, FR, { amb = 0.1, tok = bt })
c:put(24, 12, FR[3], bt) c:put(24, 15, "#e88a7a", bt) c:put(24, 16, "#e88a7a", bt) c:put(25, 17, "#c45e5e", bt)
A.map(c, { ".k", "kk", "k." }, 23, 9, { k = FR[1] }, bt)
c:put(24, 8, FR[1], bt)
-- muzzle
local mz, mzn = A.oval(13.5, 27, 3.6, 3, 0.15, 1)
local midx = A.shade(c, mz, mzn, FR, { amb = 0.12, tok = bt })
mz:each(function(x, y) if y >= 28 then c:put(x, y, CR[(midx[K(x, y)] or 3) >= 4 and 3 or 2], bt) end end)
-- nose tip, mouth
c:put(10, 26, A.INK, bt) c:put(10, 27, A.INK, bt) c:put(11, 26, A.INK, bt) c:put(10, 25, "#6a3a3a", bt)
c:put(11, 25, A.CREAM, bt)
c:put(12, 29, FR[1], bt) c:put(13, 29, FR[2], bt)
-- cheek fur line separating muzzle from head
for _, q in ipairs{ { 16, 26 }, { 17, 27 }, { 17, 28 } } do A.step(c, hidx, FR, q[1], q[2], -1, bt) end
-- eye pill + glint, pale eye ring
c:put(15, 21, FR[6], bt) c:put(16, 21, FR[6], bt) c:put(17, 22, FR[6], bt)
c:eyeSmall(15, 22)
c:put(16, 25, FR[5], bt)
c:cheek(18, 26)

-- acorn held up in the forepaws, at the mouth
local nm, nn = A.oval(13, 36, 3.2, 3.8, 0.1, 1)
local nidx = A.shade(c, nm, nn, NUT, { amb = 0.1, wrap = 0.25, tok = nt })
c:put(12, 35, NUT[6], nt) c:put(11, 35, A.CREAM, nt)
c:put(13, 40, NUT[1], nt) c:put(14, 39, NUT[2], nt)
local cm = A.oval(13, 32, 3.8, 1.9, 0.1, 1)
local cidx = A.shade(c, cm, select(2, A.oval(13, 32, 3.8, 1.9, 0.1, 1)), CAP, { cuts = { 0.3, 0.55, 0.8 }, tok = nt })
cm:each(function(x, y) if (x + y) % 2 == 0 and (cidx[K(x, y)] or 1) > 1 then c:put(x, y, CAP[(cidx[K(x, y)] or 2) - 1], nt) end end)
A.touch(nm:copy():cut(cm), cm):each(function(x, y) A.step(c, nidx, NUT, x, y, -2, nt) end)
c:put(14, 29, CAP[2], nt) c:put(14, 30, CAP[2], nt)           -- stalk
-- forepaws wrapped round the acorn (in front of it)
for _, q in ipairs{ { 16, 34 }, { 16, 38 } } do
  local pm2, pn2 = A.oval(q[1], q[2], 2.2, 1.6, -0.3, 1)
  A.shade(c, pm2, pn2, FR, { amb = 0.12, tok = bt })
  c:put(q[1] - 2, q[2], FR[2], bt)
end
-- quirk: little oak leaf caught in the tail fur
A.map(c, { ".gG.", "gGGg", ".gdg", "..d." }, 50, 33,
  { g = OAK[3], G = OAK[4], d = OAK[2] }, tt)
A.save(c, "ico-squirrel")
