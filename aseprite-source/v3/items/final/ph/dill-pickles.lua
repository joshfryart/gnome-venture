-- dill-pickles (final, Opus single pass). Slim glass jar of pale yellow-green brine: three long warty gherkins
-- (oval normals, bump warts = lit dot over a dark dot), a dill frond and a garlic clove inside, mustard seeds on the floor.
-- Glass: pale left wall + streak, dark right wall with a cool reflected rim, meniscus line, thick pale base.
-- Knurled gold screw lid with a lit top face, glass threads at the neck, kraft label with a dill doodle, ground shadow.
-- quirk: one feathery dill frond escaped under the lid and sticks out sideways.
local NAME = "dill-pickles"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new(NAME)

local BRINE = { "#2f5a48", "#3f7a58", "#5c9a66", "#86b874", "#b2d48a", "#d8eaa8" }
local AIR   = { "#4c7a80", "#6a9ea0", "#8cc0bc", "#b0dcd2", "#d2eee4", "#eef8ee" }
local PICK  = { "#1c3a2c", "#284f32", "#386b38", "#4f873e", "#6fa34c", "#9cc466" }
local GOLD  = { "#6a3a1c", "#8f4a1f", "#c2741f", "#e8a42c", "#f7cf5a", "#ffeaa0" }
local KRAFT = { "#7a5232", "#9c6c40", "#bf8c56", "#d9ac72", "#ecca94", "#f8e4b8" }
local DILL  = { "#1f4a30", "#2e6a3a", "#4d9a4a", "#7cc35a", "#b4dc7a" }

c:groundShadow(32, 56, 14, 1.5)

-- jar body (surface of revolution)
local function bw(y)
  if y <= 19 then return 8.6 elseif y == 20 then return 10.2 elseif y == 21 then return 11.0 end
  if y >= 55 then return 9.6 elseif y == 54 then return 10.6 end
  return 11.4
end
local bm, bn, BU = A.rev(32, 19, 55, bw)
local inner = bm:shrink(1)
local brine, air = HP.mask(), HP.mask()
bm:each(function(x, y) if y >= 23 then brine:set(x, y) else air:set(x, y) end end)
local btok, atok = { r = { name = "brine" } }, { r = { name = "glass" } }
A.shade(c, brine, bn, BRINE, { tok = btok, amb = 0.18, wrap = 0.4 })
A.shade(c, air, bn, AIR, { tok = atok, amb = 0.2, wrap = 0.4 })

-- pickles: long ovals, back two first, front one last (AO on the back ones)
local pk = {
  { 26.5, 38, 13, 3.4, pi / 2 + 0.16 },
  { 38.5, 37, 12, 3.3, pi / 2 - 0.2 },
  { 32.5, 41, 12.5, 3.7, pi / 2 - 0.04 },
}
for _, p in ipairs(pk) do p.m, p.n = A.oval(p[1], p[2], p[3], p[4], p[5], 0.7) p.m:clip(inner) end
for i, p in ipairs(pk) do
  local bias = {}
  for j = i + 1, #pk do X.ao(bias, p.m, pk[j].m, 1, -1) end
  local tok = { r = { name = "pickle" .. i } }
  local idx = A.shade(c, p.m, p.n, PICK, { tok = tok, bias = bias, amb = 0.06, wrap = 0.3 })
  -- warts: lit nub with a shadow pixel below-right
  p.m:each(function(x, y)
    if X.hash(x, y, 7 + i) > 0.84 and p.m:has(x + 1, y + 1) and p.m:has(x - 1, y) and not bias[K(x, y)] then
      A.step(c, idx, PICK, x, y, 2, tok) A.step(c, idx, PICK, x + 1, y + 1, -2, tok)
    end
  end)
  -- faint lengthwise ridge (pickles are ribbed): 1 px lighter line along the lit third
  local ca, sa = cos(p[5]), sin(p[5])
  p.m:each(function(x, y)
    local dx, dy = x - p[1], y - p[2]
    local v = (-dx * sa + dy * ca) / p[4]
    local u = (dx * ca + dy * sa) / p[3]
    if v > -0.55 and v < -0.25 and abs(u) < 0.7 and X.hash(x, y, 3) > 0.35 then A.step(c, idx, PICK, x, y, 1, tok) end
  end)
end

