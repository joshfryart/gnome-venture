-- Pinfeather Hush (pl-owl-1), yard sprite 64x64. Opus richness pass (c10/opus3), built on c10/opus2.
-- Seedkeeper, common. "A soft brown feather that hushes anything trying to hoot."
-- A tawny owl body feather standing on its quill, tip curling right. Richness pass: the vane is now asymmetric
-- (narrow left vane, broad right vane, like a real feather), with a saw-tooth barb fringe along both edges,
-- four V splits cut along the barbs, crisp dark chevron bars that bend toward the tip, a dark shaft streak, a pale
-- buff tip, fine barb lines, and a pale ivory shaft running the full length above and below the face.
-- 6-tone plum-brown to straw ramp, light upper-left, rim light on the left edge, cool violet bounce lower-right.
-- opus2 weakness fixed: at 25% the plump soft oval read as a bread loaf or pinecone. Now it is slimmer, pointed,
-- split and fringed, so the silhouette says "feather" before the colour does.
-- quirk: the hush. A grey down wisp curls up from the afterfeather puff and rests across its pursed lips.
-- closer look: a flake of waxy blue-grey pinfeather sheath still stuck on the quill (it is a pinfeather), and
-- hush ticks puffing off the left of its lips.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local BNC = "#7a6a9a"
local c = O.canvas("pl-owl-1-yard", 64)

local FEA  = { "#2f1b24", "#55302a", "#83502f", "#b07940", "#d6a35e", "#f0cf8e" }
local DOWN = { "#5a5070", "#837a92", "#aba2b4", "#cfc8cc", "#ebe4dc" }
local QUIL = { "#86766a", "#b6a690", "#dccfb4", "#f4ecd4" }
local SHTH = { "#6a7890", "#9aaabc", "#c8d4dc" }

c:groundShadow(31, 58, 9, 2)
-- quill (calamus) standing in the ground
local quill = c:rect(30, 46, 32, 57)
quill:cut(c:rect(32, 55, 32, 57))
O.shade(c, quill, QUIL, { R = 1, amb = .3, wrap = .4, cuts = { .3, .55, .8 } })
O.dots(c, { { 30, 49 }, { 30, 50 }, { 30, 51 }, { 30, 52 } }, QUIL[4])
O.dots(c, { { 32, 50 }, { 32, 51 } }, QUIL[1])
-- closer look: a flake of waxy pinfeather sheath on the quill
O.dots(c, { { 31, 52 }, { 32, 52 }, { 31, 53 }, { 32, 53 }, { 33, 53 }, { 32, 54 } }, SHTH[2])
O.dots(c, { { 31, 52 }, { 31, 53 } }, SHTH[3]) O.dots(c, { { 33, 53 }, { 32, 54 } }, SHTH[1])

