-- masterwork-gnome-seeder (aC22_4, Opus single pass). A tall push seeder: oak-stave hopper bound by two copper
-- hoops, capped with a floppy red gnome-hat lid; a copper funnel drops seed through a slim tube to an iron furrow
-- shoe; a small six-spoke iron wheel at the front; a long slim handle with a wrapped T-grip rises up-right.
-- Material: vertical-cylinder staves with seams + grain, copper bevel with glints, felt hat with fold lines,
-- iron spokes and tread notches, AO under the hoops and the lid.
-- quirk: a brass bell hangs from the hat tip, and two seeds are falling from the shoe.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = G.new("masterwork-gnome-seeder")
c:groundShadow(30, 53, 18, 2)

-- handle (behind the hopper): from hopper back to upper right, T-grip
local hd, hdn = G.rod(30, 34, 53, 10, 1.3)
local hidx, htok = G.shade(c, hd, hdn, G.OAK, { amb = 0.12 })
for _, t in ipairs{ 0.45, 0.6, 0.75 } do
  local x, y = floor(30 + 23 * t + .5), floor(34 - 24 * t + .5)
  if hd:has(x, y) then c:put(x, y, G.OAK[3], htok) end
end
local tg, tgn = G.rod(50, 7, 57, 12, 1.3)
local ti, ttok = G.shade(c, tg, tgn, G.WOOD, { amb = 0.15 })
tg:each(function(x, y) if (x - y) % 3 == 0 then c:put(x, y, G.WOOD[max(1, (ti[K(x, y)] or 3) - 1)], ttok) end end)

-- frame: iron strut from hopper to wheel axle, and drop tube to the shoe
local fr, frn = G.rod(21, 36, 17, 45, 0.8)
G.shade(c, fr, frn, G.IRON, { amb = 0.15 })
local tube, tuben = G.rod(26, 37, 29, 48, 1.0)
local tb = {}
local tuI, tuTok = G.shade(c, tube, tuben, G.COPPER, { bias = tb, amb = 0.15 })
-- furrow shoe
local shoe = c:poly{ { 27, 47 }, { 32, 47 }, { 34, 51 }, { 29, 51 } }
local shn = X.pillow(shoe, 1.2)
G.shade(c, shoe, shn, G.IRON, { amb = 0.15 })
c:put(34, 51, G.IRON[6])

-- wheel at the front
G.wheel(c, 16, 45, { R = 7, tw = 2, spokes = 6, rot = 0.3, sw = 0.6, hub = 1.5, wood = G.IRON, tyre = G.IRON,
  hubRamp = G.COPPER, spec = G.IRON[6] })
-- tread notches on the tyre
for _, a in ipairs{ 0.2, 1.0, 1.8, 2.6, 3.4, 4.2, 5.0, 5.8 } do
  local x, y = floor(16 + math.cos(a) * 7 + .5), floor(45 + math.sin(a) * 7 + .5)
  if c:get(x, y) then c:put(x, y, G.IRON[1]) end
end

-- hopper funnel (copper cone) under the barrel
local fun = c:poly{ { 15, 31 }, { 37, 31 }, { 29, 38 }, { 24, 38 } }
local fB = {}
local funN = {}
fun:each(function(x, y) local s = (x - 26.5) / 10 funN[K(x, y)] = { G.norm(s, 0.35, sqrt(max(0.05, 1 - s * s))) } end)
local fI, fTok = G.shade(c, fun, funN, G.COPPER, { bias = fB, amb = 0.12, wrap = 0.2 })
for x = 15, 37 do if fun:has(x, 31) then c:put(x, 31, G.COPPER[2], fTok) end end
c:put(20, 33, G.COPPER[6], fTok) c:put(21, 33, G.SPEC, fTok)

-- barrel: vertical cylinder of staves
local bar = c:rrect(14, 15, 38, 30, 2)
local bN = {}
bar:each(function(x, y) local s = (x - 26) / 12.6 bN[K(x, y)] = { G.norm(s, 0, sqrt(max(0.04, 1 - s * s))) } end)
local bB = {}
bar:each(function(x, y) if y <= 16 then bB[K(x, y)] = -1 end end) -- AO under the lid
local bidx, btok = G.shade(c, bar, bN, G.OAK, { bias = bB, amb = 0.12, wrap = 0.2 })
-- stave seams (closer together toward the edges = foreshortening)
for _, sx in ipairs{ 17, 21, 26, 31, 35 } do
  for y = 15, 30 do if bar:has(sx, y) then c:put(sx, y, G.OAK[max(1, (bidx[K(sx, y)] or 3) - 2)], btok) end end
