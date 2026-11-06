-- rooibos-seed (Opus-style single pass, artist D13_1). Rooibos (Aspalathus linearis): small, hard, glossy olive-ochre
-- bean seeds with dark mottling and a pale hilum notch, lying on a torn scrap of rooibos foliage (silvery-green, parallel
-- needle fibres, frayed into needle tips at the torn end, oxidised red-brown like brewed tea). One seed has split: a
-- red-based stem rises with a pair of oval seed leaves, a whorl and a top tuft of true needle leaves.
-- quirk: a bead of dew sits on a needle tip.
local NAME = "rooibos-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_1.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local c = A.new(NAME)
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local LEAF = { "#183a35", "#245840", "#37774a", "#549a52", "#7fbb66", "#b4da8a" }
local COT  = { "#1d4a3c", "#2b6a46", "#41904f", "#62b058", "#8ccd6a", "#bce68e" }
local SEED = { "#2b2016", "#4d3a1c", "#74602a", "#9c8238", "#c4a84c", "#eed78c" }
local STEM = { "#4a2328", "#7a3a30", "#a2573c", "#7c9a4a", "#a4c05e" }
local NEE  = { "#1f4c3a", "#2f7046", "#4a9650", "#74b95e", "#a2d676" }
local RED, REDL, VEIN = "#8a3a2c", "#b85a36", "#cfe79a"

-- torn leaf scrap ---------------------------------------------------------------------------------
local lm, ln, LT, LS, len = G.blade(6, 53, 27, 58, 57, 44, function(t)
  if t > 0.99 then return -1 end
  local u = 0.06 + 0.8 * t
  return max(0.9, 6.0 * sin(pi * u) ^ 0.6)
end, { fold = 0.3 })
-- fray the torn right end into needle strips of different lengths
local cuts = { { -0.66, 0.78 }, { -0.3, 0.86 }, { 0.06, 0.8 }, { 0.42, 0.88 }, { 0.76, 0.82 } }
local nib = HP.mask()
lm:each(function(x, y)
  local k = K(x, y)
  for _, cu in ipairs(cuts) do
    if abs(LS[k] - cu[1]) < 0.09 and LT[k] > cu[2] then nib:set(x, y) end
  end
end)
lm:cut(nib)
-- seed positions (cx, cy, rx, ry, ang)
local seeds = {
  { 14, 52, 3.8, 2.8, -0.35 },
  { 23, 55, 3.7, 2.7, 0.45 },
  { 47, 47, 3.7, 2.7, 0.2 },
  { 31, 50, 3.8, 2.8, -1.3 },   -- the split one
}
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 1.0) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) G.cast(bias, lm, s.m, 2, 2, -1) end
local ltok = { r = { name = "scrap" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.12, wrap = 0.2 })
-- parallel needle fibres: a few long grooves with a lit lip
lm:each(function(x, y)
  local k = K(x, y)
  if bias[k] then return end
  for _, b in ipairs{ -0.5, 0.42 } do
    if abs(LS[k] - b) < 0.1 and LT[k] > 0.06 and LT[k] < 0.9 then
      c:put(x, y, LEAF[2], ltok)
      if y > 0 and lm:has(x, y - 1) and abs(LS[K(x, y - 1)] - b) >= 0.1 then c:put(x, y - 1, LEAF[5], ltok) end
    end
  end
  if abs(LS[k]) < 0.09 and LT[k] > 0.1 and LT[k] < 0.8 then c:put(x, y, VEIN, ltok) end
end)
-- cool bounce light on the lower-right rim, oxidised red-brown at both torn ends
lm:edge():each(function(x, y)
  local k = K(x, y)
  if bias[k] then return end
  if LS[k] > 0.55 and LT[k] > 0.1 and LT[k] < 0.75 then c:put(x, y, "#3a8a78", ltok) end
end)
lm:each(function(x, y)
  local k = K(x, y)
  if LT[k] > 0.9 and X.hash(x, y, 3) > .15 then c:put(x, y, (LT[k] > .95 and RED) or REDL, ltok) end
  if LT[k] < 0.05 then c:put(x, y, (X.hash(x, y, 4) > .5) and REDL or RED, ltok) end
end)

-- sprout ------------------------------------------------------------------------------------------
local sp = seeds[4]
-- radicle: pale root curling down-left onto the leaf
local rm = c:line({ { 30, 52 }, { 29, 54 }, { 27, 55 }, { 26, 54 } }, 1)
rm:each(function(x, y) c:put(x, y, "#e2d2b4", { r = { name = "root" } }) end)
c:put(30, 52, "#f6ecd6") c:put(26, 54, "#b8a488")
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- stem (reddish at the base, greening)
local stm, stn, ST = G.tube({ { 31, 47 }, { 30, 39 }, { 35, 32 }, { 34, 21 } }, function(t) return 1.0 - 0.25 * t end)
local stok = { r = { name = "stem" } }
local sv = X.light(stn, { amb = 0.15, wrap = 0.3 })
stm:each(function(x, y)
  local k = K(x, y)
  local lit = sv[k] > 0.5
  local col
  if ST[k] < 0.4 then col = lit and STEM[3] or STEM[2] elseif ST[k] < 0.6 then col = lit and STEM[4] or STEM[2]
  else col = lit and STEM[5] or STEM[4] end
  c:put(x, y, col, stok)
end)

