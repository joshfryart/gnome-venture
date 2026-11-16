-- Barrow Peephole (pl-frt-5), yard sprite 64x64. Opus richness pass (c09/opus3), built on c09/opus2.
-- opus3 adds: hue-shifted stone (violet deep -> warm grey light) with lichen and a crack, plank knots and a split,
-- iron hinge straps, frost ferns creeping up the lower planks, icicles off the snow crust, a snow drift on the
-- threshold. Peephole eyes now have a dark-gold lower lid (they read as peeking, not as lights).
-- Rootwarden, uncommon, Barrow of the Frost Toad. "A peephole in the old barrow door, frosty round the edges."
-- A small arched barrow door of old grey-brown planks (grain, dark seams, one iron strap with rivets) set in a
-- frame of mossy barrow stones, a crust of snow on top of the arch. High in the door: a round iron-rimmed
-- peephole, its rim furred with frost crystals all the way round.
-- quirk: two little yellow eyes peek out of the dark peephole (whoever lives in the barrow, like the eyes in the
-- barrow doorway of the lair art).
-- closer look: an iron ring pull hanging from a hook on the right plank.
-- Fixes over haiku: flat rectangle with a target in it (now an arched barrow door in stones, snow on top),
-- one-tone wood (now 6-tone planks with grain), unreadable "eye" in the hole (now two glowing eyes peeking).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-frt-5-yard", 64)

local WOOD = { "#3e2526", "#5e3a2e", "#86583a", "#a87a52", "#c89c6e", "#e2c094" }
local STONE = { "#342c4a", "#4d4866", "#6f6f88", "#9696a6", "#c2bfc6", "#e2ddd8" }
local MOSS = { "#24544a", "#3f9150", "#7cc35a" }
local IRON = { "#2e2a3e", "#4a4660", "#6e6a86", "#9a96b0", "#c4c2d6" }
local SNOW = { "#8bc4ea", "#b9e2f5", "#dff2fb", "#f4fcff" }

c:groundShadow(32, 55, 21, 2)

-- stone frame: an arch of rounded stones
local arch = HP.mask()
local function inArch(x, y, grow) -- arch: rect 19..45 from y=24 down, round top centred (32,24) r=13
  if y >= 24 then return x >= 19 - grow and x <= 45 + grow and y <= 53 end
  return (x + .5 - 32.5) ^ 2 + (y + .5 - 24.5) ^ 2 <= (13.5 + grow) ^ 2