-- dill frond in the brine: wavy stalk, thread-leaf ticks
local dtok = { r = { name = "dill" } }
local fp = { { 36, 53 }, { 33, 44 }, { 40, 34 }, { 35, 25 } }
local last
for i = 0, 40 do
  local x, y = A.bez(fp, i / 40) x, y = floor(x + .5), floor(y + .5)
  if inner:has(x, y) then c:put(x, y, DILL[2], dtok) end
  if i % 5 == 2 and i > 4 then
    local s = (i // 5) % 2 == 0 and 1 or -1
    A.dots(c, { { x + s, y - 1 }, { x + 2 * s, y - 2 } }, DILL[3], dtok)
    c:put(x + 3 * s, y - 2, DILL[4], dtok)
  end
end
-- garlic clove (cream crescent) and mustard seeds on the floor
local gtok = { r = { name = "garlic" } }
A.dots(c, { { 25, 51 }, { 26, 51 }, { 27, 51 }, { 24, 52 }, { 25, 52 }, { 26, 52 }, { 27, 52 }, { 28, 52 } }, "#f2ead0", gtok)
A.dots(c, { { 25, 50 }, { 26, 50 } }, "#fff4d6", gtok)
A.dots(c, { { 28, 51 }, { 28, 53 }, { 27, 53 }, { 26, 53 } }, "#c8bc98", gtok)
for _, q in ipairs{ { 30, 53 }, { 33, 53 }, { 38, 52 }, { 41, 53 }, { 35, 52 } } do
  c:put(q[1], q[2], "#e0a838", dtok) c:put(q[1], q[2] + 1, "#9a6a28", dtok) end

-- kraft label wrapped on the jar
local ltok = { r = { name = "label" } }
local lm = HP.mask()
for y = 43, 50 do for x = 24, 40 do if bm:has(x, y) then lm:set(x, y) end end end
A.shade(c, lm, bn, KRAFT, { tok = ltok, amb = 0.25, wrap = 0.5, cuts = { 0.15, 0.3, 0.5, 0.7, 0.86 } })
for x = 24, 40 do c:put(x, 43, KRAFT[x < 30 and 6 or 5], ltok) c:put(x, 50, KRAFT[2], ltok) end
-- doodle: tiny dill umbel in green ink + two text dashes
A.dots(c, { { 28, 48 }, { 28, 47 }, { 27, 46 }, { 29, 46 }, { 28, 45 }, { 26, 45 }, { 30, 45 } }, DILL[2], ltok)
for x = 32, 38 do if x ~= 35 then c:put(x, 46, KRAFT[2], ltok) end end
for x = 32, 36 do c:put(x, 48, KRAFT[3], ltok) end

-- glass on top: walls, meniscus, streak, base
local gl = { r = { name = "glasswall" } }
bm:edge():each(function(x, y)
  local u = BU[K(x, y)] or 0
  if y >= 54 then c:put(x, y, AIR[3], gl)
  elseif u < -0.2 then c:put(x, y, y < 23 and AIR[6] or "#dcf0d0", gl)
  elseif u > 0.2 then c:put(x, y, y < 23 and AIR[2] or BRINE[1], gl) end
end)
for x = 22, 42 do if inner:has(x, 23) then c:put(x, 23, x < 30 and "#eaf6c4" or BRINE[5], btok) c:put(x, 24, BRINE[3], btok) end end
for x = 22, 42 do if inner:has(x, 53) then c:put(x, 53, x < 28 and AIR[5] or AIR[4], gl) end end
for y = 26, 47 do if y % 9 ~= 4 and not lm:has(23, y) then c:put(23, y, "#f2fae6", gl) end end
for y = 28, 38 do c:put(24, y, "#d8eec8", gl) end
for y = 27, 49 do if not lm:has(41, y) then c:put(41, y, y % 6 == 0 and AIR[4] or "#9ccab8", gl) end end
c:put(24, 20, A.CREAM, gl) c:put(25, 20, A.CREAM, gl) c:put(23, 22, "#eef8ee", gl)

-- neck with glass threads
local nm = HP.mask()
for y = 16, 18 do for x = 24, 40 do nm:set(x, y) end end
local nn = {}
nm:each(function(x, y) local u = (x + .5 - 32.5) / 9 nn[K(x, y)] = { A.norm(u, 0, math.sqrt(max(0.05, 1 - u * u))) } end)
A.shade(c, nm, nn, AIR, { tok = atok, amb = 0.2, wrap = 0.4 })
for x = 24, 40 do c:put(x, 17, x < 31 and AIR[4] or AIR[2], atok) end

-- lid: knurled side band + lit elliptical top
local ktok = { r = { name = "lid" } }
local sm = HP.mask()
for y = 10, 15 do for x = 21, 43 do sm:set(x, y) end end
local sn = {}
sm:each(function(x, y) local u = (x + .5 - 32.5) / 11.5 sn[K(x, y)] = { A.norm(u, 0.15, math.sqrt(max(0.05, 1 - u * u))) } end)
local kidx = A.shade(c, sm, sn, GOLD, { tok = ktok, amb = 0.1, wrap = 0.35 })
sm:each(function(x, y)
  if y >= 11 and y <= 14 and x % 2 == 0 then A.step(c, kidx, GOLD, x, y, -1, ktok) end
  if y == 15 then A.step(c, kidx, GOLD, x, y, -2, ktok) end
end)
local tm = c:ellipse(32.5, 9.5, 11, 2)
local tn = {}
tm:each(function(x, y) local u = (x + .5 - 32.5) / 11.5 tn[K(x, y)] = { A.norm(u * 0.5, -0.45, 1) } end)
A.shade(c, tm, tn, GOLD, { tok = ktok, amb = 0.25, wrap = 0.4, cuts = { 0.15, 0.3, 0.45, 0.62, 0.82 } })
tm:edge():each(function(x, y) if y <= 9 and x < 38 then c:put(x, y, GOLD[6], ktok) end end)
c:put(25, 9, A.CREAM, ktok) c:put(26, 9, A.CREAM, ktok)
-- ambient row where lid meets glass neck
for x = 24, 40 do c:put(x, 16, AIR[1], atok) end

-- quirk: a dill frond poking out sideways from under the lid
local qp = { { 22, 15 }, { 19, 13 }, { 16, 12 }, { 13, 9 } }
for i = 0, 24 do
  local x, y = A.bez(qp, i / 24) x, y = floor(x + .5), floor(y + .5)
  c:put(x, y, DILL[3], dtok)
  if i % 6 == 3 then
    A.dots(c, { { x, y - 1 }, { x - 1, y - 2 } }, DILL[4], dtok) c:put(x - 1, y - 3, DILL[5], dtok)
    A.dots(c, { { x + 1, y + 1 } }, DILL[2], dtok)
  end
end
A.dots(c, { { 12, 8 }, { 11, 8 }, { 12, 7 } }, DILL[4], dtok)

A.save(c, NAME)
