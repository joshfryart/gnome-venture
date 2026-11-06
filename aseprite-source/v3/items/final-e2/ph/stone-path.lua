-- stone-path (lean E2_14)
local NAME = "stone-path"
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
local stones = {
  { 31, 51, 14, 7, GREY, 1 }, { 21, 39, 10, 6, WARM, 2 }, { 39, 37, 10, 5.5, ROSE, 3 },
  { 28, 27, 9, 5, GREY, 4 }, { 38, 18, 7, 4, WARM, 5 }, { 29, 12, 5, 3, ROSE, 6 },
}
local ground = HP.mask()
local list = {}
for _, s in ipairs(stones) do
  local pts = {}
  for k = 0, 7 do
    local a = k * pi / 4 + 0.2
    local j = 0.82 + 0.22 * X.hash(k, s[6], 11)
    pts[#pts + 1] = { floor(s[1] + cos(a) * s[3] * j + 0.5), floor(s[2] + sin(a) * s[4] * j + 0.5) }
  end
  s.m = c:poly(pts)
  ground:add(s.m:grow(2))
  ground:add(s.m:shift(0, 2):grow(1))
  list[#list + 1] = s
end
ground:each(function(x, y)
  local h = X.hash(x, y, 9)
  c:put(x, y, h > 0.85 and GRASS[3] or (h < 0.2 and GRASS[1] or GRASS[2]))
end)
for _, s in ipairs(list) do
  local side = s.m:shift(0, 2)
  side:each(function(x, y) c:put(x, y, s[5][1]) end)
  side:shift(0, -1):each(function(x, y) if not s.m:has(x, y) then c:put(x, y, s[5][2]) end end)
  stone(s.m, s[5], s[6] * 7, 0)
  -- crack + highlight pit
  local cx, cy = s[1], s[2]
  if s.m:has(cx + 1, cy) then c:put(cx + 1, cy, s[5][2]) c:put(cx + 2, cy + 1, s[5][2]) end
end
-- grass tufts in the gaps and at the edges
ground:each(function(x, y)
  local free = true
  for _, s in ipairs(list) do if s.m:has(x, y) or s.m:has(x, y - 1) then free = false end end
  if free and X.hash(x, y, 21) > 0.8 then c:put(x, y, GRASS[5]) c:put(x, y - 1, GRASS[4]) end
end)
-- quirk: a tiny yellow flower pushing up between two slabs
for y = 29, 32 do c:put(48, y, GRASS[4]) end
plus(48, 28, "#ffe27a", "#ff9a2a")
G.save(c, NAME)
