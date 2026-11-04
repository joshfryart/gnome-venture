-- box-hedge-gate (final pass, Opus aB10_1). Two slim clipped boxwood pillars joined by a clipped hedge arch, with a
-- wooden picket gate set between them: pillars in 3/4 view (lit tops, shaded fronts), arch shaded as a leafy tube,
-- pickets with rounded tops, grain lines and bevelled edges, rails + diagonal brace casting a contact shadow on the
-- pickets, dark iron strap hinges, a latch ring with a bright specular; AO where the gate meets the pillars.
-- quirk: a little brass key hangs from the latch ring on a loop of string.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min = math.floor, math.max, math.min
local NAME = "box-hedge-gate"
local c = A.new(NAME)
local F, H, OY = 0.55, 22, 46
c:groundShadow(32, OY + 10 * F + 1, 26, 1)
-- arch (behind the pillar tops)
local ptop = OY + 5 * F - H
local am, an, AT, AS = A.tube({ { 13, ptop + 3 }, { 13, ptop - 19 }, { 51, ptop - 19 }, { 51, ptop + 3 } }, function(t) return 3.4 end)
local aface = {} am:each(function(x, y) aface[K(x, y)] = "arch" end)
local ab = {}
am:each(function(x, y) local k = K(x, y) if AS[k] > 0.55 then ab[k] = -1 end end)
local atok = { r = { name = "arch" } }
A.foliage(c, am, aface, { seed = 17, base = an, bias = ab, tok = atok, glints = 3, leaf = 0.3 })
-- pillars
local function rr(x, z, x0, x1, z0, z1, r)
  if x < x0 or x > x1 or z < z0 or z > z1 then return false end
  local cx = x < x0 + r and x0 + r or (x > x1 - r and x1 - r or x)
  local cz = z < z0 + r and z0 + r or (z > z1 - r and z1 - r or z)
  return (x - cx)^2 + (z - cz)^2 <= r * r
end
for i, px in ipairs({ 6, 44 }) do
  local function S(x, z) return rr(x, z, px, px + 13, 0, 10, 3) end
  local m, face, Z = A.prism(S, px - 1, px + 15, 0, 10, H, F, OY)
  A.roundCorners(m, 2)
  A.ragged(m, face, Z, 30 + i, 0.3)
  local idx, tok = A.foliage(c, m, face, { seed = 30 + i, Z = Z, ground = true, glints = 3 })
  A.twigs(c, m, idx, 30 + i, tok)
end
-- gate (mid depth): ground line
local GB = floor(OY + 5 * F)   -- bottom row of the gate
local GT = GB - 17
local wt = { r = { name = "gate" } }
local rails = HP.rect(20, GT + 4, 43, GT + 6):add(HP.rect(20, GB - 4, 43, GB - 2))
local brace = HP.line({ { 22, GB - 4 }, { 41, GT + 6 } }, 2)
local front = rails:copy():add(brace)
-- pickets with rounded tops, grain, contact shadow under rails/brace
local px0 = { 20, 24, 28, 32, 36, 40 }
for i, x0 in ipairs(px0) do
  local x1 = (i == #px0) and 43 or x0 + 2
  local top = GT + ((i == 1 or i == #px0) and 0 or 1)
  local b = {}
  for y = top, GB do for x = x0, x1 do
    if front:has(x, y - 1) and not front:has(x, y) then b[K(x, y)] = -2 end
    if front:has(x - 1, y) and not front:has(x, y) then b[K(x, y)] = (b[K(x, y)] or 0) - 1 end
    if x == 20 or x == 43 then b[K(x, y)] = (b[K(x, y)] or 0) - 1 end
    if y >= GB - 1 then b[K(x, y)] = (b[K(x, y)] or 0) - 1 end
  end end
  A.plank(c, x0, top, x1, GB, { vertical = true, bias = b, tok = { r = { name = "pk" .. i } }, seed = i })
  -- rounded top: clear corners
  c.pix[top * 64 + x0], c.own[top * 64 + x0] = nil, nil
  c.pix[top * 64 + x1], c.own[top * 64 + x1] = nil, nil
end
-- rails and brace
local rb = {}
A.plank(c, 20, GT + 4, 43, GT + 6, { seed = 41, tok = { r = { name = "r1" } } })
A.plank(c, 20, GB - 4, 43, GB - 2, { seed = 42, tok = { r = { name = "r2" } } })
local bn = {}
brace:each(function(x, y) bn[K(x, y)] = { A.norm(-0.2, -0.3, 1) } end)
local bv = X.light(bn, { amb = 0.15 })
brace:each(function(x, y) local k = K(x, y) if rails:has(x, y) then return end
  local edge = not brace:has(x + 1, y) or not brace:has(x, y + 1)
  c:put(x, y, edge and A.WOOD[3] or A.WOOD[4], wt) end)
-- rail edges: dark lower row where they sit on the pickets
for x = 20, 43 do c:put(x, GT + 6, A.WOOD[2], wt) c:put(x, GB - 2, A.WOOD[2], wt) c:put(x, GT + 4, A.WOOD[5], wt) c:put(x, GB - 4, A.WOOD[5], wt) end
c:put(21, GT + 4, A.WOOD[6], wt) c:put(22, GT + 4, A.WOOD[6], wt)
-- iron strap hinges on the left (over the rails)
local IR = { "#2f2c3e", "#444663", "#74758c", "#c8c6d4" }
for _, y in ipairs({ GT + 5, GB - 3 }) do
  for x = 20, 25 do c:put(x, y, x == 25 and IR[1] or IR[2], wt) end
  c:put(21, y - 1, IR[3], wt) c:put(20, y - 1, IR[3], wt) c:put(20, y + 1, IR[1], wt) c:put(21, y + 1, IR[1], wt)
  c:put(22, y, IR[4], wt)
end
-- latch ring on the right
local LY = GT + 9
A.map(c, {
  ".abb.",
  "a...c",
  "b...d",
  ".cdd.",
}, 37, LY, { a = IR[4], b = IR[3], c = IR[2], d = IR[1] })
c:put(41, LY - 1, IR[2], wt) c:put(42, LY - 1, IR[1], wt)
-- quirk: brass key on a string loop from the ring
A.map(c, {
  "s....",
  ".s...",
  ".hG..",
  "hGgG.",
  ".Gg..",
  "..g..",
  "..gG.",
  "..g..",
  "..gG.",
}, 38, LY + 4, { s = "#efe0c0", h = "#ffe38a", G = "#f5b82e", g = "#d98322" })
A.save(c, NAME)
