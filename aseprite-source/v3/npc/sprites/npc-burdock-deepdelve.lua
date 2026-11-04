-- npc-burdock-deepdelve sprite (npc2 P1_4) species: star-nosed mole
-- Burdock Deepdelve: stout star-nosed mole digger, wide straw hat, red shirt, spade planted at his side. idle x4.
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
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.bob or 0
  c:groundShadow(33, 89, 16, 2.5)
  -- spade planted in the ground (static)
  local hd = c:rect(47, 55, 48, 80) c:part(hd, "wood", { pop = { x = 47, y = 56 } })
  c:part(c:rect(45, 53, 50, 54), "wood", { pop = { x = 45, y = 53 } })
  local bl = c:poly{ { 44, 80 }, { 51, 80 }, { 51, 86 }, { 48, 89 }, { 47, 89 }, { 44, 86 } }
  c:part(bl, "stone", { pop = { x = 45, y = 81 } }) c:put(45, 82, P.stone.hi)
  for _, x in ipairs{ 26, 38 } do local m = c:ellipse(x, 88.5, 3.5, 1.5) c:part(m, PAW, { pop = { x = x - 2, y = 88 } }) under(c, m, PAW.deep) end
  -- stout pear body, red shirt
  local body = c:ellipse(32, 74 + b, 14, 13) body:add(c:poly{ { 19, 78 + b }, { 45, 78 + b }, { 42, 87 }, { 22, 87 } })
  c:part(body, FUR, { pop = { x = 21, y = 67 + b } }) under(c, body, FUR.deep)
  local sh = c:ellipse(32, 71 + b, 13, 9):clip(body)
  c:part(sh, "ember", { pop = { x = 22, y = 66 + b } }) under(c, sh, P.ember.deep)
  -- head under the brim
  local head = c:ellipse(32, 53 + b, 13, 10)
  c:part(head, FUR, { pop = { x = 22, y = 52 + b } })
  hatch(c, head:copy():add(body), { [FUR.base] = FUR.shade }, function(x, y) return (x * 3 + y * 5) % 9 == 0 end)
  local col = c:poly{ { 27, 62 + b }, { 37, 62 + b }, { 32, 68 + b } } c:part(col, { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }, { nopop = true })
  c:put(32, 71 + b, P.gold.base) c:put(32, 75 + b, P.gold.base)
  -- star nose (tentacles flare on frame 4)
  local s, f = 56 + b, p.flare or 0
  local star = c:ellipse(32, s, 2, 1.5)
  for _, q in ipairs{ { -4, 0 }, { 4, 0 }, { -3, -2 }, { 3, -2 }, { -1, -3 }, { 1, -3 }, { -3, 2 }, { 3, 2 }, { -1, 3 }, { 1, 3 } } do
    local dx = q[1] + (q[1] < 0 and -f or (q[1] > 0 and f or 0))
    star:add(c:line({ { 32, s }, { 32 + dx, s + q[2] } }, 1))
  end
  c:part(star, "petal", { pop = { x = 31, y = s - 1 } })
  c:put(31, s, P.petal.deep) c:put(33, s, P.petal.deep)
  c:put(31, 61 + b, FUR.deep) c:put(32, 61 + b, FUR.deep) c:put(33, 61 + b, FUR.deep)
  -- tiny squinty eyes
  for _, x in ipairs{ 25, 38 } do
    if p.blink then c:put(x, 51 + b, P.ink) c:put(x + 1, 51 + b, P.ink)
    else c:fillMask(c:rect(x, 50 + b, x + 1, 51 + b), P.ink) c:put(x, 50 + b, P.cream) end
  end
  -- sleeves + big spade paws (right grips the spade)
  c:part(c:ellipse(20, 67 + b, 3, 4), "ember", { nopop = true })
  c:part(c:ellipse(44, 65 + b, 3, 3.5), "ember", { nopop = true })
  local lp = c:ellipse(19, 72 + b, 3.5, 3) c:part(lp, PAW, { pop = { x = 17, y = 70 + b } })
  for _, x in ipairs{ 17, 19, 21 } do c:put(x, 75 + b, CLAW) end
  local rp = c:ellipse(47.5, 66 + b, 3, 2.5) c:part(rp, PAW, { pop = { x = 46, y = 65 + b } })
  c:put(45, 67 + b, CLAW) c:put(45, 65 + b, CLAW)
  -- wide straw hat, red band
  local brim = c:ellipse(32, 44 + b, 18, 4.5)
  c:part(brim, "gold", { pop = { x = 17, y = 43 + b } }) under(c, brim, P.gold.deep)
  for x = 16, 48, 3 do local y = 44 + b + ((x < 22 or x > 42) and 0 or 2) if brim:has(x, y) then c:put(x, y, P.gold.shade) end end
  local cr = c:ellipse(32, 38 + b, 9, 6) cr:add(c:rect(23, 38 + b, 41, 43 + b))
  c:part(cr, "gold", { pop = { x = 27, y = 34 + b } })
  for x = 24, 40, 3 do c:put(x, 37 + b, P.gold.shade) end
  local band = c:rect(23, 41 + b, 41, 42 + b) c:part(band, "ember", { nopop = true })
  c:put(26, 41 + b, P.gold.hi) c:put(36, 41 + b, P.gold.hi)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local F = { { bob = 0 }, { bob = 1 }, { bob = 0 }, { bob = 0, blink = true, flare = 1 } }
local frames = {} for _, p in ipairs(F) do frames[#frames + 1] = frame(p) end
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }:save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite" }
print(NAME .. " ok")
