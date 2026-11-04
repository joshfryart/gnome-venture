-- npc-abuela-quilla portrait (npc2 P1_0) species: alpaca
-- Same design as the sprite: fawn alpaca grandma, silver braids, bowler + red band + gold feather, red aguayo
-- shawl, drop spindle with teal yarn. 80x100, bleeds off the bottom, dusk (moon) backdrop disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-abuela-quilla"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local FLE = { hi = "#f7e2b8", base = "#dcb184", shade = "#a97c74", deep = "#6a4a5e" }
local MUZ = { hi = "#fff4d6", base = "#f3d9ae", shade = "#cfa594", deep = "#7f5a66" }
local HAT = { hi = "#9c6a52", base = "#6e4638", shade = "#4e3044", deep = "#38223a" }
local HOOF = { hi = "#8a6a6a", base = "#5e4250", shade = "#45304a", deep = "#38223a" }
local SHW = P.ember
local function D(x, y, hex) c:put(x, y, hex, c.own[y * c.w + x] or "d") end
local function restrip(m, y0, y1, r, from)
  m:each(function(x, y) if y >= y0 and y <= y1 then
    local v = c:get(x, y)
    local t = (v == from.hi and "hi") or (v == from.base and "base") or (v == from.shade and "shade")
    if t then D(x, y, r[t]) end end end)
end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
-- neck + shawl
c:part(c:rect(30, 64, 49, 80), FLE, { nopop = true })
local sh = c:poly{ {8,99},{10,86},{20,76},{59,76},{69,86},{71,99} }
c:part(sh, SHW, { band = 3 })
restrip(sh, 81, 83, P.gold, SHW) restrip(sh, 87, 88, P.sea, SHW) restrip(sh, 92, 94, P.petal, SHW)
for x = 13, 66, 5 do if c:get(x, 82) == P.gold.base or c:get(x, 82) == P.gold.shade then
  D(x, 82, P.cream) D(x - 1, 82, P.cream) D(x + 1, 82, P.cream) D(x, 81, P.cream) D(x, 83, P.cream) end end
for x = 11, 68, 3 do if sh:has(x, 90) then D(x, 90, P.ember.deep) end end
-- silver braids
for _, q in ipairs{ {21, 18}, {58, 61} } do
  local pts = { {q[1], 52}, {(q[1] + q[2]) / 2, 66}, {q[2], 80} }
  c:part(c:line(pts, 4), P.stone, { band = 1, nopop = true })
  for y = 56, 78, 4 do local x = math.floor(q[1] + (q[2] - q[1]) * (y - 52) / 28 + .5) D(x, y, P.stone.shade) D(x + 1, y + 1, P.stone.shade) end
  c:part(c:ellipse(q[2] + .5, 83, 2.5, 2), P.ember, { nopop = true })
end
-- banana ears
c:part(c:line({ {26,38},{20,26},{18,13} }, 6), FLE, { band = 2, nopop = true })
c:part(c:line({ {53,38},{59,26},{61,13} }, 6), FLE, { band = 2, nopop = true })
c:line({ {24,32},{20,24},{19,18} }, 2):each(function(x, y) if c:get(x, y) then D(x, y, MUZ.shade) end end)
c:line({ {55,32},{59,24},{60,18} }, 2):each(function(x, y) if c:get(x, y) then D(x, y, MUZ.shade) end end)
-- head (woolly edge)
local head = c:ellipse(39.5, 50, 20, 16.5)
for a = 150, 390, 24 do local r = math.rad(a) head:add(HP.ellipse(39.5 + math.cos(r) * 19.5, 50 + math.sin(r) * 16, 2, 2)) end
c:part(head, FLE, { band = 3, pop = { 25, 42 } })
for _, q in ipairs{ {25,47},{26,46},{54,46},{55,47},{23,53},{56,54} } do if c:get(q[1], q[2]) == FLE.base then D(q[1], q[2], FLE.shade) end end
-- muzzle
c:part(c:ellipse(39.5, 60, 10, 7), MUZ, { band = 2, pop = { 33, 55 } })
for x = 36, 43 do D(x, 56, MUZ.shade) end for x = 37, 42 do D(x, 57, MUZ.shade) end
for _, q in ipairs{ {36,57},{37,58},{43,57},{42,58},{39,59},{40,59},{39,60},{40,60},{35,62},{36,63},{37,63},{38,62},{41,62},{42,63},{43,63},{44,62} } do D(q[1], q[2], MUZ.deep) end
D(39, 63, P.petal.base) D(40, 63, P.petal.base)
-- eyes, lashes, soft lids, cheeks
c:eyeLocked(28, 45) c:eyeLocked(47, 45)
for x = 29, 31 do D(x, 44, FLE.shade) end for x = 48, 50 do D(x, 44, FLE.shade) end
D(27, 45, P.ink) D(26, 44, P.ink) D(52, 45, P.ink) D(53, 44, P.ink)
for _, q in ipairs{ {24,52},{25,52},{26,52},{25,53},{53,52},{54,52},{55,52},{54,53} } do D(q[1], q[2], P.petal.base) end
-- woolly bangs under the brim
local bang = HP.mask()
for _, q in ipairs{ {26,37,4,3}, {32,37.5,3,2.5}, {47,37.5,3,2.5}, {53,37,4,3} } do bang:add(HP.ellipse(q[1], q[2], q[3], q[4])) end
c:part(bang, FLE, { band = 1, pop = { 24, 36 } })
-- bowler hat
local hm = c:rrect(29, 14, 50, 33, 7) hm:add(c:ellipse(39.5, 34, 18, 3))
c:part(hm, HAT, { band = 3, pop = { 32, 17 } })
restrip(hm:copy():clip(c:rect(29, 26, 50, 30)), 26, 30, P.ember, HAT)
for x = 30, 49, 3 do D(x, 28, P.gold.base) end
for x = 23, 56 do if c:get(x, 33) == HAT.base then D(x, 33, HAT.shade) end end
-- gold feather with red tip
c:part(c:line({ {48,28},{53,19},{58,10} }, 3), P.gold, { band = 1, nopop = true })
c:line({ {49,26},{53,19},{57,12} }, 1):each(function(x, y) D(x, y, P.gold.hi) end)
c:part(c:ellipse(58.5, 9, 2, 2), P.ember, { nopop = true })
-- drop spindle (prop): stick, teal yarn cop, wooden whorl, held in a fleecy hoof
c:part(c:line({ {55,70},{61,84},{66,99} }, 2), P.wood, { nopop = true, noshade = true })
c:part(c:ellipse(58, 77, 3.5, 5), P.sea, { band = 2, pop = { 56, 74 } })
for _, q in ipairs{ {57,79},{58,78},{59,77},{57,76},{58,75} } do D(q[1], q[2], P.sea.shade) end
c:part(c:ellipse(63.5, 92, 6, 2.5), P.wood, { band = 1, pop = { 59, 91 } })
c:part(c:ellipse(61, 85, 4, 3.5), FLE, { nopop = true })
c:part(c:ellipse(63, 87.5, 2, 1.5), HOOF, { nopop = true })
c:finish{ outline = true }
backdrop(P.dusk)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
