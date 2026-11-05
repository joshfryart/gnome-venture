-- stage-spice-3 (lean E2_12)
local NAME = "stage-spice-3"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local LEAF = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#a4d86a" }
local SOIL = { "#2a1a1c", "#4a2c26", "#6b4030", "#8c5a3c", "#aa7548", "#c99a64" }
local STEM = { "#2f4a2c", "#436a34", "#5d8a3e", "#7fa84a", "#a2c863", "#cfe68a" }
local BARK = { "#2a1a1c", "#4a2c26", "#6b4030", "#8a5a3a", "#a87848", "#c89a64" }
local CHILI= { "#4a0f1e", "#7a1526", "#a8222c", "#d03a30", "#ec6240", "#ffa070" }
local function soil()
  c:groundShadow(32, 57, 22, 4)
  local m = c:ellipse(32, 52, 20, 6)
  local n = X.pillow(m, 7)
  local tok = { r = { name = "soil" } }
  G.toneN(c, m, n, SOIL, { tok = tok, amb = 0.1, wrap = 0.2 })
  m:each(function(x, y) local h = X.hash(x, y, 5)
    if h > 0.9 then c:put(x, y, SOIL[6], tok) elseif h < 0.07 then c:put(x, y, SOIL[1], tok) end end)
  return m
end
local function leaf(ax, ay, cx, cy, bx, by, w, ramp, veins, fold)
  ramp = ramp or LEAF
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.9 + 0.1)
    return max(0.5, w * sin(pi * u ^ 1.2) ^ 0.75)
  end, { fold = fold or 0.45 })
  local tok = { r = { name = "lf" .. ax .. "_" .. bx .. "_" .. by } }
  G.toneN(c, m, n, ramp, { tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.12, wrap = 0.22 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.14 and t > 0.04 and t < 0.92 then c:put(x, y, s <= 0 and ramp[6] or ramp[2], tok) return end
    for _, vt in ipairs(veins or {}) do
      local d = t * L - (vt + abs(s) * 3.4)
      if d > -0.5 and d < 0.5 and abs(s) > 0.28 and abs(s) < 0.75 then c:put(x, y, s < 0 and ramp[5] or ramp[2], tok) return end
    end
  end)
  return m, n, T, S
end
local function tube(pts, wf, ramp, name)
  local m, n, T = G.tube(pts, wf)
  G.toneN(c, m, n, ramp, { tok = { r = { name = name or "tube" } }, amb = 0.15, wrap = 0.3 })
  return m, n, T
end
local function clump(list, ramp, seed, name)
  local m = HP.mask()
  local sx, sy, cnt = 0, 0, 0
  for _, e in ipairs(list) do m:add(c:ellipse(e[1], e[2], e[3], e[4])) sx = sx + e[1] sy = sy + e[2] cnt = cnt + 1 end
  local cx, cy = sx / cnt, sy / cnt
  local rr = 0 for _, e in ipairs(list) do rr = max(rr, abs(e[1] - cx) + e[3]) end
  local n = X.pillow(m, rr * 0.8)
  local tok = { r = { name = name or "clump" } }
  G.toneN(c, m, n, ramp, { tok = tok, amb = 0.08, wrap = 0.2 })
  m:each(function(x, y) local h = X.hash(x, y, seed)
    local side = (x - cx) + (y - cy)
    if h > 0.86 then if side < 4 then c:put(x, y, ramp[6], tok) else c:put(x, y, ramp[2], tok) end
    elseif h < 0.08 and side > -2 then c:put(x, y, ramp[1], tok) end end)
  return m, n
end
local function chili(pts, r, ramp)
  local m, n, T = G.tube(pts, function(t) return max(0.45, r * sqrt(max(0, 1 - t ^ 2.2)) ) end)
  local tok = { r = { name = "chili" .. pts[1][1] .. "_" .. pts[1][2] } }
  G.toneN(c, m, n, ramp or CHILI, { tok = tok, amb = 0.08, wrap = 0.18 })
  local bx, by = G.specAt(m, n, 30)
  if bx then c:put(bx, by, "#fff0d8", tok) end
  -- cap
  local x0, y0 = pts[1][1], pts[1][2]
  local ct = { r = { name = "cap" } }
  for _, p in ipairs{ {-2,-1,2},{-1,-1,4},{0,-1,3},{1,-1,2},{2,-1,1},{-1,-2,3},{0,-2,4},{0,-3,3},{-1,0,1},{0,0,2},{1,0,1} } do
    c:put(x0 + p[1], y0 + p[2], STEM[p[3] + 1] or STEM[3], ct) end
  return m
end

soil()
tube({ {32,50},{32,40},{31,30},{30,20} }, function(t) return 1.6 - 0.6 * t end, STEM, "stem")
tube({ {31,34},{36,30},{42,28},{47,22} }, function(t) return 1.1 - 0.4 * t end, STEM, "branch")
tube({ {32,40},{26,36},{21,31},{16,28} }, function(t) return 1.1 - 0.4 * t end, STEM, "branch2")
leaf(32, 46, 22, 42, 9, 48, 4.6, LEAF, { 4, 8, 12 })
leaf(32, 44, 43, 41, 56, 47, 4.6, LEAF, { 4, 8, 12 })
leaf(24, 37, 20, 40, 12, 40, 3.2, LEAF, { 3, 7 })
leaf(36, 31, 38, 24, 36, 15, 3.6, LEAF, { 3, 7 })
leaf(30, 22, 24, 18, 18, 17, 3.6, LEAF, { 3, 7 })
-- small green chili pods hanging
chili({ {40, 30}, {40, 36}, {41, 41}, {39, 46} }, 2.0, { "#1f4a2a", "#2f6a34", "#42893f", "#5fa84a", "#86c85e", "#c4ec96" })
chili({ {21, 33}, {21, 38}, {22, 43}, {20, 46} }, 1.8, { "#1f4a2a", "#2f6a34", "#42893f", "#5fa84a", "#86c85e", "#c4ec96" })
-- white 5-petal flowers
local function flower(x, y)
  local t = { r = { name = "fl" .. x } }
  for _, p in ipairs{ {0,-2},{2,-1},{1,2},{-1,2},{-2,-1} } do
    c:put(x + p[1], y + p[2], "#ffffff", t) c:put(x + p[1], y + p[2] + 0, "#f4f0ea", t) end
  for _, p in ipairs{ {0,-1},{1,-1},{-1,-1},{-1,0},{1,0},{0,1} } do c:put(x + p[1], y + p[2], "#e6e0d6", t) end
  c:put(x, y, "#f2c230", t)
  c:put(x - 1, y + 1, "#bdb6ac", t) c:put(x + 1, y + 1, "#bdb6ac", t)
end
flower(48, 20) flower(29, 13) flower(15, 25)
-- quirk: a dewdrop on a leaf
c:put(11, 44, "#cdeeff", { r = { name = "dew" } })
c:put(12, 45, "#7cc0e0", { r = { name = "dew" } })

G.save(c, NAME)
