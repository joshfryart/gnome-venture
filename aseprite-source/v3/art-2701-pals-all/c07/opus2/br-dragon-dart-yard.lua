-- Dragon Dart (br-dragon-dart), yard sprite 64x64. Opus second pass (art-2701-pals-all/c07/opus2), from the Haiku pass.
-- Blossomreach, rare, thornblade. "Darts over the koi pond on paper wings and winks at the Long Wall."
-- A dragonfly caught mid-dart on a diagonal: big round moss head up-left, small thorax, a long segmented sea-blue
-- abdomen sweeping down-right that ends in a little thorn blade. Four slim fan-folded paper wings (front pair
-- petal washi, hind pair sky washi), each with crease stripes and a darker leading-edge spar.
-- Haiku fixes: wings slimmer and folded like paper instead of big flat slabs; the body is diagonal so it darts;
-- the wink is a clear closed-eye arc with a lifted brow, not a sparkle.
-- quirk: it winks (one locked eye open, the other a happy closed arc); one rare sparkle off its wing tip.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("br-dragon-dart-yard", 64)

local MOSS = { "#24544a", "#2f7350", "#3f9150", "#64b052", "#9ad06a", "#c9e888" }
local SEA  = { "#1f3a66", "#2a4a7a", "#3a86b0", "#4fa8c0", "#7fd2d6", "#b6f0e0" }
local PET  = { "#9a4a74", "#c96a8e", "#e892aa", "#f6b4c6", "#ffd2dc", "#fff0ea" }
local SKY  = { "#4c7cb4", "#6a9ad0", "#8bc4ea", "#b0dcf4", "#d2eefa", "#f0faff" }
local INK2 = "#3e2236"

-- wings (behind the body): fan-folded paper
local function wing(a, b, cpa, cpb, w, R, spar)
  local m, n, T = O.tube({ a, cpa, cpb, b }, function(t) return math.max(.6, math.sin(math.pi * (t * .9 + .08)) * w) end)
  local bias = {}
  m:each(function(x, y) local t = T[K(x, y)] or 0 if math.floor(t * 9) % 2 == 1 then bias[K(x, y)] = -1 end end)
  local idx, tok = O.shadeN(c, m, n, R, { amb = .45, wrap = .5, bias = bias, sep = spar })
  return m, idx, tok
end
wing({ 31, 27 }, { 52, 5 }, { 37, 20 }, { 46, 9 }, 4.2, PET, PET[1])
wing({ 32, 29 }, { 59, 17 }, { 40, 25 }, { 52, 19 }, 3.6, SKY, SKY[1])
wing({ 28, 32 }, { 4, 41 }, { 21, 34 }, { 11, 38 }, 4.0, PET, PET[1])
wing({ 30, 33 }, { 11, 53 }, { 25, 39 }, { 16, 47 }, 3.4, SKY, SKY[1])

-- abdomen: segmented, tapering, ending in a thorn blade
local ab, an, aT = O.tube({ { 32, 32 }, { 40, 40 }, { 47, 47 }, { 55, 55 } }, function(t) return 2.6 - t * 1.3 end)
local seg = {}
ab:each(function(x, y) local t = aT[K(x, y)] or 0 if math.floor(t * 30) % 4 == 0 then seg[K(x, y)] = -2 end end)
O.shadeN(c, ab, an, SEA, { amb = .3, wrap = .45, bias = seg, sep = SEA[1], rim = true, bounce = "#5a459e", bmax = 2 })
local blade = c:poly{ { 54, 54 }, { 58, 56 }, { 59, 59 }, { 56, 58 } }
O.shade(c, blade, { "#35295f", "#5a459e", "#8a6fd0", "#c9b2f0" }, { R = 1, amb = .35, cuts = { .3, .55, .8 } })
-- thorax
O.shade(c, c:ellipse(30, 30, 4.5, 4), SEA, { sphere = { 28, 28, 6 }, amb = .3, sep = SEA[1], rim = true })
O.dots(c, { { 29, 31 }, { 30, 32 }, { 31, 31 } }, SEA[6])
-- head
local head = c:ellipse(21, 21, 9.5, 8.5)
local hI, hT = O.shade(c, head, MOSS, { sphere = { 17, 16, 17 }, amb = .3, wrap = .45, sep = MOSS[1], rim = true, bounce = "#3a86b0", bmax = 2 })
O.dots(c, { { 15, 14 }, { 16, 14 }, { 17, 13 } }, MOSS[6]) -- gloss on the crown

-- face: left eye locked open, right eye a winking arc
c:eyeLocked(13, 18)
O.dots(c, { { 23, 21 }, { 24, 20 }, { 25, 19 }, { 26, 19 }, { 27, 19 }, { 28, 20 }, { 29, 21 } }, "#2b1c26")
O.dots(c, { { 25, 16 }, { 26, 15 }, { 27, 15 }, { 28, 16 } }, MOSS[1]) -- lifted brow
c:cheek(13, 24) c:cheek(26, 23)
O.dots(c, { { 17, 26 }, { 18, 27 }, { 19, 27 }, { 20, 27 }, { 21, 27 }, { 22, 26 } }, "#3e1620") -- grin
O.dots(c, { { 19, 26 }, { 20, 26 } }, "#e8493b")
-- antennae nubs
O.dots(c, { { 15, 12 }, { 14, 11 }, { 13, 10 } }, MOSS[2]) O.dots(c, { { 24, 12 }, { 25, 11 }, { 26, 10 } }, MOSS[2])

O.done(c, "br-dragon-dart-yard", function(c) c:sparkle(57, 9) end)
