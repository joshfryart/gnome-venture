-- npc-marigold-puddleby sprite (npc2 P1_21) species: frog
-- Marigold Puddleby: plump cheerful pond frog, blue raincoat, wildflower crown; prop: waterlily umbrella.
-- 64x96 cell, feet baseline y=90, idle(4): base / breath+umbrella settles / base / blink.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local NAME = "npc-marigold-puddleby"
local function kp(c, x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function under(c, m, hex) local l = {} m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do kp(c, q[1], q[2], hex) end end
local function flower(c, x, y, pet, mid) for _, d in ipairs{ {0,-1},{-1,0},{1,0},{0,1} } do c:put(x + d[1], y + d[2], pet) end c:put(x, y, mid) end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.b or 0
  local u = b + (p.u or 0)
  c:groundShadow(31.5, 89.5, 14, 2.5)
  -- raincoat: squat bell, flared hem, centre seam, gold toggles
  local coat = c:ellipse(31.5, 76 + b, 12.5, 9.5)
  coat:add(c:poly{ {20, 78 + b}, {43, 78 + b}, {46, 87}, {17, 87} })
  c:part(coat, P.sea, { band = 2, pop = { 23, 70 + b } })
  under(c, coat, P.sea.deep)
  for y = 73 + b, 87 do kp(c, 31, y, P.sea.deep) end
  for _, ty in ipairs{ 75, 80 } do
    c:put(32, ty + b, P.gold.hi) c:put(33, ty + b, P.gold.base) c:put(32, ty + b + 1, P.gold.base) c:put(33, ty + b + 1, P.gold.shade)
  end
  local sl = c:ellipse(18.5, 76 + b, 3, 4.5) c:part(sl, P.sea, { band = 1, nopop = true }) under(c, sl, P.sea.deep)
  local sr = c:ellipse(44.5, 75 + b, 3, 4.5) c:part(sr, P.sea, { band = 1, nopop = true }) under(c, sr, P.sea.deep)
  -- umbrella stalk (behind head)
  c:part(c:line({ {45, 80 + b}, {47, 58 + u}, {49, 36 + u} }, 1), P.wood, { noshade = true, nopop = true, inner = false })
  -- wide frog head
  local head = c:ellipse(31.5, 58 + b, 15.5, 10.5)
  c:part(head, P.moss, { band = 2, pop = { 21, 51 + b } })
  local thr = c:ellipse(31.5, 67 + b, 9, 2.5):clip(head)
  thr:each(function(x, y) if x < 36 and c:get(x, y) == P.moss.base then kp(c, x, y, P.moss.hi) end end)
  for _, s in ipairs{ {20, 55}, {42, 53}, {24, 64}, {39, 65} } do kp(c, s[1], s[2] + b, P.moss.shade) kp(c, s[1] + 1, s[2] + b, P.moss.shade) end
  c:line({ {18, 59 + b}, {22, 62 + b}, {31, 63 + b}, {41, 62 + b}, {45, 59 + b} }, 1):each(function(x, y) kp(c, x, y, P.moss.deep) end)
  kp(c, 30, 57 + b, P.moss.hi) kp(c, 33, 57 + b, P.moss.hi) kp(c, 30, 58 + b, P.moss.deep) kp(c, 33, 58 + b, P.moss.deep)
  c:cheek(17, 60 + b) c:cheek(45, 60 + b)
  -- eye domes on top of the head
  for _, ex in ipairs{ 24, 39 } do
    local d = c:ellipse(ex, 48 + b, 5.5, 4.5)
    c:part(d, P.moss, { band = 1, pop = { ex - 4, 45 + b }, sep = true })
    local x0, y0 = ex - 2, 46 + b
    if p.blink then
      for i = 0, 4 do c:put(x0 + i, y0 + 1, P.moss.shade) c:put(x0 + i, y0 + 2, P.ink) end
      c:put(x0, y0 + 3, P.ink) c:put(x0 + 4, y0 + 3, P.ink)
    else c:eyeLocked(x0, y0) end
  end
  -- wildflower crown
  c:line({ {17, 56 + b}, {24, 54 + b}, {31, 53 + b}, {39, 54 + b}, {46, 56 + b} }, 1):each(function(x, y) kp(c, x, y, P.moss.deep) end)
  flower(c, 19, 55 + b, P.petal.base, P.gold.hi)
  flower(c, 26, 54 + b, P.gold.base, P.cream)
  flower(c, 32, 53 + b, P.dusk.hi, P.gold.base)
  flower(c, 38, 54 + b, P.petal.base, P.gold.hi)
  flower(c, 44, 55 + b, P.gold.base, P.cream)
  -- hands
  c:part(c:ellipse(18.5, 81 + b, 2, 2), P.moss, { band = 1, nopop = true })
  c:part(c:ellipse(45, 80 + b, 2, 2), P.moss, { band = 1, pop = { 44, 79 + b } })
  -- waterlily umbrella canopy with scalloped rim
  local can = c:ellipse(49, 34 + u, 10.5, 3.5)
  can:add(c:ellipse(49, 32 + u, 8, 4):clip(c:rect(0, 0, 63, 33 + u)))
  for _, sx in ipairs{ 40, 44, 49, 54, 58 } do can:add(c:ellipse(sx, 37 + u, 1.5, 1.5)) end
  c:part(can, P.petal, { band = 2, pop = { 44, 30 + u } })
  under(c, can, P.petal.deep)
  for _, r in ipairs{ {43, 36}, {49, 37}, {55, 36} } do
    c:line({ {49, 29 + u}, {r[1], r[2] + u} }, 1):each(function(x, y) if c:get(x, y) ~= P.petal.deep then kp(c, x, y, P.petal.shade) end end)
  end
  c:put(49, 27 + u, P.gold.base) c:put(49, 28 + u, P.gold.shade)
  -- webbed feet (fixed)
  for _, fx in ipairs{ 24, 39 } do
    local f = c:ellipse(fx, 89, 4.5, 1.5)
    c:part(f, P.moss, { band = 1, pop = { fx - 3, 88 } })
    under(c, f, P.moss.deep)
    kp(c, fx - 1, 89, P.moss.deep) kp(c, fx + 2, 89, P.moss.deep)
  end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local fr = {}
for _, p in ipairs{ {}, { b = 1, u = 1 }, {}, { blink = true } } do fr[#fr + 1] = frame(p) end
HP.report(fr[1])
HP.sheet{ cellw = 64, cellh = 96, frames = fr, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
