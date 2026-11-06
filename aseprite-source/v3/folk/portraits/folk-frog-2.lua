-- folk-frog-2 portrait (folk F2_8) variant: 2
-- traveller frog: teal with dark spots, mustard striped scarf, big canvas pack + red bedroll on the back, brass lantern
local V = 2

local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "folk-frog-" .. V
local function R(a, b, c2, d) return { hi = a, base = b, shade = c2, deep = d } end
local SKIN = ({ R("#b6d861", "#6fae3e", "#3f7a4a", "#2f4a4c"), R("#9fe0d0", "#4fb0a8", "#357682", "#2c4660"), R("#ffb070", "#f07a3a", "#b84a3e", "#6e2e40") })[V]
local BELLY = ({ R("#f6eab0", "#e6d38a", "#b8a27a", "#7d6a6c"), R("#eef0d0", "#cfd8b8", "#9aa49c", "#626678"), R("#fff0c8", "#f8d8a0", "#d0a088", "#8a6070") })[V]
local CLOTH = ({ R("#e88a5c", "#c2573c", "#8a3a46", "#5a2a3e"), R("#ffd36a", "#f0a030", "#b8682e", "#7a3e36"), R("#f8f0dc", "#e4dcc8", "#b0a8b8", "#78708a") })[V]
local ACC = ({ R("#f4dc8a", "#d9b25a", "#a87c48", "#6e4e44"), R("#c8a070", "#9a7048", "#6a4a42", "#46303a"), R("#a8b8f0", "#6a7ad0", "#4a4c98", "#33305e") })[V]
local BG = ({ R("#f8d0b0", "#f2b98a", "#d98f6a", "#b06a58"), R("#fae0a0", "#f6d27a", "#e0b058", "#b8884a"), R("#d0d8f8", "#b8c4f0", "#94a0dc", "#6e74b4") })[V]
local METAL = R("#e2e8e6", "#a4b2bc", "#6c7690", "#464a68")
local WOOD = R("#dcaa6a", "#a8703e", "#764a3c", "#4a3038")
local ROLL = R("#f08a6a", "#c8483e", "#8a3046", "#58263e")
local BRASS = R("#ffe08a", "#d8a840", "#9a6a3a", "#5e3c3a")
local GLOW = R("#fff4b4", "#ffd860", "#f0a038", "#b86a30")
local LEAF = R("#c8e070", "#78b040", "#467a48", "#2e4c48")
local SOUP = R("#f8c070", "#d88a3a", "#a0563a", "#6a3438")
local IRIS = { "#f0c050", "#c08038" }
local PINK = { "#f8a0b0", "#e0607a" }
local function under(c, m, hex) local l = {} m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do c:put(q[1], q[2], hex) end end

local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local cx = 39.5
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
if V == 2 then
  local pk = c:rrect(3, 66, 22, 99, 4)
  c:part(pk, ACC, { band = 2, pop = { x = 5, y = 68 } })
  for x = 4, 21 do c:put(x, 74, ACC.deep) end
  c:put(12, 77, BRASS.hi) c:put(13, 77, BRASS.base) c:put(12, 78, BRASS.shade) c:put(13, 78, BRASS.shade)
  local roll = c:ellipse(13, 63, 11, 4)
  c:part(roll, ROLL, { band = 1, pop = { x = 6, y = 61 } })
  for _, x in ipairs{ 7, 19 } do for y = 58, 68 do if roll:has(x, y) then c:put(x, y, ROLL.deep) end end end
end
local body = c:ellipse(cx, 104, 31, 34):clip(c:rect(0, 70, 79, 99))
c:part(body, SKIN, { band = 3, pop = { x = 16, y = 84 } })
c:part(c:ellipse(cx, 104, 16, 24):clip(body), BELLY, { band = 2, nopop = true })
if V == 2 then for _, q in ipairs{ { 14, 86 }, { 20, 79 }, { 60, 82 }, { 66, 90 }, { 13, 95 } } do
  local m = c:ellipse(q[1], q[2], 2, 1.5):clip(body) c:fillMask(m, SKIN.shade) c:put(q[1] + 1, q[2] + 1, SKIN.deep) end end
if V == 1 then
  c:part(c:rrect(27, 82, 52, 99, 2), CLOTH, { band = 2, pop = { x = 28, y = 83 } })
  c:part(c:line({ { 30, 83 }, { 22, 74 } }, 3), CLOTH, { band = 1, nopop = true })
  c:part(c:line({ { 49, 83 }, { 57, 74 } }, 3), CLOTH, { band = 1, nopop = true })
  for _, x in ipairs{ 29, 49 } do c:put(x, 84, METAL.hi) c:put(x + 1, 84, METAL.base) c:put(x, 85, METAL.shade) c:put(x + 1, 85, METAL.shade) end
  c:part(c:rect(41, 84, 45, 89), { hi = "#f6ecd2", base = "#ece0c0", shade = "#c0b0a0", deep = "#8a7a80" }, { band = 1, nopop = true })
  c:put(43, 86, LEAF.base) c:put(42, 87, LEAF.shade) c:put(44, 87, LEAF.base)
  c:part(c:rect(33, 88, 46, 96), CLOTH, { band = 1, nopop = true })
  c:stitch{ { 34, 89 }, { 45, 89 } }
