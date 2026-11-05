-- stage-fruit-3 (lean E2_09)
local NAME = "stage-fruit-3"

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
local PETAL = { "#a8a0b8", "#d0c8d8", "#ece4ec", "#f8f2f2", "#fff6ea", "#fffbf2" }
local YEL   = { "#8a5a14", "#b88420", "#dcab2e", "#f2cc44", "#fae27a", "#fff4b8" }
local GRAIN = { "#6a4a20", "#8e6a2c", "#b8893a", "#d8aa4c", "#ecc668", "#f8e298" }
local DEW   = { "#2a5a8a", "#3f86b8", "#6cb4dc", "#a4dcf0", "#d6f4fc", "#f2fcff" }
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
leaf(28,48, 15,41, 5,47, 5.4, LEAF, {4,8}, "ll")
leaf(36,48, 49,41, 59,47, 5.4, LEAF, {4,8}, "lr")
local fm, fn, idx = ball(32, 35, 13, 12, GFR, "fruit")
-- melon-like stripes
fm:each(function(x, y) local k = K(x, y)
  local u = max(-1, min(1, (x - 32) / 13.0))
  local ang = math.asin(u) / (pi / 7)
  if abs((ang % 1) - 0.5) < 0.11 and idx[k] and idx[k] > 1 then c:put(x, y, GFR[idx[k] - 1], tok("fruit")) end
end)
-- dried blossom scar
c:put(32,46,GFR[1],tok("scar")) c:put(33,46,GFR[2],tok("scar"))
-- calyx and tendril
leaf(32,24, 26,19, 21,22, 2.4, LEAF2, {}, "c1")
leaf(32,24, 38,19, 43,22, 2.4, LEAF2, {}, "c2")
stem({ {32,25}, {32,21}, {33,18}, {33,15} }, 1.2, STEMG, "st")
local tm = c:line({ {33,15}, {36,11}, {41,10}, {44,13}, {42,17}, {39,16}, {39,13} }, 1)
tm:each(function(x, y) c:put(x, y, STEMG[4], tok("tendril")) end)
c:put(36,11,STEMG[5]) c:put(41,10,STEMG[5])
G.save(c, NAME)
