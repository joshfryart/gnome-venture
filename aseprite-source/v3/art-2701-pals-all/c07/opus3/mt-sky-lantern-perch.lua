-- Sky Lantern (mt-sky-lantern), perch sprite 36x36, hand-built at this size (opus3 richness pass, from opus2).
-- opus3: washi fibre flecks and a glued seam, cool dusk rim, hoop nodes, a paper patch on the dome, a wish slip on
-- the hoop, cloud rim light and a darker belly.
-- Rice-paper sky lantern glowing from inside (bright centre, ember edges), two ribs at the sides, bamboo hoop,
-- a hanging flame. Pill eyes in warm rings, open "hurry" mouth.
-- quirk: a small grey rain cloud being shooed off to the right.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mt-sky-lantern-perch", 36)

local PAP = { "#7a2238", "#b52e3f", "#e0563a", "#f08a3e", "#fbb85a", "#ffe08e" }
local BAM = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local CLD = { "#5c5d78", "#7c7d96", "#a2a3b8", "#c8c8d8" }

O.dots(c, { { 11, 28 }, { 12, 29 }, { 13, 30 }, { 19, 28 }, { 18, 29 }, { 17, 30 } }, "#6a4a40")
O.flat(c, c:poly{ { 15, 29 }, { 16, 31 }, { 16, 33 }, { 14, 33 }, { 14, 31 } }, "#f08a3e", "flame")
O.dots(c, { { 15, 31 }, { 15, 32 } }, "#ffd45e")
local body = c:ellipse(15, 10, 9, 7) body:add(c:poly{ { 6, 10 }, { 24, 10 }, { 21, 27 }, { 9, 27 } }) body:add(c:ellipse(15, 17, 8.5, 7))
local v = {}
body:each(function(x, y)
  local dx, dy = (x - 15) / 11, (y - 17) / 15
  v[K(x, y)] = math.min(1, .16 + math.max(0, 1 - math.sqrt(dx * dx * 1.1 + dy * dy)) + math.max(0, -(dx + dy)) * .08)
end)
local rb = {}
body:each(function(x, y) if (x == 9 or x == 21) and (y < 13 or y > 22) then rb[K(x, y)] = -1 end end)
local tok = { r = { name = "paper" } }
local bI = X.tone(c, body, v, PAP, { cuts = O.CUTS, bias = rb, tok = tok })
O.tex(c, bI, tok, PAP, function(x, y, i)
  if x > 9 and x < 21 and y > 11 and y < 22 then return end
  if O.H(x, y, 11) > .9 and i >= 3 then return -1 end
  if y == 8 and i >= 2 then return -1 end
end)
body:each(function(x, y) if (not body:has(x - 1, y) or not body:has(x, y - 1)) and (x - 15) + (y - 17) < -12 then c:put(x, y, "#e0789a", tok) end end)
O.flat(c, c:rect(17, 4, 19, 6), PAP[5], "patch") O.dot(c, 17, 4, PAP[6]) O.dot(c, 19, 6, PAP[4])
O.flat(c, c:rect(14, 2, 16, 3), BAM[3], "knot")
local hoop = c:ellipse(15, 27, 6.5, 1.2)
O.shade(c, hoop, BAM, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = BAM[1], rim = true })
O.dots(c, { { 12, 28 }, { 18, 28 } }, BAM[1])
O.dot(c, 21, 29, "#6a4a40") O.flat(c, c:rect(21, 30, 22, 32), "#fff0d0", "slip") O.dot(c, 21, 31, "#7a2238") -- wish slip
for _, ex in ipairs({ 11, 18 }) do
  c:ellipse(ex + .5, 15, 2, 2.5):each(function(x, y) c:put(x, y, PAP[3], tok) end)
  c:eyeSmall(ex, 14)
end
O.dots(c, { { 14, 19 }, { 15, 19 }, { 16, 19 }, { 14, 20 }, { 16, 20 } }, "#3e1620") O.dot(c, 15, 20, "#e8493b")
local cl = c:ellipse(29.5, 18, 4, 2.5) cl:add(c:ellipse(28, 16, 2.5, 2)) cl:add(c:ellipse(31, 15.5, 2.5, 2.5))
cl:cut(c:rect(0, 20, 35, 35))
O.shade(c, cl, CLD, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = CLD[1], rim = true })
O.dots(c, { { 27, 19 }, { 28, 19 }, { 29, 19 }, { 30, 19 }, { 31, 19 }, { 32, 19 } }, CLD[1])
O.dot(c, 28, 22, "#5f9ad0") O.dot(c, 31, 22, "#5f9ad0")
O.shift(c, -2, 0)
O.done(c, "mt-sky-lantern-perch", function(c)
  for _, p in ipairs({ { 22, 16 }, { 21, 16 }, { 22, 19 } }) do if not c:get(p[1], p[2]) then c:put(p[1], p[2], "#fff4d6", { r = { name = "speed" } }) end end
end)
