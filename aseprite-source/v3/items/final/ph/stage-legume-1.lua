-- stage-legume-1 (lean E2_10)
local NAME = "stage-legume-1"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 } }
local SOIL = { "#2a1a1c", "#4a2c26", "#6e4430", "#8f5e3c", "#b07c4c", "#cf9c62" }
local GRN  = { "#17382f", "#1f5a3a", "#2f7c3f", "#4c9a44", "#79b852", "#b0d878" }
local GOLD = { "#5a2e1c", "#8a4e22", "#b8782a", "#dca040", "#f0c460", "#fbe49a" }
local PUR  = { "#2c1a4a", "#46298a", "#6a46b0", "#8c6acc", "#b095e4", "#d9c8f6" }
local function soil()
  c:groundShadow(32, 54, 24, 5)
  local m = c:ellipse(32, 50, 22, 8)
  local n = X.pillow(m, 9)
  local tok = { r = { name = "soil" } }
  local idx = X.tone(c, m, X.light(n, { amb = 0.15, wrap = 0.3 }), SOIL, { cuts = CUTS.cuts, tok = tok })
  m:shrink(1):each(function(x, y) local h = X.hash(x, y, 7)
    if h > 0.9 then c:put(x, y, SOIL[6], tok) elseif h < 0.1 then c:put(x, y, SOIL[1], tok) end end)
  return m
end
local function stalk(pts, w0, w1, ramp)
  local m, n, T = G.tube(pts, function(t) return w0 + (w1 - w0) * t end)
  local v = X.light(n, { amb = 0.15, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    local i = v[k] > 0.62 and 4 or (v[k] > 0.4 and 3 or 2)
    c:put(x, y, ramp[i], { r = { name = "st" } }) end)
  return m
end
local function leaf(ax, ay, cx, cy, bx, by, w, ramp, veins, fold)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.9 + 0.1)
    return max(0.5, w * sin(pi * u ^ 1.1) ^ 0.75) end, { fold = fold or 0.4 })
  local tok = { r = { name = "lf" .. ax .. bx .. ay } }
  G.toneN(c, m, n, ramp, { tok = tok, cuts = CUTS.cuts, amb = 0.12, wrap = 0.22 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.12 and t > 0.05 and t < 0.92 then c:put(x, y, s <= 0 and ramp[6] or ramp[2], tok) return end
    for _, vt in ipairs(veins or {}) do
      local d = t * L - (vt + abs(s) * 3)
      if d > -0.5 and d < 0.5 and abs(s) > 0.3 and abs(s) < 0.75 then c:put(x, y, s < 0 and ramp[5] or ramp[2], tok) return end
    end end)
  return m
end
local function ball(cx, cy, rx, ry, ramp, spec)
  local m = c:ellipse(cx, cy, rx, ry)
  local n = X.pillow(m, max(rx, ry))
  local tok = { r = { name = "b" .. cx .. cy } }
  X.tone(c, m, X.light(n, { amb = 0.08, wrap = 0.22 }), ramp, { cuts = CUTS.cuts, tok = tok })
  if spec then local sx, sy = G.specAt(m, n, 20) if sx then c:put(sx, sy, spec, tok) end end
  return m
end

soil()
local BEAN = { "#3a1620", "#6a2430", "#963c3c", "#bc5c4c", "#d88460", "#f2b088" }
-- thick pale-green hook stem arching up and over
local hm = stalk({ {26, 50}, {24, 34}, {26, 14}, {40, 14} }, 2.6, 2.2, { GRN[2], "#4a8a46", "#7ab858", "#a6d878", "#cfee9c", "#e8f8c0" })
-- stem tip bends down to the seed coat (kidney bean) hanging from the hook
local bm = HP.mask()
for y = 12, 34 do for x = 34, 56 do
  local dx, dy = (x - 46) / 6.4, (y - 24) / 9.4
  local bend = 1.6 * (1 - dy * dy)
  local ex = dx + 0.0
  if dx * dx + dy * dy <= 1 and not ((x - 38) ^ 2 + (y - 24) ^ 2 < 9) then bm:set(x, y) end
end end
local bn = X.pillow(bm, 7)
local btok = { r = { name = "bean" } }
X.tone(c, bm, X.light(bn, { amb = 0.08, wrap = 0.22 }), BEAN, { cuts = CUTS.cuts, tok = btok })
local sx, sy = G.specAt(bm, bn, 24) if sx then c:put(sx, sy, "#fff0e0", btok) c:put(sx + 1, sy, "#ffd8b8", btok) end
-- hilum (pale scar) on the inner curve
c:put(40, 22, "#f6ecd0", btok) c:put(40, 23, "#f6ecd0", btok) c:put(40, 24, "#d8c8a0", btok) c:put(40, 25, "#f6ecd0", btok)
-- splitting coat crack at the bottom
c:line({ {46, 30}, {48, 33} }, 1):each(function(x, y) c:put(x, y, BEAN[1], btok) end)
-- two little cotyledon leaves peeking at the soil + first leaf bud
leaf(26, 50, 14, 46, 8, 38, 3.2, GRN, { 4 })
leaf(26, 50, 38, 46, 46, 40, 3.2, GRN, { 4 })
-- quirk: tiny root hair curl and a pebble
ball(52, 50, 2, 1, { "#2a2a30", "#4a4a54", "#6a6a74", "#8c8c96", "#aeaeb8", "#d0d0d8" }, "#eeeef4")

G.save(c, NAME)
