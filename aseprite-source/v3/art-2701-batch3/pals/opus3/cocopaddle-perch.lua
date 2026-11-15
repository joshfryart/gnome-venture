-- Cocopaddle (ss-cocopaddle), perch sprite 36x36. Opus richness pass (opus3), hand-built at this size.
-- Swell rebuilt as a back swell wider than the hull plus a front wave with foam caps over the hull's foot;
-- hull gets coir strokes, rim + bounce; bottle gets a red ribbon pixel. Base (opus2) notes:
-- deeper hull so the pill eyes, pore nose and grin all fit under the cream rim; palm-frond sail with
-- three leaflet grooves; paddle in front with the blade in the swell.
-- quirk: the message-in-a-bottle, here 4x2 with a cork.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("cocopaddle-perch", 36)

local HUSK = { "#3a2220", "#5e3628", "#865234", "#a8703f", "#c99254", "#e3b676" }
local MEAT = { "#c9b08e", "#e6d4b2", "#f6ead0", "#fff4d6" }
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local LEAF = { "#1f4a3c", "#2f6b46", "#3f9150", "#62b05a", "#93cc6a", "#c4e07a" }
local SEA  = { "#24406e", "#2f6a9e", "#3a8fb8", "#5fc4c8", "#9ee4dc", "#d4f6ee" }
local GLAS = { "#3f9150", "#7cc35a", "#b6e0a0" }

-- back swell
local back = HP.mask()
for x = 1, 34 do
  local top = math.floor(28 + 1 * math.sin(x * .45 + .5) + .5)
  for y = top, 32 do back:set(x, y) end
end
back:cut(c:rect(1, 32, 1, 32)) back:cut(c:rect(34, 32, 34, 32))
local bkb = {} back:each(function(x, y) bkb[K(x, y)] = -1 end)
O.shade(c, back, SEA, { R = 1, bias = bkb, amb = .35, wrap = .4, rim = true })
for x = 1, 34 do
  local top = math.floor(28 + 1 * math.sin(x * .45 + .5) + .5)
  if math.sin(x * .45 + .5) > .3 then O.mark(c, { { x, top } }, SEA[6]) end
end

-- mast + frond sail
O.shade(c, c:rect(17, 3, 18, 20), WOOD, { R = 1, amb = .3, rim = true })
local sail = c:poly{ { 19, 3 }, { 25, 5 }, { 29, 10 }, { 29, 16 }, { 25, 18 }, { 19, 18 } }
local lb = {}
sail:each(function(x, y) if (y - x * .6) % 4 < 1 and x > 20 then lb[K(x, y)] = -2 end end)
O.shade(c, sail, LEAF, { R = 2, bias = lb, amb = .2, wrap = .35, sep = LEAF[1], rim = true })

-- hull
local hull = c:ellipse(17, 20, 12, 10)
hull:cut(c:rect(0, 0, 35, 19))
local hb = {}
hull:each(function(x, y) if (x * 2 + y) % 5 == 0 and H(x, y, 8) > .4 then hb[K(x, y)] = -1 end end)
O.shade(c, hull, HUSK, { sphere = { 13, 19, 14 }, bias = hb, amb = .2, wrap = .35, bounce = "#5c5a78", bmax = 2 })
local rim = c:ellipse(17, 20, 12, 2)
rim:cut(c:rect(0, 0, 35, 18))
O.shade(c, rim, MEAT, { R = 1, amb = .45, cuts = { .3, .6, .85 } })
O.flat(c, c:ellipse(17, 19.5, 10, 1), HUSK[2], "hollow")
O.shade(c, c:rect(17, 18, 18, 20), WOOD, { R = 1, amb = .3 })

-- paddle + arm
local sh, shn = O.tube({ { 10, 13 }, { 8, 19 }, { 6, 24 }, { 5, 27 } }, function(t) return .7 end)
O.shadeN(c, sh, shn, WOOD, { amb = .35 })
O.shade(c, c:poly{ { 3, 26 }, { 7, 27 }, { 6, 31 }, { 4, 33 }, { 2, 30 } }, WOOD, { R = 1, amb = .3, sep = WOOD[1] })
O.dots(c, { { 10, 21 }, { 9, 20 }, { 9, 19 } }, HUSK[4]) O.dots(c, { { 9, 18 }, { 8, 18 } }, HUSK[5])

-- face
for _, ex in ipairs({ 12, 21 }) do -- pale coconut-flesh eye patches so the pills read on the dark husk
  local e = c:rect(ex - 1, 22, ex + 2, 26)
  e:cut(c:rect(ex - 1, 22, ex - 1, 22)) e:cut(c:rect(ex + 2, 22, ex + 2, 22)) e:cut(c:rect(ex - 1, 26, ex - 1, 26)) e:cut(c:rect(ex + 2, 26, ex + 2, 26))
  O.flat(c, e, MEAT[2], "eyewhite")
  c:eyeSmall(ex, 23)
end
O.dot(c, 9, 27, "#f5809f") O.dot(c, 25, 27, "#f5809f")
O.dots(c, { { 16, 25 }, { 17, 25 } }, HUSK[1]) O.dot(c, 16, 25, MEAT[2])
O.dots(c, { { 14, 26 }, { 15, 27 }, { 16, 27 }, { 17, 27 }, { 18, 27 }, { 19, 26 } }, P.ink)

-- front wave over the hull's foot
local front = HP.mask()
for x = 2, 33 do
  local top = math.floor(31.5 + .7 * math.sin(x * .55 + 2) + .5)
  for y = top, 33 do front:set(x, y) end
end
front:cut(c:rect(2, 33, 2, 33)) front:cut(c:rect(33, 33, 33, 33))
O.shade(c, front, SEA, { R = 1, amb = .4, wrap = .45, rim = true })
for x = 2, 33 do
  local top = math.floor(31.5 + .7 * math.sin(x * .55 + 2) + .5)
  if math.sin(x * .55 + 2) > -.2 then O.mark(c, { { x, top } }, SEA[6]) end
end

-- quirk: bottle
O.flat(c, c:rect(27, 27, 30, 28), GLAS[2], "bottle")
O.dots(c, { { 27, 27 } }, GLAS[3]) O.dot(c, 28, 27, MEAT[3]) O.dot(c, 29, 27, "#e8493b") O.dot(c, 30, 28, GLAS[1])
O.flat(c, c:rect(31, 27, 31, 28), WOOD[2], "cork")

O.done(c, "cocopaddle-perch")
