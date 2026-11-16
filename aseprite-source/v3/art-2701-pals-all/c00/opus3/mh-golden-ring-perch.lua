-- Golden Ring (mh-golden-ring), perch sprite 36x36. Opus richness pass (c00/opus3), hand-built at this size.
-- Harvest-braid hoop, face on the thick smooth lower band with 2x3 pill eyes. The opus2 perch sheaf (five inked
-- sticks) is now one solid bow-tie bundle with groove lines, so the hole reads as two clean gaps either side of the
-- waist and the ink load drops. Braid: 8 broad strands, only on the upper half.
-- quirk: three plump wheat ears over the top, ember tie, and the ladybird (one red pixel pair) on the right.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mh-golden-ring-perch", 36)

local GOLD = { "#6a2e1c", "#a4521e", "#d4801f", "#f2aa2e", "#ffd25a", "#fff09e" }
local WHT  = { "#74401f", "#a86f2c", "#d39d40", "#efc463", "#fbe194" }
local STLK = { "#6e4a26", "#9c7438", "#c69c52", "#e6c47c", "#f6e0a2" }
local RIB  = { "#5e1c36", "#a42a40", "#e0473b", "#ff8a5c" }

c:groundShadow(18, 33, 10, 1)
-- three plump wheat ears over the top, fanned with a clear gap: grain rows, pale tip
local EAR = { ".d.", "dcb", "cab", "dcb", "cab", ".b." }
local tone = { a = WHT[2], b = WHT[3], c = WHT[4], d = WHT[5] }
for _, e in ipairs({ { 10, 3 }, { 16, 1 }, { 22, 3 } }) do
  local tok = { r = { name = "ear" } }
  for j, row in ipairs(EAR) do for i = 1, 3 do
    local ch = row:sub(i, i)
    if ch ~= "." then c:put(e[1] + i - 1, e[2] + j - 1, tone[ch], tok) end
  end end
end
O.dot(c, 16, 0, WHT[3]) O.dot(c, 9, 2, WHT[3]) O.dot(c, 25, 2, WHT[3])

-- the sheaf bundle in the hole: bow tie pinched at the tie
local sheaf = c:poly{ { 14, 9 }, { 22, 9 }, { 19, 14 }, { 19, 16 }, { 22, 21 }, { 14, 21 }, { 17, 16 }, { 17, 14 } }
local sI, sT = O.shade(c, sheaf, STLK, { R = 2, amb = .3, wrap = .4, cuts = { .25, .45, .65, .85 } })
O.tex(c, sI, sT, STLK, function(x, y, i) if x % 2 == 1 and y ~= 15 then return -1 end end)
O.flat(c, c:rect(15, 14, 21, 15), RIB[3], "tie") O.dots(c, { { 15, 14 }, { 16, 14 } }, RIB[4])
O.dots(c, { { 20, 15 }, { 21, 15 } }, RIB[2])
O.flat(c, c:rect(21, 16, 22, 17), RIB[2], "tail")

local hoop = c:ellipse(18, 19.5, 14, 13.5)
hoop:cut(c:ellipse(18, 15, 7, 7))
local hI, hT = O.shade(c, hoop, GOLD, { R = 4, amb = .14, wrap = .3, rim = true, bounce = "#9c5478", bmax = 2 })
O.tex(c, hI, hT, GOLD, function(x, y, i)
  if y >= 21 and x >= 7 and x <= 29 then return 0 end
  local a = math.atan(y - 19.5, x - 18)
  local v = (a / (2 * math.pi) * 9 + math.sqrt((x - 18)^2 + (y - 19.5)^2) * .1) % 1
  if v < .16 then return -1 end
  if v > .2 and v < .4 and i >= 3 and i <= 5 then return 1 end
end)
-- ladybird
O.dots(c, { { 27, 11 }, { 28, 11 }, { 28, 12 } }, "#d8333d") O.dot(c, 27, 12, P.ink)

c:eyeSmall(13, 23)
c:eyeSmall(21, 23)
O.dot(c, 11, 26, P.petal.base) O.dot(c, 24, 26, P.petal.base)
O.dots(c, { { 16, 27 }, { 17, 28 }, { 18, 28 }, { 19, 27 } }, P.ink)

O.done(c, "mh-golden-ring-perch")
