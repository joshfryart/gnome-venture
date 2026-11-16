-- Snowcrag Halo (pl-owl-5), perch sprite 36x36. Opus second pass (c10/opus2), hand-built at this size.
-- Snow mound on grey crag rock with a scooped blue hollow on top and an aurora halo floating over it (violet back,
-- green front). Pill eyes on the snowy front.
-- quirk: two sleeping owlet heads in the hollow (shut eyes, gold beaks).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-owl-5-perch", 36)

local SNOW = { "#3a4a78", "#5f7aa8", "#8eaccc", "#bcd4e6", "#e0eef4", "#f6fbfa" }
local ROCK = { "#2e2c40", "#47465e", "#666780", "#8a8ca2", "#aeb0c2" }
local OWL  = { "#6a6482", "#9a94b0", "#c4c0d4", "#e2e0ea", "#f6f4f6" }
local GRN  = { "#24544a", "#2f8a6a", "#4fc08e", "#9aeab4", "#d6fbe0" }
local VIO  = { "#35295f", "#5a459e", "#8a6fd0", "#c9b2f0" }

c:groundShadow(18, 32, 14, 1.5)
local ringO, ringI = c:ellipse(18, 6, 10, 3.5), c:ellipse(18, 6, 8, 2)
O.shade(c, ringO:copy():cut(ringI):clip(c:rect(0, 0, 35, 5)), VIO, { R = 1, amb = .45, wrap = .5, cuts = { .3, .55, .8 }, nopop = true })
local rock = O.unionCircles{ { 7, 28, 4, 3.5 }, { 29, 28, 4, 3.5 } }
O.shade(c, rock, ROCK, { R = 1, amb = .25, wrap = .4, cuts = { .25, .45, .65, .85 } })
local mound = c:ellipse(18, 22, 13, 8.5)
mound:add(c:ellipse(18, 16, 11, 4))
mound:cut(c:rect(0, 31, 35, 35))
O.shade(c, mound, SNOW, { sphere = { 14, 16, 17 }, amb = .35, wrap = .55, rim = true, bounce = "#7a8ad0", bmax = 3, sep = ROCK[1] })
c:ellipse(18, 16, 9, 2.5):each(function(x, y) c.pix[y * c.w + x] = SNOW[(y < 16) and 1 or 2]:lower() end)
for x = 10, 26 do
  local u = (x - 18) / 9
  local y = math.floor(16 + 2.5 * math.sqrt(math.max(0, 1 - u * u)) + .5)
  if mound:has(x, y) then O.mark(c, { { x, y } }, SNOW[6]) end
end
for _, o in ipairs({ 14, 22 }) do
  local h = c:ellipse(o, 14, 2.5, 2.5)
  h:cut(c:rect(0, 17, 35, 35))
  O.shade(c, h, OWL, { sphere = { o - 1, 12, 4 }, amb = .3, wrap = .5, cuts = { .25, .45, .65, .85 }, sep = OWL[1] })
  O.dots(c, { { o - 1, 14 }, { o + 1, 14 } }, OWL[1])
  O.dot(c, o, 15, "#f5b82e")
end
c:eyeSmall(12, 21)
c:eyeSmall(22, 21)
O.dot(c, 10, 25, "#f5809f") O.dot(c, 25, 25, "#f5809f")
O.dots(c, { { 16, 25 }, { 17, 26 }, { 18, 26 }, { 19, 25 } }, P.ink)
O.shade(c, ringO:copy():cut(ringI):clip(c:rect(0, 6, 35, 35)), GRN, { R = 1, amb = .4, wrap = .5, cuts = { .25, .45, .65, .85 } })

O.shift(c, 0, 0)
O.done(c, "pl-owl-5-perch")
