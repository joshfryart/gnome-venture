-- folk-wren-2 sprite (folk F2_4) variant: 2
-- Wren villager: round body, cocked barred tail, pale eyebrow stripe, thin horn beak.
local V = 2
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "folk-wren-" .. V
local function rp(a, b, c2, d) return { hi = a, base = b, shade = c2, deep = d } end
-- plumage: v1 russet, v2 dusty grey-cinnamon, v3 dark chocolate
local PL = ({ rp("#dc9c5c", "#b06a3a", "#7a4438", "#4e2c3a"), rp("#cbab8a", "#9a7a66", "#6a5463", "#45374c"), rp("#bc8258", "#8a5638", "#5e3a3c", "#3c2633") })[V]
local BL = ({ rp("#f4dca8", "#e2b97e", "#b98d6c", "#8a6460"), rp("#ecdac0", "#cfb699", "#9c8a8a", "#6c5f72"), rp("#f2d2a0", "#d6a873", "#a67a64", "#74525a") })[V]
local BK = rp("#ecc882", "#c8955a", "#8a6050", "#5a3c44")
local LG = rp("#e6a68c", "#bc7a6a", "#8a566a", "#5c3c56")
local CR = "#f6e8c6"
local METAL = rp("#dfe2ea", "#a9b0c2", "#707792", "#474a66")
local WOOD = rp("#d8a46a", "#a87048", "#744a44", "#4c3240")
-- outfit
local HAT, KC, PK, RL, LN, AP, TQ
if V == 1 then HAT = rp("#f8da7c", "#e0b052", "#a87a48", "#6e4c48") KC = rp("#a6d672", "#62a04a", "#3e6a50", "#2c4848")
elseif V == 2 then HAT = rp("#cc80a2", "#8e4a74", "#5e3460", "#3c2448") KC = rp("#82d4c6", "#3f9a9a", "#2e6878", "#26405a")
  PK = rp("#c88a52", "#985e3a", "#6a3e3c", "#462a38") RL = rp("#e4b0a0", "#c07a6e", "#8a5062", "#5a3450") LN = rp("#f8de7c", "#d6a440", "#9a6a3a", "#5e4040")
else AP = rp("#a8c8ee", "#6a8ccc", "#4a5c9a", "#323c6a") TQ = rp("#f8ecce", "#e6d2ac", "#b0a0a4", "#786c84") end
local BACK = ({ rp("#c8e0a0", "#a8c98a", "#7fa070", "#5c7a62"), rp("#bee0ea", "#9cc4d8", "#7298b8", "#55708f"), rp("#f6c8b8", "#e8a6a0", "#c27c86", "#965c70") })[V]
local function chev(c, m, hex, per, cx, owner)
  m:copy():shrink(1):each(function(x, y) if (y + math.floor(math.abs(x - cx) / 2)) % per == 0 and c:get(x, y) then c:put(x, y, hex, owner) end end)
