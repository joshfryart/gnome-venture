-- starlight-hammock (lean E2_14)
local NAME = "starlight-hammock"
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
local BLUE = { "#141c4a", "#1f2d78", "#2f46a4", "#4766c8", "#6c8ce0", "#a2bcf4" }
local ROPE = { "#6a4c32", "#a47c52", "#d2aa74" }
c:groundShadow(32, 57, 25, 3)
for _, px in ipairs{ 10, 48 } do
  local post = c:rrect(px, 8, px + 5, 54, 2)
  shade(post, WOOD, 3, "post" .. px, { amb = 0.1, wrap = 0.15 })
  post:each(function(x, y) if X.hash(x, floor(y / 4), px) > 0.72 and x > px then c:put(x, y, WOOD[2]) end end)
  c:rect(px, 52, px + 5, 54):each(function(x, y) c:put(x, y, WOOD[1]) end)
  c:put(px + 1, 10, WOOD[6]) c:put(px + 1, 11, WOOD[5])
end
-- cloth
local m = HP.mask()
for x = 16, 47 do
  local t = (x - 16) / 31
  local sag = 4 * t * (1 - t)
  local y0 = floor(17 + 16 * sag)
  local y1 = floor(y0 + 2.5 + 6.5 * sag)
  for y = y0, y1 do m:set(x, y) end
end
local n = X.pillow(m, 4)
local idx = X.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), BLUE, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = { r = { name = "cloth" } } })
m:each(function(x, y) if (x + y) % 4 == 0 then c:put(x, y, BLUE[max(1, idx[K(x, y)] - 1)]) end end)
for _, p in ipairs{ {23, 29}, {29, 36}, {37, 36}, {41, 28} } do
  if m:has(p[1], p[2]) and m:has(p[1] - 1, p[2]) and m:has(p[1], p[2] + 1) and m:has(p[1], p[2] - 1) and m:has(p[1] + 1, p[2]) then plus(p[1], p[2], "#ffe27a", "#fff6c8") end
end
-- rope wraps where cloth is lashed to posts
for _, px in ipairs{ 10, 48 } do
  for i = 0, 3 do
    local y = 15 + i * 2
    c:rect(px, y, px + 5, y):each(function(x, yy) c:put(x, yy, (x + i) % 2 == 0 and ROPE[3] or ROPE[2]) end)
  end
  c:rect(px, 22, px + 5, 22):each(function(x, yy) c:put(x, yy, ROPE[1]) end)
end
-- quirk: a sleepy fallen star dangling below on a thread
for y = 41, 44 do c:put(32, y, ROPE[2]) end
local star = c:poly{ {32, 45}, {34, 48}, {38, 48}, {35, 51}, {36, 55}, {32, 53}, {28, 55}, {29, 51}, {26, 48}, {30, 48} }
shade(star, { "#a8541c", "#d8821e", "#f0b028", "#ffd84a", "#ffec88", "#fff8d0" }, 3, "star", {})
c:put(31, 49, "#fffbe0") c:put(32, 49, "#fffbe0")
G.save(c, NAME)
