-- red-hibiscus-seed (final D12_0, Sonnet high). Three small kidney-shaped dark brown downy seeds on a torn scrap of
-- hibiscus leaf (broad ovate blade, serrate margin, palmate veins fanning from the base, V-fold light, cool reflected
-- edge, ambient shade + contact shadow under each seed). The right seed has germinated: a red-flushed stem, two broad
-- notched seed leaves and a first toothed true leaf. quirk: a dew drop sits on the right seed leaf.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("red-hibiscus-seed")
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local VEIN, COOL = "#c6e28e", "#3a6c72"
local SEED = { "#241616", "#43291f", "#684532", "#8c6446", "#b08a62", "#d6bc92" }
local STEM = { "#6a2a3c", "#a24456", "#cf6a70", "#ee9a8c" }
local DEW = { "#2a6a7c", "#4fa3b4", "#a2e4e6", "#fff4d6" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

local seeds = { { 17, 46.5, 4.9, 3.1, 0.3 }, { 29, 48, 4.9, 3.1, -0.12 }, { 42.5, 43, 4.7, 3.0, 0.08 } }
for _, s in ipairs(seeds) do
  s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.85)
  -- kidney notch (hilum) on the lower side
  local ca, sa = cos(s[5]), sin(s[5])
  local hx, hy = s[1] - 0.2 * ca + 3.2 * sa, s[2] - 0.2 * sa - 3.2 * ca + 6.4 * ca * 0
  -- notch sits on the +perpendicular side (lower)
  local px, py = -sa, ca
  hx, hy = s[1] + px * 3.4, s[2] + py * 3.4
  s.hil = { floor(hx + 0.5), floor(hy + 0.5) }
  s.m:cut(c:ellipse(hx, hy, 1.2, 1.0))
end

-- ---------------------------------------------------------------- leaf scrap
local PER = 6.4
local lm, ln, LT, LS, len = A.blade(7, 50, 28, 53, 55, 40, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.97 + 0.04)
  return max(0.6, 10.2 * sin(pi * u ^ 0.85) ^ 0.75)
end, { fold = 0.36 })
A.teeth(lm, LT, LS, len, PER, 0.2, 0.14, 0.93)
-- torn base: jagged diagonal rip with a nibbled notch
local torn = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local zig = ((x * 7 + y * 3) % 5) * 0.012
  if t < 0.075 + zig + (s > 0 and 0.05 or 0) * (0.5 + s) then torn[#torn + 1] = k end
end)
for _, k in ipairs(torn) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- veins: midrib + two basal side veins fanning out + a few laterals
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s, t = LS[k], LT[k]
  if abs(s) < 0.13 and t > 0.03 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- palmate side veins (from the base up to ~0.5)
  if t > 0.08 and t < 0.6 and abs(abs(s) - 1.15 * (t - 0.07)) < 0.065 and abs(s) < 0.8 then
    c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) return
  end
  -- lateral veins toward each tooth
  local ph = (t * len - abs(s) * 3.6) / PER + (s > 0 and 0.5 or 0)
  local f = ph - floor(ph)
  if f > 0.92 and abs(s) > 0.2 and abs(s) < 0.75 and t > 0.1 and t < 0.9 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] and LS[k] > 0.6 and LT[k] > 0.12 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
-- torn edge: pale fibres on the rip
lm:each(function(x, y) local k = K(x, y)
  if LT[k] < 0.15 and not lm:copy():shrink(1):has(x, y) and (x + y) % 2 == 0 and not bias[k] then c:put(x, y, "#a8cc72", ltok) end end)