end
-- grain ticks
for _, g in ipairs{ { 19, 18, 3 }, { 23, 24, 3 }, { 28, 17, 2 }, { 33, 22, 3 }, { 24, 18, 2 } } do
  for i = 0, g[3] do c:put(g[1], g[2] + i, G.OAK[max(1, (bidx[K(g[1], g[2] + i)] or 3) - 1)], btok) end
end
-- copper hoops, 2 px, with bevel and AO below
local function hoop(y)
  local hm = HP.mask() for x = 13, 39 do if bar:has(x, y) or bar:has(x, y + 1) then hm:set(x, y) hm:set(x, y + 1) end end
  hm:set(13, y) hm:set(13, y + 1) hm:set(39, y) hm:set(39, y + 1)
  local hn = {}
  hm:each(function(x, yy) local s = (x - 26) / 13.5 hn[K(x, yy)] = { G.norm(s, yy == y and -0.5 or 0.4, sqrt(max(0.04, 1 - s * s))) } end)
  G.shade(c, hm, hn, G.COPPER, { amb = 0.15, wrap = 0.2, spec = { 25, 0.85, G.SPEC } })
  for x = 14, 38 do if bar:has(x, y + 2) then c:put(x, y + 2, G.OAK[max(1, (bidx[K(x, y + 2)] or 3) - 1)], btok) end end
end
hoop(18) hoop(26)
-- brass seed-window (oval) showing seeds inside, between the hoops
local win, winn = G.oval(26, 23, 3.4, 1.6, 0, 0.8)
c:fillMask(win, "#5e3226")
local seedsPx = { { 24, 23, "#e8c886" }, { 25, 22, "#cf9f60" }, { 27, 23, "#f6e2aa" }, { 28, 22, "#cf9f60" }, { 26, 24, "#a8744a" }, { 23, 24, "#cf9f60" }, { 29, 24, "#e8c886" } }
for _, s in ipairs(seedsPx) do if win:has(s[1], s[2]) then c:put(s[1], s[2], s[3]) end end
win:grow(1):cut(win):each(function(x, y) c:put(x, y, (y < 23 or x < 25) and G.BRASS[5] or G.BRASS[3]) end)

-- gnome-hat lid: wide brim band, cone curling over to the right
local brim = c:rrect(12, 13, 40, 15, 1)
local brN = X.pillow(brim, 1.5)
local brI, brTok = G.shade(c, brim, brN, G.HAT, { amb = 0.12 })
local cone = HP.mask()
local cp = { { 26, 13 }, { 24, 9 }, { 29, 5 }, { 38, 6 } }
local cm, cn, cT, cS = G.tube(cp, function(t) return 10 * (1 - t) ^ 1.2 + 0.4 end)
cm:each(function(x, y) if y <= 13 then cone:set(x, y) end end)
local hB = {}
cone:each(function(x, y) if y >= 12 then hB[K(x, y)] = -1 end end)
local hI, hTok = G.shade(c, cone, cn, G.HAT, { bias = hB, amb = 0.12, wrap = 0.25 })
-- felt fold lines
for _, f in ipairs{ { { 22, 12 }, { 24, 8 } }, { { 30, 12 }, { 30, 7 } } } do G.pline(c, f, G.HAT[2], hTok, cone) end
c:put(21, 11, G.HAT[5], hTok) c:put(22, 10, G.HAT[6], hTok)
-- brim stitch line (real seam)
c:stitch{ { 14, 14 }, { 38, 14 } }

-- quirk: brass bell at the hat tip + seeds falling from the shoe
local bell, belln = G.oval(39, 9, 1.6, 1.8, 0, 1)
G.shade(c, bell, belln, G.BRASS, { amb = 0.15, spec = { 10, 0.8, G.SPEC } })
c:put(39, 11, G.BRASS[1])
for _, s in ipairs{ { 36, 49 }, { 38, 52 } } do
  c:put(s[1], s[2], G.MARZ[4]) c:put(s[1] + 1, s[2], G.MARZ[2]) c:put(s[1], s[2] - 1, G.MARZ[6])
end

G.save(c, "ph", "masterwork-gnome-seeder")
