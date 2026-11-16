-- Octo Ogle (cs-octo-ogle), perch sprite 36x36. Opus richness pass (c08/opus3), hand-built at this size: domed
-- violet mantle (hue-shifted ramp, rim light, a few soft blotches), 2x3 pill eyes, a bold "o" mouth.
-- Fix (opus2 weakness: tentacles crowded at 36 px): now four splayed tentacles with clear gaps between them, the
-- outer pair curling outward, plus the raised one holding the ring; one pale sucker row each, pinker undersides.
-- quirk: one tentacle holds up a gold ring (teal gem) with a twinkle. closer look: a pearl by its left curl.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("cs-octo-ogle-perch", 36)

local OCT  = { "#281c4e", "#44307e", "#6648ae", "#8c6ad2", "#b494e8", "#e2cef8" }
local TEN  = { "#281c4e", "#44307e", "#6648ae", "#8466c8", "#a888e0", "#ccb0f2" }
local GOLD = { "#7a3a1c", "#b85c1f", "#e08a26", "#f5b82e", "#ffd970", "#fff0b0" }
local SUCK = "#f6c8dc"
local BNC = "#3a6a9a"

c:groundShadow(17, 33, 13, 1.5)
-- pearl by the left curl
O.shade(c, c:ellipse(4.5, 31.5, 1.5, 1.5), { "#9a9ab0", "#c8c4d4", "#e6e0e8", "#fff4e8" }, { sphere = { 4, 31, 2 }, amb = .4, cuts = { .3, .6, .85 } })

local function ten(p, w, side, sk)
  local m, n = O.tube(p, function(t) return w * (1 - t * .5) end)
  O.shadeN(c, m, n, TEN, { amb = .2, wrap = .3, sep = OCT[1], rim = true, bounce = BNC, bmax = 1 })
  O.dots(c, sk, SUCK)
end
-- outer pair curl outward, inner pair drop straight with a gap in the middle
ten({ { 12, 20 }, { 6, 22 }, { 3, 27 }, { 7, 29 } }, 2, -1, { { 5, 24 } })
ten({ { 22, 20 }, { 27, 22 }, { 31, 27 }, { 27, 30 } }, 2, 1, { { 29, 25 } })
ten({ { 14, 22 }, { 13, 26 }, { 10, 31 }, { 13, 32 } }, 1.9, -1, { { 12, 28 } })
ten({ { 20, 22 }, { 21, 26 }, { 24, 31 }, { 21, 32 } }, 1.9, 1, { { 22, 28 } })

local head = c:ellipse(17, 13, 8, 8) head:add(c:ellipse(17, 18, 8.5, 4))
local hI, hT = O.shade(c, head, OCT, { sphere = { 15, 10, 12 }, amb = .3, wrap = .35, sep = OCT[1], rim = true, bounce = BNC, bmax = 2 })
O.mark(c, { { 13, 7 }, { 14, 7 }, { 13, 8 }, { 21, 6 }, { 22, 6 }, { 22, 10 }, { 18, 4 } }, OCT[3])
O.dot(c, 12, 8, OCT[6])
-- raised tentacle + ring (in front)
local m, n = O.tube({ { 23, 19 }, { 29, 21 }, { 31, 15 }, { 30, 11 } }, function(t) return 1.6 * (1 - t * .4) end)
O.shadeN(c, m, n, OCT, { amb = .3, sep = OCT[1], rim = true })
O.dot(c, 31, 17, SUCK)
local ring = c:ellipse(30, 7, 3, 3) ring:cut(c:ellipse(30, 7, 1.5, 1.5))
O.shade(c, ring, GOLD, { sphere = { 29, 5, 4 }, amb = .42, wrap = .4, sep = GOLD[1], rim = true })
O.dots(c, { { 30, 4 } }, "#4fc4b0") O.dot(c, 29, 4, "#c8f7e2")
-- face
c:eyeSmall(13, 13)
c:eyeSmall(20, 13)
O.dots(c, { { 11, 17 }, { 23, 17 } }, "#f5809f")
O.dots(c, { { 16, 17 }, { 17, 17 }, { 15, 18 }, { 18, 18 }, { 16, 19 }, { 17, 19 } }, P.ink)
O.dots(c, { { 16, 18 }, { 17, 18 } }, "#7d2c5e")

O.shift(c, -1, -1)
O.done(c, "cs-octo-ogle-perch", function(c)
  for _, d in ipairs({ { 0, 0 }, { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do c:put(33 + d[1], 2 + d[2], "#fff4d6") end
end)
