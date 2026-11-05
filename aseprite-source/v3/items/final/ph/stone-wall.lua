-- stone-wall (lean E2_14)
local NAME = "stone-wall"
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
local H = 19
local function F(u, v) return 12 + 44 * u, 53 - 22 * u - H * v end
local function quad(u0, u1, v0, v1)
  local pts = {}
  for _, p in ipairs{ {u0, v0}, {u1, v0}, {u1, v1}, {u0, v1} } do
    local x, y = F(p[1], p[2]) pts[#pts + 1] = { floor(x + 0.5), floor(y + 0.5) }
  end
  return c:poly(pts)
end
-- ground strip + shadow
c:poly{ {9, 55}, {57, 33}, {61, 35}, {13, 58} }:each(function(x, y) c:put(x, y, X.hash(x, y, 2) > 0.8 and GRASS[3] or GRASS[1]) end)
quad(0, 1, 0, 1):each(function(x, y) c:put(x, y, GREY[1]) end)
local pal = { GREY, WARM, ROSE, GREY, WARM }
local vb = { 0, 0.34, 0.67, 1 }
local seed = 1
for r = 1, 3 do
  local u = -0.06 * ((r * 2) % 3)
  while u < 1 do
    local w = 0.14 + 0.13 * X.hash(r, floor(u * 50), 4)
    local a, b = max(0, u), min(1, u + w)
    if b - a > 0.05 then
      seed = seed + 1
      local pick = pal[1 + floor(X.hash(seed, r, 8) * 5)]
      local m = quad(a + 0.014, b - 0.014, vb[r] + 0.03, vb[r + 1] - 0.03)
      stone(m, pick, seed * 3, 1)
    end
    u = u + w
  end
end
-- cap slabs on top (oblique top face)
local function T(u, k) return 12 + 44 * u - 7 * k, 34 - 22 * u - 3.5 * k end
c:poly{ {12, 34}, {56, 12}, {49, 8}, {5, 30} }:each(function(x, y) c:put(x, y, GREY[1]) end)
local u = 0
local i = 0
while u < 1 do
  local w = 0.2 + 0.1 * X.hash(i, 3, 5)
  local a, b = u + 0.012, min(1, u + w) - 0.012
  local p = {}
  for _, q in ipairs{ {a, 0}, {b, 0}, {b, 1}, {a, 1} } do local x, y = T(q[1], q[2]) p[#p + 1] = { floor(x + 0.5), floor(y + 0.5) } end
  stone(c:poly(p), pal[1 + (i % 3)], 40 + i, -1)
  u = u + w i = i + 1
end
-- moss tufts along the foot
for k = 0, 20 do
  local uu = X.hash(k, 1, 6)
  local x, y = F(uu, 0)
  x, y = floor(x), floor(y)
  c:put(x, y, GRASS[4]) c:put(x, y - 1, GRASS[5]) c:put(x + 1, y, GRASS[3])
end
-- quirk: a little pink flower sprouting from the capstone
for y = 18, 22 do c:put(31, y, GRASS[4]) end
c:put(30, 20, GRASS[5]) c:put(32, 21, GRASS[5])
plus(31, 17, "#f08ab0", "#ffe27a")
G.save(c, NAME)
