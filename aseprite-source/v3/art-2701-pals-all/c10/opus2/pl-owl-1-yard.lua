-- Pinfeather Hush (pl-owl-1), yard sprite 64x64. Opus second pass (c10/opus2), built on c10/haiku.
-- Seedkeeper, common. "A soft brown feather that hushes anything trying to hoot."
-- A short, plump tawny owl body feather standing upright on its quill: chevron barring in dark brown, angled
-- barbs, a pale shaft, two little splits in the vane, and a puff of grey down (the afterfeather) at the base.
-- The face sits on the widest part, either side of the shaft.
-- Haiku pass fixed: the feather was a plain brown blob (ghost shape) with no barbs, shaft or barring.
-- quirk: the hush. A wisp of its grey down curls up from the base and rests across its pursed lips like a finger.
-- closer look: three hush ticks puffing off the left of its lips.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local BNC = "#7a6a8e"
local c = O.canvas("pl-owl-1-yard", 64)

local FEA  = { "#3e2422", "#64392a", "#8c5634", "#b47a46", "#d4a064", "#ecc890" }
local DOWN = { "#5e5468", "#857c8c", "#ada4ae", "#d0c8c8", "#ebe4dc" }
local QUIL = { "#8a7a68", "#b8a88e", "#dcd0b4", "#f2ead2" }

c:groundShadow(31, 58, 9, 2)
-- quill (calamus) standing in the ground
local quill = c:rect(30, 47, 32, 57)
quill:cut(c:rect(32, 56, 32, 57))
O.shade(c, quill, QUIL, { R = 1, amb = .3, wrap = .4, cuts = { .3, .55, .8 } })
O.dots(c, { { 30, 49 }, { 30, 50 }, { 30, 51 } }, QUIL[4])

-- vane: a plump feather along a gently curved shaft, tip leaning right, widest at the face
local SH = { { 31, 48 }, { 31, 36 }, { 34, 19 }, { 42, 5 } }
local vane, vn, VT, VS = O.tube(SH, function(t) return 10.5 * math.sin(math.pi * (.12 + .88 * t)) ^ .6 end)
vane:cut(c:rect(0, 47, 63, 63))
-- splits in the vane edge, cut along the barbs
local notch = HP.mask()
vane:each(function(x, y)
  local t, sd = VT[K(x, y)] or 0, VS[K(x, y)] or 0
  for _, q in ipairs({ { .22, -1 }, { .72, -1 }, { .76, 1 } }) do
    if sd * q[2] > .7 and math.abs(t - q[1] - (math.abs(sd) - .45) * .07) < .013 then notch:set(x, y) end
  end
end)
vane:cut(notch)
local inFace = function(t) return t > .33 and t < .6 end
local vb = {}
vane:each(function(x, y)
  local t, sd = VT[K(x, y)] or 0, math.abs(VS[K(x, y)] or 0)
  if not inFace(t) and (t * 30 - sd * 3) % 6 >= 4 then vb[K(x, y)] = -2 end -- chevron barring, V to the tip
end)
local fI, fT = O.shade(c, vane, FEA, { R = 5, bias = vb, amb = .3, wrap = .45, rim = true, bounce = BNC, bmax = 2 })
-- barbs: fine angled lines running up and away from the shaft; kept off the face
O.tex(c, fI, fT, FEA, function(x, y, i)
  local t, sd = VT[K(x, y)] or 0, math.abs(VS[K(x, y)] or 0)
  if inFace(t) then return 0 end
  if sd > .2 and math.floor(t * 70 - sd * 9) % 4 == 0 and i >= 4 then return -1 end
  if sd > .85 and i <= 5 and H(x, y, 7) > .55 then return 1 end -- soft pale fringe on the edge
end)
-- shaft: pale line, hidden behind the face
vane:each(function(x, y)
  local t, sd = VT[K(x, y)] or 0, math.abs(VS[K(x, y)] or 0)
  if sd * 11 < .55 and not (t > .3 and t < .62) and t < .95 then O.mark(c, { { x, y } }, t > .5 and QUIL[4] or QUIL[3]) end
end)

-- afterfeather: a puff of grey down at the base
local puff = O.unionCircles{ { 26, 46, 3, 2.5 }, { 30, 47, 3, 2.5 }, { 35, 46, 3, 2.5 }, { 24, 43.5, 2, 1.5 }, { 37.5, 43.5, 2, 1.5 } }
local pI, pT = O.shade(c, puff, DOWN, { R = 2, amb = .35, wrap = .5, cuts = { .3, .5, .7, .88 }, sep = FEA[1] })
O.tex(c, pI, pT, DOWN, function(x, y, i) if (x + y) % 3 == 0 and i >= 3 then return -1 end end)
O.dots(c, { { 22, 46 }, { 21, 47 }, { 39, 47 }, { 40, 48 } }, DOWN[3]) -- wisps

-- face: soft lit patch for the eyes, either side of the shaft
c:eyeLocked(25, 25)
c:eyeLocked(36, 25)
c:cheek(24, 32) c:cheek(41, 32)
-- pursed lips
O.dots(c, { { 30, 34 }, { 31, 35 }, { 35, 34 }, { 34, 35 } }, P.ink)
O.dot(c, 31, 34, FEA[2]) O.dot(c, 34, 34, FEA[2])

-- quirk: the hush finger, a barb strand curling in from the right edge and up across the lips
-- (a grey down wisp rising from the afterfeather puff, so it reads apart from the brown vane)
local fin, fn = O.tube({ { 39, 44 }, { 38, 40 }, { 33, 41 }, { 33, 32 } }, function(t) return 1.5 end)
O.shadeN(c, fin, fn, DOWN, { amb = .45, wrap = .5, cuts = { .3, .5, .7, .88 }, sep = DOWN[1] })
O.dots(c, { { 32, 32 }, { 33, 32 } }, DOWN[5]) -- the lit fingertip

O.shift(c, 1, 0)
O.done(c, "pl-owl-1-yard", function(c)
  -- hush ticks off to the left of the lips
  for _, p in ipairs({ { 15, 30 }, { 14, 29 }, { 14, 34 }, { 13, 34 }, { 12, 34 }, { 15, 38 }, { 14, 39 } }) do c:put(p[1], p[2], P.ink) end
end)
