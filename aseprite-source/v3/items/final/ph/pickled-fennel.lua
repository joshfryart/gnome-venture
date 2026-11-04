-- pickled-fennel (C34, Opus single pass). Tall slim open apothecary glass with a flared rolled lip (no lid): two pale
-- fennel bulb wedges showing their layered arcs, a lemon wheel against the glass, pale-green brine; three ribbed
-- stalks rise out of the mouth into feathery frond plumes (rachis + alternate pinnae, lit left, deep right).
-- quirk: one frond leans out over the rim and is about to drip a bead of brine.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = A.new("pickled-fennel")
local CX = 32
c:groundShadow(CX, 52, 12, 2)

local BRINE = { "#2c5a4e", "#4a8466", "#78ae7c", "#a6cf94", "#cfe8b4", "#f0fad8" }
local BULB = { "#4e6e4a", "#7c9e62", "#acc888", "#d4e6aa", "#ecf4cc", "#fbfdea" }
local STALK = { "#2e5a3a", "#4f8448", "#78ac58", "#a2cc72", "#c8e298", "#e8f4c4" }
local LEAF = A.LEAF
local LEMON = { "#8a5a14", "#c8901c", "#ecbe2c", "#f8dc56", "#fff09a", "#fffbd8" }

local function hw(y)
  if y < 25 or y > 50 then return nil end
  if y <= 26 then return 11.6 end
  if y == 27 then return 10.4 end
  if y <= 48 then return 10 end
  if y == 49 then return 9.6 end
  return 8.6
end
local body, bn, NX = A.lathe(CX, 25, 50, hw)
local inner = body:shrink(1)
local LEVEL = 30
local tok = { r = { name = "contents" } }
local liq = HP.mask()
inner:each(function(x, y)
  if y < LEVEL then c:put(x, y, (NX[K(x, y)] or 0) < -.2 and "#eef9fc" or "#d6edf5", tok)
  else liq:set(x, y) end end)
local ln = {} liq:each(function(x, y) ln[K(x, y)] = bn[K(x, y)] end)
A.tone(c, liq, ln, BRINE, { amb = .3, wrap = .45, tok = tok })
for x = CX - 11, CX + 11 do if liq:has(x, LEVEL) then c:put(x, LEVEL, x < CX + 3 and BRINE[6] or BRINE[5], tok) end end

