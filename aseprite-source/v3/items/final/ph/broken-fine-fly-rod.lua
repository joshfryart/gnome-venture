-- broken-fine-fly-rod (aB11_1, Opus single pass). Slim split-cane fly rod on the diagonal: brass butt cap,
-- ringed cork grip, brass reel seat, gunmetal reel with a brass crank and wound line, honey cane with dark nodes
-- and red silk guide wraps. broken: the cane is snapped; fresh pale splinters on both ends, the tip section hangs
-- from a slack loop of line, and a cane splinter flies off. Material: cork pits + rings, cane node bands and a
-- lit facet, reel bevel + specular, AO where grip meets seat. quirk: a tiny tied fly is hooked into the cork.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_1.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.start(debug.getinfo(1, "S").source)
local LINE = { "#5e8a4a", "#a6cc72", "#dcf0a4" }
local FRESH = { "#c89a52", "#f4dca0" }

-- reel (behind the rod): foot then disc on the lower-right side of the seat
local rcx, rcy = 25, 47
c:paint({ "ab", ".ab" }, 22, 43, { a = D.GUN[4], b = D.GUN[2] })
local rm, rn = c:ellipse(rcx, rcy, 4, 4), nil
rn = X.sphere(rcx - 0.6, rcy - 0.6, 4, rm)
D.toneN(c, rm, rn, D.GUN, { amb = 0.1 })
-- wound line ring + spool hub
for _, p in ipairs{ {-2,-1},{-2,0},{-1,-2},{0,-2},{-2,1},{1,-2} } do c:px(rcx + p[1], rcy + p[2], LINE[2]) end
for _, p in ipairs{ {2,1},{1,2},{2,0},{0,2} } do c:px(rcx + p[1], rcy + p[2], LINE[1]) end
c:px(rcx - 1, rcy - 1, LINE[3])
c:px(rcx, rcy, D.BRASS[4]) c:px(rcx + 1, rcy, D.BRASS[2]) c:px(rcx, rcy + 1, D.BRASS[2]) c:px(rcx - 1, rcy, D.BRASS[5])
c:px(rcx - 2, rcy - 3, D.GUN[6]) c:px(rcx - 3, rcy - 2, D.GUN[5])
-- crank arm + wooden knob
c:px(rcx + 2, rcy + 2, D.GUN[3]) c:px(rcx + 3, rcy + 3, D.GUN[2])
c:paint({ "ab", "bc" }, rcx + 4, rcy + 3, { a = D.WOOD[5], b = D.WOOD[4], c = D.WOOD[2] })

-- butt cap (brass)
D.cyl(c, 8, 57, 11, 54, function() return 1.7 end, D.BRASS)
c:px(8, 56, D.BRASS[6])
-- cork grip
local gm, gT, gS = D.cyl(c, 11, 54, 19, 46, function(t) return 1.7 + 0.5 * sin(pi * t) end, D.CORK)
local glen = sqrt(128)
gm:each(function(x, y) local k = K(x, y)
  local t, s = gT[k], gS[k]
  if floor(t * glen + 0.5) % 3 == 0 and s > -0.6 then c:px(x, y, s > 0.3 and D.CORK[2] or D.CORK[3]) end
  if X.hash(x, y, 11) > 0.82 and s > -0.5 then c:px(x, y, D.CORK[2]) end
end)
c:px(13, 50, D.CORK[6]) c:px(14, 49, D.CORK[6])
-- reel seat (brass) + AO ring where cork meets it
D.cyl(c, 19, 46, 23, 42, function() return 1.4 end, D.BRASS)
c:px(19, 45, D.BRASS[6]) c:px(21, 43, D.BRASS[1]) c:px(22, 44, D.BRASS[1])
c:px(19, 47, D.CORK[1]) c:px(20, 47, D.CORK[1]) c:px(18, 47, D.CORK[2])

-- lower cane section (snapped at its far end)
local cm, cT, cS = D.cyl(c, 23, 42, 37, 28, function(t) return 1.15 - 0.15 * t end, D.CANE)
local clen = sqrt(392)
cm:each(function(x, y) local k = K(x, y)
  local d = cT[k] * clen
  if (floor(d) % 7 == 4) then c:px(x, y, cS[k] < 0 and D.CANE[3] or D.CANE[2]) end
end)
-- red silk guide wraps + steel guide loop on the underside
local function wrap(x, y)
  c:px(x, y, D.RED[4]) c:px(x + 1, y + 1, D.RED[2]) c:px(x - 1, y - 1, D.RED[5])
  c:px(x + 2, y + 1, D.STEEL[5]) c:px(x + 2, y + 2, D.STEEL[3])
end
wrap(28, 37)
-- fresh splinters at the break (pale inner fibres)
c:px(37, 27, FRESH[1]) c:px(38, 26, FRESH[2]) c:px(39, 25, FRESH[2]) c:px(38, 27, FRESH[1]) c:px(36, 27, FRESH[1])
c:px(39, 26, D.CANE[3])

-- upper (tip) section hanging down from the break
local um, uT, uS = D.cyl(c, 41, 31, 54, 46, function(t) return 0.95 - 0.45 * t end, D.CANE)
local ulen = sqrt(13*13 + 15*15)
um:each(function(x, y) local k = K(x, y)
  if floor(uT[k] * ulen) % 7 == 5 then c:px(x, y, D.CANE[2]) end
end)
c:px(40, 30, FRESH[2]) c:px(40, 29, FRESH[1]) c:px(41, 30, FRESH[1])
c:px(47, 38, D.RED[4]) c:px(48, 39, D.RED[2]) c:px(46, 39, D.STEEL[5])
-- tip-top ring
c:px(55, 47, D.STEEL[5]) c:px(55, 48, D.STEEL[3])

-- slack loop of fly line joining the two sections
for i = 0, 40 do
  local x, y = D.bez({ { 36, 30 }, { 34, 37 }, { 41, 39 }, { 42, 34 } }, i / 40)
  local xi, yi = floor(x + .5), floor(y + .5)
  if not cm:has(xi, yi) and not um:has(xi, yi) then c:px(xi, yi, i < 22 and LINE[2] or LINE[1]) end
end

-- flying cane splinter (the chip)
c:px(43, 22, FRESH[2]) c:px(44, 21, FRESH[1]) c:px(45, 20, D.CANE[3])
c:px(46, 25, FRESH[1]) c:px(47, 25, D.CANE[3])

-- quirk: a tiny tied fly hooked into the cork (red body, pale hackle, grey wing)
c:px(12, 47, D.RED[3]) c:px(11, 47, D.RED[4]) c:px(11, 46, "#cfd6e6") c:px(12, 46, "#9aa4bd")
c:px(13, 48, D.GUN[3])

D.fin(c)
