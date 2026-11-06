-- caper (Opus single pass). A slim caper sprig: reddish woody stem rising diagonally, two round blue-green caper leaves
-- (thick, midrib, mucro tip), and four olive caper buds of falling size on short pedicels, each bud a sphere with
-- overlapping-sepal seams to a pinched point, waxy bloom flecks, one specular, cool bounce on the shade side. Paired
-- hooked tan stipule spines at each node; AO where pedicels and stem meet.
-- quirk: the smallest bud at the tip is already opening, a tuft of long pink-violet stamens poking out.
local NAME = "caper"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_2.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = G.new2(NAME)
local BUD = { "#1f3224", "#2e4a2a", "#46652f", "#62823a", "#86a24c", "#b6c873" }
local BLOOM, BOUNCE = "#a8b894", "#4a6a6c"
local LEAF = { "#163538", "#21504a", "#2e6b56", "#468a64", "#6aa878", "#9ccb94" }
local STEM = { "#3a2030", "#5a3036", "#7e463e", "#a2644a", "#c4885c", "#e0ae7a" }
local SPINE = { "#7a5432", "#c09358", "#ecd096" }
local STAM = { "#7a2c6a", "#c050a0", "#f08ad0" }

local SP = { { 12, 55 }, { 21, 43 }, { 33, 31 }, { 47, 17 } }
local stok = { r = { name = "stem" } }
local sm, ST = A.stem(c, SP, function(t) return 1.5 - 0.7 * t end, STEM, stok, { 0.2, 0.36, 0.52, 0.68, 0.84 })
-- bark: a few pale lenticel dashes and dark rings
sm:each(function(x, y) local t = ST[K(x, y)] if t and (abs(t - 0.4) < 0.008 or abs(t - 0.65) < 0.008) then c:put(x, y, STEM[2], stok) end end)

