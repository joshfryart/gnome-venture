-- broken-masterwork-wheel-hoe (final, Opus single pass). Side view: a spoked steel wheel (beaded rim, eight spokes,
-- domed brass hub), a slim ash beam (grain) rising to a turned T-grip in red lacquer with brass caps, a steel fork
-- strap from the hub, a brass clamp collar holding the steel shank, and a flat sweep blade (honed bright edge) skimming
-- the ground. Ground shadow under wheel and blade.
-- broken: the rim has cracked open at the upper left (a gap with a snapped spoke stub), a rim chip flies off.
-- quirk: a daisy is stuck between the spokes.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, sin, cos, pi, atan = math.floor, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi, math.atan
local c = A.new("broken-masterwork-wheel-hoe")
local ST, BR, WD, RD = A.STEEL, A.BRASS, A.WOOD, A.RED

local WX, WY, RO, RI = 17, 43, 9.5, 7.4
c:groundShadow(28, 54, 16, 1)

-- wheel geometry
local wheelOuter = HP.ellipse(WX, WY, RO, RO)
local rim = wheelOuter:copy():cut(HP.ellipse(WX, WY, RI, RI))
local GAP0, GAP1 = -2.75, -2.38 -- radians (screen coords): upper-left
local function ang(x, y) return atan(y - WY, x - WX) end
local gap = HP.mask()
rim:each(function(x, y) local a = ang(x, y) if a > GAP0 and a < GAP1 then gap:set(x, y) end end)
rim:cut(gap)
-- beam + fork + blade geometry
local beam = A.geo({ { 22, 38 }, { 47, 12 } }, function(t) return 1.3 end)
local fork = A.geo({ { WX, WY }, { 23, 37 } }, function() return 1.0 end)
local grip = A.geo({ { 42, 8 }, { 53, 18 } }, function(t) if t < 0.1 or t > 0.9 then return 1.3 end return 1.5 + 0.35 * sin(t * pi) end)
local shank = A.geo({ { 31, 29 }, { 32, 47 }, { 33, 49 }, { 35, 51 } }, function() return 1.0 end)
local blade = HP.poly{ { 29, 50 }, { 44, 50.5 }, { 45, 52.6 }, { 28, 52.6 } }

-- spokes (behind the rim): 1 px with a lit / shade pair
local spokes = HP.mask()
local stok = A.tok("spokes")
for i = 0, 7 do
  local a = i * pi / 4 + 0.5
  local r1 = (a % (2 * pi) > 2 * pi + GAP0 and a % (2 * pi) < 2 * pi + GAP1 + 0.25) and 4.2 or RI + 0.5 -- snapped spoke
  for r = 2.5, r1, 0.25 do
    local x, y = floor(WX + cos(a) * r + .5), floor(WY + sin(a) * r + .5)
    spokes:set(x, y)
    c:put(x, y, (cos(a) + sin(a) < 0) and ST[4] or ST[3], stok)
  end
end
-- rim: steel ring, sphere-ish normals so the top-left reads lit; a bead groove along the middle
do
  local n = {}
  rim:each(function(x, y)
    local dx, dy = x - WX, y - WY
    local r = sqrt(dx * dx + dy * dy)
    local m = (r - (RI + RO) / 2) / ((RO - RI) / 2 + 0.5)
    local nx, ny = dx / r * m, dy / r * m
    n[K(x, y)] = { nx * 0.8 + dx / r * 0.25, ny * 0.8 + dy / r * 0.25, 0.75 }
  end)
  local idx, tok = A.tone(c, rim, n, ST, { ao = { fork.m }, name = "rim" })
  rim:each(function(x, y) local dx, dy = x - WX, y - WY local r = sqrt(dx * dx + dy * dy)
    if r > 8.15 and r < 8.85 and dx + dy > 4 then c:put(x, y, ST[2], tok) end
    if r > 8.15 and r < 8.85 and dx + dy < -6 then c:put(x, y, ST[6], tok) end
  end)
  -- raw broken ends of the rim: dark faces
  rim:each(function(x, y) local a = ang(x, y)
    if (a > GAP0 - 0.13 and a <= GAP0) or (a >= GAP1 and a < GAP1 + 0.13) then c:put(x, y, ST[2], tok) end end)
end
-- quirk: a daisy wedged between the spokes (lower right of the hub)
do
  local tk = A.tok("daisy")
  A.map(c, { ".c.", "cyc", ".cs" }, WX + 2, WY + 2, { c = A.CREAM, y = "#f5b82e", s = "#d6c9b0" }, tk)
  c:put(WX + 5, WY + 5, A.LEAF[4], tk) c:put(WX + 6, WY + 6, A.LEAF[3], tk)
end
-- fork strap over the wheel + domed brass hub
A.paint(c, fork, ST, { name = "fork" })
A.streak(c, fork, -0.7, -0.3, 0.1, 0.9)
A.ball(c, WX, WY, 2.4, BR, { amb = 0.15 })
c:put(WX, WY, BR[2])
-- shank + sweep blade
A.paint(c, shank, ST, { name = "shank", ao = { beam.m } })
A.streak(c, shank, -0.7, -0.3, 0.1, 0.6)
local bl = A.slab(c, blade, 1.2, ST, { ao = { shank.m }, name = "blade" })
blade:each(function(x, y) if not blade:has(x, y - 1) and x > 30 then c:put(x, y, ST[6], bl.tok) end end) -- honed top edge
-- beam (wood) with grain; brass clamp collar where the shank meets it
A.paint(c, beam, WD, { name = "beam", ao = { fork.m } })
A.grain(c, beam, 11)
A.streak(c, beam, -0.75, -0.45, 0.2, 0.7, WD[6], 4)
do
  local col = A.sub(beam, 0.3, 0.42)
  local g = A.paint(c, col, BR, { name = "collar" })
  A.band(c, beam, 0.36, BR, g.tok, true)
  -- collar is a hair proud of the beam
  local x, y, px, py = A.at(beam, 0.36)
  for _, s in ipairs{ -2, 2 } do c:put(floor(x + px * s + .5), floor(y + py * s + .5), s < 0 and BR[5] or BR[2], g.tok) end
end
-- end grain at the top of the beam, under the grip
-- T-grip: red lacquer, brass caps
do
  local mid, caps = A.sub(grip, 0.1, 0.9), HP.mask()
  A.sub(grip, 0, 0.1).m:each(function(x, y) caps:set(x, y) end) A.sub(grip, 0.9, 1).m:each(function(x, y) caps:set(x, y) end)
  A.paint(c, mid, RD, { name = "grip", ao = { caps } })
  A.streak(c, mid, -0.7, -0.35, 0.15, 0.6, RD[6], 4)
  A.slab(c, caps, 1, BR, { name = "caps" })
  -- beam tenon shadow on the grip
  local bx, by = A.at(beam, 1)
  c:put(floor(bx + 1.5), floor(by + 1.5), RD[2], mid.tok)
end
-- flying rim chip (from the gap, upper left)
A.chip(c, { { 4, 29 }, { 7.5, 28 }, { 6.5, 30.5 }, { 4, 31 } }, ST)
A.save(c, "broken-masterwork-wheel-hoe")
