-- stirrup-hoe (lean E2_14)
local NAME = "stirrup-hoe"
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
c:groundShadow(24, 57, 14, 2)
local hm, hn, HT = G.tube({ {13, 55}, {22, 45}, {30, 35}, {38, 28} }, function(t) return 1.9 end)
local sv = X.light(hn, { amb = 0.15, wrap = 0.3 })
local idx = X.tone(c, hm, sv, WOOD, { cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = { r = { name = "handle" } } })
hm:each(function(x, y) local k = K(x, y)
  local t = HT[k]
  if t < 0.28 then c:put(x, y, floor(t * 26) % 2 == 0 and "#c8423a" or "#8a2a30") -- red tape grip
  elseif X.hash(x + y, floor((x - y) / 3), 4) > 0.82 then c:put(x, y, WOOD[max(1, idx[k] - 1)]) end
end)
hm:each(function(x, y) if HT[K(x, y)] < 0.28 and not hm:has(x - 1, y - 1) then c:put(x, y, "#e8786a") end end)
-- ferrule neck
local neck = c:line({ {37, 30}, {40, 24} }, 3)
shade(neck, STEEL, 2, "neck", {})
-- stirrup loop
local ring = c:rrect(29, 8, 56, 24, 4)
ring:cut(c:rrect(34, 12, 51, 20, 2))
local rn = X.pillow(ring, 2.5)
X.tone(c, ring, X.light(rn, { amb = 0.1, wrap = 0.2 }), STEEL, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = { r = { name = "ring" } } })
ring:each(function(x, y)
  if y >= 21 and not ring:has(x, y + 1) then c:put(x, y, STEEL[2]) end
  if y >= 21 and ring:has(x, y + 1) and not ring:has(x, y - 1) then c:put(x, y, STEEL[6]) end -- honed cutting edge
  if y <= 10 and y == 8 + 1 and x > 33 and x < 52 and X.hash(x, y, 8) > 0.5 then c:put(x, y, STEEL[6]) end
end)
c:put(31, 11, STEEL[6]) c:put(32, 10, STEEL[6])
-- quirk: a weed seedling caught in the loop
for y = 16, 20 do c:put(43, y, "#4a9a4a") end
for _, p in ipairs{ {42, 15, "#72b95a"}, {41, 15, "#4a9a4a"}, {44, 14, "#a2d46e"}, {45, 14, "#72b95a"}, {43, 14, "#a2d46e"}, {42, 16, "#2f7b43"}, {44, 15, "#2f7b43"} } do c:put(p[1], p[2], p[3]) end
G.save(c, NAME)