end
local function dots(c, list, hex, owner) for _, q in ipairs(list) do c:put(q[1], q[2], hex, owner) end end
local function eye(c, x, y)
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs{ {0,1},{3,1},{0,2},{3,2},{1,3},{2,3} } do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, tw, pd = p.b or 0, p.tw or 0, p.pd or 0
  local function Y(y) return y + b end
  c:groundShadow(32, 89.5, 13, 3)
  if V == 2 then -- travel pack + bedroll behind the body
    c:part(c:rrect(15, Y(58), 49, Y(78), 5), PK, { band = 1 })
    c:part(c:rrect(12, Y(52), 52, Y(57), 2), RL, { band = 1, nopop = true })
    for _, x in ipairs{ 15, 49 } do for y = Y(53), Y(56) do c:put(x, y, RL.deep, RL) end end
  end
  -- cocked wren tail, barred
  local tail = c:poly{ {37,Y(70)},{41,Y(62)},{48+tw,Y(45)},{54+tw,Y(47)},{47,Y(66)},{43,Y(73)} }
  c:part(tail, PL, { band = 1 })
  chev(c, tail, PL.deep, 3, 50, PL)
  -- tiny legs + three-toed feet (never move)
  for _, lx in ipairs{ 27, 36 } do
    c:part(c:rect(lx, 80, lx + 1, 88), LG, { nopop = true })
    c:part(c:rect(lx - 2, 89, lx + 3, 90), LG, { nopop = true })
    c:put(lx - 1, 90, LG.deep, LG) c:put(lx + 2, 90, LG.deep, LG)
  end
  -- round body + buff belly
  local body = c:ellipse(32, Y(70), 12, 12.5)
  c:part(body, PL, { band = 2 })
  c:part(c:ellipse(32, Y(73), 7.5, 8.5):clip(body), BL, { band = 1 })
  dots(c, { {29,Y(70)},{34,Y(72)},{31,Y(75)},{35,Y(77)} }, BL.shade, BL)
  if V == 3 then -- cook's apron with pocket
    local ap = c:rrect(25, Y(61), 39, Y(81), 3)
    c:part(ap, AP, { band = 1 })
    c:part(c:rect(29, Y(72), 35, Y(76)), AP, { nopop = true })
    for x = 29, 35 do c:put(x, Y(72), AP.deep, AP) end
    c:stitch{ {26, Y(79)}, {38, Y(79)} }
  end
  if V == 2 then -- pack straps
    for _, s in ipairs{ {{24,Y(59)},{25,Y(76)}}, {{40,Y(59)},{39,Y(76)}} } do c:fillMask(c:line(s, 2):clip(body), PK.shade) end
  end
  -- wings, barred
  for _, cx in ipairs{ 19.5, 44.5 } do
    local w = c:ellipse(cx, Y(69), 3.5, 6.5)
    c:part(w, PL, { band = 1 })
    chev(c, w, PL.deep, 3, cx, PL)
  end
  -- neckwear (under the head)
  if V == 1 then
    c:part(c:poly{ {22,Y(56)},{42,Y(56)},{32,Y(66)} }, KC, { band = 1 })
    dots(c, { {27,Y(59)},{36,Y(59)},{31,Y(62)} }, KC.hi, KC)
  elseif V == 2 then
    c:part(c:rrect(20, Y(55), 44, Y(60), 2), KC, { band = 1 })
    local st = c:poly{ {21,Y(58)},{26,Y(59)},{24,Y(69)+pd},{19,Y(68)+pd} }
    c:part(st, KC, { band = 1, nopop = true })
    dots(c, { {20,Y(68)+pd},{22,Y(69)+pd},{24,Y(69)+pd} }, KC.deep, KC)
  end
  -- head
  local head = c:ellipse(32, Y(46), 14, 12)
  c:part(head, PL, { band = 2 })
  c:part(c:ellipse(32, Y(56), 8, 3):clip(head), BL, { nopop = true })
  dots(c, { {26,Y(37)},{30,Y(36)},{35,Y(37)},{39,Y(39)} }, PL.shade, PL)
  for _, s in ipairs{ { {21,Y(43)},{22,Y(42)},{28,Y(42)} }, { {36,Y(42)},{42,Y(42)},{43,Y(43)} } } do c:fillMask(c:line(s, 1), CR) end
  if p.blink then for _, x in ipairs{ 24, 37 } do for i = 0, 3 do c:put(x + i, Y(45), P.ink) end end
  else eye(c, 24, Y(43)) eye(c, 37, Y(43)) end
  c:cheek(21, Y(49)) c:cheek(41, Y(49))
  local beak = c:poly{ {29.5,Y(48)},{34.5,Y(48)},{32,Y(53)} }
  c:part(beak, BK, { nopop = true })
  c:put(31, Y(48), BK.hi, BK) c:put(31, Y(50), BK.deep, BK) c:put(32, Y(50), BK.deep, BK)
  -- headwear
  if V == 1 then -- wide straw hat, green band
    local brim = c:ellipse(32, Y(37), 18, 4.5)
    c:part(brim, HAT, { band = 1 })
    brim:each(function(x, y) if (x + 2 * y) % 5 == 0 then c:put(x, y, HAT.shade, HAT) end end)
    local crown = c:rrect(24, Y(27), 40, Y(37), 4)
    c:part(crown, HAT, { band = 1 })
    crown:each(function(x, y) if y < Y(33) and (x + y) % 4 == 0 then c:put(x, y, HAT.shade, HAT) end end)
    c:part(c:rect(24, Y(33), 40, Y(35)), KC, { nopop = true })
  elseif V == 2 then -- jaunty plum cap, bill left
    local dome = c:ellipse(35, Y(37), 10, 6):clip(c:rect(0, 0, 63, Y(39)))
    c:part(dome, HAT, { band = 1 })
    c:part(c:ellipse(24, Y(39), 6, 2), HAT, { nopop = true })
    c:part(c:rect(35, Y(30), 36, Y(31)), LN, { nopop = true })
  else -- cook's puffy toque, blue band
    local puff = c:ellipse(32, Y(28), 12, 7):add(c:ellipse(24, Y(31), 6, 5)):add(c:ellipse(40, Y(31), 6, 5))
    c:part(puff, TQ, { band = 1 })
    for _, x in ipairs{ 28, 36 } do for y = Y(25), Y(31) do c:put(x, y, TQ.shade, TQ) end end
    c:part(c:rrect(22, Y(33), 42, Y(38), 2), TQ, { band = 1 })
    for x = 23, 41 do c:put(x, Y(36), AP.base, AP) end
  end
  -- prop
  if V == 1 then -- trowel in right wing
    c:part(c:rect(44, Y(61)+pd, 46, Y(67)+pd), WOOD, { nopop = true })
    c:part(c:rect(44, Y(68)+pd, 46, Y(68)+pd), METAL, { nopop = true, noshade = true })
    local bl = c:poly{ {42.5,Y(69)+pd},{48.5,Y(69)+pd},{47.5,Y(75)+pd},{45.5,Y(79)+pd},{43.5,Y(75)+pd} }
    c:part(bl, METAL, { band = 1 })
    c:put(46, Y(78)+pd, WOOD.deep, WOOD)
  elseif V == 2 then -- lantern hanging from left wing
    local sx = pd
    c:fillMask(c:line({ {16+sx,Y(71)},{18,Y(68)} }, 1), LN.deep)
    c:part(c:rect(13+sx, Y(72), 19+sx, Y(73)), LN, { nopop = true })
    c:part(c:rect(14+sx, Y(74), 18+sx, Y(79)), rp("#fff2b4", "#fbe08a", "#e8b450", "#b07a40"), { band = 1 })
    for y = Y(74), Y(79) do c:put(16+sx, y, LN.shade, LN) end
    c:part(c:rect(13+sx, Y(80), 19+sx, Y(81)), LN, { nopop = true })
  else -- ladle raised in left wing
    c:fillMask(c:line({ {18,Y(71)},{13,Y(57)+pd} }, 2), METAL.base)
    local bowl = c:ellipse(12, Y(54)+pd, 4, 2.5)
    c:part(bowl, METAL, { band = 1 })
    c:part(c:ellipse(12, Y(53)+pd, 2.5, 1):clip(bowl), rp("#f8c070", "#e88e4a", "#b85e44", "#7c3c40"), { nopop = true })
  end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { b = 0 }, { b = 1, tw = 1, pd = 1 }, { b = 0 }, { b = 0, blink = true, tw = -1, pd = -1 } } do frames[#frames + 1] = frame(p) end
local W, H, N = 64, 96, 4
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, N do spr:newEmptyFrame() end
local strip = Image(W * N, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
for f, c in ipairs(frames) do
  local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % W, i // W, rgba(hex)) end
  spr:newCel(spr.layers[1], spr.frames[f], im, Point(0, 0))
  strip:drawImage(im, Point((f - 1) * W, 0))
end
spr.layers[1].name = NAME
local tg = spr:newTag(1, N) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
local s2 = Sprite(W * N, H, ColorMode.RGB) s2.cels[1].image = strip
s2:saveCopyAs(out .. NAME .. ".png") s2:close()
print(NAME .. " sprite ok")
