-- Keel Drift (cs-keel-drift), yard sprite 64x64. Opus second pass (art-2701-pals-all/c08/opus2), redrawn from ../haiku.
-- Rare, thornblade. "Glides past the reef with a slow wink and a very old shell."
-- An old green sea turtle gliding right with its head turned to us: a high-domed, weathered olive-brown carapace
-- with ink-lined scutes and pale growth rings, a gold-trimmed marginal rim (rare), cream barnacles and a tuft of
-- weed, a pale plastron edge, long paddle flippers (far pair darker), teal-green scaly skin.
-- Fixes: the Haiku flat green dome on land legs is now a real sea turtle (paddle flippers, scutes, plastron);
-- the head faces the viewer so the wink reads (one locked eye, one closed arc), and the shell shows its age.
-- quirk: the slow wink.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("cs-keel-drift-yard", 64)

local SHEL = { "#2e2418", "#4a3a20", "#6e5a2a", "#94803a", "#b8a65a", "#dccf8c" }
local SKIN = { "#16343a", "#215650", "#337a66", "#52a27e", "#86c896", "#c0e8b8" }
local SKNB = { "#16343a", "#215650", "#2a6a5c", "#3a8a6a", "#52a27e" }
local GOLD = { "#7a3a1c", "#b85c1f", "#e08a26", "#f5b82e", "#ffd970", "#fff0b0" }
local PLAS = { "#8a6a3a", "#c4a060", "#e8cc8a", "#f8ecc0" }
local BNC = "#2a6a8a"

c:groundShadow(30, 59, 21, 2)

local function flip(p, w0, ramp, o)
  local m, n = O.tube(p, function(t) return w0 * (.65 + math.sin(math.pi * t) * .55) * (1 - t * .45) end)
  local I, T = O.shadeN(c, m, n, ramp, { amb = .25, wrap = .35, sep = SKIN[1], bounce = o and BNC, bmax = 2 })
  -- scale spots
  O.tex(c, I, T, ramp, function(x, y, i) if O.H(x, y, 17) > .9 and i >= 3 then return 1 end end)
  return m
end
-- far flippers (behind the shell, darker)
flip({ { 42, 26 }, { 46, 20 }, { 52, 15 }, { 57, 12 } }, 2.6, SKNB)
flip({ { 14, 30 }, { 10, 27 }, { 6, 26 }, { 4, 25 } }, 1.8, SKNB)

-- neck + head (head turned toward us)
local neck = O.tube({ { 42, 34 }, { 46, 33 }, { 48, 31 }, { 50, 30 } }, function() return 4 end)
O.shade(c, neck, SKIN, { R = 3, amb = .25, wrap = .35, sep = SKIN[1] })

-- plastron edge, peeking under the carapace
local plas = c:ellipse(28, 41, 15, 3)
O.shade(c, plas, PLAS, { R = 2, amb = .35, cuts = { .3, .55, .8 }, sep = SHEL[1] })

