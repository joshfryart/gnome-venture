-- stage-vegetable-3 (lean E2_14)
local NAME = "stage-vegetable-3"
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
local HEAD = { "#1f5a40", "#2f7a4c", "#4a9a58", "#6eba68", "#98d682", "#c8efa0" }
local LG = { "#17402f", "#1f5c3a", "#2f7b43", "#4a9a4a", "#72b95a", "#a2d46e" }
c:groundShadow(32, 57, 21, 3)
local mound = c:ellipse(32, 52, 19, 6)
shade(mound, SOIL, 4, "soil")
mound:each(function(x, y) local h = X.hash(x, y, 5) if h > 0.9 then c:put(x, y, SOIL[5]) elseif h < 0.07 then c:put(x, y, SOIL[1]) end end)
-- back leaves, tall and cupped
leaf(29, 50, 11, 44, 6, 26, 6.5, LG, { 5, 10, 15 }, "bl1")
leaf(35, 50, 53, 44, 58, 26, 6.5, LG, { 5, 10, 15 }, "bl2")
leaf(31, 48, 20, 36, 21, 14, 5, LG, { 5, 10 }, "bl3")
-- the new head: round, ribbed, pale
local head = c:ellipse(32, 33, 12, 12)
shade(head, HEAD, 6, "head", { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.1, wrap = 0.2 })
for _, ln in ipairs{ { {23, 25}, {26, 30}, {29, 36}, {30, 43} }, { {33, 22}, {34, 28}, {36, 34}, {38, 42} }, { {41, 27}, {40, 32}, {42, 38} } } do
  c:line(ln, 1):each(function(x, y) if head:has(x, y) then c:put(x, y, HEAD[2]) if head:has(x + 1, y) and X.hash(x, y, 3) > 0.4 then c:put(x + 1, y, HEAD[5]) end end end)
end
-- front wrapper leaves cupping the head
leaf(30, 53, 16, 52, 10, 38, 7, LG, { 5, 10, 15 }, "fl1")
leaf(34, 53, 48, 52, 54, 38, 7, LG, { 5, 10, 15 }, "fl2")
local hx, hy = G.specAt(head, X.pillow(head, 6), 30)
if hx then c:put(hx, hy, "#f4ffd8") c:put(hx + 1, hy, "#dcf6b0") end
-- quirk: a ladybird on the head
for _, p in ipairs{ {39, 25, "#d8342c"}, {40, 25, "#d8342c"}, {41, 25, "#a8242a"}, {39, 26, "#a8242a"}, {40, 26, "#d8342c"}, {41, 26, "#d8342c"}, {38, 25, "#2b1c26"}, {40, 25, "#2b1c26"} } do c:put(p[1], p[2], p[3]) end
G.save(c, NAME)
