-- npc-auntie-mossbead: kindly mossy elder gnome-folk, green knit cap, moss-bead necklace, kitten in basket (quirk).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-auntie-mossbead"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 31, 31)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local function pts(list, hex) for _, p in ipairs(list) do c:px(p[1], p[2], hex) end end
local function keep(x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function recol(mask, map) mask:each(function(x, y) local v = map[c:get(x, y) or ""] if v then keep(x, y, v) end end) end
local SK = P.skinC
local ORG = "#e89d28"

---------------------------------------------------------------- shawl body (gold-orange, ember stripes, folds, trim)
local body = c:ellipse(39.5, 106, 35, 36):clip(c:rect(0, 70, 79, 99))
c:part(body, "gold", { band = 1, pop = { x = 16, y = 84 } })
for _, y0 in ipairs{ 82, 91 } do
  local s = HP.mask() for x = 0, 79 do for y = y0 + (x % 2), y0 + 2 do s:set(x, y) end end
  s:clip(body):each(function(x, y)
    local v = c:get(x, y)
    if v == P.gold.base or v == P.gold.hi then keep(x, y, P.ember.hi) elseif v == P.gold.shade then keep(x, y, P.ember.base) end
  end)
end
-- folds (cool shade creases)
for _, f in ipairs{ { {22,78},{18,99} }, { {58,80},{63,99} }, { {33,95},{31,99} } } do
  recol(c:line(f, 1):clip(body), { [P.gold.base] = P.gold.shade, [P.ember.hi] = P.ember.base, [P.gold.hi] = P.gold.base, [P.gold.shade] = P.gold.deep })
end
-- front V opening with moss trim band
c:part(c:poly{ {30,70},{49,70},{39.5,86} }, { hi = P.moss.hi, base = P.moss.base, shade = P.moss.shade, deep = P.moss.deep }, { band = 2, nopop = true })
c:stitch{ {33,73}, {40,83} } c:stitch{ {46,73}, {40,83} }
-- neck
c:part(c:rrect(33, 60, 46, 74, 3), SK, { band = 2, nopop = true })
c:fillMask(c:rect(34, 66, 45, 68), SK.shade)

---------------------------------------------------------------- head
local head = c:ellipse(39.5, 47, 21, 18)
head:add(HP.ellipse(18.5, 50, 2, 3.5)) head:add(HP.ellipse(61.5, 50, 2, 3.5)) -- ears
c:part(head, SK, { band = 3, pop = { x = 28, y = 42 } })
-- grey hair puffs under the cap at the sides
local hair = HP.mask():add(HP.ellipse(18, 42, 3.5, 8)):add(HP.ellipse(61, 42, 3.5, 8)):add(HP.ellipse(16.5, 50, 2, 3)):add(HP.ellipse(62.5, 50, 2, 3))
c:part(hair, { hi = P.cream, base = P.stone.hi, shade = P.stone.base, deep = P.stone.shade }, { band = 4, pop = { x = 17, y = 38 } })
for _, s in ipairs{ {17,36,17,46},{19,37,19,47},{60,36,60,46},{62,38,62,47} } do
  recol(c:line({ {s[1],s[2]},{s[3],s[4]} }, 1):clip(hair), { [P.stone.hi] = P.cream, [P.stone.base] = P.stone.hi })
end
-- knit cap: dome, ribbed brim, pom
local cap = c:ellipse(39.5, 38, 23, 17):clip(c:rect(0, 0, 79, 36))
local CAP = { hi = P.moss.base, base = P.moss.shade, shade = P.moss.deep, deep = P.moss.deep }
c:part(cap, CAP, { band = 5, pop = { x = 27, y = 26 } })
for y = 25, 34, 3 do for x = 18 + (y % 2) * 2, 62, 4 do
  recol(c:rect(x, y, x + 1, y + 1):clip(cap), { [P.moss.shade] = P.moss.base, [P.moss.base] = P.moss.hi })
end end
local brim = c:rrect(16, 34, 63, 41, 2)
c:part(brim, CAP, { band = 6, pop = { x = 20, y = 35 } })
for x = 18, 62, 3 do recol(c:rect(x, 35, x, 40):clip(brim), { [P.moss.shade] = P.moss.deep, [P.moss.base] = P.moss.base }) end
for x = 19, 61, 3 do recol(c:rect(x, 36, x, 39):clip(brim), { [P.moss.shade] = P.moss.base }) end
local pom = HP.mask():add(HP.ellipse(39.5, 20, 4, 4)) for _, b in ipairs{ {35,18},{44,18},{39,15},{36,23},{43,23} } do pom:set(b[1], b[2]) end
c:part(pom, "gold", { band = 7, pop = { x = 37, y = 18 } })

---------------------------------------------------------------- face
c:paint({ "iiii", ".ii." }, 29, 41, { i = "stone.shade" }) c:paint({ "iiii", ".ii." }, 46, 41, { i = "stone.shade" }) -- grey brows
pts({ {29,41},{30,41} }, P.stone.base) pts({ {46,41},{47,41} }, P.stone.base)
c:eyeLocked(30, 44) c:eyeLocked(45, 44)
pts({ {27,46},{27,48},{52,46},{52,48} }, SK.shade)  -- crow's feet
pts({ {26,47},{53,47} }, SK.shade)
-- designed nose: lit warm tip, nostril shadow, dark underside row
c:paint({ ".HH.", "HBBs", "DssD", ".dd." }, 38, 48, { H = "skinB.hi", B = "skinB.base", s = "skinC.shade", D = "skinC.deep", d = "skinC.deep" })
pts({ {38,48},{41,48} }, SK.base)
c:paint({ "PP", "pp" }, 26, 52, { P = "petal.base", p = "petal.base" }) c:paint({ "PP" }, 26, 52, { P = "petal.base" })
c:paint({ "PP" }, 52, 52, { P = "petal.base" })
pts({ {26,52} }, P.petal.hi)
c:paint({ "i.....i", ".iDDDi.", "..iii.." }, 36, 54, { i = "ink", D = "ember.deep" })
pts({ {36,54},{42,54} }, P.ink)
pts({ {33,57},{46,57},{32,56},{47,56} }, SK.shade) -- smile lines
-- moss-bead necklace along the trim edge
for _, b in ipairs{ {32,74},{34,77},{36,80},{39,82},{42,80},{44,77},{46,74} } do
  c:part(c:rect(b[1], b[2], b[1] + 1, b[2] + 1), { hi = P.moss.hi, base = P.moss.base, shade = P.moss.shade, deep = P.moss.deep }, { band = 8, nopop = true })
  c:px(b[1], b[2], P.moss.hi)
end

---------------------------------------------------------------- quirk: kitten peeking from a basket
local bask = c:rrect(47, 84, 78, 99, 3)
c:part(bask, "wood", { band = 9, pop = { x = 49, y = 85 } })
for y = 87, 98, 3 do recol(c:rect(48, y, 77, y):clip(bask), { [P.wood.base] = P.wood.shade, [P.wood.hi] = P.wood.base }) end
for x = 50 + 0, 76, 4 do recol(c:rect(x, 85, x, 99):clip(bask), { [P.wood.base] = P.wood.hi, [P.wood.shade] = P.wood.base }) end
c:fillMask(c:rect(47, 84, 78, 85), P.wood.hi)
local kit = HP.mask():add(HP.ellipse(62, 78, 8, 6.5)):add(c:poly{ {54,75},{54,68},{59,73} }):add(c:poly{ {70,75},{70,68},{65,73} })
c:part(kit, "stone", { band = 10, pop = { x = 57, y = 74 } })
c:paint({ "ii", "ii" }, 58, 76, {i = "ink"}) c:paint({ "ii", "ii" }, 65, 76, {i = "ink"})
pts({ {58,76},{65,76} }, P.cream)
c:paint({ "pp" }, 62, 79, { p = "petal.base" })
pts({ {56,70},{68,70} }, P.petal.hi)
pts({ {56,78},{57,79},{67,79},{68,78} }, P.stone.shade)

c:finish{ outline = true }
backdrop(P.moss)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