end
for y = 0, 63 do for x = 0, 63 do if inArch(x, y, 4) and not inArch(x, y, 0) then arch:set(x, y) end end end
arch:cut(c:rect(0, 54, 63, 63))
-- stones: split the frame into blocks by angle (top) and height (sides)
local stones = {}
arch:each(function(x, y)
  local id
  if y >= 28 then id = (x < 32 and "L" or "R") .. ((y - 28) // 6)
  else id = "A" .. math.floor((math.atan(y + .5 - 24.5, x + .5 - 32.5) + math.pi) / (math.pi / 6)) end
  stones[id] = stones[id] or HP.mask()
  stones[id]:set(x, y)
end)
for id, m in pairs(stones) do
  local core = m:copy()
  local I, T = O.shade(c, m, STONE, { R = 2, amb = .35, wrap = .45, rim = true, sep = STONE[1] })
  O.tex(c, I, T, STONE, function(x, y, i)
    if H(x, y, 5) > .9 then return -1 end
    if i >= 3 and H(x, y, 6) > .93 then return 1 end
  end)
end
-- a crack in the right stone and pale lichen rosettes
O.dots(c, { { 47, 33 }, { 48, 34 }, { 48, 35 }, { 47, 36 } }, STONE[1])
O.dots(c, { { 16, 37 }, { 17, 37 }, { 16, 38 } }, "#c8c890") O.dot(c, 17, 38, "#9a9a6a")
O.dots(c, { { 46, 46 }, { 47, 46 } }, "#c8c890")
-- moss in the lower stone joints
O.dots(c, { { 16, 46 }, { 17, 47 }, { 16, 52 }, { 47, 41 }, { 48, 40 }, { 47, 52 }, { 48, 53 } }, MOSS[2])
O.dots(c, { { 17, 46 }, { 48, 41 }, { 47, 53 } }, MOSS[3])

-- the door: planks
local door = HP.mask()
for y = 0, 53 do for x = 0, 63 do if inArch(x, y, 0) then door:set(x, y) end end end
local dI, dT = O.shade(c, door, WOOD, { R = 3, amb = .3, wrap = .4, sep = WOOD[1], bounce = "#5a5a8a", bmax = 2 })
O.tex(c, dI, dT, WOOD, function(x, y, i)
  if x == 25 or x == 32 or x == 39 then return -2 end            -- plank seams
  if x == 26 or x == 33 or x == 40 then return 1 end             -- lit plank edge
  local g = H(x, y // 4 + x * 3, 2)
  if g > .82 then return -1 end                                    -- grain streaks
  if i >= 4 and H(x, y // 3, 4) > .9 then return 1 end             -- lit grain
end)
-- knot on the left plank and a split running down from it
O.dots(c, { { 28, 49 }, { 29, 49 }, { 27, 50 }, { 30, 50 }, { 28, 51 }, { 29, 51 } }, WOOD[2])
O.dots(c, { { 28, 50 }, { 29, 50 } }, WOOD[1])
O.dots(c, { { 37, 48 }, { 37, 49 }, { 36, 50 }, { 36, 51 } }, WOOD[1])
O.dots(c, { { 38, 49 }, { 37, 50 } }, WOOD[5])
-- hinge straps on the left (iron, pointed tips)
for _, hy in ipairs({ 28, 49 }) do
  O.shade(c, c:poly{ { 19, hy }, { 24, hy }, { 26, hy + 1 }, { 24, hy + 2 }, { 19, hy + 2 } }, IRON, { R = 1, amb = .35, cuts = { .3, .5, .7, .85 }, sep = IRON[1] })
  O.dot(c, 21, hy + 1, IRON[5])
end
-- frost ferns creeping up the lower planks from the corners
for _, fr in ipairs({ { 20, 53, 1 }, { 44, 53, -1 } }) do
  local x, y, d = fr[1], fr[2], fr[3]
  for k = 0, 4 do
    O.dot(c, x + d * (k // 2), y - k, SNOW[2])
    if k % 2 == 1 then O.dot(c, x + d * (k // 2 + 1), y - k, SNOW[3]) end
  end
  O.dot(c, x + d * 2, y - 5, SNOW[3])
end
-- iron strap with rivets
local strap = c:rect(19, 44, 45, 46)
O.shade(c, strap, IRON, { R = 1, amb = .35, wrap = .4, cuts = { .3, .5, .7, .85 }, sep = IRON[1] })
for _, x in ipairs({ 21, 28, 36, 43 }) do O.dot(c, x, 45, IRON[5]) O.dot(c, x + 1, 46, IRON[1]) end

-- peephole: iron rim, dark hole, frost crystals round the edge
local rimM = c:ellipse(32, 23, 6, 6)
O.shade(c, rimM, IRON, { sphere = { 30, 21, 7 }, amb = .3, wrap = .45, cuts = { .3, .5, .7, .85 }, sep = IRON[1] })
local hole = c:ellipse(32, 23, 3.5, 3.5)
O.flat(c, hole, "#221a30", "hole")
O.dots(c, { { 30, 20 }, { 31, 20 }, { 29, 21 } }, "#3a2e4a") -- inner lip shade
-- the eyes peeking out
O.dots(c, { { 30, 23 }, { 34, 23 } }, "#ffd75a")
O.dots(c, { { 30, 24 }, { 34, 24 }, { 29, 23 }, { 35, 23 } }, "#d98a22")
-- frost: spiky crystals all round the rim
for a = 0, 11 do
  local ang = a * math.pi / 6 + .2
  local x1, y1 = 32 + math.cos(ang) * 6.5, 23 + math.sin(ang) * 6.5
  local x2, y2 = 32 + math.cos(ang) * 8, 23 + math.sin(ang) * 8
  O.dot(c, math.floor(x1 + .5), math.floor(y1 + .5), SNOW[3])
  if a % 2 == 0 then O.dot(c, math.floor(x2 + .5), math.floor(y2 + .5), SNOW[2]) end
end

-- snow crust on top of the arch, drooping over the stones
local snow = HP.mask()
for y = 0, 63 do for x = 0, 63 do
  if inArch(x, y, 5) and not inArch(x, y, 1) and y <= 9 + math.floor(math.abs(x - 32) * .7) + ((H(x, 0, 9) > .5) and 1 or 0) and y < 26 then snow:set(x, y) end
end end
local sI, sT = O.shade(c, snow, SNOW, { R = 2, amb = .45, wrap = .5, cuts = { .35, .6, .82 } })
-- icicles hanging off the crust over the side stones
for _, ic in ipairs({ { 14, 22, 5 }, { 16, 24, 3 }, { 50, 22, 4 }, { 48, 24, 2 } }) do
  for k = 0, ic[3] - 1 do O.dot(c, ic[1], ic[2] + k, k == 0 and SNOW[3] or (k == ic[3] - 1 and SNOW[1] or SNOW[2])) end
end
-- snow drift heaped on the threshold
local drift = c:ellipse(32, 54, 13, 2):cut(c:rect(0, 55, 63, 63))
drift:add(c:ellipse(24, 53.5, 4, 1.5)) drift:add(c:ellipse(41, 53.5, 3, 1.5))
drift:cut(c:rect(0, 55, 63, 63))
O.shade(c, drift, SNOW, { R = 1, amb = .45, wrap = .5, cuts = { .35, .6, .82 } })

-- face on the lower planks
c:eyeLocked(23, 33)
c:eyeLocked(36, 33)
c:cheek(22, 39) c:cheek(40, 39)
O.dots(c, { { 30, 40 }, { 31, 41 }, { 32, 41 }, { 33, 41 }, { 34, 40 } }, P.ink)

-- ring pull on a hook (right plank)
O.dot(c, 42, 49, IRON[2])
local ring = c:ellipse(42, 51.5, 1.5, 1.5):cut(c:rect(42, 51, 42, 52))
O.flat(c, ring, IRON[4], "ring") O.dot(c, 41, 51, IRON[5])

O.done(c, "pl-frt-5-yard")
