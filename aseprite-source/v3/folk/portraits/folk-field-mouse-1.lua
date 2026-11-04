-- folk-field-mouse-1 portrait (folk F1_1) variant: 1
local NAME = "folk-field-mouse-1"
-- Field mouse villager: big round ears with pink lining, pointed cream muzzle, pink nose, whiskers, long thin tail.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") or "."
local out = app.params.out or (DIR .. "/")
local INK = "#2b1c26"
local EAR = { hi = "#f8c4c0", base = "#eb9a9e", shade = "#bc6c88", deep = "#7c4a66" }
local PAW = { hi = "#f8d0c0", base = "#e8a898", shade = "#b87888", deep = "#7a4a62" }
local TAIL = { hi = "#e8b8a8", base = "#c98e84", shade = "#94607a", deep = "#5e3e58" }
local CREAM = { hi = "#fff2de", base = "#f2dcba", shade = "#c8a898", deep = "#8a6c80" }
local NOSE = { hi = "#ffc0cc", base = "#e86c8c", shade = "#b04870", deep = "#6e2c50" }
local METAL = { hi = "#eef2f4", base = "#b8c2d0", shade = "#7a86a4", deep = "#4c5276" }
local function F(c, m, r, band) c:part(m, r, { band = band or 2, nopop = true }) return m end
local function low(c, m, hex) local l = {} m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do c:put(q[1], q[2], hex) end end
local function onCol(c, m, from, to, test) local l = {} m:each(function(x, y) if c:get(x, y) == from and (not test or test(x, y)) then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do c:put(q[1], q[2], to) end end
local FUR = { hi = "#ecc080", base = "#cf9450", shade = "#946048", deep = "#5c3c4a" }
local DUNG = { hi = "#b0d878", base = "#78b04c", shade = "#4a7c4c", deep = "#2e4e46" }
local STRAW = { hi = "#fbe6a0", base = "#e8c262", shade = "#b48a4c", deep = "#705446" }
local BAND = { hi = "#f08a7a", base = "#d85a52", shade = "#9c3c4c", deep = "#5e2a40" }
local WOOD = { hi = "#d8a070", base = "#a8704a", shade = "#74483e", deep = "#4a2e36" }
local V = { BG = { base = "#a9d08c", shade = "#80ae74", deep = "#5a8a62" } }
local function hat(c, cx, by, brx, bry, crx, cry, cyo)
  local brim = c:ellipse(cx, by, brx, bry) F(c, brim, STRAW, 2) low(c, brim, STRAW.deep)
  onCol(c, brim, STRAW.base, STRAW.shade, function(x, y) return (x + y * 2) % 5 == 0 end)
  local crown = c:ellipse(cx, by - cyo, crx, cry):clip(c:rect(0, 0, 79, by + 1)) F(c, crown, STRAW, 2)
  local bl = {} crown:each(function(x, y) if not crown:has(x, y + 1) or not crown:has(x, y + 2) then bl[#bl + 1] = { x, y } end end)
  for _, q in ipairs(bl) do c:put(q[1], q[2], q[1] > cx + crx * 0.4 and BAND.shade or BAND.base) end
  return crown
end
V.S = {
  clothes = function(c, p, b, body)
    local m = body:copy():clip(c:rect(0, 75 + b, 63, 95)) m:add(c:rrect(27, 67 + b, 37, 75 + b, 1)) F(c, m, DUNG, 2)
    F(c, c:line({ { 28, 68 + b }, { 24, 63 + b } }, 2), DUNG, 1) F(c, c:line({ { 36, 68 + b }, { 40, 63 + b } }, 2), DUNG, 1)
    c:put(28, 68 + b, STRAW.hi) c:put(36, 68 + b, STRAW.hi)
    for x = 30, 34 do c:put(x, 71 + b, DUNG.shade) end c:put(30, 72 + b, DUNG.shade) c:put(34, 72 + b, DUNG.shade)
  end,
  head = function(c, p, b)
    hat(c, 32, 40 + b, 16, 4.5, 8, 5, 3)
    c:put(38, 39 + b, P.cream) c:put(40, 39 + b, P.cream) c:put(39, 38 + b, P.cream) c:put(39, 40 + b, P.cream) c:put(39, 39 + b, STRAW.hi)
  end,
  prop = function(c, p, b)
    F(c, c:rect(45, 75 + b, 47, 81 + b), WOOD, 1)
    local bl = c:poly{ { 43, 74 + b }, { 49, 74 + b }, { 49, 68 + b }, { 46, 62 + b }, { 43, 68 + b } }
    F(c, bl, METAL, 2) c:put(44, 67 + b, METAL.hi) c:put(44, 68 + b, METAL.hi)
    c:put(47, 64 + b + (p.pr or 0), WOOD.shade) c:put(48, 65 + b, WOOD.shade)
  end,
}
V.P = {
  clothes = function(c, body)
    F(c, c:rrect(27, 80, 52, 99, 3):clip(body), DUNG, 2)
    F(c, c:line({ { 29, 82 }, { 24, 70 } }, 3):clip(body), DUNG, 1) F(c, c:line({ { 50, 82 }, { 55, 70 } }, 3):clip(body), DUNG, 1)
    for _, x in ipairs{ 29, 49 } do F(c, c:rect(x, 82, x + 1, 83), STRAW, 1) end
    c:stitch{ { 33, 89 }, { 46, 89 } }
    for y = 89, 96 do c:put(33, y, DUNG.shade) c:put(46, y, DUNG.shade) end for x = 33, 46 do c:put(x, 89, DUNG.shade) end
  end,
  head = function(c)
    hat(c, 39.5, 35, 26, 6.5, 13, 9, 5)
    for _, q in ipairs{ { 48, 30 }, { 50, 30 }, { 49, 29 }, { 49, 31 } } do c:put(q[1], q[2], P.cream) end c:put(49, 30, STRAW.hi)
  end,
  prop = function(c)
    F(c, c:rect(60, 84, 63, 97), WOOD, 1)
    F(c, c:poly{ { 57, 83 }, { 66, 83 }, { 66, 74 }, { 61.5, 64 }, { 57, 74 } }, METAL, 2)
    for y = 70, 79 do c:put(59, y, METAL.hi) end
    F(c, c:ellipse(64, 68, 1.5, 1.5), WOOD, 1)
    F(c, c:ellipse(61.5, 87, 4, 3), PAW, 1)
  end,
}
local PV = V.P
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
if PV.back then PV.back(c) end
local body = c:ellipse(39.5, 102, 28, 34):clip(c:rect(0, 0, 79, 99)) F(c, body, FUR, 3)
F(c, c:ellipse(39.5, 100, 12, 20):clip(body), CREAM, 2)
if PV.clothes then PV.clothes(c, body) end
for _, e in ipairs{ { 18, -1 }, { 61, 1 } } do
  F(c, c:ellipse(e[1], 30, 11, 10.5), FUR, 2)
  F(c, c:ellipse(e[1] - e[2] * 0.5, 31.5, 7.5, 7), EAR, 2)
end
local head = c:ellipse(39.5, 52, 20, 17)
head:add(c:ellipse(21, 59, 3, 3)) head:add(c:ellipse(58, 59, 3, 3))
F(c, head, FUR, 3)
for _, q in ipairs{ { 27, 38 }, { 28, 38 }, { 26, 39 }, { 31, 37 }, { 23, 42 } } do c:put(q[1], q[2], FUR.hi) end
F(c, c:ellipse(39.5, 61, 8, 5.5), CREAM, 2)
F(c, c:ellipse(39.5, 57, 3, 2), NOSE, 1) c:put(38, 56, NOSE.hi) c:put(37, 56, NOSE.hi)
for _, q in ipairs{ { 39, 60 }, { 40, 60 }, { 36, 61 }, { 37, 62 }, { 38, 62 }, { 39, 61 }, { 40, 61 }, { 41, 62 }, { 42, 62 }, { 43, 61 } } do c:put(q[1], q[2], INK) end
c:eyeLocked(28, 47) c:eyeLocked(47, 47)
for _, x in ipairs{ 23, 54 } do for dx = 0, 2 do c:put(x + dx, 57, EAR.base) c:put(x + dx, 58, EAR.base) end c:put(x, 57, EAR.hi) end
if PV.head then PV.head(c) end
if PV.prop then PV.prop(c) end
c:finish{ outline = true }
for _, w in ipairs{ { 31, 60, 14, 57 }, { 31, 62, 14, 65 }, { 48, 60, 65, 57 }, { 48, 62, 65, 65 } } do
  c:fillMask(c:line({ { w[1], w[2] }, { w[3], w[4] } }, 1), FUR.deep)
end
backdrop(V.BG)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")
