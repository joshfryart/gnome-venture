-- rhubarb (final D12, Sonnet high). A tied bunch: three slim ridged stalks (deep red at the cut ends, streaking up into
-- green) crossing at a twine tie, pale pink-cream cut faces with vascular dots, topped by one big puckered leaf blade
-- (heart-notched, crinkled rim, red-to-pale veins fanning from the stalk crown, cool lower rim, contact shadow on the stalk tops).
-- quirk: a little ladybird is walking across the leaf.
local NAME = "rhubarb"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = G.new2(NAME)
local RED  = { "#5e1634", "#8e2444", "#c23458", "#e0506a", "#f28aa0", "#ffc4cc" }
local GRN  = { "#2a4e34", "#3f6e3c", "#5f8f46", "#86b45a", "#aed07c", "#d8eaa6" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local FLESH = { "#9a8a58", "#c4b878", "#dcd490", "#eceaa8", "#f8f4c4", "#fffbe0" }
local TWINE = { "#6a4a22", "#a07a34", "#cfa04a", "#ecc86a", "#f8e49a" }
local VEIN, COOL = "#d2eaa0", "#3c6f74"
local CUTS = { 0.26, 0.44, 0.6, 0.75, 0.88 }
local function quant(v) local i = 1 for j, t in ipairs(CUTS) do if v >= t then i = j + 1 end end return i end

-- ---------- geometry
local P = {
  L = { { 17, 54 }, { 27, 46 }, { 28, 41 }, { 24, 30 } },
  R = { { 47, 54 }, { 37, 46 }, { 36, 41 }, { 40, 30 } },
  C = { { 32, 55 }, { 31, 48 }, { 33, 40 }, { 32, 29 } },
}
local S = {}
for name, p in pairs(P) do
  local m, n, T, SS = G.tube(p, function(t) return 1.9 - 0.25 * t end)
  S[name] = { m = m, n = n, T = T, S = SS, p = p }
end
-- leaf mask: rounded heart with a crinkled rim, V notch at the base where the stalks enter
local lm, lr = HP.mask(), {}
local CX, CY = 32, 19.5
for y = 3, 36 do for x = 8, 56 do
  local dx, dy = (x - CX) / 19.6, (y - CY) / 12.6
  local a = atan(dy, dx)
  local wob = 1 + 0.05 * sin(a * 13) + 0.035 * sin(a * 7 + 1.2) + 0.025 * sin(a * 21)
  if dx*dx + dy*dy <= wob * wob then
    local notch = (y > 25.5) and abs(x - CX) < (y - 25.5) * 0.75 + 0.4
    if not notch then lm:set(x, y) lr[K(x, y)] = { a = a, r = sqrt((x - CX)^2 + (y - CY)^2) } end
  end
end end
local leafAll = lm

-- ---------- stalks (L and R behind, C in front), contact shadows from the leaf and from C
local function paintStalk(s, bias)
  local tok = { r = { name = "st" .. tostring(s) } }
  local v = X.light(s.n, { amb = 0.1, wrap = 0.25 })
  s.m:each(function(x, y)
    local k = K(x, y)
    local i = quant(v[k])
    local t, sd = s.T[k], s.S[k]
    if abs(sd + 0.34) < 0.1 and t > 0.03 and t < 0.97 then i = i - 1 end            -- groove
    if abs(sd - 0.3) < 0.1 and t > 0.03 and t < 0.97 then i = i - 1 end            -- groove
    if abs(sd + 0.62) < 0.1 and t > 0.06 and t < 0.92 then i = i + 1 end           -- rib highlight
    if bias[k] then i = i + bias[k] end
    i = max(1, min(6, i))
    local col = floor((sd + 1) * 3.2)
    local tg = 0.58 + 0.2 * X.hash(col, 3, 9) + 0.06 * (s == S.C and 1 or 0)
    c:put(x, y, (t > tg) and GRN[i] or RED[i], tok)
  end)
end
local bL, bR, bC = {}, {}, {}
X.ao(bL, S.L.m, S.C.m, 1, -1) X.ao(bR, S.R.m, S.C.m, 1, -1)
for _, nm in ipairs{ "L", "R", "C" } do
  local b = nm == "L" and bL or nm == "R" and bR or bC
  X.ao(b, S[nm].m, leafAll, 2, -1)
end
paintStalk(S.L, bL) paintStalk(S.R, bR)
-- cut faces (pale flesh, red skin ring, vascular dots)
local function cutFace(s)
  local p = s.p
  local tx, ty = p[2][1] - p[1][1], p[2][2] - p[1][2]
  local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
  local px, py = -ty, tx
  local cx, cy = p[1][1] - tx * 0.4, p[1][2] - ty * 0.4
  local m = G.rell(cx, cy, px, py, 2.3, 1.5)
  G.toneN(c, m, X.pillow(m, 1.6), FLESH, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.15, wrap = 0.3 })
  m:edge():each(function(x, y) c:px(x, y, RED[2]) end)
  c:px(floor(cx + px * 0.9 + .5), floor(cy + py * 0.9 + .5), RED[4]) c:px(floor(cx - px * 0.9 + .5), floor(cy - py * 0.9 + .5), RED[4])
  c:px(floor(cx + .5), floor(cy + .5) - 0, FLESH[2])
  c:px(floor(cx - px * 1.3 - .5), floor(cy - py * 1.3 - .5), FLESH[6])
end
cutFace(S.L) cutFace(S.R)
paintStalk(S.C, bC) cutFace(S.C)

