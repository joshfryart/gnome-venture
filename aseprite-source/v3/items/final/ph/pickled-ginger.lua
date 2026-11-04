-- pickled-ginger (C34, Opus single pass). Small glazed porcelain bowl: lathe-lit cream glaze body, indigo brush band
-- and rim line, glossy lip arc, a darker interior back wall, foot ring with a raw clay edge. Heaped in it: thin
-- shaved slices of pink gari, each a curled petal (pillow-lit 6-tone pink) with fibre lines, a pale translucent edge
-- and AO where slices overlap. A pair of slim wooden chopsticks (grain, paler cut ends) rests above.
-- quirk: the chopsticks are lifting one slice off the heap, and it droops between their tips.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs, sin = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin
local c = A.new("pickled-ginger")
local CX = 33
local GLAZE = { "#5c5a78", "#8c8aa4", "#c2bec8", "#e2dcd4", "#f4eedf", "#fffaf0" }
local INDIGO = { "#1f2a5a", "#2e4590", "#4a6cc0", "#7a9ae0" }
local PINK = { "#7d2c5e", "#b34a78", "#e07494", "#f59ab0", "#ffc0cc", "#ffe4e4" }
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#d89a62", "#e8b982", "#f6dcb0" }

c:groundShadow(CX - .5, 52, 12, 1)
local RX, RY, RIMY = 17, 3.5, 35

-- bowl body: rows 35..48, front edge follows the rim ellipse front arc
local function hwB(y)
  if y < 33 or y > 48 then return nil end
  local t = (y - 35) / 13
  if t < 0 then return RX end
  return RX - 6 * t ^ 1.6
end
local bm, bn, BNX = A.lathe(CX, 33, 48, hwB, 1.2)
local front = HP.mask()
bm:each(function(x, y)
  local dx = (x + .5 - CX) / (RX + .5)
  local arc = RIMY + RY * sqrt(max(0, 1 - dx * dx))
  if y >= arc - .5 then front:set(x, y) end
end)
-- interior (back wall) ellipse
local inside = HP.ellipse(CX - .5, RIMY, RX, RY)
inside:cut(front)
local iv = {}
inside:each(function(x, y) iv[K(x, y)] = { -(x + .5 - CX) / RX * .6, .3, .7 } end)
A.tone(c, inside, iv, GLAZE, { amb = .1, wrap = .2 })

-- heap of slices (painted back to front)
local slices = {
  { 26, 32, .9, -.4, 5.5, 2.6 }, { 38, 31, -.8, -.5, 5.5, 2.5 }, { 32, 28, .3, -1, 5, 2.6 },
  { 22, 35, 1, .1, 4.6, 2.2 }, { 44, 34, -1, .2, 4.6, 2.2 }, { 29, 34, .7, .3, 5, 2.4 }, { 37, 35, -.6, .3, 5, 2.4 },
  { 33, 33, .1, -1, 4, 2.2 },
}
local heap = HP.mask()
local function slice(q, clipm)
  local l = sqrt(q[3] ^ 2 + q[4] ^ 2) local ux, uy = q[3] / l, q[4] / l
  local m = A.rell(q[1], q[2], ux, uy, q[5], q[6])
  -- curl: notch one side so the slice reads as a curled shaving
  local nm = A.rell(q[1] + uy * q[6] * 1.1, q[2] - ux * q[6] * 1.1, ux, uy, q[5] * .55, q[6] * .55)
  m:cut(nm)
  if clipm then m:cut(clipm) end
  local bias = {}
  X.ao(bias, m, heap, 1, -1)
  local n = X.pillow(m, 1.6)
  local idx = A.tone(c, m, n, PINK, { amb = .14, wrap = .3, bias = bias })
  -- fibre lines along the slice
  m:each(function(x, y)
    local k = K(x, y)
    local dx, dy = x + .5 - q[1], y + .5 - q[2]
    local b = -dx * uy + dy * ux
    local a = dx * ux + dy * uy
    if abs(b - .2) < .45 and abs(a) < q[5] - 1.2 and idx[k] >= 3 then c:put(x, y, PINK[idx[k] - 1]) end
  end)
  -- translucent pale lit edge
  m:edge():each(function(x, y) local k = K(x, y) if idx[k] and idx[k] >= 4 and not heap:has(x, y) then c:put(x, y, PINK[6]) end end)
  heap:add(m)
  return m
