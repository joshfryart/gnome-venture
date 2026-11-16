-- Lightning Pinch (pl-hcr-1), yard sprite 64x64. Opus second pass (c14/opus2), built on c14/haiku.
-- Thornblade, common, Lair of the Hurricane Crab. "A little claw of lightning that snaps at anyone who sneezes."
-- Haiku drew a round gold ball holding two blue claws; the pal now IS the claw: one crab pincer made of
-- lightning (fat palm with the face, a hooked fixed finger and a lower movable finger, open wide, serrated
-- inner edges), balanced on a zigzag bolt that strikes the ground. Crackle veins run over the palm.
-- quirk: the jaws are snapping at a little sneeze puff (droplets flying), sparks jumping across the gap.
-- closer look: a frown of two slanted brow strokes (thornblade), and the bolt tip scorches a pale mark on the ground.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-hcr-1-yard", 64)

local BOLT = { "#7a3524", "#b8602a", "#e4962c", "#f8c63e", "#ffe57a", "#fff6c4" }
local ZAP  = { "#2c3c78", "#3a6ab0", "#5aa2dc", "#94d2f2", "#d0f0fa" }
local PUFF = { "#76829e", "#b2bfd0", "#dee6ea", "#f6f8ee" }

c:groundShadow(25, 57, 11, 2.5)

-- the bolt it stands on (behind the palm)
local bolt = c:poly{ { 17, 38 }, { 30, 38 }, { 26, 45 }, { 31, 45 }, { 23, 57 }, { 24, 49 }, { 18, 49 } }
local bI, bT = O.shade(c, bolt, BOLT, { R = 2, amb = .3, wrap = .4, rim = true, bounce = "#b0607a", bmax = 2, sep = BOLT[1] })
O.tex(c, bI, bT, BOLT, function(x, y, i) if y == 45 or y == 49 then return -1 end end) -- zig creases

-- lower movable finger (dactyl): from the palm's lower right, curving up, tip pointing up-right
local lf, ln, lT, lS = O.tube({ { 34, 37 }, { 41, 37 }, { 46, 33 }, { 49, 26 } }, function(t) return 4 * (1 - t) ^ .8 + .6 end)
local lI, lTk = O.shadeN(c, lf, ln, BOLT, { amb = .3, wrap = .4, rim = true, bounce = "#b0607a", bmax = 2, sep = BOLT[1] })
-- upper fixed finger (pollex): bigger, sweeping up and hooking over to the right
local uf, un, uT, uS = O.tube({ { 31, 24 }, { 34, 13 }, { 44, 8 }, { 50, 15 } }, function(t) return 5.2 * (1 - t) ^ .75 + .6 end)
local uI, uTk = O.shadeN(c, uf, un, BOLT, { amb = .3, wrap = .4, rim = true, bounce = "#b0607a", bmax = 2, sep = BOLT[1] })

-- palm (propodus) with the face
local palm = c:ellipse(24, 30, 12.5, 10.5)
local pI, pT = O.shade(c, palm, BOLT, { sphere = { 21, 26, 18 }, amb = .36, wrap = .5, rim = true, bounce = "#b0607a", bmax = 2, sep = BOLT[1] })
-- crackle veins: a few pale zigzags over the shell (not on the face)
local veins = { { 14, 22 }, { 15, 21 }, { 16, 22 }, { 17, 21 }, { 30, 21 }, { 31, 20 }, { 32, 21 }, { 33, 20 }, { 34, 21 },
                { 33, 35 }, { 34, 34 }, { 35, 35 }, { 15, 37 }, { 16, 38 }, { 17, 37 } }
O.mark(c, veins, BOLT[3])
-- serrated teeth along the inner edges of both fingers (every other pixel a dark notch)
for _, p in ipairs({ { 36, 22 }, { 38, 19 }, { 41, 17 }, { 44, 17 }, { 47, 19 } }) do O.mark(c, { p }, BOLT[2]) end
for _, p in ipairs({ { 39, 35 }, { 42, 34 }, { 44, 31 }, { 46, 29 } }) do O.mark(c, { p }, BOLT[2]) end
O.dots(c, { { 33, 12 }, { 34, 11 }, { 36, 10 } }, BOLT[6]) -- glint along the top of the hook

-- face
c:eyeLocked(15, 26)
c:eyeLocked(25, 26)
O.dots(c, { { 15, 24 }, { 16, 24 }, { 17, 25 }, { 29, 24 }, { 28, 24 }, { 27, 25 } }, P.ink) -- slanted brows
c:cheek(13, 32) c:cheek(31, 32)
-- snapping open mouth with a top row of little teeth
O.dots(c, { { 20, 33 }, { 21, 33 }, { 22, 33 }, { 23, 33 }, { 24, 33 }, { 19, 34 }, { 25, 34 }, { 20, 35 }, { 24, 35 }, { 21, 36 }, { 22, 36 }, { 23, 36 } }, P.ink)
O.dots(c, { { 20, 34 }, { 22, 34 }, { 24, 34 } }, BOLT[6])
O.dots(c, { { 21, 34 }, { 23, 34 }, { 21, 35 }, { 22, 35 }, { 23, 35 } }, "#8a2a3a")

-- the sneeze puff, up and right of the jaws
local PF = { a = PUFF[4], b = PUFF[3], c = PUFF[2], d = PUFF[1] }
local tokP = { r = { name = "puff" } }
for j, row in ipairs({ "..aa.ab..", ".abbbabbc.", "abbbbbbbc.", "abbbbbbcc.", ".bbbbbccd.", "..cbccdd..", "...dd....." }) do
  for i = 1, #row do local ch = row:sub(i, i) if PF[ch] then c:put(49 + i, 16 + j, PF[ch], tokP) end end
end
O.dots(c, { { 52, 27 }, { 58, 26 }, { 58, 17 } }, ZAP[4]) -- flying droplets

O.done(c, "pl-hcr-1-yard", function(c)
  -- sparks jumping across the open jaws toward the puff (not outlined)
  O.dots(c, { { 42, 25 }, { 43, 24 }, { 44, 25 }, { 45, 24 }, { 46, 25 }, { 47, 24 } }, ZAP[5])
  O.dots(c, { { 41, 28 }, { 42, 29 }, { 43, 28 } }, ZAP[4])
  O.dots(c, { { 47, 21 }, { 47, 23 }, { 46, 22 }, { 48, 22 } }, BOLT[6])
  O.dots(c, { { 21, 59 }, { 25, 59 }, { 23, 58 } }, BOLT[5]) -- scorch flecks where the bolt strikes
end)
