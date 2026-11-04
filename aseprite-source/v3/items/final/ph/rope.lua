-- rope (final, Opus-style single pass). A hemp rope coiled in a rising spiral: one full lap flat on the floor, a
-- second lap stacked above it that breaks out into a long tail swinging round the right and down; a red thread
-- whipping binds the tail just before the end, which is unlaid into splayed pale strands.
-- Material: 5 px twisted rope, per-pixel cylinder light (6-tone hemp), diagonal strand grooves and lit ridges,
-- contact shadow where the upper lap and the tail cross the lower lap, loose fibres, whipping thread with its own
-- bevel, a bright ridge catch-light.
-- quirk: the end is unravelled, one stray strand curling away.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, ceil, sqrt, max, min, abs, sin, cos, pi = math.floor, math.ceil, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "rope" }
local HM = A.HEMP
local H = A.hash
local OY = -1

c:groundShadow(29, 47, 19, 3)

local function ring(a0, a1, f)
  local pts = {}
  local n = ceil(abs(a1 - a0) / 0.03)
  for i = 0, n do
    local fr = i / n
    local a = a0 + (a1 - a0) * fr
    local cx, cy, rx, ry = f(fr)
    pts[#pts + 1] = { cx + rx * cos(a), cy + ry * sin(a) + OY }
  end
  return pts
end
local function smooth(t) t = max(0, min(1, t)) return t * t * (3 - 2 * t) end
local A0 = -1.0
local lap1 = ring(A0, A0 - 2 * pi, function() return 28, 33, 18, 12 end)
local lap2 = ring(A0 - 2 * pi, 1.2 - 4 * pi, function(fr)
  local t = smooth(fr / 0.5)
  return 28, 33 - 5 * t, 18 - 4.5 * t, 12 - 3.5 * t
end)
local tailPts = A.poly(A.curve({ { 32.9, 35.9 + OY }, { 41, 34 + OY }, { 53, 38 + OY }, { 48, 51 + OY } }, 80), 0.5)

local W = 2.5
local m1, n1, U1, S1 = A.sweep(lap1, function() return W end)
local m2, n2, U2, S2 = A.sweep(lap2, function() return W end)
local mt, nt, Ut, St, totT = A.sweep(tailPts, function() return W end)

local idx = {}
local function paint(m, n, U, S, o)
  local i2 = A.hempPaint(c, m, n, U, S, HM, o)
  for k, v in pairs(i2) do idx[k] = v end
end
local function shadow(over, region)
  -- darken already-painted rope under a part lying on top (offset down-right)
  local sh = over:shift(1, 2):grow(1):cut(over)
  sh:each(function(x, y)
    if region:has(x, y) then
      local k = K(x, y) local i = idx[k]
      if i then i = A.clamp(i - 2) idx[k] = i c:put(x, y, HM[i]) end
    end
  end)
end

paint(m1, n1, U1, S1, { per = 3.0, k = 0.9 })
shadow(m2, m1)
paint(m2, n2, U2, S2, { per = 3.0, k = 0.9 })
shadow(mt, m1:copy():add(m2))
paint(mt, nt, Ut, St, { per = 3.0, k = 0.9 })

-- catch-light on the lit ridges (upper-left of each lap)
for _, p in ipairs{ { 20, 20 + OY + 1 }, { 21, 20 + OY + 1 } } do end
local function catch(m, x0, y0, x1, y1)
  local best, bx, by = -1, nil, nil
  m:each(function(x, y)
    if x >= x0 and x <= x1 and y >= y0 and y <= y1 and (idx[K(x, y)] or 0) >= 6 then
      local sc = -(x + y)
      if sc > best or best < 0 then best, bx, by = sc, x, y end
    end
  end)
  if bx then c:px(bx, by, "#fff4d0") c:px(bx + 1, by, "#fff4d0") end
end
catch(m2, 14, 12, 30, 28)
catch(m1, 8, 20, 22, 36)

-- whipping thread near the tail end
local ER = A.EMBER
tailPts[#tailPts].u = totT
mt:each(function(x, y)
  local k = K(x, y)
  local u = Ut[k]
  if u > totT - 9.0 and u < totT - 5.0 then
    local s = St[k]
    local i = s < -0.45 and 5 or (s < 0.1 and 4 or (s < 0.55 and 3 or 2))
    if (u / 1.25) % 1 < 0.28 then i = i - 1 end
    c:put(x, y, ER[A.clamp(i)])
  end
end)
-- thread tails hanging from the whipping
local E = tailPts[#tailPts]
mt:each(function(x, y)
  local k = K(x, y)
  if Ut[k] > totT - 5.0 and Ut[k] < totT - 0.2 then
    -- slightly darker raw rope below the whipping
    local i = idx[k]
    if i then c:put(x, y, HM[A.clamp(i - 1)]) end
  end
end)

-- unravelled end: splayed strands
local ex, ey = E[1], E[2]
local bx, by = E.tx, E.ty
local base = math.atan(by, bx)
local tips = { "#fff0c4", "#f8e6aa", "#fff6dc" }
for k = -3, 3 do
  local ang = base + k * 0.22
  local ox, oy = ex + (-by) * k * 0.62, ey + bx * k * 0.62
  local len = 4 + (abs(k) % 2) + (k == 2 and 1 or 0)
  local x1, y1 = ox + cos(ang) * len, oy + sin(ang) * len
  A.line(c, { { floor(ox + 0.5), floor(oy + 0.5) }, { floor(x1 + 0.5), floor(y1 + 0.5) } }, HM[k < 0 and 5 or (k == 0 and 4 or 3)])
  c:px(floor(x1 + 0.5), floor(y1 + 0.5), tips[(k % 3) + 1])
end
-- one stray strand curls away
local sx, sy = floor(ex + 0.5) + 4, floor(ey + 0.5) + 3
for _, p in ipairs{ { 0, 0 }, { 1, 0 }, { 2, -1 }, { 3, -1 }, { 4, -2 }, { 4, -3 } } do c:px(sx + p[1], sy + p[2], HM[5]) end
c:px(sx + 4, sy - 4, tips[1])

-- loose fibres along the edges
local all = m1:copy():add(m2):add(mt)
all:edge():each(function(x, y)
  if H(x, y, 31) > 0.955 then
    for _, d in ipairs{ { 0, -1 }, { -1, 0 }, { 0, 1 }, { 1, 0 } } do
      if not all:has(x + d[1], y + d[2]) and y + d[2] < 53 and (x + d[1]) > 6 and (x + d[1]) < 57 then c:px(x + d[1], y + d[2], HM[4]) break end
    end
  end
end)

A.fin(c, "rope")
