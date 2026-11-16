-- Golden Ring (mh-golden-ring), perch sprite 36x36. Opus second pass (c00/opus2), hand-built at this size.
-- Twisted straw hoop with a hole wide enough to read (7 px radius against the Haiku's small one), face on the
-- thick lower band with 2x3 pill eyes.
-- quirk: the wheat sheaf filling the hole, three ears poking over the top, ember tie.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mh-golden-ring-perch", 36)

local GOLD = { "#6e3418", "#a8581c", "#d8861e", "#f5b02c", "#ffd658", "#fff0a0" }
local WHT  = { "#7a4a1f", "#b07a32", "#d8a848", "#f0cc6a", "#fbe49a" }
local STLK = { "#7a5a2a", "#a88442", "#d0ac62", "#ecd290" }
local RIB  = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }

c:groundShadow(18, 33, 10, 1)
-- stalks (gaps left open so the hole stays a hole), pinched at the tie
for _, st in ipairs({ { 13, 14 }, { 15, 16 }, { 18, 18 }, { 21, 20 }, { 23, 22 } }) do
  local m = c:line({ { st[1], 7 }, { st[2], 15 }, { st[1], 23 } }, 1)
  O.flat(c, m, STLK[3], "stalk")
end
-- three plump wheat ears over the top: grain rows, pointed tip, an awn
local EAR = { ".a.", "bac", "acb", "bac", "acb", "bab" }
for _, e in ipairs({ { 12, 2 }, { 17, 1 }, { 22, 2 } }) do
  for j, row in ipairs(EAR) do for i = 1, 3 do
    local ch = row:sub(i, i)
    if ch ~= "." then O.dot(c, e[1] + i - 1, e[2] + j - 1, ch == "a" and WHT[4] or ch == "c" and WHT[3] or WHT[2]) end
  end end
  O.dot(c, e[1] + 1, e[2], WHT[5])
end
O.flat(c, c:rect(13, 14, 23, 15), RIB[3], "tie") O.dots(c, { { 13, 14 }, { 14, 14 } }, RIB[4]) O.dots(c, { { 20, 15 }, { 21, 16 }, { 22, 17 } }, RIB[2])

local hoop = c:ellipse(18, 19.5, 14, 13.5)
hoop:cut(c:ellipse(18, 15, 7, 7))
local hI, hT = O.shade(c, hoop, GOLD, { R = 4, amb = .14, wrap = .3, rim = true, bounce = "#a0587a", bmax = 2 })
O.tex(c, hI, hT, GOLD, function(x, y, i)
  if y >= 23 and x >= 9 and x <= 27 then return 0 end
  local a = math.atan(y - 19.5, x - 18)
  local v = (a / (2 * math.pi) * 16 + math.sqrt((x - 18)^2 + (y - 19.5)^2) * .45) % 1
  if v < .2 then return -1 end
end)

c:eyeSmall(13, 24)
c:eyeSmall(21, 24)
O.dot(c, 11, 27, P.petal.base) O.dot(c, 24, 27, P.petal.base)
O.dots(c, { { 16, 28 }, { 17, 29 }, { 18, 29 }, { 19, 28 } }, P.ink)

O.shift(c, 0, 0)
O.done(c, "mh-golden-ring-perch")
