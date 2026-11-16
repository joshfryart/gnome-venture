-- Harbour Leap (ow-harbour-leap), yard sprite 64x64. Opus richness pass (art-2701-pals-all/c02/opus3), built on opus2.
-- Wayfinder, RARE, Olivewhistle. "Leaps the breakwater and lands in the same bay every time."
-- A chunky sea-blue dolphin mid-leap in a high arc over a stone breakwater, sea on both sides. Countershaded
-- (pale belly), a big rounded melon head with the locked eye and a smile running along the beak, flippers and
-- flukes. Rare touch: the dorsal fin curls into a gold hook (hook knob), gold fin edge, sparkles in the air.
-- Fix vs Haiku: the head end was thin with a tiny eye, so the face was weak; now the body thickens towards a
-- big head that holds a full 5x5 eye; the splash is a real water crown with drops, not dots; the breakwater is
-- built from lit stone blocks.
-- Fix (opus3): the splash crown was a soft teal blob. Now a real crown: a hollow dark well with a lit lip, five
-- separate spikes either side of the flukes with foam-cream tips, and three outlined 2x2 drops flung up after the
-- tail (no lone pixels).
-- Richness (opus3): wet sheen streaks running along the lit back, a darker saddle, the fin's trailing-edge nick,
-- breakwater speckle, barnacles and a dark wet band, lit wave lines on both sea planes, buoy with a lit dome.
-- closer look: a little crab on top of the breakwater, claws up, watching it go over.
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
back:each(function(x, y) bkb[K(x, y)] = -1 if y == 49 and (x + 3) % 7 < 2 then bkb[K(x, y)] = 0 end end)
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
local wI, wT = O.shade(c, wall, STN, { R = 3, bias = wb, amb = .25, wrap = .35, rim = true, bounce = "#4a7a8a", bmax = 2 })
O.tex(c, wI, wT, STN, function(x, y, i) if H(x, y, 8) > .9 and i >= 2 then return (H(x, y, 9) > .5) and 1 or -1 end end) -- speckle
O.tex(c, wI, wT, STN, function(x, y, i) if y >= 49 and y <= 51 and H(x, y, 4) > .6 then return -1 end end) -- wet line
O.dots(c, { { 25, 41 }, { 33, 45 }, { 37, 41 } }, "#72b35a") -- weed tufts
O.dots(c, { { 24, 50 }, { 29, 51 }, { 38, 50 } }, "#d2cfc0") O.dots(c, { { 25, 50 }, { 30, 51 } }, "#8d8fa5") -- barnacles
-- closer look: a crab on top of the breakwater (claws up, eye stalks)
O.dots(c, { { 32, 36 }, { 33, 36 }, { 34, 36 }, { 35, 36 }, { 36, 36 }, { 33, 37 }, { 34, 37 }, { 35, 37 } }, "#d4553f")
O.dots(c, { { 32, 36 }, { 33, 36 } }, "#ef8a5a") O.dots(c, { { 35, 37 }, { 36, 36 } }, "#a3343a")
O.dots(c, { { 30, 33 }, { 31, 33 }, { 30, 34 }, { 31, 35 } }, "#d4553f") O.dot(c, 30, 33, "#ef8a5a") -- left claw
O.dots(c, { { 37, 33 }, { 38, 33 }, { 38, 34 }, { 37, 35 } }, "#d4553f") -- right claw
O.dots(c, { { 33, 35 }, { 35, 35 } }, P.ink) -- eyes

-- front sea: lower plane laps the wall foot
local front = HP.mask()
for x = 4, 59 do
  local top = math.floor(52.5 + 1.2 * math.sin(x * .4 + 1) + .5)
  for y = top, 57 do front:set(x, y) end
