-- stone-wall-corner (lean E2_14)
local NAME = "stone-wall-corner"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local GREY = { "#2f2c3a", "#4b475a", "#6b6678", "#8c879a", "#aeaabb", "#d3d0dc" }
local WARM = { "#3a2c2c", "#5e4a44", "#86705e", "#a8917a", "#c9b394", "#e6d6b4" }
local ROSE = { "#3a2a36", "#5e4558", "#86647a", "#a8829a", "#c9a2b8", "#e6c8d6" }
local GRASS = { "#16382f", "#1f5236", "#2f7040", "#4a8f4a", "#74b05a", "#a4d070" }
local SOIL = { "#2a1a1c", "#44291f", "#5f3a28", "#7e5233", "#9c6c40", "#bb8a55" }
local WOOD = { "#2e1c1c", "#4d2e24", "#6e4530", "#8f5f3e", "#b17d4e", "#d3a266" }
local STEEL = { "#27293c", "#434a63", "#66708a", "#8e9ab2", "#bcc8da", "#eaf0f8" }
local function shade(m, R, rad, name, o)
  local n = X.pillow(m, rad or 3)
  o = o or {}
  o.tok = { r = { name = name } }
  G.toneN(c, m, n, R, o)
  return n
end
local function stone(m, R, seed, d)
  d = d or 0
  local tok = { r = { name = "s" .. seed } }
  m:each(function(x, y)
    local up, lf, dn, rt = m:has(x, y - 1), m:has(x - 1, y), m:has(x, y + 1), m:has(x + 1, y)
    local i, h = 3, X.hash(x, y, seed)
    if h > 0.9 then i = 4 elseif h < 0.1 then i = 2 end
    if not up or not lf then i = 5 end
    if not dn or not rt then i = 2 end
    if not up and not lf then i = 6 end
    c:put(x, y, R[max(1, min(6, i + d))], tok)
  end)
end
local function leaf(ax, ay, cx, cy, bx, by, w, R, veins, name, vcol)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.9 + 0.1)
    return max(0.5, w * sin(pi * u ^ 1.2) ^ 0.7)
  end, { fold = 0.45 })
  local tok = { r = { name = name } }
  G.toneN(c, m, n, R, { tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.22 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.13 and t > 0.04 and t < 0.92 then c:put(x, y, s <= 0 and R[6] or R[2], tok) return end
    for _, vt in ipairs(veins) do
      local d = t * L - (vt + abs(s) * 4)
      if d > -0.5 and d < 0.5 and abs(s) > 0.25 and abs(s) < 0.75 then c:put(x, y, s < 0 and R[5] or R[2], tok) return end
    end
  end)
  return m
end
local function plus(x, y, a, b)
  c:put(x, y, b) c:put(x - 1, y, a) c:put(x + 1, y, a) c:put(x, y - 1, a) c:put(x, y + 1, a)
end
local H = 22
local function FL(u, v) return 32 - 26 * u, 52 - 13 * u - H * v end
local function FR(u, v) return 32 + 26 * u, 52 - 13 * u - H * v end
local function quad(F, u0, u1, v0, v1)
  local pts = {}
  for _, p in ipairs{ {u0, v0}, {u1, v0}, {u1, v1}, {u0, v1} } do
    local x, y = F(p[1], p[2]) pts[#pts + 1] = { floor(x + 0.5), floor(y + 0.5) }
  end
  return c:poly(pts)
end
c:poly{ {32, 55}, {6, 42}, {6, 45}, {32, 58}, {58, 45}, {58, 42} }:each(function(x, y) c:put(x, y, X.hash(x, y, 2) > 0.8 and GRASS[3] or GRASS[1]) end)
local pal = { GREY, WARM, ROSE, GREY, WARM }
local vb = { 0, 0.34, 0.67, 1 }
local seed = 1
for f = 1, 2 do
  local F = f == 1 and FL or FR
  quad(F, 0, 1, 0, 1):each(function(x, y) c:put(x, y, GREY[1]) end)
  for r = 1, 3 do
    local u = 0
    local first = true
    while u < 1 do
      local w
      if first then w = ((r + f) % 2 == 0) and 0.34 or 0.14 else w = 0.15 + 0.12 * X.hash(r + f * 5, floor(u * 50), 4) end
      first = false
      local a, b = u, min(1, u + w)
      if b - a > 0.05 then
        seed = seed + 1
        local pick = pal[1 + floor(X.hash(seed, r, 8) * 5)]
        local m = quad(F, a + 0.02, b - 0.02, vb[r] + 0.03, vb[r + 1] - 0.03)
        if a < 0.01 then m = m:copy() quad(F, 0, b - 0.02, vb[r] + 0.03, vb[r + 1] - 0.03):each(function(x, y) m:set(x, y) end) end
        stone(m, pick, seed * 3, f == 1 and 0 or 1)
      end
      u = u + w
    end
  end
end
-- top: L-shaped cap
local function slabs(F, k, dx, base)
  local u, i = 0.27, 0
  while u < 1 do
    local w = 0.22 + 0.1 * X.hash(i, base, 5)
    local a, b = u + 0.02, min(1, u + w) - 0.02
    local p = {}
    for _, q in ipairs{ {a, 0}, {b, 0}, {b, 1}, {a, 1} } do
      local x, y = F(q[1], 0) p[#p + 1] = { floor(x + q[2] * dx + 0.5), floor(y - H - q[2] * 3.5 + 0.5) }
    end
    stone(c:poly(p), pal[1 + (i + base) % 3], 60 + i + base * 9, -1)
    u = u + w i = i + 1
  end
end
c:poly{ {6, 17}, {32, 30}, {39, 26}, {13, 13} }:each(function(x, y) c:put(x, y, GREY[1]) end)
c:poly{ {58, 17}, {32, 30}, {25, 26}, {51, 13} }:each(function(x, y) c:put(x, y, GREY[1]) end)
slabs(FL, 1, 7, 1)
slabs(FR, 1, -7, 2)
local corner = c:poly{ {32, 30}, {25, 26}, {32, 23}, {39, 26} }
stone(corner, WARM, 99, -1)
-- bright quoin edge down the corner
for y = 31, 52 do if X.hash(32, y, 3) > 0.35 then c:put(32, y, WARM[5]) end end
-- tufts at the foot
for k = 0, 22 do
  local uu = X.hash(k, 2, 6)
  local x, y = FL(uu, 0) if k % 2 == 1 then x, y = FR(uu, 0) end
  x, y = floor(x), floor(y)
  c:put(x, y, GRASS[4]) c:put(x, y - 1, GRASS[5])
end
-- quirk: an orange snail on the left face
for _, p in ipairs{ {17, 33, "#ffb04a"}, {18, 33, "#e8782a"}, {17, 34, "#e8782a"}, {18, 34, "#a8481c"}, {16, 34, "#e8d4a8"}, {15, 35, "#e8d4a8"}, {16, 35, "#e8d4a8"}, {17, 35, "#c8b088"}, {14, 34, "#e8d4a8"} } do c:put(p[1], p[2], p[3]) end
G.save(c, NAME)
