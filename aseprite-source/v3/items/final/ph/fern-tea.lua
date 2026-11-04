-- fern-tea (B31, Opus single pass). A low, wide ceramic teacup (cream glaze, a moss-green glazed band and a green
-- rim line) with a slim ring handle, on a matching saucer. Inside, clear amber-green fern tea with a dark inner rim
-- shadow and one bright glint. A young fern frond (rachis + alternating pinnae, curled tip) leans out of the cup
-- like a stirrer, its foot dipped in the tea. Ceramic: per-pixel light, foot-ring ambient shade, cool bounce on the
-- saucer, contact shadow under the cup. Ground shadow.
-- quirk: the curl of steam winds up into a little fiddlehead spiral.
local NAME = "fern-tea"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_1.lua")
local HP, X, K, P = G.HP, G.X, G.K, G.P
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new(NAME)

local CER  = { "#6e5a72", "#9c8a98", "#c9b8b2", "#e8d8c4", "#f8ecd6", "#fff8ec" }
local BAND = { "#24544a", "#2e7246", "#3f9150", "#5aab56", "#7cc35a", "#a8d878" }
local TEA  = { "#3a3416", "#5a5220", "#7e7228", "#a8962e", "#c8b448", "#e8d880" }
local FERN = { "#163a38", "#1f5644", "#2b744c", "#43944f", "#6cb45a", "#a2d274" }
local STEAM, STEAMSH = "#e4f6ff", "#b9e2f5"
local COOL = "#a8b4d8"

c:groundShadow(31, 58, 23, 1)

-- saucer: shallow dish, wide ellipse with a sunken well
local sau = HP.ellipse(31, 53, 24, 4.5)
local sn = X.pillow(sau, 3, 0.8)
local stok = { r = { name = "saucer" } }
local sidx = G.shade(c, sau, sn, CER, { tok = stok, amb = 0.25, wrap = 0.4 })
local well = HP.ellipse(31, 52.5, 15, 2.5)
well:each(function(x, y) c:put(x, y, (y <= 51) and CER[3] or CER[4], stok) end)
-- green rim line on the saucer front edge, cool bounce underneath
sau:edge():each(function(x, y) if y >= 55 then c:put(x, y, x < 31 and BAND[4] or BAND[2], stok) end end)
for x = 12, 50 do if sau:has(x, 56) and not sau:has(x, 57) then c:put(x, 56, COOL, stok) end end

-- cup body: bowl that narrows from the rim (y 33) to the foot (y 49)
local rimY = 32
local function hw(y)
  local t = (y - rimY) / (49 - rimY)
  return 15.4 - 5.5 * t ^ 1.8
end
local cup = HP.mask()
for y = rimY, 49 do local w = hw(y) for x = floor(31 - w + .5), floor(31 + w + .5) do cup:set(x, y) end end
cup:add(HP.ellipse(31, rimY, 15.4, 3.6):clip(HP.rect(0, rimY, 63, 63)))
cup:add(HP.rect(25, 49, 37, 51))   -- foot ring
local cn = {}
cup:each(function(x, y) local w = y <= 49 and hw(min(49, max(rimY, y))) or 6.5
  local t = max(-.96, min(.96, (x + .5 - 31.5) / (w + .5)))
  local ny = y <= 49 and 0.35 * (y - rimY) / 17 or 0.2
  cup:has(x, y)
  cn[K(x, y)] = { G.norm(t, ny, sqrt(1 - t * t)) } end)
-- contact shadow of the cup on the saucer well
cup:shift(2, 1):each(function(x, y) if sau:has(x, y) and not cup:has(x, y) then c:put(x, y, CER[2], stok) end end)

-- handle: slim ring on the right
local hm = HP.ellipse(48, 39, 4.6, 5):cut(HP.ellipse(48, 39, 2.4, 2.8)):cut(cup)
local hn = X.pillow(hm, 1.2)
local htok = { r = { name = "handle" } }
G.shade(c, hm, hn, CER, { tok = htok, amb = 0.15, wrap = 0.35 })
-- ambient where the handle meets the cup
G.touch(hm, cup):each(function(x, y) c:put(x, y, CER[2], htok) end)

