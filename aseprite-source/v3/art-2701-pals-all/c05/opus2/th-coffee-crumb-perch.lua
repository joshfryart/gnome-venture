-- Coffee Crumb (th-coffee-crumb), perch sprite 36x36. Opus second pass (c05/opus2), hand-built at this size.
-- The bean and its too-big fedora, bold and few: brim wider than the bean, red band, brim shadow over the brow,
-- clear pill eyes below it, a grin, the bean crease as a 3 px S on the belly. No paddle at this size.
-- quirk: the roasting steam wisp rising out of the crown dent.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("th-coffee-crumb-perch", 36)

local BEAN = { "#2e1a1c", "#4a2a22", "#6b3d2a", "#8f5634", "#b67645", "#d8a067" }
local HAT  = { "#251c38", "#3a2b56", "#54407c", "#7058a0", "#8e77bf", "#b29ddb" }
local BAND = { "#4f1a26", "#7f2a33", "#b2423d", "#de6a4e", "#f29a6c" }
local STM  = { "#9e93ad", "#c6bccf", "#e6dfe8", "#f7f2f4" }
local BNC  = "#5b4a6e"

c:groundShadow(18, 32, 9, 1.5)
for _, fx in ipairs({ 14, 22 }) do
  O.shade(c, c:ellipse(fx, 30, 2, 1.5), BEAN, { R = 1, amb = .3, sep = BEAN[1] })
end
local body = c:ellipse(18, 22.5, 8, 7.5)
O.shade(c, body, BEAN, { R = 5, amb = .3, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
O.mark(c, { { 22, 25 }, { 21, 26 }, { 21, 27 }, { 22, 28 } }, BEAN[1]) -- bean crease, low on the right
O.mark(c, { { 21, 25 }, { 20, 26 }, { 20, 27 } }, BEAN[5])
O.shade(c, c:ellipse(9.5, 23, 1.5, 2.5), BEAN, { R = 1, amb = .3, sep = BEAN[1] })
O.shade(c, c:ellipse(26.5, 23, 1.5, 2.5), BEAN, { R = 1, amb = .3, sep = BEAN[1] })

-- hat
local brim = c:ellipse(18, 14, 13, 2.5)
local bb = {} brim:each(function(x, y) if y >= 15 then bb[K(x, y)] = -1 end end)
O.shade(c, brim, HAT, { R = 1, bias = bb, amb = .25, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
local crown = c:poly{ { 11, 13 }, { 11, 7 }, { 13, 4 }, { 17, 4 }, { 18, 5 }, { 19, 4 }, { 23, 4 }, { 25, 7 }, { 25, 13 } }
local cb = {} crown:each(function(x, y) if x > 22 then cb[K(x, y)] = -1 end end)
O.shade(c, crown, HAT, { R = 2, bias = cb, amb = .25, wrap = .4, sep = HAT[1], rim = true })
O.mark(c, { { 18, 6 } }, HAT[2]) O.mark(c, { { 17, 6 } }, HAT[5])
O.shade(c, c:rect(11, 10, 25, 12), BAND, { R = 1, amb = .35, wrap = .4, cuts = { .25, .45, .65, .85 }, sep = HAT[1] })
O.mark(c, { { 12, 10 }, { 13, 10 }, { 14, 10 }, { 15, 10 } }, BAND[5])
-- brim shadow on the brow
for x = 12, 24 do if c:get(x, 17) then O.mark(c, { { x, 17 } }, BEAN[2]) end end

-- face
c:eyeSmall(14, 18) c:eyeSmall(20, 18)
c:cheek(11, 22) c:cheek(23, 22)
O.dots(c, { { 16, 22 }, { 17, 23 }, { 18, 23 }, { 19, 22 } }, P.ink)

local function wisps(c)
  local W = { { 18, 4 }, { 17, 3 }, { 17, 2 }, { 18, 1 }, { 18, 0 } }
  for i, p in ipairs(W) do if not c:get(p[1], p[2]) then c:put(p[1], p[2], i < 3 and STM[4] or STM[2]) end end
  for _, p in ipairs({ { 20, 3 }, { 21, 2 }, { 20, 1 } }) do if not c:get(p[1], p[2]) then c:put(p[1], p[2], STM[3]) end end
end
O.shift(c, 0, 1)
O.done(c, "th-coffee-crumb-perch", wisps)
