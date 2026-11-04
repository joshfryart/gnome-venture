-- folk-ladybird-3 sprite (folk F2_1) variant: 3
-- Generic rest-stop ladybird villager, 64x96 cell, 3/4 top-down, feet y=90 x=32, idle x4 (256x96 strip).
-- Anatomy: domed spotted elytra worn like a back shell, dark head with cream pronotum cheek patches,
-- clubbed antennae, six legs (arms + side nubs + feet). v1 red 7-spot gardener (straw hat, dungarees, trowel),
-- v2 lemon 22-spot traveller (cap, scarf, pack + bedroll, lantern), v3 orange cream-spot cook (toque, apron, ladle).
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local V = 3
local NAME = "folk-ladybird-" .. V
local INK = "#2b1c26"
local function R(a, b, c2, d) return { hi = a, base = b, shade = c2, deep = d } end
local HEAD  = R("#6e5d84", "#4f4164", "#3d3150", "#342a44")
local MUZ   = R("#a896be", "#86749e", "#66567e", "#4f4164")
local CREAM = R("#fff3d6", "#f4e2bc", "#d6bfa0", "#a8917c")
local CREAMD = R("#f4e2bc", "#d6bfa0", "#a8917c", "#a8917c")
local STRAW = R("#fff0a0", "#f0cc6a", "#c99a48", "#8e6838")
local WOOD  = R("#d8a070", "#a86e48", "#7a4a3a", "#53322f")
local WOODD = R("#a86e48", "#7a4a3a", "#53322f", "#53322f")
local METAL = R("#eef2f6", "#b8c4d0", "#7f8ca8", "#56607e")
local BRASS = R("#ffe08a", "#e0a838", "#a8702c", "#6e4628")
local GLOW  = R("#fff8c8", "#ffe070", "#f0b040", "#c07a30")
local ROLL  = R("#f0a0aa", "#c8566e", "#8e3a5a", "#5e2846")
local TEAL  = R("#8ae6d6", "#36b0a4", "#24788a", "#1d4f66")
local CAP   = R("#9ab8f4", "#5a78d0", "#3e4ea0", "#2e3470")
local CAPD  = R("#5a78d0", "#3e4ea0", "#2e3470", "#2e3470")
local SOUP  = R("#ffd27a", "#e89a40", "#b86a30", "#7a4430")
local BLUSH = "#f2a0a8"
local SHELL = ({ R("#f7735a", "#d93a30", "#a52638", "#6e1d36"),
                 R("#fff08a", "#f2cf38", "#c99a2c", "#8a5f2e"),
                 R("#ffb066", "#ec7a30", "#b8522e", "#7a3430") })[V]
local SPOT = V == 3 and CREAM or R("#5a4868", "#3a2c48", "#33263f", "#33263f")
local CLOTH = ({ R("#a6d36a", "#6aa84a", "#447a3e", "#2f5236"),
                 R("#e8c99a", "#c49a68", "#8e6a4e", "#5e4440"),
                 R("#d6b8f0", "#a87cd8", "#7656a8", "#4e3a78") })[V]
local CLOTHD = R(CLOTH.base, CLOTH.shade, CLOTH.deep, CLOTH.deep)
local function part(c, m, r, band, pop)
  c:part(m, r, { band = band or 1, nopop = pop == nil, pop = pop, inner = false })
  return m
end
local function under(c, m, hex)
  local l = {}
  m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], hex) end
end
local out = app.params.out or "/home/user/gnome-venture/aseprite-source/v3/folk/sprites/"
local SPOTS = ({ { {19,70,2}, {45,70,2}, {20,80,1.5}, {44,80,1.5}, {26,61,1.5}, {38,61,1.5} },
                 { {18,68,1.2}, {21,74,1.2}, {18,79,1.2}, {23,84,1.2}, {46,68,1.2}, {43,74,1.2}, {46,79,1.2}, {41,84,1.2}, {23,61,1.2}, {41,61,1.2} },
                 { {19,72,2}, {45,72,2}, {21,82,1.5}, {43,82,1.5} } })[V]
