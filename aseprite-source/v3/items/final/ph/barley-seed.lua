-- barley-seed (ph, round 3, artist 4). Three hulled barley grains (pointed spindles, gold hull with
-- lengthwise nerves, ventral crease, awn stub) on a torn scrap of blue-green barley leaf (ragged torn ends,
-- parallel veins, V-fold light, cool reflected edge, AO + contact shadow under each grain). The right grain
-- has germinated: white seminal rootlets splay over the scrap, a pale coleoptile, then a slim grass blade
-- (barley leaf shape) curling up-left and a short second blade.
-- quirk: a single dewdrop bead sitting on the sprout blade.
local NAME = "barley-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new(NAME)

local LEAF = { "#183a38", "#22543f", "#2f7048", "#468e50", "#6cae5e", "#a2cc80" }
local YOUNG = { "#1f5236", "#2e7040", "#46924a", "#68b456", "#98d26c", "#cfee9a" }
local GRAIN = { "#5a361e", "#86562a", "#b48038", "#d6a64e", "#eec776", "#fbe6aa" }
local VEIN, COOL = "#bfe0a0", "#3a6a74"
local ROOT = { "#b8a88a", "#e4d8bc", "#f8f0dc" }
local COLE = { "#6a8a5a", "#a8c48a", "#dcecbc" }

-- grain shape: pointed spindle (lemon), normals from a height field
local function grain(cx, cy, rx, ry, ang)
  local ca, sa = cos(ang), sin(ang)
  local m, n, U, V = HP.mask(), {}, {}, {}
  local R = floor(max(rx, ry)) + 2
  local function hw(u) return ry * max(0, 1 - u * u) ^ 0.62 end
  for y = floor(cy) - R, floor(cy) + R do for x = floor(cx) - R, floor(cx) + R do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (rx + 0.4)
    local w = -dx * sa + dy * ca
    local h = hw(u) + 0.35
    if abs(u) <= 1 and abs(w) <= h then
      m:set(x, y)
      local v = w / h
      local k = K(x, y)
      -- normal: across (v) + along taper (u)
      local nx_, ny_ = -sa * v * 0.95, ca * v * 0.95
      nx_, ny_ = nx_ + ca * u * 0.55, ny_ + sa * u * 0.55
      local nz = sqrt(max(0.05, 1 - v * v * 0.8 - u * u * 0.25))
      local l = sqrt(nx_ * nx_ + ny_ * ny_ + nz * nz)
      n[k] = { nx_ / l, ny_ / l, nz / l }
      U[k], V[k] = u, v
    end
  end end
  return m, n, U, V
end
local gs = {
  { 17, 50, 5.2, 2.5, -0.12 },
  { 28.5, 48.5, 5.0, 2.4, 0.32 },
  { 41, 44, 4.8, 2.3, -1.05 },   -- germinating, more upright
}
for _, s in ipairs(gs) do s.m, s.n, s.U, s.V = grain(s[1], s[2], s[3], s[4], s[5]) end

