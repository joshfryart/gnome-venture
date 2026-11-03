-- avocado-seed (final, Opus aR3_1, single pass). A sprouting avocado stone sitting on a torn scrap of avocado leaf.
-- Stone: egg-shaped, glossy brown with patches of matte papery seed coat flaking off, split open along the base
-- (dark seam) with a pale tap root curling out over the leaf, and a split at the top where a thin bronze-red shoot
-- rises to three elliptic young leaves (two green, one bronze, as new avocado growth is). Leaf scrap: elliptic,
-- glossy dark green, pale midrib, pinnate veins curving toward the tip, spec streak on the lit half, torn base edge
-- in paler tissue. AO and contact shadow under the stone, root and pick.
-- quirk: a wooden toothpick is stuck into the stone, the way it is suspended over a glass of water.
local NAME = "avocado-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local LEAF  = { "#10281f", "#173b2c", "#1f5233", "#2c6a3b", "#438646", "#6aa656" }
local VEIN, TORN, LSPEC = "#b6d47a", "#a6c97e", "#c9e69a"
local STONE = { "#361b19", "#552d1e", "#784227", "#9c5c34", "#c0814c", "#e3b27a" }
local COAT  = { "#6e4a34", "#93684a", "#b48a62", "#d2ad82" }
local ROOT  = { "#9a7a62", "#c8aa8a", "#e8d4b4", "#f8ecd2" }
local SHOOT = { "#4a1e22", "#76302c", "#a24c38", "#c87450" }
local YLEAF = { "#173a2e", "#21553a", "#2f7244", "#46904a", "#6aae56", "#98ca6a" }
local BRONZE = { "#4a1e26", "#702c2c", "#963e30", "#b85a3a", "#d6804e", "#eeac72" }
local PICK  = { "#8a6440", "#c49a68", "#e8c890", "#f8e4b4" }
local SPEC = "#fff4d6"

-- leaf scrap: elliptic blade lower-left -> right, torn at the base (left)
local lm, ln, LT, LS, len = G.blade(6, 50, 30, 50, 58, 37, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 8.0 * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.62)
end, { fold = 0.32 })
G.tear(lm, 12, 48, -0.94, 0.34, 1.6, 3)

-- stone
local SX, SY, RX, RY = 30, 34, 8.2, 9.4
local stone = HP.mask()
for y = floor(SY - RY - 1), floor(SY + RY + 1) do for x = floor(SX - RX - 1), floor(SX + RX + 1) do
  local dy = (y - SY) / (RY + 0.45)
  local rx = (RX + 0.45) * (1 + 0.1 * dy)           -- egg: narrower at the top
  if ((x - SX) / rx) ^ 2 + dy * dy <= 1 then stone:set(x, y) end
end end
local sn = X.sphere(SX - 0.5, SY - 0.5, 9, stone)

-- toothpick (quirk), behind the stone on the left
local pm, pn, PT, PS = G.tube({ { 31, 37 }, { 23, 37.6 }, { 17, 38.1 }, { 9, 38.6 } }, function(t) return t > 0.92 and 0.45 or 0.95 end)
pm:cut(stone)

-- root out of the base seam, curling over the leaf
local rm, rn, RT, RS = G.tube({ { 31, 42 }, { 30, 48 }, { 34, 53 }, { 38, 56 } }, function(t) return 2.0 * (1 - t) ^ 0.75 + 0.35 end)
rm:cut(stone)

-- leaf tone with AO / cast shadows from stone, root, pick
local bias = {}
X.ao(bias, lm, stone, 1, -1) G.cast(bias, lm, stone, 2, 2, -1) G.cast(bias, lm, stone, 1, 1, -1)
G.cast(bias, lm, rm, 1, 1, -1) G.cast(bias, lm, pm, 1, 2, -1)
local ltok = { r = { name = "leaf" } }
G.leafTone(c, lm, ln, LEAF, { bias = bias, tok = ltok })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if abs(s) < 0.16 and t > 0.03 and t < 0.95 then c:put(x, y, bias[k] and LEAF[3] or (s <= 0 and VEIN or LEAF[2]), ltok) return end
  if bias[k] then return end
  -- pinnate veins sweeping toward the tip
  local ph = (t * len - abs(s) * 6.5) / 6.2 + (s > 0 and 0.5 or 0)
  local f = ph - floor(ph)
  if f < 0.12 and abs(s) > 0.18 and abs(s) < 0.8 and t > 0.08 and t < 0.9 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
-- glossy streak on the lit half
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if not bias[k] and s < -0.42 and s > -0.62 and t > 0.62 and t < 0.8 then c:put(x, y, LSPEC, ltok) end end)
-- torn base: pale exposed tissue on the ragged edge
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] < 0.2 and (x - 12) * -0.94 + (y - 48) * 0.34 > -2.2 then c:put(x, y, TORN, ltok) end end)

