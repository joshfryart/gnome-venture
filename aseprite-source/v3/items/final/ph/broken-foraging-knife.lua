-- broken-foraging-knife (aB11_2, Opus single pass). Mushroom knife on the diagonal: hooked steel blade, brass bolster,
-- slim walnut handle with grain and two brass pins, a brass ferrule and a short bristle brush at the butt.
-- Material: tube light on steel with a honed bevel and specular streak, grain on wood, twist-like alternating bristles.
-- broken: the hooked tip has snapped off and tumbles away with a shard; a crack runs into the handle from the bolster.
-- quirk: a tuft of green moss is still caught in the brush.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_2.lua")
local HP, X, K = H.HP, H.X, H.K
local S, W, B = H.STEEL, H.WOOD, H.BRASS
local floor = math.floor
local c = H.new("broken-foraging-knife")
local wtok, stok = { r = { name = "wood" } }, { r = { name = "steel" } }

-- brush bristles fanning lower-left from the ferrule
local BR = { "#5a3a28", "#8a6038", "#c49a5c", "#e6c88a" }
for i = -2, 2 do
  local ax, ay = 12, 53
  local dx, dy = -0.72 + i * 0.16, 0.72 + i * 0.16
  for s = 1, 6 do
    local x, y = floor(ax + dx * s + 0.5), floor(ay + dy * s + 0.5)
    local col = BR[((s + i) % 2 == 0) and 3 or 2]
    if s == 6 then col = BR[4] end
    if i == 2 then col = BR[1] end
    c:put(x, y, col)
  end
end
-- moss tuft (quirk)
local MO = H.MOSS
for _, p in ipairs{ { 7, 57, 3 }, { 8, 57, 4 }, { 7, 58, 2 }, { 8, 56, 5 }, { 6, 58, 3 }, { 9, 58, 1 } } do c:put(p[1], p[2], MO[p[3]]) end

-- ferrule
local fm, fn = X.cyl(11, 54, 15, 50, function() return 2.0 end)
H.shade(c, fm, fn, B, { spec = 20, specThr = 0.85 })
-- handle
local hp = { { 15, 50 }, { 19, 46 }, { 23, 42 }, { 28, 37 } }
local hm, hn, hT, hS = H.tube(hp, function(t) return 2.1 + 0.4 * math.sin(t * 3.1) end)
local hb = X.ao({}, hm, fm, 1, -1)
local hidx = H.shade(c, hm, hn, W, { tok = wtok, bias = hb, spec = 26, specThr = 0.92 })
H.grain(c, hm, hT, hS, hidx, W, 18, wtok, 5)
-- brass pins
for _, p in ipairs{ { 19, 46 }, { 25, 40 } } do c:put(p[1], p[2], B[5]) c:put(p[1] + 1, p[2] + 1, B[2]) end
-- crack into the handle from the bolster
for _, p in ipairs{ { 27, 39 }, { 26, 40 }, { 26, 41 }, { 25, 42 } } do c:put(p[1], p[2], W[1], wtok) end

-- bolster
local bm, bn = X.cyl(27, 38, 31, 34, function() return 2.8 end)
H.shade(c, bm, bn, B, { spec = 20, specThr = 0.82, specCol = B[6] })

-- hooked blade, snapped at t 0.66
local bp = { { 31, 34 }, { 38, 27 }, { 46, 19 }, { 52, 22 } }
local function bw(t) return 2.9 * (1 - t) + 0.6 end
local m, n, T, Sx = H.tube(bp, bw, 0, 0.66)
local bb = X.ao({}, m, bm, 1, -1)
H.shade(c, m, n, S, { tok = stok, bias = bb, spec = 14, specThr = 0.9, specCol = H.SPEC, bounce = "#6a78b0" })
-- honed bevel: bright line along the lower-right cutting edge, dark fuller line along the spine
m:edge():each(function(x, y) local k = K(x, y) if Sx[k] > 0.45 and T[k] > 0.08 then c:put(x, y, S[5], stok) end end)
m:each(function(x, y) local k = K(x, y) if T[k] > 0.08 and T[k] < 0.55 and Sx[k] > -0.45 and Sx[k] < -0.2 then c:put(x, y, S[3], stok) end end)
-- jagged break
do local ex, ey = H.bez(bp, 0.66)
  H.erase(c, HP.mask():set(floor(ex + 0.5), floor(ey + 1.5)))
  c:put(floor(ex - 0.5), floor(ey + 0.5), S[1], stok) end
-- flying hooked tip, rotated
local tp = { { 49, 25 }, { 52, 23 }, { 55, 25 }, { 56, 29 } }
local tm, tn = H.tube(tp, function(t) return 1.5 * (1 - t) + 0.5 end)
H.shade(c, tm, tn, S, { tok = stok, spec = 14, specThr = 0.88, specCol = H.SPEC })
c:put(49, 25, S[2], stok)
c:put(46, 29, S[5], stok) c:put(47, 30, S[3], stok)
H.fin(c, debug.getinfo(1, "S").source)
