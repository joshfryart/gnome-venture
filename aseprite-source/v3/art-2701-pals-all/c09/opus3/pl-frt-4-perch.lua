-- Frostwart Bumps (pl-frt-4), perch sprite 36x36. Opus richness pass (c09/opus3), hand-built at this size.
-- Squat patch of sage toad skin with spots, goosebump specks and a pale belly; four warts on top, frost caps with
-- an icicle point each. quirk: the third wart has hopped off the back and hangs in the air over its dimple
-- (opus2 had it on a stalk), bump ticks over it. Fewer, bolder details than the yard (no pimples, no flake).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-frt-4-perch", 36)
local TOAD = { "#1d3540", "#2b5648", "#467a50", "#72a05a", "#a5c676", "#d2e4a2" }
local BELLY = { "#8fb86a", "#bcd88a", "#dcecb0", "#f0f8d4" }
local ICE = { "#3a5a9a", "#5a8cd0", "#86c2ea", "#b6e0f5", "#e0f4fc", "#f2fbff" }
c:groundShadow(18, 31, 13, 1.5)
local body = c:ellipse(18, 23, 12, 7):cut(c:rect(0, 30, 35, 35))
body:cut(c:ellipse(21, 16, 2, 1))
local I, T = O.shade(c, body, TOAD, { sphere = { 15, 19, 15 }, amb = .3, wrap = .45, rim = true, bounce = "#4a6aa8", bmax = 2 })
O.tex(c, I, T, TOAD, function(x, y, i)
  if (x < 11 or x > 25 or y < 19) and H(x // 2, y // 2, 7) > .75 then return -1 end
  if (x < 11 or x > 25) and i >= 3 and H(x, y, 11) > .9 then return 1 end
end)
O.dots(c, { { 20, 17 }, { 21, 17 }, { 22, 17 } }, TOAD[1]) O.dot(c, 21, 18, TOAD[5])
O.shade(c, c:ellipse(18, 29, 7, 2):clip(body), BELLY, { R = 1, amb = .45, wrap = .4, cuts = { .35, .6, .85 } })
for wi, w in ipairs({ { 8, 18 }, { 14, 15 }, { 21, 9 }, { 28, 18 } }) do
  local m = c:ellipse(w[1], w[2], 3, 2.5)
  O.shade(c, m, TOAD, { sphere = { w[1] - 1, w[2] - 1, 4 }, amb = .3, wrap = .4, sep = TOAD[1] })
  local cap = HP.mask() m:each(function(x, y) if y <= w[2] - 1 + ((x % 2 == 0) and 1 or 0) then cap:set(x, y) end end)
  O.shade(c, cap, ICE, { sphere = { w[1] - 1, w[2] - 2, 3 }, amb = .4, wrap = .5 })
  O.dot(c, w[1] - 1, w[2] - 2, ICE[6])
  O.dot(c, w[1] + 1, w[2] + 1, ICE[4])
end
c:eyeSmall(13, 21) c:eyeSmall(21, 21)
O.dot(c, 11, 25, P.petal.base) O.dot(c, 24, 25, P.petal.base)
O.dots(c, { { 15, 25 }, { 16, 26 }, { 17, 26 }, { 18, 26 }, { 19, 26 }, { 20, 25 } }, P.ink)
O.dots(c, { { 17, 27 }, { 18, 27 } }, TOAD[5])
O.done(c, "pl-frt-4-perch", function(c)
  O.dots(c, { { 17, 4 }, { 21, 3 }, { 25, 4 } }, ICE[3])
  for _, p in ipairs({ { 17, 13 }, { 25, 13 } }) do if not c:get(p[1], p[2]) then c:put(p[1], p[2], ICE[3]) end end
end)
