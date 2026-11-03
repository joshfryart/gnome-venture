-- ico-bouquet (final pass, Opus). A hand-tied bouquet in a kraft-paper cone.
-- Structure: three different blooms (pink rose, white daisy, blue cornflower) packed in the mouth of a slim
-- kraft cone, two long leaves fanning out, the back of the wrap showing behind the flowers, a red satin ribbon
-- tied round the waist of the cone in a bow with two tails.
-- Material: sphere light on the blooms with a rose spiral, ray-split daisy petals, frilled cornflower edge,
-- leaf midribs, paper fold and crinkle lines, AO where the blooms sink into the cone, satin highlight on the ribbon.
-- quirk: a ladybird walking up the right-hand leaf.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_4.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local floor, abs, max, min, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new("ico-bouquet")
local KR, RO, DA, CO, GO, MO, RB = R.kraft, R.rose, R.daisy, R.corn, R.gold, R.moss, R.ribbon

-- back of the wrap (inside of the paper), behind everything
local back = A.poly{ { 18, 31 }, { 20, 21 }, { 30, 16 }, { 45, 17 }, { 48, 28 } }
local nb = {}
back:each(function(x, y) nb[K(x, y)] = { A.norm(0.25 + (x - 33) / 40, 0.3, 0.9) } end)
local ib = A.shadeN(c, back, nb, KR, { cuts = { 0.3, 0.5, 0.66, 0.8, 0.93 } })
back:each(function(x, y) A.step(c, ib, KR, x, y, -1) end)
-- back rim (cut paper edge) lit
back:edge():each(function(x, y) if not back:has(x, y - 1) then A.step(c, ib, KR, x, y, 2) end end)

-- leaves fanning out
local function leaf(ax, ay, cx, cy, bx, by, wmax)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t) return wmax * math.sin(pi * min(1, t * 1.05)) ^ 0.8 end, { fold = 0.5 })
  local idx = A.shadeN(c, m, n, MO, { cuts = { 0.24, 0.42, 0.58, 0.74, 0.88 } })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.16 and T[k] > 0.08 and T[k] < 0.9 then A.setI(c, idx, MO, x, y, idx[k] + 1) end end)
  return m, idx
end
local lL = leaf(21, 30, 12, 24, 9, 12, 3.2)
local lR, iR = leaf(44, 28, 54, 24, 56, 13, 3.2)

-- blooms: sphere-lit discs
local function bloom(m, cx, cy, r, ramp, cuts)
  local n = X.sphere(cx - 0.6, cy - 0.6, r, m)
  return A.shadeN(c, m, n, ramp, { cuts = cuts or { 0.18, 0.34, 0.5, 0.66, 0.82 }, wrap = 0.35 }), n
end

-- cornflower (back, top-centre): frilled edge
local cfx, cfy = 33, 12
local cf = A.ellM(cfx, cfy, 5, 4.6)
for i = 0, 11 do
  local a = i / 12 * 2 * pi
  local x, y = floor(cfx + cos(a) * 6.3 + 0.5), floor(cfy + sin(a) * 5.9 + 0.5)
  cf:set(x, y)
end
local icf = bloom(cf, cfx, cfy, 6, CO)
-- floret slits radiating from the centre
for i = 0, 7 do
  local a = i / 8 * 2 * pi + 0.2
  for rr = 2.5, 4.5, 1 do
    local x, y = floor(cfx + cos(a) * rr + 0.5), floor(cfy + sin(a) * rr + 0.5)
    if cf:has(x, y) then A.step(c, icf, CO, x, y, -1) end
  end
end
-- dark plum centre
for _, p in ipairs{ { 0, 0, "#35295f" }, { -1, 0, "#5a459e" }, { 0, -1, "#5a459e" }, { 1, 0, "#35295f" }, { 0, 1, "#35295f" }, { -1, -1, "#8a6fd0" } } do
  c:put(cfx + p[1], cfy + p[2], p[3]) end

-- daisy (right): white ray petals around a gold disc
local dx, dy = 41, 21
local prev = HP.mask()
for i = 0, 9 do
  local a = i / 10 * 2 * pi + 0.15
  local px, py = dx + cos(a) * 4.4, dy + sin(a) * 4.2
  local m, n = A.oval(px, py, 2.6, 1.3, a)
  local idx = A.shadeN(c, m, n, DA, { cuts = { 0.18, 0.32, 0.48, 0.64, 0.8 }, wrap = 0.4 })
  -- split from earlier petals
  m:each(function(x, y)
    if prev:has(x + 1, y) or prev:has(x - 1, y) or prev:has(x, y + 1) or prev:has(x, y - 1) then
      if not prev:has(x, y) then A.setI(c, idx, DA, x, y, 2) end end end)
  prev:add(m)
end
local disc = A.ellM(dx, dy, 2.2, 2.2)
local idisc = bloom(disc, dx, dy, 2.6, GO)
c:put(dx - 1, dy - 1, A.CREAM)
for _, p in ipairs{ { 1, 1 }, { 0, 2 }, { 2, 0 } } do if disc:has(dx + p[1], dy + p[2]) then c:put(dx + p[1], dy + p[2], GO[2]) end end

