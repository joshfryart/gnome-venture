-- Chilli Chime (sp-chilli-chime), perch sprite 36x36. Opus second pass (art-2701-pals-all/c06/opus2), hand-built at this size.
-- Same design as the yard, fewer and bolder parts: round moss pal, wooden peg, one chilli garland strand to
-- each side with two hooked chillis and a gold bell at the end. Face: c:eyeSmall pills 6 px apart, smile, cheeks.
-- quirk: the wind swings every chilli to the right and the bells ring (ticks, un-outlined).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("sp-chilli-chime-perch", 36)

local MOSS = { "#24423a", "#33664a", "#4a8c4c", "#6cb256", "#9ad06a", "#cdea98" }
local WOOD = { "#3a2422", "#5e3a2a", "#86573a", "#ad7c4f", "#cfa36c", "#ead0a0" }
local CHIL = { "#4a1020", "#7a1626", "#b01e2c", "#d8303a", "#f05a58", "#ff9e92" }
local GOLD = { "#7a3e1c", "#c4741f", "#f0aa2a", "#ffd866", "#fff0b0" }
local TWN  = "#8a6040"
local BNC  = "#4c6a8a"

c:groundShadow(18, 32, 10, 1.5)
local body = c:ellipse(18, 23.5, 10.5, 8.5)
O.shade(c, body, MOSS, { sphere = { 14, 19, 12 }, amb = .26, wrap = .35, rim = true, bounce = BNC, bmax = 2 })
O.shade(c, c:rect(17, 6, 18, 16), WOOD, { R = 1, amb = .3, wrap = .4, sep = MOSS[2] })
O.shade(c, c:ellipse(17.5, 5, 2, 1.5), WOOD, { sphere = { 17, 4, 2 }, amb = .3 })

local function bz(a, b, cc, t) local u = 1 - t return u*u*a[1] + 2*u*t*b[1] + t*t*cc[1], u*u*a[2] + 2*u*t*b[2] + t*t*cc[2] end
local G = { { { 17, 6 }, { 9, 12 }, { 4, 17 } }, { { 18, 6 }, { 26, 12 }, { 31, 17 } } }
for _, g in ipairs(G) do
  for i = 0, 40 do local x, y = bz(g[1], g[2], g[3], i / 40) O.dot(c, math.floor(x + .5), math.floor(y + .5), TWN) end
end
local function chilli(ax, ay)
  O.dots(c, { { ax, ay + 1 }, { ax, ay + 2 }, { ax + 1, ay + 3 }, { ax + 1, ay + 4 }, { ax + 2, ay + 5 } }, CHIL[3])
  O.dots(c, { { ax + 1, ay + 1 }, { ax + 1, ay + 2 }, { ax + 2, ay + 3 }, { ax + 2, ay + 4 } }, CHIL[2])
  O.dot(c, ax, ay + 1, CHIL[5]) O.dot(c, ax, ay + 2, CHIL[4])
  O.dot(c, ax, ay, "#6cb256") O.dot(c, ax + 1, ay, "#33664a")
end
for _, t in ipairs({ .4, .78 }) do
  local x, y = bz(G[1][1], G[1][2], G[1][3], t) chilli(math.floor(x + .5), math.floor(y + .5) + 1)
  x, y = bz(G[2][1], G[2][2], G[2][3], t) chilli(math.floor(x + .5), math.floor(y + .5) + 1)
end
for _, bx in ipairs({ 4, 31 }) do
  local m = c:poly{ { bx - 1, 17 }, { bx + 1, 17 }, { bx + 2, 20 }, { bx - 2, 20 } }
  O.shade(c, m, GOLD, { sphere = { bx - 1, 18, 3 }, amb = .35, wrap = .4, cuts = { .25, .45, .65, .85 } })
  O.dot(c, bx, 21, GOLD[1])
end

c:eyeSmall(13, 21) c:eyeSmall(21, 21)
O.dots(c, { { 16, 25 }, { 17, 26 }, { 18, 26 }, { 19, 25 } }, P.ink)
c:cheek(10, 25) c:cheek(24, 25)

O.done(c, "sp-chilli-chime-perch", function(c)
  for _, p in ipairs({ { 0, 17 }, { 1, 16 }, { 35, 17 }, { 34, 16 }, { 35, 20 } }) do
    if not c.pix[p[2] * c.w + p[1]] then c:put(p[1], p[2], GOLD[4]) end
  end
end)
