-- folk-frog-1 sprite (folk F2_8) variant: 1
-- gardener tree frog: leaf-green, straw sunhat with a pink-flower sprig behind the eye bulges, terracotta dungarees, trowel (quirk: soil crumbs on the blade)
local V = 1

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

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, scale = 1, name = NAME }
  local b, tw, st = p.b or 0, p.tw or 0, p.st or 0
  local bw = ({ 11, 10, 13 })[V]
  local lx = ({ 10, 9, 11 })[V]
  c:groundShadow(32, 89, 15, 3)
  if V == 2 then -- pack on the back, bedroll on top
    local pk = c:rrect(8, 60 + b, 22, 80 + b, 3)
    c:part(pk, ACC, { band = 2, pop = { x = 10, y = 62 + b } }) under(c, pk, ACC.deep)
    for x = 9, 21 do c:put(x, 66 + b, ACC.deep) end
    c:put(15, 68 + b, BRASS.hi) c:put(15, 69 + b, BRASS.shade)
    local roll = c:ellipse(15, 58 + b + st, 8, 2.5)
    c:part(roll, ROLL, { band = 1, nopop = true })
    for _, x in ipairs{ 10, 20 } do for y = 55, 61 do if roll:has(x, y + b + st) then c:put(x, y + b + st, ROLL.deep) end end end
  end
  -- folded thighs then webbed feet (feet fixed)
  for _, s in ipairs{ -1, 1 } do
    local th = c:ellipse(32 + s * lx, 81 + b, 5, 6)
    c:part(th, SKIN, { band = 2, nopop = true }) under(c, th, SKIN.deep)
    if V == 2 then c:put(32 + s * lx - 1, 79 + b, SKIN.deep) c:put(32 + s * lx, 79 + b, SKIN.shade) c:put(32 + s * lx + 2, 83 + b, SKIN.deep) end
  end
  for _, s in ipairs{ -1, 1 } do
    local fx = 32 + s * (lx - 1)
    local foot = c:ellipse(fx, 88, 4.5, 1.6)
    for _, t in ipairs{ -4, 0, 4 } do foot:add(c:rect(fx + t, 89, fx + t + 1, 90)) end
    c:part(foot, SKIN, { band = 1, nopop = true })
    for _, t in ipairs{ -4, 0, 4 } do c:put(fx + t, 89, SKIN.hi) end
  end
  local body = c:ellipse(32, 74 + b, bw, 11)
  c:part(body, SKIN, { band = 2, nopop = true }) under(c, body, SKIN.deep)
  c:part(c:ellipse(32, 76 + b, bw - 4, 8):clip(body), BELLY, { band = 1, nopop = true })
  if V == 1 then
    local ov = body:copy():clip(c:rect(0, 78 + b, 63, 95))
    ov:add(c:rrect(26, 68 + b, 38, 80 + b, 1))
    c:part(ov, CLOTH, { band = 2, pop = { x = 27, y = 69 + b } }) under(c, ov, CLOTH.deep)
    c:part(c:line({ { 27, 69 + b }, { 24, 63 + b } }, 2), CLOTH, { band = 1, nopop = true })
    c:part(c:line({ { 37, 69 + b }, { 40, 63 + b } }, 2), CLOTH, { band = 1, nopop = true })
    c:put(27, 70 + b, METAL.hi) c:put(37, 70 + b, METAL.hi)
    for x = 29, 35 do c:put(x, 73 + b, CLOTH.shade) end
    for y = 73, 76 do c:put(29, y + b, CLOTH.shade) c:put(35, y + b, CLOTH.shade) end
  elseif V == 2 then
    c:part(c:line({ { 22, 64 + b }, { 25, 80 + b } }, 2), ACC, { band = 1, nopop = true })
    c:part(c:line({ { 42, 64 + b }, { 39, 80 + b } }, 2), ACC, { band = 1, nopop = true })
  else
    local ap = c:poly{ { 25, 66 + b }, { 39, 66 + b }, { 44, 85 + b }, { 20, 85 + b } }
    c:part(ap, CLOTH, { band = 2, pop = { x = 26, y = 68 + b } }) under(c, ap, CLOTH.deep)
    for x = 18, 46 do if ap:has(x, 83 + b) then c:put(x, 83 + b, ACC.base) end end
    for x = 18, 46 do if body:has(x, 72 + b) and not ap:has(x, 72 + b) then c:put(x, 72 + b, ACC.shade) end end
    for x = 29, 35 do c:put(x, 76 + b, ACC.base) end
    for y = 77, 80 do c:put(29, y + b, CLOTH.shade) c:put(35, y + b, CLOTH.shade) end
  end
  -- prop
  if V == 1 then
    c:part(c:line({ { 46, 71 + b }, { 46, 77 + b } }, 2), WOOD, { band = 1, nopop = true })
    local bl = c:poly{ { 43, 78 + b }, { 49, 78 + b }, { 47 + tw, 85 + b }, { 45 + tw, 85 + b } }
    c:part(bl, METAL, { band = 1, pop = { x = 44, y = 78 + b } })
    c:put(46 + tw, 84 + b, WOOD.deep) c:put(47 + tw, 83 + b, WOOD.shade)
  elseif V == 2 then
    local lxp = 49 + tw
    c:fillMask(c:line({ { 47, 76 + b }, { lxp, 77 + b } }, 1), METAL.deep)
    c:part(c:rect(lxp - 3, 78 + b, lxp + 2, 79 + b), BRASS, { band = 1, nopop = true })
    local gl = c:rect(lxp - 3, 80 + b, lxp + 2, 84 + b)
    c:part(gl, GLOW, { band = 1, nopop = true })
    c:put(lxp - 1, 82 + b, GLOW.hi) c:put(lxp, 82 + b, GLOW.hi) c:put(lxp - 1, 81 + b, GLOW.hi)
    for y = 80, 84 do c:put(lxp - 3, y + b, BRASS.shade) c:put(lxp + 2, y + b, BRASS.deep) end
    c:part(c:rect(lxp - 3, 85 + b, lxp + 2, 85 + b), BRASS, { band = 1, nopop = true })
  else
    c:part(c:line({ { 47, 78 + b }, { 53, 50 + b } }, 2), WOOD, { band = 1, nopop = true })
    local bowl = c:ellipse(54 + tw, 47 + b, 4, 3)
    c:part(bowl, METAL, { band = 1, pop = { x = 51 + tw, y = 46 + b } })
    c:part(c:ellipse(54 + tw, 45.5 + b, 2.5, 1), SOUP, { band = 1, nopop = true })
    c:put(57 + tw, 51 + b, SOUP.base)
  end
  for _, s in ipairs{ -1, 1 } do
    local ax = 32 + s * (bw + 1)
    c:part(c:ellipse(ax, 71 + b, 2.5, 4), SKIN, { band = 1, nopop = true })
    local hx, hy2 = ax + s, 76 + b
    if V == 2 and s == 1 then hx, hy2 = 46, 75 + b end
    c:part(c:ellipse(hx, hy2, 2.5, 2), SKIN, { band = 1, nopop = true })
    for _, d in ipairs{ -2, 0, 2 } do c:put(hx + d, hy2 + 2, SKIN.hi) end
  end
  -- head: wide flat frog head with eye bulges
  local hy = 54 + b
  local head = c:ellipse(32, hy, 16, 10)
  local bul = { [-1] = c:ellipse(23, hy - 7, 5.5, 5), [1] = c:ellipse(41, hy - 7, 5.5, 5) }
  c:part(head:copy():add(bul[-1]):add(bul[1]), SKIN, { band = 2, pop = { x = 21, y = hy - 3 } })
  c:part(c:ellipse(32, hy + 8, 11, 3):clip(head), BELLY, { band = 1, nopop = true })
  for _, tx in ipairs{ 18, 45 } do c:put(tx, hy - 1, SKIN.shade) c:put(tx + 1, hy - 1, SKIN.shade) c:put(tx, hy, SKIN.shade) c:put(tx + 1, hy, SKIN.deep) end
  if V == 2 then for _, q in ipairs{ { 25, hy - 1 }, { 37, hy - 2 }, { 31, hy - 4 }, { 41, hy + 1 }, { 22, hy + 2 } } do
    c:put(q[1], q[2], SKIN.shade) c:put(q[1] + 1, q[2], SKIN.shade) c:put(q[1], q[2] + 1, SKIN.shade) c:put(q[1] + 1, q[2] + 1, SKIN.deep) end end
  for x = 20, 44 do local t = (x - 32) / 12 c:put(x, math.floor(hy + 5 - 2.2 * t * t + 0.5), SKIN.deep) end
  c:put(30, hy - 1, SKIN.deep) c:put(34, hy - 1, SKIN.deep)
  c:cheek(21, hy + 1) c:cheek(41, hy + 1)
  if V == 2 then -- striped scarf under the chin, tail down the front
    local sc = c:rrect(19, hy + 8, 45, hy + 11, 2)
    sc:add(c:line({ { 38, hy + 10 }, { 40, hy + 17 + st }, { 39, hy + 21 + st } }, 3))
    c:part(sc, CLOTH, { band = 1, nopop = true }) under(c, sc, CLOTH.deep)
    sc:each(function(x, y) if (x + y) % 6 < 2 and c:get(x, y) ~= CLOTH.deep then c:put(x, y, ROLL.base) end end)
  end
  if V == 1 then -- straw sunhat sits on the crown behind the eyes
    local brim = c:ellipse(32, hy - 13, 15, 3)
    c:part(brim, ACC, { band = 1, nopop = true })
    for x = 18, 46 do if x % 3 == 0 and brim:has(x, hy - 13) then c:put(x, hy - 13, ACC.shade) end end
    c:part(c:rrect(25, hy - 21, 39, hy - 13, 4), ACC, { band = 2, pop = { x = 27, y = hy - 19 } })
    for x = 25, 39 do c:put(x, hy - 15, CLOTH.base) c:put(x, hy - 14, CLOTH.shade) end
    c:part(c:line({ { 26, hy - 15 }, { 22, hy - 19 + st } }, 2), LEAF, { band = 1, nopop = true })
    local fx, fy = 21, hy - 21 + st
    for _, q in ipairs{ { 0, -1 }, { -1, 0 }, { 1, 0 }, { 0, 1 } } do c:put(fx + q[1], fy + q[2], PINK[1]) end
    c:put(fx + 1, fy + 1, PINK[2]) c:put(fx, fy, GLOW.base)
  elseif V == 3 then -- kerchief with a knot at the back-right
    local k = head:copy():clip(c:rect(0, 0, 63, hy - 5))
    k:add(c:ellipse(32, hy - 10, 10, 4))
    c:part(k, ACC, { band = 2, pop = { x = 25, y = hy - 12 } })
    c:part(c:poly{ { 45, hy - 9 }, { 51, hy - 13 - tw }, { 50, hy - 7 } }, ACC, { band = 1, nopop = true })
    c:part(c:poly{ { 45, hy - 8 }, { 51, hy - 3 + st }, { 47, hy - 4 } }, ACC, { band = 1, nopop = true })
    k:each(function(x, y) if (x + 2 * y) % 5 == 0 and y % 2 == 0 then c:put(x, y, ACC.hi) end end)
  end
  for _, s in ipairs{ -1, 1 } do
    local bx = 32 + s * 9
    c:part(bul[s], SKIN, { band = 1, pop = { x = bx - 3, y = hy - 11 } })
    local ex, ey = bx - 2, hy - 9
    for x = ex + 1, ex + 3 do c:put(x, ey - 1, SKIN.shade) end
    if p.blink then for x = ex, ex + 4 do c:put(x, ey + 1, SKIN.shade) c:put(x, ey + 2, P.ink) end
    else c:eyeLocked(ex, ey) end
  end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local FR = { { b = 0 }, { b = 1, st = 1 }, { b = 0 }, { b = 0, blink = true, tw = 1 } }
local frames = {}
for i, p in ipairs(FR) do frames[i] = frame(p) end
local W, H, N = 64, 96, 4
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local imgs = {}
for f, c in ipairs(frames) do
  local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % W, i // W, rgba(hex)) end
  imgs[f] = im
end
local strip = Image(W * N, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
for f = 1, N do strip:drawImage(imgs[f], Point((f - 1) * W, 0)) end
local s1 = Sprite(W * N, H, ColorMode.RGB) s1.cels[1].image = strip
s1:saveCopyAs(out .. NAME .. ".png") s1:close()
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, N do spr:newEmptyFrame() end
local Ly = spr.layers[1] Ly.name = NAME
for f = 1, N do spr:newCel(Ly, spr.frames[f], imgs[f], Point(0, 0)) spr.frames[f].duration = ({ 0.3, 0.3, 0.3, 0.18 })[f] end
local tg = spr:newTag(1, N) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
print(NAME .. " sprite ok")
