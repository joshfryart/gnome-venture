-- folk-firefly-1 portrait (folk F2_13) variant: 1
-- Firefly villager portrait, 80x100, head + shoulders, bleeds off the bottom, same design/colours as the sprite.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local V = 1
local NAME = "folk-firefly-" .. V
local function rp(h, b, s, d) return { hi = h, base = b, shade = s, deep = d } end
-- v1 gardener (straw hat, neckerchief, trowel) / v2 traveller (denim cap, striped scarf, pack + bedroll)
-- v3 cook (polka kerchief, apron, copper ladle). All: lampyrid pronotum hood with pale margin + dark spot,
-- wing-case coat with pale edges, segmented belly whose last plates are the glowing lantern.
local VR = {
  { pro = rp("#ffc27e", "#f08a4c", "#c45c4a", "#8a3e4e"), ely = rp("#7e8c6c", "#56644f", "#404b47", "#30353f"),
    trim = "#f2d87a", trim2 = "#ffe08a", head = rp("#fbe6a2", "#e7c36a", "#c3944f", "#8d6449"),
    cloth = rp("#a8dc78", "#6eb454", "#4a8a4c", "#33604a"), prop = rp("#e4e6ee", "#aeb4c8", "#7a7c9a", "#54506c"),
    prop2 = rp("#e0a670", "#b07650", "#80544a", "#583c42"), bg = rp("#c4e48c", "#9cc46a", "#78a05a", "#58784e") },
  { pro = rp("#ffa89c", "#e46c6c", "#b04c64", "#7a3452"), ely = rp("#a67c5c", "#7c5844", "#5c4242", "#3e2e3a"),
    trim = "#f0c870", trim2 = "#ffd48a", head = rp("#94bcec", "#5c86c8", "#47599a", "#363f72"),
    cloth = rp("#92e2d2", "#46b0a6", "#307e86", "#285468"), prop = rp("#ead29a", "#c8a46a", "#987656", "#6a5048"),
    prop2 = rp("#f0a070", "#c8683e", "#984a40", "#6a343c"), bg = rp("#a8c4f0", "#7ea0d8", "#6480b8", "#4c5f94") },
  { pro = rp("#fff0a0", "#f4c24a", "#d08a3e", "#9a5a40"), ely = rp("#a46c9e", "#7a4a7e", "#5a3a66", "#3e2c50"),
    trim = "#f4b8c8", trim2 = "#fdf2d4", head = rp("#ff9a88", "#e05a50", "#b03e4c", "#7a2c44"),
    cloth = rp("#fdf2d4", "#f0dcb4", "#c8b0a0", "#94808a"), prop = rp("#ffc48a", "#d88a54", "#a85a48", "#723e44"),
    prop2 = rp("#ffc48a", "#d88a54", "#a85a48", "#723e44"), bg = rp("#f8c49a", "#f0a878", "#d08060", "#a0604e") },
}
local R = VR[V]
R.face = rp("#6c5c7c", "#4d405e", "#3b3049", "#30263c")
R.dome = rp("#8a7a9c", "#6c5c7c", "#5a4b6a", "#4d405e")
R.belly = rp("#f3ddb2", "#dcb98c", "#b48c76", "#806272")
R.glow = rp("#fbf6b4", "#e6ef72", "#b5d64c", "#7ba63e")
R.glow2 = rp("#fdfbd0", "#f4f8a0", "#d4ea66", "#98c048")

local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function pt(m, r, bd) c:part(m, r, { band = bd or 2, nopop = true }) return m end
local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local function put(x, y, hex, r) if x >= 0 and y >= 0 and x < 80 and y < 100 then c:put(x, y, hex, r) end end
local function gl(m, x, y, r) if m:has(x, y) then put(x, y, r.hi, r) end end
local CX = 40
if V == 2 then
  local pk = c:rrect(49, 62, 68, 99, 5) pt(pk, R.prop, 3) gl(pk, 52, 65, R.prop)
  for y = 70, 99 do if pk:has(64, y) then put(64, y, R.prop.shade, R.prop) end end
  local roll = E(58, 62, 10, 4.5) pt(roll, R.prop2, 2) gl(roll, 51, 60, R.prop2) gl(roll, 52, 59, R.prop2)
  for _, x in ipairs{ 52, 64 } do for y = 57, 67 do if roll:has(x, y) then put(x, y, R.prop2.deep, R.prop2) end end end