-- vane along a curved shaft, tip curling right
local SH = { { 31, 48 }, { 31, 36 }, { 34, 19 }, { 43, 4 } }
local vane, vn, VT, VS = O.tube(SH, function(t) return 10.5 * math.sin(math.pi * (.12 + .88 * t)) ^ .6 end)
vane:cut(c:rect(0, 46, 63, 63))
-- asymmetric: the left (leading) vane is narrower
local lead = HP.mask()
vane:each(function(x, y) if (VS[K(x, y)] or 0) < -.86 then lead:set(x, y) end end)
vane:cut(lead)
local KB = .09 -- how far the barbs sweep toward the tip at the edge
local function bt(x, y) local t, s = VT[K(x, y)] or 0, math.abs(VS[K(x, y)] or 0) return t - KB * s end
-- V splits along the barbs, and a saw-tooth fringe of barb tips on both edges
local cut = HP.mask()
vane:each(function(x, y)
  local t, s = VT[K(x, y)] or 0, VS[K(x, y)] or 0
  for _, q in ipairs({ { .2, 1 }, { .66, 1 }, { .3, -1 }, { .78, -1 } }) do
    local reach = q[2] > 0 and .45 or .38
    if s * q[2] > reach and math.abs(bt(x, y) - q[1]) < .02 then cut:set(x, y) end
  end
end)
vane:cut(cut)
local edge = vane:edge()
edge:each(function(x, y)
  local s = math.abs(VS[K(x, y)] or 0)
  if s > .5 and math.floor(bt(x, y) * 62) % 3 == 0 then vane:cut(HP.mask():set(x, y)) end
end)
local inFace = function(t, s) return t > .34 and t < .6 and s < .8 end
local vb = {}
vane:each(function(x, y)
  local t, s = VT[K(x, y)] or 0, math.abs(VS[K(x, y)] or 0)
  local b = bt(x, y)
  if b > .92 then vb[K(x, y)] = 1 end -- pale buff tip
end)
local fI, fT = O.shade(c, vane, FEA, { R = 5, bias = vb, amb = .3, wrap = .45, rim = true, bounce = BNC, bmax = 2 })
-- barb lines, crisp chevron bars, shaft streak, pale fringe
O.tex(c, fI, fT, FEA, function(x, y, i)
  local t, s = VT[K(x, y)] or 0, math.abs(VS[K(x, y)] or 0)
  local b = bt(x, y)
  if not inFace(t, s) and b > .04 and b < .88 then
    local ph = (b - .04) % .13
    if ph < .034 then return math.min(i, 3) - 1 - i end -- dark bar core
    if ph < .048 then return math.min(i, 4) - 1 - i end -- softer trailing edge of the bar
  end
  if inFace(t, s) then
    if s > .62 and math.floor(bt(x, y) * 70) % 4 == 0 then return -1 end
    return 0
  end
  if s < .22 and t < .9 and i >= 3 then return -1 end -- dark streak along the shaft
  if s > .25 and math.floor(bt(x, y) * 70) % 4 == 0 and i >= 4 then return -1 end
  if s > .82 and i <= 5 and i >= 3 and H(x, y, 7) > .5 then return 1 end
end)
-- shaft: pale line, hidden behind the face
vane:each(function(x, y)
  local t, s = VT[K(x, y)] or 0, math.abs(VS[K(x, y)] or 0)
  if s * 10 < .55 and not (t > .32 and t < .62) and t < .95 then O.mark(c, { { x, y } }, t > .5 and QUIL[4] or QUIL[3]) end
end)

-- afterfeather: a puff of grey down at the base
local puff = O.unionCircles{ { 26, 45, 3, 2.5 }, { 30, 46.5, 3, 2.5 }, { 35, 45, 3, 2.5 }, { 23.5, 42.5, 2, 1.5 }, { 37.5, 42.5, 2, 1.5 } }
local pI, pT = O.shade(c, puff, DOWN, { R = 2, amb = .35, wrap = .5, cuts = { .3, .5, .7, .88 }, sep = FEA[1], rim = true, bounce = BNC, bmax = 2 })
O.tex(c, pI, pT, DOWN, function(x, y, i) if (x + y) % 3 == 0 and i >= 3 then return -1 end end)
O.dots(c, { { 21, 45 }, { 20, 46 }, { 39, 46 }, { 40, 47 } }, DOWN[3]) -- wisps

-- face, either side of the shaft
c:eyeLocked(25, 25)
c:eyeLocked(36, 25)
c:cheek(24, 32) c:cheek(41, 32)
O.dots(c, { { 30, 34 }, { 31, 35 }, { 35, 34 }, { 34, 35 } }, P.ink)
O.dot(c, 31, 34, FEA[2]) O.dot(c, 34, 34, FEA[2])

-- quirk: the hush finger, a grey down wisp rising from the puff and up across the lips
local fin, fn = O.tube({ { 39, 43 }, { 39, 39 }, { 33, 41 }, { 33, 32 } }, function(t) return 1.5 end)
O.shadeN(c, fin, fn, DOWN, { amb = .45, wrap = .5, cuts = { .3, .5, .7, .88 }, sep = DOWN[1] })
O.dots(c, { { 32, 32 }, { 33, 32 } }, DOWN[5])

O.shift(c, 1, 0)
O.done(c, "pl-owl-1-yard", function(c)
  for _, p in ipairs({ { 15, 30 }, { 14, 29 }, { 14, 34 }, { 13, 34 }, { 12, 34 }, { 15, 38 }, { 14, 39 } }) do c:put(p[1], p[2], P.ink) end
end)