-- toothpick
local ptok = { r = { name = "pick" } }
X.tone(c, pm, X.light(pn, { amb = 0.2, wrap = 0.3 }), PICK, { cuts = { 0.3, 0.55, 0.8 }, tok = ptok })
c:put(9, 39, PICK[2], ptok)

-- root: ivory, two growth rings, root hairs
local rtok = { r = { name = "root" } }
local ridx = X.tone(c, rm, X.light(rn, { amb = 0.12, wrap = 0.3 }), ROOT, { cuts = { 0.28, 0.52, 0.76 }, tok = rtok })
rm:each(function(x, y) local k = K(x, y) if (abs(RT[k] - 0.38) < 0.03 or abs(RT[k] - 0.62) < 0.03) and RS[k] > -0.4 then c:put(x, y, ROOT[max(1, ridx[k] - 1)], rtok) end end)
for _, q in ipairs{ { 29, 49 }, { 35, 55 } } do if not rm:has(q[1], q[2]) then c:put(q[1], q[2], ROOT[2], rtok) end end

-- stone: glossy body, papery coat patches, base seam, top split
local sv = X.light(sn, { amb = 0.05, wrap = 0.15 })
local sb = {}
X.ao(sb, stone, pm, 1, -1)
local ttok = { r = { name = "stone" } }
local tidx = X.tone(c, stone, sv, STONE, { cuts = { 0.15, 0.3, 0.47, 0.64, 0.82 }, tok = ttok, bias = sb })
-- coat patches: matte tan, irregular (noise threshold), kept off the specular zone; dark curled lower edge
local coatEdge = {}
stone:each(function(x, y) local k = K(x, y)
  local nz = X.hash(floor((x + 1) / 3), floor((y + 2) / 3), 21) * 0.7 + X.hash(x, y, 22) * 0.3
  if nz > 0.5 and not (x - SX < -1 and y - SY < -1) and abs(x - SX) < RX - 0.8 then
    local below = X.hash(floor((x + 1) / 3), floor((y + 3) / 3), 21) * 0.7 + X.hash(x, y + 1, 22) * 0.3
    c:put(x, y, COAT[max(1, min(4, tidx[k] - 1))], ttok)
    if below <= 0.5 and stone:has(x, y + 1) then coatEdge[#coatEdge + 1] = { x, y + 1 } end
  end
end)
for _, q in ipairs(coatEdge) do c:put(q[1], q[2], STONE[2], ttok) end
-- seam: vertical crack from base up, slightly opened (dark), lit lip on the left
for y = floor(SY + 2), floor(SY + RY + 0.5) do
  local x = floor(SX + 0.5 + (y - SY) * 0.08)
  if stone:has(x, y) then c:put(x, y, STONE[1], ttok) end
  if y > SY + 4 and stone:has(x + 1, y) then c:put(x + 1, y, STONE[2], ttok) end
  if stone:has(x - 1, y) and tidx[K(x - 1, y)] > 2 then c:put(x - 1, y, STONE[5], ttok) end
end
-- top split where the shoot comes out
c:put(30, floor(SY - RY + 0.5), STONE[1], ttok) c:put(30, floor(SY - RY + 1.5), STONE[1], ttok) c:put(31, floor(SY - RY + 1.5), STONE[2], ttok)
-- cool bounce + spec
local srim = X.rim(sn)
stone:edge():each(function(x, y) if srim[K(x, y)] > 0.75 then c:put(x, y, "#7c6684", ttok) end end)
c:put(25, 28, SPEC, ttok) c:put(26, 28, SPEC, ttok) c:put(25, 29, STONE[6], ttok)

-- shoot: thin bronze-red stem from the top split up to the leaves
local shm, shn = G.tube({ { 30, 26 }, { 29, 21 }, { 32, 17 }, { 32, 13 } }, function(t) return 1.0 end)
shm:cut(stone)
local shtok = { r = { name = "shoot" } }
X.tone(c, shm, X.light(shn, { amb = 0.15, wrap = 0.3 }), SHOOT, { cuts = { 0.3, 0.55, 0.8 }, tok = shtok })

local function youngLeaf(ax, ay, cx, cy, bx, by, w, ramp)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.7)
  end, { fold = 0.34 })
  m:cut(shm)
  local tok = { r = { name = "yl" .. ax .. bx } }
  G.toneN(c, m, n, ramp, { tok = tok, cuts = { 0.16, 0.32, 0.5, 0.66, 0.84 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.15 and T[k] > 0.08 and T[k] < 0.86 then
    c:put(x, y, S[k] <= 0 and ramp[6] or ramp[3], tok) end end)
  return m
end
youngLeaf(31, 19, 24, 18, 17, 13, 3.0, YLEAF)
youngLeaf(32, 17, 39, 15, 46, 10, 3.0, YLEAF)
youngLeaf(32, 14, 35, 11, 39, 9, 1.8, BRONZE)

G.save2(c, NAME)
