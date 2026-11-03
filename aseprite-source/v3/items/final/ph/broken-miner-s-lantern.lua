-- broken-miner-s-lantern (final, Opus single pass). Slim standing lantern: steel wire bail, brass chimney with vent
-- holes, domed brass cap, a bulging glass globe (bright rim, pale core, warm flame glow, cool tint), two bowed steel
-- guard posts, a small flame on a brass burner, and a brass fuel font (cylinder light, rolled lip, wick knob).
-- Ground shadow. broken: a jagged hole knocked out of the globe (dark interior, bright crack lines), the shard flies
-- off to the right with a small chip. quirk: a moth clings to the glass, drawn to the light.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new("broken-miner-s-lantern")
local ST, BR, GL = A.STEEL, A.BRASS, A.GLASS
local CX = 32

c:groundShadow(CX, 53, 13, 1)
-- bail (wire loop)
local bail = A.geo({ { 24, 17 }, { 23, 6 }, { 41, 6 }, { 40, 17 } }, function() return 0.7 end)
A.paint(c, bail, ST, { name = "bail" })
A.streak(c, bail, -0.9, -0.2, 0.25, 0.5)
-- chimney
local chim = HP.rrect(29, 11, 35, 17, 1)
local cg = A.slab(c, chim, 1.5, BR, { name = "chimney" })
c:put(30, 14, BR[1], cg.tok) c:put(32, 14, BR[1], cg.tok) c:put(34, 14, BR[1], cg.tok) -- vent holes
for x = 29, 35 do c:put(x, 11, x < 32 and BR[6] or BR[5], cg.tok) end
-- cap: dome + rim band
local dome = HP.ellipse(CX, 20, 8, 3.5):clip(HP.rect(0, 0, 63, 20)):add(HP.rect(23, 20, 41, 22))
local glassM = HP.ellipse(CX, 32.5, 7.5, 9.5):clip(HP.rect(0, 23, 63, 42))
local posts = { A.geo({ { 24, 22 }, { 21.5, 30 }, { 21.5, 36 }, { 24, 43 } }, function() return 0.8 end),
                A.geo({ { 40, 22 }, { 42.5, 30 }, { 42.5, 36 }, { 40, 43 } }, function() return 0.8 end) }
local pm = posts[1].m:copy():add(posts[2].m)
local font = HP.rrect(22, 43, 42, 50, 2)

-- glass globe
do
  local n = {}
  glassM:each(function(x, y)
    local nx, ny = (x - CX) / 8, (y - 32.5) / 10
    local q = 1 - nx * nx - ny * ny
    n[K(x, y)] = { nx, ny, sqrt(max(q, 0.05)) }
  end)
  local bias = {}
  X.ao(bias, glassM, dome, 1, -1) X.ao(bias, glassM, pm, 1, -1) X.ao(bias, glassM, font, 1, -1)
  local idx, tok = A.tone(c, glassM, n, { GL[2], GL[3], GL[3], GL[4], GL[4], GL[5] }, { bias = bias, name = "glass", amb = 0.35, wrap = 0.5 })
  -- warm flame glow inside the glass
  glassM:each(function(x, y)
    local d = sqrt((x - CX) ^ 2 + ((y - 35) * 0.9) ^ 2)
    if d < 3.6 then c:put(x, y, "#ffe9a6", tok) elseif d < 5.6 then c:put(x, y, "#cfe8b4", tok) end
  end)
  -- bright rim on the lit (left) side, cool dark rim on the shade side
  glassM:edge():each(function(x, y)
    if x < CX - 3 and y < 38 and y > 24 then c:put(x, y, GL[6], tok) elseif x > CX + 4 and y > 30 then c:put(x, y, GL[1], tok) end
  end)
  -- vertical glare streak
  for y = 26, 31 do c:put(27, y, GL[6], tok) end c:put(28, 27, GL[6], tok) c:put(28, 26, A.CREAM, tok)
  -- the hole: dark interior, broken edge, bright crack lines
  local hole = HP.poly{ { 34, 24.5 }, { 38.5, 24 }, { 39.5, 29.5 }, { 37.5, 28 }, { 36, 31 }, { 35, 27.5 } }:clip(glassM)
  c:fillMask(hole, "#3b2c48")
  hole:each(function(x, y) if not hole:has(x - 1, y) or not hole:has(x, y - 1) then c:put(x, y, "#5a4468", tok) end end)
  hole:grow(1):cut(hole):clip(glassM):each(function(x, y) c:put(x, y, GL[5], tok) end)
  for _, p in ipairs{ { 34, 28 }, { 33, 29 }, { 33, 30 }, { 32, 31 }, { 36, 32 }, { 36, 33 }, { 37, 34 }, { 33, 24 }, { 32, 23 } } do
    if glassM:has(p[1], p[2]) then c:put(p[1], p[2], GL[6], tok) end
  end
  -- hole pixels must still count as solid (the back of the lantern shows through)
  hole:each(function(x, y) c.own[y * c.w + x] = tok end)
end
-- flame + burner
do
  local tk = A.tok("flame")
  A.map(c, { "..e..", ".ega.", ".egc.", "egcge", ".egge", "..e.." }, CX - 2, 31, { e = "#e8493b", g = "#f5b82e", a = "#ffe38a", c = A.CREAM }, tk)
  local burner = HP.rrect(28, 38, 36, 42, 1)
  A.slab(c, burner, 1.2, BR, { name = "burner" })
  c:put(CX, 37, "#2b1c26", tk) -- wick
end
-- cap over the glass top
local dg = A.slab(c, dome, 2, BR, { name = "cap" })
for x = 23, 41 do c:put(x, 22, (x < 33) and BR[3] or BR[2], dg.tok) end -- rim underside
c:put(26, 18, BR[6], dg.tok) c:put(27, 18, BR[6], dg.tok)
-- guard posts
for _, p in ipairs(posts) do A.paint(c, p, ST, { name = "post" }) A.streak(c, p, -0.9, -0.2, 0.1, 0.9) end
-- fuel font: vertical cylinder light
do
  local m, n = X.cyl(32, 42, 32, 51, function() return 10.5 end, font)
  local fg = A.paint(c, { m = font, n = n }, BR, { name = "font", amb = 0.12 })
  local tok = fg.tok
  for x = 22, 42 do c:put(x, 44, (x < 30) and BR[6] or (x < 37 and BR[5] or BR[3]), tok) c:put(x, 45, (x < 34) and BR[2] or BR[1], tok) end
  c:put(26, 47, BR[6], tok) c:put(27, 47, BR[6], tok)
  -- rivets
  for _, x in ipairs{ 25, 32, 39 } do c:put(x, 48, BR[2], tok) end
  -- wick knob on the right
  local knob = HP.rrect(43, 45, 45, 47, 0)
  local kg = A.slab(c, knob, 1, BR, { name = "knob" })
  c:put(44, 46, BR[2], kg.tok)
end
-- flying shard + chip
A.chip(c, { { 45, 18 }, { 49.5, 20 }, { 46, 23 } }, GL)
A.chip(c, { { 48, 25 }, { 50, 25 }, { 49, 27 } }, GL)
-- quirk: a moth on the glass (left side)
do
  local tk = A.tok("moth")
  A.map(c, { "w.w", "wbw", ".b." }, 25, 33, { w = "#c9b2f0", b = "#5a459e" }, tk)
  c:put(24, 33, "#8a6fd0", tk) c:put(28, 33, "#8a6fd0", tk)
end
A.save(c, "broken-miner-s-lantern")
