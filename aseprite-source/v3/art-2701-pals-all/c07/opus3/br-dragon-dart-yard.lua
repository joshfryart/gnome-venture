-- Dragon Dart (br-dragon-dart), yard sprite 64x64. Opus richness pass (art-2701-pals-all/c07/opus3), built on opus2.
-- opus3: washi fibre flecks and a dark pterostigma cell near each wing tip, rim on the front wings, moss fuzz on the
-- head, gold stripes on the thorax, pale dorsal spots per abdomen segment, three tucked legs, a gloss on the thorn;
-- closer look: the paper-maker's red hanko seal stamped on the lower hind wing.
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
local function wing(a, b, cpa, cpb, w, R, spar, stig, rim)
  local p = { a, cpa, cpb, b }
  local m, n, T = O.tube(p, function(t) return math.max(.6, math.sin(math.pi * (t * .9 + .08)) * w) end)
  local bias = {}
  m:each(function(x, y) local t = T[K(x, y)] or 0 if math.floor(t * 9) % 2 == 1 then bias[K(x, y)] = -1 end end)
  local idx, tok = O.shadeN(c, m, n, R, { amb = .45, wrap = .5, bias = bias, sep = spar, rim = rim })
  -- washi fibres: sparse short light/dark flecks
  O.tex(c, idx, tok, R, function(x, y, i)
    local h = H(x, y, 21)
    if h > .93 and i >= 3 then return -1 elseif h < .06 and i <= 5 then return 1 end
  end)
  -- pterostigma: a small dark cell near the tip
  for _, t in ipairs({ .8, .84 }) do
    local x, y = O.bez(p, t)
    O.dot(c, math.floor(x + .5), math.floor(y + .5), stig)
  end
  return m, idx, tok
end
wing({ 31, 27 }, { 52, 5 }, { 37, 20 }, { 46, 9 }, 4.2, PET, PET[1], "#7a2a4e", true)
wing({ 32, 29 }, { 59, 17 }, { 40, 25 }, { 52, 19 }, 3.6, SKY, SKY[1], "#2a4a7a", true)
wing({ 28, 32 }, { 4, 41 }, { 21, 34 }, { 11, 38 }, 4.0, PET, PET[1], "#7a2a4e", true)
wing({ 30, 33 }, { 11, 53 }, { 25, 39 }, { 16, 47 }, 3.4, SKY, SKY[1], "#2a4a7a")
-- closer look: the paper-maker's red hanko seal on the lower hind wing
O.flat(c, c:rect(17, 44, 18, 45), "#c8323e", "hanko") O.dot(c, 17, 44, "#ff7a6a") O.dot(c, 18, 45, "#8a1e34")

-- abdomen: segmented, tapering, ending in a thorn blade
local ab, an, aT = O.tube({ { 32, 32 }, { 40, 40 }, { 47, 47 }, { 55, 55 } }, function(t) return 2.6 - t * 1.3 end)
local seg = {}
ab:each(function(x, y) local t = aT[K(x, y)] or 0 if math.floor(t * 30) % 4 == 0 then seg[K(x, y)] = -2 end end)
O.shadeN(c, ab, an, SEA, { amb = .3, wrap = .45, bias = seg, sep = SEA[1], rim = true, bounce = "#5a459e", bmax = 2 })
-- pale dorsal spot on each segment, upper-left side
for t = .1, .8, .135 do local x, y = O.bez({ { 32, 32 }, { 40, 40 }, { 47, 47 }, { 55, 55 } }, t)
  O.dot(c, math.floor(x + .5) - 1, math.floor(y + .5), "#b6f0e0") end
local blade = c:poly{ { 54, 54 }, { 58, 56 }, { 59, 59 }, { 56, 58 } }
O.shade(c, blade, { "#35295f", "#5a459e", "#8a6fd0", "#c9b2f0" }, { R = 1, amb = .35, cuts = { .3, .55, .8 } })
O.dot(c, 55, 54, "#e8dcff") -- thorn gloss
-- thorax
O.shade(c, c:ellipse(30, 30, 4.5, 4), SEA, { sphere = { 28, 28, 6 }, amb = .3, sep = SEA[1], rim = true })
O.dots(c, { { 27, 29 }, { 28, 28 }, { 29, 27 } }, "#f5c84a") O.dots(c, { { 30, 33 }, { 31, 32 }, { 32, 31 } }, "#d99a32") -- gold thorax stripes
O.dot(c, 28, 29, "#ffe38a")
-- three tucked legs under the thorax (ink-plum, with a lit knee)
O.dots(c, { { 27, 34 }, { 26, 35 }, { 26, 36 }, { 25, 37 } }, "#3e2236")
O.dots(c, { { 29, 35 }, { 29, 36 }, { 28, 37 }, { 28, 38 } }, "#3e2236")
O.dots(c, { { 31, 35 }, { 32, 36 } }, "#3e2236")
O.dots(c, { { 26, 35 }, { 29, 36 } }, "#6a5064")
-- head
local head = c:ellipse(21, 21, 9.5, 8.5)
local hI, hT = O.shade(c, head, MOSS, { sphere = { 17, 16, 17 }, amb = .3, wrap = .45, sep = MOSS[1], rim = true, bounce = "#3a86b0", bmax = 2 })
O.tex(c, hI, hT, MOSS, function(x, y, i) -- soft moss fuzz, kept off the face
  if y < 17 or x > 27 or x < 13 then if H(x, y, 4) > .88 and i >= 2 then return -1 end end
end)
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
