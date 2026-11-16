-- Harbour Leap (ow-harbour-leap), perch sprite 36x36. Opus second pass (c02/opus2), hand-built at this size.
-- Countershaded dolphin in a high arc over a block breakwater, gold hook-tipped dorsal fin (hook knob), sparkle.
-- Fix vs Haiku: the head end was thin and the eye tiny; now the body swells into a big head with a pill eye
-- and cheek, the back is darker than the belly so the arc reads at 1x.
-- quirk: the red buoy marking its landing spot in the bay.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ow-harbour-leap-perch", 36)

local DOL  = { "#1d3a66", "#25578c", "#3279ac", "#4d9cc8", "#7cc0dc", "#b4e0ec" }
local BELLY = { "#a8c4d4", "#cde0e4", "#e6efe8", "#f2f4e8" }
local STN  = { "#33344a", "#4d4f67", "#6b6d86", "#8d8fa5", "#b0b1c2", "#d2d2dc" }
local SEA  = { "#1d3f55", "#245e74", "#2f8592", "#48aaa6", "#7ccbb8", "#b9e8d4" }
local GOLD = { "#8a5a1c", "#c98a26", "#f0b83a", "#fde08a" }
local BUOY = { "#6a2430", "#a3343a", "#d4553f", "#ef8a5a" }

local wall = c:rect(12, 21, 23, 30)
local wb = {}
wall:each(function(x, y)
  local off = (((y - 21) // 3) % 2) * 3
  if (y - 21) % 3 == 2 or (x + off) % 6 == 0 then wb[K(x, y)] = -2 end
end)
O.shade(c, wall, STN, { R = 2, bias = wb, amb = .25, wrap = .35, rim = true })

local sea = HP.mask()
for x = 2, 33 do
  local top = math.floor(27.5 + .8 * math.sin(x * .5) + .5)
  for y = top, 31 do sea:set(x, y) end
end
O.shade(c, sea, SEA, { R = 1.5, amb = .3, wrap = .4, rim = true })
for x = 2, 33 do
  local top = math.floor(27.5 + .8 * math.sin(x * .5) + .5)
  if math.sin(x * .5) > .3 then O.mark(c, { { x, top } }, SEA[6]) end
end
-- buoy
O.shade(c, c:ellipse(30, 27, 2, 2), BUOY, { R = 1, amb = .3, cuts = { .3, .55, .78 } })
O.mark(c, { { 28, 27 }, { 29, 27 }, { 30, 27 }, { 31, 27 }, { 32, 27 } }, "#f4e4c0")
O.flat(c, c:rect(30, 23, 30, 24), "#4d4f67", "pole") O.dot(c, 30, 23, BUOY[3])

-- dolphin
local m, n, T, S = O.tube({ { 5, 24 }, { 7, 7 }, { 21, 3 }, { 26, 17 } }, function(t)
  if t < .12 then return 1 + t * 6 end
  return math.min(4.2, 1.8 + t * 3.2)
end)
local db, cb = {}, {}
m:each(function(x, y)
  local s = S[K(x, y)] or 0
  if s > .3 and T[K(x, y)] > .1 then db[K(x, y)] = 9 end
  if s < -.1 then cb[K(x, y)] = -1 end
end)
local dI, dT = O.shadeN(c, m, n, DOL, { bias = cb, amb = .2, wrap = .35, rim = true })
O.retone(c, dI, dT, { BELLY[1], BELLY[2], BELLY[2], BELLY[3], BELLY[3], BELLY[4] }, function(x, y, i) return db[K(x, y)] == 9 end)
O.shade(c, O.tube({ { 25, 18 }, { 26, 19 }, { 26, 20 }, { 27, 21 } }, function(t) return 1.2 end), BELLY, { R = 1, amb = .35, sep = DOL[2] })
-- flukes
O.flat(c, c:rect(2, 24, 5, 24), DOL[3], "fluke") O.flat(c, c:rect(5, 25, 6, 27), DOL[2], "fluke")
-- dorsal fin, gold hook
O.flat(c, c:rect(11, 3, 12, 5), DOL[3], "fin") O.dot(c, 11, 3, DOL[5])
O.dots(c, { { 12, 2 }, { 13, 2 }, { 14, 3 } }, GOLD[3]) O.dot(c, 13, 2, GOLD[4])
-- face
c:eyeSmall(20, 10)
O.dot(c, 22, 15, "#f5809f")
O.dots(c, { { 23, 16 }, { 24, 17 }, { 25, 18 } }, DOL[1])

O.shift(c, 0, 1)
O.done(c, "ow-harbour-leap-perch", function(c) c:sparkle(31, 7) end)
