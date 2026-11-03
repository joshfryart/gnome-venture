-- beehive-1 (final pass, Opus). Tier 1 hive: a small coiled-straw skep on a plank stand. The skep is a bell of seven
-- stacked straw rolls; each roll bulges (scalloped silhouette), is lit per pixel as a curved coil on a dome
-- (6-tone straw ramp), carries fine straw streaks and diagonal cane bindings that step from roll to roll, and the
-- seams between rolls get a dark ambient row. A knotted crown tuft caps it. Dark arched entrance at the foot.
-- Stand: a slim plank (lit top face, front face with grain lines, pale end grain with rings) on two thin legs with a
-- 2-tone ground shadow; contact shadow where the skep sits on the plank.
-- History: Sonnet draft (_dA14) replaced.
-- quirk: a glossy honey drip runs out over the entrance lip and hangs off the plank edge as a round drop.
local NAME = "beehive-1"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR4_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local STRAW = { "#5e321e", "#8a5226", "#b4762c", "#d69c3a", "#eec05a", "#ffe08e" }
local BIND  = "#6e3e20"
local WOOD  = { "#3e2422", "#5a3428", "#7c4a30", "#a0663e", "#c48a56", "#e2b07c" }
local HON   = { "#8f4a1f", "#c8761c", "#eea21e", "#ffc83a", "#ffe68a" }
local DARK  = { "#2e1a24", "#45262a" }

-- ---------------------------------------------------------------- ground shadow + stand
c:groundShadow(32, 57, 21, 1.4)
local wtok = { r = { name = "wood" } }
-- legs (vertical grain)
for _, lx in ipairs{ 14, 48 } do
  for y = 51, 56 do
    c:put(lx, y, WOOD[5], wtok) c:put(lx + 1, y, WOOD[4], wtok) c:put(lx + 2, y, WOOD[2], wtok)
  end
  c:put(lx + 1, 53, WOOD[3], wtok) c:put(lx + 1, 54, WOOD[3], wtok)
  c:put(lx, 51, WOOD[2], wtok) c:put(lx + 1, 51, WOOD[1], wtok) c:put(lx + 2, 51, WOOD[1], wtok)   -- ambient under plank
end
-- plank: top face y47, front face y48-50
local PX0, PX1 = 9, 55
for x = PX0, PX1 do
  c:put(x, 47, WOOD[5], wtok)
  c:put(x, 48, WOOD[4], wtok) c:put(x, 49, WOOD[4], wtok) c:put(x, 50, WOOD[3], wtok)
  -- grain: long wavy lines on the front face
  local g = 48.6 + 0.9 * sin(x * 0.23) + 0.5 * sin(x * 0.61 + 1)
  local gy = floor(g + 0.5)
  if x % 9 ~= 4 then c:put(x, gy, WOOD[3], wtok) end
  if X.hash(x, 7, 2) > 0.8 then c:put(x, 47, WOOD[6], wtok) end
end
-- knot on the front face
c:put(40, 49, WOOD[2], wtok) c:put(41, 49, WOOD[1], wtok) c:put(41, 48, WOOD[3], wtok)
-- end grain (left end pale with rings, right end in shade)
for y = 47, 50 do c:put(PX0, y, WOOD[6], wtok) c:put(PX1, y, WOOD[2], wtok) end
c:put(PX0, 48, WOOD[5], wtok) c:put(PX0, 49, WOOD[4], wtok)
c:put(PX1, 47, WOOD[3], wtok)

-- ---------------------------------------------------------------- skep (seven coiled straw rolls)
local CX, YB, YT = 32, 46, 13
local RH = (YB - YT + 1) / 7.3          -- roll height
local sm = HP.mask()
local info = {}
for y = YT, YB do
  local u = (YB + 1 - y) / (YB + 1 - YT)                  -- 0 bottom .. 1 top
  local q = (YB + 0.5 - y) / RH
  local ring, p = floor(q), q - floor(q)                  -- p: 0 bottom of a roll .. 1 top
  local hw = 15.6 * max(0, 1 - u ^ 2.3) ^ 0.55
  if y >= YB - 1 then hw = hw - 0.6 end                   -- slight tuck at the foot
  hw = hw * (0.93 + 0.1 * sin(pi * p))                  -- each roll bulges
  for x = floor(CX - hw - 1), floor(CX + hw + 1) do
    if abs(x + 0.5 - CX) <= hw then
      sm:set(x, y)
      info[K(x, y)] = { u = u, p = p, ring = ring, hw = hw }
    end
  end
