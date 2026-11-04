-- bitter-melon (final, Opus aR20_2). A slim bitter gourd on the diagonal: pointed blossom end lower left, stem end
-- upper right. Per-pixel cylinder light; five long ridges across the body (dark grooves between) studded with
-- rows of lit warts that each cast a 1 px shadow; cool reflected light on the shade side, one wet specular,
-- AO ring at the calyx, woody fibrous stem with a 5-point calyx.
-- quirk: the blossom tip is turning ripe orange and has split, showing one scarlet seed.
local NAME = "bitter-melon"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = A.new(NAME)
local GR = { "#14352a", "#1d5233", "#2b723a", "#4a9440", "#78b84c", "#b2dc6e" }
local OR = { "#6a2a24", "#a8452a", "#dc7330", "#f39a3a", "#ffc25a", "#ffe49a" }
local COOL, SEED = "#3f7a76", "#e0303f"
local STEM = { "#2e3a1e", "#4c5a26", "#6f7a34", "#97a04a", "#c2c672" }

-- body
local pts = { { 10, 53 }, { 15, 37 }, { 33, 22 }, { 49, 14 } }
local bm, bn, BT, BS = A.tube(pts, function(t)
  if t < 0.03 then return 0.6 end
  local w = 5.4 * sin(pi * min(1, (t ^ 0.8) * 0.82 + 0.02)) ^ 0.55
  if t > 0.84 then w = w * (1 - (t - 0.84) * 2.2) end
  return max(t > 0.5 and 2.4 or 0.8, w + 0.2)
end)
local bias = {}
local tok = { r = { name = "melon" } }
-- ridges: 4 long ridges across; each has a lit upper-left facet and a dark groove; warts on the crests
bm:each(function(x, y) local k = K(x, y)
  local s, t = BS[k], BT[k]
  local q = (s + 1) * 2
  local f, ri = q - floor(q), floor(q)
  if f < 0.16 or f > 0.9 then bias[k] = -1 elseif f < 0.42 then bias[k] = 1 end
  local L = t * 64
  local ph = L / 3.4 + ri * 0.5
  if f > 0.4 and f < 0.68 and abs((ph - floor(ph)) - 0.5) > 0.38 and X.hash(floor(ph), ri, 7) > 0.2 then bias[k] = 2 end
end)
-- wart shadows: pixel down-right of a wart that is not itself a wart
local ws = {}
for k, v in pairs(bias) do if v == 2 then local x, y = k % 1024 - 256, k // 1024 - 256
  local q = K(x + 1, y + 1) if bm:has(x + 1, y + 1) and bias[q] ~= 2 then ws[#ws + 1] = q end end end
for _, q in ipairs(ws) do bias[q] = -2 end
local v = X.light(bn, { amb = 0.06, wrap = 0.3 })
local idx = X.tone(c, bm, v, GR, { cuts = A.CUTS, bias = bias, tok = tok })
-- cool reflected light on the shade-side rim
local rim = X.rim(bn)
bm:edge():each(function(x, y) local k = K(x, y) if BS[k] > 0.7 and rim[k] > 0.55 and BT[k] > 0.15 and BT[k] < 0.85 then c:put(x, y, COOL, tok) end end)
-- ripening blossom end (quirk) in orange, re-lit with the same normals
local om = HP.mask()
bm:each(function(x, y) local k = K(x, y) if BT[k] < 0.16 + 0.03 * BS[k] then om:set(x, y) end end)
local ob = {} om:each(function(x, y) local k = K(x, y) ob[k] = min(1, bias[k] or 0) end)
X.tone(c, om, v, OR, { cuts = A.CUTS, bias = ob, tok = tok })
-- split: a dark slit with one scarlet seed peeking out
local sx, sy = A.bez(pts, 0.08)
sx, sy = floor(sx + .5), floor(sy + .5)
c:put(sx, sy, OR[1], tok) c:put(sx + 1, sy - 1, OR[1], tok)
c:put(sx + 1, sy, SEED, tok) c:put(sx + 2, sy - 1, OR[2], tok) c:put(sx, sy + 1, OR[2], tok)
c:put(sx + 1, sy + 1, "#8e1c30", tok)
-- specular on the lit flank
local spx, spy = A.bez(pts, 0.52)
local qx, qy = floor(spx - 3 + .5), floor(spy - 2.4 + .5)
for _, d in ipairs{ { 0, 0 }, { 1, -1 } } do if bm:has(qx + d[1], qy + d[2]) then c:put(qx + d[1], qy + d[2], A.CREAM, tok) end end
if bm:has(qx + 2, qy - 2) then c:put(qx + 2, qy - 2, GR[6], tok) end

-- calyx + stem at the top end
local ex, ey = A.bez(pts, 0.97)
local cm = HP.mask()
for i = 0, 4 do local a = -0.5 + i * 2 * pi / 5
  cm:add(A.rell(ex + cos(a) * 2.4, ey + sin(a) * 2.4, cos(a), sin(a), 2.4, 1.0)) end
cm:add(c:ellipse(ex, ey, 1, 1))
X.ao(bias, bm, cm, 1, -1)
-- AO on the melon around the calyx
cm:grow(1):cut(cm):each(function(x, y) local k = K(x, y) if bm:has(x, y) then c:put(x, y, GR[max(1, (idx[k] or 3) - 1)], tok) end end)
local ctok = { r = { name = "calyx" } }
A.tone(c, cm, X.pillow(cm, 1.4), { GR[1], GR[1], GR[2], GR[3], GR[4], GR[5] }, { amb = 0.1, wrap = 0.3, tok = ctok })
local sp = { { ex, ey }, { ex + 2, ey - 3 }, { ex + 3, ey - 6 }, { ex + 6, ey - 8 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return 1.25 - t * 0.35 end)
sm:cut(cm)
local stok = { r = { name = "stem" } }
local sidx = A.tone(c, sm, sn, STEM, { amb = 0.1, wrap = 0.3, cuts = { 0.25, 0.45, 0.65, 0.82 }, tok = stok })
-- fibrous stem: a dark grain line down the middle, pale cut end
sm:each(function(x, y) local k = K(x, y) if abs(SS[k]) < 0.2 and ST[k] > 0.2 and ST[k] < 0.85 then c:put(x, y, STEM[2], stok) end end)
sm:each(function(x, y) local k = K(x, y) if ST[k] > 0.9 then c:put(x, y, STEM[5], stok) end end)

A.fin(c, NAME)
