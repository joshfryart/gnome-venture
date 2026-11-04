-- garden-gate-straight (final pass, Opus single pass). Front view of one straight fence run: two slim oak posts with
-- turned ball finials, two oak rails nailed ACROSS THE FRONT of a row of weathered, silver-grey dog-eared pickets
-- (flat level top, unlike the arched gate). Grain on every board, nail heads at each crossing, AO under the rails and
-- below each finial neck, 2-tone ground shadow.
-- quirk: a lost red knitted mitten has been pushed onto one picket top for its owner to find.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min = math.floor, math.max, math.min
local c = A.new("garden-gate-straight")
c:groundShadow(32, 55, 24, 2)

-- pickets (behind the rails)
local rails = c:rect(11, 25, 52, 27):add(c:rect(11, 43, 52, 45))
local pick = HP.mask()
local picks = {}
for i = 0, 7 do
  local x0 = 12 + i * 5
  local m = c:rect(x0, 20, x0 + 2, 52)
  m:set(x0 + 1, 19)
  picks[#picks + 1] = m
  pick:add(m)
end
for i, m in ipairs(picks) do
  local b = {}
  A.cast(b, m, rails, 0, 1, -2)
  A.cast(b, m, rails, 0, 2, -1)
  A.board(c, m, A.SILV, { seed = i + 7, R = 1.3, bias = b, knots = (i == 2 and { { 18, 34 } }) or (i == 7 and { { 43, 49 } }) or nil, name = "pk" .. i })
end

-- rails in front, nails at each crossing
local rb = {}
local rtok = select(2, A.board(c, rails, A.OAK, { dir = "h", seed = 4, R = 1.2, bias = rb, name = "rail" }))
for i = 0, 7 do local x0 = 12 + i * 5 A.nail(c, x0 + 1, 25, rtok) A.nail(c, x0 + 1, 43, rtok) end

-- posts with ball finials
local function post(x0)
  local m = c:rect(x0, 18, x0 + 3, 54)
  local b = {}
  for x = x0, x0 + 3 do b[K(x, 18)] = -2 b[K(x, 19)] = -1 end
  local _, tok = A.board(c, m, A.OAK, { seed = x0, R = 1.5, per = 2, bias = b, name = "post" .. x0 })
  -- collar
  for x = x0 - 1, x0 + 4 do c:put(x, 16, x < x0 + 2 and A.OAK[5] or A.OAK[4], tok) c:put(x, 17, x < x0 + 3 and A.OAK[3] or A.OAK[2], tok) end
  -- neck
  for x = x0 + 1, x0 + 2 do c:put(x, 15, x == x0 + 1 and A.OAK[3] or A.OAK[2], tok) end
  -- ball
  local cx, cy = x0 + 1.5, 11.5
  local bm = c:ellipse(cx, cy, 2.5, 2.5)
  local n = X.sphere(cx, cy, 2.5, bm)
  local v = X.light(n, { amb = 0.08, wrap = 0.2 })
  X.tone(c, bm, v, A.OAK, { cuts = A.CUTS, tok = tok })
  c:put(x0 + 1, 10, A.CREAM, tok)
end
post(7) post(53)

-- quirk: red knitted mitten on a picket top (thumb out to the left, ribbed cuff below)
local R = { "#4e1630", "#7e1f36", "#b52e3f", "#e04a42", "#ff7f5c", "#ffb48a" }
local mtok = { r = { name = "mitten" } }
A.map(c, {
  "...cdc..",
  "..cdedc.",
  "..cdeddb",
  "cc.cddcb",
  "cdccddcb",
  ".bccdccb",
  "..bccccb",
  "..fafafa",
  "..ewewew",
  "..fafafa",
}, 34, 15, { f = R[1], w = "#f2e2c4", a = R[2], b = R[2], c = R[3], d = R[4], e = R[5] }, mtok)
c:put(38, 16, R[6], mtok)
c:put(37, 19, R[2], mtok) c:put(39, 20, R[2], mtok) -- knit stitches

A.save(c, "garden-gate-straight")
