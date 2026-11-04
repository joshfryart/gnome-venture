-- cornflower-seed (ph, Opus single pass): three ivory cornflower achenes (slim barrels, fine lengthwise stripe, a dark
-- notched hilum at the foot, a short fanned brush of tan pappus bristles at the head) on a torn scrap of narrow,
-- grey-green woolly cornflower leaf (midrib, faint laterals, pale hairs on the lit edge, ragged torn end).
-- The right seed has sprouted: slim stem, two spoon cotyledons and a first lance-shaped grey-green true leaf.
-- quirk: the seedling is far too eager - it already wears one tiny frilled cornflower-blue floret.
local NAME = "cornflower-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB22_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = G.new(NAME)
local LEAF = { "#22383a", "#30544c", "#44735c", "#62946c", "#8cb682", "#bcd8a6" }
local HAIR, COOL = "#dcebc6", "#3e6470"
local SEED = { "#4a3832", "#7a6454", "#a8927c", "#cdbda2", "#e8dcc0", "#fbf3dc" }
local PAP = { "#9c7a4c", "#c9a874", "#ecd8a8" }
local STEM = { "#3f6a52", "#6f9a72", "#a6c69a", "#d6e8c0" }
local BLUE = { "#1f2a6e", "#2f44a8", "#3f66d8", "#5f8cf0", "#9cbcff", "#d6e4ff" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- leaf scrap: narrow lance, torn at the lower-left end
local lm, ln, LT, LS, len = G.blade(8, 52, 30, 52, 55, 41, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 6.2 * sin(pi * min(1, 0.42 + t * 0.6)) ^ 0.8)
end, { fold = 0.4 })
-- ragged tear across the base
lm:each(function(x, y) local k = K(x, y)
  local jag = 0.05 + 0.05 * X.hash(floor(LS[k] * 6), 1, 4) + 0.02 * ((y % 2))
  if LT[k] < jag then lm.s[k] = nil end end)

local seeds = {
  { 17, 47.5, 3.9, 1.8, -0.35, tuft = 1 },
  { 28, 45.5, 3.8, 1.8, 0.5, tuft = -1 },
  { 42, 42, 3.7, 1.9, -1.25, tuft = 1 },
}
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.8 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.1 and t < 0.93 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5) / 6.5
  if abs(ph - floor(ph + 0.5)) < 0.07 and abs(s) > 0.2 and abs(s) < 0.75 and t > 0.12 and t < 0.85 then
    c:put(x, y, s < 0 and LEAF[5] or LEAF[3], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LS[k] > 0.6 and LT[k] > 0.15 and LT[k] < 0.9 then c:put(x, y, COOL, ltok)
  elseif LS[k] < -0.6 and X.hash(x, y, 9) < 0.35 then c:put(x, y, HAIR, ltok) end
  if LT[k] < 0.13 then c:put(x, y, LEAF[2], ltok) end   -- torn edge reads darker, slightly bruised
end)

-- sprout (behind the seed coat)
local stok = { r = { name = "stem" } }
local sp = { { 42, 40 }, { 41, 33 }, { 40, 27 }, { 40, 21 } }
local sm, sn = G.tube(sp, function(t) return 1.05 end)
for _, s in ipairs(seeds) do sm:cut(s.m) end
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function blade(ax, ay, cx, cy, bx, by, w, pw)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.88 + 0.1)) ^ (pw or 0.6))
  end, { fold = 0.32 })
  m:cut(sm)
  G.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.16, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.86 then
    c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
-- spoon cotyledons (rounder near the tip)
local cl = blade(39, 29, 34, 28, 29, 25, 2.5, 0.35)
local cr = blade(41, 29, 46, 28, 51, 26, 2.5, 0.35)
-- first true leaf: narrow lance, swept up-left
local tl = blade(40, 22, 38, 16, 34, 9, 2.4, 0.7)
tl:edge():each(function(x, y) if X.hash(x, y, 2) < 0.25 and x < 37 then c:put(x, y, HAIR, ltok) end end)

