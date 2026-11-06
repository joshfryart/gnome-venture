-- npc-burdock-deepdelve portrait (npc2 P1_4) species: star-nosed mole
-- head+shoulders, wide straw hat, pink star nose, heavy-lidded eyes, spade over the shoulder. moss backdrop.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local function under(c, m, hex) local l = {} m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do c:put(q[1], q[2], hex) end end
local function spike(c, m, cx, cy, deg, r0x, r0y, r1x, r1y, w)
  local a = math.rad(deg) local ca, sa = math.cos(a), math.sin(a)
  local bx, by = cx + ca * r0x, cy + sa * r0y
  m:add(c:poly{ { bx - sa * w, by + ca * w }, { bx + sa * w, by - ca * w }, { cx + ca * r1x, cy + sa * r1y } })
end
local function recol(c, m, map) local l = {} m:each(function(x, y) local v = map[c:get(x, y) or ""] if v then l[#l + 1] = { x, y, v } end end) for _, q in ipairs(l) do c:put(q[1], q[2], q[3]) end end
local function hatch(c, m, map, f) local l = {} m:each(function(x, y) if f(x, y) then local v = map[c:get(x, y) or ""] if v then l[#l + 1] = { x, y, v } end end end) for _, q in ipairs(l) do c:put(q[1], q[2], q[3]) end end
local function eye(c, x, y)
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs{ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } } do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local QU = { hi = "#b48466", base = "#7e5546", shade = "#583a4c", deep = "#3b2640" }
local FC = { hi = P.cream, base = "#f6deb0", shade = "#d9a982", deep = "#9c6a62" }
local BER = { hi = P.dusk.hi, base = P.dusk.shade, shade = P.dusk.deep, deep = "#24183a" }
local NOSE = { hi = "#8a6a8a", base = "#4a2f4a", shade = "#3b2640", deep = "#2f1f34" }
local FUR = { hi = "#a08a98", base = "#715c6c", shade = "#4e3c56", deep = "#33243e" }
local PAW = { hi = "#ffd9cf", base = "#f2a9a3", shade = "#c97a8c", deep = "#7d405e" }
local CLAW = "#f6e6cc"
local NAME = "npc-burdock-deepdelve"
local c = HP.canvas{ w = 80, h = 100, name = NAME }
-- spade over the right shoulder (behind)
local hd = c:line({ { 50, 99 }, { 66, 53 } }, 3) c:part(hd, "wood", { pop = { x = 63, y = 58 } })
local bl = c:poly{ { 62, 54 }, { 62, 43 }, { 67, 36 }, { 72, 43 }, { 72, 54 } }
c:part(bl, "stone", { pop = { x = 64, y = 42 } }) c:part(c:rect(63, 54, 70, 56), "stone", { nopop = true })
c:put(64, 44, P.stone.hi) c:put(64, 45, P.stone.hi)
-- red shirt shoulders, cream collar
local body = c:ellipse(39.5, 104, 33, 32):clip(c:rect(0, 68, 79, 99))
c:part(body, "ember", { pop = { x = 14, y = 84 } })
local col = c:poly{ { 30, 69 }, { 49, 69 }, { 39.5, 82 } } c:part(col, { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }, { nopop = true })
c:button(39, 86) c:button(39, 94)
-- head
local head = c:ellipse(39.5, 54, 20, 17)
c:part(head, FUR, { pop = { x = 24, y = 52 } })
hatch(c, head, { [FUR.base] = FUR.shade, [FUR.hi] = FUR.base }, function(x, y) return (x * 3 + y * 5) % 11 == 0 end)
hatch(c, head, { [FUR.base] = FUR.hi }, function(x, y) return x < 34 and (x * 5 + y * 3) % 13 == 0 end)
for x = 20, 59 do for y = 44, 45 do if head:has(x, y) then c:put(x, y, FUR.shade) end end end
-- heavy-lidded locked eyes
c:eyeLocked(28, 47) c:eyeLocked(47, 47)
for _, x in ipairs{ 28, 47 } do for i = 1, 3 do c:put(x + i, 47, FUR.deep) end c:put(x, 48, FUR.shade) c:put(x + 4, 48, FUR.shade) end
c:paint({ "PP" }, 24, 58, { P = "petal.base" }) c:paint({ "PP" }, 54, 58, { P = "petal.base" })
-- star nose: 12 fleshy rays
local star = c:ellipse(39.5, 59, 3, 2.5)
for i = 0, 11 do
  local a = math.rad(i * 30 + 15) local ca, sa = math.cos(a), math.sin(a)
  star:add(c:line({ { 39.5 + ca * 2, 59 + sa * 2 }, { 39.5 + ca * 6, 59 + sa * 5 } }, 2))
  star:add(HP.ellipse(39.5 + ca * 6.5, 59 + sa * 5.5, 1.2, 1.2))
end
c:part(star, "petal", { pop = { x = 36, y = 55 } })
c:put(38, 59, P.petal.deep) c:put(41, 59, P.petal.deep) c:put(37, 57, P.petal.hi)
c:paint({ "i....i", ".iiii." }, 37, 66, { i = "ink" })
-- big spade paws: left resting low, right gripping the handle
local lp = c:ellipse(18, 91, 6, 5) c:part(lp, PAW, { pop = { x = 15, y = 88 } })
for _, x in ipairs{ 14, 17, 20, 23 } do c:put(x, 96, CLAW) c:put(x, 95, CLAW) end
local rp = c:ellipse(56, 82, 5, 4.5) c:part(rp, PAW, { pop = { x = 54, y = 79 } })
for _, y in ipairs{ 80, 83, 86 } do c:put(51, y, CLAW) c:put(52, y, CLAW) end
-- wide straw hat
local brim = c:ellipse(39.5, 37, 29, 6)
c:part(brim, "gold", { pop = { x = 15, y = 35 } }) under(c, brim, P.gold.deep)
for x = 12, 68, 3 do local y = (x < 26 or x > 53) and 37 or 40 if brim:has(x, y) then c:put(x, y, P.gold.shade) end end
local cr = c:ellipse(39.5, 28, 13, 9) cr:add(c:rect(27, 28, 52, 36))
c:part(cr, "gold", { pop = { x = 31, y = 22 } })
for _, y in ipairs{ 24, 28 } do for x = 29 + (y % 3), 51, 3 do if cr:has(x, y) then c:put(x, y, P.gold.shade) end end end
local band = c:rect(27, 32, 52, 35) c:part(band, "ember", { nopop = true })
c:stitch{ { 28, 33 }, { 51, 33 } }
c:finish{ outline = true }
backdrop(c, P.moss)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
