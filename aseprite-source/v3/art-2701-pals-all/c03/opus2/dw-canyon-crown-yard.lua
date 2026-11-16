-- Canyon Crown (dw-canyon-crown), yard sprite 64x64. Opus second pass (art-2701-pals-all/c03/opus2), built on the
-- Haiku first pass. Uncommon, rootwarden, Dunewhisper. "Wears a rose-red crown of cliff and never takes it off."
-- A warm sandstone boulder (Dunewhisper sand, not the first pass's grey) with faint strata and wind pits; its crown
-- is a rose-red canyon skyline on a cliff band: a flat mesa, a tall butte with a natural arch cut clean through it
-- (an enclosed 7x8 hole you can see the sky through; the first pass's arch was 2 px), and a leaning spire. The crown
-- carries sandstone strata stripes. quirk: worn so long a tiny cactus has taken root on top of the mesa.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("dw-canyon-crown-yard", 64)

local SND  = { "#5a3e2e", "#8a6040", "#b68a5a", "#d4ac78", "#ead0a0", "#f8e8c8" }
local ROSE = { "#5a1e2a", "#8a2e38", "#b8464a", "#d86a62", "#ec9a86", "#f8c8b4" }
local CAC  = { "#1f4a3c", "#3a7a48", "#6aae58", "#a8d878" }

c:groundShadow(32, 58, 19, 2.5)
for _, fx in ipairs({ 24, 40 }) do O.shade(c, c:ellipse(fx, 55, 4.5, 2), SND, { R = 1, amb = .25, sep = SND[1] }) end

-- sandstone boulder body
local body = c:ellipse(32, 44, 17, 11)
body:add(c:ellipse(25, 41, 9, 8))
local bI, bT = O.shade(c, body, SND, { sphere = { 27, 38, 18 }, amb = .2, wrap = .4, sep = SND[1], rim = true, bounce = "#8a7ab0", bmax = 2 })
O.tex(c, bI, bT, SND, function(x, y, i)
  local face = x > 21 and x < 43 and y > 39 and y < 53
  if not face and y % 4 == 0 and H(x, y, 3) > .3 and i >= 2 then return -1 end -- strata
  if not face and H(x, y, 9) > .93 and i >= 2 then return -1 end -- wind pits
end)

-- the crown: mesa, arched butte, spire on a cliff band
local crown = c:poly{ { 13, 37 }, { 14, 25 }, { 16, 24 }, { 23, 24 }, { 24, 27 } }          -- mesa
crown:add(c:poly{ { 22, 37 }, { 25, 18 }, { 27, 15 }, { 36, 15 }, { 38, 18 }, { 41, 37 } })   -- butte
crown:add(c:poly{ { 39, 37 }, { 42, 23 }, { 44, 17 }, { 46, 18 }, { 48, 25 }, { 51, 37 } })   -- spire
crown:add(c:rect(13, 32, 51, 37))                                                             -- cliff band
crown:cut(c:ellipse(31.5, 25.5, 3.5, 4.5))                                                     -- the arch
crown:cut(c:rect(28, 25, 35, 29))
local cI, cT = O.shade(c, crown, ROSE, { R = 3, amb = .22, wrap = .4, sep = ROSE[1], rim = true, bounce = "#7a5aa8", bmax = 2 })
O.tex(c, cI, cT, ROSE, function(x, y, i) -- sandstone strata
  if y % 3 == 0 and i >= 2 then return -1 end
  if y % 6 == 1 and i <= 5 and H(x, y, 4) > .4 then return 1 end
end)
for x = 13, 51 do if crown:has(x, 32) then c:put(x, 32, ROSE[2], cT) end end -- band top edge
O.dots(c, { { 16, 35 }, { 22, 35 }, { 28, 35 }, { 34, 35 }, { 40, 35 }, { 46, 35 } }, ROSE[5]) -- band studs

-- quirk: a tiny cactus rooted on the mesa
local cac = c:rect(18, 18, 19, 23)
cac:add(c:rect(16, 20, 16, 21)) cac:add(c:rect(16, 21, 17, 21)) cac:add(c:rect(21, 19, 21, 20)) cac:add(c:rect(20, 20, 21, 20))
O.shade(c, cac, CAC, { R = 1, amb = .4, cuts = { .3, .55, .8 } })
O.dot(c, 18, 17, "#f5809f")

-- face
c:eyeLocked(24, 42) c:eyeLocked(35, 42)
c:cheek(21, 48) c:cheek(41, 48)
O.dots(c, { { 29, 49 }, { 30, 50 }, { 31, 50 }, { 32, 50 }, { 33, 50 }, { 34, 49 } }, P.ink)

O.done(c, "dw-canyon-crown-yard")
