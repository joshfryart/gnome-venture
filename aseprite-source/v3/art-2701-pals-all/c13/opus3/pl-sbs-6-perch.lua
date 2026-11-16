-- Silverback Spool (pl-sbs-6), perch sprite 36x36. Opus second pass (c13/opus2), hand-built at this size.
-- Upright spool of wound silver silk between two wood flanges with a peg, eight jointed charcoal spider legs
-- splaying from behind, 2x3 pill eyes on the silk, humming "o" mouth.
-- quirk: still humming: two notes drifting up off the top left. Rare: one sparkle.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-sbs-6-perch", 36)

local WOOD = { "#3a2018", "#5e3426", "#8a5232", "#b47844", "#d9a066", "#f2c890" }
local SILK = { "#3e3f58", "#5e6484", "#8b93b0", "#b6bfd4", "#dae1f0", "#f1f4fb" }
local LEG  = { "#1c1824", "#2c2838", "#433e58", "#5f5a7a", "#8a86a6" }

c:groundShadow(18, 32, 13, 1.5)
local legs = {
  { { 12, 12 }, { 8, 8 }, { 4, 9 }, { 2, 15 } },
  { { 12, 17 }, { 7, 13 }, { 3, 16 }, { 2, 22 } },
  { { 12, 22 }, { 8, 19 }, { 4, 23 }, { 3, 28 } },
  { { 12, 26 }, { 9, 25 }, { 6, 28 }, { 7, 32 } },
}
for side = -1, 1, 2 do
  for _, L in ipairs(legs) do
    local p = {}
    for i, q in ipairs(L) do p[i] = { side < 0 and q[1] or 35 - q[1], q[2] } end
    local m, n = O.tube(p, function(t) return .75 - t * .25 end)
    O.shadeN(c, m, n, LEG, { amb = .35, wrap = .4, sep = LEG[1], rim = true })
  end
end
local barrel = c:rect(11, 8, 24, 28)
local bn = {}
barrel:each(function(x, y)
  local sx = math.max(-.95, math.min(.95, (x - 17.5) / 7.5))
  bn[K(x, y)] = { sx, -.15, math.sqrt(1 - sx * sx) }
end)
local bI, bT = O.shadeN(c, barrel, bn, SILK, { amb = .28, wrap = .45, rim = true, bounce = "#7a8ab8", bmax = 3 })
O.tex(c, bI, bT, SILK, function(x, y, i) if y % 2 == 0 and i >= 2 and not (y >= 13 and y <= 20 and x >= 13 and x <= 22) then return -1 end end)
local function flange(cy, top)
  local rimm = HP.mask()
  for dy = 0, 2 do rimm:add(c:ellipse(17.5, cy + dy, 9.5, 2.2)) end
  O.shade(c, rimm, WOOD, { R = 2, amb = .3, wrap = .45, sep = WOOD[1], rim = true })
  if top then
    local fI, fT = O.shade(c, c:ellipse(17.5, cy, 9.5, 2.2), WOOD, { R = 1, amb = .45, wrap = .5, sep = WOOD[2] })
    O.tex(c, fI, fT, WOOD, function(x, y, i) if math.abs(x - 17.5) > 4 and math.abs(x - 17.5) < 5.2 then return -1 end end)
  end
end
flange(26, false)
flange(6, true)
O.shade(c, c:rect(16, 2, 19, 6), WOOD, { R = 1, amb = .35, wrap = .45, sep = WOOD[1], rim = true })
O.flat(c, (O.tube({ { 24, 25 }, { 28, 26 }, { 27, 31 }, { 31, 31 } }, function() return .45 end)), SILK[5], "loose")

c:eyeSmall(13, 14)
c:eyeSmall(20, 14)
O.dot(c, 12, 18, P.petal.base) O.dot(c, 23, 18, P.petal.base)
O.dots(c, { { 17, 19 }, { 18, 19 }, { 16, 20 }, { 19, 20 }, { 17, 21 }, { 18, 21 } }, P.ink)
O.dots(c, { { 17, 20 }, { 18, 20 } }, "#8a3a5a")

O.done(c, "pl-sbs-6-perch", function(c)
  local function note(x, y, h)
    c:put(x, y, P.ink) c:put(x + 1, y, P.ink) c:put(x, y + 1, P.ink) c:put(x + 1, y + 1, P.ink)
    for k = 1, h do c:put(x + 2, y + 1 - k, P.ink) end
    c:put(x + 3, y + 2 - h, P.ink)
  end
  note(2, 5, 4)
  note(7, 1, 3)
  c:sparkle(31, 3)
end)
