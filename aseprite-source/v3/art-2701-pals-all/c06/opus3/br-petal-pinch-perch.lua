-- Petal Pinch (br-petal-pinch), perch sprite 36x36. Opus richness pass (c06/opus3), hand-built at this size.
-- Same design as the yard, fewer and bolder parts: berry-rose round pal, two round sprout leaves, a moss-green
-- pocket with pale petal tips peeking out, one hand up pinching a notched sakura petal.
-- Richness: velvet pinpricks on the skin, leaf midribs, linen weave and a dark lip on the pocket, a blush vein
-- on the big petal. Face: c:eyeSmall pills, smile, cheeks.
-- quirk: one petal has slipped out of the full pocket and drifts down at the left.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("br-petal-pinch-perch", 36)

local ROSE = { "#3e1630", "#642444", "#8c3460", "#b44c7a", "#d4709a", "#eca2bc" }
local SAK  = { "#c2708e", "#eea4b8", "#fbcdd8", "#fff0f2" }
local LEAF = { "#1f3b2e", "#2c5a3a", "#3f7f43", "#5ea24c", "#8cc463", "#c2e290" }
local CLTH = { "#24402e", "#33583a", "#4a7646", "#6a9656", "#92b872", "#bcd89a" }
local BNC  = "#5a5a8a"

local function petal(x, y, pat)
  local m = HP.mask()
  for j, row in ipairs(pat) do for i = 1, #row do if row:sub(i, i) == "#" then m:set(x + i - 1, y + j - 1) end end end
  O.shade(c, m, SAK, { sphere = { x, y, #pat[1] + 1 }, amb = .45, wrap = .5, sep = SAK[1], cuts = { .3, .55, .8 } })
end

c:groundShadow(17, 32, 10, 1.5)
for _, fx in ipairs({ 13, 21 }) do O.shade(c, c:ellipse(fx, 30, 2.5, 1.5), ROSE, { R = 1, amb = .25, bounce = BNC, bmax = 2 }) end
local rI, rT = O.shade(c, c:ellipse(17, 21, 9.5, 8.5), ROSE, { sphere = { 14, 17, 11 }, amb = .26, wrap = .35, rim = true, bounce = BNC, bmax = 2, sep = ROSE[1] })
O.tex(c, rI, rT, ROSE, function(x, y, i)
  if y >= 16 and y <= 23 and x >= 9 and x <= 25 then return 0 end
  if (x * 2 + y * 3) % 7 == 0 then if i >= 4 then return 1 elseif i >= 2 then return -1 end end
end)
O.flat(c, c:rect(17, 9, 17, 12), LEAF[3], "stem")
O.shade(c, c:ellipse(14, 9.5, 2.5, 1.5), LEAF, { R = 1, amb = .35, sep = LEAF[1] })
O.shade(c, c:ellipse(21, 8.5, 2.5, 1.5), LEAF, { R = 1, amb = .25, sep = LEAF[1] })
O.dots(c, { { 13, 9 }, { 14, 9 } }, LEAF[2]) O.dots(c, { { 21, 8 }, { 22, 8 } }, LEAF[2])

c:eyeSmall(12, 17) c:eyeSmall(20, 17)
O.dots(c, { { 15, 21 }, { 16, 22 }, { 17, 22 }, { 18, 21 } }, P.ink)
c:cheek(9, 21) c:cheek(23, 21)

for _, px in ipairs({ 12, 16, 20 }) do petal(px, 24, { "#.#", "###" }) end
local pk = c:rrect(10, 26, 24, 30, 2)
local pb = {} pk:each(function(x, y) if y == 26 then pb[K(x, y)] = 2 end end)
local cI, cT = O.shade(c, pk, CLTH, { R = 1, amb = .3, wrap = .4, bias = pb, sep = CLTH[1] })
O.tex(c, cI, cT, CLTH, function(x, y, i) if y == 26 then return -1 end if y % 2 == 1 and x % 2 == 0 and y > 27 then return -1 end end)
O.dots(c, { { 12, 27 }, { 16, 27 }, { 20, 27 } }, "#f0c050")

petal(3, 22, { "##", ".#" }) -- quirk: the slipped petal

local arm, an = O.tube({ { 25, 22 }, { 28, 20 }, { 29, 16 }, { 29, 13 } }, function(t) return 1.2 end)
O.shadeN(c, arm, an, ROSE, { amb = .3, sep = ROSE[1] })
petal(27, 7, { "##.##", "#####", ".###.", "..#.." })
O.dots(c, { { 28, 11 }, { 30, 11 } }, ROSE[5])
O.mark(c, { { 29, 10 } }, SAK[1]) O.mark(c, { { 29, 9 } }, SAK[2])

O.shift(c, 0, -1)
O.done(c, "br-petal-pinch-perch")
