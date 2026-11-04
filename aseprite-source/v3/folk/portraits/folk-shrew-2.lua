-- folk-shrew-2 portrait (folk F1_3) variant: 2
-- Hearth Pop v3 generic rest-stop shrew villager portrait, 80x100, head+shoulders, backdrop disc.

local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME, R, BACK, CLOTHES, NECK, HAT, FRONT
local c
local function F(m, r, px, py, band, inner)
  c:part(m, r, { band = band or 2, pop = px and { x = px, y = py } or nil, nopop = (px == nil), inner = inner })
  return m
end
local function U(...) local a = { ... } local m = a[1] for i = 2, #a do m:add(a[i]) end return m end
local function under(m, hex)
  local l = {}
  m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], hex) end
end
local function dots(list, hex) for _, q in ipairs(list) do c:put(q[1], q[2], hex) end end
local function EARS(y)
  for i, ex in ipairs{ 22, 57 } do
    F(c:ellipse(ex, y, 5, 5), R.fur, i == 1 and ex - 3 or nil, y - 3, 1, false)
    F(c:ellipse(ex + (i == 1 and 0.5 or -0.5), y + 0.5, 2.5, 2.5), R.pink, nil, nil, 1, false)
  end
end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end

NAME = "folk-shrew-2"

R = {
  fur = { hi = "#a89c98", base = "#7e7280", shade = "#585068", deep = "#3a344a" },
  belly = { hi = "#e6dcd0", base = "#c8bab0", shade = "#9a8a94", deep = "#6c5e70" },
  pink = { hi = "#f2b4b4", base = "#d88892", shade = "#a85e7a", deep = "#74405c" },
  tail = { hi = "#968a90", base = "#6c6070", shade = "#4c445a", deep = "#332e40" },
  scarf = { hi = "#f6bc66", base = "#dc8a3e", shade = "#a45a40", deep = "#683846" },
  coat = { hi = "#7c9ed0", base = "#5272a2", shade = "#3c4e7c", deep = "#2e3658" },
  cap = { hi = "#c8b07a", base = "#9c8456", shade = "#6c5a4c", deep = "#463a3e" },
  pack = { hi = "#d8c088", base = "#b0945e", shade = "#7c6450", deep = "#4e3e3e" },
  roll = { hi = "#e88a80", base = "#c05a5c", shade = "#8a3e52", deep = "#5a2c42" },
  brass = { hi = "#f8dc90", base = "#d4a44c", shade = "#9a6c44", deep = "#5e4238" },
  glow = { hi = "#fff0b2", base = "#ffd068", shade = "#eca24a", deep = "#c8703a" },
  bg = { base = "#f7cf8a", shade = "#e0a868", deep = "#b47e52" },
}
R.arm = R.coat

-- traveller: tweed flat cap, mustard fringed scarf, indigo coat, bedroll pack, glowing brass lantern.
R.earsInHat = false
R.earY = 36
BACK = function()
  local roll = c:rrect(5, 68, 74, 80, 5)
  F(roll, R.roll, 8, 70, 2)
  for _, x in ipairs{ 16, 63 } do for y = 68, 80 do c:put(x, y, R.pack.shade) end end
  dots({ { 7, 73 }, { 8, 72 }, { 9, 73 }, { 8, 75 }, { 72, 73 }, { 71, 72 }, { 70, 73 }, { 71, 75 } }, R.roll.deep)
  F(c:rrect(9, 78, 70, 99, 6), R.pack, 12, 80, 2)
end
CLOTHES = function(body)
  F(body, R.coat, 18, 82, 2)
  c:fillMask(c:line({ { 34, 78 }, { 39, 99 } }, 1), R.coat.deep)
  c:fillMask(c:line({ { 45, 78 }, { 40, 99 } }, 1), R.coat.shade)
  for _, y in ipairs{ 86, 93 } do F(c:rect(41, y, 43, y + 1), R.brass, 41, y, 1, false) end
  F(c:line({ { 24, 79 }, { 22, 99 } }, 3), R.pack, 23, 80, 1, false)
  F(c:line({ { 55, 79 }, { 57, 99 } }, 3), R.pack, nil, nil, 1, false)
  F(c:rect(21, 89, 25, 91), R.brass, 21, 89, 1, false)
end
NECK = function()
  local sc = c:rrect(22, 64, 57, 76, 4)
  F(sc, R.scarf, 24, 65, 2)
  for x = 25, 55, 3 do c:fillMask(c:rect(x, 67, x, 74), R.scarf.shade) end
  local tail = c:poly{ { 25, 72 }, { 33, 73 }, { 31, 93 }, { 23, 93 } }
  F(tail, R.scarf, 25, 74, 2, false)
  for i = 0, 8, 2 do c:put(23 + i, 93, R.scarf.deep) end
  for y = 78, 90, 4 do c:fillMask(c:line({ { 25, y }, { 31, y } }, 1):clip(tail), R.scarf.shade) end
