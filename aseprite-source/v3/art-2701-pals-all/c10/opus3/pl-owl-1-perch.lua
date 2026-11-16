-- Pinfeather Hush (pl-owl-1), perch sprite 36x36. Opus richness pass (c10/opus3), built on c10/opus2, hand-built at this size.
-- Richness pass: crisp dark bars bending toward the tip, one V split on each edge, a dark shaft streak, pale buff
-- tip, fringe teeth on the right edge, rim light + bounce on the down puff, and a sheath flake on the quill.
-- Plump tawny feather on a curved shaft, leaning right, two bold bars and a pale shaft above the face, grey down
-- puff at the base, quill in the ground. Pill eyes on the widest part.
-- quirk: a grey down wisp held up across its pursed lips (the hush), with hush ticks on the left.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local BNC = "#7a6a8e"
local c = O.canvas("pl-owl-1-perch", 36)

local FEA  = { "#2f1b24", "#55302a", "#83502f", "#b07940", "#d6a35e", "#f0cf8e" }
local DOWN = { "#5e5468", "#857c8c", "#ada4ae", "#d0c8c8", "#ebe4dc" }
local QUIL = { "#8a7a68", "#b8a88e", "#dcd0b4", "#f2ead2" }

c:groundShadow(18, 32, 5, 1)
O.shade(c, c:rect(17, 27, 18, 32), QUIL, { R = 1, amb = .3, cuts = { .3, .55, .8 } })

local SH = { { 17, 28 }, { 17, 21 }, { 19, 11 }, { 24, 3 } }
local vane, vn, VT, VS = O.tube(SH, function(t) return 6.5 * math.sin(math.pi * (.12 + .88 * t)) ^ .6 end)
vane:cut(c:rect(0, 28, 35, 35))
local function bt(x, y) return (VT[K(x, y)] or 0) - .1 * math.abs(VS[K(x, y)] or 0) end
-- one V split on each edge, and barb-tip teeth on the right edge
local cut = HP.mask()
vane:each(function(x, y)
  local s = VS[K(x, y)] or 0
  if s > .45 and math.abs(bt(x, y) - .7) < .025 then cut:set(x, y) end
  if s < -.5 and math.abs(bt(x, y) - .24) < .03 then cut:set(x, y) end
end)
vane:edge():each(function(x, y) if (VS[K(x, y)] or 0) > .6 and math.floor(bt(x, y) * 40) % 3 == 0 and (VT[K(x, y)] or 0) > .62 then cut:set(x, y) end end)
vane:cut(cut)
local vb = {}
vane:each(function(x, y)
  local b, t = bt(x, y), VT[K(x, y)] or 0
  if (b > .6 and b < .67) or (b > .79 and b < .85) or (b < .17 and b > .09) then vb[K(x, y)] = -3 end
  if b > .93 then vb[K(x, y)] = 1 end
end)
local fI, fT = O.shade(c, vane, FEA, { R = 3, bias = vb, amb = .3, wrap = .45, rim = true, bounce = BNC, bmax = 2 })
O.tex(c, fI, fT, FEA, function(x, y, i)
  local t, s = VT[K(x, y)] or 0, math.abs(VS[K(x, y)] or 0)
  if s < .25 and (t < .3 or t > .6) and i >= 3 and t < .9 then return -1 end -- shaft streak
end)
vane:each(function(x, y)
  local t, sd = VT[K(x, y)] or 0, math.abs(VS[K(x, y)] or 0)
  if sd < .16 and t > .62 and t < .95 then O.mark(c, { { x, y } }, QUIL[4]) end
end)

local puff = O.unionCircles{ { 14.5, 27, 2, 1.5 }, { 18, 28, 2, 1.5 }, { 21, 27, 2, 1.5 } }
O.shade(c, puff, DOWN, { R = 1, amb = .35, wrap = .5, cuts = { .3, .5, .7, .88 }, sep = FEA[1], rim = true, bounce = BNC, bmax = 2 })
O.dots(c, { { 17, 30 }, { 17, 31 } }, "#9aaabc")

c:eyeSmall(14, 14)
c:eyeSmall(20, 14)
O.dot(c, 12, 18, "#f5809f") O.dot(c, 23, 18, "#f5809f")
O.dots(c, { { 16, 19 }, { 19, 19 } }, P.ink)
-- the hush wisp
local fin, fn = O.tube({ { 21, 26 }, { 21, 23 }, { 18, 23 }, { 18, 17 } }, function(t) return 1 end)
O.shadeN(c, fin, fn, DOWN, { amb = .45, wrap = .5, cuts = { .3, .5, .7, .88 }, sep = DOWN[1] })
O.dot(c, 18, 17, DOWN[5])

O.done(c, "pl-owl-1-perch", function(c)
  for _, p in ipairs({ { 7, 16 }, { 6, 15 }, { 6, 19 }, { 5, 19 }, { 7, 22 }, { 6, 23 } }) do c:put(p[1], p[2], P.ink) end
end)
