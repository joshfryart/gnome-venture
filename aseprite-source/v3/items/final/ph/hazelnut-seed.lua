-- hazelnut-seed (final, Opus aC11_3). Two hazelnuts on a torn scrap of hazel leaf. Leaf scrap: broad ovate blade with a
-- pointed tip and a ragged torn base, double-toothed margin, pale midrib and the straight parallel side veins of hazel,
-- V-fold light, cool reflected edge, AO + contact shadow under the nuts. Nuts: per-pixel egg light (6-tone chestnut),
-- fine darker stripes running tip to base, a pale rough basal scar, one bright specular each. The upright nut has split
-- at the tip: a pale stem rises into two round, toothed, pointed hazel seedling leaves (midrib + veins) and a bud.
-- quirk: a squirrel has nibbled a notch out of the lying nut, showing the cream kernel.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC11_3.lua")
local HP, X, K = A.HP, A.X, A.K
local max, min, floor, abs, sqrt, sin, cos, pi = math.max, math.min, math.floor, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = A.new("hazelnut-seed")
local LEAF = { "#1b3b33", "#285a3c", "#3b7a42", "#589b48", "#80b956", "#acd570" }
local VEIN, COOL = "#c6e488", "#3a6a6e"
local NUT  = { "#3a1f1c", "#5e3424", "#86502e", "#ad7240", "#d09a58", "#efc88c" }
local SCAR = { "#8a7660", "#b8a486", "#dccaa6" }
local KERN = { "#c8a878", "#f0dcb0", "#fff4d6" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local SPEC = "#fff2d8"
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local ltok = A.tok("leaf")

-- nut: egg with a soft point; (cx,cy), radius r, angle of the tip direction
local function mknut(cx, cy, r, ang)
  local ca, sa = cos(ang), sin(ang)
  local m, n, U, V = HP.mask(), {}, {}, {}
  for y = floor(cy - r - 3), floor(cy + r + 3) do for x = floor(cx - r - 3), floor(cx + r + 3) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u = (dx * ca + dy * sa) / (r + .3)
    local v = (-dx * sa + dy * ca) / (r + .1)
    local lim = 1 - max(u, 0)^1.6 * 0.45          -- narrower toward the tip
    if u < 1.12 and v * v <= (1 - min(u, 1)^2) * lim * lim + (u > 0.95 and 0.02 or 0) then
      m:set(x, y)
      local k = K(x, y)
      local q = max(0.02, 1 - u * u - v * v)
      local nx, ny, nz = dx / (r + .5), dy / (r + .5), sqrt(q)
      local l = sqrt(nx * nx + ny * ny + nz * nz)
      n[k] = { nx / l, ny / l, nz / l } U[k], V[k] = u, v
    end
  end end
  return { m = m, n = n, U = U, V = V, cx = cx, cy = cy, r = r }
end
local nutA = mknut(21, 45, 5.4, pi * 1.08)   -- lying, tip to the left
local nutB = mknut(35, 41, 5.6, -pi / 2 - 0.15) -- upright, tip up (split, sprouting)

-- leaf scrap: hazel blade on the diagonal, torn base at lower-left
local lm, ln, LT, LS, len = A.blade(8, 56, 30, 54, 57, 36, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 10.2 * sin(pi * (0.22 + 0.78 * t)) ^ 0.75)
end, { fold = 0.35 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local p = t * len
  -- double teeth: small every 2.2 px, bigger every 6.6 px
  local f1, f2 = (p / 2.2) % 1, (p / 6.6) % 1
  if t > 0.12 and t < 0.96 and ((abs(s) > 0.9 and f1 < 0.45) or (abs(s) > 0.8 and f2 < 0.22)) then cut[#cut + 1] = k end
  -- torn base: ragged edge
  local tear = 1.6 + 2.2 * abs(sin(s * 5.3)) + X.hash(floor(s * 6), 1, 2) * 1.5
  if p < tear then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, nt in ipairs{ nutA, nutB } do X.ao(bias, lm, nt.m, 1, -1) A.cast(bias, lm, nt.m, 1, 2, -1) end
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- straight parallel side veins swept toward the tip (hazel)
  local ph = (t * len - abs(s) * 6.5) / 5.2
  local f = ph % 1
  if f < 0.16 and abs(s) > 0.16 and abs(s) < 0.82 and t > 0.06 and t < 0.88 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.12 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)
-- torn fibres: pale broken vein ends at the tear
for _, p in ipairs{ { 10, 54 }, { 9, 52 } } do if lm:has(p[1], p[2]) then c:put(p[1], p[2], VEIN, ltok) end end

-- sprout: stem from nutB tip, two seedling leaves, bud
local stok = A.tok("stem")
local sm, sn = A.tube({ { 36, 37 }, { 35, 31 }, { 37, 26 }, { 36, 19 } }, function(t) return 1.0 end)
sm:cut(nutB.m)
A.shade(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3, tok = stok })
local function seedling(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, L = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, w * sin(pi * min(1, 0.12 + t * 0.95)) ^ 0.55)
  end, { fold = 0.3 })
  local cc = {}
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) > 0.82 and T[k] > 0.15 and T[k] < 0.9 and ((T[k] * L) / 2.1) % 1 < 0.42 then cc[#cc + 1] = k end end)
  for _, k in ipairs(cc) do m.s[k] = nil end
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.15 and T[k] > 0.08 and T[k] < 0.88 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok)
    else
      local f = ((T[k] * L - abs(S[k]) * w * 0.9) / 3.0) % 1
      if f < 0.25 and abs(S[k]) > 0.2 and abs(S[k]) < 0.75 and T[k] < 0.8 then c:put(x, y, S[k] < 0 and LEAF[5] or LEAF[2], ltok) end
    end
  end)
  return m
