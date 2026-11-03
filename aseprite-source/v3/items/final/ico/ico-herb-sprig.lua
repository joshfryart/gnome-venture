-- ico-herb-sprig (final pass, Opus). A cut sprig of sweet basil leaning to the right: slim curved stem (3 px, lit
-- left edge, pale cut end with a green core ring), three opposite pairs of broad pointed leaves plus a top bud cluster.
-- Leaves: per-pixel light with a folded (V) midrib so the two halves take different light, carved midrib + side veins,
-- waxy specular on the upper leaves, AO where each leaf joins the stem. quirk: a caterpillar has nibbled a round bite
-- out of the lower right leaf.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_4.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, max, min, abs, sqrt, cos, sin = math.floor, math.max, math.min, math.abs, math.sqrt, math.cos, math.sin
local c = A.new("ico-herb-sprig")
local LEAF = { "#163c34", "#1f5a3e", "#2c7a44", "#44a04a", "#6cc256", "#a8e070" }
local STEM = { "#24543e", "#3f8048", "#6aa856", "#a6d47a" }
local SPEC = "#e8ffc0"
local CR = A.CREAM

-- stem: quadratic-ish bezier from the cut end (lower left) up to the bud (top)
local P = { { 24, 55 }, { 28, 43 }, { 31, 28 }, { 32, 15 } }
local function bez(t) return G.bez(P, t) end
local stem = HP.mask()
local SS = {}
for i = 0, 200 do
  local t = i / 200
  local x, y = bez(t)
  local w = t < 0.85 and 1 or 0.5
  for dx = -1, 1 do
    if abs(dx) <= w then
      local px, py = floor(x + dx + .5), floor(y + .5)
      stem:set(px, py)
      if not SS[K(px, py)] then SS[K(px, py)] = { t = t, s = dx } end
    end
  end
end
local stT = A.tok("stem")

-- leaves
local leaves = {
  -- t on stem, side (-1 left / +1 right), length, width, angle tweak
  { 0.22, -1, 16, 5.0, -0.1 },
  { 0.24,  1, 15, 5.0, 0.0, bite = true },
  { 0.52, -1, 13.5, 4.4, -0.05 },
  { 0.54,  1, 13, 4.4, 0.05 },
  { 0.79, -1, 10, 3.2, 0.15 },
  { 0.81,  1, 9.5, 3.2, 0.2 },
}
local lfT = A.tok("leaf")
local allLeaf = HP.mask()
local painted = {}
local function leaf(L)
  local t, side, len, wid, tw = L[1], L[2], L[3], L[4], L[5]
  local x0, y0 = bez(t)
  local x1, y1 = bez(min(1, t + 0.02))
  local tx, ty = x1 - x0, y1 - y0
  local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  -- leaf axis: rotate stem tangent outward and up
  local ang = side * (1.3 - tw)
  local ux, uy = G.rot(tx, ty, ang)
  local fr = A.frame(x0 + .5, y0 + .5, ux, uy)
  local m = A.pred(floor(x0 - len - 2), floor(y0 - len - 2), floor(x0 + len + 2), floor(y0 + len + 2), function(x, y)
    local u, v = fr(x + .5, y + .5)
    if u < 1 or u > len then return false end
    local f = (u - 1) / (len - 1)
    -- broad near the base third, drawn to a point
    local w = wid * (sin(math.pi * f ^ 0.7)) ^ 1.1
    return abs(v) <= w
  end)
  if L.bite then
    local u0, v0 = len * 0.62, wid * 0.85
    local bx, by = x0 + ux * u0 - uy * v0, y0 + uy * u0 + ux * v0
    m:cut(A.ell(bx - .5, by - .5, 2.3, 2.3))
  end
  m:cut(stem)
  -- folded normals: each half tilts away from the midrib, plus a lengthwise dome
  local n = {}
  m:each(function(x, y)
    local u, v = fr(x + .5, y + .5)
    local f = (u - 1) / (len - 1)
    local w = max(0.8, wid * (sin(math.pi * max(0.02, f) ^ 0.7)) ^ 1.1)
    local q = v / w
    local fold = (q > 0 and 1 or -1) * 0.22 + q * 0.6
    local along = (f - 0.45) * 0.7
    local vx, vy = -uy, ux
    local nx, ny = vx * fold + ux * along, vy * fold + uy * along
    n[K(x, y)] = { G.norm(nx, ny, 1.1) }
  end)
  local bias = {}
  m:each(function(x, y) local u = fr(x + .5, y + .5) if u < 2.6 then bias[K(x, y)] = -1 end end)
  local idx = A.shade(c, m, n, LEAF, { tok = lfT, bias = bias, amb = 0.1, wrap = 0.3, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 } })
  -- carved midrib (dark) and side veins (one step darker), lit edge of the midrib toward the light
  m:each(function(x, y)
    local u, v = fr(x + .5, y + .5)
    local k = K(x, y)
    if abs(v) < 0.6 and u < len - 2 then
      c:put(x, y, (idx[k] or 3) >= 4 and LEAF[2] or LEAF[5], lfT)
    else
      for vi = 1, 3 do
        local u0 = 1 + vi * (len / 4.2)
        local d = (u - u0) - abs(v) * 0.9
        if abs(d) < 0.5 and abs(v) > 1.1 and abs(v) < wid * 0.75 then A.step(c, idx, LEAF, x, y, -1, lfT) end
      end
    end
  end)
  -- bitten edge: pale torn rim
  if L.bite then
    m:edge():each(function(x, y)
      local u0, v0 = len * 0.62, wid * 0.85
      local bx, by = x0 + ux * u0 - uy * v0, y0 + uy * u0 + ux * v0
      if (x - bx) ^ 2 + (y - by) ^ 2 < 14 then c:put(x, y, "#c8e890", lfT) end
    end)
  end
  allLeaf:add(m)
  return m, idx, fr
