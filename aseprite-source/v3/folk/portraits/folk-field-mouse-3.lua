-- folk-field-mouse-3 portrait (folk F1_1) variant: 3
local NAME = "folk-field-mouse-3"
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
local FUR = { hi = "#e8a07c", base = "#bf6c48", shade = "#86464a", deep = "#542c42" }
local SMOCK = { hi = "#dcc8f4", base = "#a88ad4", shade = "#7462a8", deep = "#483c74" }
local APRON = { hi = "#fff2dc", base = "#f0dcc0", shade = "#c4a8a8", deep = "#866c84" }
local KER = { hi = "#fde08a", base = "#f0b84a", shade = "#b47a44", deep = "#6e4a44" }
local SOUP = { hi = "#ffc070", base = "#f08a3c", shade = "#c05a3c", deep = "#7e3a3e" }
local STRIPE = "#6a9ad8"
local V = { SLEEVE = SMOCK, BG = { base = "#f4bc94", shade = "#da9078", deep = "#ac665e" } }
local function dots(c, m, x0, y0)
  local l = {} m:each(function(x, y) if (x - x0) % 4 == 0 and (y - y0) % 3 == 0 and ((y - y0) // 3) % 2 == 0 or (x - x0 - 2) % 4 == 0 and (y - y0) % 3 == 0 and ((y - y0) // 3) % 2 == 1 then
    if m:has(x + 1, y) and m:has(x - 1, y) and m:has(x, y + 1) and m:has(x, y - 1) then l[#l + 1] = { x, y } end end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], P.cream) end
end
V.S = {
  clothes = function(c, p, b, body)
    F(c, body:copy(), SMOCK, 3)
    local a = c:rrect(26, 67 + b, 38, 86 + b, 2):clip(body) F(c, a, APRON, 2)
    for y = 68, 86 do for _, x in ipairs{ 29, 35 } do if a:has(x, y + b) then c:put(x, y + b, STRIPE) end end end
    for x = 29, 35 do c:put(x, 78 + b, APRON.shade) end
    F(c, c:line({ { 27, 67 + b }, { 25, 63 + b } }, 1), APRON, 1) F(c, c:line({ { 37, 67 + b }, { 39, 63 + b } }, 1), APRON, 1)
  end,
  head = function(c, p, b)
    local k = c:ellipse(32, 49 + b, 14, 12):clip(c:rect(0, 0, 63, 43 + b)) F(c, k, KER, 2) low(c, k, KER.deep) dots(c, k, 24, 38 + b)
    F(c, c:ellipse(46, 41 + b, 2, 2), KER, 1)
    F(c, c:poly{ { 47, 41 + b }, { 51, 38 + b + (p.pr or 0) }, { 51, 43 + b + (p.pr or 0) } }, KER, 1)
  end,
  prop = function(c, p, b)
    F(c, c:line({ { 45, 77 + b }, { 48, 63 + b } }, 2), METAL, 1)
    F(c, c:ellipse(49, 60 + b, 3.5, 2.5), METAL, 1)
    F(c, c:ellipse(49, 59.5 + b, 2, 1), SOUP, 1) c:put(48, 59 + b, SOUP.hi)
  end,
}
V.P = {
  clothes = function(c, body)
    F(c, body:copy(), SMOCK, 3)
    F(c, c:ellipse(39.5, 70, 11, 3), SMOCK, 1)
    local a = c:rrect(26, 79, 53, 99, 3):clip(body) F(c, a, APRON, 2)
    for y = 80, 99 do for _, x in ipairs{ 31, 35, 44, 48 } do if a:has(x, y) and c:get(x, y) ~= APRON.shade then c:put(x, y, STRIPE) end end end
    F(c, c:line({ { 28, 80 }, { 33, 70 } }, 2), APRON, 1) F(c, c:line({ { 51, 80 }, { 46, 70 } }, 2), APRON, 1)
    for x = 33, 46 do c:put(x, 88, APRON.shade) end for y = 88, 95 do c:put(33, y, APRON.shade) c:put(46, y, APRON.shade) end
  end,
  head = function(c)
    local k = c:ellipse(39.5, 52, 20, 17):clip(c:rect(0, 0, 79, 42)) F(c, k, KER, 2) low(c, k, KER.deep) dots(c, k, 25, 37)
    F(c, c:ellipse(59.5, 38, 3, 2.5), KER, 1)
    F(c, c:poly{ { 60, 37 }, { 67, 33 }, { 66, 39 } }, KER, 1) F(c, c:poly{ { 60, 39 }, { 67, 42 }, { 63, 45 } }, KER, 1)
  end,
  prop = function(c)
    F(c, c:line({ { 62, 99 }, { 65, 73 } }, 2), METAL, 1)
    F(c, c:ellipse(65.5, 70, 5, 3.5), METAL, 2)
    F(c, c:ellipse(65.5, 69.5, 3.5, 2), SOUP, 1) c:put(63, 69, SOUP.hi) c:put(64, 69, SOUP.hi)
    F(c, c:ellipse(62.5, 90, 3.5, 3), PAW, 1)
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