-- ---------- twine tie where the stalks cross
do
  local all = S.L.m:copy():add(S.R.m):add(S.C.m)
  local band = HP.mask()
  for y = 43, 47 do for x = 22, 40 do
    if all:has(x, y) or all:has(x - 1, y) and all:has(x + 1, y) then band:set(x, y) end
  end end
  band:each(function(x, y)
    local i
    if y == 43 then i = 4 elseif y == 47 then i = 1 elseif y == 46 then i = 2 else i = ((x + y) % 3 == 0) and 2 or 3 end
    if y == 44 and (x + y) % 3 == 1 then i = 4 end
    c:put(x, y, TWINE[i])
  end)
  -- knot and two loose tails (right side)
  for _, q in ipairs{ { 37, 44, 3 }, { 38, 44, 4 }, { 37, 45, 2 }, { 38, 45, 3 }, { 38, 46, 2 } } do c:put(q[1], q[2], TWINE[q[3]]) end
  for _, q in ipairs{ { 39, 46, 3 }, { 39, 47, 2 }, { 40, 48, 2 }, { 40, 49, 1 }, { 38, 47, 2 }, { 37, 48, 2 }, { 37, 49, 1 } } do c:put(q[1], q[2], TWINE[q[3]]) end
end

-- ---------- leaf: pillow light + pucker ridges, veins, rim
do
  local tok = { r = { name = "leaf" } }
  local n = X.pillow(lm, 6)
  local v = X.light(n, { amb = 0.14, wrap = 0.3 })
  local bias = {}
  lm:each(function(x, y)
    local k = K(x, y) local q = lr[k]
    local rip = sin(q.a * 9 + q.r * 0.22)
    if q.r > 6 then if rip > 0.6 then bias[k] = 1 elseif rip < -0.55 then bias[k] = -1 end end
  end)
  -- shade on the leaf where it covers the stalk crown
  for _, nm in ipairs{ "L", "C", "R" } do X.ao(bias, lm, S[nm].m, 1, -1) end
  local idx = X.tone(c, lm, v, LEAF, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bias, tok = tok })
  -- veins radiating from the crown (32, 27)
  local vx, vy = 32, 27.2
  for ai, deg in ipairs{ -80, -54, -28, 0, 28, 54, 80 } do
    local a = (deg - 90) * pi / 180
    local ux, uy = cos(a), sin(a)
    local R = 0
    while R < 30 do
      local x, y = floor(vx + ux * R + .5), floor(vy + uy * R + .5)
      if lm:has(x, y) then
        local lit = ux * 0.7 + uy * 0.7 < 0.12
        if R < 10 then c:put(x, y, lit and RED[5] or RED[3], tok)
        else c:put(x, y, lit and VEIN or LEAF[3], tok) end
        if R >= 10 and lm:has(x + 1, y + 1) then local k2 = K(x + 1, y + 1) if not lm:has(x + 2, y + 2) or true then
          -- dark companion line below-right gives the vein a raised look
          if not (abs(deg) < 1) then c:put(x + 1, y, LEAF[2], tok) else c:put(x + 1, y, LEAF[2], tok) end end end
      end
      R = R + 0.5
    end
    -- small side veins from the main veins
    for _, r0 in ipairs{ 13, 18 } do
      for _, side in ipairs{ -1, 1 } do
        local bx, by = vx + ux * r0, vy + uy * r0
        local sx, sy = G.rot(ux, uy, side * 0.7)
        for j = 1, 3 do
          local x, y = floor(bx + sx * j + .5), floor(by + sy * j + .5)
          if lm:has(x, y) and lm:has(x + 1, y + 1) then c:put(x, y, side < 0 and LEAF[5] or LEAF[2], tok) end
        end
      end
    end
  end
  -- cool bounce on the lower-right rim
  lm:edge():each(function(x, y) local k = K(x, y) local q = lr[k]
    if q.a > 0.1 and q.a < 1.6 and q.r > 11 then c:put(x, y, "#3c7a78", tok) end end)
  -- waxy specular on the upper-left lobe
  c:px(22, 12, LEAF[6]) c:px(23, 12, LEAF[6]) c:px(21, 13, LEAF[5])
end

-- ---------- quirk: ladybird crossing the leaf
do
  local x, y = 38, 12
  local RB = { "#8e1c24", "#c42c2c", "#e8503c", "#ff9a7a" }
  local INK = "#2b1c26"
  local rows = {
    { 1, 1, 1, 0 },   -- placeholder shape handled below
  }
  local body = { { 1, 0 }, { 2, 0 }, { 3, 0 }, { 0, 1 }, { 1, 1 }, { 2, 1 }, { 3, 1 }, { 4, 1 }, { 0, 2 }, { 1, 2 }, { 2, 2 }, { 3, 2 }, { 4, 2 }, { 1, 3 }, { 2, 3 }, { 3, 3 } }
  for _, q in ipairs(body) do c:px(x + q[1], y + q[2], q[2] == 3 and RB[1] or RB[2]) end
  c:px(x + 1, y, RB[3]) c:px(x + 2, y, RB[3]) c:px(x + 1, y + 1, INK) c:px(x + 3, y + 1, INK) c:px(x + 2, y + 2, INK) c:px(x, y + 2, RB[1])
  c:px(x + 2, y + 1, RB[2]) c:px(x + 1, y + 2, RB[2])
  c:px(x + 2, y - 1, INK) c:px(x + 1, y - 2, INK) c:px(x + 3, y - 2, INK)
  c:px(x - 1, y + 3, INK) c:px(x + 5, y + 3, INK) c:px(x + 5, y + 1, INK)
end
G.save2(c, NAME)
