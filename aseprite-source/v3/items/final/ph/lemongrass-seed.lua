-- lemongrass-seed (final, Opus single pass). Three slim straw-gold lemongrass spikelets (husk ridges, a twisted
-- geniculate awn each) on a torn scrap of lemongrass blade (parallel veins, pale midrib, ragged torn ends, V-fold
-- light, cool reflected edge, AO + contact shadow under each seed). The middle seed has germinated: pale violet-tinged
-- sheath, white rootlets, and three long arching grass blades that show the lemongrass clump.
-- quirk: the right torn end of the scrap has curled up into a little scroll.
local NAME = "lemongrass-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new(NAME)

local LEAF  = { "#1e4a3c", "#2b6646", "#3f8a4e", "#64a856", "#94c86a", "#c2e290" }
local SPR   = { "#24543e", "#357a48", "#4e9a50", "#78bc5c", "#a8d878", "#d4eea2" }
local COOL  = "#3c6e78"
local HUSK  = { "#4e3220", "#7a5230", "#a6773e", "#cc9d55", "#e8c47a", "#f8e2a6" }
local SHEATH = { "#6a4a6a", "#9a7896", "#c8aec2", "#ece0e2" }
local ROOT  = { "#b8a890", "#e8dcc4", "#fbf3e2" }

-- torn scrap of lemongrass blade, lying on a slight diagonal
local AX, AY, BX, BY = 7, 52, 54, 43
local lm, ln, LT, LS, len = A.blade(AX, AY, 30, 49, BX, BY, function(t) return 6.4 - 0.8 * t end, { fold = 0.3 })
-- ragged torn ends
local cut = {}
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  local j = X.hash(floor(s * 6), 3, 11)
  if t < 0.035 + 0.05 * j then cut[#cut + 1] = k end
  if t > 0.95 - 0.06 * X.hash(floor(s * 5), 9, 4) then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- seeds: spikelets (cx, cy, rx, ry, ang)
local seeds = { { 16, 47.5, 5, 2.1, -0.35 }, { 30, 45, 4.6, 2.1, -0.9 }, { 41, 46, 5, 2.1, 0.25 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 1, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- parallel veins + pale midrib
lm:each(function(x, y) local k = K(x, y) if bias[k] then return end
  local s = LS[k]
  if abs(s) < 0.1 then c:put(x, y, LEAF[6], ltok)
  elseif abs(abs(s) - 0.45) < 0.07 or abs(abs(s) - 0.78) < 0.06 then c:put(x, y, LEAF[max(1, (lidx[k] or 3) - 1)], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.08 and LT[k] < 0.86 then c:put(x, y, COOL, ltok) end end)
-- torn fibres: pale frayed pixels at the left end
for _, p in ipairs{ {7, 49}, {6, 51}, {8, 54} } do if lm:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[5], ltok) end end

-- quirk: curled scroll at the right torn end
local sc = c:ellipse(55, 41.5, 2.6, 3.2)
local scn = X.sphere(54.6, 41, 3.3, sc)
local stok = { r = { name = "scroll" } }
A.shade(c, sc, scn, LEAF, { tok = stok, amb = 0.12 })
for _, p in ipairs{ {55, 41, 1}, {55, 42, 2}, {56, 41, 2}, {54, 40, 6}, {55, 39, 5} } do c:put(p[1], p[2], LEAF[p[3]], stok) end
c:put(54, 42, LEAF[3], stok)

-- rootlets from the sprouting seed, lying on the leaf
local rtok = { r = { name = "root" } }
for _, r in ipairs{ { {27, 47}, {25, 50}, {22, 51} }, { {29, 48}, {30, 51}, {33, 52} } } do
  local m = HP.line(r, 1)
  m:each(function(x, y) if lm:has(x, y) then c:put(x, y, ROOT[2], rtok) if lm:has(x + 1, y + 1) and not m:has(x + 1, y + 1) then c:put(x + 1, y + 1, LEAF[1], ltok) end end end)
end

-- sprout: sheath + three arching blades
local sh, shn, SHT, SHS = A.tube({ {30, 43}, {30, 39}, {30.5, 35}, {30.5, 31} }, function(t) return 1.5 - 0.4 * t end)
local shtok = { r = { name = "sheath" } }
local shidx = A.shade(c, sh, shn, SHEATH, { tok = shtok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.2, wrap = 0.35 })
-- sheath turns green toward the top
sh:each(function(x, y) if y < 34 then c:put(x, y, SPR[min(6, (shidx[K(x, y)] or 2) + 2)], shtok) end end)
local B1 = A.grass(c, 30, 32, 27, 18, 31, 7, 1.7, SPR, { pw = 0.55 })
local B2 = A.grass(c, 30, 33, 22, 22, 12, 25, 1.5, SPR, { pw = 0.6, cut = B1 })
local B3 = A.grass(c, 31, 33, 40, 19, 49, 22, 1.5, SPR, { pw = 0.6, cut = B1 })
-- AO where blades leave the sheath
for _, p in ipairs{ {29, 31}, {31, 31}, {30, 30} } do c:put(p[1], p[2], SPR[2], shtok) end

-- seeds last: husk ridges, glint, twisted awn
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local idx = A.shade(c, s.m, s.n, HUSK, { tok = tok, amb = 0.12, wrap = 0.3 })
  s.m:each(function(x, y) local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / s[3]
    local vv = (-dx * sa + dy * ca) / s[4]
    if abs(vv) < 0.35 and abs(u) < 0.7 then c:put(x, y, HUSK[max(1, (idx[K(x, y)] or 3) - 1)], tok) end end)
  local gx, gy = A.specAt(s.m, s.n, 30)
  if gx then c:put(gx, gy, HUSK[6], tok) end
  -- awn from the tip: straight then kinked (geniculate), twisted dark/light below the knee
  if i ~= 2 then
    local tx, ty = s[1] + ca * (s[3] + 1), s[2] + sa * (s[3] + 1)
    local kx, ky = tx + ca * 3, ty + sa * 3
    local ex, ey = kx + 2, ky - 3
    local m1 = HP.line({ {tx, ty}, {kx, ky} }, 1)
    local n = 0
    m1:each(function(x, y) n = n + 1 c:put(x, y, ((x + y) % 2 == 0) and HUSK[2] or HUSK[4], tok) end)
    HP.line({ {kx, ky}, {ex, ey} }, 1):each(function(x, y) c:put(x, y, HUSK[5], tok) end)
  end
end
A.save(c, NAME)