-- carapace
local shell = c:ellipse(28, 30, 19, 13)
shell:cut(c:rect(0, 41, 63, 63))
local sI, sT = O.shade(c, shell, SHEL, { sphere = { 23, 23, 21 }, amb = .25, wrap = .4, sep = SHEL[1], rim = true, bounce = BNC, bmax = 2 })
-- weathering speckle
O.tex(c, sI, sT, SHEL, function(x, y, i) local h = O.H(x, y, 23) if h > .92 and i >= 2 then return -1 end if h < .05 and i >= 3 then return 1 end end)
-- scute seams: a central row of three hexagons + rib seams down to the rim
local seams = {
  { 18, 22 }, { 20, 20 }, { 24, 19 }, { 27, 21 }, { 31, 19 }, { 35, 20 }, { 38, 22 },
  { 18, 22 }, { 17, 26 }, { 19, 29 }, { 24, 30 }, { 27, 28 }, { 31, 30 }, { 36, 29 }, { 38, 26 }, { 38, 22 },
}
local seamPx = {}
local function seg(a, b)
  local n = math.max(math.abs(b[1] - a[1]), math.abs(b[2] - a[2]), 1)
  for t = 0, n do seamPx[#seamPx+1] = { math.floor(a[1] + (b[1] - a[1]) * t / n + .5), math.floor(a[2] + (b[2] - a[2]) * t / n + .5) } end
end
for i = 1, 6 do seg(seams[i], seams[i + 1]) end
for i = 8, 15 do seg(seams[i], seams[i + 1]) end
seg({ 27, 21 }, { 27, 28 })
seg({ 19, 29 }, { 14, 37 }) seg({ 24, 30 }, { 22, 39 }) seg({ 31, 30 }, { 32, 39 }) seg({ 36, 29 }, { 41, 37 })
seg({ 17, 26 }, { 11, 28 }) seg({ 38, 26 }, { 45, 28 })
local isSeam = {}
for _, q in ipairs(seamPx) do isSeam[q[1] .. "," .. q[2]] = true end
local bev = {}
for _, q in ipairs(seamPx) do
  local bx, by = q[1] + 1, q[2] + 1
  if shell:has(bx, by) and not isSeam[bx .. "," .. by] then bev[#bev+1] = { bx, by } end
end
O.mark(c, bev, SHEL[5])
O.mark(c, seamPx, SHEL[1])
-- growth rings: pale inner outline in two scutes
O.mark(c, { { 22, 22 }, { 23, 21 }, { 24, 21 }, { 25, 22 }, { 30, 21 }, { 31, 21 }, { 32, 22 }, { 33, 22 } }, SHEL[5])
-- gold-trimmed marginal rim
local rim = shell:copy():cut(c:ellipse(28, 28.5, 18, 10.5))
rim:cut(c:rect(0, 0, 63, 31))
O.mark(c, (function() local l = {} rim:each(function(x, y) l[#l+1] = { x, y } end) return l end)(), GOLD[4])
O.mark(c, { { 12, 36 }, { 18, 39 }, { 26, 40 }, { 34, 40 }, { 41, 38 } }, GOLD[5])
O.mark(c, { { 15, 38 }, { 22, 40 }, { 30, 41 }, { 38, 39 }, { 44, 35 } }, GOLD[2])
-- barnacles: cream volcano bumps
for _, b in ipairs({ { 14, 31 }, { 34, 25 }, { 21, 35 } }) do
  O.dots(c, { { b[1], b[2] }, { b[1] + 1, b[2] }, { b[1] - 1, b[2] + 1 }, { b[1] + 2, b[2] + 1 } }, "#efe4c8")
  O.dots(c, { { b[1], b[2] + 1 }, { b[1] + 1, b[2] + 1 } }, "#6e5a4a")
  O.dot(c, b[1], b[2], "#fff4d6")
end
-- weed tuft on top
O.flat(c, c:line({ { 27, 17 }, { 25, 14 }, { 26, 12 } }, 1), "#3f9150", "weed")
O.flat(c, c:line({ { 29, 17 }, { 30, 14 }, { 29, 13 } }, 1), "#7cc35a", "weed")

-- near front flipper sweeping back and down
flip({ { 42, 39 }, { 47, 45 }, { 50, 50 }, { 55, 53 } }, 3.4, SKIN, true)
-- near rear flipper
flip({ { 13, 40 }, { 9, 44 }, { 6, 46 }, { 4, 47 } }, 2.2, SKIN, true)

-- head
local head = c:ellipse(52, 28, 8, 7)
head:add(c:ellipse(53, 32, 6, 4))
local hI, hT = O.shade(c, head, SKIN, { sphere = { 49, 24, 10 }, amb = .28, wrap = .4, sep = SKIN[1], rim = true, bounce = BNC, bmax = 2 })
-- head scutes (pale polygon plates on the crown)
O.mark(c, { { 50, 22 }, { 51, 22 }, { 52, 22 }, { 53, 23 }, { 49, 23 }, { 55, 23 }, { 56, 24 } }, SKIN[3])
O.mark(c, { { 51, 23 }, { 52, 23 }, { 54, 24 } }, SKIN[6])

-- face: open locked eye on the left, wink on the right, beak smile
c:eyeLocked(46, 26)
O.dots(c, { { 54, 29 }, { 55, 28 }, { 56, 28 }, { 57, 28 }, { 58, 29 } }, P.ink) -- winking lid arc
O.dots(c, { { 59, 30 } }, SKIN[2]) -- crow's foot
c:cheek(45, 32) c:cheek(56, 31)
O.dots(c, { { 49, 33 }, { 50, 34 }, { 51, 34 }, { 52, 34 }, { 53, 34 }, { 54, 34 }, { 55, 33 } }, P.ink)
O.dots(c, { { 51, 35 }, { 52, 35 }, { 53, 35 } }, SKIN[2])

O.shift(c, 0, -2)
O.done(c, "cs-keel-drift-yard", function(c)
  -- the gleam of a very old shell
  for _, d in ipairs({ { 0, 0 }, { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do c:put(14 + d[1], 12 + d[2], "#fff4d6") end
  -- glide streaks behind it
  for x = 1, 3 do c:put(x, 37, "#b9e2f5") end
  for x = 1, 2 do c:put(x, 33, "#b9e2f5") end
end)
