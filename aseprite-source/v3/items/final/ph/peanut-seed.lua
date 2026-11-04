-- peanut-seed (final pass, Opus, aC32_5). Two oblong peanut kernels in papery red-brown skins (fine skin veins, pale
-- germ tip, AO between them) on a torn peanut-leaflet scrap (obovate, ragged torn end, midrib + veins, V-fold light,
-- cool reflected edge, contact shadows). A third kernel has split into its two cream halves and sprouted: a pale stem
-- carrying a true peanut leaf, two pairs of oval leaflets on a petiole, and a short root over the scrap edge.
-- quirk: the left kernel still rides in half of its netted shell, like a little boat.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("peanut-seed")

local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local VEIN, COOL = "#c2e48c", "#3a6c72"
local SKIN  = { "#3e1a1e", "#66262a", "#8e3a32", "#b2563e", "#cc7a56", "#e8a684" }
local CRM   = { "#7a5a3a", "#a8865a", "#cfae7c", "#e6cc98", "#f4e2b6", "#fff4d6" }
local SHELL = { "#5a3c26", "#86603a", "#ac844e", "#c8a466", "#dcc084", "#eed8a4" }
local STEM  = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local ROOT  = { "#9a8a6a", "#c8b894", "#e8dcbc", "#fbf2dc" }

-- leaf scrap: one peanut leaflet lying on the diagonal, torn off across its wide end
local lm, ln, LT, LS = A.blade(8, 52, 30, 54, 56, 42, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 8.0 * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.55)
end, { fold = 0.36 })
-- ragged tear at the base end
lm:each(function(x, y) local k = K(x, y)
  local t = LT[k]
  local jag = 0.06 + 0.07 * X.hash(floor(LS[k] * 6), 0, 9) + 0.03 * sin(LS[k] * 11)
  if t < jag then lm.s[k] = nil end
end)

-- kernels: cx, cy, rx, ry, angle
local ks = { { 17, 47, 5.2, 3.2, -0.15 }, { 28, 48.5, 5.0, 3.1, 0.1 } }
for _, s in ipairs(ks) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end
-- shell boat under kernel 1
local sh, shn = A.oval(17, 49, 7.4, 3.6, -0.15, 0.8)
local shTop = HP.mask()
sh:each(function(x, y) if y < 47 - (x - 17) * 0.15 then shTop:set(x, y) end end)
sh:cut(shTop)

local bias = {}
for _, s in ipairs(ks) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
X.ao(bias, lm, sh, 1, -1) A.cast(bias, lm, sh, 1, 2, -1)
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local d = (t * 50 - abs(s) * 7) % 5.2
  if d < 0.85 and abs(s) > 0.2 and abs(s) < 0.78 and t < 0.9 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.12 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
-- torn edge: pale broken fibre pixels
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] < 0.2 and abs(LS[k]) < 0.85 then c:put(x, y, LEAF[5], ltok) end end)

-- sprouting kernel: split into two cream halves (cotyledons), skin peeled back
local sx, sy = 42, 43
local h1, n1 = A.oval(sx - 2.6, sy + 0.5, 3.0, 4.2, 0.35, 0.8)
local h2, n2 = A.oval(sx + 2.8, sy + 0.2, 3.0, 4.2, -0.35, 0.8)
-- root: short pale radicle down over the scrap edge
local rm = A.stem(c, { { sx, sy + 3 }, { sx + 1, sy + 7 }, { sx + 4, sy + 9 }, { sx + 5, sy + 13 } }, function(t) return 1.1 * (1 - t) + 0.35 end, ROOT, { cut = h1:copy():add(h2) })
A.cast(bias, lm, rm, 1, 1, -1)
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
c:px(sx + 2, sy + 9, ROOT[2]) c:px(sx + 6, sy + 11, ROOT[2])   -- root hairs

