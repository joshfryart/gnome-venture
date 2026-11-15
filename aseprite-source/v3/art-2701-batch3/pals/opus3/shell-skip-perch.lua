-- Shell Skip (ss-shell-skip), perch sprite 36x36. Opus richness pass (opus3), hand-built at this size;
-- adds a shell rim light + violet bounce, two growth-line arcs, a 2 px barnacle and a pale carapace bump:
-- shell as three stacked whorls with groove lines, short eye stalks with 2x3 pill eyes, 3 legs,
-- a bold ink grin so the face reads at 36 px.
-- quirk: the blue sea-glass bead in its claw (3x3 here).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("shell-skip-perch", 36)

local SHL  = { "#5e2c26", "#8c4a2c", "#bd723a", "#e09c50", "#f3c473", "#fde2a4" }
local APER = { "#3a1a2e", "#55263c", "#73384a" }
local CRAB = { "#6a1e2e", "#a3383c", "#d2564a", "#ee7b5c", "#faa47c", "#ffcfa6" }
local GLAS = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#9ee4dc", "#d4f6ee" }

c:groundShadow(18, 32, 12, 1.5)

-- legs
for _, L in ipairs({ { { 22, 27 }, { 24, 29 }, { 25, 30 }, { 25, 31 } }, { { 18, 28 }, { 17, 30 }, { 16, 31 }, { 15, 31 } },
                     { { 12, 27 }, { 10, 28 }, { 8, 29 }, { 7, 30 } } }) do
  local m, n = O.tube(L, function(t) return .8 end)
  O.shadeN(c, m, n, CRAB, { amb = .35 })
end

-- shell
local main = c:ellipse(24, 20, 8.5, 8)
local spire = c:ellipse(28, 11.5, 4.5, 3.5)
local tip = c:ellipse(30.5, 7, 2, 2)
local shell = main:copy():add(spire):add(tip)
O.shade(c, shell, SHL, { sphere = { 20, 15, 15 }, amb = .2, wrap = .35, rim = true, bounce = "#8a5a6e", bmax = 2 })
O.mark(c, { { 26, 26 }, { 28, 25 }, { 30, 24 }, { 31, 22 }, { 22, 13 }, { 24, 12 } }, SHL[2]) -- growth lines
O.dots(c, { { 25, 10 }, { 26, 10 } }, "#d8cdbc") O.dot(c, 26, 11, "#7a6e78") -- barnacle
spire:edge():each(function(x, y) if main:has(x, y) and y > 10 and x < 33 then O.mark(c, { { x, y } }, SHL[1]) end end)
tip:edge():each(function(x, y) if spire:has(x, y) and y > 5 and x < 33 then O.mark(c, { { x, y } }, SHL[1]) end end)
O.mark(c, { { 28, 20 }, { 29, 19 }, { 30, 18 } }, SHL[6]) -- pale spiral cord
O.dots(c, { { 18, 13 }, { 19, 13 } }, SHL[6])
O.shade(c, c:ellipse(18, 23, 5, 4), APER, { R = 1, amb = .1, cuts = { .45, .7 } })

-- head
local head = c:ellipse(14, 24, 5, 3.5)
O.shade(c, head, CRAB, { sphere = { 12, 22, 6 }, amb = .25, sep = CRAB[1], rim = true })
-- arm + claw + quirk bead
O.dots(c, { { 9, 25 }, { 8, 24 }, { 7, 23 } }, CRAB[3])
local claw = c:ellipse(6, 20, 2.5, 2.5)
claw:cut(c:rect(7, 18, 8, 19))
O.shade(c, claw, CRAB, { sphere = { 5, 19, 3 }, amb = .3, sep = CRAB[1] })
O.flat(c, c:rect(5, 15, 7, 17), GLAS[3], "glass")
O.dot(c, 5, 15, GLAS[5]) O.dots(c, { { 7, 17 }, { 6, 17 } }, GLAS[2]) O.dot(c, 7, 15, GLAS[4])

-- eye stalks + pill eyes
O.flat(c, c:rect(12, 19, 12, 21), CRAB[4], "stalk")
O.flat(c, c:rect(16, 19, 16, 21), CRAB[3], "stalk")
O.flat(c, c:rect(11, 15, 13, 18), CRAB[5], "eyeball") O.flat(c, c:rect(15, 15, 17, 18), CRAB[5], "eyeball")
c:eyeSmall(12, 15)
c:eyeSmall(16, 15)

-- face
O.dot(c, 10, 24, "#f5809f") O.dot(c, 18, 24, "#f5809f")
O.dot(c, 14, 23, CRAB[6])
O.dots(c, { { 11, 25 }, { 12, 26 }, { 13, 26 }, { 14, 26 }, { 15, 26 }, { 16, 26 }, { 17, 25 } }, P.ink)

O.done(c, "shell-skip-perch")