-- quirk: tiny floret on a pedicel curving right
local pt = { { 40, 22 }, { 42, 19 }, { 44, 17 }, { 45, 15 } }
for i = 0, 20 do local x, y = G.bez(pt, i / 20) c:put(floor(x + .5), floor(y + .5), i < 10 and STEM[2] or STEM[3], stok) end
-- involucre: small scaly cup (green-bronze) under the blue fan
local cup = c:ellipse(45, 14, 1.6, 1.2)
cup:each(function(x, y) c:put(x, y, (x + y) % 2 == 0 and LEAF[3] or LEAF[2], stok) end)
c:put(44, 13, LEAF[5], stok)
-- blue fan of funnel florets, toothed rim
local ftok = { r = { name = "floret" } }
local fan = HP.mask()
for _, a in ipairs{ -1.15, -0.55, 0.0, 0.55, 1.15 } do
  local ux, uy = sin(a), -cos(a)
  for r = 1, 4 do
    local wd = r >= 3 and 0.9 or 0.5
    fan:add(G.rell(45 + ux * (r + 0.5), 12.5 + uy * (r + 0.5), ux, uy, 0.9, wd))
  end
end
fan:cut(cup)
local fn = X.sphere(45, 11, 5, fan)
G.toneN(c, fan, fn, BLUE, { tok = ftok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.88 }, amb = 0.2, wrap = 0.3 })
-- toothed tips and dark throats
fan:edge():each(function(x, y) if y < 11 and X.hash(x, y, 6) < 0.4 then c:put(x, y, BLUE[5], ftok) end end)
c:put(45, 12, BLUE[1], ftok) c:put(44, 11, BLUE[2], ftok) c:put(46, 11, BLUE[2], ftok)
c:put(43, 9, BLUE[6], ftok)

-- seeds last
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local v = X.light(s.n, { amb = 0.12, wrap = 0.25 })
  local idx = X.tone(c, vis, v, SEED, { cuts = { 0.16, 0.3, 0.46, 0.64, 0.84 }, bias = sb, tok = tok })
  vis:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45) * s.tuft
    local w = (-dx * sa + dy * ca) / (s[4] + .45)
    -- lengthwise stripe, browned foot
    if abs(w - 0.15) < 0.17 and abs(u) < 0.7 then c:put(x, y, SEED[max(1, (idx[K(x, y)] or 3) - 1)], tok) end
    if u < -0.72 then c:put(x, y, SEED[max(1, min(3, (idx[K(x, y)] or 3) - 1))], tok) end
  end)
  -- hilum notch at the foot
  local fx, fy = s[1] - s.tuft * (s[3] + 0.2) * ca, s[2] - s.tuft * (s[3] + 0.2) * sa
  c:put(floor(fx + .5), floor(fy + .5), SEED[1], tok)
  -- pappus brush at the head (skip the planted one: its head is buried by the stem)
  if i < 3 or true then
    local hx, hy = s[1] + s.tuft * (s[3] + 0.9) * ca, s[2] + s.tuft * (s[3] + 0.9) * sa
    for b, a in ipairs{ -0.7, -0.25, 0.2, 0.65 } do
      local ux, uy = G.rot(s.tuft * ca, s.tuft * sa, a)
      for r = 0, 2 do
        local x, y = floor(hx + ux * r + .5), floor(hy + uy * r + .5)
        if not s.m:has(x, y) and not sm:has(x, y) then
          c:put(x, y, PAP[(b + r) % 2 == 0 and 3 or (r == 0 and 1 or 2)], tok) end
      end
    end
  end
  -- glint
  local gx, gy = G.specAt(vis, s.n, 30)
  if gx and i == 2 then c:put(gx, gy, SEED[6], tok) end
end

G.saveTo(c, "ph", NAME)