end
HAT = function()
  local cap = c:ellipse(39.5, 46, 21, 18):clip(c:rect(0, 0, 79, 35))
  F(cap, R.cap, 28, 31, 2)
  local l = {}
  cap:each(function(x, y) if (x + y) % 4 == 0 and (x - y) % 3 == 0 then l[#l + 1] = { x, y } end end)
  dots(l, R.cap.shade)
  local peak = c:ellipse(39.5, 36, 14, 3)
  F(peak, R.cap, 30, 34, 1, false)
  under(peak, R.cap.deep)
  dots({ { 39, 29 }, { 40, 29 } }, R.cap.deep)
end
FRONT = function()
  F(c:line({ { 57, 75 }, { 58, 71 }, { 61, 69 }, { 64, 71 }, { 65, 75 } }, 1), R.brass, nil, nil, 1, false)
  F(c:poly{ { 56, 75 }, { 66, 75 }, { 68, 78 }, { 54, 78 } }, R.brass, 57, 75, 1, false)
  c:fillMask(c:rect(55, 79, 67, 90), R.glow.base)
  c:fillMask(c:rrect(58, 81, 64, 88, 1), R.glow.hi)
  c:fillMask(U(c:rect(66, 79, 66, 90), c:rect(56, 90, 66, 90)), R.glow.shade)
  F(c:ellipse(61, 85, 1.5, 2.5), R.glow, nil, nil, 1, false)
  dots({ { 61, 83 } }, R.glow.deep) dots({ { 61, 85 }, { 61, 86 } }, R.glow.shade)
  for y = 79, 90 do c:put(55, y, R.brass.shade) c:put(67, y, R.brass.deep) end
  F(c:rect(54, 91, 68, 93), R.brass, 55, 91, 1, false)
  F(c:ellipse(61, 70, 3, 2.5), R.pink, 60, 69, 1, false)
end

c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
BACK()
local body = c:ellipse(39.5, 104, 31, 29):clip(c:rect(0, 74, 79, 99))
F(body, R.fur, 16, 84, 2)
CLOTHES(body)
F(c:rect(32, 60, 47, 77), R.fur, nil, nil, 1, false)
if NECK then NECK() end
local hcx, hcy, hrx, hry = 39.5, 46, 20, 17
local head = c:ellipse(hcx, hcy, hrx, hry)
for _, a in ipairs{ 150, 165, 180, 0, 15, 30 } do
  local r = math.rad(a)
  head:add(HP.ellipse(hcx + math.cos(r) * (hrx - 0.5), hcy + math.sin(r) * (hry - 0.5), 1.5, 1.5))
end
F(head, R.fur, 26, 35, 3)
for _, s in ipairs{ { 30, 34, 31, 32 }, { 36, 32, 37, 30 }, { 42, 32, 43, 30 }, { 48, 34, 49, 32 }, { 25, 38, 26, 36 }, { 53, 38, 54, 36 }, { 22, 47, 23, 45 } } do
  local l = {}
  c:line({ { s[1], s[2] }, { s[3], s[4] } }, 1):clip(head):each(function(x, y) l[#l + 1] = { x, y } end)
  dots(l, R.fur.hi)
end
for _, s in ipairs{ { 55, 50 }, { 52, 56 }, { 27, 57 } } do dots({ { s[1], s[2] }, { s[1], s[2] + 1 } }, R.fur.shade) end
-- long tapering shrew snout, lit ridge, pink bulb nose with nostrils
local sn = U(c:poly{ { 31, 50 }, { 48, 50 }, { 43.5, 66 }, { 35.5, 66 } }, c:ellipse(39.5, 51, 9, 5))
F(sn, R.fur, 35, 48, 2, false)
for y = 52, 63 do dots({ { 38, y } }, R.fur.hi) end
under(sn, R.fur.deep)
F(c:ellipse(39.5, 66.5, 3.5, 2.5), R.pink, 38, 65, 1, false)
dots({ { 38, 67 }, { 41, 67 } }, R.pink.deep)
dots({ { 36, 70 }, { 37, 71 }, { 38, 71 }, { 41, 71 }, { 42, 71 }, { 43, 70 } }, R.fur.deep)
dots({ { 39, 71 }, { 40, 71 } }, R.pink.shade)
-- whiskers
for _, w in ipairs{ { 33, 57, 27, 55 }, { 33, 59, 29, 60 }, { 46, 57, 52, 55 }, { 46, 59, 50, 60 } } do
  c:fillMask(c:line({ { w[1], w[2] }, { w[3], w[4] } }, 1), R.fur.deep)
end
c:eyeLocked(27, 40) c:eyeLocked(48, 40)
dots({ { 22, 49 }, { 23, 49 }, { 24, 49 }, { 22, 50 }, { 23, 50 }, { 24, 50 }, { 55, 49 }, { 56, 49 }, { 57, 49 }, { 55, 50 }, { 56, 50 }, { 57, 50 } }, R.pink.base)
dots({ { 22, 49 }, { 55, 49 } }, R.pink.hi)
if not R.earsInHat then EARS(R.earY or 31) end
HAT()
FRONT()
c:finish{ outline = true }
backdrop(R.bg)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")
