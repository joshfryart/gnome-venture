-- Mate Mumble (rr-mate-mumble), yard sprite 64x64. Opus richness pass (art-2701-batch3/pals/opus3), built on opus2.
-- Richness: toasted mottling in the polished calabash, a burnt-in zigzag + dot band (pyrography), rim light on
-- the gourd's upper-left and a cool plum bounce lower-right, engraved ticks on the silver rim, stalk bits in the
-- yerba, a bright streak down the bombilla.
-- Brewroot, common, Rainroot. "Sips from a gourd all day and hums the rain's favourite tune."
-- A round calabash mate gourd (toasted brown, polished, burnt-in dot band) with a silver rim, a
-- heaped crown of green yerba and a silver bombilla straw with a gold collar. Face on the belly,
-- lips pursed in a hum, two little stubby feet.
-- quirk: two music notes drifting up from the straw tip; look closer and a stray yerba leaf is stuck to its cheek.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("mate-mumble-yard", 64)

local GRD  = { "#3e1e1e", "#64322a", "#8c4e34", "#b46e42", "#d4935a", "#ecbd82" }
local SILV = { "#444663", "#6c6e88", "#9496ac", "#bcbdcc", "#dddde6", "#f1eff4" }
local YERB = { "#24442c", "#3a6233", "#58823c", "#7ea24a", "#a6c266", "#c9dc8e" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local NOTE = { "#35295f", "#5a459e", "#8a6fd0", "#c9b2f0" }

c:groundShadow(31, 57, 16, 3)

-- feet
for _, fx in ipairs({ 24, 38 }) do O.shade(c, c:ellipse(fx, 55, 4, 2), GRD, { R = 1, amb = .25, sep = GRD[1], rim = true }) end

-- bombilla straw (behind the yerba crown), angled up-right with a bent mouthpiece
local st, sn = O.tube({ { 34, 26 }, { 38, 18 }, { 42, 11 }, { 45, 6 } }, function(t) return 1.2 end)
O.shadeN(c, st, sn, SILV, { amb = .35, wrap = .4, rim = true })
O.flat(c, c:rect(44, 4, 47, 5), SILV[4], "tip")
O.dots(c, { { 44, 4 }, { 45, 4 } }, SILV[6]) O.dots(c, { { 46, 5 }, { 47, 5 } }, SILV[2])
-- gold collar
O.dots(c, { { 38, 16 }, { 39, 16 }, { 39, 17 }, { 40, 16 }, { 38, 17 } }, GOLD[3])
O.dots(c, { { 40, 17 }, { 39, 18 } }, GOLD[2]) O.dot(c, 38, 16, GOLD[4])

-- gourd body: round bulb with a short neck
local gourd = c:ellipse(31, 41, 15, 14)
gourd:add(c:ellipse(31, 28, 10, 5))
gourd:cut(c:rect(0, 56, 63, 63))
local gb = {}
gourd:each(function(x, y)
  -- burnt-in dot band (pyrography) round the shoulder
  local m4 = x % 4
  if (y == 30 and m4 == 0) or (y == 31 and (m4 == 1 or m4 == 3)) or (y == 32 and m4 == 2) then gb[K(x, y)] = -2 end
  if y == 34 and x % 4 == 2 then gb[K(x, y)] = -2 end
  if y == 29 or y == 33 then gb[K(x, y)] = -1 end
end)
local gI, gT = O.shade(c, gourd, GRD, { sphere = { 25, 33, 20 }, bias = gb, amb = .24, wrap = .45, rim = true, bounce = "#7a5466", bmax = 2 })
-- toasted mottling: soft darker patches in the calabash skin, away from the face
O.tex(c, gI, gT, GRD, function(x, y, i)
  if y < 35 then return end
  local m = math.sin(x * .55 + y * .2) * math.cos(y * .6 - x * .15)
  if m > .72 and i >= 3 and i <= 5 and not (x > 21 and x < 41 and y > 36 and y < 51) then return -1 end
  if y > 50 and H(x, y, 3) > .88 and i >= 2 then return -1 end
end)
O.dots(c, { { 21, 34 }, { 22, 33 }, { 23, 33 } }, GRD[6]) -- polish streak

-- silver rim (virola)
local rim = c:ellipse(31, 25, 10.5, 3)
rim:cut(c:ellipse(31, 24, 8.5, 2))
O.shade(c, rim, SILV, { R = 1, amb = .4, wrap = .4, cuts = { .25, .45, .62, .78, .9 }, rim = true })
for x = 22, 40, 3 do if rim:has(x, 27) then O.mark(c, { { x, 27 } }, SILV[2]) end end -- engraved ticks
-- yerba crown heaped in the mouth
local yb = c:ellipse(31, 23, 8.5, 4)
yb:cut(c:rect(0, 25, 63, 63))
local ybias = {}
yb:each(function(x, y) if (x * 7 + y * 3) % 5 == 0 then ybias[K(x, y)] = -1 elseif (x + y * 2) % 7 == 0 then ybias[K(x, y)] = 1 end end)
O.shade(c, yb, YERB, { R = 3, bias = ybias, amb = .25, wrap = .4, rim = true })
O.mark(c, { { 26, 21 }, { 27, 21 }, { 30, 20 }, { 37, 22 } }, "#d8d08a") -- pale yerba stalk bits
-- straw goes into the yerba
O.dots(c, { { 34, 23 }, { 35, 22 }, { 34, 22 } }, SILV[3])

-- face on the belly
c:eyeLocked(23, 38)
c:eyeLocked(34, 38)
c:cheek(20, 45) c:cheek(40, 45)
-- the stray yerba leaf stuck to its right cheek
O.dots(c, { { 42, 43 }, { 43, 42 } }, YERB[5]) O.dots(c, { { 42, 44 }, { 43, 43 } }, YERB[3]) O.dot(c, 44, 42, YERB[4])
-- nose: a little stem-nub of the gourd, lit tip
O.dots(c, { { 30, 43 }, { 31, 43 } }, GRD[5]) O.dot(c, 30, 43, GRD[6]) O.dots(c, { { 30, 44 }, { 31, 44 } }, GRD[2])
-- humming mouth: pursed "o"
O.dots(c, { { 30, 47 }, { 31, 47 }, { 29, 48 }, { 32, 48 }, { 30, 49 }, { 31, 49 } }, "#3e1620")
O.dots(c, { { 30, 48 }, { 31, 48 } }, "#8e2f3a")

-- quirk: hummed notes drifting up from the straw tip
local function note(x, y, two) -- head 2x2 at (x,y+4), stem up from x+1
  O.flat(c, c:rect(x, y + 4, x + 1, y + 5), NOTE[3], "note")
  O.dot(c, x, y + 4, NOTE[4]) O.dot(c, x + 1, y + 5, NOTE[2])
  O.flat(c, c:rect(x + 2, y, x + 2, y + 4), NOTE[2], "note")
  O.dots(c, { { x + 3, y + 1 }, { x + 4, y + 2 } }, NOTE[3])
end
note(49, 12) note(54, 5)

O.shift(c, -3, 0)
O.done(c, "mate-mumble-yard")
