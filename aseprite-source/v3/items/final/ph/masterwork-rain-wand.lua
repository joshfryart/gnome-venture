-- masterwork-rain-wand (final, Opus single pass). Slim oak wand on the diagonal: teal cord-wrapped grip (spiral twist),
-- brass collar and pommel, oak shaft with broken grain, a flared brass cup holding a raindrop of blue glass in two
-- prongs (bright lit rim, deep shade rim, pale refracted core, cream glint). Two small drops fall from the crystal.
-- quirk: the wand leaks from the wrong end - a drip hangs off the pommel.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_5.lua")
local K = A.K
local c = A.new("masterwork-rain-wand")
local ax, ay, bx, by = 15, 51, 40, 26

-- shaft (oak), slight taper
local sm, sT, sS, sidx, _, slen = A.rod(c, ax, ay, bx, by, function(t) return 1.75 - 0.5 * t end, A.WOOD)
A.grain(c, sm, sT, sS, sidx, A.WOOD, slen, 7, { t0 = 0.3 })

-- cord-wrapped grip t 0..0.3 (spiral grooves = twist)
local gx, gy = ax + (bx - ax) * 0.3, ay + (by - ay) * 0.3
local gm, gT, gS, gidx, _, glen = A.rod(c, ax - 0.3, ay + 0.3, gx, gy, 2.15, A.TEAL, { round = true })
gm:each(function(x, y) local k = K(x, y)
  local u = gT[k] * glen + gS[k] * 1.7
  if u % 2.5 < 0.85 then A.step(c, gidx, A.TEAL, x, y, -2) end
end)
A.contact(c, gm, 1)

-- brass collar over the grip end
local cx0, cy0 = ax + (bx - ax) * 0.28, ay + (by - ay) * 0.28
local cx1, cy1 = ax + (bx - ax) * 0.36, ay + (by - ay) * 0.36
local cm, cT, cS, cidx = A.rod(c, cx0, cy0, cx1, cy1, 2.5, A.BRASS)
cm:each(function(x, y) local k = K(x, y) if cT[k] > 0.4 and cT[k] < 0.62 then A.step(c, cidx, A.BRASS, x, y, -2) end end)
A.contact(c, cm, 1)

-- flared brass cup at the top
local um, uT, uS, uidx = A.rod(c, 37.5, 28.5, 41.6, 24.4, function(t) return 1.5 + 1.4 * t end, A.BRASS)
A.contact(c, um, 1)

-- raindrop crystal sitting in the cup, tip up-right
local u, v = 0.7071, -0.7071
local dm = A.drop(c, 44.6, 21.4, 4.3, 7.5, u, v, A.GLASS)
-- prongs holding it (brass wire, lit and shaded)
A.wire(c, { { 40, 23 }, { 41, 21 }, { 42, 19 } }, function(i, j, n) return j == n and A.BRASS[6] or A.BRASS[5] end)
A.wire(c, { { 43, 27 }, { 45, 26 }, { 47, 25 } }, function(i, j, n) return j == 0 and A.BRASS[3] or A.BRASS[4] end)

-- brass pommel
local pm = A.ball(c, 13.4, 52.6, 2.4, A.BRASS)
c:put(12, 51, A.CREAM)

-- quirk: drip hanging off the pommel
A.drop(c, 13, 58.2, 1.6, 2.6, 0, -1, A.GLASS)

-- two drops falling from the crystal
A.drop(c, 53, 28, 1.5, 2.6, 0, -1, A.GLASS)
A.drop(c, 49.5, 34, 1.2, 2.2, 0, -1, A.GLASS)

-- one cream sparkle off the crystal tip
c:sparkle(55, 13)
A.save(c, "masterwork-rain-wand")
