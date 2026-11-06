-- chamomile-seed (final, Opus aB1r1_3). Three tiny curved, ribbed achenes (straw-olive, pale ribs) lying on a torn
-- broad leaf scrap (horizontal, midrib + swept veins, pale torn tissue, cool reflected margin, AO + contact shadows).
-- A fourth seed has sprouted: slim pale stem with two feathery, thread-fine chamomile leaves (rachis + paired pinnules).
-- quirk: the seedling is impatient and already wears a tiny chamomile bud, gold dome with cream petal tips.
local NAME = "chamomile-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r1_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, cos, sin = math.floor, math.abs, math.max, math.min, math.cos, math.sin
local c = A.new(NAME)
local LEAF = { "#173f36", "#22573f", "#2f7448", "#47944e", "#6cb457", "#a2d272" }
local SEED = { "#4a3a24", "#6e5a30", "#93803e", "#b5a253", "#d3c47a", "#efe4a8" }
local STEM = { "#3f7a4c", "#6fa85e", "#a2cf80", "#d2eaa8" }
local FEA = { "#2f7448", "#4f9a50", "#7fc25e", "#b6e080" }

local seeds = { { 15, 48, 3.3, 1.5, 0.35 }, { 22, 51, 3.2, 1.5, -0.25 }, { 28, 47, 3.1, 1.4, 0.75 }, { 36, 50, 3.0, 1.5, -0.1 } }
local cast = {}
for i, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7) cast[i] = s.m end

-- stem mask first so the scrap gets its contact shadow too
local sp = { { 37, 49 }, { 35, 40 }, { 39, 31 }, { 37, 21 } }
local sm, sn = A.tube(sp, function(t) return 0.95 + 0.25 * (1 - t) end)
cast[#cast + 1] = sm

A.scrap(c, { 7, 50, 30, 59, 60, 45 }, { w = 7.8, tear = 0.82, ramp = LEAF, vein = "#c6e690", cool = "#3d6f78",
  torn = "#cfe39a", casters = cast, veinPer = 6.5, notch = { 20, 43.5, 1.6 } })

-- stem
local stok = A.tok("stem")
sm:cut(seeds[4].m)
A.shade(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })

-- feathery leaves: rachis + paired thread pinnules (bipinnate look); lit pixels on the upper side
local ftok = A.tok("frond")
local function frond(pts, dir)
  -- rachis
  for i = 0, 40 do
    local x, y = A.bez(pts, i / 40)
    c:put(floor(x + .5), floor(y + .5), FEA[2], ftok)
  end
  for j = 1, 5 do
    local t = j / 6
    local x, y = A.bez(pts, t)
    local x2, y2 = A.bez(pts, min(1, t + 0.02))
    local tx, ty = x2 - x, y2 - y local l = math.sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
    local L = 3.6 - t * 1.6
    for _, sd in ipairs{ -1, 1 } do
      local nx, ny = -ty * sd, tx * sd
      local ex, ey = x + (nx * 0.8 + tx * 0.6) * L, y + (ny * 0.8 + ty * 0.6) * L
      local up = (ny < 0)
      A.pline(c, { { floor(x + .5), floor(y + .5) }, { floor(ex + .5), floor(ey + .5) } }, up and FEA[3] or FEA[1], ftok)
      c:put(floor(ex + .5), floor(ey + .5), up and FEA[4] or FEA[2], ftok)
    end
  end
  local x, y = A.bez(pts, 1)
  c:put(floor(x + .5), floor(y + .5), FEA[4], ftok)
end
frond({ { 36, 37 }, { 31, 33 }, { 26, 32 }, { 20, 27 } })
frond({ { 38, 31 }, { 43, 29 }, { 48, 27 }, { 52, 22 } })
frond({ { 38, 26 }, { 34, 23 }, { 31, 20 }, { 29, 15 } })
-- re-draw stem core over frond roots
for i = 0, 30 do local x, y = A.bez(sp, i / 30) c:put(floor(x + .5), floor(y + .5), i > 20 and STEM[3] or STEM[2], stok) end

-- quirk: bud (gold dome, cream petal tips, green sepal cup)
local btok = A.tok("bud")
local bm = c:ellipse(37, 17, 2.5, 2)
local bn = X.sphere(37, 17, 2.5, bm)
A.shade(c, bm, bn, { "#8f4a1f", "#c97a1e", "#eba52a", "#f8c84a", "#ffe38a" }, { cuts = { 0.2, 0.45, 0.65, 0.85 }, tok = btok })
for _, q in ipairs{ { 34, 19 }, { 36, 20 }, { 38, 20 }, { 40, 19 } } do c:put(q[1], q[2], q[1] < 37 and A.CREAM or "#e6dcc0", btok) end
for _, q in ipairs{ { 35, 21 }, { 36, 21 }, { 37, 21 }, { 38, 21 }, { 39, 21 } } do c:put(q[1], q[2], STEM[2], btok) end
c:put(36, 15, "#fff1b8", btok)

-- seeds: curved ribbed achenes
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = A.tok("seed" .. i)
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  local v0 = X.light(s.n, { amb = 0.1, wrap = 0.3 })
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    local v = flip * (-dx * sa + dy * ca) / (s[4] + .45)
    local i2 = floor(v0[k] * 5.5) + 1
    -- ribs: pale rib on the lit side of the long axis, a dark furrow below it
    if v > -0.25 and v < 0.25 then i2 = i2 + 1 end
    if v >= 0.25 and v < 0.7 then i2 = i2 - 1 end
    if abs(u) > 0.8 then i2 = i2 - 1 end
    if sb[k] then i2 = i2 - 1 end
    c:put(x, y, SEED[max(1, min(6, i2))], tok)
  end)
end
-- glint on the front seed
c:put(13, 47, SEED[6], A.tok("seed1"))

A.save(c, NAME)