end
local la = seedling(35, 25, 28, 22, 20, 15, 5.0)
local lb = seedling(37, 22, 45, 20, 52, 12, 4.6)
-- bud at the stem top
A.map(c, { ".a.", "abc", ".bc" }, 35, 16, { a = LEAF[6], b = LEAF[4], c = LEAF[2] }, ltok)

-- nuts last (B behind A? they do not overlap); stripes, scar, specular
local function paintNut(nt, tok, split)
  local b = {}
  nt.m:each(function(x, y) local k = K(x, y)
    local u, v = nt.U[k], nt.V[k]
    if u > -0.55 and u < 0.85 and ((v * 3.2 + u * 0.4) % 1) < 0.2 then b[k] = -1 end
  end)
  local idx = A.shade(c, nt.m, nt.n, NUT, { amb = 0.08, wrap = 0.25, bias = b, tok = tok })
  -- basal scar: pale rough patch at the wide end
  nt.m:each(function(x, y) local k = K(x, y)
    if nt.U[k] < -0.62 then
      local i = (idx[k] or 3) >= 4 and 3 or 2
      if X.hash(x, y, 9) > 0.7 then i = i - 1 end
      c:put(x, y, SCAR[max(1, i)], tok)
    end
  end)
  -- specular
  local sx, sy = A.specAt(nt.m, nt.n, 30)
  c:put(sx, sy, SPEC, tok)
  if nt.m:has(sx + 1, sy) then c:put(sx + 1, sy, NUT[6], tok) end
end
paintNut(nutB, A.tok("nutB"))
-- split tip of nutB around the stem
c:put(35, 36, NUT[1], stok) c:put(37, 36, NUT[2], stok) c:put(36, 36, STEM[2], stok)
paintNut(nutA, A.tok("nutA"))
-- quirk: nibbled notch in the lying nut (top edge), kernel showing
local notch = c:ellipse(22, 39.5, 1.8, 1.4)
local inNotch = HP.mask()
notch:each(function(x, y) if nutA.m:has(x, y) then inNotch:set(x, y) end end)
inNotch:each(function(x, y) c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil if lm:has(x, y) then c:put(x, y, LEAF[2], ltok) end end)
nutA.m:cut(inNotch)
inNotch:grow(1):each(function(x, y)
  if nutA.m:has(x, y) then c:put(x, y, (x < 22) and KERN[3] or KERN[2], A.tok("kernel")) end end)
for x = 20, 24 do if nutA.m:has(x, 42) and inNotch:grow(2):has(x, 42) then c:put(x, 42, KERN[1], A.tok("kernel")) end end

A.save(c, "hazelnut-seed")