elseif V == 2 then
  c:part(c:line({ { 20, 76 }, { 25, 99 } }, 3), ACC, { band = 1, nopop = true })
  c:part(c:line({ { 59, 76 }, { 54, 99 } }, 3), ACC, { band = 1, nopop = true })
  local sc = c:rrect(17, 66, 62, 74, 3)
  sc:add(c:line({ { 48, 72 }, { 52, 84 }, { 50, 93 } }, 5))
  c:part(sc, CLOTH, { band = 2, pop = { x = 19, y = 67 } }) under(c, sc, CLOTH.deep)
  sc:each(function(x, y) if (x + y) % 7 < 2 and c:get(x, y) ~= CLOTH.deep then c:put(x, y, ROLL.base) end end)
  for _, x in ipairs{ 48, 50, 52 } do c:put(x, 96, CLOTH.base) c:put(x, 97, CLOTH.shade) end
else
  c:part(c:poly{ { 25, 82 }, { 54, 82 }, { 58, 99 }, { 21, 99 } }, CLOTH, { band = 2, pop = { x = 27, y = 84 } })
  c:part(c:line({ { 27, 83 }, { 30, 73 } }, 2), ACC, { band = 1, nopop = true })
  c:part(c:line({ { 52, 83 }, { 49, 73 } }, 2), ACC, { band = 1, nopop = true })
  for x = 25, 54 do c:put(x, 82, ACC.base) c:put(x, 83, ACC.shade) end
  c:part(c:rrect(32, 89, 47, 97, 2), CLOTH, { band = 1, nopop = true })
  for x = 32, 47 do c:put(x, 89, ACC.base) end
end
-- head
local hy = 58
local head = c:ellipse(cx, hy, 20, 13)
local bul = { [-1] = c:ellipse(cx - 11, 44, 8, 7.5), [1] = c:ellipse(cx + 11, 44, 8, 7.5) }
c:part(head:copy():add(bul[-1]):add(bul[1]), SKIN, { band = 3, pop = { x = 22, y = 52 } })
c:part(c:ellipse(cx, hy + 11, 14, 4):clip(head), BELLY, { band = 1, nopop = true })
for _, tx in ipairs{ 22.5, 56.5 } do
  local t = c:ellipse(tx, hy - 1, 2.5, 2.5)
  t:edge():each(function(x, y) c:put(x, y, SKIN.shade) end)
  c:put(math.floor(tx) - 1, hy - 2, SKIN.hi)
end
if V == 2 then for _, q in ipairs{ { 29, 54 }, { 47, 53 }, { 38, 51 }, { 52, 62 }, { 25, 61 } } do
  local m = c:ellipse(q[1], q[2], 1.6, 1.3) c:fillMask(m, SKIN.shade) c:put(q[1] + 1, q[2] + 1, SKIN.deep) end end
for x = 21, 58 do local t = (x - cx) / 18.5 c:put(x, math.floor(hy + 7 - 3 * t * t + 0.5), SKIN.deep) end
c:put(20, hy + 3, SKIN.deep) c:put(59, hy + 3, SKIN.deep)
for x = 36, 43 do local t = (x - cx) / 4 c:put(x, math.floor(hy + 8 - 1 * t * t + 0.5), SKIN.shade) end
c:put(36, hy, SKIN.deep) c:put(37, hy, SKIN.deep) c:put(42, hy, SKIN.deep) c:put(43, hy, SKIN.deep) c:put(36, hy - 1, SKIN.shade) c:put(43, hy - 1, SKIN.shade)
c:cheek(24, hy + 3) c:cheek(53, hy + 3)
if V == 1 then
  local brim = c:ellipse(cx, 37, 23, 4.5)
  c:part(brim, ACC, { band = 1, nopop = true })
  brim:each(function(x, y) if (x + y) % 4 == 0 then c:put(x, y, ACC.shade) end end)
  local cr = c:rrect(27, 19, 52, 37, 7)
  c:part(cr, ACC, { band = 2, pop = { x = 30, y = 22 } })
  cr:each(function(x, y) if (x * 2 + y) % 6 == 0 and y < 31 then c:put(x, y, ACC.hi) end end)
  for x = 27, 52 do c:put(x, 31, CLOTH.hi) c:put(x, 32, CLOTH.base) c:put(x, 33, CLOTH.shade) end
  c:part(c:line({ { 29, 32 }, { 22, 25 } }, 3), LEAF, { band = 1, nopop = true })
  c:put(23, 26, LEAF.shade) c:put(25, 28, LEAF.shade)
  local fl = c:ellipse(20.5, 22.5, 2.5, 2.5)
  c:part(fl, { hi = PINK[1], base = PINK[1], shade = PINK[2], deep = PINK[2] }, { band = 1, nopop = true })
  c:put(20, 22, GLOW.base) c:put(21, 22, GLOW.shade)
