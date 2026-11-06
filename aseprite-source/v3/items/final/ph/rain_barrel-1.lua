-- rain_barrel-1 (artist pass aD11_2). Tier 1: a slim, plain oak cask with two riveted iron hoops, water low in the open
-- top, a zinc downspout bracketed to the left and ending over the water.
-- Material: per-pixel cylinder light on 7 curved staves (bevelled seams, vertical grain streaks, one knot), curved bevelled
-- hoops with rivets + specular, pale end-grain rim, dark back wall, rippled water with a bright lip, warm bounce on the shade side.
-- quirk: a single drop hangs from the spout, about to fall.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_2.lua")
local G = A.G
local c = A.new("rain_barrel-1")
c:groundShadow(32, 55, 14, 2)
local b = A.cask(c, { cx = 32, yt = 25, yb = 50, wt = 9, wb = 8, bulge = 3, ry = 6, ryb = 3, nst = 7, lv = 2, ripple = .55,
  knot = { 36, 40 }, hoops = { { y = 30, rivets = { -5, 3, 7 } }, { y = 45, rivets = { -6, 1, 6 } } } })
-- downspout: wall bracket plate, vertical run, elbow, horizontal run, short spout over the water
local Z = A.STONE
A.rod(c, 13, 8, 13, 14, 1.5, Z, { amb = .1 })
A.rod(c, 13, 14, 27, 14, 1.5, Z, { amb = .1 })
A.rod(c, 27, 14, 27, 18, 1.5, Z, { amb = .1 })
G.disc(c, 13, 14, 2.6, Z)
c:fillMask(c:rect(11, 10, 15, 10), Z[2]) c:fillMask(c:rect(11, 9, 15, 9), Z[5])   -- wall bracket band
A.collar(c, 20, 13, 0, Z, 3)                                                       -- coupling on the run
c:px(26, 18, Z[1]) c:px(27, 18, Z[1]) c:px(28, 18, Z[2])                           -- dark spout mouth
A.drop(c, 27, 20, A.WATER)                                                         -- the quirk
A.fin(c, "rain_barrel-1")
