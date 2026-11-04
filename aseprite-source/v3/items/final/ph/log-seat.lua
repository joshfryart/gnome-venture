-- log-seat (final, Opus single pass aC21_1). A half-log bench: a long split log, flat sawn top, round bark belly,
-- on four slim splayed stick legs pegged through the seat (front legs lit, back legs in shadow).
-- Material: sawn top with long grain lines, a ringed knot, a bright bevel on the front edge and wedged peg ends;
-- bark belly with per-pixel cylinder light and long fissures; pale end grain with rings on the left end; AO under the
-- seat on the legs; ground shadow. quirk: somebody left an acorn on the seat.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("log-seat")
local BARK = { "#2e1b20", "#45282a", "#5f3a31", "#7c4f3b", "#9a6a4b", "#b98a62" }
local TOP  = { "#8a5634", "#a86e42", "#c48b54", "#dcaa6c", "#eec68a", "#fbe2b0" }
local LEG  = { "#33201f", "#4d3029", "#6a4433", "#8a5c40", "#aa7a52", "#c99a6a" }
local GOLD = { "#6e3a1c", "#9a5a24", "#c47e2c", "#e0a23c", "#f5c65a", "#ffe79a" }
c:groundShadow(32, 50, 25, 2)

-- legs: back pair first (in shadow), front pair after the seat? no: legs sit under the seat, so all legs first
local seat = c:rect(10, 22, 55, 34):add(c:ellipse(55, 28, 3, 6))
local function leg(ax, ay, bx, by, back)
  local m, n = X.cyl(ax, ay, bx, by, function(t) return 1.5 + 0.2 * (1 - t) end)
  local bias = {}
  m:each(function(x, y) local k = K(x, y)
    if back then bias[k] = -1 end
    if y <= 37 then bias[k] = (bias[k] or 0) - 1 end            -- AO under the seat
  end)
  local idx = A.shade(c, m, n, LEG, { bias = bias })
  -- a growth node on the stick
  local mx, my = floor(ax + (bx - ax) * 0.55 + .5), floor(ay + (by - ay) * 0.55 + .5)
  A.step(c, idx, LEG, mx, my, -1) A.step(c, idx, LEG, mx + 1, my, -1)
  return m
end
leg(22, 30, 24, 47, true) leg(42, 30, 40, 47, true)
leg(17, 31, 12, 50) leg(48, 31, 53, 50)

-- bark belly: horizontal cylinder, lower half visible
local bm, bn, BT, BS = X.cyl(9, 26, 58, 26, function() return 8 end)
bm:clip(seat):cut(c:rect(0, 0, 63, 26))
local bb = {}
bm:each(function(x, y) if y == 27 then bb[K(x, y)] = -1 end end)   -- shadow under the top's bevel
local bi = A.shade(c, bm, bn, BARK, { bias = bb })
-- long bark fissures
bm:each(function(x, y) local k = K(x, y)
  if y >= 28 and (y % 2 == 1) and X.hash(floor(x / 4), y, 7) > 0.45 then A.step(c, bi, BARK, x, y, -1) end
end)
for _, x in ipairs{ 24, 37, 50 } do c:put(x, 30, BARK[1]) c:put(x, 31, BARK[2]) end   -- cross cracks

-- sawn top face (flat, facing up toward the light)
local top = c:rect(11, 22, 55, 26):add(c:ellipse(55, 24, 2, 2)):clip(seat:copy():add(c:ellipse(55, 24, 2, 2)))
local tn = {}
top:each(function(x, y) tn[K(x, y)] = { -0.15, -0.55, 0.82 } end)
local tb = {}
top:each(function(x, y) if x >= 52 then tb[K(x, y)] = -1 end end)
local ti = A.shade(c, top, tn, TOP, { bias = tb })
-- grain lines along the length, gently wavy
for _, g in ipairs{ { 23, 0.0 }, { 25, 1.3 } } do
  for x = 12, 53 do
    local y = g[1] + ((math.sin(x * 0.35 + g[2]) > 0.6) and -1 or 0)
    if top:has(x, y) and X.hash(x, y, 3) > 0.15 then A.step(c, ti, TOP, x, y, -1) end
  end
end
-- knot with a ring
A.map(c, { ".ab.", "acca", ".ab." }, 34, 23, { a = TOP[2], b = TOP[3], c = TOP[1] })
-- bevel: bright front edge of the top, deep row of the back edge
for x = 12, 54 do c:put(x, 26, TOP[6]) end
for x = 11, 54 do c:put(x, 22, TOP[3]) end
-- wedged peg ends of the front legs
for _, p in ipairs{ { 17, 24 }, { 47, 24 } } do
  A.map(c, { "ab", "bc" }, p[1], p[2], { a = LEG[5], b = LEG[3], c = LEG[2] })
  c:put(p[1] + 1, p[2], LEG[1])
end

-- left end grain (cut face of the split log)
local ef = c:ellipse(10, 28, 3, 6):clip(c:rect(0, 22, 63, 63))
local en = X.pillow(ef, 1.2)
local ei = A.shade(c, ef, en, TOP, { amb = 0.2, wrap = 0.5, bias = {} })
ef:each(function(x, y) local d = sqrt(((x - 10) * 1.9) ^ 2 + (y - 27) ^ 2)
  if d > 1.5 and abs(d % 2.6 - 1.3) < 0.45 then A.step(c, ei, TOP, x, y, -1) end end)
ef:edge():each(function(x, y) if y > 26 then c:put(x, y, (x < 10) and BARK[4] or BARK[2]) end end)
c:put(9, 23, TOP[6]) c:put(10, 23, TOP[6])

-- quirk: an acorn left on the seat
A.map(c, {
  ".hggf.",
  "hggfee",
  "fefefe",
  ".aabc.",
  ".aabc.",
  "..bc..",
}, 41, 17, { h = GOLD[5], g = GOLD[4], f = GOLD[3], e = GOLD[2], a = "#d9b07e", b = "#b07a48", c = "#7a4a2e" })
c:put(43, 16, LEG[2])
c:put(42, 20, "#fff4d6")
A.save(c, "log-seat")
