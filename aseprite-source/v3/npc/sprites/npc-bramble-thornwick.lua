-- npc-bramble-thornwick sprite (npc2 P1_4) species: hedgehog
-- Bramble Thornwick: prickly hedgehog in a tilted blue beret, hugging a basket of blackberries. idle x4.
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
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.bob or 0
  c:groundShadow(32, 89, 14, 2.5)
  for _, x in ipairs{ 27, 37 } do local m = c:ellipse(x, 88.5, 3, 1.5) c:part(m, "wood", { pop = { x = x - 2, y = 88 } }) under(c, m, P.wood.deep) end
  -- body: quill cloak with side spikes, cream belly
  local body = c:ellipse(32, 72 + b, 14, 14)
  for _, d in ipairs{ 150, 165, 180, 195, 210, 330, 345, 0, 15, 30 } do spike(c, body, 32, 72 + b, d, 12, 12, 18, 16, 2.2) end
  c:part(body, QU, { pop = { x = 20, y = 64 + b } })
  HH.texture(c, body, 32, 70 + b, 14, 13, QU)
  under(c, body, QU.deep)
  local belly = c:ellipse(32, 75 + b, 9, 10)
  c:part(belly, FC, { pop = { x = 27, y = 68 + b } })
  HH.head(c, { cx = 32, cy = 46 + b, s = 1, SP = QU, FACE = FC, blink = p.blink })
  -- basket of blackberries hugged in front
  local bk = c:rrect(25, 78 + b, 39, 85 + b, 2)
  c:part(bk, "wood", { pop = { x = 26, y = 79 + b } })
  hatch(c, bk, { [P.wood.base] = P.wood.shade }, function(x, y) return (x + (y % 2) * 2) % 4 == 0 and y > 79 + b end)
  under(c, bk, P.wood.deep)
  for _, q in ipairs{ { 28, 76 }, { 32, 75 }, { 36, 76 } } do
    local m = c:ellipse(q[1], q[2] + b, 2, 2) c:part(m, BER, { pop = { x = q[1] - 1, y = q[2] - 1 + b } })
  end
  c:fillMask(c:poly{ { 33, 73 + b }, { 37, 72 + b }, { 36, 74 + b } }, P.moss.base) c:put(34, 73 + b, P.moss.hi)
  local rim = c:rrect(24, 77 + b, 40, 78 + b, 1) c:part(rim, "wood", { nopop = true }) for x = 25, 31 do c:put(x, 77 + b, P.wood.hi) end
  for _, x in ipairs{ 23, 41 } do c:part(c:ellipse(x, 79 + b, 2, 2), FC, { nopop = true }) end
  -- tilted beret with nub (nub settles late)
  local bm = c:ellipse(31, 33 + b, 12, 4)
  bm:add(c:ellipse(29, 31 + b, 9, 3.5)) bm:add(c:ellipse(20, 35 + b, 3, 2))
  c:part(bm, "sea", { pop = { x = 23, y = 30 + b } })
  under(c, bm, P.sea.deep)
  c:stitch{ { 22, 35 + b }, { 41, 35 + b } }
  local n = p.nub or 0
  c:part(c:rect(30, 26 + b + n, 32, 28 + b), "sea", { nopop = true }) c:put(30, 26 + b + n, P.sea.hi)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local F = { { bob = 0 }, { bob = 1, nub = 1 }, { bob = 0 }, { bob = 0, blink = true, ear = -1 } }
local frames = {} for _, p in ipairs(F) do frames[#frames + 1] = frame(p) end
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }:save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite" }
print(NAME .. " ok")
