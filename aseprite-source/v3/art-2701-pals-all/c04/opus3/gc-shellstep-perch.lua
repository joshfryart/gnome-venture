-- Shellstep (gc-shellstep), perch sprite 36x36. Opus richness pass (c04/opus3), hand-built at this size.
-- Richness pass: hue-shifted amber ramp, a lit centre patch and one growth ring per visible scute, rim scuffs,
-- toe nails, a chain-link cord to the watch and a tiny snail hitching a ride on the shell's back. From opus2:
-- amber dome with five drawn scute seams and a pale rim band, one moss tuft, stumpy sage legs, and a head big
-- enough for the 2x3 pill eyes, smile and cheeks.
-- quirk: the gold pocket watch hanging under its chin.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("gc-shellstep-perch", 36)

local SHELL = { "#3a1e26", "#62362a", "#8e582c", "#b47e38", "#d8aa52", "#f0d48e" }
local SKIN  = { "#2a3430", "#45564a", "#617a5e", "#83a072", "#a8c48e", "#d0e2b0" }
local GOLD  = { "#8a5a1a", "#c98a22", "#f0be38", "#fbe07a" }
local MOSS  = { "#1f4a3c", "#2f6b46", "#4a8f4e", "#72b35a", "#a2d070" }

c:groundShadow(17, 31, 14, 1.5)
for _, L in ipairs({ { 7, 26 }, { 20, 26 } }) do
  O.shade(c, c:rrect(L[1] - 2, L[2], L[1] + 2, L[2] + 4, 1), SKIN, { R = 1, amb = .2, wrap = .4, sep = SKIN[1] })
end

local shell = c:ellipse(14, 21, 12, 11) shell:cut(c:rect(0, 26, 40, 40))
local _, sT = O.shade(c, shell, SHELL, { sphere = { 11, 15, 15 }, amb = .22, wrap = .45, rim = true, bounce = "#6a5a8a", bmax = 2, sep = SHELL[1] })
-- seams
O.mark(c, { { 10, 13 }, { 9, 14 }, { 9, 15 }, { 10, 16 }, { 11, 17 }, { 15, 17 }, { 16, 16 }, { 17, 15 }, { 17, 14 }, { 16, 13 },
            { 12, 17 }, { 13, 17 }, { 14, 17 }, { 11, 18 }, { 10, 19 }, { 10, 20 }, { 10, 21 }, { 16, 18 }, { 17, 19 }, { 18, 20 }, { 18, 21 },
            { 8, 15 }, { 6, 16 }, { 7, 16 }, { 18, 15 }, { 19, 15 }, { 20, 16 }, { 21, 17 } }, SHELL[2])
O.mark(c, { { 12, 14 }, { 13, 14 }, { 13, 15 } }, SHELL[6])
O.mark(c, { { 5, 19 }, { 6, 18 }, { 13, 20 }, { 14, 20 }, { 21, 19 } }, SHELL[6]) -- lit scute centres
O.mark(c, { { 12, 21 }, { 15, 21 }, { 6, 20 }, { 20, 18 } }, SHELL[3]) -- growth rings
local rim = c:rect(2, 22, 26, 24) rim:clip(shell)
rim:each(function(x, y) c:put(x, y, (y == 22) and SHELL[2] or ((x % 4 == 0) and SHELL[3] or SHELL[5]), sT) end)
O.shade(c, c:ellipse(13, 10.5, 3, 1.3), MOSS, { R = 1, amb = .3, sep = MOSS[1] })
O.dot(c, 12, 9, MOSS[5])
-- tiny snail hitching a ride (lavender foot, pink swirl shell)
O.flat(c, c:rect(3, 14, 6, 14), "#9a92b0", "foot") O.dot(c, 6, 13, "#9a92b0") O.dot(c, 6, 12, "#2b1c26")
O.flat(c, c:rect(3, 12, 4, 13), "#e0a08a", "snail") O.dot(c, 3, 12, "#f4d0a8") O.dot(c, 4, 13, "#6a3a4a")
for _, L in ipairs({ { 7, 26 }, { 20, 26 } }) do O.dots(c, { { L[1] - 1, 30 }, { L[1] + 1, 30 } }, SKIN[6]) end

local head = c:ellipse(27, 18, 6, 5.5)
O.shade(c, head, SKIN, { sphere = { 25, 15, 10 }, amb = .35, wrap = .5, rim = true, bounce = "#5a7aa0", bmax = 2, sep = SKIN[1] })
-- quirk: watch
O.dots(c, { { 25, 23 }, { 26, 23 } }, "#7a3a2a")
O.flat(c, c:rect(26, 24, 28, 26), GOLD[3], "watch") O.dot(c, 27, 25, P.ink) O.dot(c, 26, 24, GOLD[4]) O.dot(c, 28, 26, GOLD[1])

c:eyeSmall(24, 15)
c:eyeSmall(30, 15)
O.dot(c, 23, 19, "#f5809f") O.dot(c, 32, 19, "#f5809f")
O.dots(c, { { 26, 19 }, { 27, 20 }, { 28, 20 }, { 29, 19 } }, P.ink)

O.shift(c, 0, -1)
O.done(c, "gc-shellstep-perch")
