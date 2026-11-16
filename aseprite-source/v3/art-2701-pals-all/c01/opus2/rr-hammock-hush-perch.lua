-- Hammock Hush (rr-hammock-hush), perch sprite 36x36. Opus second pass (c01/opus2), hand-built at this size.
-- Upside-down sloth under a 3-stripe hammock, cut down to the bold parts: branch, sagging cloth, toes over the
-- edge, short body, big head at the bottom with a cream mask, dark eye patches, pill eyes, mouth above the eyes,
-- falling tuft. Arms dropped (they crowded the face at this size).
-- quirk: the thought cloud, here a 6 px puff with three dots.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("rr-hammock-hush-perch", 36)

local FUR  = { "#2c2a34", "#44483a", "#5f6a40", "#82904e", "#a9b264", "#d0d08c" }
local FACE = { "#8a6458", "#c09474", "#e4c29a", "#f6e2bc" }
local MASK = "#4a3026"
local WOOD = { "#3a2228", "#5e3a2e", "#86563a", "#ad7a4c", "#d0a068", "#ecc890" }
local GOLD = { "#5e3a1c", "#9a5d1e", "#d08a2a", "#f0b440", "#f8d670", "#fdf0b0" }
local CLOT = { "#5a1f3a", "#9a3048", "#d2505a", "#f08070" }
local TEAL = { "#173f4a", "#1f6a6a", "#2f9a8a", "#5cc8a8" }
local CLD  = { "#8696b4", "#b2c0d6", "#d9e3ee", "#eef3f8" }

c:groundShadow(16, 33, 6, 1)
O.shade(c, c:line({ { 4, 4 }, { 31, 4 } }, 2), WOOD, { R = 1, amb = .25, sep = WOOD[1], rim = true })
O.seg(c, 6, 6, 7, 8, GOLD[3]) O.seg(c, 29, 6, 28, 8, GOLD[3])
for _, lx in ipairs({ 14, 19 }) do O.shade(c, c:rect(lx - 1, 10, lx + 1, 15), FUR, { R = 1, amb = .2, sep = FUR[1] }) end
local cloth = HP.mask()
for x = 7, 28 do
  local u = (x + .5 - 18) / 11
  local t = 8 + 3.5 * (1 - u * u)
  for y = math.floor(t), math.floor(t + 2 + (1 - u * u)) do cloth:set(x, y) end
end
local ctok = { r = { name = "cloth" } }
cloth:each(function(x, y)
  local band = (x // 3) % 3
  local R = band == 0 and GOLD or (band == 1 and CLOT or TEAL)
  local i = (y <= 9 + (x > 18 and 1 or 0)) and 4 or 3
  if x > 20 then i = i - 1 end
  c:put(x, y, R[i], ctok)
end)
for _, tx in ipairs({ 13, 18 }) do O.dots(c, { { tx, 9 }, { tx + 1, 9 }, { tx + 2, 9 } }, FUR[5]) O.dots(c, { { tx, 10 }, { tx + 2, 10 } }, "#3a2a2a") end
O.shade(c, c:ellipse(16.5, 17, 5.5, 4), FUR, { R = 2, amb = .18, wrap = .35, sep = FUR[1], rim = true })
local head = c:ellipse(16.5, 24, 7.5, 6)
O.shade(c, head, FUR, { R = 3, amb = .2, wrap = .35, sep = FUR[1], rim = true, bounce = "#4f7a8a", bmax = 2 })
O.shade(c, c:poly{ { 12, 29 }, { 14, 32 }, { 16, 30 }, { 18, 32 }, { 21, 29 } }, FUR, { R = 1, amb = .2 })
O.dot(c, 19, 30, "#ef7a8a")
local fm = c:ellipse(16.5, 23.5, 6, 4.5)
O.shade(c, fm, FACE, { R = 2, amb = .35, wrap = .4, cuts = { .3, .55, .8 } })
for _, ex in ipairs({ 11, 20 }) do
  O.dots(c, { { ex, 24 }, { ex + 3, 24 }, { ex, 25 }, { ex + 3, 25 }, { ex, 26 }, { ex + 3, 26 }, { ex + 1, 27 }, { ex + 2, 27 } }, MASK)
  c:eyeSmall(ex + 1, 24)
end
O.dots(c, { { 16, 23 }, { 17, 23 } }, MASK)
O.dots(c, { { 14, 21 }, { 15, 22 }, { 16, 22 }, { 17, 22 }, { 18, 22 }, { 19, 21 } }, P.ink)
O.dot(c, 10, 22, P.petal.base) O.dot(c, 23, 22, P.petal.base)
local cl = O.unionCircles{ { 27, 18, 2.5, 2 }, { 30, 17.5, 2, 2 }, { 29, 20, 2.5, 1.5 } }
O.shade(c, cl, CLD, { R = 1, amb = .4, cuts = { .35, .6, .85 } })
O.dots(c, { { 26, 19 }, { 28, 19 }, { 30, 19 } }, "#5d6b8c")
O.dot(c, 25, 23, CLD[3])
O.done(c, "rr-hammock-hush-perch")