-- leaf scrap: broad grass blade fragment on a shallow diagonal with ragged torn ends
local lm, ln, LT, LS, len = G.blade(8, 53, 30, 53, 56, 42, function(t) return 5.6 - t * 1.4 + 0.5 * sin(t * 9) end, { fold = 0.4 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local d0 = t * len
  local d1 = (1 - t) * len
  local j0 = 1.2 + 2.4 * X.hash(floor(s * 6 + 9), 3, 5) + s * 1.5
  local j1 = 1.0 + 2.8 * X.hash(floor(s * 5 + 9), 7, 11) - s * 2.0
  if d0 < j0 or d1 < j1 then cut[#cut + 1] = k end
  -- a small tear notch in the lower edge
  if abs(t - 0.55) < 0.025 and s > 0.62 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(gs) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = G.tok("leaf")
local lidx = G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.13, 0.28, 0.44, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 then c:put(x, y, VEIN, ltok) return end
  -- parallel veins (grass): thin lines along the blade
  for _, vs in ipairs{ -0.62, -0.32, 0.36, 0.66 } do
    if abs(s - vs) < 0.07 and (x % 4 ~= 0) then c:put(x, y, s < 0 and LEAF[min(6, lidx[k] + 1)] or LEAF[max(1, lidx[k] - 1)], ltok) end
  end
end)
-- cool bounce on the lower edge; pale fibre ends on the torn edges
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LS[k] > 0.7 and LT[k] > 0.1 and LT[k] < 0.9 then c:put(x, y, COOL, ltok)
  elseif (LT[k] < 0.1 or LT[k] > 0.9) and (x + y) % 2 == 0 then c:put(x, y, LEAF[6], ltok) end end)

-- rootlets from the germinating grain's base, splayed over the scrap
local g3 = gs[3]
local ca3, sa3 = cos(g3[5]), sin(g3[5])
local bx3, by3 = g3[1] + ca3 * (g3[3] + 0.3), g3[2] + sa3 * (g3[3] + 0.3)      -- lower end (ang -1.05 => +u points up-right... pick the lower one)
local tx3, ty3 = g3[1] - ca3 * (g3[3] + 0.3), g3[2] - sa3 * (g3[3] + 0.3)
if by3 < ty3 then bx3, by3, tx3, ty3 = tx3, ty3, bx3, by3 end
local rtok = G.tok("root")
for i, r in ipairs{ { -5, 6 }, { 1, 7 }, { 6, 5 } } do
  local p = { { bx3, by3 }, { bx3 + r[1] * 0.2, by3 + r[2] * 0.5 }, { bx3 + r[1] * 0.7, by3 + r[2] * 0.8 }, { bx3 + r[1], by3 + r[2] } }
  for _, q in ipairs(G.bezPix(p, 40)) do if not g3.m:has(q[1], q[2]) then
    c:put(q[1], q[2], q[3] < 0.5 and ROOT[3] or ROOT[2], rtok)
    if lm:has(q[1] + 1, q[2] + 1) and not g3.m:has(q[1] + 1, q[2] + 1) then c:put(q[1] + 1, q[2] + 1, LEAF[1], ltok) end   -- contact shadow
  end end
end
-- re-lay roots over their own shadows
for i, r in ipairs{ { -5, 6 }, { 1, 7 }, { 6, 5 } } do
  local p = { { bx3, by3 }, { bx3 + r[1] * 0.2, by3 + r[2] * 0.5 }, { bx3 + r[1] * 0.7, by3 + r[2] * 0.8 }, { bx3 + r[1], by3 + r[2] } }
  for _, q in ipairs(G.bezPix(p, 40)) do if not g3.m:has(q[1], q[2]) then c:put(q[1], q[2], q[3] < 0.5 and ROOT[3] or ROOT[2], rtok) end end
end

-- coleoptile: pale sheath from the grain's top end
local ctok = G.tok("cole")
local cp = { { tx3, ty3 + 1 }, { tx3 - 0.5, ty3 - 2 }, { tx3 - 0.5, ty3 - 4 }, { tx3 - 1, ty3 - 7 } }
local cm, cn, CT, CS = G.tube(cp, function(t) return 1.25 - t * 0.2 end)
cm:cut(g3.m)
X.tone(c, cm, X.light(cn, { amb = 0.2, wrap = 0.3 }), COLE, { cuts = { 0.35, 0.7 }, tok = ctok })
local cx1, cy1 = tx3 - 1, ty3 - 7

-- sprout blades: long one curls up-left, short one right
local stok = G.tok("sprout")
local b1, b1n, B1T, B1S = G.blade(cx1, cy1, cx1 + 1, cy1 - 16, cx1 - 12, cy1 - 26, function(t)
  if t > 0.985 then return -1 end return max(0.45, 1.9 * (1 - t) ^ 0.55 * min(1, 0.55 + t * 4)) end, { fold = 0.3 })
local b2, b2n, B2T, B2S = G.blade(cx1 + 1, cy1 + 1, cx1 + 5, cy1 - 5, cx1 + 9, cy1 - 12, function(t)
  if t > 0.98 then return -1 end return max(0.45, 1.4 * (1 - t) ^ 0.6 * min(1, 0.6 + t * 4)) end, { fold = 0.3 })
b2:cut(b1)
local bb = {}
X.ao(bb, b2, b1, 1, -1)
local i2 = G.toneN(c, b2, b2n, YOUNG, { tok = stok, bias = bb, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
local i1 = G.toneN(c, b1, b1n, YOUNG, { tok = G.tok("sprout1"), cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
b1:each(function(x, y) local k = K(x, y) if abs(B1S[k]) < 0.15 and B1T[k] > 0.08 and B1T[k] < 0.85 then c:put(x, y, B1S[k] <= 0 and YOUNG[6] or YOUNG[3], stok) end end)
b2:each(function(x, y) local k = K(x, y) if abs(B2S[k]) < 0.15 and B2T[k] > 0.1 and B2T[k] < 0.8 and not bb[k] then c:put(x, y, YOUNG[5], stok) end end)
-- AO where the blades leave the coleoptile
cm:grow(1):cut(cm):each(function(x, y) if b1:has(x, y) or b2:has(x, y) then c:put(x, y, YOUNG[1], stok) end end)

-- grains last: gold hull, lengthwise nerves, crease, awn stub; AO between neighbours
for i, s in ipairs(gs) do
  local tok = G.tok("g" .. i)
  local gb = {}
  local idx = X.tone(c, s.m, X.light(s.n, { amb = 0.04, wrap = 0.12 }), GRAIN, { cuts = { 0.22, 0.4, 0.56, 0.7, 0.86 }, bias = gb, tok = tok })
  s.m:each(function(x, y) local k = K(x, y) local u, v = s.U[k], s.V[k]
    if abs(v - 0.05) < 0.16 and abs(u) < 0.62 then c:put(x, y, GRAIN[max(1, idx[k] - 2)], tok)        -- crease
    elseif abs(v + 0.55) < 0.12 and abs(u) < 0.5 then c:put(x, y, GRAIN[min(6, idx[k] + 1)], tok) end -- lit nerve
    if abs(u) > 0.86 then c:put(x, y, GRAIN[max(1, idx[k] - 1)], tok) end                              -- darker pointed tips
  end)
  local gx, gy = G.specAt(s.m, s.n, 40)
  c:put(gx, gy, i == 2 and "#fff4d6" or GRAIN[6], tok)
end
-- awn stub off grain 1's left tip
do local s = gs[1] local ca, sa = cos(s[5]), sin(s[5])
  local x0, y0 = s[1] - ca * (s[3] + 1), s[2] - sa * (s[3] + 1)
  for i = 0, 3 do c:put(floor(x0 - ca * i + .5), floor(y0 - sa * i - i * 0.35 + .5), GRAIN[i < 2 and 4 or 5], G.tok("g1")) end end

-- quirk: dewdrop bead on the long sprout blade (bright rim, pale core, dark lower right, glint)
do local k0, kx, ky = nil, 0, 0
  b1:each(function(x, y) local k = K(x, y) if abs(B1T[k] - 0.42) < 0.02 and B1S[k] > 0.3 then kx, ky = x, y end end)
  local dtok = G.tok("dew")
  local d = { { 0, -1, "#b6f0e0" }, { 1, -1, "#b6f0e0" }, { -1, 0, "#e8fffa" }, { 0, 0, "#8ee0d8" }, { 1, 0, "#9ce6dc" }, { 2, 0, "#5fc4c8" },
              { -1, 1, "#8ee0d8" }, { 0, 1, "#d8faf2" }, { 1, 1, "#c8f4ec" }, { 2, 1, "#3a86b0" }, { 0, 2, "#3a86b0" }, { 1, 2, "#2f6e98" } }
  for _, q in ipairs(d) do c:put(kx + q[1], ky + q[2], q[3], dtok) end
  c:put(kx - 1, ky, "#fff4d6", dtok)
end

G.done(c, NAME)
