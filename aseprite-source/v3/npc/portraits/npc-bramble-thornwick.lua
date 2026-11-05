-- npc-bramble-thornwick portrait (npc2 P1_4) species: hedgehog
-- head+shoulders, quill crown, tilted blue beret, pointed muzzle, basket of blackberries in frame. petal backdrop.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local HH = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hedgehog.lua")
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
local NAME = "npc-bramble-thornwick"
local c = HP.canvas{ w = 80, h = 100, name = NAME }
local body = c:ellipse(39.5, 102, 33, 30):clip(c:rect(0, 66, 79, 99))
for _, d in ipairs{ 200, 215, 230, 310, 325, 340 } do spike(c, body, 39.5, 102, d, 30, 27, 38, 36, 3) end
body:clip(c:rect(0, 0, 79, 99))
c:part(body, QU, { pop = { x = 14, y = 82 } })
HH.texture(c, body, 39.5, 100, 33, 28, QU)
local belly = c:ellipse(39.5, 104, 15, 30):clip(c:rect(0, 72, 79, 99))
c:part(belly, FC, { pop = { x = 30, y = 78 } })
-- head with quill crown
HH.head(c, { cx = 39.5, cy = 46, s = 1.4, SP = QU, FACE = FC })
local bk = c:rrect(26, 85, 53, 99, 3) c:part(bk, "wood", { pop = { x = 28, y = 87 } })
hatch(c, bk, { [P.wood.base] = P.wood.shade, [P.wood.hi] = P.wood.base }, function(x, y) return (x + (y % 3 == 0 and 2 or 0)) % 4 == 0 and y > 87 end)
for _, q in ipairs{ { 31, 81 }, { 37, 79 }, { 43, 80 }, { 49, 82 }, { 34, 83 }, { 46, 84 } } do
  local m = c:ellipse(q[1], q[2], 3, 3) c:part(m, BER, { pop = { x = q[1] - 1, y = q[2] - 1 } })
  c:put(q[1] + 1, q[2] + 1, BER.base) c:put(q[1] - 1, q[2] + 1, BER.base)
end
local lf = c:poly{ { 40, 76 }, { 48, 72 }, { 50, 74 }, { 43, 78 } } c:part(lf, "moss", { pop = { x = 43, y = 75 } })
c:part(c:rrect(24, 84, 55, 87, 2), "wood", { pop = { x = 26, y = 84 } })
for _, x in ipairs{ 22, 57 } do c:part(c:ellipse(x, 86, 3, 3), FC, { pop = { x = x - 1, y = 84 } }) end
-- tilted beret
local bm = c:ellipse(38, 31, 17, 5.5) bm:add(c:ellipse(35, 28, 13, 5)) bm:add(c:ellipse(22, 34, 4, 2.5))
c:part(bm, "sea", { pop = { x = 27, y = 26 } }) under(c, bm, P.sea.deep)
c:fillMask(c:poly{ { 42, 28 }, { 50, 27 }, { 46, 29 } }, P.sea.shade)
c:stitch{ { 23, 34 }, { 54, 34 } }
c:part(c:rect(37, 20, 39, 23), "sea", { pop = { x = 37, y = 20 } })
c:finish{ outline = true }
backdrop(c, P.petal)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
