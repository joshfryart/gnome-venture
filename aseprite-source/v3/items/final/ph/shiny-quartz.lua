-- shiny-quartz (D15 final, Sonnet). A tall, slim six-sided quartz point leaning out of a small grey rock lump, with a
-- baby point to the right and a tiny one to the left. Each point is a real hex prism: three body facets (lit left,
-- wide pale-core centre, shaded right) under a faceted pyramid tip, bright edge arrises, a dark base where it
-- vanishes into the rock, cool reflected light on the shade side; the rock is per-pixel lit with speckle + cracks.
-- quirk: a hairline rainbow fracture (pink, gold, cyan) is trapped inside the big point, with one bubble beside it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD15_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("shiny-quartz")

local Q = { "#34457f", "#4f6cb0", "#7a9fd8", "#a9c9ee", "#d6eafa", "#f7fcff" }
local QS = "#5a5aa6"      -- cool violet shade
local ROCK = { "#2f2c44", "#46435e", "#615f78", "#7f7d92", "#a09eb0", "#c4c2d0" }
local rtok = { r = { name = "rock" } }
local own = {}
local filled = HP.mask()

-- one hex prism point. bx,by base centre; a lean (rad); hw half-width; L body length; T tip length
local function crystal(name, bx, by, a, hw, L, T, o)
  o = o or {}
  local tok = { r = { name = name } }
  local pxv, pyv = cos(a), sin(a)          -- across
  local dxv, dyv = sin(a), -cos(a)         -- along (up)
  local e1, e2 = -0.42 * hw, 0.38 * hw      -- facet edges (left | centre | right)
  local apx = 0.02 * hw
  local m = HP.mask()
  local U, Vv = {}, {}
  for y = floor(by - L - T - 4), by + 4 do for x = floor(bx - hw - T - 6), floor(bx + hw + T + 6) do
    local rx, ry = x - bx, y - by
    local u = rx * pxv + ry * pyv
    local v = rx * dxv + ry * dyv
    local inside
    if v < 0 then inside = false
    elseif v <= L then inside = abs(u) <= hw
    elseif v <= L + T then
      local f = (v - L) / T
      inside = u >= -hw + (apx + hw) * f * 1.0 - 0.0 and u <= hw + (apx - hw) * f
    else inside = false end
    if inside then m:set(x, y) U[K(x, y)] = u Vv[K(x, y)] = v end
  end end
  -- facet index per pixel
  m:each(function(x, y)
    local k = K(x, y)
    local u, v = U[k], Vv[k]
    local g, t
    if v <= L then
      if u < e1 then g = 1 t = (u + hw) / (e1 + hw)
      elseif u < e2 then g = 2 t = (u - e1) / (e2 - e1)
      else g = 3 t = (u - e2) / (hw - e2) end
      -- tone: vertical sweep gives the long glassy gradient
      local ty = v / L
      local i
      if g == 1 then i = 5 - floor(t * 1.4) + ((ty > 0.7) and -1 or 0)
      elseif g == 2 then
        i = 6
        if t > 0.16 and t < 0.34 then i = 5 end
        if t >= 0.34 and t < 0.62 then i = 6 end
        if t >= 0.62 then i = 5 end
        if ty < 0.18 then i = i - 1 end
        if ty < 0.06 then i = i - 1 end
      else i = 3 - ((t > 0.6) and 1 or 0) + ((ty > 0.5) and 0 or 1) end
      if g == 3 and ty < 0.16 then i = 2 end
      local col = Q[max(1, min(6, i))]
      if g == 3 and i <= 2 then col = (i == 2) and QS or Q[1] end
      m.col = m.col or {}
      m.col[k] = col
    else
      -- pyramid tip: facets split about the ridge lines from the body corners to the apex
      local f = (v - L) / T
      local lx = -hw + (apx + hw) * f
      local rx_ = hw + (apx - hw) * f
      local ridge1 = e1 + (apx - e1) * f
      local ridge2 = e2 + (apx - e2) * f
      local col
      if u < ridge1 then col = Q[5 - ((f > 0.55) and 1 or 0)]
      elseif u < ridge2 then col = (f < 0.5) and Q[6] or Q[5]
      else col = (f < 0.5) and Q[3] or Q[2] end
      if u < ridge2 and u >= ridge1 and f > 0.7 then col = Q[6] end
      m.col = m.col or {}
      m.col[k] = col
    end
  end)
  -- arrises: bright line on the lit edge, soft lines between facets
  m:each(function(x, y)
    local k = K(x, y)
    local u, v = U[k], Vv[k]
    if v <= L then
      if u < -hw + 0.9 then m.col[k] = Q[6] end
      if abs(u - e1) < 0.5 and v < L - 1 then m.col[k] = Q[6] end
      if abs(u - e2) < 0.5 and v < L - 1 then m.col[k] = Q[3] end
      if u > hw - 1.1 then m.col[k] = (v / L > 0.35) and "#7f86c8" or Q[2] end   -- cool reflected light on shade edge
    end
  end)
  m.U, m.V = U, Vv
  m.tok = tok
  return m
end