-- ---------------------------------------------------------------- sprout
local stok = { r = { name = "stem" } }
local sp = { { 42.5, 42 }, { 41, 37 }, { 44, 32 }, { 43, 26 } }
local sm, sn, ST = A.tube(sp, function(t) return 1.1 end)
sm:cut(seeds[3].m)
A.toneN(c, sm, sn, STEM, { tok = stok, amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
-- seed leaves (cotyledons): broad, a notch at the outer tip, midvein
local function cot(cx, cy, ang, rx, ry)
  local m, n = A.oval(cx, cy, rx, ry, ang, 0.9)
  local ca, sa = cos(ang), sin(ang)
  local tipx, tipy = cx + ca * rx * (ang < 0 and -1 or 1), cy + sa * rx * (ang < 0 and -1 or 1)
  m:cut(c:ellipse(tipx, tipy, 0.9, 0.9))
  m:cut(sm)
  local idx = A.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local dx, dy = x - cx, y - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if abs(v) < 0.55 and abs(u) < rx * 0.78 then c:put(x, y, v <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local cl = cot(36, 25.5, -0.28, 6.4, 3.9)
local cr = cot(50.5, 24, 0.3, 6.4, 3.9)
-- first true leaf: ovate with teeth, palmate veins, on a short petiole above the seed leaves
local tl, tn, TLT, TLS, tlen = A.blade(43, 25, 42, 18, 44, 9, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 4.6 * sin(pi * min(1, t * 0.96 + 0.06)) ^ 0.8)
end, { fold = 0.3 })
A.teeth(tl, TLT, TLS, tlen, 4.2, 0.22, 0.25, 0.92)
tl:cut(cl):cut(cr)
A.toneN(c, tl, tn, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
tl:each(function(x, y) local k = K(x, y) local s, t = TLS[k], TLT[k]
  if abs(s) < 0.2 and t > 0.05 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  if t > 0.2 and t < 0.65 and abs(abs(s) - 1.1 * (t - 0.18)) < 0.12 and abs(s) < 0.75 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
-- petiole joint: red knob where the stem meets the leaf stalks
c:px(43, 26, STEM[3]) c:px(42, 26, STEM[2]) c:px(43, 27, STEM[2]) c:px(44, 26, STEM[1])
-- dew drop on the right seed leaf (quirk)
c:fillMask(c:rect(51, 22, 53, 24), DEW[2])
c:px(51, 22, DEW[3]) c:px(52, 22, DEW[3]) c:px(51, 23, DEW[3]) c:px(53, 24, DEW[1]) c:px(52, 24, DEW[1]) c:px(53, 23, DEW[1])
c:px(51, 22, DEW[4])
-- tiny radicle poking from the sprouting seed over the leaf edge
local rm, rn = A.tube({ { 46, 45 }, { 48, 46 }, { 49, 48 }, { 51, 50 } }, function(t) return 1.3 - 0.9 * t end)
rm:cut(seeds[3].m)
A.toneN(c, rm, rn, { "#8a5a4a", "#b88a72", "#e0b8a0", "#f6dcc8" }, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not seeds[3].m:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- ---------------------------------------------------------------- seeds last
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = A.toneN(c, vis, s.n, SEED, { tok = tok, bias = sb, cuts = CUTS, amb = 0.1, wrap = 0.3 })
  vis:each(function(x, y) local k = K(x, y)
    local h = X.hash(x, y, 17 + i)
    if h < 0.1 and idx[k] and idx[k] >= 3 then c:put(x, y, SEED[idx[k] - 1], tok) end
    if h > 0.9 and idx[k] and idx[k] <= 5 then c:put(x, y, SEED[idx[k] + 1], tok) end
  end)
  -- downy halo: pale hairs on the rim, mostly upper-left / lower-right
  local ring = s.m:copy():grow(1):cut(s.m)
  ring:each(function(x, y)
    if lm:has(x, y) and X.hash(x, y, 41 + i) < 0.34 and not s.m:has(x, y) then
      local lit = (x + y) < (s[1] + s[2])
      local own = false
      for j = 1, #seeds do if j ~= i and seeds[j].m:has(x, y) then own = true end end
      if not own then c:put(x, y, lit and SEED[6] or SEED[3], tok) end
    end
  end)
  -- hilum fleck in the notch and one glint
  c:put(s.hil[1], s.hil[2], SEED[5], tok)
  local gx, gy = A.specAt(vis, s.n, 24)
  if gx then c:put(gx, gy, "#fff4d6", tok) c:put(gx + 1, gy, SEED[6], tok) end
end
A.save(c, "red-hibiscus-seed")