local ctok = { r = { name = "cup" } }
local cidx = G.shade(c, cup, cn, CER, { tok = ctok, amb = 0.18, wrap = 0.45 })
-- glazed green band
cup:each(function(x, y) if y >= 38 and y <= 41 then
  local i = cidx[K(x, y)] or 3
  c:put(x, y, BAND[(y == 41) and max(1, i - 2) or i], ctok) end end)
-- foot ring ambient line and base shade
for x = 25, 37 do c:put(x, 49, CER[2], ctok) end
for x = 26, 30 do c:put(x, 50, CER[4], ctok) end
-- cup body specular: 2x1 on the upper left of the bowl
c:put(20, 36, CER[6], ctok) c:put(21, 36, CER[6], ctok) c:put(21, 44, CER[5], ctok)

-- rim + tea surface
local rim = HP.ellipse(31, rimY, 15.4, 3.6)
local tea = HP.ellipse(31, rimY + 0.3, 13.4, 2.4)
rim:copy():cut(tea):each(function(x, y)
  local col = CER[5]
  if y > rimY then col = x < 31 and CER[6] or CER[4] end
  if y < rimY - 1 and x > 38 then col = CER[4] end
  c:put(x, y, col, ctok) end)
local ttok = { r = { name = "tea" } }
tea:each(function(x, y)
  local col = TEA[4]
  if y <= rimY - 1 then col = TEA[2] end           -- inner rim shadow at the back
  if y >= rimY + 2 then col = TEA[5] end
  if not tea:has(x, y - 1) then col = TEA[1] end
  if x > 40 and y > rimY then col = TEA[3] end
  c:put(x, y, col, ttok) end)
c:put(36, rimY + 1, TEA[6], ttok) c:put(37, rimY + 1, TEA[6], ttok)

-- fern frond leaning out of the cup to the upper left
local fern = { { 27, 33 }, { 23, 25 }, { 19, 18 }, { 14, 13 } }
local ftok = { r = { name = "fern" } }
local pin = HP.mask()
for i = 1, 9 do
  local t = 0.12 + (i - 1) * 0.095
  local x, y = G.bez(fern, t)
  local x2, y2 = G.bez(fern, t + 0.01)
  local tx, ty = x2 - x, y2 - y local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  local side = (i % 2 == 0) and 1 or -1
  local px, py = -ty * side, tx * side
  local L = 4.3 * (1 - t * 0.75)
  -- pinna angled toward the tip
  local ux, uy = px * 0.8 + tx * 0.6, py * 0.8 + ty * 0.6
  pin:add(G.oval(x + ux * (L * 0.55 + 0.4), y + uy * (L * 0.55 + 0.4), L * 0.6 + 0.3, 1.05, math.atan(uy, ux), 1))
end
pin:cut(tea):cut(rim)
G.shade(c, pin, X.pillow(pin, 1.2), FERN, { tok = ftok, amb = 0.2, wrap = 0.3 })
-- rachis
local prev
for i = 0, 40 do local x, y = G.bez(fern, i / 40) local px, py = floor(x + .5), floor(y + .5)
  if not tea:has(px, py) then c:put(px, py, i < 20 and FERN[3] or FERN[4], ftok) end end
-- curled tip
for _, q in ipairs{ { 13, 12 }, { 12, 11 }, { 12, 10 }, { 13, 9 }, { 14, 10 } } do c:put(q[1], q[2], FERN[4], ftok) end
c:put(13, 10, FERN[6], ftok)
-- frond foot dipped in the tea: a ripple ring
c:put(26, rimY, TEA[6], ttok) c:put(29, rimY, TEA[6], ttok)

-- quirk: steam rising and winding into a fiddlehead spiral
local steam = HP.mask()
local pts = { { 35, 28 }, { 37, 25 }, { 35, 22 }, { 36, 19 } }
for i = 0, 30 do local x, y = G.bez(pts, i / 30) steam:set(floor(x + .5), floor(y + .5)) end
-- spiral: centre (40,15)
local scx, scy = 40, 15
for i = 0, 60 do local a = pi + i / 60 * 1.9 * pi
  local r = 4.2 * (1 - i / 60 * 0.75)
  steam:set(floor(scx + cos(a) * r + .5), floor(scy + sin(a) * r * 0.9 + .5)) end
steam:set(36, 18) steam:set(36, 17)
local smtok = { r = { name = "steam" } }
steam:each(function(x, y) c:put(x, y, (x > 41 or y > 22) and STEAMSH or STEAM, smtok) end)

G.save(c, NAME)
