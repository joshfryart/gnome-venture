-- folk-shrew-3 portrait (folk F1_3) variant: 3
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

NAME = "folk-shrew-3"

R = {
  fur = { hi = "#c89c74", base = "#a07456", shade = "#704e5a", deep = "#48323f" },
  belly = { hi = "#f4e2c0", base = "#dcc09a", shade = "#b09080", deep = "#806474" },
  pink = { hi = "#f8c0b6", base = "#e69494", shade = "#b4667e", deep = "#804660" },
  tail = { hi = "#ac8466", base = "#86604e", shade = "#5e4452", deep = "#3e2c3a" },
  smock = { hi = "#d88ea4", base = "#b0607e", shade = "#7e4266", deep = "#52304e" },
  apron = { hi = "#fbf0d6", base = "#ecdcbc", shade = "#c6b09c", deep = "#92807c" },
  scarf = { hi = "#8ed6c2", base = "#52aa9a", shade = "#3c7c7e", deep = "#2c525a" },
  wood = { hi = "#ecc08a", base = "#c8915a", shade = "#90604a", deep = "#5c3e3c" },
  soup = { hi = "#ffc870", base = "#f0a040", shade = "#c8702e", deep = "#8a4a30" },
  bg = { base = "#a8e2d2", shade = "#78c2b2", deep = "#56998e" },
}
R.arm = R.smock

-- cook: teal polka-dot headscarf with a top knot (ears poke through), plum smock, cream apron, wooden soup ladle.
R.earsInHat = true
NECK = nil
BACK = function()
  F(c:line({ { 57, 99 }, { 62, 62 }, { 65, 46 } }, 3), R.wood, 61, 66, 1, false)
  local bowl = c:ellipse(66.5, 41, 7, 5)
  F(bowl, R.wood, 62, 38, 2)
  under(bowl, R.wood.deep)
  F(c:ellipse(66.5, 39.5, 5, 2.5), R.soup, 64, 38, 1, false)
  dots({ { 72, 46 }, { 72, 47 } }, R.soup.base)
end
CLOTHES = function(body)
  F(body, R.smock, 18, 82, 2)
  for x = 12, 68, 3 do if body:has(x, 80) then c:put(x, 80, R.smock.shade) end end
  local ap = U(c:rrect(27, 80, 52, 99, 3), c:line({ { 29, 81 }, { 33, 74 } }, 2), c:line({ { 50, 81 }, { 46, 74 } }, 2))
  F(ap, R.apron, 29, 81, 2)
  F(c:rrect(34, 88, 45, 95, 1), R.apron, nil, nil, 1)
  c:stitch{ { 35, 89 }, { 44, 89 } }
end
HAT = function()
  local sc = c:ellipse(39.5, 46, 21, 18):clip(c:rect(0, 0, 79, 36))
  F(sc, R.scarf, 28, 31, 2)
  under(sc, R.scarf.deep)
  local l = {}
  for gy = 30, 35, 4 do for gx = 22 + (gy % 8 == 2 and 3 or 0), 57, 6 do
    for _, d in ipairs{ { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } } do if sc:has(gx + d[1], gy + d[2]) and sc:has(gx + d[1], gy + d[2] + 1) then l[#l + 1] = { gx + d[1], gy + d[2] } end end
  end end
  dots(l, R.scarf.hi)
  local lob = U(c:ellipse(33, 25, 6, 3.5), c:ellipse(46, 25, 6, 3.5))
  F(lob, R.scarf, 29, 23, 1)
  F(c:ellipse(39.5, 27.5, 3, 2.5), R.scarf, 38, 26, 1, false)
  dots({ { 38, 27 }, { 41, 28 } }, R.scarf.deep)
  EARS(32)
end
FRONT = function()
  F(c:ellipse(60, 80, 3, 2.5), R.pink, 59, 79, 1, false)
  dots({ { 58, 82 }, { 60, 82 } }, R.pink.shade)
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
