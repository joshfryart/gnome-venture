-- Scarab Roll (dw-scarab-roll), perch sprite 36x36. Opus second pass, hand-built at this size.
-- Domed iridescent elytra with a seam, a round thorax with pill eyes and a smile, a clubbed antenna, legs drawn
-- as bold 1 px strokes, and a sand ball pushed ahead. quirk: the gold coin stuck in the ball (3x3 with a shine).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("dw-scarab-roll-perch", 36)

local SCB  = { "#1c2244", "#1f4664", "#22706e", "#2e9a80", "#6cc89a", "#bdeec4" }
local LEG  = { "#1a1630", "#2c2a48", "#46466a", "#646a8a" }
local SND  = { "#6a4626", "#986a3a", "#c49254", "#dcb474", "#eed29c", "#f8eac8" }
local GOLD = { "#7a4a14", "#c08a22", "#f0c440", "#fde89a" }

c:groundShadow(18, 31, 15, 1.5)
local function leg(pts) O.flat(c, c:line(pts, 1), LEG[3], "leg") end
leg({ { 23, 27 }, { 26, 29 }, { 28, 30 } })
local ball = c:ellipse(8.5, 24, 6, 6)
local sI, sT = O.shade(c, ball, SND, { sphere = { 6, 21, 8 }, amb = .2, wrap = .4, sep = SND[1], rim = true })
O.tex(c, sI, sT, SND, function(x, y, i) if H(x, y, 11) > .85 and i <= 5 then return 1 end end)
O.flat(c, c:rect(5, 21, 7, 23), GOLD[3], "coin") O.dot(c, 5, 21, GOLD[4]) O.dot(c, 7, 23, GOLD[2])

local ely = c:ellipse(25, 22, 8, 7.5) ely:cut(c:rect(16, 28, 34, 34))
local eI, eT = O.shade(c, ely, SCB, { sphere = { 22, 18, 10 }, amb = .2, wrap = .4, sep = SCB[1], rim = true, bounce = "#7a5ab0", bmax = 2 })
for y = 16, 27 do if ely:has(19, y) then c:put(19, y, SCB[1], eT) end end
O.dots(c, { { 22, 17 }, { 23, 17 } }, SCB[6])
leg({ { 28, 27 }, { 31, 29 }, { 32, 31 } })
leg({ { 22, 28 }, { 22, 30 }, { 21, 31 } })

local th = c:ellipse(15.5, 23, 6, 6)
O.shade(c, th, SCB, { sphere = { 13, 20, 8 }, amb = .22, wrap = .4, sep = SCB[1], rim = true, bounce = "#7a5ab0", bmax = 2 })
leg({ { 14, 29 }, { 12, 31 } })
O.flat(c, c:line({ { 14, 17 }, { 13, 15 }, { 12, 13 } }, 1), LEG[3], "antenna")
O.dots(c, { { 11, 12 }, { 12, 12 }, { 11, 13 } }, LEG[4])

c:eyeSmall(12, 21) c:eyeSmall(17, 21)
O.dot(c, 11, 25, "#f5809f") O.dot(c, 19, 25, "#f5809f")
O.dots(c, { { 14, 25 }, { 15, 26 }, { 16, 26 }, { 17, 25 } }, P.ink)

O.done(c, "dw-scarab-roll-perch")
