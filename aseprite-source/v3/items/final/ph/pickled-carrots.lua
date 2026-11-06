-- pickled-carrots (C34, Opus single pass). Tall slim swing-top jar: glass dome lid on an orange rubber gasket, wire bail
-- with hinge knobs, straight glass body with rounded foot. Inside: carrot sticks standing in pale turmeric brine, each a
-- per-pixel cylinder (6-tone orange) with growth-ring grooves and rounded cut tops; peppercorns on the floor; AO in the
-- brine gaps. Glass: lit wall rim, left highlight band, pale core streak, dark right band with cool bounce.
-- quirk: a feathery carrot frond is tucked under the wire bail, flopping over the side.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min = math.floor, math.max, math.min
local c = A.new("pickled-carrots")
local CX = 32
local OR = { "#6a2236", "#a2332e", "#d04b25", "#ee6c22", "#fb983a", "#ffc874" }
local BRINE = { "#8a5a2a", "#c08a38", "#deb050", "#efcc6e", "#f8e29a", "#fff2c6" }
local RUB = { "#5c1a2a", "#9a2c30", "#d0483a", "#f07a50", "#ffae80" }

c:groundShadow(CX - .5, 53, 13, 1)

-- body profile
local function hwBody(y)
  if y < 15 or y > 51 then return nil end
  if y <= 17 then return 9.5 end
  if y == 18 then return 10 end
  if y == 50 then return 10 elseif y == 51 then return 9 end
  return 10.5
end
local body, bn, NX = A.lathe(CX, 15, 51, hwBody)
local inner = body:shrink(1)
local LEVEL = 21

-- empty glass above brine (pale air), brine below
local air, brine = HP.mask(), HP.mask()
inner:each(function(x, y) if y < LEVEL then air:set(x, y) else brine:set(x, y) end end)
local an = {} air:each(function(x, y) an[K(x, y)] = bn[K(x, y)] end)
A.tone(c, air, an, A.GLASS, { amb = .4, wrap = .5 })
local brn = {} brine:each(function(x, y) brn[K(x, y)] = bn[K(x, y)] end)

-- carrot sticks
local sticks = { { 24, 1.1, 19 }, { 28.5, 1.6, 23 }, { 33, 1.1, 18 }, { 37.5, 1.6, 21 }, { 41, .6, 25 } }
local smask = HP.mask()
local SM = {}
for i, s in ipairs(sticks) do
  local m, n, T, S = X.cyl(s[1], s[3], s[1], 50, function() return s[2] end)
  -- rounded cut top: drop corners of the first row
  local x0, y0, x1 = m:bbox()
  if x1 - x0 >= 2 then m.s[K(x0, y0)] = nil m.s[K(x1, y0)] = nil end
  m:clip(inner)
  SM[i] = { m = m, n = n, S = S, top = y0, x0 = x0, x1 = x1 }
  smask:add(m)
end
-- brine with AO next to sticks
local bb = {}
X.ao(bb, brine, smask, 1, -1)
local bmask = brine:copy():cut(smask)
A.tone(c, bmask, brn, BRINE, { amb = .3, wrap = .45, bias = bb })
-- meniscus
for x = CX - 10, CX + 10 do if bmask:has(x, LEVEL) then c:put(x, LEVEL, BRINE[6]) end end
-- peppercorns
for _, p in ipairs{ { 26, 48 }, { 35, 49 }, { 40, 47 } } do
  if bmask:has(p[1], p[2]) then c:put(p[1], p[2], "#4a2a2a") c:put(p[1] + 1, p[2], "#2e1c22") c:put(p[1], p[2] + 1, "#3a2226") end
end
for i, s in ipairs(SM) do
  local bias = {}
  s.m:each(function(x, y) local k = K(x, y) if y == s.top then bias[k] = 1 end end)
  local idx = A.tone(c, s.m, s.n, OR, { amb = .08, wrap = .25, bias = bias })
  -- growth-ring grooves: dark row + lit lip above, hashed spacing
  local y = s.top + 4 + floor(X.hash(i, 3) * 3)
  while y < 48 do
    for x = s.x0, s.x1 do
      local k = K(x, y)
      if s.m:has(x, y) and (x - s.x0 + i) % 4 ~= 3 then
        c:put(x, y, OR[max(1, (idx[k] or 3) - 2)])
        if s.m:has(x, y - 1) and (idx[K(x, y - 1)] or 0) >= 3 then c:put(x, y - 1, OR[min(6, idx[K(x, y - 1)] + 1)]) end
      end
    end
    y = y + 5 + floor(X.hash(i, y) * 4)
  end
  -- under brine: slight warm tint
  local sub = s.m:copy() sub:each(function(x, yy) if yy <= LEVEL then sub.s[K(x, yy)] = nil end end)
  A.tint(c, sub, BRINE[3], .12)
