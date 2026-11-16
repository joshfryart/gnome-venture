-- Ledge Feather (pl-cnd-2), yard sprite 64x64. Opus second pass (c09/opus2), built on the c09/haiku concept.
-- Wayfinder, common, Condor's Crag. "Drifts off every ledge and always finds its way back."
-- A soft condor body feather in the crag's dusky violet, curved like it is gliding: pale rachis, barbs combed
-- toward the tip, a fluffy cream afterfeather at the quill, and a little stub of sandy crag ledge under its tip
-- (the ledge it keeps drifting off). Floating, so no shadow of its own.
-- quirk: a dotted flight path loops out from the ledge, round underneath, and back up to the feather's quill:
-- the way back it always finds.
-- closer look: the tip of the feather is ragged, two barbs split apart from all the drifting.
-- Fixes over haiku: brown wedge with no feather structure (now a curved vane with rachis and barbs in condor
-- violet), sparkle-dots trail that read as dirt (now a clear looping path from the ledge and back).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cnd-2-yard", 64)

local FEA = { "#231c38", "#35295f", "#4f4280", "#6f63a0", "#9a90c4", "#c9c2e6" }
local CREAM = { "#a88a78", "#d8bfa0", "#f0e0c4", "#fbf2e0" }
local ROCK = { "#2e2440", "#463656", "#634c72", "#82688e", "#a48aa8", "#c4aec0" }
local SAND = { "#c9a479", "#e6c995", "#f5e3b8" }

c:groundShadow(46, 56, 12, 1.5)

-- ledge stub
local ledge = c:poly({ { 34, 45 }, { 40, 44 }, { 49, 44 }, { 56, 43 }, { 57, 48 }, { 55, 52 }, { 56, 56 }, { 39, 56 }, { 37, 51 }, { 35, 50 } })
local lI, lT = O.shade(c, ledge, ROCK, { R = 3, amb = .3, wrap = .45, rim = true, bounce = "#7a6aa0", bmax = 2 })
O.tex(c, lI, lT, ROCK, function(x, y, i)
  if (y == 49 and x > 38) or (y == 53 and x > 40 and x < 50) then return -2 end -- strata
  if (y == 50 and x > 38) or (y == 54 and x > 40 and x < 50) then return 1 end
  if (x == 46 and y > 49 and y < 53) then return -2 end
  if H(x, y, 6) > .88 then return -1 end
end)
-- sandy top on the ledge
ledge:each(function(x, y) if not ledge:has(x, y - 2) then c.pix[y * c.w + x] = (ledge:has(x, y - 1) and SAND[1] or (x < 47 and SAND[3] or SAND[2])) end end)
O.dots(c, { { 42, 50 }, { 43, 51 }, { 43, 52 }, { 52, 46 }, { 53, 47 }, { 53, 48 } }, "#d9a040") -- gold vein like the crag's

-- feather: curved gliding vane
local A = { { 9, 42 }, { 20, 30 }, { 36, 20 }, { 56, 18 } }
local vane, vn, VT, VS = O.tube(A, function(t)
  if t < .14 then return 0 end
  local u = (t - .14) / .86
  return 7.5 * math.sin(math.min(1, u / .22) * math.pi / 2) * (u < .4 and 1 or (1 - (u - .4) / .6) ^ .9) + .3
end)
-- ragged tip: two splits
vane:each(function(x, y) local t, s = VT[K(x, y)], VS[K(x, y)]
  if t and ((t > .84 and t < .86 and s > .3) or (t > .9 and t < .92 and s < -.3)) then vane.s[K(x, y)] = nil end end)
local vI, vTk = O.shadeN(c, vane, vn, FEA, { amb = .3, wrap = .5, rim = true, bounce = "#4f7aa0", bmax = 2, sep = FEA[1] })
local function face(x, y) return x >= 20 and x <= 33 and y >= 25 and y <= 34 end
O.tex(c, vI, vTk, FEA, function(x, y, i)
  local t, s = VT[K(x, y)], VS[K(x, y)]
  if not t or face(x, y) then return 0 end
  if math.abs(s) < .12 then return 3 end                              -- pale rachis
  if s > .12 and s < .3 then return -1 end
  local ph = t * 55 - math.abs(s) * 3
  if math.abs(s) > .3 and math.floor(ph) % 3 == 0 then return -1 end -- barbs
end)
-- quill and afterfeather fluff
local q, qn = O.tube({ { 6, 46 }, { 7, 45 }, { 9, 43 }, { 11, 40 } }, function(t) return 1 end)
O.shadeN(c, q, qn, CREAM, { amb = .4, wrap = .5, cuts = { .3, .55, .8 }, sep = CREAM[1] })
local fluff = O.unionCircles({ { 12, 38, 2.5 }, { 10, 41, 2 }, { 14, 41, 2 }, { 9, 37, 1.5 } })
local fI, fT = O.shade(c, fluff, CREAM, { sphere = { 10, 37, 5 }, amb = .4, wrap = .5, cuts = { .3, .55, .8 }, sep = CREAM[1] })
O.dots(c, { { 8, 35 }, { 15, 43 } }, CREAM[2]) -- stray wisps

-- face on the vane
c:eyeLocked(21, 26)
c:eyeLocked(28, 25)
c:cheek(20, 32) c:cheek(32, 31)
O.dots(c, { { 25, 32 }, { 26, 33 }, { 27, 33 }, { 28, 32 } }, P.ink)

O.done(c, "pl-cnd-2-yard", function(c)
  -- the dotted way back: from the ledge, round underneath, up to the quill; an arrow tip at the end
  local path = { { 33, 47 }, { 24, 59 }, { 6, 57 }, { 6, 50 } }
  local last
  for i = 0, 40 do
    local x, y = O.bez(path, i / 40)
    x, y = math.floor(x + .5), math.floor(y + .5)
    if (i % 3 == 0) and not c:get(x, y) then c:put(x, y, "#f0e0c4") last = { x, y } end
  end
  for _, p in ipairs({ { 5, 49 }, { 7, 49 } }) do if not c:get(p[1], p[2]) then c:put(p[1], p[2], "#f0e0c4") end end
end)
