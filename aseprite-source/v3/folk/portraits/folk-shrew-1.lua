-- folk-shrew-1 portrait (folk F1_3) variant: 1
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

NAME = "folk-shrew-1"

R = {
  fur = { hi = "#b48c6c", base = "#8c6852", shade = "#604654", deep = "#3f2d3d" },
  belly = { hi = "#f0dcb8", base = "#d6b994", shade = "#ab8c80", deep = "#7a6070" },
  pink = { hi = "#f6bcb2", base = "#e2908e", shade = "#b2627a", deep = "#7e425e" },
  tail = { hi = "#9a7a66", base = "#7a5c4c", shade = "#56404e", deep = "#3a2a38" },
  cloth = { hi = "#b2cc7e", base = "#82a45a", shade = "#567858", deep = "#38524a" },
  straw = { hi = "#f4dc8e", base = "#dbb65c", shade = "#aa824c", deep = "#6e5040" },
  band = { hi = "#f08a7a", base = "#d05a5a", shade = "#9a3e56", deep = "#622c46" },
  wick = { hi = "#eab878", base = "#c48a52", shade = "#8c5e48", deep = "#5c3c3e" },
  leaf = { hi = "#bfe07a", base = "#7cb84a", shade = "#4c8448", deep = "#30583e" },
  carrot = { hi = "#ffb860", base = "#ee8436", shade = "#b85a3a", deep = "#7a3a36" },
  bg = { base = "#d2e6a0", shade = "#a8c67c", deep = "#7e9e64" },
}
R.arm = R.fur

-- gardener: straw hat (ears through the brim), sage dungarees with brass buttons, wicker basket of greens + carrot.
R.earsInHat = true
NECK = nil
BACK = function() end
CLOTHES = function(body)
  local m = U(body:copy():clip(c:rect(0, 90, 79, 99)), c:rrect(27, 78, 52, 99, 3),
    c:line({ { 30, 81 }, { 26, 78 } }, 3), c:line({ { 49, 81 }, { 53, 78 } }, 3))
  F(m, R.cloth, 29, 80, 2)
  F(c:rrect(33, 86, 46, 94, 1), R.cloth, nil, nil, 1)
  c:stitch{ { 34, 87 }, { 45, 87 } }
  F(c:rect(28, 80, 30, 82), R.straw, 28, 80, 1, false) F(c:rect(49, 80, 51, 82), R.straw, 49, 80, 1, false)
end
HAT = function()
  local brim = c:ellipse(39.5, 31, 28, 6.5)
  F(brim, R.straw, 16, 28, 2)
  local l = {}
  brim:each(function(x, y) if (x * 2 + y) % 5 == 0 then l[#l + 1] = { x, y } end end)
  dots(l, R.straw.shade)
  under(brim, R.straw.deep)
  EARS(29)
  local cr = c:ellipse(39.5, 24, 13, 9.5):clip(c:rect(0, 0, 79, 31))
  F(cr, R.straw, 31, 17, 2)
  l = {}
  cr:each(function(x, y) if (x + y * 2) % 5 == 0 and y < 27 then l[#l + 1] = { x, y } end end)
  dots(l, R.straw.shade)
  F(cr:copy():clip(c:rect(0, 27, 79, 30)), R.band, 28, 27, 1, false)
end
FRONT = function()
  F(U(c:poly{ { 11, 84 }, { 6, 70 }, { 15, 82 } }, c:poly{ { 14, 84 }, { 15, 66 }, { 19, 84 } }), R.leaf, 14, 69, 1)
  c:fillMask(c:line({ { 15, 82 }, { 15, 69 } }, 1), R.leaf.shade)
  F(c:line({ { 21, 85 }, { 26, 75 } }, 3), R.carrot, 24, 76, 1, false)
  dots({ { 23, 80 }, { 24, 78 } }, R.carrot.shade)
  F(U(c:poly{ { 26, 75 }, { 25, 69 }, { 28, 74 } }, c:poly{ { 26, 75 }, { 30, 70 }, { 28, 76 } }), R.leaf, nil, nil, 1, false)
  local bk = c:poly{ { 6, 84 }, { 29, 84 }, { 26, 99 }, { 9, 99 } }
  F(bk, R.wick, 9, 86, 2)
  local l = {}
  bk:each(function(x, y) if y % 3 == 0 or ((x + (y // 3) * 2) % 5 == 0) then l[#l + 1] = { x, y } end end)
  dots(l, R.wick.shade)
  local rim = c:rrect(5, 82, 30, 85, 1)
  F(rim, R.wick, 7, 82, 1, false)
  for x = 6, 29, 3 do c:put(x, 84, R.wick.shade) end
  F(c:ellipse(29, 84, 3, 2.5), R.pink, 28, 83, 1, false)
  dots({ { 28, 86 }, { 30, 86 } }, R.pink.shade)
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