end
-- specular glint on the tallest stick top
c:put(33, 19, A.SPEC)

-- glass overlay + walls (body rows 18..55)
local lower = HP.mask() body:each(function(x, y) if y >= 18 then lower:set(x, y) end end)
A.glass(c, lower, inner, bn, NX, { ys = 18 })

-- thick glass lip (rows 15..17)
local lip = HP.mask() body:each(function(x, y) if y <= 17 then lip:set(x, y) end end)
local ln = {} lip:each(function(x, y) ln[K(x, y)] = bn[K(x, y)] end)
A.tone(c, lip, ln, A.GLASS, { amb = .35, wrap = .4 })
for x = CX - 9, CX + 8 do if lip:has(x, 15) then c:put(x, 15, A.GLASS[6]) end end
for x = CX - 9, CX + 9 do if lip:has(x, 17) then c:put(x, 17, A.GLASS[3]) end end

-- rubber gasket
local gm, gn = A.lathe(CX, 14, 14, function() return 10.5 end)
A.tone(c, gm, gn, RUB, { amb = .1, wrap = .3 })
-- glass dome lid
local dm, dn, DNX = A.lathe(CX, 9, 13, function(y)
  if y == 9 then return 5.5 elseif y == 10 then return 7.5 elseif y == 11 then return 8.5 end return 9 end, 1.6)
A.tone(c, dm, dn, A.GLASS, { amb = .3, wrap = .4 })
c:put(CX - 5, 10, A.SPEC) c:put(CX - 4, 10, A.SPEC) c:put(CX - 7, 11, A.GLASS[6])
for x = CX - 8, CX + 8 do if dm:has(x, 13) then c:put(x, 13, A.GLASS[2]) end end

-- wire bail: hinge knobs + loop over the lid
local W = A.METAL
local function wire(pts, col)
  local m = HP.line(pts, 1)
  m:each(function(x, y) c:put(x, y, col(x, y)) end)
  return m
end
wire({ { CX - 11, 17 }, { CX - 9, 12 }, { CX - 7, 8 } }, function() return W[5] end)
wire({ { CX + 10, 17 }, { CX + 8, 12 }, { CX + 6, 8 } }, function() return W[3] end)
wire({ { CX - 6, 7 }, { CX + 5, 7 } }, function(x) return x < CX - 2 and W[6] or (x < CX + 3 and W[5] or W[4]) end)
for _, h in ipairs{ { CX - 12, 17, W[4] }, { CX + 10, 17, W[3] } } do
  c:put(h[1], h[2], h[3]) c:put(h[1] + 1, h[2], W[2]) c:put(h[1], h[2] + 1, W[2]) c:put(h[1] + 1, h[2] + 1, W[1])
end

-- quirk: carrot frond tucked under the bail on the right, flopping over the side
local p = { { CX + 3, 8 }, { CX + 8, 5 }, { CX + 14, 6 }, { CX + 16, 13 } }
local ltok = { r = { name = "frond" } }
for i = 0, 40 do
  local t = i / 40 local x, y = A.bez(p, t)
  c:put(floor(x + .5), floor(y + .5), t < .5 and "#5b9a52" or "#8cc066", ltok)
end
for _, q in ipairs{ { .3, -1, 3 }, { .42, 1, 3 }, { .55, -1, 3 }, { .68, 1, 3 }, { .8, -1, 2.6 }, { .92, 1, 2.4 } } do
  local x, y = A.bez(p, q[1]) local x2, y2 = A.bez(p, q[1] + .02)
  local tx, ty = x2 - x, y2 - y
  local ux, uy = tx * .5 - ty * q[2], ty * .5 + tx * q[2]
  A.leaf(c, x, y, ux, uy, q[3], 1.3, A.LEAF, { tok = ltok, norib = true, R = 1.2 })
end
do local x, y = A.bez(p, 1) A.leaf(c, x, y, .2, 1, 3.4, 1.4, A.LEAF, { tok = ltok, norib = true, R = 1.2 }) end
A.fin(c, "pickled-carrots")
