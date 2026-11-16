-- pierce (Opus). Tag "pierce" (Pierce: goes through guard). One long arrow driven clean through a round wooden
-- buckler seen nearly edge-on: fletching and shaft in front at lower-left, the shaft punching in through a cracked
-- star in the planks, the same shaft and a steel bodkin head coming out the far side at upper-right with splinters.
-- The buckler is narrow so the arrow reads as one unbroken line. Material: plank grain + iron rim and boss on the
-- shield, lit round shaft, bevelled steel head with a hot edge, barred feather vanes.
-- quirk: a little green leaf got skewered on the arrow on its way through.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local HP, X, K = O.HP, O.X, O.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = O.new("pierce")

local WOOD  = { "#4a2a26", "#6e3f2c", "#94593a", "#b97a4a", "#d89c62", "#f0c48a" }
local SHAFT = { "#5a3626", "#8a5a36", "#c0884e", "#deae6c", "#f4d496", "#fff0c4" }
local IRON  = { "#2f3150", "#444663", "#62647e", "#8a8ba2", "#b8b8c8", "#e6e6ee" }
local FEA   = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local FEW   = { "#a9a2b4", "#d8d2dc", "#f4efe6" }
local LEAF  = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }

-- arrow line
local AX, AY, BX, BY = 3, 54, 60, 17
local dx, dy = BX - AX, BY - AY
local LEN = sqrt(dx * dx + dy * dy)
local ux, uy = dx / LEN, dy / LEN
local function P(t) return AX + dx * t, AY + dy * t end
-- shield centre on the arrow line
local SCX, SCY = 26, 34
local tS = ((SCX - AX) * ux + (SCY - AY) * uy) / LEN          -- arrow param where it meets the shield

local function shaftMask(t0, t1)
  local x0, y0 = P(t0) local x1, y1 = P(t1)
  local m, n, T, S = X.cyl(x0, y0, x1, y1, function() return 1.45 end)
  return m, n, S
end
local function paintShaft(m, n, S, tok)
  local idx = O.shade(c, m, n, SHAFT, { tok = tok, amb = 0.15, wrap = 0.3 })
  m:each(function(x, y) local s = S[K(x, y)] if s and s < -0.45 then O.set(c, idx, SHAFT, x, y, 5, tok) end end)
  return idx
end

-- 1) exit half of the shaft (behind the shield) + steel head
local exitM, exitN, exitS = shaftMask(tS, 0.85)
local eidx = paintShaft(exitM, exitN, exitS, O.tok("shaftB"))
do
  local tok = O.tok("head")
  local hx, hy = P(0.83)
  -- bodkin/leaf head in the arrow frame
  local m, U, V = O.lmask(hx, hy, math.atan(dy, dx), 12, function(u, v)
    if u < 0 or u > 13 then return false end
    local w = u < 4 and 1.6 + u * 0.75 or 4.6 * (13 - u) / 9
    return abs(v) <= w
  end)
  local n = {}
  m:each(function(x, y) local k = K(x, y)
    -- two bevel planes either side of a centre ridge
    local v = V[k]
    local s = v < 0 and -0.75 or 0.75
    n[k] = { -uy * s, ux * s, 0.66 }
  end)
  local idx = O.shade(c, m, n, IRON, { tok = tok, amb = 0.1, wrap = 0.2 })
  m:each(function(x, y) local k = K(x, y)
    if abs(V[k]) < 0.5 then O.set(c, idx, IRON, x, y, V[k] < 0 and 6 or 3, tok) end    -- ridge: hot edge / dark
  end)
  -- socket band
  m:each(function(x, y) local k = K(x, y) if U[k] < 1.2 then O.set(c, idx, IRON, x, y, 2, tok) end end)
end

-- 2) splinters flying off the exit side
do
  local tok = O.tok("splinter")
  local ex, ey = SCX + 9, SCY - 1
  O.map(c, { "ab..", ".abb" }, ex + 3, ey - 9, { a = WOOD[6], b = WOOD[4] }, tok)
  O.map(c, { "aab" }, ex + 6, ey - 3, { a = WOOD[5], b = WOOD[3] }, tok)
  O.map(c, { "a.", "ab", ".b" }, ex + 4, ey + 3, { a = WOOD[5], b = WOOD[3] }, tok)
end

-- 3) the shield: narrow ellipse face + right-hand thickness
local face, faceN = O.oval(SCX, SCY, 9, 21, 0.12, 1.6)
local edge = O.oval(SCX + 3, SCY + 0.4, 9, 21, 0.12):cut(face)
do
  local tok = O.tok("shieldEdge")
  local idx = O.shade(c, edge, (function() local n = {} edge:each(function(x, y) n[K(x, y)] = { 0.8, 0.2, 0.55 } end) return n end)(), WOOD, { tok = tok, amb = 0.25 })
  -- plank ends show as darker ticks on the edge
  edge:each(function(x, y) if (y % 5) == 0 then O.step(c, idx, WOOD, x, y, -1, tok) end end)
