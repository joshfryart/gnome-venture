-- Ledge Feather (pl-cnd-2), perch sprite 36x36. Opus richness pass (c09/opus3), hand-built at this size.
-- opus3: the ledge was only a few px tall; now a proper cliff block (11 px) with a sand top, two strata, a crack
-- and a gold vein. Lit barb edges and a teal sheen glint on the feather; fluff snag on the ledge.
-- Dusky violet condor feather gliding (pale rachis, barbs, cream fluff at the quill) over a stub of crag ledge.
-- quirk: a dotted flight path loops from the ledge, round underneath, back up to the quill.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cnd-2-perch", 36)
local FEA = { "#231c38", "#35295f", "#4f4280", "#6f63a0", "#9a90c4", "#c9c2e6" }
local CREAM = { "#a88a78", "#d8bfa0", "#f0e0c4", "#fbf2e0" }
local ROCK = { "#2e2440", "#463656", "#634c72", "#82688e", "#a48aa8", "#c4aec0" }
local SAND = { "#c9a479", "#e6c995", "#f5e3b8" }
c:groundShadow(26, 33, 9, 1.2)
local ledge = c:poly({ { 18, 24 }, { 22, 22 }, { 26, 23 }, { 30, 21 }, { 34, 23 }, { 33, 27 }, { 35, 30 }, { 33, 33 }, { 21, 33 }, { 20, 29 }, { 18, 27 } })
local lI, lT = O.shade(c, ledge, ROCK, { R = 2, amb = .3, wrap = .45, rim = true, bounce = "#7a6aa0", bmax = 2 })
O.tex(c, lI, lT, ROCK, function(x, y, i)
  local wob = (x // 4) % 2
  if (y == 26 + wob and x > 20 and x ~= 27) or (y == 30 and x > 21 and x < 31) then return -2 end
  if (y == 27 + wob and x > 20 and x ~= 27) or (y == 31 and x > 21 and x < 31) then return 1 end
end)
ledge:each(function(x, y) if not ledge:has(x, y - 1) then c.pix[y * c.w + x] = (x < 27 and SAND[3] or SAND[2]) end
  if ledge:has(x, y - 1) and not ledge:has(x, y - 2) then c.pix[y * c.w + x] = SAND[1] end end)
O.dots(c, { { 25, 28 }, { 26, 29 }, { 26, 30 } }, "#d9a040")
O.dots(c, { { 31, 28 }, { 31, 29 }, { 32, 30 } }, ROCK[1])
O.dots(c, { { 24, 23 }, { 25, 23 } }, CREAM[4])
local vane, vn, VT, VS = O.tube({ { 6, 21 }, { 11, 14 }, { 20, 9 }, { 32, 9 } }, function(t)
  if t < .12 then return 0 end local u = (t - .12) / .88
  return 4.5 * math.sin(math.min(1, u / .22) * math.pi / 2) * (u < .4 and 1 or (1 - (u - .4) / .6) ^ .9) + .3 end)
local I, T = O.shadeN(c, vane, vn, FEA, { amb = .3, wrap = .5, rim = true, bounce = "#4f7aa0", bmax = 2, sep = FEA[1] })
local function face(x, y) return x >= 9 and x <= 19 and y >= 12 and y <= 18 end
O.tex(c, I, T, FEA, function(x, y, i)
  local t, s = VT[K(x, y)], VS[K(x, y)]
  if not t or face(x, y) then return 0 end
  if math.abs(s) < .15 then return 3 end
  if math.abs(s) > .3 and math.floor(t * 34 - math.abs(s) * 2) % 3 == 0 then return -1 end
  if s < -.3 and math.floor(t * 34 - math.abs(s) * 2) % 3 == 1 and i >= 3 and i <= 4 then return 1 end
end)
O.tex(c, I, T, { "#2f4a78", "#3f6a96" }, function(x, y, i)
  local t, s = VT[K(x, y)], VS[K(x, y)]
  if t and t > .45 and t < .8 and s > .3 and i <= 2 and H(x, y, 14) > .75 then return 0 end
end)
local fl = O.unionCircles({ { 7, 21, 1.5 }, { 6, 23, 1.2 } })
O.shade(c, fl, CREAM, { sphere = { 6, 20, 3 }, amb = .4, wrap = .5, cuts = { .3, .55, .8 }, sep = CREAM[1] })
c:eyeSmall(11, 13) c:eyeSmall(16, 12)
O.dot(c, 10, 17, P.petal.base) O.dot(c, 19, 16, P.petal.base)
O.dots(c, { { 13, 17 }, { 14, 18 }, { 15, 17 } }, P.ink)
O.done(c, "pl-cnd-2-perch", function(c)
  local path = { { 18, 28 }, { 12, 35 }, { 2, 32 }, { 4, 26 } }
  for i = 0, 24 do local x, y = O.bez(path, i / 24) x, y = math.floor(x + .5), math.floor(y + .5)
    if i % 3 == 0 and not c:get(x, y) then c:put(x, y, CREAM[3]) end end
end)
