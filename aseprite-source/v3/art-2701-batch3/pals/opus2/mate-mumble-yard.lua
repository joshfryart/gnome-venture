-- Mate Mumble (rr-mate-mumble), yard sprite 64x64. Opus second pass (art-2701-batch3/pals/opus2).
-- Brewroot, common, Rainroot. "Sips from a gourd all day and hums the rain's favourite tune."
-- A round calabash mate gourd (toasted brown, polished, burnt-in dot band) with a silver rim, a
-- heaped crown of green yerba and a silver bombilla straw with a gold collar. Face on the belly,
-- lips pursed in a hum, two little stubby feet.
-- quirk: two music notes drifting up from the straw tip.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mate-mumble-yard", 64)

local GRD  = { "#3e1e1e", "#64322a", "#8c4e34", "#b46e42", "#d4935a", "#ecbd82" }
local SILV = { "#444663", "#6c6e88", "#9496ac", "#bcbdcc", "#dddde6", "#f1eff4" }
local YERB = { "#24442c", "#3a6233", "#58823c", "#7ea24a", "#a6c266", "#c9dc8e" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local NOTE = { "#35295f", "#5a459e", "#8a6fd0", "#c9b2f0" }

c:groundShadow(31, 57, 16, 3)

-- feet
for _, fx in ipairs({ 24, 38 }) do O.shade(c, c:ellipse(fx, 55, 4, 2), GRD, { R = 1, amb = .25, sep = GRD[1] }) end

-- bombilla straw (behind the yerba crown), angled up-right with a bent mouthpiece
local st, sn = O.tube({ { 34, 26 }, { 38, 18 }, { 42, 11 }, { 45, 6 } }, function(t) return 1.2 end)
O.shadeN(c, st, sn, SILV, { amb = .35, wrap = .4 })
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
  if y == 31 and x % 3 == 0 then gb[K(x, y)] = -2 end
  if y == 32 or y == 30 then gb[K(x, y)] = -1 end
end)
O.shade(c, gourd, GRD, { sphere = { 25, 33, 20 }, bias = gb, amb = .24, wrap = .45 })
O.dots(c, { { 21, 34 }, { 22, 33 }, { 23, 33 } }, GRD[6]) -- polish streak

-- silver rim (virola)
local rim = c:ellipse(31, 25, 10.5, 3)
rim:cut(c:ellipse(31, 24, 8.5, 2))
O.shade(c, rim, SILV, { R = 1, amb = .4, wrap = .4, cuts = { .25, .45, .62, .78, .9 } })
-- yerba crown heaped in the mouth
local yb = c:ellipse(31, 23, 8.5, 4)
yb:cut(c:rect(0, 25, 63, 63))
local ybias = {}
yb:each(function(x, y) if (x * 7 + y * 3) % 5 == 0 then ybias[K(x, y)] = -1 elseif (x + y * 2) % 7 == 0 then ybias[K(x, y)] = 1 end end)
O.shade(c, yb, YERB, { R = 3, bias = ybias, amb = .25, wrap = .4 })
-- straw goes into the yerba
O.dots(c, { { 34, 23 }, { 35, 22 }, { 34, 22 } }, SILV[3])

-- face on the belly
c:eyeLocked(23, 38)
c:eyeLocked(34, 38)
c:cheek(20, 45) c:cheek(40, 45)
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