end
local L = {}
for i, l in ipairs(leaves) do L[i] = { leaf(l) } end

-- top bud: two small folded leaves cupping a tip
local bud = A.ell(32, 13, 2.2, 3.0)
bud:add(c:poly{ { 30, 12 }, { 32, 7 }, { 34, 12 } })
local bn = X.pillow(bud, 2)
A.shade(c, bud, bn, LEAF, { tok = lfT, amb = 0.15, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
c:put(32, 11, LEAF[2], lfT) c:put(32, 12, LEAF[2], lfT) c:put(32, 13, LEAF[2], lfT) c:put(32, 14, LEAF[2], lfT)
c:put(31, 10, LEAF[6], lfT)

-- stem paint (over leaf bases): lit left column, shade right
stem:each(function(x, y)
  local s = SS[K(x, y)]
  if not s then return end
  local col = s.s < 0 and STEM[3] or (s.s > 0 and STEM[1] or STEM[2])
  if s.t > 0.85 and s.s == 0 then col = STEM[2] end
  c:put(x, y, col, stT)
end)
-- nodes: dark ring where each pair leaves the stem
for _, t in ipairs({ 0.23, 0.53, 0.8 }) do
  local x, y = bez(t)
  for dx = -1, 1 do c:put(floor(x + dx + .5), floor(y + .5), STEM[1], stT) end
  c:put(floor(x - 1 + .5), floor(y - 1 + .5), STEM[4], stT)
end
-- cut end: pale disc with a green core
c:put(23, 55, STEM[4], stT) c:put(24, 55, CR, stT) c:put(25, 55, STEM[3], stT)
c:put(24, 56, STEM[2], stT) c:put(23, 56, STEM[3], stT) c:put(25, 56, STEM[1], stT)

-- waxy speculars on the two upper-left leaves
for _, p in ipairs({ { 1, 6.5, 1.6 }, { 3, 5.5, 1.4 } }) do
  local m, idx, fr = L[p[1]][1], L[p[1]][2], L[p[1]][3]
  local hit = 0
  m:each(function(x, y) local u, v = fr(x + .5, y + .5)
    if abs(u - p[2]) < 1.5 and abs(v - p[3]) < 0.5 then c:put(x, y, LEAF[6], lfT) end
    if abs(u - p[2] + 0.4) < 0.5 and abs(v - p[3]) < 0.5 then c:put(x, y, SPEC, lfT) end
  end)
end

A.save(c, "ico-herb-sprig")
