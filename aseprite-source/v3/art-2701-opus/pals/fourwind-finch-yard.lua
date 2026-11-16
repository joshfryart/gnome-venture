-- Fourwind Finch (mw-fourwind-finch), yard sprite 64x64. Opus pass, art-2701-opus.
-- Wayfinder, uncommon. A plump chaffinch-like finch facing the viewer: slate-blue cap, rosy face
-- and breast, chestnut wings with cream wing bars, stubby gold beak, thin legs.
-- quirk: four tail feathers fanned like a compass rose, each tipped with a needle point; the
-- north feather is red. (Points four ways, right about two.)
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("fourwind-finch-yard", 64)

local SLATE = { "#26314f", "#384a78", "#506a9e", "#7090c0", "#98b4da", "#c4d8ee" }
local ROSE  = { "#7a3040", "#a84a50", "#d06c60", "#e8907a", "#f6b49a", "#fcd6c0" }
local BRN   = { "#4a2a26", "#6e3c2e", "#94573a", "#b5764a", "#d09864", "#e8bc88" }
local OLIVE = { "#2f3f2a", "#4a5e34", "#6a7e42", "#8ca056", "#b0c274", "#d0dc98" }
local BEAK  = { "#6e4a2a", "#a87838", "#d8a848", "#f0cc70", "#fbe6a4" }
local LEG   = { "#7a4a4a", "#b07468", "#d49a88" }
local TIPS  = { "#e8493b", "#f5e6c0", "#f5e6c0", "#f5e6c0" }

c:groundShadow(30, 58, 15, 3)

-- quirk: compass tail, four feathers fanned behind the body (drawn first)
local base = { 38, 43 }
local angs = { -66, -30, 5, 40 } -- degrees from east, north feather first
local lens = { 26, 23, 21, 18 }
for i, a in ipairs(angs) do
  local r = math.rad(a)
  local L = lens[i]
  local ex, ey = base[1] + math.cos(r) * L, base[2] + math.sin(r) * L
  local mx, my = base[1] + math.cos(r) * L * .5, base[2] + math.sin(r) * L * .5
  local fm, fn, fT = O.tube({ base, { mx, my }, { mx + (ex - mx) * .5, my + (ey - my) * .5 }, { ex, ey } }, function(t)
    if t > .62 then return math.max(.4, 3.3 * (1 - (t - .62) / .38) ^ .8) end
    return 1.3 + 2.0 * t / .62 end)
  local fb = {}
  fm:each(function(x, y) if (fT[K(x, y)] or 0) > .74 then fb[K(x, y)] = 9 end end)
  O.shadeN(c, fm, fn, SLATE, { amb = .25, wrap = .4, sep = SLATE[1] })
  -- needle tip
  fm:each(function(x, y) local t = fT[K(x, y)] or 0 if t > .8 then O.mark(c, { { x, y } }, (t > .88 or i > 1) and TIPS[i] or "#b52e3f") end end)
  -- rachis (shaft)
  for s = 4, 14 do
    local t = s / 20
    local x, y = math.floor(base[1] + math.cos(r) * L * t + .5), math.floor(base[2] + math.sin(r) * L * t + .5)
    if fm:has(x, y) then O.mark(c, { { x, y } }, SLATE[2]) end
  end
end
-- north tip darker edge for the red needle
O.dots(c, {}, P.ink)

-- legs
for _, x in ipairs({ 25, 33 }) do
  for y = 49, 56 do O.dot(c, x, y, LEG[2]) end
  O.dots(c, { { x - 2, 57 }, { x - 1, 57 }, { x, 57 }, { x + 1, 57 }, { x + 2, 57 } }, LEG[2])
  O.dots(c, { { x - 2, 57 }, { x, 56 } }, LEG[3])
end

-- body + head
local body = c:ellipse(29, 38, 14, 13)
local head = c:ellipse(29, 23, 11, 10)
local bird = body:copy():add(head)
O.shade(c, bird, ROSE, { sphere = { 27, 30, 18 }, amb = .2, wrap = .35 })
-- cap + nape: slate over the top of the head
local cap = head:copy():clip(c:poly{ { 10, 0 }, { 50, 0 }, { 50, 22 }, { 40, 19 }, { 29, 17 }, { 18, 19 }, { 10, 22 } })
O.shade(c, cap, SLATE, { sphere = { 27, 22, 12 }, amb = .25, wrap = .35 })
-- pale belly
local belly = c:ellipse(29, 46, 7, 4):clip(body)
O.shade(c, belly, { ROSE[4], ROSE[5], ROSE[6], "#fde8d8", "#fdf0e0" }, { R = 2, amb = .4 })

-- breast feather scallops (tiny v marks) and a brow line under the cap
for _, q in ipairs({ { 25, 33 }, { 31, 34 }, { 28, 37 }, { 34, 38 }, { 24, 39 } }) do
  O.mark(c, { { q[1] - 1, q[2] }, { q[1], q[2] + 1 }, { q[1] + 1, q[2] } }, ROSE[3])
end
cap:each(function(x, y) if not cap:has(x, y + 1) and head:has(x, y + 1) then O.mark(c, { { x, y } }, SLATE[2]) end end)

-- wings at the sides, chestnut with two cream wing bars
local function wing(s)
  local m = function(x) return 29 + s * (x - 29) end
  local w = c:poly{ { m(17), 30 }, { m(13), 36 }, { m(13), 44 }, { m(17), 50 }, { m(21), 46 }, { m(21), 34 } }
  w:clip(body:grow(1))
  O.shade(c, w, BRN, { R = 2, amb = .25, sep = BRN[1] })
  for _, y in ipairs({ 39, 43 }) do
    for x = math.min(m(14), m(20)), math.max(m(14), m(20)) do
      if w:has(x, y + math.floor(s * (x - 29) > 0 and 0 or 0)) then O.mark(c, { { x, y } }, "#f5e6c0") end
    end
  end
  O.mark(c, { { m(16), 47 }, { m(17), 48 } }, BRN[2])
end
wing(1) wing(-1)

-- beak: short seed-cracker cone pointing down-left
O.dots(c, { {27,27},{28,27},{29,27},{30,27},{31,27}, {27,28},{28,28},{29,28},{30,28}, {28,29},{29,29} }, BEAK[3])
O.dots(c, { {27,27},{28,27} }, BEAK[5]) O.dots(c, { {31,27},{30,28},{29,29} }, BEAK[2])
O.dots(c, { {28,28} }, BEAK[4])

-- face
c:eyeLocked(21, 21)
c:eyeLocked(32, 21)
c:cheek(19, 27) c:cheek(37, 27)

O.shift(c, -3, 0)
O.done(c, "fourwind-finch-yard")
