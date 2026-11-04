-- plum-seed (aC35_3 final, Opus single pass). Two plum stones on a torn scrap of plum leaf. Each stone is a flattened
-- almond-shaped pit: per-pixel 6-tone light, a raised keel ridge along the upper edge (lit ridge + dark groove), pitted
-- woody surface (shadow dot + lit lip per pit), AO between the stones and contact shadows on the leaf. The leaf scrap has
-- a torn left end, a finely serrated margin, midrib + veins, V-fold light and a cool reflected edge. The right stone has
-- split along its seam: a pale stem rises from the crack with two rounded cotyledons and a first true plum leaf
-- (elliptic, serrated, pointed, with a reddish petiole). History: Sonnet draft replaced.
-- quirk: a dried shred of purple plum skin still clings to the left stone.
local NAME = "plum-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = A.new(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local NEW  = { "#24543e", "#33704a", "#4c9150", "#6fb058", "#9ccc68", "#cae688" }
local PIT  = { "#3a2022", "#5e3428", "#86502f", "#ad713f", "#cf9a5c", "#ecc58a" }
local STEM = { "#7a4a4a", "#b8826a", "#d8c09a", "#f2e6c0" }
local PLM  = { "#35295f", "#5a459e", "#8a6fd0" }
local COOL = "#3a6c72"

-- torn leaf scrap on the diagonal
local ltok = A.tok("leaf")
local lm, ln, LT, LS, len = A.blade(8, 54, 30, 50, 56, 42, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 8.4 * sin(pi * min(1, t * 0.82 + 0.18)) ^ 0.6)
end, { fold = 0.4 })
-- tear the left end: jagged cut line
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.1 + 0.05 * sin(LS[k] * 9) + 0.04 * (X.hash(x, y, 5) - 0.5) + 0.03 * LS[k]
  if LT[k] < lim then cut[#cut + 1] = k end
  -- serration: tiny notches on the margin
  if abs(LS[k]) > 0.9 and LT[k] > 0.2 and ((x + y) % 3 == 0) then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- stones
local st = { { 21, 46, 6.2, 3.9, -0.22 }, { 37, 42.5, 5.6, 3.6, -0.5 } }
for _, s in ipairs(st) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7) end
local bias = {}
for _, s in ipairs(st) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t < 0.95 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  local d = (t * len - abs(s) * 7) % 5.2
  if d < 0.9 and abs(s) > 0.18 and abs(s) < 0.82 and t < 0.9 then c:put(x, y, s < 0 and LEAF[min(6, (lidx[k] or 4) + 1)] or LEAF[max(1, (lidx[k] or 3) - 1)], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.15 then c:put(x, y, COOL, ltok) end
  if LT[k] < 0.2 and not bias[k] then c:put(x, y, "#c2d890", ltok) end   -- pale torn fibre edge
end)

-- sprout from the right stone's split (behind the stone)
local stok = A.tok("stem")
local sm = A.stem(c, { { 38, 41 }, { 37, 34 }, { 39, 28 }, { 38, 22 } }, function(t) return 1.0 end, STEM, { tok = stok })
local function blade(ax, ay, cx, cy, bx, by, w, ramp, pw, vs)
  local m, T, S, idx = A.leaf(c, ax, ay, cx, cy, bx, by, w, ramp, { tok = ltok, pw = pw, vs = vs or 2.4, fold = 0.35 })
  return m, T, S, idx
end
-- cotyledons: rounded, fleshy
local c1 = blade(37, 31, 33, 29, 28, 30, 2.3, NEW, 0.45, 9)
local c2 = blade(39, 31, 43, 29, 48, 30, 2.3, NEW, 0.45, 9)
-- first true leaf: elliptic plum leaf, pointed tip, serrated
local tm, TT, TS, tidx = blade(38, 23, 42, 14, 48, 8, 3.6, LEAF, 0.8, 2.2)
tm:edge():each(function(x, y) local k = K(x, y) if TS[k] and TS[k] < -0.6 and (x + y) % 2 == 0 then c:put(x, y, LEAF[6], ltok) end end)
for _, p in ipairs{ { 38, 22 }, { 38, 21 }, { 39, 21 } } do c:put(p[1], p[2], STEM[1], stok) end   -- reddish petiole

-- stones last: pitted wood, keel ridge, AO where they touch
local SC = {}
for i, s in ipairs(st) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #st do vis:cut(st[j].m) X.ao(sb, s.m, st[j].m, 1, -1) end
  local tok = A.tok("stone" .. i)
  local idx = A.toneN(c, vis, s.n, PIT, { tok = tok, bias = sb, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.08, wrap = 0.25 })
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    local i2 = idx[k] or 3
    -- keel ridge along the upper edge
    if v < -0.5 and v > -0.78 and abs(u) < 0.8 then c:put(x, y, PIT[min(6, i2 + 1)], tok)
    elseif v >= -0.5 and v < -0.3 and abs(u) < 0.75 then c:put(x, y, PIT[max(1, i2 - 2)], tok) end
    -- pits
    if abs(u) < 0.75 and v > -0.15 and v < 0.75 and X.hash(x, y, 11) < 0.13 then
      c:put(x, y, PIT[max(1, i2 - 2)], tok)
      if vis:has(x - 1, y - 1) then c:put(x - 1, y - 1, PIT[min(6, (idx[K(x - 1, y - 1)] or 3) + 1)], tok) end
    end
  end)
  SC[i] = { vis = vis, idx = idx, tok = tok }
end
-- glint on the left stone's ridge
c:put(17, 43, "#fff4d6", SC[1].tok)
-- split seam on the right stone, dark gap opening where the stem emerges
for _, p in ipairs{ { 33, 44 }, { 34, 43 }, { 35, 43 }, { 36, 42 }, { 37, 41 }, { 38, 41 }, { 39, 40 }, { 40, 40 } } do
  c:put(p[1], p[2], PIT[1], SC[2].tok) end
c:put(38, 40, STEM[2], stok) c:put(37, 40, STEM[3], stok)

-- quirk: shred of dried plum skin clinging to the left stone (curled, lit edge)
local qtok = A.tok("skin")
for _, p in ipairs{ { 23, 48, 1 }, { 24, 48, 2 }, { 25, 48, 2 }, { 24, 49, 1 }, { 25, 49, 1 }, { 26, 49, 2 }, { 26, 48, 3 }, { 27, 49, 1 } } do
  c:put(p[1], p[2], PLM[p[3]], qtok) end
A.save(c, NAME)