local occ = HP.mask()
-- stalks (tubes), drawn first so the wedges sit in front of their feet
local stalkTips = {}
local function stalk(p)
  local m, n, T, S = A.tube(p, function(t) return 1.55 - t * .25 end, 80)
  local idx = A.tone(c, m, n, STALK, { amb = .15, wrap = .3, tok = tok })
  -- ribs: a groove one px right of the centre line
  m:each(function(x, y) local k = K(x, y) if S[k] > .15 and S[k] < .55 and T[k] > .05 then c:put(x, y, STALK[max(1, idx[k] - 1)], tok) end end)
  occ:add(m)
  stalkTips[#stalkTips + 1] = p
  return m
end
stalk({ { 28, 40 }, { 27.5, 32 }, { 26.5, 24 }, { 24.5, 15 } })
stalk({ { 32.5, 42 }, { 32.5, 33 }, { 33, 22 }, { 33, 11 } })
stalk({ { 37, 40 }, { 37.5, 32 }, { 39, 24 }, { 41.5, 16 } })

-- bulb wedges: pillow-lit fan with concentric layer arcs about the root point
local function wedge(wx, wy, ux, uy, ra, rb)
  local m = A.rell(wx, wy, ux, uy, ra, rb)
  m:clip(inner)
  local n = X.pillow(m, 2.2)
  local bias = {}
  X.ao(bias, m, occ, 1, -1)
  local idx = A.tone(c, m, n, BULB, { amb = .15, wrap = .3, tok = tok, bias = bias })
  local l = sqrt(ux*ux + uy*uy) ux, uy = ux / l, uy / l
  local bx, by = wx + ux * ra * .95, wy + uy * ra * .95   -- root at the bottom end
  m:each(function(x, y)
    local d = sqrt((x + .5 - bx)^2 + (y + .5 - by)^2)
    local f = d % 3.2
    local k = K(x, y)
    if f < .9 and d > 2 then c:put(x, y, BULB[max(1, idx[k] - 2)], tok)
    elseif f < 1.9 and d > 2 and idx[k] >= 4 then c:put(x, y, BULB[min(6, idx[k] + 1)], tok) end
  end)
  -- root plate
  c:put(floor(bx), floor(by) - 1, BULB[2], tok) c:put(floor(bx) - 1, floor(by) - 1, BULB[2], tok)
  m:edge():each(function(x, y)
    if occ:has(x + 1, y) or occ:has(x - 1, y) or occ:has(x, y + 1) or occ:has(x, y - 1) then
      if not occ:has(x, y) then c:put(x, y, BULB[1], tok) end end end)
  local sh = m:shift(1, 1):cut(m)
  sh:each(function(x, y) if occ:has(x, y) then local h = c:get(x, y) if h then c:put(x, y, A.mix(h, "#1c3a30", .3), tok) end end end)
  occ:add(m)
end
wedge(27.5, 42, .25, 1, 7.6, 5.0)
wedge(37, 43.5, -.3, 1, 6.6, 4.6)
-- lemon wheel against the glass (rind ring, segments, pale pith spokes)
do
  local lx, ly, r = 35.5, 34.5, 3.6
  local m = HP.mask()
  for y = floor(ly - r - 1), floor(ly + r + 1) do for x = floor(lx - r - 1), floor(lx + r + 1) do
    if (x + .5 - lx)^2 + (y + .5 - ly)^2 <= r * r then m:set(x, y) end end end
  m:each(function(x, y)
    local dx, dy = x + .5 - lx, y + .5 - ly
    local d = sqrt(dx*dx + dy*dy)
    local col
    if d > r - 1 then col = (dx + dy < 0) and LEMON[4] or LEMON[3]
    elseif d > r - 1.7 then col = LEMON[6]
    else local a = math.atan(dy, dx) col = (((a + pi) / (2 * pi) * 7) % 1 < .22) and LEMON[6] or ((dx + dy < 0) and LEMON[5] or LEMON[4]) end
    c:put(x, y, col, tok)
  end)
  c:put(floor(lx), floor(ly), LEMON[6], tok)
  occ:add(m)
end
-- submerged tint
occ:each(function(x, y) if y > LEVEL and inner:has(x, y) then local h = c:get(x, y) if h then c.pix[y * c.w + x] = A.mix(h, "#a6cf94", .12) end end end)
for _, b in ipairs{ { 30, 33 }, { 31, 35 }, { 40, 41 } } do c:put(b[1], b[2], "#f6fde6", tok) end

A.glass(c, body, inner, bn, NX, { ys = LEVEL + 1 })
-- flared rolled lip on top (rows 25-26), in front of the stalks
for x = CX - 12, CX + 12 do
  if body:has(x, 25) then c:put(x, 25, x < CX - 3 and A.GLASS[6] or A.GLASS[4]) end
  if body:has(x, 26) then c:put(x, 26, x < CX - 3 and A.GLASS[4] or A.GLASS[2]) end
end
c:put(CX - 10, 25, A.SPEC) c:put(CX - 9, 25, A.SPEC)

-- fronds: rachis continues past the stalk tip, alternate pinnae angled forward
local function frond(x0, y0, ang, len, n)
  local ux, uy = cos(ang), sin(ang)
  for i = 0, len do
    local x, y = x0 + ux * i, y0 + uy * i
    c:put(floor(x + .5), floor(y + .5), i < 2 and STALK[3] or LEAF[4])
  end
  for i = 1, n do
    local t = 1 + (i - 1) * (len - 1) / max(1, n - 1)
    local x, y = x0 + ux * t, y0 + uy * t
    local side = (i % 2 == 0) and 1 or -1
    local a2 = ang + side * .85
    local L = 3.6 - t / len * 1.6
    local col = side < 0 and LEAF[5] or LEAF[3]
    if (ux * side) > .3 then col = LEAF[3] end
    A.ln(c, x, y, x + cos(a2) * L, y + sin(a2) * L, col)
    c:put(floor(x + cos(a2) * L + .5), floor(y + sin(a2) * L + .5), side < 0 and LEAF[6] or LEAF[4])
  end
end
-- left plume
frond(24.5, 15, -2.1, 7, 6) frond(25, 17, -2.75, 6, 5) frond(24.6, 15.5, -1.55, 6, 5)
-- centre plume
frond(33, 11, -1.62, 6, 6) frond(33, 12, -2.3, 6, 5) frond(33, 12, -.95, 6, 5)
-- right plume; one frond leans out over the rim (quirk)
frond(41.5, 16, -1.2, 6, 5) frond(41.5, 16, -.55, 5, 4)
A.ln(c, 42, 17, 45, 19, LEAF[4]) A.ln(c, 45, 19, 47, 22, LEAF[4])
c:put(44, 17, LEAF[5]) c:put(46, 19, LEAF[5]) c:put(44, 20, LEAF[3]) c:put(46, 21, LEAF[3])
-- the bead of brine hanging from its tip
c:put(47, 23, "#cfeef6") c:put(47, 24, "#9ad4e4") c:put(48, 24, "#6eb0cc") c:put(47, 25, "#6eb0cc")
c:put(47, 23, A.SPEC)
-- AO where the stalks leave the mouth
for _, x in ipairs{ 26, 27, 33, 34, 39, 40 } do local h = c:get(x, 24) if h then c:put(x, 24, A.mix(h, "#1c3a30", .35)) end end

A.fin(c, "pickled-fennel")
