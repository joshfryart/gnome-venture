-- Thawdrop Pip (pl-frt-3), perch sprite 36x36. Opus second pass (c09/opus2), hand-built at this size.
-- Meltwater drop (6-tone glassy ramp, window highlight, caustic lower-right), 2x3 pill eyes.
-- quirk: mid-yawn, a tall open mouth with a pink tongue; a sleepy bead falling off the tip.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-frt-3-perch", 36)
local WATER = { "#1f3a6e", "#2a5f9a", "#3a86b0", "#5fc4c8", "#9ee6dc", "#dcfaf2" }
c:groundShadow(18, 31, 9, 1.5)
local cy, r, top = 21, 9, 5
local drop = HP.mask()
for y = top, cy + r do
  local w, cx
  if y <= cy then local s = (y - top) / (cy - top) w = r * math.sin(s * math.pi / 2) ^ 1.5 cx = 17.5 + 2.5 * (1 - s) ^ 2
  else w = math.sqrt(math.max(0, r * r - (y - cy) ^ 2)) + .3 cx = 17.5 end
  for x = math.floor(cx - w), math.ceil(cx + w) do if math.abs(x - cx) <= w then drop:set(x, y) end end
end
local I, T = O.shade(c, drop, WATER, { sphere = { 15, 17, 12 }, amb = .28, wrap = .6, rim = true, bounce = "#7a6fc0", bmax = 3 })
local inner = drop:copy():cut(drop:edge())
O.tex(c, I, T, WATER, function(x, y, i) if inner:edge():has(x, y) and (x - 18) + (y - 22) > 5 and y > 21 then return 3 end end)
O.dots(c, { { 11, 18 }, { 11, 19 }, { 12, 16 }, { 13, 15 } }, WATER[6])
c:eyeSmall(13, 18) c:eyeSmall(21, 18)
O.dot(c, 11, 22, P.petal.base) O.dot(c, 24, 22, P.petal.base)
local mouth = c:rect(17, 22, 18, 25)
O.flat(c, mouth, "#5a2a4a", "mouth") O.dots(c, { { 17, 25 }, { 18, 25 } }, P.petal.base)
O.dots(c, { { 16, 22 }, { 16, 23 }, { 16, 24 }, { 16, 25 }, { 19, 22 }, { 19, 23 }, { 19, 24 }, { 19, 25 }, { 17, 21 }, { 18, 21 }, { 17, 26 }, { 18, 26 } }, P.ink)
O.flat(c, c:rect(25, 8, 26, 9), WATER[4], "bead") O.dot(c, 25, 8, WATER[6])
O.done(c, "pl-frt-3-perch")
