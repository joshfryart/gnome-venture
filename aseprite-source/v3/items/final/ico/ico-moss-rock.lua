-- ico-moss-rock (Opus single pass). A squat rounded boulder with a moss cushion draped over its crown.
-- Rock: pillow bevel + 4 px block facets on a 6-tone warm-grey stone ramp (cool-violet deep), one crack with a lit
-- lip, a chipped facet, pale lichen flecks, cool reflected light on the lower-right edge, 2-tone ground shadow.
-- Moss: a chain of small cushion bumps along the crown (each its own sphere normal) over a draped body with three
-- drips, 6-tone green with a dark AO row on the rock beneath the moss and dark pockets between the bumps.
-- quirk: one tiny red toadstool has popped up out of the moss.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA7_1.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
local c = A.new("ico-moss-rock")
local ST = { "#35304a", "#504b60", "#6f6b7a", "#928e98", "#b6b2b4", "#d8d5cc" }
local MO = { "#1f4a3e", "#2c6a44", "#3f8a48", "#62aa4e", "#8fc95a", "#c2e07a" }
local LICH = "#d9d48a"
local BOUNCE = "#8a9ac4"
local function nrm(a, b, cc) local l = sqrt(a*a + b*b + cc*cc) return { a / l, b / l, cc / l } end

c:groundShadow(32, 50, 22, 2)
local rock = c:poly{ { 10, 49 }, { 7, 44 }, { 8, 36 }, { 12, 29 }, { 18, 24 }, { 26, 21 }, { 35, 20 }, { 44, 22 }, { 51, 27 }, { 55, 34 }, { 57, 42 }, { 55, 48 }, { 52, 49 } }
-- top-of-rock per column
local top = {}
rock:each(function(x, y) if not top[x] or y < top[x] then top[x] = y end end)
-- normals: pillow bevel + block facets
local pn = X.pillow(rock, 4)
-- voronoi facets: each facet tilts the normal a little, so the boulder reads as knapped stone, not a balloon
local seeds = { { 15, 38, -0.25, 0.1 }, { 22, 30, 0.1, -0.2 }, { 30, 39, -0.15, 0.15 }, { 39, 31, 0.2, -0.1 },
  { 46, 40, 0.15, 0.2 }, { 24, 46, 0.05, 0.25 }, { 52, 33, -0.1, -0.2 }, { 38, 46, -0.2, 0.05 } }
local rn, fac = {}, {}
rock:each(function(x, y) local k = K(x, y)
  local ex, ey = (x - 32) / 26.5, (y - 37) / 19
  local q = max(0.05, 1 - ex*ex - ey*ey)
  local best, bs
  for i, sd in ipairs(seeds) do local d = (x - sd[1])^2 + (y - sd[2])^2 * 1.3 if not best or d < best then best, bs = d, i end end
  fac[k] = bs
  local p = pn[k]
  local sd = seeds[bs]
  rn[k] = nrm(ex * 0.9 + p[1] * 0.6 + sd[3], ey * 0.7 + p[2] * 0.6 + sd[4], sqrt(q) + p[3] * 0.4)
end)

-- moss body: crown band with drips; cushion bumps along the top edge (may rise above the rock)
local moss = HP.mask()
local depth = function(x) return 6 + floor(2 * math.sin(x * 0.7) + 1.5 * math.sin(x * 0.31 + 1)) end
local drips = { [17] = 6, [18] = 7, [19] = 6, [33] = 5, [34] = 6, [35] = 5, [47] = 4, [48] = 5, [49] = 4 }
rock:each(function(x, y)
  local d = depth(x) + (drips[x] or 0)
  if y <= top[x] + d then moss:set(x, y) end
end)
-- trim moss off the far sides so the rock shows its shoulders
moss:cut(c:rect(0, 0, 10, 63)):cut(c:rect(54, 0, 63, 63))
local bumps = {}
for x = 12, 52, 4 do
  local r = 2.4 + X.hash(x, 1, 3) * 1.2
  bumps[#bumps + 1] = { x + 0.5, top[x] + 1.2, r }
end
local bm = HP.mask()
for _, b in ipairs(bumps) do bm:add(c:ellipse(b[1], b[2], b[3], b[3] * 0.85)) end
moss:add(bm)
local rockOnly = rock:copy():cut(moss)

-- rock paint: AO under the moss (2 rows), crack, chip, lichen, bounce
local rb = {}
X.ao(rb, rockOnly, moss, 2, -1)
local rtok = { r = { name = "rock" } }
local v = X.light(rn, { amb = 0.05, wrap = 0.2 })
local ridx = X.tone(c, rockOnly, v, ST, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = rb, tok = rtok })
-- crack: zig line down the front with a lit lip on its right
local crack = { { 27, 33 }, { 28, 36 }, { 26, 39 }, { 27, 42 }, { 25, 45 } }
for i = 1, #crack - 1 do
  local a, b = crack[i], crack[i + 1]
  local ns = max(abs(b[1] - a[1]), abs(b[2] - a[2]))
  for j = 0, ns do
    local x = floor(a[1] + (b[1] - a[1]) * j / ns + .5)
    local y = floor(a[2] + (b[2] - a[2]) * j / ns + .5)
    if rockOnly:has(x, y) then
      c:put(x, y, ST[1], rtok)
      if rockOnly:has(x + 1, y) then c:put(x + 1, y, ST[min(6, (ridx[K(x + 1, y)] or 3) + 1)], rtok) end
    end
  end
