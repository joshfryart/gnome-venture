-- Toadstool Tuck (mm-toadstool-tuck), perch sprite 36x36. Opus second pass, hand-built at this size:
-- cap kept wide but shallower so the stem face gets 10 px of height; 2x3 pill eyes, fewer warts,
-- counting hand as 3 finger pixels.
-- quirk: two tiny tan fairy-ring mushrooms at its feet.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("toadstool-tuck-perch", 36)

local CAP  = { "#5e1a2e", "#8e2436", "#c0333c", "#e5503f", "#f67c52", "#ffad78" }
local STEM = { "#8e7268", "#b5998a", "#d1b79f", "#e4cfb4", "#f0e1c6", "#f8eed8" }
local GILL = { "#8a5a5e", "#b98078", "#d9a593", "#ecc6ad" }
local WART = { "#e7d2b8", "#f7ead0", "#fff4d6" }
local TAN  = { "#6b4330", "#9a6a45", "#c79563", "#e3b982", "#f4d7a4" }

c:groundShadow(18, 32, 11, 2)

-- stem
local stem = c:ellipse(18, 24, 7.5, 8)
stem:add(c:ellipse(18, 29, 8, 3))
stem:cut(c:rect(0, 32, 35, 35))
O.shade(c, stem, STEM, { R = 4, amb = .3, wrap = .4 })
-- arms: left down, right up counting
O.shade(c, c:ellipse(9.5, 27, 1.5, 2), STEM, { R = 1, amb = .35, sep = STEM[2] })
O.shade(c, c:rect(26, 21, 27, 25), STEM, { R = 1, amb = .4, sep = STEM[2] })
O.dots(c, { { 26, 19 }, { 27, 19 }, { 28, 20 } }, STEM[5])
O.dots(c, { { 26, 20 }, { 27, 20 } }, STEM[4])

-- gill skirt
local gill = c:ellipse(18, 16, 13, 2)
gill:cut(c:rect(0, 0, 35, 15))
O.shade(c, gill, GILL, { R = 1, amb = .45, cuts = { .3, .55, .78 } })
for x = 6, 30, 2 do O.dot(c, x, 16, GILL[2]) end

-- cap
local cap = c:ellipse(18, 14, 14.5, 11)
cap:cut(c:rect(0, 16, 35, 35))
cap:cut(c:rect(0, 15, 3, 15)) cap:cut(c:rect(33, 15, 35, 15))
local cb = {}
cap:each(function(x, y) if y >= 15 then cb[K(x, y)] = -1 end end)
O.shade(c, cap, CAP, { sphere = { 14, 10, 16 }, bias = cb, amb = .16, wrap = .3 })
-- warts
for _, w in ipairs({ { 12, 7, 2, 1 }, { 21, 6, 2, 1 }, { 27, 11, 1, 1 }, { 8, 12, 1, 1 }, { 17, 11, 1.5, 1 } }) do
  local m = c:ellipse(w[1], w[2], w[3], w[4])
  O.flat(c, m, WART[2], "wart")
  O.dot(c, math.floor(w[1] - w[3] + .5), math.floor(w[2] - w[4] + .5), WART[3])
end
O.dots(c, { { 13, 8 }, { 22, 7 }, { 18, 12 } }, WART[1])

-- face
c:eyeSmall(14, 19)
c:eyeSmall(20, 19)
O.dots(c, { { 13, 22 }, { 15, 22 }, { 19, 22 }, { 21, 22 } }, STEM[3]) -- lower lids
O.dots(c, { { 11, 23 }, { 12, 23 } }, "#f5809f") O.dots(c, { { 23, 23 }, { 24, 23 } }, "#f5809f")
O.dot(c, 17, 22, "#d9a28c") O.dot(c, 17, 23, "#a8746a") -- nose
O.dots(c, { { 17, 25 }, { 18, 25 } }, "#6e2c2a") O.dot(c, 16, 25, "#a8483a") O.dot(c, 19, 25, "#a8483a")

-- quirk: fairy ring minis
local function mini(x, y)
  O.flat(c, c:rect(x + 1, y + 2, x + 2, y + 3), STEM[4], "ms")
  O.dot(c, x + 2, y + 3, STEM[2])
  O.flat(c, c:rect(x, y + 1, x + 3, y + 1), TAN[3], "mc")
  O.dots(c, { { x + 1, y }, { x + 2, y } }, TAN[4])
  O.dot(c, x + 3, y + 1, TAN[2])
end
mini(3, 29) mini(29, 28)

O.done(c, "toadstool-tuck-perch")
