-- coriander (final pass, Opus single pass). A slim tied bunch of fresh cilantro: six pale ribbed stems fan up from a
-- twine wrap into three-lobed, scalloped flat leaves (pillow + sphere light, 6-tone cool green, lit veins fanning from
-- the base of each leaflet, contact shadow where leaves overlap). Twine has a diagonal twist; below it the stems end in
-- a tuft of pale, hairy roots with soil-brown tips.
-- quirk: one stem has bolted and carries a tiny white umbel of flowers.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "coriander"
local c = A.new(NAME)
local LEAF = { "#163a33", "#1f5a3e", "#2c7a44", "#44a04c", "#72c45a", "#a8e07a" }
local STEM = { "#2f6a44", "#4f9a52", "#7cc068", "#b4e08e" }
local TW = { "#4a2a22", "#7a4a30", "#a8743e", "#d0a060", "#f0d08e" }
local ROOT = { "#6a4a3a", "#a08268", "#d4c0a0", "#f2e8d0" }
local FL = { "#8a8aa8", "#dcdce8", "#fff4d6" }
local ltok = { r = { name = "leaf" } }
local stok = { r = { name = "stem" } }

local BX, BY = 31, 43        -- bundle point (top of twine)
-- stems: bezier end points and leaf clusters
local stems = {
  { { BX - 1, BY }, { 27, 37 }, { 21, 32 }, { 15, 28 }, ang = -2.5 },
  { { BX - 1, BY }, { 28, 34 }, { 23, 25 }, { 20, 18 }, ang = -2.0 },
  { { BX, BY },     { 31, 33 }, { 31, 22 }, { 31, 15 }, ang = -1.6 },
  { { BX + 1, BY }, { 34, 35 }, { 39, 26 }, { 43, 20 }, ang = -1.05 },
  { { BX + 1, BY }, { 35, 38 }, { 42, 34 }, { 48, 31 }, ang = -0.55 },
}
-- bolted flower stem (quirk) runs behind
local bolt = { { BX, BY }, { 33, 32 }, { 37, 20 }, { 39, 13 } }

local function drawStem(p, from, to, wide)
  for i = 0, 80 do local t = from + (to - from) * i / 80
    local x, y = A.bez(p, t) local xi, yi = floor(x + .5), floor(y + .5)
    c:put(xi, yi, t < 0.2 and STEM[2] or STEM[3], stok)
    if wide and t < 0.35 then c:put(xi + 1, yi, STEM[1], stok) end
  end
end

-- leaf lobes: 3-lobed rounded leaflet, base at (bx,by) pointing along ang, size r
local painted = HP.mask()
local idxAll = {}
local function leaflet(bx, by, ang, r)
  local m = HP.mask()
  local ux, uy = cos(ang), sin(ang)
  local cx, cy = bx + ux * r * 0.9, by + uy * r * 0.9
  m:add(c:ellipse(cx + ux * r * 0.6, cy + uy * r * 0.6, r * 0.48, r * 0.48))
  for _, s in ipairs{ -1, 1 } do local vx, vy = A.rot(ux, uy, s * 1.15)
    m:add(c:ellipse(cx + vx * r * 0.62, cy + vy * r * 0.62, r * 0.44, r * 0.44)) end
  m:add(c:ellipse(cx, cy, r * 0.42, r * 0.42))
  -- notches between lobes (scalloped margin)
  for _, s in ipairs{ -1, 1 } do local vx, vy = A.rot(ux, uy, s * 0.62)
    for _, d in ipairs{ r * 0.85, r * 1.05 } do
    local nx, ny = floor(cx + vx * d + .5), floor(cy + vy * d + .5)
    m.s[K(nx, ny)] = nil end end
  -- wedge base toward petiole
  m:add(c:line({ { floor(bx + .5), floor(by + .5) }, { floor(cx + .5), floor(cy + .5) } }, 1))
  local n = A.body(m, cx - 0.5, cy - 0.5, r + 0.5, 2.2, 0.55)
  local bias = {}
  -- separation from earlier leaves: own edge touching them is one step darker
  m:edge():each(function(x, y) if painted:has(x + 1, y) or painted:has(x, y + 1) or painted:has(x - 1, y) or painted:has(x, y - 1) then
    if not m:has(x - 1, y - 1) or painted:has(x - 1, y - 1) then bias[K(x, y)] = -1 end end end)
  local idx = A.shade(c, m, n, LEAF, { tok = ltok, bias = bias, amb = 0.1, wrap = 0.3 })
  -- veins fanning from base to each lobe
  for _, s in ipairs{ -1.15, 0, 1.15 } do local vx, vy = A.rot(ux, uy, s * 0.8)
    for d = 1, floor(r * 1.2) do
      local x, y = floor(bx + ux * 1.2 + vx * d + .5), floor(by + uy * 1.2 + vy * d + .5)
      if m:has(x, y) and not m:edge():has(x, y) then local i = idx[K(x, y)] or 3
        c:put(x, y, LEAF[min(6, i + 2)], ltok) end
    end
  end
  -- contact shadow on earlier leaves (lower-right)
  m:shift(1, 1):each(function(x, y) if painted:has(x, y) and not m:has(x, y) then
    local i = idxAll[K(x, y)] or 3 c:put(x, y, LEAF[max(1, i - 2)], ltok) end end)
  for k, i in pairs(idx) do idxAll[k] = i end
  painted:add(m)
  return m
