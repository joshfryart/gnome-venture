-- picket-fence-straight (final, Opus single pass). Front view of one straight fence panel: two slim natural-wood
-- posts with two-plane pyramid caps, two rails behind, five white-painted pointed pickets nailed on.
-- Material: bevelled boards with grain, chipped paint showing wood, iron nail heads, contact shadow of pickets on
-- the rails, AO where pickets meet rails and posts meet ground, paler end grain on the cap boards. Ground shadow.
-- quirk: a little snail is climbing the fourth picket.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_5.lua")
local HP, X, K = A.HP, A.X, A.K
local c = A.new("picket-fence-straight")
local P, W, I = A.PAINT, A.WOOD, A.IRON

c:groundShadow(31, 50, 26, 2)

-- rails (behind pickets)
for i, ry in ipairs{ 22, 39 } do
  local rm = c:rect(12, ry, 50, ry + 2)
  A.board(c, rm, W, { R = 1.2, dir = "h", seed = i * 3, name = "rail" })
end
-- posts
local function post(x0, seed)
  local pm = c:rect(x0, 11, x0 + 4, 50)
  A.board(c, pm, W, { R = 1.8, dir = "v", seed = seed, name = "post", knot = { x0 + 2, 33 } })
  -- cap board (end grain paler on its left face)
  local cm = c:rect(x0 - 1, 9, x0 + 5, 10)
  A.cast(c, cm, 1, 1, -1)
  A.board(c, cm, W, { R = 1, grain = false, name = "cap" })
  c:put(x0 - 1, 9, W[6]) c:put(x0 - 1, 10, W[5])
  -- pyramid finial
  local fm = HP.mask()
  for y = 5, 8 do local h = y - 5 for x = x0 + 2 - h, x0 + 2 + h do if x >= x0 and x <= x0 + 4 then fm:set(x, y) end end end
  A.pyramid(c, fm, x0 + 2, W)
  -- AO at the foot
  for x = x0, x0 + 4 do A.step(c, x, 50, -1) A.step(c, x, 49, -1) end
  -- rail meets post: dark joint
  for _, ry in ipairs{ 22, 39 } do for y = ry, ry + 2 do A.step(c, x0 == 7 and x0 + 5 or x0 - 1, y, -1) end end
end
post(7, 2) post(50, 5)

-- pickets
local xs = { 15, 22, 29, 36, 43 }
local pick = {}
for i, x in ipairs(xs) do
  local m = HP.mask()
  local top = 14 + ((i == 2 or i == 5) and 1 or 0)
  m:set(x + 1, top) m:set(x + 2, top)
  for y = top + 1, 48 do for xx = x, x + 3 do m:set(xx, y) end end
  A.cast(c, m, 1, 1, -1)
  A.cast(c, m, 2, 1, -1)
  A.board(c, m, P, { R = 1.4, dir = "v", seed = i * 7, dens = 0.22, name = "picket" })
  -- AO where the picket crosses the rail lines (rail seen through the gap edge)
  for _, ry in ipairs{ 22, 39 } do A.step(c, x + 3, ry + 3, -1) end
  -- nail heads
  c:put(x + 1, 23, I[2]) c:put(x + 1, 40, I[2]) c:put(x + 2, 23, I[4])
  pick[i] = m
end
-- chipped paint showing bare wood
for _, p in ipairs{ { 24, 30 }, { 25, 30 }, { 24, 31 }, { 44, 44 }, { 45, 44 }, { 45, 45 }, { 18, 17 } } do
  c:put(p[1], p[2], W[4]) end
c:put(25, 31, W[3]) c:put(45, 46, W[3])
-- pop: one bright paint glint
c:put(15, 17, P[6]) c:put(29, 18, A.CREAM)

-- quirk: a snail climbing picket 4 (x 37..40), shell sticks out to the right
A.map(c, {
  "e..e....",
  ".b.b....",
  ".bbb....",
  ".bbD.kk.",
  ".bbkSSSk",
  ".bbSsgsSk",
  ".bbSsGgSk",
  ".bbkSssSk",
  ".bbDkSSk.",
  ".bD..kk..",
  "..D......",
}, 36, 24, { k = "#6e2038", S = "#c94f84", s = "#f5809f", g = "#ffc4d8", G = "#fff1cf", b = "#8f9a52", D = "#4f5a32", e = "#2b1c26" })
A.save(c, "picket-fence-straight")
