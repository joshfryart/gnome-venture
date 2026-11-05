-- stage-vegetable-4 (lean E2_14)
local NAME = "stage-vegetable-4"
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
local MEL = { "#12452f", "#1a6a40", "#2a8a4a", "#48aa56", "#76c868", "#b4e888" }
local STR = { "#0e3626", "#14502f", "#1d6e3a", "#2f8a45", "#52a858", "#8cc878" }
local LG = { "#17402f", "#1f5c3a", "#2f7b43", "#4a9a4a", "#72b95a", "#a2d46e" }
local VINE = { "#2a4a24", "#3f6a2c", "#5c8a38", "#82aa48", "#aac860" }
c:groundShadow(32, 57, 22, 3)
local mound = c:ellipse(32, 53, 20, 5)
shade(mound, SOIL, 4, "soil")
mound:each(function(x, y) local h = X.hash(x, y, 6) if h > 0.9 then c:put(x, y, SOIL[5]) elseif h < 0.07 then c:put(x, y, SOIL[1]) end end)
leaf(22, 52, 9, 50, 6, 36, 5, LG, { 5, 10 }, "bl1")
leaf(42, 52, 55, 50, 58, 36, 5, LG, { 5, 10 }, "bl2")
local body = c:ellipse(32, 37, 17, 15)
local n = X.pillow(body, 7)
local idx = X.tone(c, body, X.light(n, { amb = 0.08, wrap = 0.2 }), MEL, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = { r = { name = "mel" } } })
body:each(function(x, y)
  local phi = math.atan(x - 32, 37 - y + 1)
  local s = sin(phi * 5 + 0.3)
  local k = K(x, y)
  if s > 0.15 then c:put(x, y, STR[max(1, min(6, idx[k]))], { r = { name = "mel" } }) end
end)
-- ripe field spot, pale yellow, low left
for _, p in ipairs{ {20, 44}, {21, 45}, {22, 45}, {21, 44}, {22, 46}, {23, 46}, {20, 43} } do if body:has(p[1], p[2]) then c:put(p[1], p[2], p[1] < 22 and "#f0d878" or "#d8b850") end end
local hx, hy = G.specAt(body, n, 40)
if hx then c:put(hx, hy, "#f4ffd8") c:put(hx + 1, hy, "#f4ffd8") c:put(hx, hy + 1, "#dcf6b0") end
-- stalk + curl tendril
local sm, sn = G.tube({ {32, 24}, {32, 18}, {38, 14}, {42, 18} }, function(t) return 1.6 - 0.5 * t end)
shade(sm, VINE, 2, "stalk", {})
for _, p in ipairs{ {43, 20}, {44, 19}, {44, 18}, {43, 17} } do c:put(p[1], p[2], VINE[3]) end
c:put(41, 17, VINE[4])
-- quirk: tiny yellow flower still clinging to the tendril
plus(45, 22, "#ffd84a", "#ff9a2a")
G.save(c, NAME)