end

-- bolted stem first (behind)
drawStem(bolt, 0.15, 1, false)
for _, p in ipairs(stems) do drawStem(p, 0, 1, true) end

-- clusters: lateral pair along the stem then the terminal leaflet
for i, p in ipairs(stems) do
  local ex, ey = A.bez(p, 1)
  local lx, ly = A.bez(p, 0.72)
  local r = (i == 3) and 4.8 or 4.4
  local lx, ly = A.bez(p, 0.6)
  leaflet(lx, ly, p.ang - 1.05, 3.1)
  leaflet(lx, ly, p.ang + 1.05, 3.1)
  leaflet(ex, ey, p.ang, r)
end
-- re-draw petiolules over leaves briefly near their bases (stalk joins)
for _, p in ipairs(stems) do
  for i = 0, 6 do local x, y = A.bez(p, 0.62 + i * 0.016) c:put(floor(x + .5), floor(y + .5), STEM[2], stok) end
end

-- umbel (quirk): tiny white flower heads at the bolt top
do local ex, ey = A.bez(bolt, 1) ex, ey = floor(ex + .5), floor(ey + .5)
  local rays = { { -3, -2 }, { -1, -3 }, { 2, -3 }, { 3, -1 } }
  for _, r in ipairs(rays) do
    c:put(ex + floor(r[1] / 2), ey + floor(r[2] / 2), STEM[3], stok)
    local fx, fy = ex + r[1], ey + r[2]
    c:put(fx, fy, FL[2]) c:put(fx + 1, fy, FL[1]) c:put(fx, fy - 1, FL[3]) c:put(fx - 1, fy, FL[2])
  end
  c:put(ex, ey, STEM[2], stok)
end

-- stems below the bundle and roots
for _, dx in ipairs{ -2, -1, 0, 1, 2 } do
  for y = BY, 48 do c:put(BX + dx, y, (dx <= -1) and STEM[3] or (dx == 2 and STEM[1] or STEM[2]), stok) end
  c:put(BX + dx, 49, STEM[1], stok)
end
local rtok = { r = { name = "root" } }
local roots = { { -2, -5, 5 }, { -1, -2, 6 }, { 1, 1, 6 }, { 2, 4, 5 } }
for _, r in ipairs(roots) do
  local x0, sway, L = BX + r[1], r[2], r[3]
  for i = 0, L do local f = i / L
    local x = floor(x0 + sway * f + sin(f * 5 + x0) * 0.6 + .5)
    local y = 50 + i
    c:put(x, y, f > 0.75 and ROOT[2] or (r[1] < 0 and ROOT[4] or ROOT[3]), rtok)
  end
  -- root hair
  local hx = floor(x0 + sway * 0.5 + .5)
  if r[3] >= 6 then c:put(hx + (sway >= 0 and 1 or -1), 50 + floor(L / 2), ROOT[3], rtok) end
end
-- soil crumb on root tips
c:put(BX - 3, 56, ROOT[1], rtok)

-- twine wrap: 4 rows with diagonal twist, AO on stems above and below
local ttok = { r = { name = "twine" } }
for y = BY + 1, BY + 4 do
  for x = BX - 4, BX + 4 do
    local e = (x == BX - 4 or x == BX + 4) and (y == BY + 1 or y == BY + 4)
    if not e then
      local ph = (x + y * 1) % 3
      local base = (x < BX - 1) and 4 or (x > BX + 2 and 2 or 3)
      local i = base + (ph == 0 and -1 or (ph == 1 and 1 or 0))
      if y == BY + 4 then i = i - 1 end
      c:put(x, y, TW[max(1, min(5, i))], ttok)
    end
  end
end
c:put(BX - 2, BY + 1, TW[5], ttok)
-- twine tail hanging off the knot on the right
for i, q in ipairs{ { BX + 5, BY + 3 }, { BX + 6, BY + 4 }, { BX + 6, BY + 5 }, { BX + 7, BY + 6 } } do c:put(q[1], q[2], TW[(i % 2 == 0) and 2 or 4], ttok) end
-- ambient band under twine
for x = BX - 2, BX + 2 do c:put(x, BY + 5, STEM[1], stok) end
for x = BX - 2, BX + 2 do if c:get(x, BY) then c:put(x, BY, STEM[1], stok) end end

A.save(c, NAME)