end
local ely = E(CX, 104, 29, 32):clip(c:rect(0, 72, 79, 99)) pt(ely, R.ely, 3) gl(ely, 22, 80, R.ely) gl(ely, 23, 79, R.ely)
ely:edge():each(function(x, y) if x < 27 or x > 52 then put(x, y, R.trim, R.ely) end end)
local brx = V == 3 and 17 or 13
local bel = E(CX, 108, brx, 32):clip(c:rect(0, 76, 79, 99)) pt(bel, R.belly, 2)
for _, y in ipairs{ 83, 88 } do for x = 20, 60 do if bel:has(x, y) and bel:has(x, y - 1) then put(x, y, R.belly.shade, R.belly) end end end
local lo = bel:copy():clip(c:rect(0, 93, 79, 99)) pt(lo, R.glow, 2) gl(lo, 31, 94, R.glow) gl(lo, 32, 94, R.glow) gl(lo, 31, 95, R.glow)
if V == 1 then
  local nk = c:poly{ { 25, 66 }, { 55, 66 }, { 40, 84 } } pt(nk, R.cloth, 2)
  for _, q in ipairs{ { 31, 69 }, { 40, 69 }, { 48, 69 }, { 35, 74 }, { 44, 74 }, { 40, 79 } } do put(q[1], q[2], R.cloth.hi, R.cloth) end
  -- trowel in the left hand
  pt(E(15, 92, 4.5, 6), R.face, 1)
  pt(c:rect(15, 76, 18, 88), R.prop2, 1)
  local bl = c:poly{ { 11, 77 }, { 22, 77 }, { 21, 69 }, { 16.5, 60 }, { 12, 69 } } pt(bl, R.prop, 2)
  for y = 63, 76 do put(16, y, R.prop.shade, R.prop) end gl(bl, 13, 70, R.prop) gl(bl, 14, 67, R.prop)
  put(17, 62, R.prop2.shade, R.prop2) put(16, 61, R.prop2.deep, R.prop2)
  local hd = E(16.5, 86, 4, 3.5) pt(hd, R.face, 1) gl(hd, 14, 84, R.face)
elseif V == 2 then
  pt(c:line({ { 25, 72 }, { 30, 99 } }, 3), R.prop, 1)
  local sc = c:rrect(22, 63, 58, 73, 4) pt(sc, R.cloth, 2) gl(sc, 25, 65, R.cloth)
  for x = 22, 58 do if x % 6 == 2 then for y = 63, 73 do if sc:has(x, y) then put(x, y, R.prop2.base, R.cloth) end end end end
  local tl = c:poly{ { 44, 71 }, { 52, 71 }, { 54, 90 }, { 46, 89 } } pt(tl, R.cloth, 2)
  for y = 75, 87, 5 do for x = 44, 54 do if tl:has(x, y) then put(x, y, R.prop2.base, R.cloth) end end end
  local hd = E(28, 92, 3.5, 3.5) pt(hd, R.face, 1) gl(hd, 26, 90, R.face)
else
  local ap = c:rrect(29, 79, 51, 99, 4) pt(ap, R.cloth, 2)
  pt(c:line({ { 31, 80 }, { 27, 72 } }, 2), R.cloth, 1) pt(c:line({ { 49, 80 }, { 53, 72 } }, 2), R.cloth, 1)
  c:rrect(34, 88, 46, 95, 2):edge():each(function(x, y) put(x, y, R.cloth.shade, R.cloth) end)
  c:stitch{ { 35, 89 }, { 45, 89 } }
  pt(c:line({ { 63, 64 }, { 61, 97 } }, 2), R.prop, 1)
  local bw = E(64, 60, 6, 3.5) pt(bw, R.prop, 2) c:fillMask(E(64, 59, 4.5, 1.5), R.prop.deep) gl(bw, 59, 60, R.prop)
  local hd = E(61, 90, 4, 4) pt(hd, R.face, 1) gl(hd, 59, 88, R.face)
end
-- head
local face = E(CX, 57, 16, 11) pt(face, R.face, 2)
local pro = E(CX, 37, 21, 13) pt(pro, R.pro, 3) gl(pro, 27, 30, R.pro) gl(pro, 28, 29, R.pro) gl(pro, 26, 31, R.pro)
pro:edge():each(function(x, y) if y < 47 then put(x, y, R.trim2, R.pro) end end)
local sp = E(CX, V == 1 and 39 or 34, 6, 3.5) c:fillMask(sp, R.face.shade)
face:each(function(x, y) if pro:has(x, y - 1) and not pro:has(x, y) then put(x, y, R.face.deep, R.face) end end)
for _, dx in ipairs{ 33.5, 46.5 } do
  local d = E(dx, 55.5, 5, 4.5) pt(d, R.dome, 1)
