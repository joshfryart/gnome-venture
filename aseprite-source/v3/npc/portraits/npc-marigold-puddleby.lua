-- npc-marigold-puddleby portrait (npc2 P1_21) species: frog
-- 80x100 head+shoulders: wide frog head, eye domes with locked eyes, snout ridge + nostrils, wildflower crown,
-- blue raincoat bleeding off the bottom, waterlily umbrella held over the right shoulder. Sky backdrop disc.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local NAME = "npc-marigold-puddleby"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function kp(x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function under(m, hex) local l = {} m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do kp(q[1], q[2], hex) end end
local function flower(x, y, pet, mid) for _, d in ipairs{ {0,-1},{-1,0},{1,0},{0,1} } do c:put(x + d[1], y + d[2], pet) end c:put(x, y, mid) end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end

-- umbrella stalk (behind everything)
c:part(c:line({ {61, 86}, {60, 50}, {57, 20} }, 1), P.wood, { noshade = true, nopop = true, inner = false })
-- raincoat
local coat = c:ellipse(39.5, 104, 33, 26):clip(c:rect(0, 0, 79, 99))
c:part(coat, P.sea, { band = 3, pop = { 14, 90 } })
for y = 84, 99 do kp(39, y, P.sea.deep) end
for _, ty in ipairs{ 88, 94 } do
  c:put(41, ty, P.gold.hi) c:put(42, ty, P.gold.base) c:put(43, ty, P.gold.base)
  c:put(41, ty + 1, P.gold.base) c:put(42, ty + 1, P.gold.shade) c:put(43, ty + 1, P.gold.shade)
end
c:part(c:poly{ {24, 81}, {38, 78}, {33, 89} }, P.sea, { band = 1, sep = true, pop = { 27, 81 } })
c:part(c:poly{ {55, 81}, {41, 78}, {46, 89} }, P.sea, { band = 1, sep = true, nopop = true })
-- head
local head = c:ellipse(39.5, 57, 21, 13.5)
c:part(head, P.moss, { band = 3, pop = { 23, 50 } })
c:ellipse(39.5, 67, 13, 3.5):clip(head):each(function(x, y) if x < 46 and c:get(x, y) == P.moss.base then kp(x, y, P.moss.hi) end end)
for _, s in ipairs{ {24, 53}, {55, 52}, {30, 66}, {50, 65}, {57, 58} } do
  kp(s[1], s[2], P.moss.shade) kp(s[1] + 1, s[2], P.moss.shade) kp(s[1], s[2] + 1, P.moss.shade) kp(s[1] + 1, s[2] + 1, P.moss.shade)
end
-- snout ridge + nostrils
c:part(c:ellipse(39.5, 54, 5, 2), P.moss, { band = 1, sep = true, pop = { 36, 53 } })
kp(37, 55, P.moss.deep) kp(42, 55, P.moss.deep)
-- wide smile
c:line({ {23, 59}, {27, 62}, {39.5, 63}, {52, 62}, {56, 59} }, 1):each(function(x, y) kp(x, y, P.moss.deep) end)
kp(22, 58, P.moss.deep) kp(57, 58, P.moss.deep)
c:paint({ "PPP", "PPP" }, 22, 60, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 55, 60, { P = "petal.base" })
c:put(22, 60, P.petal.hi) c:put(55, 60, P.petal.hi)
-- eye domes with sockets and locked eyes
for _, ex in ipairs{ 29, 50 } do
  c:part(c:ellipse(ex, 40, 7, 6.5), P.moss, { band = 2, sep = true, pop = { ex - 5, 36 } })
  c:rrect(ex - 3, 37, ex + 3, 43, 2):each(function(x, y) kp(x, y, P.moss.deep) end)
  c:eyeLocked(ex - 2, 38)
  kp(ex - 2, 44, P.moss.shade) kp(ex - 1, 44, P.moss.shade) kp(ex, 44, P.moss.shade) kp(ex + 1, 44, P.moss.shade) kp(ex + 2, 44, P.moss.shade)
end
-- wildflower crown under the eye domes
c:line({ {19, 51}, {29, 48}, {39.5, 47}, {50, 48}, {60, 51} }, 1):each(function(x, y) kp(x, y, P.moss.deep) end)
flower(21, 51, P.petal.base, P.gold.hi)
flower(28, 49, P.gold.base, P.cream)
flower(35, 48, P.dusk.hi, P.gold.base)
flower(44, 48, P.petal.base, P.gold.hi)
flower(51, 49, P.gold.base, P.cream)
flower(58, 51, P.dusk.hi, P.gold.base)
-- hand on the stalk
c:part(c:ellipse(61, 86, 3.5, 3), P.moss, { band = 1, pop = { 59, 84 } })
-- waterlily umbrella canopy
local can = c:ellipse(57, 19, 12, 4)
can:add(c:ellipse(57, 16, 9.5, 5):clip(c:rect(0, 0, 79, 18)))
for _, sx in ipairs{ 46, 51, 57, 63, 68 } do can:add(c:ellipse(sx, 23, 1.5, 1.5)) end
c:part(can, P.petal, { band = 2, pop = { 50, 13 } })
under(can, P.petal.deep)
for _, r in ipairs{ {48, 22}, {57, 23}, {66, 22} } do
  c:line({ {57, 12}, {r[1], r[2]} }, 1):each(function(x, y) if c:get(x, y) ~= P.petal.deep then kp(x, y, P.petal.shade) end end)
end
c:put(57, 10, P.gold.base) c:put(57, 9, P.gold.hi)
c:finish{ outline = true }
backdrop(P.sky)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
