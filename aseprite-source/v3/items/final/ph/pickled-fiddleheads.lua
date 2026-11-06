-- pickled-fiddleheads (C34, Opus single pass). Tulip-shaped clip jar (Weck style): narrow foot flaring to a wide
-- mouth, thick glass lip, orange rubber ring, low domed glass lid held by two bent steel spring clips. Inside: tight
-- fern coils in pale golden brine, each sphere-lit (6-tone green) with a carved spiral groove, a dark eye, brown
-- papery chaff flecks and a slim curved stem trailing down; AO where coils and stems meet the brine.
-- Glass: wall rim, left highlight band, pale core, dark right band, cool bounce.
-- quirk: one fiddlehead has escaped and sits on the lid, already unfurling a tiny leaflet.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, atan, pi = math.floor, math.max, math.min, math.sqrt, math.atan, math.pi
local c = A.new("pickled-fiddleheads")
local CX = 32
local FERN = { "#183a2c", "#225438", "#30743c", "#4c943f", "#74b44a", "#aad266" }
local BRINE = { "#7a6a34", "#ae9a48", "#ccb862", "#e0d282", "#efe6ac", "#faf6d6" }
local RUB = { "#5c1a2a", "#9a2c30", "#d0483a", "#f07a50", "#ffae80" }
local CHAFF = "#8a5a36"
local W = A.METAL

c:groundShadow(CX - .5, 55, 10, 1)

local function hwBody(y)
  if y < 20 or y > 53 then return nil end
  if y <= 21 then return 11 end
  if y == 53 then return 7 end
  if y == 52 then return 8 end
  local t = (52 - y) / 30
  return 8 + 2.6 * t ^ 1.4
end
local body, bn, NX = A.lathe(CX, 20, 53, hwBody)
local inner = body:shrink(1)
local LEVEL = 25
local air, brine = HP.mask(), HP.mask()
inner:each(function(x, y) if y < LEVEL then air:set(x, y) else brine:set(x, y) end end)
local an = {} air:each(function(x, y) an[K(x, y)] = bn[K(x, y)] end)
A.tone(c, air, an, A.GLASS, { amb = .4, wrap = .5 })
local brn = {} brine:each(function(x, y) brn[K(x, y)] = bn[K(x, y)] end)

-- coils {cx, cy, r, stem bezier end dx, dy, flip}
local coils = { { 27, 30, 4.4, -1, 21, 1 }, { 37, 29, 3.9, 1, 21, -1 }, { 31.5, 40, 4.4, -2, 11, 1 }, { 38, 44, 3.4, 0, 8, -1 }, { 25, 45, 3.2, 1, 7, 1 } }
local solid = HP.mask()
local stems = {}
for i, q in ipairs(coils) do
  local sx, sy = q[1] + q[6] * (q[3] - .5), q[2] + 1
  local p = { { sx, sy }, { sx + q[6] * 2, sy + 4 }, { sx + q[4] - q[6], sy + q[5] * .6 }, { sx + q[4], min(51, sy + q[5]) } }
  local m = HP.mask()
  for j = 0, 40 do local x, y = A.bez(p, j / 40) m:set(floor(x + .5), floor(y + .5)) m:set(floor(x + .5) + 1, floor(y + .5)) end
  m:clip(inner)
  stems[i] = m solid:add(m)
end
local discs = {}
for i, q in ipairs(coils) do
  local m = HP.ellipse(q[1], q[2], q[3], q[3])
  m:clip(inner)
  discs[i] = m solid:add(m)
end
local bb = {}
X.ao(bb, brine, solid, 1, -1)
local bmask = brine:copy():cut(solid)
A.tone(c, bmask, brn, BRINE, { amb = .3, wrap = .45, bias = bb })
for x = CX - 11, CX + 11 do if bmask:has(x, LEVEL) then c:put(x, LEVEL, BRINE[6]) end end
-- stems: lit left pixel, shade right pixel; contact AO under the coil
for i, m in ipairs(stems) do
  m:each(function(x, y) c:put(x, y, m:has(x - 1, y) and FERN[3] or FERN[5]) end)