end
c:eyeLocked(31, 53) c:eyeLocked(44, 53)
local mz = E(CX, 62.5, 4.5, 2.5) pt(mz, R.belly, 1) gl(mz, 37, 61, R.belly)
put(36, 65, R.belly.deep) put(43, 65, R.belly.deep)
for _, q in ipairs{ { 37, 66 }, { 38, 67 }, { 39, 67 }, { 40, 67 }, { 41, 67 }, { 42, 66 } } do put(q[1], q[2], P.ink) end
for _, x0 in ipairs{ 25, 52 } do for y = 61, 62 do for x = x0, x0 + 2 do put(x, y, P.petal.base) end end put(x0, 61, P.petal.hi) end
local ant
if V == 1 then
  local brim = E(CX, 28, 26, 5)
  pro:each(function(x, y) if (brim:has(x, y - 1) or brim:has(x, y - 2)) and not brim:has(x, y) then put(x, y, R.pro.shade, R.pro) end end)
  pt(brim, R.head, 2) gl(brim, 17, 27, R.head) gl(brim, 18, 26, R.head)
  brim:each(function(x, y) if (x + 2 * y) % 5 == 0 and c:get(x, y) == R.head.base then put(x, y, R.head.shade, R.head) end end)
  local cr = c:rrect(28, 10, 51, 28, 6) pt(cr, R.head, 3) gl(cr, 31, 12, R.head) gl(cr, 30, 13, R.head)
  cr:each(function(x, y) if (x + y) % 4 == 0 and c:get(x, y) == R.head.base then put(x, y, R.head.shade, R.head) end end)
  pt(c:rect(28, 23, 51, 26), R.cloth, 1)
  pt(c:poly{ { 46, 23 }, { 54, 15 }, { 56, 18 }, { 50, 23 } }, R.cloth, 1)
  pt(c:poly{ { 47, 23 }, { 50, 14 }, { 52, 15 }, { 49, 23 } }, R.cloth, 1)
  ant = { { { 35, 11 }, { 31, 6 }, { 27, 3 } }, { { 45, 11 }, { 49, 6 }, { 53, 3 } } }
elseif V == 2 then
  local dome = E(CX, 31, 15, 10):clip(c:rect(0, 0, 79, 31)) pt(dome, R.head, 3) gl(dome, 31, 24, R.head) gl(dome, 32, 23, R.head)
  for y = 21, 31 do if dome:has(40, y) then put(40, y, R.head.shade, R.head) end end
  local br = E(31, 32.5, 13, 3.5) pt(br, R.head, 1) gl(br, 22, 31, R.head)
  pt(E(40, 21, 1.5, 1.5), R.head, 1)
  ant = { { { 35, 23 }, { 28, 13 }, { 22, 9 }, { 19, 8 } }, { { 45, 23 }, { 52, 13 }, { 58, 9 }, { 61, 8 } } }
else
  local kc = pro:copy():clip(c:rect(0, 0, 79, 32)) pt(kc, R.head, 2)
  kc:each(function(x, y) if x % 5 == 2 and y % 4 == 1 then put(x, y, R.cloth.hi, R.head) end end)
  for x = 18, 62 do if kc:has(x, 32) then put(x, 32, R.head.shade, R.head) end end
  pt(c:poly{ { 59, 30 }, { 69, 25 }, { 68, 33 } }, R.head, 2)
  pt(c:poly{ { 59, 34 }, { 68, 39 }, { 63, 41 } }, R.head, 2)
  pt(E(60, 32.5, 3, 2.5), R.head, 1)
  ant = { { { 35, 26 }, { 31, 16 }, { 26, 12 } }, { { 45, 26 }, { 49, 16 }, { 54, 12 } } }
end
c:finish{ outline = true }
for _, a in ipairs(ant) do c:fillMask(c:line(a, 1), P.ink) local t = a[#a] put(t[1] + (t[1] < 40 and -1 or 1), t[2], P.ink) put(t[1], t[2] - 1, P.ink) end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
backdrop(R.bg)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")