-- stem up to the true leaf
local stok = { r = { name = "stem" } }
local spts = { { sx, sy - 1 }, { sx - 1, sy - 9 }, { sx + 1, sy - 17 }, { sx, sy - 25 } }
local stm = A.stem(c, spts, function(t) return 1.1 - t * 0.2 end, STEM, { tok = stok })
-- peanut leaf: petiole + two pairs of oval leaflets
local px, py = sx, sy - 25
local ll = HP.mask()
local function leaflet(ax, ay, bx, by, w)
  local m = A.leaf(c, ax, ay, (ax + bx) / 2 + (by - ay) * 0.12, (ay + by) / 2 - (bx - ax) * 0.12, bx, by, w, LEAF,
    { cut = stm, vs = 2.6, pw = 0.6, wfn = function(t) if t > 0.985 then return -1 end return max(0.4, w * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.55) end })
  ll:add(m)
  return m
end
-- lower pair (from mid stem), upper pair (from the petiole tip)
leaflet(sx - 1, sy - 15, sx - 11, sy - 21, 2.7)
leaflet(sx + 1, sy - 16, sx + 11, sy - 21, 2.7)
leaflet(px - 1, py, px - 8, py - 7, 2.6)
leaflet(px + 1, py, px + 8, py - 7, 2.6)
-- petiole drawn over leaflet bases
for i = 0, 8 do local x, y = A.bez(spts, 0.62 + i * 0.047) c:put(floor(x + .5), floor(y + .5), i < 4 and STEM[2] or STEM[3], stok) end
c:px(px, py - 1, STEM[4])

-- cotyledon halves (drawn over the stem foot)
local ctok = { r = { name = "coty" } }
A.shade(c, h1, n1, CRM, { tok = ctok, amb = 0.12, wrap = 0.3 })
local h2v = h2:copy():cut(h1)
A.shade(c, h2v, n2, CRM, { tok = ctok, amb = 0.12, wrap = 0.3 })
for y = sy - 3, sy + 4 do if h2v:has(sx, y) then c:put(sx, y, CRM[1], ctok) end end   -- split line
-- peeled skin flap curling off the right half
A.map(c, { "ab.", "bcb", ".bd" }, sx + 4, sy - 3, { a = SKIN[5], b = SKIN[3], c = SKIN[4], d = SKIN[2] }, ctok)
c:px(sx - 4, sy - 2, CRM[6])
for _, p in ipairs{ {sx - 1, sy + 3}, {sx + 1, sy + 4}, {sx - 2, sy + 4}, {sx + 2, sy + 3} } do if lm:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[1], ltok) end end

-- shell boat: netted texture, pale inner lip
local stok2 = { r = { name = "shell" } }
local si = A.shade(c, sh, shn, SHELL, { tok = stok2, amb = 0.15, wrap = 0.3 })
sh:each(function(x, y) local k = K(x, y)
  if ((x + 2 * y) % 5 == 0 or (x - 2 * y) % 6 == 0) then c:put(x, y, SHELL[max(1, si[k] - 2)], stok2) end end)
-- inner lip: top row of the boat
sh:each(function(x, y) if not sh:has(x, y - 1) then c:put(x, y, SHELL[6], stok2) end end)

-- kernels last: oval light, skin veins, germ tip, AO between
for i, s in ipairs(ks) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #ks do vis:cut(ks[j].m) X.ao(sb, s.m, ks[j].m, 1, -1) end
  if i == 1 then X.ao(sb, s.m, sh, 1, -1) end
  local tok = { r = { name = "kern" .. i } }
  local idx = A.shade(c, vis, s.n, SKIN, { tok = tok, bias = sb, amb = 0.08, wrap = 0.25 })
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / s[3], (-dx * sa + dy * ca) / s[4]
    -- papery skin veins: thin wavy lines along the kernel
    local w = v + 0.18 * sin(u * 5 + i)
    if (abs(w - 0.15) < 0.11 or abs(w + 0.45) < 0.1) and abs(u) < 0.8 then c:put(x, y, SKIN[max(1, idx[k] - 2)], tok) end
  end)
  -- germ tip at the left end: pale cream nub
  local gx, gy = floor(s[1] - s[3] * ca + 1.5), floor(s[2] - s[3] * sa + 0.5)
  c:put(gx, gy, CRM[4], tok) c:put(gx, gy + 1, CRM[2], tok)
  -- 2x1 specular
  c:put(s[1] - 2, s[2] - 2, SKIN[6], tok) c:put(s[1] - 1, s[2] - 2, CRM[6], tok)
end
A.save(c, "peanut-seed")
