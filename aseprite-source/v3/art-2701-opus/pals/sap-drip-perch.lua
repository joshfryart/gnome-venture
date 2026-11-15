-- Sap Drip (mw-sap-drip), perch sprite 36x36. Opus pass, drawn at this size by hand:
-- amber dollop with a curled tip, in its own sticky puddle, pill eyes, a small yawn, low glow.
-- quirk: the fly stuck in the amber dome above its face (5x3 px, pale wings, red eye).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("sap-drip-perch", 36)

local AMB = { "#6e3412", "#a5521a", "#d27a22", "#eca23a", "#f8c860", "#fde49a" }

local pud = c:ellipse(17, 32, 12, 2)
local pt = O.flat(c, pud, AMB[3], "puddle")
pud:each(function(x, y)
  if not pud:has(x, y - 1) then c:put(x, y, AMB[4], pt) end
  if not pud:has(x, y + 1) then c:put(x, y, AMB[2], pt) end
end)
O.mark(c, { {8,31},{9,31},{26,32} }, AMB[6])

local body = c:ellipse(17, 25, 8.5, 7)
body:add((O.tube({ { 17, 20 }, { 19, 13 }, { 17, 8 }, { 12, 8 } }, function(t) return 4.2 - 3.5 * t end)))
body:add((O.tube({ { 24, 27 }, { 25, 29 }, { 25, 30 }, { 25, 31 } }, function(t) return .8 + .4 * t end)))
O.shade(c, body, { AMB[1], AMB[2], AMB[3], AMB[3], AMB[4], AMB[5] }, { sphere = { 15, 21, 10 }, amb = .2, wrap = .3 })
local glow = c:ellipse(18, 29, 5, 1.5):clip(body)
glow:each(function(x, y) O.mark(c, { { x, y } }, math.abs(x - 18) < 3 and AMB[5] or AMB[4]) end)
local core = c:ellipse(17, 15, 2.5, 2.5):clip(body)
core:each(function(x, y) O.mark(c, { { x, y } }, AMB[5]) end)
O.dots(c, { {10,20},{11,20},{10,21} }, P.cream)
O.dots(c, { {16,10} }, AMB[6])

-- quirk: the fly in the dome
O.dot(c, 15, 15, "#c0443a")
O.dots(c, { {16,15},{17,15},{18,15},{17,16},{18,16} }, "#4a2a1e")
O.dots(c, { {17,14},{16,13},{19,14},{19,13} }, "#eef4ec") O.dot(c, 18, 14, "#9fb4b0")

c:eyeSmall(12, 21)
c:eyeSmall(21, 21)
O.dot(c, 10, 25, "#f5809f") O.dot(c, 24, 25, "#f5809f")
O.dots(c, { {16,25},{17,25},{15,26},{18,26},{16,27},{17,27} }, "#6e2038")
O.dots(c, { {16,26},{17,26} }, "#e8493b")

O.shift(c, 0, -1)
O.done(c, "sap-drip-perch")
