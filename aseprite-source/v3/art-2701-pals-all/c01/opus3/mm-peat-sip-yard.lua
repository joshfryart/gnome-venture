-- Peat Sip (mm-peat-sip), yard sprite 64x64. Opus second pass (art-2701-pals-all/c01/opus2), from the Haiku idea.
-- Brewroot, common, Mistmoor. "Puffs warm smoke over the cottage roof and hums about tea."
-- The pal is a little peat croft: walls of stacked, fibrous cut-peat bricks (staggered joints), a mounded turf
-- roof with grass tufts and two tormentil flowers, a fieldstone chimney puffing warm smoke, two flat
-- foundation stones for feet. Face on the front wall, round humming mouth.
-- Fixes: the Haiku dome read as a coconut with a pipe; now walls, roof and chimney say "cottage", peat bricks
-- carry the material, the smoke rises in proper curls.
-- quirk: one smoke puff has curled into a little music note (it is humming about tea).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("mm-peat-sip-yard", 64)

local PEAT = { "#24161e", "#3e2626", "#5c3a2e", "#7e5238", "#a07048", "#c4986a" }
local TURF = { "#1f3a30", "#2f5a3a", "#4a7e44", "#6fa452", "#9cc86a", "#cce496" }
local STN  = { "#33344a", "#4d4f67", "#6b6d86", "#8d8fa5", "#b0b1c2", "#d2d2dc" }
local SMK  = { "#8a8496", "#b2acba", "#d6d0d8", "#eeeaee" }

c:groundShadow(32, 57, 19, 3)
for _, fx in ipairs({ 22, 42 }) do
  O.shade(c, c:rrect(fx - 5, 52, fx + 5, 55, 1), STN, { R = 1, amb = .25, sep = STN[1], rim = true })
end

-- chimney (behind the roof)
local ch = c:rect(40, 14, 46, 28)
local cI, cT = O.shade(c, ch, STN, { R = 2, amb = .2, wrap = .35, sep = STN[1], rim = true })
O.tex(c, cI, cT, STN, function(x, y, i) if (y % 3 == 0) or ((x + (y // 3) * 3) % 4 == 0 and y % 3 ~= 0 and H(x, y, 2) > .5) then return -1 end end)
O.flat(c, c:rect(41, 14, 45, 14), STN[1], "flue")

-- peat walls
local wall = c:rrect(15, 30, 49, 53, 2)
local wI, wT = O.shade(c, wall, PEAT, { R = 6, amb = .15, wrap = .3, sep = PEAT[1], rim = true, bounce = "#5a5a7a", bmax = 2 })
O.tex(c, wI, wT, PEAT, function(x, y, i)
  local face = x > 19 and x < 45 and y > 35 and y < 49
  local row = (y - 30) // 5
  if (y - 30) % 5 == 4 then return -1 end                                -- bed joint
  if (x + row * 4) % 9 == 0 then return -1 end                            -- staggered head joint
  if (y - 30) % 5 == 0 and i <= 5 then return 1 end                       -- lit top edge of each brick
  if not face and H(x, y, 8) > .88 then return (H(x, y, 9) > .5) and 1 or -1 end -- fibres
end)

-- turf roof
local roof = c:ellipse(32, 31, 22, 12)
roof:cut(c:rect(0, 33, 63, 63))
roof:add(c:rect(11, 31, 53, 33))
roof:cut(ch:copy():cut(c:rect(0, 23, 63, 63)))
local tI, tT = O.shade(c, roof, TURF, { R = 4, amb = .2, wrap = .35, sep = TURF[1], rim = true })
O.tex(c, tI, tT, TURF, function(x, y, i)
  if H(x, y, 51) > .8 and i <= 5 then return 1 end
  if y >= 32 then return -1 end
end)
-- grass tufts on the ridge and hanging fringe at the eaves
O.dots(c, { { 22, 19 }, { 23, 18 }, { 27, 18 }, { 28, 17 }, { 34, 18 } }, TURF[5])
for x = 12, 52, 3 do O.dot(c, x, 34, TURF[2]) end
-- tormentil flowers
O.dots(c, { { 19, 25 }, { 21, 25 }, { 20, 24 }, { 20, 26 } }, "#f0c43a") O.dot(c, 20, 25, "#d0802a")
O.dots(c, { { 33, 22 }, { 35, 22 }, { 34, 21 }, { 34, 23 } }, "#f0c43a") O.dot(c, 34, 22, "#d0802a")

-- smoke curls + the music-note puff
local sm = O.unionCircles{ { 44, 10, 2.5, 2 }, { 47.5, 7.5, 2, 1.8 } }
O.shade(c, sm, SMK, { R = 1, amb = .35, cuts = { .35, .6, .85 }, rim = true })
local note = c:rect(54, 6, 54, 11)
note:add(c:ellipse(52.5, 11.5, 1.5, 1)):add(c:rect(55, 6, 56, 7)):add(c:rect(56, 8, 56, 8))
O.shade(c, note, SMK, { R = 1, amb = .35, cuts = { .35, .6, .85 } })
O.dot(c, 52, 11, SMK[4])

-- face on the front wall
c:eyeLocked(21, 37)
c:eyeLocked(38, 37)
c:cheek(18, 44) c:cheek(44, 44)
O.dots(c, { { 31, 43 }, { 32, 43 }, { 30, 44 }, { 33, 44 }, { 30, 45 }, { 33, 45 }, { 31, 46 }, { 32, 46 } }, P.ink)
O.dots(c, { { 31, 44 }, { 32, 44 }, { 31, 45 }, { 32, 45 } }, "#8a3a48")

O.done(c, "mm-peat-sip-yard")
