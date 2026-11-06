-- foxtail-lily-seed (B32, Opus single pass). Three Eremurus seeds: a plump dark-brown body inside a papery,
-- three-cornered tan wing with fine radial veins, on a long, keeled, glaucous strap-leaf scrap (parallel veins, waxy
-- bloom, cool reflected edge, AO and contact shadows) torn ragged at the lower-left. The top seed has germinated the
-- monocot way: two slim, keeled grass-like strap leaves, one arching over.
-- quirk: a single fallen orange star floret, long stamen and all, rests near the leaf tip.
local NAME = "foxtail-lily-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = G.new(NAME)

local LEAF = { "#173a40", "#20504c", "#2c6a58", "#468868", "#6ea67c", "#a2c69a" }
local VEIN, COOL, BLOOM = "#b8d8b4", "#3c6a80", "#a6c4bc"
local WING = { "#6e4e34", "#9a7448", "#c49e66", "#e2c690", "#f4e2b4" }
local SEED = { "#2e1a1c", "#4a2a24", "#6e3e2c", "#94583a", "#b8784c", "#d89e68" }
local ORA = { "#8e3226", "#d0562a", "#f08636", "#ffb456", "#ffe38a" }

-- strap leaf on the diagonal, ragged at the lower-left, pointed upper-right
local lm, ln, LT, LS, len = G.blade(6, 55, 26, 47, 58, 29, function(t)
  if t > 0.995 then return -1 end
  return max(0.4, 4.6 * min(1, (1 - t) / 0.28) ^ 0.8)
end, { fold = 0.6 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  if LT[k] < 0.05 + 0.05 * sin(LS[k] * 8 + 1) + 0.04 * X.hash(x, y, 4) then cut[#cut + 1] = k end end)
for _, k in ipairs(cut) do lm.s[k] = nil end

local seeds = { { 17, 47, 0.3 }, { 29, 46, -0.5 }, { 38, 36, 0.9 } }
for _, s in ipairs(seeds) do
  local pts = {}
  for j = 0, 2 do local a = s[3] + j * 2 * pi / 3 pts[#pts + 1] = { s[1] + 5.6 * cos(a), s[2] + 5.6 * sin(a) } end
  local w = c:poly(pts)
  w:add(G.oval(s[1], s[2], 4.2, 4.2, 0, 1))   -- rounded wing lobes
  local tri = HP.mask()
  w:each(function(x, y)
    -- trim to a rounded triangle: keep pixels within 4.2 or near a corner direction
    local dx, dy = x - s[1], y - s[2]
    local r = sqrt(dx * dx + dy * dy)
    local a = math.atan(dy, dx) - s[3]
    local lobe = 3.6 + 1.9 * (0.5 + 0.5 * cos(3 * a))
    if r <= lobe then tri:set(x, y) end
  end)
  s.w = tri
  s.wn = X.pillow(tri, 2)
  s.b, s.bn = G.oval(s[1], s[2], 1.9, 1.5, s[3], 0.9)
end

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.w, 1, -2) G.cast(bias, lm, s.w, 1, 1, -1) end
local lidx = G.shade(c, lm, ln, LEAF, { bias = bias, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.2, wrap = 0.3 })
-- parallel veins and the keel
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 then c:put(x, y, s <= 0 and VEIN or LEAF[2]) return end
  local band = abs(s) * 4.2
  if abs(band - floor(band + 0.5)) < 0.12 and abs(s) < 0.85 then c:put(x, y, LEAF[max(1, min(6, (lidx[k] or 3) + (s < 0 and 1 or -1)))]) return end
  if X.hash(x, y, 13) > 0.93 and (lidx[k] or 1) >= 3 then c:put(x, y, BLOOM) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.08 and LT[k] < 0.9 then c:put(x, y, COOL) end end)
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] < 0.14 and abs(LS[k]) < 0.85 then c:put(x, y, LEAF[5]) end end)

-- sprout: two keeled strap leaves from the top seed
local function strap(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.35, w * (1 - t) ^ 0.5)
  end, { fold = 0.5 })
  G.shade(c, m, n, LEAF, { amb = 0.16, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.18 and T[k] > 0.1 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3]) end end)
  return m
end
local s2 = strap(39, 34, 45, 22, 51, 15, 1.3)
local s1 = strap(37, 34, 34, 18, 25, 13, 1.6)
-- sheath at the base where both leaves leave the seed
c:put(38, 33, LEAF[5]) c:put(37, 33, LEAF[4]) c:put(39, 33, LEAF[3])

-- seeds: wing then body, AO ring on the wing around the body
for i, s in ipairs(seeds) do
  local wv = X.light(s.wn, { amb = 0.2, wrap = 0.35 })
  local wb = {}
  X.ao(wb, s.w, s.b, 1, -1)
  local vis = s.w:copy()
  if i == 3 then vis:cut(HP.mask()) end
  vis:each(function(x, y) local k = K(x, y)
    local idx = 1
    for jj, t in ipairs{ 0.2, 0.4, 0.6, 0.8 } do if wv[k] >= t then idx = jj + 1 end end
    -- radial veins toward each corner
    local dx, dy = x - s[1], y - s[2]
    local a = math.atan(dy, dx) - s[3]
    if cos(3 * a) > 0.93 and (dx * dx + dy * dy) > 6 then idx = idx - 1 end
    if wb[k] then idx = idx - 1 end
    c:put(x, y, WING[max(1, min(5, idx))])
  end)
  local bv = X.light(s.bn, { amb = 0.1, wrap = 0.3 })
  s.b:each(function(x, y) local k = K(x, y)
    local idx = 1
    for jj, t in ipairs{ 0.16, 0.32, 0.48, 0.64, 0.82 } do if bv[k] >= t then idx = jj + 1 end end
    c:put(x, y, SEED[max(1, min(6, idx))])
  end)
  local gx, gy = G.specAt(s.b, s.bn, 30)
  if gx and i == 2 then c:put(gx, gy, "#fff4d6") end
end
-- sprout leaves rise out of the top seed body: redraw their bases over the wing
c:put(38, 34, LEAF[4]) c:put(38, 35, LEAF[3])

-- quirk: fallen orange star floret near the tip (six tiny petals + long stamen)
local fx, fy = 50, 37
for _, q in ipairs{ { 0, 0, 2 }, { -1, 0, 4 }, { 1, 0, 2 }, { 0, -1, 4 }, { 0, 1, 1 }, { -1, -1, 5 }, { 1, 1, 1 }, { -2, 1, 3 }, { 2, -1, 3 }, { 1, -1, 3 }, { -1, 1, 2 } } do
  c:put(fx + q[1], fy + q[2], ORA[q[3]]) end
c:put(fx + 1, fy - 2, ORA[5]) c:put(fx + 2, fy - 3, ORA[5]) c:put(fx + 3, fy - 4, "#c46a2a")

G.save(c, NAME)
