-- Stupa Snug (sp-stupa-snug), perch sprite 36x36. Opus richness pass (c06/opus3), hand-built at this size.
-- Same design as the yard, bolder and fewer parts: violet pal under a warm white dome with a gold rim band,
-- harmika box and gold spire; one prayer-flag string to each side with three flags in the five colours.
-- Richness: lotus-petal ring and rain streaks on the dome, studded gold band, fur strokes, a printed dot on
-- each flag. Face: c:eyeSmall pills under the rim, smile, cheeks.
-- quirk: one hand is up, straightening the last (crooked) flag on the right string.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("sp-stupa-snug-perch", 36)

local VIO  = { "#2e2448", "#45346a", "#614a92", "#8066b4", "#a48ad0", "#cab6e8" }
local DOME = { "#7a6e86", "#a49aa8", "#c8c0c4", "#e2dcd6", "#f2ede4", "#fbf7ee" }
local GOLD = { "#7a3e1c", "#c4741f", "#f0aa2a", "#ffd866", "#fff0b0" }
local FLAG = { { "#2c4e9a", "#4a7ad0" }, { "#d6d0cc", "#f6f2ea" }, { "#a8283a", "#e04a4a" }, { "#2c7a44", "#4eae5a" }, { "#d89a1e", "#f8d050" } }
local STR  = "#7a5a46"
local BNC  = "#4c6a8a"

c:groundShadow(18, 33, 10, 1)
local function bz(a, b, cc, t) local u = 1 - t return u*u*a[1] + 2*u*t*b[1] + t*t*cc[1], u*u*a[2] + 2*u*t*b[2] + t*t*cc[2] end
local S = { { { 17, 5 }, { 9, 7 }, { 2, 13 } }, { { 19, 5 }, { 27, 7 }, { 34, 13 } } }
for _, s in ipairs(S) do
  for i = 0, 40 do local x, y = bz(s[1], s[2], s[3], i / 40) O.dot(c, math.floor(x + .5), math.floor(y + .5), STR) end
end
local order = { { 1, 2, 3 }, { 4, 5, 1 } }
for si, s in ipairs(S) do
  for n, t in ipairs({ .4, .68, .94 }) do
    local x, y = bz(s[1], s[2], s[3], t)
    x, y = math.floor(x + .5) - (si == 1 and 1 or 0), math.floor(y + .5)
    local f = FLAG[order[si][n]]
    for j = 1, 3 do for i = 0, 1 do O.dot(c, x + i + ((si == 2 and n == 3 and j == 3) and 1 or 0), y + j, (i == 0) and f[2] or f[1]) end end
    O.dot(c, x, y + 2, (order[si][n] == 2) and "#a49aa8" or f[1])
  end
end

for _, fx in ipairs({ 13, 23 }) do O.shade(c, c:ellipse(fx, 31.5, 3, 1.5), VIO, { R = 1, amb = .25, bounce = BNC, bmax = 2 }) end
local body = c:ellipse(18, 25, 9.5, 7.5)
local vI, vT = O.shade(c, body, VIO, { sphere = { 15, 22, 11 }, amb = .26, wrap = .35, sep = VIO[1], rim = true, bounce = BNC, bmax = 2 })
O.tex(c, vI, vT, VIO, function(x, y, i)
  if y >= 21 and y <= 28 and x >= 11 and x <= 25 then return 0 end
  if O.H(x, y // 2, 13) > .8 and i >= 2 and i <= 4 then return -1 end
end)
local dome = c:ellipse(18, 19, 9.5, 9)
dome:cut(c:rect(0, 20, 35, 35))
local dI, dT = O.shade(c, dome, DOME, { sphere = { 14, 13, 12 }, amb = .3, wrap = .4, rim = true })
O.tex(c, dI, dT, DOME, function(x, y, i)
  local r = math.sqrt((x - 18)^2 + ((y - 19) * 9.5 / 9)^2)
  if r >= 6.4 and r < 7.4 and y < 16 then return (x % 3 == 0) and -2 or 1 end
  if y > 13 and x % 4 == 1 and i >= 3 and y % 3 ~= 0 then return -1 end
end)
local rim = c:rect(8, 19, 28, 20)
local rb = {} rim:each(function(x, y) if y == 20 then rb[K(x, y)] = -1 else rb[K(x, y)] = 1 end end)
O.shade(c, rim, GOLD, { R = 1, amb = .3, wrap = .45, bias = rb, sep = GOLD[1], cuts = { .22, .42, .62, .82 } })
for x = 10, 26, 4 do O.mark(c, { { x, 19 } }, GOLD[5]) end
O.shade(c, c:rect(16, 8, 20, 10), DOME, { R = 1, amb = .3, sep = DOME[1] })
O.flat(c, c:rect(17, 9, 19, 9), "#a8283a", "band")
O.shade(c, c:poly{ { 17, 7 }, { 19, 7 }, { 18, 3 } }, GOLD, { R = 1, amb = .35, sep = GOLD[1], cuts = { .22, .42, .62, .82 } })
O.dot(c, 18, 2, GOLD[4]) O.dot(c, 17, 6, GOLD[2])

c:eyeSmall(13, 22) c:eyeSmall(21, 22)
O.dots(c, { { 16, 26 }, { 17, 27 }, { 18, 27 }, { 19, 26 } }, P.ink)
c:cheek(10, 26) c:cheek(24, 26)
local arm, an = O.tube({ { 26, 27 }, { 29, 25 }, { 31, 21 }, { 32, 18 } }, function(t) return 1.2 end)
O.shadeN(c, arm, an, VIO, { amb = .3, sep = VIO[1] })
O.dots(c, { { 32, 17 }, { 33, 17 } }, VIO[5])

O.done(c, "sp-stupa-snug-perch")
