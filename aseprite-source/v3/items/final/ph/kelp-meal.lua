-- kelp-meal (final, Opus single pass). A slim, tall burlap sack with a rolled-down cuff, brimming with a domed heap
-- of dark olive kelp meal (granular: teal, olive and brown flecks, per-pixel dome light). A slim wooden scoop leans
-- out of the heap; a small spill of meal sits at the foot. Burlap: diagonal weave, rolled cuff with lit roll edge and
-- AO beneath, a faded green kelp-leaf stencil on the front, cool reflected light on the right, 2-tone ground shadow.
-- quirk: a tiny pink spiral seashell has ended up in the spilled meal.
local NAME = "kelp-meal"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local SACK = { "#4a2e2a", "#6e4a34", "#93683f", "#b88a52", "#d6ac6c", "#ecd096" }
local MEAL = { "#1f2a28", "#2f3f30", "#45573a", "#5e7044", "#7e8c52", "#a6ac6c" }
local FLECK = { "#3e7a72", "#7a5a34", "#9fb070" }
local WOOD = { "#51302b", "#74452e", "#9a6438", "#bd844a", "#dba566", "#f0c78c" }
local STEN = { "#6f8a52", "#5c7848" }
local SHELL = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }

c:groundShadow(32, 53, 16, 2)
-- sack body: slightly bellied, slim
local body = HP.mask()
for y = 20, 52 do
  local t = (y - 20) / 32
  local hw = 11.5 + 2.2 * sin(pi * min(1, t * 0.95)) ^ 0.8 - (y > 50 and (y - 50) * 1.2 or 0)
  for x = floor(32 - hw + .5), floor(32 + hw - 0.5) do body:set(x, y) end
end
local bn = A.blend(body, { { X.pillow(body, 6), 1 }, { select(2, X.cyl(32, 0, 32, 64, function() return 14 end, body)), 0.7 } })
-- cuff: rolled band
local cuff = HP.mask()
for y = 16, 22 do local hw = 13.5 + (y == 16 and -0.6 or 0) + (y == 22 and -0.4 or 0)
  for x = floor(32 - hw + .5), floor(32 + hw - 0.5) do cuff:set(x, y) end end
local cn = select(2, X.cyl(32, 15.5, 32, 22.5, function() return 4 end, nil))
local cnn = {}
cuff:each(function(x, y) local k = K(x, y) local s = (y - 19) / 3.6 s = max(-0.95, min(0.95, s))
  local edge = abs(x - 32) / 14
  cnn[k] = { A.norm(edge * (x < 32 and -0.6 or 0.6), s, sqrt(1 - s*s)) } end)
-- heap: dome of meal above the cuff
local heap = c:ellipse(32, 16, 12, 8):clip(c:rect(0, 0, 63, 17))
heap:add(c:ellipse(32, 16.5, 12, 2))
local hn = X.sphere(30, 15, 13, heap)

-- scoop handle behind the heap? no: planted in it, painted after the heap
local stok = { r = { name = "sack" } }
local sb = {}
X.ao(sb, body, cuff, 2, -1)
local sidx = A.shade(c, body, bn, SACK, { tok = stok, bias = sb, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, amb = 0.1, wrap = 0.3 })
-- weave: diagonal twill, darker on every 3rd diagonal, pale fleck on crossings
body:each(function(x, y) local k = K(x, y) local i = sidx[k]
  if (x + y * 2) % 4 == 0 then c:put(x, y, SACK[max(1, i - 1)], stok)
  elseif (x - y) % 6 == 0 and i >= 3 then c:put(x, y, SACK[min(6, i + 1)], stok) end end)
-- stencil: faded kelp leaf with bladder on the front
local leaf = A.tube({ { 28, 46 }, { 26, 40 }, { 34, 38 }, { 33, 30 } }, function(t) return 2.0 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.6 end)
leaf:each(function(x, y) c:put(x, y, (x + y) % 5 == 0 and STEN[2] or STEN[1], stok) end)
for _, p in ipairs{ { 28, 47 }, { 29, 47 }, { 28, 48 }, { 29, 48 } } do c:put(p[1], p[2], STEN[2], stok) end
-- cool reflected light on the right edge, darker belly crease at the bottom
local rim = X.rim(bn)
body:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.5 and x > 36 and y > 26 then c:put(x, y, "#6a5a72", stok) end end)
for x = 24, 40 do if body:has(x, 50) then c:put(x, 50, SACK[2], stok) end end

-- cuff
local ctok = { r = { name = "cuff" } }
local cidx = A.shade(c, cuff, cnn, SACK, { tok = ctok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.12, wrap = 0.3 })
cuff:each(function(x, y) local k = K(x, y)
  if (x * 2 + y) % 4 == 0 then c:put(x, y, SACK[max(1, cidx[k] - 1)], ctok) end end)
for x = 19, 45 do if cuff:has(x, 22) then c:put(x, 22, SACK[1], ctok) end end   -- roll underside
-- frayed thread ends at the cuff corners
c:put(18, 21, SACK[4]) c:put(46, 18, SACK[3])

-- heap
local mtok = { r = { name = "meal" } }
local mb = {}
heap:each(function(x, y) if y >= 16 then mb[K(x, y)] = -1 end end)
local midx = A.shade(c, heap, hn, MEAL, { tok = mtok, bias = mb, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, amb = 0.1, wrap = 0.35 })
heap:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, 11)
  local i = midx[k]
  if h < 0.12 then c:put(x, y, FLECK[1], mtok)
  elseif h < 0.2 then c:put(x, y, FLECK[2], mtok)
  elseif h < 0.27 and i >= 4 then c:put(x, y, FLECK[3], mtok)
  elseif h > 0.9 then c:put(x, y, MEAL[max(1, i - 1)], mtok) end end)

-- scoop: slim handle out of the heap to the upper right, bowl buried
local wtok = { r = { name = "scoop" } }
local wm, wn = X.cyl(37, 13, 48, 6, function(t) return 1.4 end)
wm:cut(heap:copy():clip(c:rect(0, 11, 63, 63)))
local widx = A.shade(c, wm, wn, WOOD, { tok = wtok, cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 }, amb = 0.12 })
wm:each(function(x, y) if (x * 3 + y) % 7 == 0 then c:put(x, y, WOOD[max(1, widx[K(x, y)] - 1)], wtok) end end)
-- end grain cap and a contact shadow on the heap
c:put(48, 6, WOOD[6]) c:put(49, 7, WOOD[5])
for _, p in ipairs{ { 37, 14 }, { 38, 14 }, { 39, 13 }, { 38, 15 } } do if heap:has(p[1], p[2]) then c:put(p[1], p[2], MEAL[1], mtok) end end
c:put(36, 12, MEAL[5], mtok)

-- spill at the foot, right side, with the shell (quirk)
local spill = c:ellipse(46, 52, 6, 2):clip(c:rect(0, 0, 63, 53))
spill:cut(body)
local spn = X.sphere(45, 52, 6, spill)
local pidx = A.shade(c, spill, spn, MEAL, { tok = mtok, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, amb = 0.1 })
spill:each(function(x, y) if X.hash(x, y, 5) < 0.18 then c:put(x, y, FLECK[1], mtok) end end)
c:paint({ ".ab", "bcb", "dbd" }, 48, 49, { a = SHELL[4], b = SHELL[3], c = SHELL[1], d = SHELL[2] })
A.save(c, NAME)
