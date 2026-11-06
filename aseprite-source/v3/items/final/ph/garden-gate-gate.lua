-- garden-gate-gate (final pass, Opus single pass). Front view of a little arched picket gate hung between two slim
-- square posts. Cedar pickets (3 px, dog-eared points) on a ledge-and-brace frame seen through the gaps; black-iron
-- strap hinges with nail heads on the left, a thumb-latch bar and ring on the right. Posts: oak with grain, pale
-- chamfered caps. AO where pickets cross rails, contact shadow under every strap, 2-tone ground shadow.
-- quirk: a small brass bell hangs from a hook on the latch post.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, pi, max, min = math.floor, math.sin, math.pi, math.max, math.min
local c = A.new("garden-gate-gate")
c:groundShadow(31, 55, 23, 2)

-- frame behind the pickets: two ledges + diagonal brace
local frame = HP.mask()
local railT = c:rect(13, 27, 50, 29)
local railB = c:rect(13, 45, 50, 47)
local brace = c:line({ { 15, 44 }, { 48, 30 } }, 2.4)
frame:add(railT):add(railB):add(brace)

-- pickets
local pick = HP.mask()
local picks = {}
for i = 0, 7 do
  local x0 = 13 + i * 5
  local t = (x0 + 1 - 13) / 37
  local top = floor(23 - 6 * sin(pi * t) + 0.5)
  local m = c:rect(x0, top + 1, x0 + 2, 50)
  m:set(x0 + 1, top)
  picks[#picks + 1] = m
  pick:add(m)
end

-- frame painted with AO from the pickets in front
local fb = {}
A.cast(fb, frame, pick, 1, 1, -2)
A.cast(fb, frame, pick, 2, 1, -1)
A.board(c, railT:copy():add(railB), A.CEDAR, { dir = "h", bias = fb, seed = 3, R = 1.2, name = "frame" })
local bb = {}
for k, v in pairs(fb) do bb[k] = v end
A.cast(bb, brace, railT:copy():add(railB), 0, 1, -1)
A.board(c, brace:copy():cut(railT):cut(railB), A.CEDAR, { dir = "h", bias = bb, seed = 5, R = 1.0, grain = false, name = "frame" })

-- pickets on top
for i, m in ipairs(picks) do
  A.board(c, m, A.CEDAR, { seed = i, R = 1.3, per = 3, knots = (i == 3 and { { 24, 38 } }) or (i == 6 and { { 40, 33 } }) or nil, name = "picket" .. i })
end

-- posts: oak, 4 px, chamfered pale caps
local function post(x0, top, tag)
  local m = c:rect(x0, top + 2, x0 + 3, 54)
  local idx, tok = A.board(c, m, A.OAK, { seed = x0, R = 1.5, per = 2, name = tag })
  local cap = c:rect(x0 - 1, top, x0 + 4, top + 1)
  cap:set(x0, top - 1) cap:set(x0 + 1, top - 1) cap:set(x0 + 2, top - 1) cap:set(x0 + 3, top - 1)
  cap:each(function(x, y) c:put(x, y, (y < top) and A.OAK[6] or (y == top and (x < x0 + 3 and A.OAK[5] or A.OAK[4]) or (x < x0 + 2 and A.OAK[4] or A.OAK[3])), tok) end)
  for x = x0, x0 + 3 do c:put(x, top + 2, A.OAK[2], tok) end -- shadow under the cap
  return m, tok
end
local lp, ltok = post(8, 11, "postL")
local rp, rtok = post(51, 11, "postR")

-- iron strap hinges (left), nails, shadows under
local itok = { r = { name = "iron" } }
local function strap(y)
  for x = 9, 22 do
    local tail = x > 19
    c:put(x, y, tail and A.IRON[4] or A.IRON[5], itok)
    if not (x == 22) then c:put(x, y + 1, A.IRON[2], itok) end
    if pick:has(x, y + 2) then c:put(x, y + 2, A.CEDAR[2], { r = { name = "sh" } }) end
  end
  c:put(23, y, A.IRON[3], itok)
  c:put(9, y - 1, A.IRON[3], itok) c:put(10, y - 1, A.IRON[4], itok) -- hinge knuckle
  c:put(9, y + 2, A.IRON[1], itok) c:put(10, y + 2, A.IRON[2], itok)
  c:put(14, y, A.IRON[6], itok) c:put(19, y, A.IRON[6], itok) -- nail glints
end
strap(27) strap(45)

-- thumb latch: bar across the gap into a keeper on the right post, ring below
for x = 45, 53 do c:put(x, 34, A.IRON[x < 50 and 5 or 4], itok) c:put(x, 35, A.IRON[2], itok) end
c:put(46, 34, A.IRON[6], itok)
A.map(c, {
  ".abc.",
  "a...c",
  "b...d",
  ".cdd.",
}, 44, 37, { a = A.IRON[5], b = A.IRON[4], c = A.IRON[3], d = A.IRON[1] }, itok)
c:put(46, 36, A.IRON[3], itok)
c:put(52, 33, A.IRON[3], itok) c:put(53, 33, A.IRON[3], itok) c:put(52, 36, A.IRON[1], itok) c:put(53, 36, A.IRON[1], itok)

-- quirk: little brass bell on a hook on the latch post
local GOLD = { "#6a3a1e", "#9a5a1f", "#d08a28", "#f2b938", "#ffe08a", "#fff4d6" }
local gtok = { r = { name = "bell" } }
c:put(55, 17, A.IRON[3], gtok) c:put(56, 17, A.IRON[3], gtok) c:put(56, 18, A.IRON[2], gtok)
A.map(c, {
  ".ed.",
  ".dc.",
  "edcb",
  "dccb",
  "baba",
  ".a..",
}, 55, 19, { e = GOLD[5], d = GOLD[4], c = GOLD[3], b = GOLD[2], a = GOLD[1] }, gtok)
c:put(55, 20, GOLD[6], gtok)

A.save(c, "garden-gate-gate")
