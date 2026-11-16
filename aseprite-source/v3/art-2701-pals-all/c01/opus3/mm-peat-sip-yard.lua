-- Peat Sip (mm-peat-sip), yard sprite 64x64. Opus third pass (art-2701-pals-all/c01/opus3), richness pass over
-- opus2: each peat brick gets its own tone and fibre streaks, a dark eave shadow under the roof, the turf roof
-- grows blades (lit tips, dark roots) with a sod edge showing at the eaves and a fringe of drooping grass,
-- the chimney has soot at the top and an ember glow in the flue, the smoke rises in three growing puffs, and
-- a tiny steaming teacup waits on the right foundation stone.
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
O.tex(c, cI, cT, STN, function(x, y, i)
  if y <= 16 then return -2 end -- soot
  if (y % 3 == 0) or ((x + (y // 3) * 3) % 4 == 0 and y % 3 ~= 0 and H(x, y, 2) > .5) then return -1 end
end)
O.flat(c, c:rect(41, 14, 45, 14), STN[1], "flue")
O.dots(c, { { 42, 14 }, { 43, 14 } }, "#e0702a") O.dot(c, 44, 14, "#9a3a2a") -- ember glow in the flue

-- peat walls
local wall = c:rrect(15, 30, 49, 53, 2)
local wb = {}
wall:each(function(x, y) if y <= 35 then wb[K(x, y)] = (y <= 33) and -2 or -1 end end) -- eave shadow
local wI, wT = O.shade(c, wall, PEAT, { R = 6, bias = wb, amb = .15, wrap = .3, sep = PEAT[1], rim = true, bounce = "#5a5a7a", bmax = 2 })
O.tex(c, wI, wT, PEAT, function(x, y, i)
  local face = x > 19 and x < 45 and y > 35 and y < 49
  local row = (y - 30) // 5
  if (y - 30) % 5 == 4 then return -1 end                                -- bed joint
  if (x + row * 4) % 9 == 0 then return -1 end                            -- staggered head joint
  local brick = H((x + row * 4) // 9, row, 3)                              -- each brick its own tone
  local d = (brick > .72) and 1 or ((brick < .25) and -1 or 0)
  if (y - 30) % 5 == 0 and i <= 5 then return 1 + d end                   -- lit top edge of each brick
  if not face and (y - 30) % 5 == 2 and H(x // 2, y, 8) > .7 then return d - 1 end -- fibre streak
  if not face and H(x, y, 8) > .9 then return (H(x, y, 9) > .5) and 1 or -1 end
  return d
end)

-- turf roof
local roof = c:ellipse(32, 31, 22, 12)
roof:cut(c:rect(0, 33, 63, 63))
roof:add(c:rect(11, 31, 53, 33))
roof:cut(ch:copy():cut(c:rect(0, 23, 63, 63)))
local tI, tT = O.shade(c, roof, TURF, { R = 4, amb = .2, wrap = .35, sep = TURF[1], rim = true })
O.tex(c, tI, tT, TURF, function(x, y, i)
  if y >= 32 then return nil end
  -- scattered grass tufts on a jittered grid: a lit blade tip with a dark root under it, and a side blade
  local gx, gy = x // 4, y // 3
  local jx, jy = math.floor(H(gx, gy, 52) * 3), math.floor(H(gx, gy, 53) * 2)
  local cx, cy = gx * 4 + jx, gy * 3 + jy
  if H(gx, gy, 54) < .25 then return nil end
  if x == cx and y == cy then return 1 end
  if x == cx and y == cy + 1 and i >= 2 then return -1 end
  if x == cx + 1 and y == cy + 1 and i >= 3 then return (cx < 32) and 1 or -1 end
end)
-- sod edge at the eaves: the cut turf shows earth and roots
for x = 11, 53 do
  if c.own[32 * 64 + x] == tT then c.pix[32 * 64 + x] = (x % 4 == 0) and PEAT[3] or PEAT[2] end
  if c.own[33 * 64 + x] == tT then c.pix[33 * 64 + x] = (x % 3 == 1) and PEAT[4] or PEAT[2] end
end
-- grass tufts on the ridge and hanging fringe at the eaves
O.dots(c, { { 22, 19 }, { 23, 18 }, { 27, 18 }, { 28, 17 }, { 34, 18 } }, TURF[5])
for x = 12, 52, 3 do O.dot(c, x, 34, TURF[3]) if H(x, 3, 3) > .5 then O.dot(c, x, 35, TURF[2]) end end -- drooping fringe
-- tormentil flowers
O.dots(c, { { 19, 25 }, { 21, 25 }, { 20, 24 }, { 20, 26 } }, "#f0c43a") O.dot(c, 20, 25, "#d0802a")
O.dots(c, { { 33, 22 }, { 35, 22 }, { 34, 21 }, { 34, 23 } }, "#f0c43a") O.dot(c, 34, 22, "#d0802a")

-- smoke curls + the music-note puff
local sm = O.unionCircles{ { 43.5, 11, 2, 1.5 }, { 46.5, 8, 2.5, 2 } }
O.shade(c, sm, SMK, { R = 1, amb = .35, cuts = { .35, .6, .85 }, rim = true })
local note = c:rect(54, 6, 54, 11)
note:add(c:ellipse(52.5, 11.5, 1.5, 1)):add(c:rect(55, 6, 56, 7)):add(c:rect(56, 8, 56, 8))
O.shade(c, note, SMK, { R = 1, amb = .35, cuts = { .35, .6, .85 } })
O.dot(c, 52, 11, SMK[4])
-- a tiny steaming teacup on the right foundation stone
O.flat(c, c:rect(52, 52, 55, 54), "#e8e0d4", "cup") O.dot(c, 52, 53, "#f8f0e4") O.dots(c, { { 55, 53 }, { 55, 54 } }, "#b0a8a8")
O.dot(c, 56, 53, "#d8d0c4") O.dot(c, 53, 54, "#d06a6a") -- handle, a painted rose dot
O.dots(c, { { 53, 52 }, { 54, 52 } }, "#8a5a3a") O.dot(c, 52, 52, "#c8c0b4") -- tea
O.dot(c, 53, 49, SMK[3]) O.dot(c, 54, 50, SMK[2]) -- steam wisp


-- face on the front wall
c:eyeLocked(21, 37)
c:eyeLocked(38, 37)
c:cheek(18, 44) c:cheek(44, 44)
O.dots(c, { { 31, 43 }, { 32, 43 }, { 30, 44 }, { 33, 44 }, { 30, 45 }, { 33, 45 }, { 31, 46 }, { 32, 46 } }, P.ink)
O.dots(c, { { 31, 44 }, { 32, 44 }, { 31, 45 }, { 32, 45 } }, "#8a3a48")

O.done(c, "mm-peat-sip-yard")