end
-- coils
for i, q in ipairs(coils) do
  local m = discs[i]
  local n = X.sphere(q[1], q[2], q[3], m)
  local idx = A.tone(c, m, n, FERN, { amb = .1, wrap = .3 })
  -- spiral groove: r = pitch * (theta / 2pi + k)
  local pitch = 1.75
  m:each(function(x, y)
    local dx, dy = x + .5 - q[1], (y + .5 - q[2])
    local r = sqrt(dx * dx + dy * dy)
    local th = (atan(dy, dx) * q[6] + 2 * pi) % (2 * pi)
    local f = (r / pitch - th / (2 * pi)) % 1
    local k = K(x, y)
    if r < 1 then c:put(x, y, FERN[1])
    elseif f < .3 and r < q[3] - .6 then c:put(x, y, FERN[max(1, idx[k] - 2)])
    elseif f > .3 and f < .55 and idx[k] >= 3 and r < q[3] - .6 then c:put(x, y, FERN[min(6, idx[k] + 1)]) end
  end)
  -- chaff flecks
  local hx, hy = floor(q[1] + q[3] * .55), floor(q[2] + q[3] * .45)
  if m:has(hx, hy) then c:put(hx, hy, CHAFF) end
  local hx2 = floor(q[1] - q[3] * .2)
  if m:has(hx2, floor(q[2] + q[3] - .5)) then c:put(hx2, floor(q[2] + q[3] - .5), "#6a4028") end
  local sub = m:copy() sub:each(function(x, yy) if yy <= LEVEL then sub.s[K(x, yy)] = nil end end)
  A.tint(c, sub, BRINE[3], .1)
end
c:put(25, 28, A.SPEC)

-- glass overlay + walls
local lower = HP.mask() body:each(function(x, y) if y >= 22 then lower:set(x, y) end end)
A.glass(c, lower, inner, bn, NX, { ys = 22 })
-- thick lip rows 20..21
local lip = HP.mask() body:each(function(x, y) if y <= 21 then lip:set(x, y) end end)
local ln = {} lip:each(function(x, y) ln[K(x, y)] = bn[K(x, y)] end)
A.tone(c, lip, ln, A.GLASS, { amb = .35, wrap = .4 })
for x = CX - 10, CX + 9 do if lip:has(x, 20) then c:put(x, 20, A.GLASS[5]) end end
for x = CX - 10, CX + 10 do if lip:has(x, 21) then c:put(x, 21, A.GLASS[3]) end end
-- rubber ring row 19 (sticks out with a tab on the left)
local rm, rn = A.lathe(CX, 19, 19, function() return 11.5 end)
A.tone(c, rm, rn, RUB, { amb = .1, wrap = .3 })
c:put(CX - 13, 19, RUB[3]) c:put(CX - 13, 20, RUB[2]) c:put(CX - 14, 20, RUB[2]) c:put(CX - 14, 21, RUB[1])
-- domed glass lid rows 15..18
local dm, dn = A.lathe(CX, 15, 18, function(y) if y == 15 then return 7 elseif y == 16 then return 9.5 end return 10.5 end, 1.6)
A.tone(c, dm, dn, A.GLASS, { amb = .3, wrap = .4 })
c:put(CX - 5, 15, A.SPEC) c:put(CX - 4, 15, A.SPEC) c:put(CX - 8, 16, A.GLASS[6])
for x = CX - 10, CX + 10 do if dm:has(x, 18) then c:put(x, 18, A.GLASS[2]) end end

-- spring clips: bent strip from lid shoulder over the ring down under the lip (2 px wide)
local function clip(side)
  local x = side < 0 and CX - 10 or CX + 9
  local pts = { { x, 16 }, { x + side * 2, 17 }, { x + side * 2, 22 }, { x + side * 1, 23 } }
  local m = HP.line(pts, 1)
  m:add(HP.line({ { x + side * 3, 18 }, { x + side * 3, 21 } }, 1))
  local lit = side < 0
  m:each(function(px, py)
    local col
    if px == x + side * 3 then col = lit and W[5] or W[2] else col = lit and W[4] or W[3] end
    c:put(px, py, col)
  end)
  c:put(x + side * 3, 18, lit and W[6] or W[4])
  c:put(x + side * 1, 24, W[1])
end
clip(-1) clip(1)

-- quirk: escaped fiddlehead on the lid, unfurling a leaflet
local qx, qy = CX + 3, 11
local qm = HP.ellipse(qx, qy, 2.4, 2.4)
local qn = X.sphere(qx, qy, 2.4, qm)
local qi = A.tone(c, qm, qn, FERN, { amb = .12, wrap = .3 })
c:put(qx, qy, FERN[1]) c:put(qx + 1, qy, FERN[2]) c:put(qx + 1, qy - 1, FERN[3])
c:put(qx - 1, qy - 1, FERN[6])
c:put(qx + 2, qy + 1, CHAFF)
-- stem lying across the lid, curling down to the left
for _, p in ipairs{ { -2, 3, 3 }, { -3, 3, 4 }, { -4, 4, 3 }, { -5, 4, 4 }, { -6, 4, 3 }, { -7, 4, 4 } } do
  c:put(qx + p[1], qy + p[2], FERN[p[3] + 1]) c:put(qx + p[1], qy + p[2] - 0, FERN[p[3] + 1])
end
-- leaflet opening up-right
A.leaf(c, qx + 2, qy - 2, 1, -1.1, 3.2, 1.2, FERN, { R = 1.1 })
A.fin(c, "pickled-fiddleheads")
