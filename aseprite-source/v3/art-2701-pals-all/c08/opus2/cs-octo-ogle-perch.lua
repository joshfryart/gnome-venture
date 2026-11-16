-- Octo Ogle (cs-octo-ogle), perch sprite 36x36. Opus second pass, hand-built at this size: domed violet mantle,
-- 2x3 pill eyes, a bold "o" mouth, five hooked tentacles with a few pale suckers.
-- quirk: one tentacle holds up a gold ring (teal gem) with a twinkle.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, P = O.HP, O.P
local c = O.canvas("cs-octo-ogle-perch", 36)

local OCT  = { "#2e1f52", "#4c3384", "#6e4fb4", "#9473d6", "#b99cec", "#dccaff" }
local TEN  = { "#2e1f52", "#4c3384", "#6e4fb4", "#8a68cc", "#a988e2" }
local GOLD = { "#7a3a1c", "#b85c1f", "#e08a26", "#f5b82e", "#ffd970", "#fff0b0" }

c:groundShadow(17, 33, 12, 1.5)
local function ten(p, w)
  local m, n = O.tube(p, function(t) return w * (1 - t * .55) end)
  O.shadeN(c, m, n, TEN, { amb = .2, wrap = .3, sep = OCT[1] })
end
ten({ { 12, 21 }, { 6, 24 }, { 2, 31 }, { 6, 30 } }, 2)
ten({ { 22, 21 }, { 27, 24 }, { 30, 31 }, { 27, 30 } }, 2)
ten({ { 14, 23 }, { 12, 27 }, { 9, 32 }, { 12, 32 } }, 1.8)
ten({ { 20, 23 }, { 22, 27 }, { 25, 32 }, { 22, 32 } }, 1.8)
ten({ { 17, 23 }, { 17, 28 }, { 16, 32 }, { 18, 32 } }, 1.6)
O.dots(c, { { 5, 26 }, { 11, 28 }, { 23, 28 }, { 28, 26 } }, "#f2c4e0")

local head = c:ellipse(17, 13, 8, 8) head:add(c:ellipse(17, 19, 8.5, 4))
O.shade(c, head, OCT, { sphere = { 15, 10, 12 }, amb = .3, wrap = .35, sep = OCT[1], rim = true, bounce = "#3a6a9a", bmax = 2 })
O.mark(c, { { 13, 7 }, { 14, 7 }, { 21, 6 }, { 22, 10 } }, OCT[3])
-- raised tentacle + ring
local m, n = O.tube({ { 23, 21 }, { 29, 22 }, { 31, 16 }, { 30, 11 } }, function(t) return 1.5 * (1 - t * .4) end)
O.shadeN(c, m, n, OCT, { amb = .3, sep = OCT[1] })
local ring = c:ellipse(30, 7, 3, 3) ring:cut(c:ellipse(30, 7, 1.5, 1.5))
O.shade(c, ring, GOLD, { sphere = { 29, 5, 4 }, amb = .42, wrap = .4, sep = GOLD[1] })
O.dots(c, { { 30, 4 } }, "#4fc4b0") O.dot(c, 29, 4, "#c8f7e2")
-- face
c:eyeSmall(13, 14)
c:eyeSmall(20, 14)
O.dots(c, { { 11, 18 }, { 23, 18 } }, "#f5809f")
O.dots(c, { { 16, 18 }, { 17, 18 }, { 15, 19 }, { 18, 19 }, { 16, 20 }, { 17, 20 } }, P.ink)
O.dots(c, { { 16, 19 }, { 17, 19 } }, "#7d2c5e")

O.shift(c, -1, -2)
O.done(c, "cs-octo-ogle-perch", function(c)
  for _, d in ipairs({ { 0, 0 }, { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do c:put(33 + d[1], 2 + d[2], "#fff4d6") end
end)
