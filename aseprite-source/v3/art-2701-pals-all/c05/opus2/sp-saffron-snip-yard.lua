-- Saffron Snip (sp-saffron-snip), yard sprite 64x64. Opus second pass (art-2701-pals-all/c05/opus2) over the Haiku pass.
-- Seedkeeper, common, Spicepeak. "Snips saffron threads with tiny scissors and hums while picking."
-- A round saffron-gold sprite wearing a lilac crocus bloom as a cap (three cupped petals, veined), with three
-- crimson saffron threads standing up out of the bloom. It holds a pair of tiny scissors (brass finger loops,
-- steel blades, pivot rivet) open round one thread it has just snipped, which drifts off the blade tip. Mouth
-- in a small "o": it is humming.
-- Fixes vs Haiku: the grey X now reads as scissors (loops, pivot, blades), the threads come from a crocus so the
-- saffron read is clear, body has a 6-tone ramp with rim light and a cool bounce, threads have flared tips.
-- quirk: the hum: a little plum music note floating off to the left.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("sp-saffron-snip-yard", 64)

local GLD   = { "#5e2e14", "#93501e", "#c97a24", "#eaa431", "#f6c95a", "#fbe49a" }
local PET   = { "#3a2556", "#5a3a82", "#7f5aae", "#a582d0", "#c8aae6", "#e6d6f6" }
local THR   = { "#5a1218", "#9a1e22", "#d23a2a", "#f06a3a" }
local STEEL = { "#3a3e52", "#6a7088", "#a4aabc", "#dde0e8" }
local BRASS = { "#6a3a12", "#b0701e", "#e6aa3a", "#f8d27a" }
local NOTE  = { "#3a2244", "#6a3e78", "#9a6aac" }
local BNC   = "#7a5a8a"

c:groundShadow(31, 58, 14, 2.5)
for _, fx in ipairs({ 25, 37 }) do
  O.shade(c, c:ellipse(fx, 55.5, 3.5, 2), GLD, { R = 1, amb = .25, sep = GLD[1], rim = true })
end

-- body
local body = c:ellipse(31, 42, 13, 12)
local bI, bT = O.shade(c, body, GLD, { sphere = { 27, 37, 15 }, amb = .25, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
O.tex(c, bI, bT, GLD, function(x, y, i) -- faint pollen freckles
  if (x > 21 and x < 41 and y > 34 and y < 50) then return nil end
  if H(x, y, 7) > .95 and i >= 2 and i <= 5 then return 1 end
end)
O.shade(c, c:ellipse(17.5, 44, 2.5, 4), GLD, { R = 1, amb = .3, sep = GLD[1], rim = true }) -- left arm

-- threads out of the bloom (drawn first; petals overlap the roots)
for _, t in ipairs({ { 29, 26, 25, 12 }, { 31, 24, 31, 9 }, { 33, 26, 37, 12 } }) do
  local m, n = O.tube({ { t[1], t[2] }, { (t[1] * 2 + t[3]) / 3, t[2] - 5 }, { (t[1] + t[3] * 2) / 3, t[4] + 4 }, { t[3], t[4] } }, function() return .7 end)
  O.shadeN(c, m, n, THR, { amb = .3, cuts = { .3, .55, .8 }, sep = THR[1] })
  O.flat(c, c:rect(t[3] - 1, t[4] - 1, t[3] + 1, t[4] - 1), THR[3], "tip") -- flared tip
  O.dot(c, t[3] - 1, t[4] - 1, THR[4])
end
-- crocus cap: three cupped petals
local petals = {
  { c:poly{ { 20, 31 }, { 19, 25 }, { 21, 19 }, { 25, 22 }, { 28, 31 } }, 0 },
  { c:poly{ { 34, 31 }, { 37, 22 }, { 41, 19 }, { 43, 25 }, { 42, 31 } }, -1 },
  { c:poly{ { 26, 31 }, { 27, 22 }, { 31, 16 }, { 35, 22 }, { 36, 31 } }, 0 },
}
for _, pe in ipairs(petals) do
  local m = pe[1]
  m:cut(c:rect(0, 31, 63, 63))
  local bias = {} m:each(function(x, y) bias[K(x, y)] = pe[2] end)
  local pI, pT = O.shade(c, m, PET, { R = 2, bias = bias, amb = .25, wrap = .4, sep = PET[1], rim = true })
end
-- petal veins and the cup's rim on the head
O.mark(c, { { 31, 19 }, { 31, 21 }, { 31, 23 }, { 31, 25 }, { 31, 27 }, { 22, 23 }, { 23, 25 }, { 23, 27 }, { 40, 23 }, { 39, 25 }, { 39, 27 } }, PET[3])
for x = 20, 42 do if c:get(x, 30) then O.mark(c, { { x, 30 } }, PET[2]) end end
for x = 22, 40 do if c:get(x, 31) then O.mark(c, { { x, 31 } }, GLD[2]) end end -- cap shadow on the brow

-- face: humming "o"
c:eyeLocked(24, 34) c:eyeLocked(34, 34)
c:cheek(21, 41) c:cheek(40, 41)
O.dots(c, { { 30, 42 }, { 31, 42 }, { 29, 43 }, { 32, 43 }, { 30, 44 }, { 31, 44 } }, P.ink)
O.dots(c, { { 30, 43 }, { 31, 43 } }, "#a23a3a")

-- scissors in the right hand: blades up-right open round a thread, loops down
for _, bl in ipairs({ { { 49, 37 }, { 51, 34 }, { 54, 30 }, { 57, 26 } }, { { 49, 37 }, { 52, 36 }, { 56, 35 }, { 59, 34 } } }) do
  local m, n = O.tube(bl, function(t) return 1.3 - t * .9 end)
  O.shadeN(c, m, n, STEEL, { amb = .35, wrap = .4, cuts = { .3, .55, .8 }, sep = STEEL[1] })
end
O.dots(c, { { 52, 32 }, { 54, 35 } }, STEEL[4]) -- edge glints
for _, L in ipairs({ { 44.5, 41.5 }, { 49.5, 43.5 } }) do
  local ring = c:ellipse(L[1], L[2], 2.5, 2.5)
  ring:cut(c:ellipse(L[1], L[2], 1, 1))
  O.shade(c, ring, BRASS, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = BRASS[1] })
end
O.flat(c, c:line({ { 46, 39 }, { 48, 37 } }, 1), BRASS[2], "shank") O.flat(c, c:line({ { 49, 40 }, { 49, 38 } }, 1), BRASS[2], "shank")
O.flat(c, c:rect(48, 36, 49, 37), STEEL[1], "rivet") O.dot(c, 48, 36, STEEL[4])
O.shade(c, c:ellipse(43, 44, 2.5, 2.5), GLD, { R = 1, amb = .3, sep = GLD[1] }) -- hand through the loop
-- the snipped thread drifting off the blade tips
O.flat(c, c:line({ { 59, 29 }, { 58, 26 } }, 1), THR[3], "cut") O.dot(c, 58, 26, THR[4]) O.dot(c, 59, 29, THR[2])

-- quirk: the hum, a music note floating off to the left
O.flat(c, c:rect(13, 22, 13, 27), NOTE[2], "note")
O.flat(c, c:rect(14, 22, 15, 23), NOTE[2], "note") O.dot(c, 16, 24, NOTE[2])
local head = c:ellipse(11.5, 28, 1.5, 1.2)
O.shade(c, head, NOTE, { R = 1, amb = .4, cuts = { .4, .75 } })

O.done(c, "sp-saffron-snip-yard")