local A1 = -0.12
local big   = crystal("big",   30, 51, A1, 7.2, 25, 12)
local baby  = crystal("baby",  42, 52, 0.40, 3.9, 9, 6)
local tiny  = crystal("tiny",  20, 53, -0.62, 2.8, 6, 5)
-- paint back to front: tiny, baby, big (big overlaps neighbours at the rock line)
local function paint(m)
  m:each(function(x, y) c:put(x, y, m.col[K(x, y)], m.tok) filled:set(x, y) end)
end
paint(tiny) paint(baby)
-- contact: baby/tiny darker where big overlaps
paint(big)
-- shade ambient where baby meets the big one (cast onto big's right edge)
baby:each(function(x, y) if big:has(x + 1, y) and not baby:has(x + 1, y) then c:put(x + 1, y, QS, big.tok) end end)

-- internal detail on the big point: rainbow fracture + bubble + faint phantom outline
local function bigPt(u, v)
  local a = A1
  return floor(30 + u * cos(a) + v * sin(a) + 0.5), floor(51 + u * sin(a) - v * cos(a) + 0.5)
end
do
  local fr = { { -1.5, 9 }, { -1.0, 10.5 }, { -0.4, 12 }, { 0.3, 13.2 } }
  local cols = { "#ff8fb8", "#ffe27a", "#8fe8e0", "#ffe27a" }
  for i, p in ipairs(fr) do
    local x, y = bigPt(p[1], p[2])
    if big:has(x, y) then c:put(x, y, cols[i], big.tok) end
  end
  -- bubble ring (3x3 hollow) in the centre facet
  local bx, by = bigPt(0.2, 19)
  for _, d in ipairs{ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } } do c:put(bx + d[1], by + d[2], Q[6], big.tok) end
  c:put(bx, by, Q[3], big.tok)
  -- phantom: a ghost point outline inside the base, one tone darker than the facet
  for v = 3, 12 do
    local x, y = bigPt(-2.4 + (v < 6 and 0 or (v - 6) * 0.15), v)
    if big:has(x, y) then c:put(x, y, Q[4], big.tok) end
    x, y = bigPt(2.0 - (v - 3) * 0.1, v)
    if big:has(x, y) then c:put(x, y, Q[3], big.tok) end
  end
  -- sparkle on the lit tip facet
  local sx, sy = bigPt(-2.2, 33)
  c:put(sx, sy, Q[6], big.tok)
  c:put(sx - 1, sy, Q[6], big.tok) c:put(sx + 1, sy, Q[6], big.tok)
  c:put(sx, sy - 1, Q[6], big.tok) c:put(sx, sy + 1, Q[6], big.tok)
  c:put(sx - 1, sy - 1, "#fff4d6", big.tok)
end
-- baby highlight
do local x, y = 40, 45 c:put(x, y, Q[6], baby.tok) end

-- rock lump in front: union of ellipses, rough top edge, lit with pillow normals
local rm = HP.mask()
local function blob(cx, cy, rx, ry) rm:add(c:ellipse(cx, cy, rx, ry)) end
blob(30, 56, 21, 5) blob(18, 55, 8, 5) blob(43, 55, 9, 4.5) blob(31, 53, 12, 3.5)
rm:each(function(x, y) if y < 52 and X.hash(x, y, 3) > 0.55 then rm.s[K(x, y)] = nil end end)
rm:cut(c:rect(0, 58, 63, 63))
rm:each(function(x, y) if y > 57 then rm.s[K(x, y)] = nil end end)
local rn = X.pillow(rm, 4.5)
local rv = X.light(rn, { amb = 0.08, wrap = 0.3 })
-- AO row at the crystal base is added through bias
local bias = {}
rm:each(function(x, y)
  local k = K(x, y)
  local h = X.hash(x // 2, y // 2, 5)
  if h > 0.78 then bias[k] = 1 elseif h < 0.2 then bias[k] = -1 end
end)
X.tone(c, rm, rv, ROCK, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bias, tok = rtok })
-- crack lines + pale chips
for _, p in ipairs{ { 14, 56 }, { 15, 56 }, { 16, 57 }, { 36, 55 }, { 37, 56 }, { 37, 57 }, { 47, 56 }, { 48, 56 } } do
  if rm:has(p[1], p[2]) then c:put(p[1], p[2], ROCK[1], rtok) end
end
for _, p in ipairs{ { 20, 53 }, { 35, 52 }, { 45, 54 }, { 24, 55 } } do
  if rm:has(p[1], p[2]) then c:put(p[1], p[2], ROCK[6], rtok) end
end
-- ambient: dark row on crystal pixels touching the rock top
rm:each(function(x, y)
  if not rm:has(x, y - 1) and filled:has(x, y - 1) then
    c:put(x, y - 1, "#26305e", { r = { name = "ao" } })
    if filled:has(x, y - 2) and X.hash(x, y, 8) > 0.4 then c:put(x, y - 2, Q[1], { r = { name = "ao" } }) end
  end
end)
-- cool glint on rock lit edge
for _, p in ipairs{ { 12, 54 }, { 13, 53 } } do if rm:has(p[1], p[2]) then c:put(p[1], p[2], "#d6d4e6", rtok) end end

A.save(c, "shiny-quartz")