local function eye4(c, x, y)
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } }) do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, tw, sw, hs = p.b or 0, p.tw or 0, p.sw or 0, p.hs or 0
  local function Y(y) return y + b end
  c:groundShadow(32, 89, 14, 3)
  if V == 2 then -- pack + bedroll behind the right shoulder
    part(c, c:rrect(37, Y(54), 52, Y(71), 3), WOOD, 2)
    part(c, c:rrect(37, Y(54), 52, Y(59), 2), WOODD, 1)
    part(c, c:rrect(38, Y(49) + hs, 53, Y(54) + hs, 2), ROLL, 1, { x = 40, y = Y(50) + hs })
    c:put(44, Y(58), BRASS.base) c:put(45, Y(58), BRASS.hi)
  end
  local sh = c:ellipse(32, Y(72), 16, 14)
  part(c, sh, SHELL, 2, { x = 20, y = Y(64) })
  for _, q in ipairs(SPOTS) do part(c, c:ellipse(q[1], Y(q[2]), q[3], q[3]):clip(sh:copy()), SPOT, 1) end
  for _, q in ipairs({ { 18, Y(68) }, { 18, Y(69) }, { 19, Y(66) }, { 20, Y(65) } }) do if sh:has(q[1], q[2]) then c:put(q[1], q[2], SHELL.hi) end end
  part(c, c:line({ { 17, Y(80) }, { 13, Y(84) } }, 2), HEAD, 1)
  part(c, c:line({ { 47, Y(80) }, { 51, Y(84) } }, 2), HEAD, 1)
  for _, fx in ipairs({ 26.5, 37.5 }) do -- feet never move
    part(c, c:rect(math.floor(fx) - 1, 83, math.floor(fx) + 1, 87), HEAD, 1)
    local f = c:ellipse(fx, 88, 3.5, 2) part(c, f, HEAD, 1, { x = math.floor(fx) - 2, y = 87 }) under(c, f, HEAD.deep)
  end
  local to = c:ellipse(32, Y(75), 9, 10)
  if V == 1 then
    part(c, to, CREAM, 1)
    local dg = to:copy():clip(c:rect(0, Y(71), 63, 95)) dg:add(c:rect(27, Y(68), 36, Y(72)))
    part(c, dg, CLOTH, 2)
    part(c, c:rect(29, Y(74), 34, Y(77)), CLOTHD, 1)
    c:put(27, Y(68), STRAW.hi) c:put(36, Y(68), STRAW.hi)
    under(c, to, CLOTH.deep)
  elseif V == 2 then
    part(c, to, CLOTH, 2)
    for x = 23, 41 do if to:has(x, Y(79)) then c:put(x, Y(79), WOOD.shade) end end
    part(c, c:line({ { 25, Y(66) }, { 37, Y(80) } }, 2):clip(to:copy()), WOOD, 1)
    c:put(32, Y(79), BRASS.hi) c:put(33, Y(79), BRASS.base)
    under(c, to, CLOTH.deep)
  else
    part(c, to, CLOTH, 2)
    local ap = c:rrect(26, Y(69), 37, Y(84), 2)
    part(c, ap, CREAM, 2)
    part(c, c:rrect(29, Y(77), 34, Y(80), 1), CREAMD, 1)
    c:put(25, Y(73), CREAM.base) c:put(24, Y(74), CREAM.shade) c:put(25, Y(75), CREAM.shade)
    under(c, ap, CREAM.deep)
  end
  local SL = V == 1 and CREAM or CLOTH
  if V == 2 then part(c, c:line({ { 23, Y(66) }, { 17, Y(73) } }, 3), SL, 1)
  else part(c, c:line({ { 23, Y(66) }, { 19, Y(73) } }, 3), SL, 1) end
  if V == 3 then part(c, c:line({ { 41, Y(66) }, { 45, Y(71) } }, 3), SL, 1)
  else part(c, c:line({ { 41, Y(66) }, { 45, Y(73) } }, 3), SL, 1) end
  if V == 1 then -- trowel, crumb of soil on the blade
    part(c, c:line({ { 45, Y(74) }, { 46, Y(80) } }, 2), WOOD, 1)
    part(c, c:poly{ { 43 + sw, Y(80) }, { 49 + sw, Y(80) }, { 46 + sw, Y(87) } }, METAL, 1, { x = 44 + sw, y = Y(80) })
    c:put(46 + sw, Y(84), WOOD.shade) c:put(47 + sw, Y(83), WOOD.base)
  elseif V == 2 then -- lantern, swings in frame 4
    local s = -sw
    part(c, c:rect(15 + s, Y(77), 17 + s, Y(78)), BRASS, 1)
    part(c, c:rrect(12 + s, Y(79), 20 + s, Y(80), 1), BRASS, 1)
    part(c, c:rect(13 + s, Y(81), 19 + s, Y(86)), GLOW, 1, { x = 14 + s, y = Y(82) })
    for y = Y(81), Y(86) do c:put(16 + s, y, BRASS.shade) end
    part(c, c:rrect(12 + s, Y(87), 20 + s, Y(88), 1), BRASS, 1)
  else -- ladle raised, a drop of soup in frame 4
    part(c, c:line({ { 46, Y(74) }, { 50 + sw, Y(58) } }, 2), METAL, 1)
    local bw = c:ellipse(51 + sw, Y(56), 4, 3)
    part(c, bw, METAL, 1, { x = 49 + sw, y = Y(54) }) under(c, bw, METAL.deep)
    part(c, c:ellipse(51 + sw, Y(55), 2.5, 1.2), SOUP, 1)
    if p.drip then c:put(54 + sw, Y(60), SOUP.base) end
  end
  part(c, c:ellipse(V == 2 and 17 or 19, Y(75), 2.5, 2.5), HEAD, 1)
  part(c, c:ellipse(V == 3 and 46 or 45, V == 3 and Y(73) or Y(75), 2.5, 2.5), HEAD, 1)
  if V == 2 then -- scarf + tail
    part(c, c:rrect(21, Y(60), 43, Y(65), 2), TEAL, 1, { x = 23, y = Y(61) })
    local tl = c:poly{ { 25, Y(63) }, { 30, Y(63) }, { 29, Y(73) + hs }, { 24, Y(72) + hs } }
    part(c, tl, TEAL, 1)
    c:put(25, Y(72) + hs, TEAL.deep) c:put(27, Y(72) + hs, TEAL.deep)
  end
  -- head: dark head + pronotum cream patches as cheeks, little muzzle
  local hd = c:ellipse(32, Y(47), 13, 11)
  part(c, hd, HEAD, 2, { x = 24, y = Y(40) })
  part(c, c:ellipse(22, Y(53), 3.5, 2.5):clip(hd:copy()), CREAM, 1)
  part(c, c:ellipse(42, Y(53), 3.5, 2.5):clip(hd:copy()), CREAM, 1)
  c:put(22, Y(53), BLUSH) c:put(23, Y(53), BLUSH) c:put(40, Y(53), BLUSH) c:put(41, Y(53), BLUSH)
  part(c, c:ellipse(32, Y(54), 4, 3), MUZ, 1)
  c:put(31, Y(52), HEAD.deep) c:put(32, Y(52), HEAD.deep) c:put(30, Y(52), MUZ.hi)
  c:put(30, Y(54), INK) c:put(31, Y(55), INK) c:put(32, Y(55), INK) c:put(33, Y(54), INK)
  if p.blink then for _, x in ipairs({ 24, 36 }) do for i = 0, 3 do c:put(x + i, Y(46), INK) end end
  else eye4(c, 24, Y(44)) eye4(c, 36, Y(44)) end
  -- hats
  if V == 1 then
    local brim = c:ellipse(32, Y(39), 17, 4)
    brim:add(c:ellipse(16, Y(40) + hs, 2, 1.5)) brim:add(c:ellipse(48, Y(40) + hs, 2, 1.5))
    brim:add(c:rect(49, Y(37), 50, Y(37)))
    part(c, brim, STRAW, 2) under(c, brim, STRAW.deep)
    for x = 17, 46, 3 do if brim:has(x, Y(41)) and brim:has(x + 1, Y(41)) then c:put(x, Y(41), STRAW.shade) c:put(x + 1, Y(41), STRAW.shade) end end
    local cr = c:ellipse(32, Y(34), 8, 5.5) cr:add(c:rect(24, Y(34), 39, Y(38)))
    part(c, cr, STRAW, 2, { x = 27, y = Y(31) })
    for x = 24, 39 do c:put(x, Y(37), CLOTH.base) c:put(x, Y(38), CLOTH.shade) end
  elseif V == 2 then
    local cr = c:ellipse(32, Y(39), 12.5, 6.5):clip(c:rect(0, 0, 63, Y(40)))
    part(c, cr, CAP, 2, { x = 26, y = Y(34) })
    for _, q in ipairs({ { 27, Y(35) }, { 27, Y(37) }, { 37, Y(35) }, { 37, Y(37) } }) do c:put(q[1], q[2], CAP.shade) end
    local pk = c:ellipse(32, Y(41), 10, 2.5):clip(c:rect(0, Y(40), 63, 95))
    part(c, pk, CAPD, 1) under(c, pk, CAP.deep)
    part(c, c:rect(31, Y(32), 32, Y(32)), BRASS, 1, { x = 31, y = Y(32) })
  else
    local tq = c:ellipse(33, Y(29) + hs, 10, 6.5)
    tq:add(c:ellipse(25, Y(32) + hs, 4, 4)) tq:add(c:ellipse(41, Y(32) + hs, 4, 4))
    part(c, tq, CREAM, 2, { x = 28, y = Y(25) + hs })
    for _, x in ipairs({ 29, 33, 37 }) do for y = Y(32), Y(35) do c:put(x, y, CREAM.shade) end end
    local bd = c:rrect(23, Y(35), 40, Y(40), 1)
    part(c, bd, CREAM, 1) under(c, bd, CREAM.deep)
  end
  local AN = V == 3 and { { 25, Y(39), 17, Y(33) + hs }, { 39, Y(39), 47 + tw, Y(33) + hs - tw } }
          or { { 27, Y(37), 21, Y(28) + hs }, { 37, Y(37), 43 + tw, Y(28) + hs - tw } }
  for _, a in ipairs(AN) do part(c, c:ellipse(a[3], a[4], 1.5, 1.5), HEAD, 1) end
  c:finish{ outline = true }
  for _, a in ipairs(AN) do
    c:fillMask(c:line({ { a[1], a[2] }, { a[3] + (a[1] > a[3] and 2 or -2), a[4] + 2 } }, 1), INK)
  end
  HP.assertClean(c)
  return c
end
local FR = { { b = 0 }, { b = 1, hs = 1 }, { b = 0 }, { b = 0, blink = true, tw = 1, sw = 1, drip = true } }
local frames = {}
for _, p in ipairs(FR) do frames[#frames + 1] = frame(p) end
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local spr = Sprite(64, 96, ColorMode.RGB)
for _ = 2, 4 do spr:newEmptyFrame() end
local strip = Image(256, 96, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
for f, c in ipairs(frames) do
  local im = Image(64, 96, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % 64, i // 64, rgba(hex)) end
  spr:newCel(spr.layers[1], spr.frames[f], im, Point(0, 0))
  spr.frames[f].duration = (f == 2) and 0.4 or 0.3
  strip:drawImage(im, Point((f - 1) * 64, 0))
end
spr.layers[1].name = NAME
local tg = spr:newTag(1, 4) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
local s2 = Sprite(256, 96, ColorMode.RGB) s2.cels[1].image = strip s2:saveCopyAs(out .. NAME .. ".png") s2:close()
print(NAME .. " sprite ok")
