-- Harbour Leap (ow-harbour-leap), yard sprite 64x64. Opus second pass (art-2701-pals-all/c02/opus2), built on the Haiku pass.
-- Wayfinder, RARE, Olivewhistle. "Leaps the breakwater and lands in the same bay every time."
-- A chunky sea-blue dolphin mid-leap in a high arc over a stone breakwater, sea on both sides. Countershaded
-- (pale belly), a big rounded melon head with the locked eye and a smile running along the beak, flippers and
-- flukes. Rare touch: the dorsal fin curls into a gold hook (hook knob), gold fin edge, sparkles in the air.
-- Fix vs Haiku: the head end was thin with a tiny eye, so the face was weak; now the body thickens towards a
-- big head that holds a full 5x5 eye; the splash is a real water crown with drops, not dots; the breakwater is
-- built from lit stone blocks.
-- quirk: a little red-and-cream buoy bobs in the bay ahead, marking the exact spot it always lands on.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ow-harbour-leap-yard", 64)

local DOL  = { "#1d3a66", "#25578c", "#3279ac", "#4d9cc8", "#7cc0dc", "#b4e0ec" }
local BELLY = { "#a8c4d4", "#cde0e4", "#e6efe8", "#f2f4e8" }
local STN  = { "#33344a", "#4d4f67", "#6b6d86", "#8d8fa5", "#b0b1c2", "#d2d2dc" }
local SEA  = { "#1d3f55", "#245e74", "#2f8592", "#48aaa6", "#7ccbb8", "#b9e8d4" }
local GOLD = { "#8a5a1c", "#c98a26", "#f0b83a", "#fde08a" }
local BUOY = { "#6a2430", "#a3343a", "#d4553f", "#ef8a5a" }

-- back sea
local back = HP.mask()
for x = 3, 60 do
  local top = math.floor(46.5 + 1.0 * math.sin(x * .5) + .5)
  for y = top, 52 do back:set(x, y) end
end
local bkb = {}
back:each(function(x, y) bkb[K(x, y)] = -1 end)
O.shade(c, back, SEA, { R = 2, bias = bkb, amb = .3, wrap = .4 })

-- breakwater: stone blocks
local wall = c:rect(22, 40, 41, 55)
wall:add(c:rect(24, 38, 39, 39))
local wb = {}
wall:each(function(x, y)
  local row = (y - 38) // 4
  local off = (row % 2) * 4
  if (y - 38) % 4 == 3 or (x + off) % 8 == 0 then wb[K(x, y)] = -2 end -- mortar joints
  if (y - 38) % 4 == 0 and (x + off) % 8 ~= 0 then wb[K(x, y)] = 1 end -- lit block tops
end)
local wI, wT = O.shade(c, wall, STN, { R = 3, bias = wb, amb = .25, wrap = .35, rim = true })
O.tex(c, wI, wT, STN, function(x, y, i) if y >= 49 and y <= 51 and H(x, y, 4) > .6 then return -1 end end) -- wet line
O.dots(c, { { 25, 41 }, { 33, 45 }, { 37, 41 } }, "#72b35a") -- weed tufts

-- front sea: lower plane laps the wall foot
local front = HP.mask()
for x = 4, 59 do
  local top = math.floor(52.5 + 1.2 * math.sin(x * .4 + 1) + .5)
  for y = top, 57 do front:set(x, y) end
end
local fb = {}
front:each(function(x, y) if (y == 55 and x % 6 < 3) then fb[K(x, y)] = -1 end end)
local fI, fT = O.shade(c, front, SEA, { R = 2, bias = fb, amb = .3, wrap = .4, rim = true })
for x = 4, 59 do
  local top = math.floor(52.5 + 1.2 * math.sin(x * .4 + 1) + .5)
  if math.sin(x * .4 + 1) > .3 then O.mark(c, { { x, top } }, SEA[6]) end
end

-- splash crown where it left the water (left)
local spl = c:poly{ { 6, 48 }, { 7, 42 }, { 9, 46 }, { 11, 40 }, { 13, 46 }, { 15, 43 }, { 16, 48 } }
O.shade(c, spl, SEA, { R = 1, bias = {}, amb = .55, wrap = .5, cuts = { .2, .38, .55, .71, .86 } })

