-- stage-fruit-4 (lean E2_09)
local NAME = "stage-fruit-4"

local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local LEAF  = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" }
local LEAF2 = { "#1a4238", "#255f43", "#33804b", "#4f9f52", "#78bd5c", "#a8d877" }
local STEMG = { "#2f5a3a", "#3f7a46", "#5a9a4e", "#80b85a", "#a8d474" }
local DIRT  = { "#2a1a1e", "#4a2c28", "#6e4232", "#8e5a3c", "#ae7848", "#cf9a60" }
local RED   = { "#4a1424", "#7a1e2e", "#a82a36", "#d1403e", "#ea6a4c", "#f8a276" }
local GFR   = { "#24482e", "#356a3a", "#4c8c42", "#6fac4c", "#98c85e", "#c8e384" }
local PINK  = { "#5a1f4a", "#8a2d62", "#b8467a", "#dc6892", "#f090b0", "#fcc4d4" }
local PETAL = { "#a8a0b8", "#d0c8d8", "#ece4ec", "#f8f2f2", "#fffaf0", "#ffffff" }
local YEL   = { "#8a5a14", "#b88420", "#dcab2e", "#f2cc44", "#fae27a", "#fff4b8" }
local GRAIN = { "#6a4a20", "#8e6a2c", "#b8893a", "#d8aa4c", "#ecc668", "#f8e298" }
local DEW   = { "#2a5a8a", "#3f86b8", "#6cb4dc", "#a4dcf0", "#d6f4fc", "#ffffff" }
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function tok(n) return { r = { name = n } } end
local function soil()
  c:groundShadow(32, 57, 21, 3)
  local m = c:ellipse(32, 53, 20, 6)
  local n = X.pillow(m, 6)
  local tk = tok("soil")
  X.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.3 }), DIRT, { cuts = CUTS, tok = tk })
  m:each(function(x, y) local h = X.hash(x, y, 7)
    if h > 0.9 then c:put(x, y, DIRT[2], tk) elseif h < 0.06 then c:put(x, y, DIRT[6], tk) end end)
  return m
end
local function leaf(ax, ay, cx, cy, bx, by, w, ramp, veins, nm)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.9 + 0.1)
    return max(0.5, w * sin(pi * u ^ 1.25) ^ 0.75)
  end, { fold = 0.5 })
  local tk = tok(nm)
  G.toneN(c, m, n, ramp, { tok = tk, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.12, wrap = 0.22 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.14 and t > 0.05 and t < 0.92 then c:put(x, y, s <= 0 and ramp[6] or ramp[2], tk) return end
    for _, vt in ipairs(veins or {}) do
      local d = t * L - (vt + abs(s) * 3.4)
      if d > -0.5 and d < 0.5 and abs(s) > 0.28 and abs(s) < 0.72 then c:put(x, y, s < 0 and ramp[6] or ramp[2], tk) return end
    end
  end)
  return m
end
local function stem(pts, w, ramp, nm)
  local m, n = G.tube(pts, function(t) return w end)
  local tk = tok(nm)
  local sv = X.light(n, { amb = 0.15, wrap = 0.3 })
  m:each(function(x, y) local v = sv[K(x, y)]
    c:put(x, y, v > 0.7 and ramp[5] or v > 0.5 and ramp[4] or v > 0.3 and ramp[3] or ramp[2], tk) end)
  return m
end
local function ballM(m, ramp, nm, r, nospec)
  local n = X.pillow(m, r)
  local tk = tok(nm)
  local idx = X.tone(c, m, X.light(n, { amb = 0.08, wrap = 0.25 }), ramp, { cuts = CUTS, tok = tk })
  if not nospec then
    local bx, by = G.specAt(m, n, 24)
    if bx then c:put(bx, by, "#fffbe8", tk) c:put(bx + 1, by, "#fffbe8", tk) c:put(bx, by + 1, "#fffbe8", tk) end
  end
  return m, n, idx
end
local function ball(cx, cy, rx, ry, ramp, nm, nospec)
  return ballM(c:ellipse(cx, cy, rx, ry), ramp, nm, max(rx, ry), nospec)
end
local function grown(m, n) local g = m:copy() local r = g:grow(n) return r or g end

soil()
leaf(27,50, 16,47, 7,54, 4.4, LEAF, {4}, "ll")
leaf(37,50, 48,47, 57,54, 4.4, LEAF, {4}, "lr")
local orig = c:ellipse(32, 34, 15, 14)
local bite = c:ellipse(47, 28, 5.5, 5.0)
local dimple = c:ellipse(32, 21, 3.5, 2.5)
local fm = orig:copy()
fm:cut(bite) fm:cut(dimple)
ballM(fm, RED, "fruit", 14)
-- flesh rim of the bite
local ring = grown(bite, 1)
local rt = tok("flesh")
ring:each(function(x, y) if orig:has(x, y) and not bite:has(x, y) then
  c:put(x, y, (x - y) > 18 and "#e8c890" or "#fbefc8", rt) end end)
for _, p in ipairs{ {44,31}, {46,33}, {42,28} } do if fm:has(p[1], p[2]) then c:put(p[1], p[2], "#d8a868", rt) end end
-- calyx crown + short stem
leaf(32,23, 25,17, 19,20, 2.8, LEAF2, {}, "c1")
leaf(32,23, 39,17, 45,20, 2.8, LEAF2, {}, "c2")
leaf(32,23, 30,15, 25,11, 2.4, LEAF2, {}, "c3")
stem({ {32,24}, {32,19}, {33,15}, {35,11} }, 1.3, { "#4a2c28", "#6e4232", "#8e5a3c", "#ae7848", "#cf9a60" }, "twig")
G.save(c, NAME)