-- rose (left, front): sphere + spiral petal lines
local rx, ry = 25, 22
local rose = A.ellM(rx, ry, 6.2, 5.6)
local iro = bloom(rose, rx, ry, 6.5, RO)
local a = 0.3
while a < 2 * pi * 2.1 do
  local rr = 0.7 + a * 0.36
  local x, y = floor(rx + cos(a) * rr + 0.5), floor(ry - 0.5 + sin(a) * rr * 0.9 + 0.5)
  if rose:shrink(1):has(x, y) then
    A.setI(c, iro, RO, x, y, (iro[K(x, y)] or 3) - 2)
    local ix, iy = floor(rx + cos(a) * (rr - 1) + 0.5), floor(ry - 0.5 + sin(a) * (rr - 1) * 0.9 + 0.5)
    if rose:has(ix, iy) and not (ix == x and iy == y) then A.step(c, iro, RO, ix, iy, 1) end
  end
  a = a + 0.12
end
c:put(rx - 3, ry - 3, RO[6]) c:put(rx - 2, ry - 3, RO[6])
-- a small leaf tucked between rose and daisy
local lM = leaf(32, 27, 33, 22, 34, 17, 1.7)

-- front cone (kraft)
local cone = A.poly{ { 16.5, 28.5 }, { 23, 30.5 }, { 31, 28 }, { 40, 29.5 }, { 48.5, 25.5 }, { 34.5, 58 }, { 32, 58 } }
local nc = {}
local fold = function(y) return 31 + (y - 28) * 0.06 end   -- fold line x at row y
cone:each(function(x, y)
  local left = x < fold(y)
  local u = (x - fold(y)) / 14
  if left then nc[K(x, y)] = { A.norm(-0.35 + u * 0.4, -0.15, 0.92) }
  else nc[K(x, y)] = { A.norm(0.55 + u * 0.3, 0.05, 0.82) } end
end)
local bc = {}
cone:each(function(x, y) -- crinkle lines
  local h = X.hash(floor((y + x * 0.35) / 1), 3, 17)
  if (floor(y + x * 0.35) % 7 == 0) and x < fold(y) then bc[K(x, y)] = -1 end
  if (floor(y - x * 0.5) % 8 == 0) and x > fold(y) + 1 then bc[K(x, y)] = -1 end
end)
local ic = A.shadeN(c, cone, nc, KR, { bias = bc, cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 } })
-- fold line: lit ridge + dark valley
for y = 28, 58 do
  local fx = floor(fold(y) + 0.5)
  if cone:has(fx, y) then A.setI(c, ic, KR, fx, y, 6) end
  if cone:has(fx + 1, y) then A.step(c, ic, KR, fx + 1, y, -1) end
end
-- cut paper top edge: lit rim, AO on the flowers just above it
cone:edge():each(function(x, y)
  if not cone:has(x, y - 1) then
    A.step(c, ic, KR, x, y, 1)
    A.darken(c, x, y - 1, -1)
    if not cone:has(x, y - 2) then A.darken(c, x, y - 2, -1) end
  end
end)

-- red satin ribbon round the waist + bow
local rbY = 44
local band = HP.mask()
for x = 20, 46 do for y = rbY, rbY + 2 do
  local yy = y + floor((x - 33) * 0.06 + 0.5)
  if cone:has(x, yy) then band:set(x, yy) end end end
band:each(function(x, y)
  local t = y - (rbY + floor((x - 33) * 0.06 + 0.5))
  local i = t == 0 and 5 or (t == 1 and 4 or 2)
  if x > 34 then i = i - 1 end
  c:put(x, y, RB[max(1, i)])
end)
for x = 20, 46 do A.darken(c, x, rbY + 3 + floor((x - 33) * 0.06 + 0.5), -1) end
A.map(c, {
  ".aab.....bbc.",
  "abbbbc.cbbbcd",
  "abbccdkdcccdd",
  ".bcccdkddddd.",
  "..ccd.k.dcd..",
  "...........",
}, 27, rbY - 2, { a = RB[6], b = RB[5], c = RB[4], d = RB[2], k = RB[1] })
-- knot
c:put(33, rbY, RB[5]) c:put(32, rbY + 1, RB[4]) c:put(33, rbY + 1, RB[3]) c:put(34, rbY + 1, RB[2])
-- tails
A.map(c, {
  "ab..cd",
  "ab..cd",
  "ab...cd",
  "bb...cd",
  "ab....cd",
  "b......d",
}, 30, rbY + 3, { a = RB[5], b = RB[4], c = RB[3], d = RB[2] })

-- quirk: ladybird on the right leaf
local lx, ly = 53, 18
A.map(c, {
  ".kk.",
  "abbc",
  "akbd",
  ".cd.",
}, lx, ly, { k = A.INK, a = "#ff7a5c", b = "#e8493b", c = "#b52e3f", d = "#6e2038" })
c:put(lx, ly + 1, "#ffb08a")

A.save(c, "ico-bouquet")
