-- ico-rope (Opus artist pass). A coil of hemp rope seen from above: two stacked loops (outer + inner turn, dark groove
-- between them, open eye in the middle) and a tail that leaves the coil lower-right, bound with a red whipping and
-- ending in a frayed tassel. Material: torus-lit 6-tone hemp, diagonal three-strand twist (dark groove + lit lip),
-- AO inside the eye and where the tail crosses over the coil, contact shadow under the tail.
-- quirk: the frayed end has splayed out into a little fluffy tassel with one stray fibre.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA9_0.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, max, min, sqrt, abs, atan = math.floor, math.max, math.min, math.sqrt, math.abs, math.atan
local c = D.new("ico-rope")
local R = D.ROPE
local cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }
local CX, CY, RX, RY = 29, 29, 20, 17
local QI, QM = 0.42, 0.71         -- inner eye edge, groove between the two turns
local tok = { r = { name = "rope" } }

local coil = HP.mask()
local n, PH, SV = {}, {}, {}
for y = CY - RY - 1, CY + RY + 1 do for x = CX - RX - 1, CX + RX + 1 do
  local u, w = (x - CX) / (RX + .5), (y - CY) / (RY + .5)
  local q = sqrt(u * u + w * w)
  if q <= 1 and q >= QI then
    coil:set(x, y)
    local a, b
    if q < QM then a, b = QI, QM else a, b = QM, 1 end
    local s = ((q - a) / (b - a)) * 2 - 1          -- -1 inner edge .. 1 outer edge of this turn
    s = max(-0.95, min(0.95, s))
    local th = atan(w, u)
    local dx, dy = math.cos(th), math.sin(th)
    local k = K(x, y)
    n[k] = { dx * s, dy * s, sqrt(1 - s * s) }
    local rad = (q < QM) and 0.56 or 0.86
    PH[k] = th * rad * (RX + RY) / 2 + s * 1.6 * (q < QM and 1 or -1)
    SV[k] = s
  end
end end
local v = X.light(n, { amb = 0.08, wrap = 0.3 })
local bias = {}
-- AO: inner turn near the eye sits in shadow on the upper-left inside (eye wall), groove between turns
coil:each(function(x, y) local k = K(x, y)
  local u, w = (x - CX) / (RX + .5), (y - CY) / (RY + .5)
  local q = sqrt(u * u + w * w)
  if abs(q - QM) < 0.03 then bias[k] = -3 end
end)
local idx = X.tone(c, coil, v, R, { cuts = cuts, bias = bias, tok = tok })
-- twist: diagonal strand grooves, lit lip after each
coil:each(function(x, y) local k = K(x, y)
  if (bias[k] or 0) == 0 then
    local ph = PH[k] % 4.2
    local i = idx[k]
    if ph < 0.9 then c:put(x, y, R[max(1, i - 2)], tok)
    elseif ph < 1.9 and i >= 3 then c:put(x, y, R[min(6, i + 1)], tok) end
  end
end)
-- eye: dark floor visible through the hole (shadowed inside wall)
local eye = HP.mask()
for y = CY - RY, CY + RY do for x = CX - RX, CX + RX do
  local u, w = (x - CX) / (RX + .5), (y - CY) / (RY + .5)
  if sqrt(u * u + w * w) < QI then eye:set(x, y) end
end end

-- tail: leaves the outer turn lower-right, crosses over, whipping, fray
local tp = { { 36, 40 }, { 46, 46 }, { 48, 50 }, { 52, 53 } }
local tm, tn, TT, TS, samp = G.tube(tp, function(t) return 2.6 - t * 0.3 end)
-- contact shadow under the tail onto the coil
local tb = {}
tm:shift(1, 2):each(function(x, y) if coil:has(x, y) and not tm:has(x, y) then D.set(c, x, y, R[max(1, D.find(R, c:get(x, y)) - 2)]) end end)
local tv = X.light(tn, { amb = 0.08, wrap = 0.3 })
local tid = X.tone(c, tm, tv, R, { cuts = cuts, tok = tok })
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i - 1].x)^2 + (samp[i].y - samp[i - 1].y)^2) end
tm:each(function(x, y) local k = K(x, y)
  local ph = (TT[k] * LEN + TS[k] * 1.8) % 4.2
  local i = tid[k]
  if TT[k] > 0.78 then
    -- red whipping band: thread wraps
    local wi = (floor(TT[k] * LEN) % 2 == 0) and i or i - 1
    c:put(x, y, D.RED[max(1, min(6, wi))], tok)
  elseif ph < 0.9 then c:put(x, y, R[max(1, i - 2)], tok)
  elseif ph < 1.9 and i >= 3 then c:put(x, y, R[min(6, i + 1)], tok) end
  if TT[k] < 0.06 then D.set(c, x, y, R[max(1, (tid[k] or 3) - 1)]) end
end)
-- quirk: frayed tassel splaying out past the whipping
local tokT = { r = { name = "fray" } }
local fr = {
  "..ab.a",
  ".abab.",
  "abbab.",
  "bab.a.",
  ".a.b..",
  "a.....",
}
local FC = { a = R[6], b = R[4] }
for yy, row in ipairs(fr) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if FC[ch] then c:put(52 + xx - 1, 52 + yy - 1, FC[ch], tokT) end end end
-- glint on the outer turn
c:put(16, 16, D.CREAM, tok) c:put(17, 15, R[6], tok)

D.save(c, "ico-rope")