elseif V == 3 then
  local k = head:copy():clip(c:rect(0, 0, 79, hy - 6))
  k:add(c:ellipse(cx, hy - 13, 14, 6))
  c:part(k, ACC, { band = 2, pop = { x = 30, y = 42 } })
  k:each(function(x, y) if (x + 2 * y) % 6 == 0 and y % 3 == 0 then c:put(x, y, ACC.hi) end end)
  c:part(c:poly{ { 56, 48 }, { 65, 41 }, { 64, 51 } }, ACC, { band = 1, nopop = true })
  c:part(c:poly{ { 56, 50 }, { 64, 57 }, { 58, 55 } }, ACC, { band = 1, nopop = true })
  c:part(c:ellipse(57, 49, 2, 2), ACC, { band = 1, nopop = true })
end
for _, s in ipairs{ -1, 1 } do
  local bx = cx + s * 11
  c:part(bul[s], SKIN, { band = 2, pop = { x = math.floor(bx) - 4, y = 39 } })
  local ex, ey = (s < 0) and 26 or 49, 42
  local ir = c:rrect(ex - 1, ey - 1, ex + 5, ey + 5, 2)
  ir:each(function(x, y) c:put(x, y, (x + y > ex + ey + 6) and IRIS[2] or IRIS[1]) end)
  for x = ex, ex + 4 do c:put(x, ey - 2, SKIN.shade) end
  c:eyeLocked(ex, ey)
end
-- prop in hand
if V == 1 then
  c:part(c:line({ { 66, 99 }, { 66, 83 } }, 3), WOOD, { band = 1, nopop = true })
  c:part(c:rect(65, 80, 67, 82), METAL, { band = 1, nopop = true })
  local bl = c:poly{ { 61, 80 }, { 71, 80 }, { 66, 63 } }
  c:part(bl, METAL, { band = 2, pop = { x = 64, y = 72 } })
  for y = 66, 79 do c:put(66, y, METAL.shade) end
  c:put(65, 66, WOOD.deep) c:put(66, 68, WOOD.shade) c:put(67, 67, WOOD.deep) c:put(65, 69, WOOD.shade)
  c:part(c:ellipse(66, 90, 4.5, 3.5), SKIN, { band = 1, nopop = true })
  for _, d in ipairs{ -3, 0, 3 } do c:put(66 + d, 87, SKIN.hi) end
elseif V == 2 then
  c:part(c:ellipse(65, 72, 4, 3.5), SKIN, { band = 1, nopop = true })
  for _, d in ipairs{ -2, 0, 2 } do c:put(65 + d, 74, SKIN.hi) end
  c:fillMask(c:line({ { 62, 77 }, { 65, 75 }, { 68, 77 } }, 1), METAL.deep)
  c:part(c:rrect(60, 77, 70, 80, 1), BRASS, { band = 1, nopop = true })
  local gl = c:rrect(59, 81, 71, 93, 1)
  c:part(gl, GLOW, { band = 2, nopop = true })
  for y = 81, 93 do c:put(59, y, BRASS.shade) c:put(71, y, BRASS.deep) c:put(65, y, BRASS.base) end
  for _, q in ipairs{ { 64, 86 }, { 66, 86 }, { 64, 87 }, { 66, 87 }, { 64, 88 }, { 66, 88 } } do c:put(q[1], q[2], GLOW.hi) end
  c:put(65, 85, GLOW.hi) c:put(61, 83, GLOW.hi) c:put(61, 84, GLOW.hi)
  c:part(c:rect(59, 94, 71, 96), BRASS, { band = 1, nopop = true })
else
  c:part(c:line({ { 64, 99 }, { 68, 62 } }, 3), WOOD, { band = 1, nopop = true })
  c:part(c:ellipse(68, 58, 7, 5), METAL, { band = 2, pop = { x = 63, y = 56 } })
  c:part(c:ellipse(68, 56, 5, 2), SOUP, { band = 1, nopop = true })
  c:put(66, 56, LEAF.base) c:put(70, 56, LEAF.shade)
  c:put(62, 62, SOUP.base) c:put(62, 63, SOUP.shade)
  c:part(c:ellipse(65, 88, 4.5, 3.5), SKIN, { band = 1, nopop = true })
  for _, d in ipairs{ -3, 0, 3 } do c:put(65 + d, 85, SKIN.hi) end
end
c:finish{ outline = true }
backdrop(BG)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")