-- quirk: the buoy in the landing bay (right)
O.shade(c, c:ellipse(54, 49, 3, 3), BUOY, { sphere = { 53, 47, 4 }, amb = .3, cuts = { .3, .55, .78 } })
O.mark(c, { { 51, 49 }, { 52, 49 }, { 53, 49 }, { 54, 49 }, { 55, 49 }, { 56, 49 }, { 57, 49 } }, "#f4e4c0")
O.flat(c, c:rect(54, 42, 54, 45), "#4d4f67", "pole")
O.flat(c, c:rect(55, 42, 57, 43), BUOY[3], "flag")

-- dolphin: thick arc, head lower right
local path = { { 9, 41 }, { 14, 14 }, { 38, 6 }, { 47, 30 } }
local m, n, T, S = O.tube(path, function(t)
  if t < .12 then return 1.6 + t * 10 end
  return math.min(6.5, 2.8 + t * 5)
end)
local db, cb = {}, {}
m:each(function(x, y)
  local s = S[K(x, y)] or 0
  if s > .3 and T[K(x, y)] > .1 then db[K(x, y)] = 9 end -- belly marker
  if s < -.1 then cb[K(x, y)] = -1 end -- darker back (countershading)
end)
local dI, dT = O.shadeN(c, m, n, DOL, { bias = cb, amb = .2, wrap = .35, rim = true })
-- countershaded pale belly (keeps lighting)
O.retone(c, dI, dT, { BELLY[1], BELLY[2], BELLY[2], BELLY[3], BELLY[3], BELLY[4] }, function(x, y, i) return db[K(x, y)] == 9 end)
-- beak (rostrum)
local beak = O.tube({ { 46, 31 }, { 48, 34 }, { 49, 36 }, { 51, 38 } }, function(t) return 2 - t * .8 end)
O.shade(c, beak, BELLY, { R = 1, amb = .35, sep = DOL[2] })
-- flukes
O.shade(c, c:poly{ { 9, 42 }, { 4, 44 }, { 3, 42 }, { 8, 39 } }, DOL, { R = 1, amb = .3, sep = DOL[1] })
O.shade(c, c:poly{ { 9, 42 }, { 12, 47 }, { 10, 48 }, { 7, 42 } }, DOL, { R = 1, amb = .3, sep = DOL[1] })
-- pectoral flipper
O.shade(c, c:poly{ { 36, 19 }, { 33, 25 }, { 35, 25 }, { 39, 20 } }, DOL, { R = 1, amb = .3, sep = DOL[1] })
-- dorsal fin with a gold hook (hook knob)
local fin = c:poly{ { 19, 13 }, { 22, 6 }, { 25, 6 }, { 26, 8 }, { 24, 8 }, { 25, 12 } }
O.shade(c, fin, DOL, { R = 1, amb = .3, sep = DOL[1], rim = true })
O.dots(c, { { 22, 6 }, { 23, 6 }, { 24, 6 }, { 25, 6 }, { 26, 7 }, { 26, 8 }, { 25, 8 } }, GOLD[3])
O.dots(c, { { 23, 6 } }, GOLD[4]) O.dots(c, { { 26, 8 } }, GOLD[2])

-- face on the head
c:eyeLocked(38, 20)
O.dots(c, { { 42, 30 }, { 43, 31 }, { 44, 32 }, { 45, 32 }, { 46, 33 } }, DOL[1]) -- smile line along the beak
O.dots(c, { { 42, 27 }, { 43, 27 } }, "#f5809f")
O.dot(c, 41, 18, DOL[1]) -- blowhole-side brow

O.done(c, "ow-harbour-leap-yard", function(c)
  for _, p in ipairs({ { 50, 10 }, { 8, 30 } }) do c:sparkle(p[1], p[2]) end
  for _, p in ipairs({ { 14, 37 }, { 17, 39 }, { 12, 35 } }) do c:put(p[1], p[2], SEA[6], { r = { name = "drop" } }) end
end)
