-- Kapok Nook (rr-kapok-nook), yard sprite 64x64. Opus second pass (art-2701-batch3/pals/opus2).
-- Seedkeeper, common, Rainroot. "Naps behind a tiny door in a tree root and calls it a castle."
-- A split kapok pod (olive-brown husk with pointed ends) brimming with a cloud of silky fluff; the
-- face sits in the fluff, lids half down, snoozing. Dark kapok seeds peek out of the floss.
-- It rests on a fat buttress root with bark grain.
-- quirk: the root has a tiny arched castle door with a gold knob and a pennant flying over it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("kapok-nook-yard", 64)

local BARK = { "#3a2329", "#5a3530", "#7c4f3a", "#9e6c48", "#bf8d5c", "#dcb27c" }
local HUSK = { "#2f2a1f", "#4c4228", "#6c6033", "#8c7d3f", "#ab9a52", "#c9b874" }
local FLUF = { "#6c5f80", "#9488aa", "#bbb0cb", "#d8d0e2", "#ece6ee", "#faf3ee" }
local DOOR = { "#3d2422", "#5e3a2c", "#7e5236", "#9b6a42" }

c:groundShadow(32, 58, 22, 3)

-- root: a fat knobbly knuckle on the left (the "castle"), tapering into a root that runs under the pod
local root = c:ellipse(14, 49, 11, 10)
root:add(c:ellipse(10, 56, 7, 2.5))
local tail, tn = O.tube({ { 20, 52 }, { 32, 47 }, { 48, 48 }, { 58, 56 } }, function(t) return 3.6 - 1.8 * t end)
root:add(tail)
root:cut(c:rect(0, 58, 63, 63))
local rb = {}
root:each(function(x, y) -- bark grain: arcs round the knuckle, streaks along the tail
  local d = math.sqrt((x - 14) ^ 2 + ((y - 49) * 1.1) ^ 2)
  if x < 25 and (math.abs(d - 8) < .5 or math.abs(d - 5) < .5) and (x + y) % 5 ~= 0 then rb[K(x, y)] = -1 end
  if x >= 25 and (x + y) % 7 == 0 then rb[K(x, y)] = -1 end
end)
O.shade(c, root, BARK, { R = 5, bias = rb, amb = .2, wrap = .4 })

-- quirk: castle door in the knuckle + pennant on top
local door = c:rect(10, 50, 17, 57)
door:add(c:ellipse(13.5, 50, 3.5, 3))
door:cut(c:rect(0, 58, 63, 63))
local frame = door:grow(1)
frame:cut(c:rect(0, 58, 63, 63))
O.flat(c, frame, BARK[6], "frame")
O.mark(c, { { 18, 51 }, { 18, 52 }, { 18, 53 }, { 18, 54 }, { 18, 55 }, { 18, 56 }, { 18, 57 }, { 17, 48 }, { 18, 49 }, { 18, 50 }, { 17, 47 } }, BARK[4])
O.flat(c, door, DOOR[3], "door")
for y = 48, 57 do O.mark(c, { { 12, y }, { 15, y } }, DOOR[2]) end
O.dots(c, { { 11, 48 }, { 13, 47 }, { 11, 49 }, { 10, 50 } }, DOOR[4])
O.dots(c, { { 17, 52 }, { 17, 53 }, { 17, 54 }, { 17, 55 }, { 17, 56 }, { 17, 57 }, { 16, 48 }, { 17, 50 }, { 17, 51 } }, DOOR[1])
O.dot(c, 16, 53, "#ffe38a") O.dot(c, 16, 54, "#d98322") -- gold knob
-- pennant pole + flag on the crown of the knuckle
O.flat(c, c:rect(12, 32, 12, 39), DOOR[4], "pole")
O.dot(c, 12, 31, "#f5b82e")
local flag = c:poly{ { 13, 32 }, { 19, 34 }, { 13, 36 } }
O.flat(c, flag, "#e8493b", "flag")
O.dots(c, { { 13, 32 }, { 14, 33 }, { 15, 33 } }, "#ff8a5c")
O.dots(c, { { 13, 36 }, { 14, 35 }, { 15, 35 } }, "#b52e3f")

-- fluff cloud (drawn first so the husk cup overlaps its lower half)
local fl = O.unionCircles{ { 39, 33, 13, 11 }, { 29, 28, 5 }, { 35, 23, 5 }, { 43, 22, 5 }, { 50, 27, 5 },
                           { 53, 34, 4 }, { 26, 35, 4 }, { 39, 21, 4 } }
local fb = {}
fl:each(function(x, y) -- floss strands: soft darker curls in the fluff
  if y > 36 then fb[K(x, y)] = -1 end
end)
O.shade(c, fl, FLUF, { R = 6, bias = fb, amb = .3, wrap = .45 })
-- silky curls drawn into the floss
for _, cl in ipairs({ { { 31, 25 }, { 32, 24 }, { 33, 24 } }, { { 42, 20 }, { 43, 19 }, { 44, 19 } },
                      { { 49, 25 }, { 50, 25 }, { 51, 26 } }, { { 53, 31 }, { 54, 32 } }, { { 27, 33 }, { 26, 34 } } }) do
  O.mark(c, cl, FLUF[3])
end
-- dark kapok seeds caught in the floss
for _, s in ipairs({ { 48, 23 }, { 27, 31 } }) do
  O.dots(c, { { s[1], s[2] }, { s[1] + 1, s[2] }, { s[1] + 1, s[2] + 1 }, { s[1] + 2, s[2] + 1 } }, "#3b2f36")
  O.dot(c, s[1], s[2], "#6a5662")
end

-- husk cup with pointed ends
local husk = c:ellipse(39, 41, 16, 7)
husk:cut(c:rect(0, 0, 63, 38))
husk:add(c:poly{ { 20, 34 }, { 25, 38 }, { 24, 42 } })
husk:add(c:poly{ { 59, 34 }, { 54, 38 }, { 55, 42 } })
local hb = {}
husk:each(function(x, y)
  if y == 39 then hb[K(x, y)] = 1 end -- lit lip
  if x == 39 and y > 40 then hb[K(x, y)] = -2 end -- seam
  if (x == 30 or x == 48) and y > 41 then hb[K(x, y)] = -1 end -- ribs
end)
O.shade(c, husk, HUSK, { R = 4, bias = hb, amb = .18, wrap = .3, sep = HUSK[1] })

-- face in the fluff: sleepy half-lids over locked eyes
for _, ex in ipairs({ 31, 42 }) do
  c:eyeLocked(ex, 30)
  O.dots(c, { { ex + 1, 30 }, { ex + 2, 30 }, { ex + 3, 30 }, { ex, 31 }, { ex + 1, 31 }, { ex + 2, 31 }, { ex + 3, 31 }, { ex + 4, 31 } }, FLUF[3])
  O.dots(c, { { ex, 32 }, { ex + 1, 32 }, { ex + 2, 32 }, { ex + 3, 32 }, { ex + 4, 32 } }, FLUF[1])
  O.dot(c, ex + 1, 33, P.cream)
end
c:cheek(28, 35) c:cheek(48, 35)
-- button nose, mauve, lit tip
O.dots(c, { { 38, 34 }, { 39, 34 } }, "#a07a9a") O.dot(c, 38, 34, "#c9a2bd") O.dot(c, 39, 35, "#6c4a68") O.dot(c, 38, 35, "#6c4a68")
-- snoozing mouth, small and round
O.dots(c, { { 38, 37 }, { 39, 37 } }, "#6e2c4a")

O.shift(c, 0, -4)
O.done(c, "kapok-nook-yard")