local function node(t) local x, y = G.bez(SP, t) return x, y end
-- leaves: rounded ovals on a short petiole, toward the upper-left
local ltok = { r = { name = "leaf" } }
local leaves = {}
local function leaf(t, ux, uy, ra, rb)
  local nx, ny = node(t)
  local l = sqrt(ux * ux + uy * uy) ux, uy = ux / l, uy / l
  local ccx, ccy = nx + ux * (ra + 2), ny + uy * (ra + 2)
  local pet = A.stem(c, { { nx, ny }, { nx + ux, ny + uy }, { nx + ux * 2, ny + uy * 2 }, { nx + ux * 3, ny + uy * 3 } }, function() return 0.6 end, STEM, stok, { 0.2, 0.36, 0.52, 0.68, 0.84 })
  local m = G.rell(ccx, ccy, ux, uy, ra, rb)
  m:set(floor(ccx + ux * (ra + 0.8) + 0.5), floor(ccy + uy * (ra + 0.8) + 0.5))   -- mucro point
  m:cut(sm)
  local n = X.pillow(m, 2.2)
  local idx = G.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.12 })
  m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - ccx, y - ccy
    local a, b = dx * ux + dy * uy, -dx * uy + dy * ux
    if abs(b) < 0.5 and a > -ra and a < ra - 0.5 then c:put(x, y, b <= 0 and LEAF[6] or LEAF[3], ltok)          -- midrib
    elseif abs(abs(b) - (a + ra) * 0.45) < 0.5 and a > -ra + 1 and a < ra - 1.5 and abs(b) > 0.9 then
      c:put(x, y, LEAF[max(1, (idx[k] or 3) + (b < 0 and 1 or -1))], ltok) end                                  -- side veins
  end)
  local gx, gy = G.specAt(m, n, 50) if gx then c:put(gx, gy, LEAF[6], ltok) c:put(gx + 1, gy, LEAF[6], ltok) end
  leaves[#leaves + 1] = m
  return m
end
leaf(0.3, -1, -0.55, 6, 4.2)
leaf(0.6, -1, -0.95, 5.2, 3.8)

-- buds
local buds = {}
local function bud(t, ox, oy, r, open)
  local nx, ny = node(t)
  local cx, cy = nx + ox, ny + oy
  local ax, ay = ox, oy local l = sqrt(ax * ax + ay * ay) ax, ay = ax / l, ay / l   -- bud axis: pedicel -> apex
  local base = { cx - ax * r, cy - ay * r }
  local ped = A.stem(c, { { nx, ny }, { nx + (base[1] - nx) * 0.3, ny + (base[2] - ny) * 0.3 - 1 }, { base[1] - ax, base[2] - ay }, base },
    function() return 0.7 end, LEAF, ltok, { 0.2, 0.36, 0.52, 0.68, 0.84 })
  local m = G.rell(cx, cy, ax, ay, r + 0.3, r)
  local n = X.sphere(cx - 0.3, cy - 0.3, r + 0.3, m)
  local bias = {}
  local tok = { r = { name = "bud" .. #buds } }
  local idx = G.toneN(c, m, n, BUD, { tok = tok, bias = bias, cuts = { 0.12, 0.28, 0.45, 0.62, 0.8 }, amb = 0.08, wrap = 0.2 })
  local rim = X.rim(n)
  m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - cx, y - cy
    local u, v = (dx * ax + dy * ay) / r, (-dx * ay + dy * ax) / r      -- u: toward apex
    local i = idx[k] or 3
    -- sepal seams converging on the apex: v = +-0.5*(1-u)
    local w = 0.42 * (1 - u)
    if u > -0.6 and abs(abs(v) - w) < 0.11 + 0.04 * r / 5 then c:put(x, y, BUD[max(1, i - 2)], tok)
    elseif u > -0.6 and abs(v) - w > 0.11 and abs(v) - w < 0.32 and v < 0 then c:put(x, y, BUD[min(6, i + 1)], tok)  -- lit sepal lip
    elseif rim[k] > 0.55 and i <= 2 then c:put(x, y, BOUNCE, tok)
    elseif i >= 3 and i <= 5 and X.hash(x, y, 9) > 0.86 then c:put(x, y, BLOOM, tok) end
  end)
  -- apex point
  c:put(floor(cx + ax * r + 0.5), floor(cy + ay * r + 0.5), BUD[2], tok)
  local gx, gy = G.specAt(m, n, 60) if gx and not open then c:put(gx, gy, "#eef2c8", tok) c:put(gx + 1, gy, BUD[6], tok) end
  buds[#buds + 1] = { m = m, cx = cx, cy = cy, ax = ax, ay = ay, r = r }
  return m
end
bud(0.28, 9.5, 4.5, 5.6)
bud(0.56, 9, 3.5, 4.6)
bud(0.82, 6, 3.5, 3.4)
-- tip bud (quirk), along the stem end
local ex, ey = G.bez(SP, 1)
local tb = bud(0.97, 1.6, -3.2, 2.6, true)
do
  local b = buds[#buds]
  local px, py = b.cx + b.ax * (b.r + 0.5), b.cy + b.ay * (b.r + 0.5)
  -- split tip: dark gap then filaments fanning out with pale anthers
  c:put(floor(px + 0.5), floor(py + 0.5), STAM[1])
  local fans = { { -0.9, 4 }, { -0.25, 5 }, { 0.4, 4.5 } }
  for _, f in ipairs(fans) do
    local dx, dy = G.rot(b.ax, b.ay, f[1])
    for s = 1, f[2] do
      local x, y = floor(px + dx * s + 0.5), floor(py + dy * s + 0.5)
      c:put(x, y, s == f[2] and "#ffe08a" or (s < 2 and STAM[1] or STAM[2]))
    end
  end
end

-- stipule spines: tiny hooked pairs at each node
local function spines(t)
  local nx, ny = node(t)
  local x, y = floor(nx + 0.5), floor(ny + 0.5)
  c:put(x - 2, y - 2, SPINE[3]) c:put(x - 3, y - 2, SPINE[2])
  c:put(x + 2, y + 2, SPINE[2]) c:put(x + 2, y + 3, SPINE[1])
end
spines(0.42) spines(0.72)

G.save2(c, NAME)
