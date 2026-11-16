-- Scalecrust Tot (pl-dlz-1), perch sprite 36x36. Opus richness pass (c11/opus3), hand-built at this size.
-- Baby lizard sitting up, big head with an ochre crust cap of plates, pale belly, tail curled out right, laughing
-- open mouth. 2x3 pill eyes on the brick skin. opus3: sparse head beads, plate cracks, throat, rim + bounce. quirk: the crust flake popping off the top, two motion ticks.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-dlz-1-perch", 36)

local SKIN = { "#481a26", "#76283a", "#a43c3a", "#cc5a40", "#e88452", "#f6b47a" }
local CRST = { "#5a2a22", "#8a4a2c", "#b8763c", "#daa05a", "#f0c67e", "#fde2aa" }
local BELY = { "#c47e5a", "#e6aa7c", "#f6cfa0" }

c:groundShadow(18, 33, 10, 1)
local tail, tn = O.tube({ { 22, 29 }, { 30, 31 }, { 33, 26 }, { 30, 23 } }, function(t) return 2.2 * (1 - .65 * t) + .3 end)
O.shadeN(c, tail, tn, SKIN, { amb = .25, wrap = .4, rim = true, bounce = "#6a5a8a", bmax = 2 })
local body = c:ellipse(18, 26, 7, 6)
O.shade(c, body, SKIN, { sphere = { 15, 22, 9 }, amb = .25, wrap = .4, rim = true, bounce = "#6a5a8a", bmax = 2, sep = SKIN[1] })
O.shade(c, c:ellipse(18, 27.5, 3.5, 4), BELY, { sphere = { 17, 25, 5 }, amb = .4, wrap = .5, cuts = { .35, .7 }, sep = SKIN[2] })
for _, s in ipairs({ { 11, 30 }, { 25, 30 } }) do
  O.shade(c, c:ellipse(s[1], s[2], 3, 2.5), SKIN, { sphere = { s[1] - 1, s[2] - 2, 4 }, amb = .3, wrap = .4, sep = SKIN[1] })
  O.dots(c, { { s[1] - 2, 33 }, { s[1], 33 }, { s[1] + 2, 33 } }, CRST[4])
end
local head = c:ellipse(18, 14, 9, 7)
head:add(c:ellipse(18, 17, 8, 4.5))
local hI, hT = O.shade(c, head, SKIN, { sphere = { 14, 10, 11 }, amb = .3, wrap = .4, rim = true, bounce = "#6a5a8a", bmax = 2, sep = SKIN[1] })
O.bumps(c, hI, hT, SKIN, 9, .93, 4)
-- crust cap: three plates and the bare spot
for _, q in ipairs({ { 13, 9 }, { 22.5, 8.5 }, { 18, 9 } }) do
  local pl = c:ellipse(q[1], q[2], 2.5, 1.8) pl:clip(head)
  if q[1] ~= 18 then O.shade(c, pl, CRST, { sphere = { q[1] - 1, q[2] - 1.5, 3 }, amb = .3, wrap = .4, sep = SKIN[2] }) O.mark(c, { { math.floor(q[1]), math.floor(q[2]) } }, CRST[2]) end
end
O.dots(c, { { 17, 8 }, { 18, 8 }, { 19, 8 } }, BELY[3]) O.dots(c, { { 17, 9 }, { 18, 9 } }, BELY[1])
-- laughing mouth
O.flat(c, c:poly{ { 13, 16 }, { 23, 16 }, { 21, 19 }, { 15, 19 } }, "#4a1a2a", "mouth")
O.dots(c, { { 15, 17 }, { 16, 17 }, { 17, 17 }, { 18, 17 }, { 19, 17 }, { 20, 17 }, { 21, 17 } }, "#30121e")
O.dots(c, { { 17, 18 }, { 18, 18 }, { 19, 18 } }, P.petal.base)
for x = 13, 23 do O.dot(c, x, 15, P.ink) end
c:eyeSmall(13, 11)
c:eyeSmall(21, 11)
O.dot(c, 11, 15, P.petal.base) O.dot(c, 25, 15, P.petal.base)
-- the flake popping off
O.shade(c, c:ellipse(25, 3.5, 2, 1.5), CRST, { sphere = { 24, 2.5, 2.5 }, amb = .4, wrap = .45, cuts = { .25, .45, .65, .85 } })

O.done(c, "pl-dlz-1-perch", function(c)
  for _, p in ipairs({ { 22, 6 }, { 28, 6 } }) do c:put(p[1], p[2], CRST[5]) end
end)