end
local n = {}
sm:each(function(x, y) local k = K(x, y) local I = info[k]
  local nx = max(-0.96, min(0.96, (x + 0.5 - CX) / (I.hw + 0.6)))
  local nyc = -(I.p - 0.5) * 1.5
  local nyd = -0.05 - I.u * 0.6
  n[k] = { A.norm(nx * 1.15, nyc + nyd, sqrt(1 - nx * nx) * 0.75) }
end)
local bias = {}
sm:each(function(x, y) local k = K(x, y) local I = info[k]
  if I.p < 0.2 and I.ring > 0 then bias[k] = -2 elseif I.p < 0.34 and I.ring > 0 then bias[k] = -1 elseif I.p > 0.62 and I.p < 0.82 then bias[k] = 1 end
end)
local stok = { r = { name = "skep" } }
local idx = A.shade(c, sm, n, STRAW, { tok = stok, bias = bias, amb = 0.03, wrap = 0.12, cuts = { 0.22, 0.4, 0.56, 0.7, 0.85 } })
-- straw streaks + cane bindings
sm:each(function(x, y) local k = K(x, y) local I = info[k]
  if I.p > 0.38 and I.p < 0.9 then
    local h = X.hash(floor(x / 2), y, I.ring + 3)
    if h > 0.82 then A.step(c, idx, STRAW, x, y, 1, stok) elseif h < 0.1 then A.step(c, idx, STRAW, x, y, -1, stok) end
  end
end)
for r = 0, 7 do
  local yc = floor(YB + 0.5 - (r + 0.55) * RH)
  for x = 0, 63 do
    if (x + r * 4) % 8 == 0 and sm:has(x, yc) and sm:has(x + 1, yc - 1) and sm:has(x - 2, yc) and sm:has(x + 3, yc) then
      local lit = (idx[K(x, yc)] or 3) >= 4
      c:put(x, yc, BIND, stok) c:put(x + 1, yc - 1, BIND, stok)
      if lit then c:put(x - 1, yc, STRAW[6], stok) end    -- bright straw ridge beside the binding
    end
  end
end
-- crown tuft: knotted twist of straw
for _, q in ipairs{ { 31, 12, 5 }, { 32, 12, 4 }, { 33, 12, 3 }, { 31, 11, 4 }, { 32, 11, 3 }, { 32, 10, 5 }, { 33, 10, 2 },
  { 31, 13, 4 }, { 33, 11, 2 }, { 30, 12, 6 }, { 34, 12, 2 } } do c:put(q[1], q[2], STRAW[q[3]], stok) end
c:put(32, 9, STRAW[6], stok)
-- glint on the upper-left of the dome
c:put(24, 22, STRAW[6], stok) c:put(25, 22, STRAW[6], stok)

-- contact shadow: plank top under the skep, front face just below
for x = PX0, PX1 do
  if sm:has(x, YB) then c:put(x, 47, WOOD[3], wtok) c:put(x, 48, WOOD[3], wtok) end
  if sm:has(x - 2, YB) and not sm:has(x, YB) then c:put(x, 47, WOOD[4], wtok) end
end

-- ---------------------------------------------------------------- entrance arch
local em = c:rrect(27, YB - 5, 34, YB, 3)
em:clip(sm)
local etok = { r = { name = "door" } }
em:each(function(x, y) c:put(x, y, (y >= YB - 1 or x >= 32) and DARK[1] or DARK[2], etok) end)
-- shaded straw lip over the arch
em:grow(1):cut(em):each(function(x, y) if sm:has(x, y) and y < YB then A.step(c, idx, STRAW, x, y, -2, stok) end end)
-- faint honey glow deep inside
c:put(29, YB - 1, HON[1], etok) c:put(30, YB - 1, HON[2], etok)

-- ---------------------------------------------------------------- quirk: honey drip
local htok = { r = { name = "honey" } }
-- pool on the plank top in front of the door, run down the front face, round drop hanging below
for _, q in ipairs{ { 29, 47, 4 }, { 30, 47, 5 }, { 31, 47, 4 }, { 32, 47, 3 }, { 30, 48, 4 }, { 31, 48, 3 },
  { 30, 49, 4 }, { 31, 49, 2 }, { 30, 50, 4 }, { 31, 50, 2 }, { 30, 51, 3 }, { 29, 52, 4 }, { 30, 52, 3 }, { 31, 52, 2 },
  { 29, 53, 3 }, { 30, 53, 2 }, { 31, 53, 1 } } do c:put(q[1], q[2], HON[q[3]], htok) end
c:put(29, 52, A.CREAM, htok)

A.save(c, NAME)