end
-- chipped facet (a flat bright plane with a dark edge below) lower-left
for _, p in ipairs{ { 14, 40 }, { 15, 40 }, { 16, 40 }, { 13, 41 }, { 14, 41 }, { 15, 41 }, { 13, 42 }, { 14, 42 } } do c:put(p[1], p[2], ST[6], rtok) end
for _, p in ipairs{ { 12, 43 }, { 13, 43 }, { 14, 43 }, { 15, 42 }, { 16, 41 }, { 17, 40 } } do c:put(p[1], p[2], ST[2], rtok) end
-- lichen flecks
for _, p in ipairs{ { 20, 37 }, { 21, 37 }, { 38, 41 }, { 44, 36 }, { 45, 36 }, { 33, 46 } } do if rockOnly:has(p[1], p[2]) then c:put(p[1], p[2], LICH, rtok) end end
-- cool reflected light on the lower-right rim
rockOnly:edge():each(function(x, y) if x > 48 and y > 41 and y < 47 and not rockOnly:has(x + 1, y) then c:put(x, y, BOUNCE, rtok) end end)
-- dark contact row along the very bottom
for x = 9, 55 do if rockOnly:has(x, 49) then c:put(x, 49, ST[2], rtok) end end

-- moss paint: body follows the rock curvature, bumps are little spheres; pockets between bumps darken
local mn = {}
moss:each(function(x, y) local k = K(x, y) mn[k] = rn[k] or { -0.3, -0.6, 0.74 } end)
for _, b in ipairs(bumps) do
  local e = c:ellipse(b[1], b[2], b[3], b[3] * 0.85)
  local sn = X.sphere(b[1] - 0.3, b[2] - 0.3, b[3], e)
  for k, n in pairs(sn) do mn[k] = n end
end
local mb = {}
moss:each(function(x, y)
  local k = K(x, y)
  local inBump = bm:has(x, y)
  if not inBump and (bm:has(x, y - 1)) then mb[k] = -2 end       -- shadow under each cushion
  if X.hash(x, y, 7) > 0.83 then mb[k] = (mb[k] or 0) - 1 end    -- tufty texture
end)
local mtok = { r = { name = "moss" } }
local mv = X.light(mn, { amb = 0.08, wrap = 0.25 })
local midx = X.tone(c, moss, mv, MO, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = mb, tok = mtok })
-- sparse bright tips on the lit bumps
for _, b in ipairs(bumps) do
  local x, y = floor(b[1] - b[3] * 0.4 + .5), floor(b[2] - b[3] * 0.45 + .5)
  if moss:has(x, y) and (midx[K(x, y)] or 0) >= 4 then c:put(x, y, MO[6], mtok) end
end
-- drip tips: one dark pixel at the end of each drip
for x, d in pairs(drips) do
  local y = top[x] + depth(x) + d
  if moss:has(x, y) and d >= 5 then c:put(x, y, MO[2], mtok) end
end

-- quirk: tiny toadstool out of the moss (right of centre)
local tx, ty = 40, top[40] - 1
local tm = {
  "..rRRr..",
  ".rRcRRr.",
  "rRRRRcRd",
  "dddddddd",
  "...sS...",
  "...sS...",
}
A.bmp(tm, tx - 3, ty - 6, { r = "#ff7a5a", R = "#e8493b", c = "#fff4d6", d = "#8f2a3c", s = "#d8c4a0", S = "#f6e8c8" })
A.done()
