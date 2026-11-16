-- Dragon Dart (br-dragon-dart), perch sprite 36x36, hand-built at this size (opus3 richness pass, from opus2).
-- opus3: dark pterostigma dot near each wing tip, rim on the front wings, a gold thorax stripe, pale abdomen spots,
-- a red hanko seal dot on the lower hind wing, rim/bounce on the body.
-- Diagonal dart: moss head up-left with a big face, sea-blue thorax and banded abdomen to the lower right with a
-- violet thorn tip, four slim paper wings (petal front, sky hind) with one crease stripe each.
-- quirk: the wink (left pill eye open, right eye a closed arc).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("br-dragon-dart-perch", 36)

local MOSS = { "#24544a", "#2f7350", "#3f9150", "#64b052", "#9ad06a", "#c9e888" }
local SEA  = { "#1f3a66", "#2a4a7a", "#3a86b0", "#4fa8c0", "#7fd2d6", "#b6f0e0" }
local PET  = { "#9a4a74", "#c96a8e", "#e892aa", "#f6b4c6", "#ffd2dc", "#fff0ea" }
local SKY  = { "#4c7cb4", "#6a9ad0", "#8bc4ea", "#b0dcf4", "#d2eefa", "#f0faff" }

local function wing(a, b, cpa, cpb, w, R, stig)
  local m, n, T = O.tube({ a, cpa, cpb, b }, function(t) return math.max(.5, math.sin(math.pi * (t * .9 + .08)) * w) end)
  local bias = {}
  m:each(function(x, y) local t = T[K(x, y)] or 0 if math.floor(t * 5) % 2 == 1 then bias[K(x, y)] = -1 end end)
  O.shadeN(c, m, n, R, { amb = .45, wrap = .5, bias = bias, sep = R[1], rim = true })
  local x, y = O.bez({ a, cpa, cpb, b }, .82) O.dot(c, math.floor(x + .5), math.floor(y + .5), stig)
end
wing({ 18, 15 }, { 30, 3 }, { 21, 11 }, { 26, 6 }, 2.4, PET, "#7a2a4e")
wing({ 19, 17 }, { 33, 11 }, { 23, 14 }, { 28, 12 }, 2.0, SKY, "#2a4a7a")
wing({ 16, 18 }, { 3, 23 }, { 12, 19 }, { 7, 21 }, 2.3, PET, "#7a2a4e")
wing({ 17, 19 }, { 7, 30 }, { 14, 22 }, { 10, 26 }, 1.9, SKY, "#2a4a7a")

local ab, an, aT = O.tube({ { 19, 19 }, { 23, 23 }, { 27, 27 }, { 31, 31 } }, function(t) return 1.6 - t * .7 end)
local seg = {}
ab:each(function(x, y) local t = aT[K(x, y)] or 0 if math.floor(t * 12) % 3 == 0 then seg[K(x, y)] = -2 end end)
O.shadeN(c, ab, an, SEA, { amb = .3, wrap = .45, bias = seg, sep = SEA[1], rim = true, bounce = "#5a459e", bmax = 2 })
O.dots(c, { { 22, 23 }, { 26, 27 } }, "#b6f0e0")
O.dot(c, 10, 26, "#c8323e") -- hanko seal
O.flat(c, c:rect(31, 31, 32, 32), "#5a459e", "tip") O.dot(c, 33, 33, "#35295f")
O.shade(c, c:ellipse(17.5, 17.5, 2.5, 2.5), SEA, { R = 1, amb = .3, sep = SEA[1] })
O.dots(c, { { 17, 19 }, { 18, 18 } }, "#f5c84a")
local head = c:ellipse(12, 12, 6.5, 6)
O.shade(c, head, MOSS, { sphere = { 9, 9, 13 }, amb = .32, wrap = .45, sep = MOSS[1], rim = true, bounce = "#3a86b0", bmax = 2 })
O.dots(c, { { 9, 7 }, { 10, 7 } }, MOSS[6])
c:eyeSmall(8, 10)
O.dots(c, { { 13, 11 }, { 14, 10 }, { 15, 10 }, { 16, 11 } }, "#2b1c26")
O.dot(c, 6, 14, "#f5809f") O.dot(c, 16, 14, "#f5809f")
O.dots(c, { { 10, 15 }, { 11, 16 }, { 12, 16 }, { 13, 15 } }, "#3e1620")
O.dots(c, { { 9, 5 }, { 8, 4 } }, MOSS[2]) O.dots(c, { { 14, 5 }, { 15, 4 } }, MOSS[2])
O.done(c, "br-dragon-dart-perch")
