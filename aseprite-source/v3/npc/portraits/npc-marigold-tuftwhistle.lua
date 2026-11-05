-- npc-marigold-tuftwhistle portrait (npc2 P1_21) species: hedgehog
-- 80x100 head+shoulders: spiky quill crown, tan face with eye patches + locked eyes, pointed snout with button nose,
-- red jumper + cream collar bleeding off the bottom, brass tin whistle on a cord at the chest. Moss backdrop disc.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local NAME = "npc-marigold-tuftwhistle"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function R(v) return math.floor(v + 0.5) end
local function kp(x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local FACE = { hi = P.cream, base = P.skinA.hi, shade = P.skinA.base, deep = P.skinA.shade }
local CR = { hi = P.cream, base = P.cream, shade = P.skinA.hi, deep = P.skinA.shade }
local NOSE = { hi = P.wood.shade, base = P.wood.deep, shade = P.skinC.deep, deep = P.skinC.deep }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end

-- quill crown
local cy = 47
local Q = c:ellipse(39.5, cy, 21.5, 19.5)
local tips = {}
for a = 150, 390, 12 do
  local r = math.rad(a)
  local ux, uy = math.cos(r), math.sin(r)
  local tx, ty = -uy, ux
  local len = ((a // 12) % 2 == 0) and 8 or 6
  local bx, by = 39.5 + ux * 18.5, cy + uy * 16.5
  local ex, ey = 39.5 + ux * (21.5 + len), cy + uy * (19.5 + len)
  Q:add(c:poly{ { R(bx + tx * 3.5), R(by + ty * 3.5) }, { R(bx - tx * 3.5), R(by - ty * 3.5) }, { R(ex), R(ey) } })
  tips[#tips + 1] = { bx, by, ex, ey }
end
c:part(Q, P.wood, { band = 3, pop = { 24, 34 } })
for _, t in ipairs(tips) do
  c:line({ { R(t[1]), R(t[2]) }, { R(t[3] - (t[3] - t[1]) * 0.15), R(t[4] - (t[4] - t[2]) * 0.15) } }, 1)
    :each(function(x, y) if Q:has(x, y) then kp(x, y, P.wood.deep) end end)
end
for y = 26, 66, 4 do for x = 18 + (y % 8 == 2 and 3 or 0), 60, 6 do
  if Q:has(x, y) and Q:has(x + 1, y - 1) and Q:has(x + 2, y) then
    kp(x, y, P.wood.shade) kp(x + 1, y - 1, P.wood.shade) kp(x + 2, y, P.wood.shade)
    if x < 40 and y < 46 then kp(x + 1, y, P.wood.hi) end
  end
end end
-- jumper + collar + chin ruff
local sw = c:ellipse(39.5, 100, 33, 27):clip(c:rect(0, 0, 79, 99))
c:part(sw, P.ember, { band = 3, pop = { 15, 88 } })
for y = 82, 99 do kp(22 + (y % 2), y, P.ember.shade) kp(57 - (y % 2), y, P.ember.shade) end
c:part(c:ellipse(39.5, 71, 13, 5), FACE, { band = 1, nopop = true })
c:part(c:poly{ {28, 75}, {51, 75}, {39.5, 85} }, CR, { band = 1, sep = true, pop = { 31, 76 } })
-- ears
for _, ex in ipairs{ 24, 55 } do
  c:part(c:ellipse(ex, 45, 3.5, 3.5), FACE, { band = 1, nopop = true })
  kp(ex, 45, P.petal.shade) kp(ex, 46, P.petal.shade)
end
-- face
local face = c:ellipse(39.5, 56, 15, 12.5)
c:part(face, FACE, { band = 3, pop = { 28, 47 } })
local DR = { 2, 3, 1, 3, 2, 4, 2, 3, 1, 3 }
local i = 0
for x = 26, 53, 3 do
  i = i + 1
  for y = 40, 60 do if face:has(x, y) then
    for k = 0, DR[i] - 1 do kp(x, y + k, P.wood.base) kp(x + 1, y + k, k == DR[i] - 1 and P.wood.shade or P.wood.base) end
    break end end
end
for _, ex in ipairs{ 33, 46 } do c:ellipse(ex, 53, 4, 3.5):clip(face):each(function(x, y) kp(x, y, P.skinA.base) end) end
c:eyeLocked(31, 51) c:eyeLocked(44, 51)
-- snout + button nose + tiny w mouth
c:part(c:ellipse(39.5, 62, 5.5, 4), FACE, { band = 1, sep = true, pop = { 36, 60 } })
c:part(c:ellipse(39.5, 64.5, 3, 2), NOSE, { band = 1, nopop = true })
c:put(38, 63, P.cream)
for _, q in ipairs{ {36, 67}, {37, 68}, {38, 68}, {39, 67}, {40, 67}, {41, 68}, {42, 68}, {43, 67} } do kp(q[1], q[2], P.skinA.shade) end
c:paint({ "PPP", "PPP" }, 25, 59, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 52, 59, { P = "petal.base" })
c:put(25, 59, P.petal.hi) c:put(52, 59, P.petal.hi)
-- whistle on a cord
c:line({ {30, 77}, {34, 85} }, 1):each(function(x, y) c:put(x, y, P.gold.deep) end)
c:line({ {49, 77}, {45, 85} }, 1):each(function(x, y) c:put(x, y, P.gold.deep) end)
c:part(c:rrect(33, 86, 45, 89, 1), P.gold, { band = 1, pop = { 34, 86 } })
c:part(c:rect(46, 87, 49, 88), P.gold, { band = 1, sep = true, nopop = true })
kp(37, 87, P.wood.deep) kp(38, 87, P.wood.deep) kp(41, 87, P.gold.deep)
c:finish{ outline = true }
backdrop(P.moss)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
