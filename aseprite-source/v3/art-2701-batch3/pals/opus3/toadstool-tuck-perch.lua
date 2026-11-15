-- Toadstool Tuck (mm-toadstool-tuck), perch sprite 36x36. Opus richness pass (opus3), hand-built at this size:
-- cap kept wide but shallow so the stem face gets 10 px of height; bolder, fewer details than the yard:
-- cap rim light + a few freckles, warts with one shadow pixel, fanned gills, cool bounce on the stem,
-- 2x3 pill eyes with lower lids, counting hand.
-- quirk: two fairy-ring mushrooms at its feet, the right one a red baby Tuck.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("toadstool-tuck-perch", 36)

local CAP  = { "#561634", "#86213a", "#b9303c", "#e04c3e", "#f47a50", "#ffaf7a" }
local STEM = { "#87697a", "#ae9390", "#cdb39f", "#e2cdb3", "#efdfc4", "#f9efd9" }
local GILL = { "#7e4c62", "#a8707a", "#cc9590", "#e4b8a6", "#f3d4bc" }
local WART = { "#d6c0aa", "#f8eed6", "#fff4d6" }
local TAN  = { "#5e3a33", "#8c5c42", "#b98656", "#dcae78", "#f2d29e" }

c:groundShadow(18, 32, 11, 2)

-- stem
local stem = c:ellipse(18, 24, 7.5, 8)
stem:add(c:ellipse(18, 29, 8, 3))
stem:cut(c:rect(0, 32, 35, 35))
local si, st = O.shade(c, stem, STEM, { R = 4, amb = .3, wrap = .4, bounce = "#b7a6b6", bmax = 3 })
O.tex(c, si, st, STEM, function(x, y) if y > 26 and (x == 13 or x == 23) then return -1 end end)
-- annulus: one frilly row round the waist
for x = 11, 25 do O.dot(c, x, 28, (x % 3 == 0) and GILL[3] or GILL[4]) end
O.dots(c, { { 12, 28 }, { 13, 28 } }, GILL[5])
-- arms: left down, right up counting
O.shade(c, c:ellipse(9.5, 26, 1.5, 2), STEM, { R = 1, amb = .35, sep = STEM[2] })
O.shade(c, c:rect(26, 21, 27, 25), STEM, { R = 1, amb = .4, sep = STEM[2] })
O.dots(c, { { 26, 19 }, { 27, 19 }, { 28, 20 } }, STEM[5])
O.dots(c, { { 26, 20 }, { 27, 20 } }, STEM[4])

-- gill skirt, gills fanned
local gill = c:ellipse(18, 16, 13, 2)
gill:cut(c:rect(0, 0, 35, 15))
local gi, gt = O.shade(c, gill, GILL, { R = 1, amb = .45, cuts = { .25, .45, .65, .82 } })
O.tex(c, gi, gt, GILL, function(x, y) if math.floor(18 + (x - 18) / (1 - (y - 16) * .15) + .5) % 2 == 0 then return -1 end end)

-- cap
local cap = c:ellipse(18, 14, 14.5, 11)
cap:cut(c:rect(0, 16, 35, 35))
cap:cut(c:rect(0, 15, 3, 15)) cap:cut(c:rect(33, 15, 35, 15))
local cb = {}
cap:each(function(x, y) if y >= 15 then cb[K(x, y)] = -1 end end)
local ci, ct = O.shade(c, cap, CAP, { sphere = { 14, 10, 16 }, bias = cb, amb = .16, wrap = .3, rim = true })
O.tex(c, ci, ct, CAP, function(x, y, i) if H(x, y, 7) > .9 and i >= 3 and i <= 5 then return -1 end end)
-- warts, each with one shadow pixel lower-right
for _, w in ipairs({ { 12, 7, 2, 1 }, { 21, 6, 2, 1 }, { 27, 11, 1, 1 }, { 8, 12, 1, 1 }, { 17, 11, 1.5, 1 } }) do
  local m = c:ellipse(w[1], w[2], w[3], w[4])
  m:shift(1, 1):each(function(x, y) if c.own[y * 36 + x] == ct and not m:has(x, y) then c.pix[y * 36 + x] = CAP[2] end end)
  O.flat(c, m, WART[2], "wart")
  O.dot(c, math.floor(w[1] - w[3] + .5), math.floor(w[2] - w[4] + .5), WART[3])
end
O.dots(c, { { 13, 8 }, { 22, 7 }, { 18, 12 } }, WART[1])

-- face
c:eyeSmall(14, 19)
c:eyeSmall(20, 19)
O.dots(c, { { 13, 22 }, { 15, 22 }, { 19, 22 }, { 21, 22 } }, STEM[3]) -- lower lids
O.dots(c, { { 11, 23 }, { 12, 23 } }, "#f5809f") O.dots(c, { { 23, 23 }, { 24, 23 } }, "#f5809f")
O.dot(c, 17, 22, "#e6b49e") O.dot(c, 17, 23, "#a8746a") -- nose
O.dots(c, { { 17, 25 }, { 18, 25 } }, "#6e2c2a") O.dot(c, 16, 25, "#a8483a") O.dot(c, 19, 25, "#a8483a")

-- quirk: fairy ring minis; the right one is a red baby
local function mini(x, y, red)
  O.flat(c, c:rect(x + 1, y + 2, x + 2, y + 3), STEM[4], "ms")
  O.dot(c, x + 2, y + 3, STEM[2])
  local R = red and CAP or TAN
  O.flat(c, c:rect(x, y + 1, x + 3, y + 1), R[3], "mc")
  O.dots(c, { { x + 1, y }, { x + 2, y } }, R[4])
  O.dot(c, x + 3, y + 1, R[2])
  if red then O.dot(c, x + 1, y, WART[3]) end
end
mini(3, 29) mini(29, 28, true)

O.done(c, "toadstool-tuck-perch")