-- needle leaf: slim tapered blade; lit upper-left side
local function needle(ax, ay, bx, by, bend, w, ramp, tip)
  local mx, my = (ax + bx) / 2, (ay + by) / 2
  local dx, dy = bx - ax, by - ay
  local l = sqrt(dx * dx + dy * dy)
  local cx, cy = mx + (-dy / l) * bend, my + (dx / l) * bend
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t) return max(0.45, w * (1 - t * .6)) end, { fold = 0.2 })
  local tok = { r = { name = "nee" .. ax .. "_" .. bx .. by } }
  m:each(function(x, y)
    local k = K(x, y)
    local i = (S[k] < -0.25) and 4 or ((S[k] < 0.35) and 3 or 2)
    if T[k] > .8 then i = i + 1 end
    if T[k] < .12 then i = i - 1 end
    c:put(x, y, ramp[max(1, min(5, i))], tok)
  end)
  m:edge():each(function(x, y) end)
  return m
end
-- cotyledon: plump oval seed leaf
local function cot(ax, ay, cx, cy, bx, by)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.92 + 0.08)
    return max(0.6, 2.7 * sin(pi * u ^ 0.9) ^ 0.7)
  end, { fold = 0.5 })
  m:cut(stm)
  local tok = { r = { name = "cot" .. ax .. bx } }
  G.toneN(c, m, n, COT, { tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.12, wrap = 0.22 })
  m:each(function(x, y)
    local k = K(x, y)
    if abs(S[k]) < 0.14 and T[k] > 0.08 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and COT[6] or COT[2], tok) end
  end)
  m:edge():each(function(x, y) local k = K(x, y) if S[k] > 0.6 and T[k] > 0.2 and T[k] < 0.85 then c:put(x, y, "#3a8a78", tok) end end)
  return m
end
local CL = cot(31, 34, 25, 31, 19, 34)
local CR = cot(35, 33, 41, 30, 47, 32)
-- whorl of needles at y~27 and the crown tuft at the top
local function fan(x, y, list, L)
  for _, a in ipairs(list) do
    local ex, ey = x + cos(a[1]) * a[2], y + sin(a[1]) * a[2]
    needle(x, y, floor(ex + .5), floor(ey + .5), a[3] or 0, 0.9, NEE)
  end
end
fan(34, 27, { { -2.45, 9, -1 }, { -0.7, 9, 1 } })
fan(34, 21, { { -2.6, 11, -1.5 }, { -2.05, 13, -1 }, { -1.57, 13, 0 }, { -1.1, 13, 1 }, { -0.55, 11, 1.5 } })
for _, p in ipairs{ { 34, 20, 4 }, { 33, 19, 5 }, { 34, 19, 5 }, { 34, 18, 4 } } do c:put(p[1], p[2], NEE[p[3]], { r = { name = "bud" } }) end
-- AO where leaves meet the stem
for _, p in ipairs{ { 32, 34 }, { 33, 34 }, { 34, 28 }, { 34, 23 } } do if stm:has(p[1], p[2]) then c:put(p[1], p[2], STEM[1], stok) end end

-- seeds -------------------------------------------------------------------------------------------
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local m = s.m
  -- bean notch (hilum side): cut one pixel from the concave edge
  local a = s[5]
  local nx, ny = floor(s[1] - sin(a) * (s[4] + .2) + .5), floor(s[2] + cos(a) * (s[4] + .2) + .5)
  m:cut(HP.mask():set(nx, ny))
  local idx = X.tone(c, m, X.light(s.n, { amb = 0.07, wrap = 0.22 }), SEED, { cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = tok })
  -- mottled coat: dark flecks on the mid tones
  m:each(function(x, y)
    local k = K(x, y)
    if idx[k] >= 3 and idx[k] <= 5 and X.hash(x, y, 40 + i) > 0.74 then c:put(x, y, SEED[idx[k] - 2], tok) end
  end)
  -- hilum: dark dot ringed pale at the concave side
  local hx, hy = floor(s[1] - sin(a) * (s[4] - 1.0) + .5), floor(s[2] + cos(a) * (s[4] - 1.0) + .5)
  if m:has(hx, hy) then c:put(hx, hy, SEED[1], tok) end
  if m:has(hx + 1, hy) and i ~= 4 then c:put(hx + 1, hy, "#e8d6a8", tok) end
  -- specular
  local bx, by = G.specAt(m, s.n, 28)
  if bx then c:put(bx, by, "#fff4d6", tok) end
  -- contact shadow under the seed on the lower-right happens via bias; reflected green on the lower rim
  m:edge():each(function(x, y) end)
end
-- the sprouting seed: split open where the stem leaves
for _, p in ipairs{ { 30, 47 }, { 31, 47 }, { 31, 48 } } do if sp.m:has(p[1], p[2]) then c:put(p[1], p[2], SEED[1], { r = { name = "seed4" } }) end end
c:put(31, 47, STEM[2], { r = { name = "seed4" } })
c:put(32, 48, SEED[2], { r = { name = "seed4" } })

-- quirk: dew bead on the tip of the lower-left needle
local dx0, dy0 = 26, 21
local dew = { { 1, 0, 0 }, { 0, 1, 0 }, { 1, 1, 0 }, { 2, 1, 0 }, { 1, 2, 0 } }
local DEW = { rim = "#4a9aa6", core = "#bff0e6", lite = "#e8fff4", dark = "#2f6f86" }
c:put(dx0 + 1, dy0, DEW.rim) c:put(dx0, dy0 + 1, DEW.rim) c:put(dx0 + 1, dy0 + 1, DEW.core) c:put(dx0 + 2, dy0 + 1, DEW.dark)
c:put(dx0 + 1, dy0 + 2, DEW.dark) c:put(dx0, dy0, "#e8fff4") c:put(dx0, dy0 + 1, DEW.lite)
A.save(c)