end
local fb = {}
front:each(function(x, y)
  if (y == 55 and x % 6 < 3) then fb[K(x, y)] = -1 end
  if (y == 54 and x % 6 >= 3 and x % 6 < 5) then fb[K(x, y)] = 1 end
  if y >= 57 then fb[K(x, y)] = -1 end
end)
local fI, fT = O.shade(c, front, SEA, { R = 2, bias = fb, amb = .3, wrap = .4, rim = true })
for x = 4, 59 do
  local top = math.floor(52.5 + 1.2 * math.sin(x * .4 + 1) + .5)
  if math.sin(x * .4 + 1) > .3 then O.mark(c, { { x, top } }, SEA[6]) end
end

-- splash crown where it left the water (left)
local FOAM = "#e4f2e6"
local spl = c:poly{ { 1, 49 }, { 2, 44 }, { 9, 43 }, { 16, 44 }, { 19, 49 } }
for _, sp in ipairs({ { 2, 39, 1 }, { 5, 35, 1.2 }, { 14, 35, 1.2 }, { 18, 39, 1 } }) do
  spl:add(c:poly{ { sp[1] - sp[3] - 1, 45 }, { sp[1], sp[2] }, { sp[1] + sp[3] + 1, 45 } })
end
local spb = {}
spl:each(function(x, y) spb[K(x, y)] = (y <= 41) and 1 or 0 end)
local pI, pT = O.shade(c, spl, SEA, { R = 1, bias = spb, amb = .4, wrap = .4, rim = true, sep = SEA[1] })
-- foam tips on each spike
for _, t in ipairs({ { 2, 39 }, { 5, 35 }, { 14, 35 }, { 18, 39 } }) do
  for d = 0, 2 do for dx = -1, 0 do if spl:has(t[1] + dx, t[2] + d) then O.mark(c, { { t[1] + dx, t[2] + d } }, d == 0 and FOAM or (dx == -1 and FOAM or SEA[6])) end end end
end
-- the hollow well and its lit lip
for x = 4, 16 do O.mark(c, { { x, 47 }, { x, 48 } }, SEA[2]) O.mark(c, { { x, 46 } }, SEA[5]) end

-- quirk: the buoy in the landing bay (right)
O.shade(c, c:ellipse(54, 49, 3, 3), BUOY, { sphere = { 53, 47, 4 }, amb = .3, cuts = { .3, .55, .78 }, rim = true })
O.dot(c, 53, 47, "#f8bf8a")
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
local dI, dT = O.shadeN(c, m, n, DOL, { bias = cb, amb = .2, wrap = .35, rim = true, bounce = "#4a8a9a", bmax = 2 })
-- wet sheen streaks along the lit back (follow the arc), off the face
O.tex(c, dI, dT, DOL, function(x, y, i)
  local t, s = T[K(x, y)] or 0, S[K(x, y)] or 0
  if x >= 35 and y >= 17 then return end
  if s < -.2 and s > -.75 and i >= 3 and i <= 5 and math.floor(t * 46) % 5 == 0 then return 1 end
  if s < -.8 and i >= 2 and t > .2 and t < .8 then return -1 end -- darker saddle on the far edge
end)
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
O.dot(c, 24, 10, DOL[1]) -- the nick in the fin's trailing edge

-- face on the head
c:eyeLocked(38, 20)
O.dots(c, { { 42, 30 }, { 43, 31 }, { 44, 32 }, { 45, 32 }, { 46, 33 } }, DOL[1]) -- smile line along the beak
O.dots(c, { { 42, 27 }, { 43, 27 } }, "#f5809f")
O.dot(c, 41, 18, DOL[1]) -- blowhole-side brow

-- drops flung up after the tail: outlined 2x2, lit top-left
for _, p in ipairs({ { 2, 34 }, { 17, 33 }, { 11, 31 } }) do
  O.dots(c, { { p[1], p[2] }, { p[1] + 1, p[2] }, { p[1], p[2] + 1 }, { p[1] + 1, p[2] + 1 } }, SEA[5])
  O.dot(c, p[1], p[2], FOAM) O.dot(c, p[1] + 1, p[2] + 1, SEA[4])
end
O.done(c, "ow-harbour-leap-yard", function(c)
  for _, p in ipairs({ { 50, 10 }, { 8, 30 } }) do c:sparkle(p[1], p[2]) end
end)
