-- chili-pepper (final, Opus single pass). One slim glossy red chili lying on the diagonal: broad shoulder upper-right
-- under a lobed green calyx, tapering down-left to a fine point. Material: per-pixel cylinder light on a 6-tone red ramp
-- (violet deep), a long waxy specular streak + cream glint on the lit shoulder, a shallow lengthwise crease (dark groove,
-- lit lip), cool reflected light on the lower-right edge, AO where calyx meets flesh. Calyx: 6-tone lobes with dark
-- seams; stalk: bent 5-tone tube with a pale cut end.
-- quirk: the tip curls back into a tiny hook.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_1.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new("chili-pepper")
local RED  = { "#4a0f2a", "#7e1832", "#b2232f", "#da3a2c", "#f2633a", "#ff9a68" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STK  = { "#1d4434", "#2e6142", "#4a8048", "#73a456", "#a6c878" }
local SPEC, BOUNCE = "#fff1cf", "#9a4a7a"
local rtok, ltok, stok = { r = { name = "red" } }, { r = { name = "calyx" } }, { r = { name = "stalk" } }

-- body
local p = { { 42, 17 }, { 37, 30 }, { 30, 44 }, { 15, 50 } }
local function hw(t)
  if t < 0.06 then return 4.3 + t / 0.06 * 1.0 end
  return 5.3 * ((1 - t) / 0.94) ^ 0.95 + 0.4
end
local bm, bn, BT, BS, samp = G.tube(p, hw)
-- hook at the tip
local hm, hn = G.tube({ { 15.5, 50 }, { 12, 51.5 }, { 9.5, 49.5 }, { 11, 46.5 } }, function(t) return 0.95 - t * 0.35 end)
for k, v in pairs(hn) do if not bn[k] then bn[k] = v BT[k] = 1 BS[k] = 0 end end
bm:add(hm)
-- calyx mask (for AO)
local cal = HP.mask()
local lobes = { { 37.5, 17.5, 3.2, 2.2 }, { 41, 20.5, 3.0, 2.2 }, { 45.5, 19.5, 3.0, 2.0 }, { 42, 15.5, 4.2, 2.6 }, { 47, 16.5, 2.2, 1.8 } }
for _, l in ipairs(lobes) do cal:add(HP.ellipse(l[1], l[2], l[3], l[4])) end
local bias = {}
X.ao(bias, bm, cal, 2, -1)
local v = X.light(bn, { amb = 0.06, wrap = 0.22 })
local idx = X.tone(c, bm, v, RED, { cuts = A.CUTS, bias = bias, tok = rtok })
-- lengthwise crease along the shade half
bm:each(function(x, y) local k = K(x, y) local t, s = BT[k], BS[k]
  if t and t > 0.12 and t < 0.72 then
    if abs(s - 0.28) < 0.11 then c:put(x, y, RED[max(1, (idx[k] or 3) - 2)], rtok)
    elseif s > 0.4 and s < 0.52 and (idx[k] or 0) >= 3 then c:put(x, y, RED[min(6, idx[k] + 1)], rtok) end
  end end)
-- cool reflected light
local rim = X.rim(bn)
bm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.62 and (BT[k] or 1) > 0.18 and (BT[k] or 1) < 0.85 and (BS[k] or 0) > 0.7 then c:put(x, y, BOUNCE, rtok) end end)
-- specular streak along the lit side + glint
for i = 0, 9 do
  local s = samp[floor((0.1 + i * 0.035) * 160) + 1]
  local w = -0.5 + i * 0.012
  c:put(floor(s.x + s.px * s.w * w + .5), floor(s.y + s.py * s.w * w + .5), i < 6 and RED[6] or RED[5], rtok)
end
do local s = samp[floor(0.14 * 160) + 1]
  local x, y = floor(s.x + s.px * s.w * -0.5 + .5), floor(s.y + s.py * s.w * -0.5 + .5)
  c:put(x, y, SPEC, rtok) c:put(x + 1, y - 1, SPEC, rtok) end
c:put(14, 48, RED[5], rtok)

-- stalk (painted before calyx so calyx sits over its base)
local sm, sn, ST = G.tube({ { 43, 16 }, { 44, 11 }, { 47, 8 }, { 51, 8 } }, function(t) return 1.5 - t * 0.35 end)
local sv = X.light(sn, { amb = 0.14, wrap = 0.3 })
local sidx = X.tone(c, sm, sv, STK, { cuts = { 0.25, 0.45, 0.65, 0.82 }, tok = stok })
sm:each(function(x, y) if ST[K(x, y)] > 0.93 then c:put(x, y, x + y < 60 and "#d8e6a0" or STK[4], stok) end end)

-- calyx: lobes, each pillow-lit, dark seams between
local cn = X.pillow(cal, 2.2)
local cb = {}
cal:each(function(x, y) if y >= 20 then cb[K(x, y)] = -1 end end)
local cidx = X.tone(c, cal, X.light(cn, { amb = 0.12, wrap = 0.28 }), LEAF, { cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, bias = cb, tok = ltok })
for _, q in ipairs{ { 39, 19 }, { 40, 19 }, { 43, 19 }, { 44, 18 }, { 45, 18 } } do c:put(q[1], q[2], LEAF[2], ltok) end
-- stalk socket over calyx top
c:put(42, 14, STK[1], stok) c:put(43, 14, STK[2], stok) c:put(43, 13, STK[3], stok) c:put(42, 13, STK[4], stok)
c:put(39, 15, LEAF[6], ltok) c:put(40, 15, LEAF[6], ltok)

A.save(c, "chili-pepper")