end
for _, q in ipairs(slices) do slice(q, front) end
-- ambient shading on the heap just above the rim
heap:each(function(x, y) if front:has(x, y + 1) then local h = c:get(x, y) if h then c.pix[y * c.w + x] = A.mix(h, PINK[1], .35) end end end)

-- bowl front
local fn = {} front:each(function(x, y) fn[K(x, y)] = bn[K(x, y)] end)
local fidx = A.tone(c, front, fn, GLAZE, { amb = .15, wrap = .35 })
-- glossy lip: front arc row
front:each(function(x, y)
  local k = K(x, y)
  if not front:has(x, y - 1) then c:put(x, y, (BNX[k] or 0) < .3 and GLAZE[6] or GLAZE[4])
  elseif not front:has(x, y - 2) then c:put(x, y, INDIGO[2]) end
end)
-- indigo brush band (wavy) around the belly
front:each(function(x, y)
  local k = K(x, y)
  local s = BNX[k] or 0
  local wy = 42 + floor(sin((x - CX) * .55) * 1.2 + .5)
  if y == wy or y == wy + 1 then
    local i = s < -.5 and 4 or (s < .2 and 3 or (s < .7 and 2 or 1))
    c:put(x, y, INDIGO[i])
  end
end)
-- dots of the brushed pattern
for _, p in ipairs{ { -10, 39 }, { -4, 39 }, { 2, 39 }, { 8, 39 } } do
  if front:has(CX + p[1], p[2]) then c:put(CX + p[1], p[2], INDIGO[3]) end
end
-- glaze specular
c:put(CX - 12, 39, GLAZE[6]) c:put(CX - 12, 40, A.SPEC) c:put(CX - 11, 39, A.SPEC)
-- foot ring rows 49..50 with raw clay
local ft, ftn = A.lathe(CX, 49, 50, function(y) return y == 49 and 8 or 7.5 end)
A.tone(c, ft, ftn, { "#6a4636", "#9a6a50", "#c4946c", "#e2b88c" }, { amb = .15, wrap = .3 })
for x = CX - 8, CX + 8 do if ft:has(x, 49) then c:put(x, 49, GLAZE[1]) end end

-- chopsticks: slim tapering rods from upper right toward the heap, tips pinching a slice
local function stick(ax, ay, bx, by)
  local m, n, T, S = X.cyl(ax, ay, bx, by, function(t) return .6 + .5 * (1 - t) end)
  local idx = A.tone(c, m, n, WOOD, { amb = .1, wrap = .3 })
  m:each(function(x, y)
    local k = K(x, y)
    if T[k] > .9 then c:put(x, y, WOOD[6]) end           -- pale cut end (back)
    if T[k] < .9 and (floor(T[k] * 18) % 3 == 0) and S[k] > -.2 then c:put(x, y, WOOD[max(1, idx[k] - 1)]) end -- grain
  end)
  return m
end
local s1 = stick(26, 21, 55, 9)
local s2 = stick(27, 24, 56, 13)
-- lifted slice drooping between the tips
local lm = HP.poly{ { 23, 20 }, { 27, 20 }, { 29, 22 }, { 28, 25 }, { 25, 28 }, { 23, 27 }, { 22, 24 } }
lm:cut(s1):cut(s2)
local ln = X.pillow(lm, 1.4)
local lidx = A.tone(c, lm, ln, PINK, { amb = .14, wrap = .3 })
for _, p in ipairs{ { 25, 22 }, { 25, 23 }, { 24, 24 }, { 24, 25 } } do if lm:has(p[1], p[2]) then c:put(p[1], p[2], PINK[3]) end end
c:put(23, 21, PINK[6]) c:put(24, 21, A.SPEC)
-- shadow of the sticks across the slice
for x = 26, 29 do if lm:has(x, 23) then c:put(x, 23, PINK[2]) end end
A.fin(c, "pickled-ginger")