end
local fidx
do
  local tok = O.tok("shieldFace")
  local rim = face:copy():cut(face:shrink(1))
  local wood = face:shrink(1)
  -- planks: vertical boards (squashed), seams every 4 columns along the tilted axis
  local b = {}
  wood:each(function(x, y) local k = K(x, y)
    local xx = x - SCX - (y - SCY) * 0.12
    if floor(xx + 40) % 5 == 0 then b[k] = -2 end
    if O.hash(x, y, 3) > 0.95 then b[k] = (b[k] or 0) - 1 end        -- grain flecks
  end)
  local n = {}
  wood:each(function(x, y) local k = K(x, y) local a = faceN[k] n[k] = { a[1] * 0.5, a[2] * 0.4, 1 } end)
  fidx = O.shade(c, wood, n, WOOD, { tok = tok, bias = b, amb = 0.1, wrap = 0.35 })
  local ridx = O.shade(c, rim, faceN, IRON, { tok = O.tok("rim"), amb = 0.1, wrap = 0.3 })
  -- rivets on the rim
  for _, p in ipairs{ { SCX - 4, SCY - 16 }, { SCX - 6, SCY - 2 }, { SCX - 4, SCY + 12 } } do
    if rim:has(p[1], p[2]) then c:put(p[1], p[2], IRON[6], O.tok("rim")) end
  end
  -- iron boss above the arrow
  local boss, bn = O.oval(SCX - 1, SCY - 9, 3, 4, 0.12)
  local bidx = O.shade(c, boss, bn, IRON, { tok = O.tok("boss"), amb = 0.05, wrap = 0.1 })
  c:put(SCX - 2, SCY - 11, IRON[6], O.tok("boss"))
  -- AO under the boss
  boss:shift(1, 1):each(function(x, y) if not boss:has(x, y) then O.step(c, fidx, WOOD, x, y, -1, tok) end end)
end

-- 4) entry crack star around the hole
local hx, hy = P(tS - 0.03)
hx, hy = floor(hx + .5), floor(hy + .5)
do
  local tok = O.tok("crack")
  for _, d in ipairs{ { -3, -2 }, { -2, -1 }, { 2, -3 }, { 1, -2 }, { -2, 3 }, { -1, 2 }, { 3, 2 }, { 2, 1 }, { 0, -4 }, { 0, -3 } } do
    c:put(hx + d[1], hy + d[2], WOOD[1], tok)
  end
  for _, d in ipairs{ { -3, -3 }, { 1, -4 }, { -3, 2 } } do c:put(hx + d[1], hy + d[2], WOOD[6], tok) end
end

-- 5) front half of the shaft + fletching
local frontM, frontN, frontS = shaftMask(0.04, tS - 0.02)
local sidx = paintShaft(frontM, frontN, frontS, O.tok("shaftF"))
-- AO where the shaft enters
frontM:each(function(x, y) local t = ((x - AX) * ux + (y - AY) * uy) / LEN if t > tS - 0.07 then O.step(c, sidx, SHAFT, x, y, -2, O.tok("shaftF")) end end)
do
  local tok = O.tok("fletch")
  local ang = math.atan(dy, dx)
  local tx, ty = P(0.015)
  for side = -1, 1, 2 do
    local m, U, V = O.lmask(tx, ty, ang, 16, function(u, v)
      local vv = v * side
      if vv < 1.2 or u < 1 or u > 13 then return false end
      local prof = u < 3.5 and 4.6 or 4.6 * (13 - u) / 9.5
      return vv <= 1.2 + prof - (u < 3.5 and 0 or 0) and u - 1 >= (vv - 1.2) * 0.5
    end)
    local n = {}
    m:each(function(x, y) n[K(x, y)] = side < 0 and { -0.3, -0.5, 0.8 } or { 0.4, 0.5, 0.75 } end)
    local idx = {}
    m:each(function(x, y) local k = K(x, y)
      local u = U[k]
      local vv = V[k] * side
      local band = u > 6 and u < 8.2
      local col
      if side < 0 then col = band and FEW[3] or FEA[3] else col = band and FEW[2] or FEA[2] end
      if side < 0 and vv > 4.6 and not band then col = FEA[4] end               -- lit outer edge
      if side > 0 and vv > 4.6 then col = band and FEW[1] or FEA[1] end         -- shade outer edge
      if vv < 1.8 then col = side < 0 and FEA[2] or FEA[1] end                  -- root line along the shaft
      c:put(x, y, col, tok)
    end)
    if side < 0 then local x, y = O.lmask(tx, ty, ang, 1, function() return false end) end
  end
  local nx, ny = P(0.008)
  c:put(floor(nx + .5), floor(ny + .5), SHAFT[2], tok)
end

-- 6) quirk: a leaf skewered on the exit shaft (shaft redrawn over its middle so it is pierced, not stuck on)
do
  local tok = O.tok("leaf")
  local lx, ly = P(0.74)
  lx, ly = floor(lx + .5), floor(ly + .5)
  local ddx, ddy = -0.42, -0.91
  local p0 = { lx - ddx * 2, ly - ddy * 2 }
  local p3 = { lx + ddx * 9, ly + ddy * 9 }
  local m, n, T, S = O.tube({ p0, { p0[1] + ddx * 3 + 1.5, p0[2] + ddy * 3 }, { p3[1] + 1, p3[2] + 2 }, p3 },
    function(t) return 3.0 * math.sin(math.pi * math.min(1, t * 0.97 + 0.03)) ^ 0.9 end)
  local idx = O.shade(c, m, n, { LEAF[1], LEAF[2], LEAF[3], LEAF[4] }, { tok = tok, amb = 0.2, wrap = 0.35, cuts = { 0.2, 0.45, 0.8 } })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.22 and T[k] > 0.12 and T[k] < 0.85 then c:put(x, y, LEAF[2], tok) end
  end)
  -- shaft back on top across the leaf
  local tok2 = O.tok("shaftB")
  exitM:each(function(x, y)
    if abs(x - lx) <= 4 and abs(y - ly) <= 4 and eidx[K(x, y)] then c:put(x, y, SHAFT[eidx[K(x, y)]], tok2) end
  end)
end

O.save(c, "pierce")
