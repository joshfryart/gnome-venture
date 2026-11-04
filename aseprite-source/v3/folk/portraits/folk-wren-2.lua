-- folk-wren-2 portrait (folk F2_4) variant: 2
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
-- cocked barred tail behind right shoulder
local tail = c:poly{ {52,76},{57,58},{62,38},{70,40},{67,60},{61,80} }
c:part(tail, PL, { band = 2 })
chev(c, tail, PL.deep, 3, 64, PL)
if V == 2 then -- bedroll peeking over the left shoulder
  c:part(c:rrect(6, 62, 26, 70, 3), RL, { band = 1, nopop = true })
  for y = 63, 69 do c:put(11, y, RL.deep, RL) end
end
-- shoulders + belly
local body = c:ellipse(39.5, 101, 31, 30):clip(c:rect(0, 0, 79, 99))
c:part(body, PL, { band = 2 })
c:part(c:ellipse(39.5, 102, 15, 25):clip(body), BL, { band = 1 })
dots(c, { {34,82},{44,85},{38,90},{46,94},{32,95} }, BL.shade, BL)
for _, cx in ipairs{ 14, 65 } do
  local w = c:ellipse(cx, 90, 8, 14):clip(c:rect(0, 0, 79, 99))
  c:part(w, PL, { band = 1 })
  chev(c, w, PL.deep, 3, cx, PL)
end
if V == 3 then
  local ap = c:rrect(27, 73, 52, 99, 4)
  c:part(ap, AP, { band = 2 })
  for _, s in ipairs{ {{29,74},{24,66}}, {{50,74},{55,66}} } do c:part(c:line(s, 3), AP, { nopop = true }) end
  c:part(c:rrect(32, 86, 47, 94, 2), AP, { nopop = true })
  for x = 33, 46 do c:put(x, 86, AP.deep, AP) end
  c:stitch{ {29, 97}, {50, 97} }
elseif V == 2 then
  for _, s in ipairs{ {{26,74},{23,99}}, {{53,74},{56,99}} } do c:part(c:line(s, 3), PK, { nopop = true }) end
  c:part(c:rect(21, 88, 26, 91), LN, { nopop = true }) c:part(c:rect(53, 88, 58, 91), LN, { nopop = true })
end
if V == 1 then
  c:part(c:poly{ {22,64},{57,64},{39.5,85} }, KC, { band = 2 })
  dots(c, { {30,68},{38,67},{46,68},{34,73},{43,73},{39,79} }, KC.hi, KC)
  c:part(c:ellipse(39.5, 66, 3.5, 2.5), KC, { nopop = true })
elseif V == 2 then
  c:part(c:rrect(18, 62, 61, 71, 4), KC, { band = 2 })
  for x = 20, 59, 4 do for y = 63, 70 do if y % 2 == 0 then c:put(x, y, KC.shade, KC) end end end
  local st = c:poly{ {21,68},{30,69},{28,90},{19,89} }
  c:part(st, KC, { band = 1, nopop = true })
  dots(c, { {20,89},{22,90},{24,90},{26,90} }, KC.deep, KC)
end
-- head
local head = c:ellipse(39.5, 46, 20, 18)
for _, a in ipairs{ 150, 170, 190, 350, 10, 30 } do local r = math.rad(a) head:add(HP.ellipse(39.5 + math.cos(r) * 19.5, 46 + math.sin(r) * 17.5, 1.5, 1.5)) end
c:part(head, PL, { band = 3, pop = { x = 27, y = 35 } })
c:part(c:ellipse(39.5, 63, 8, 2.5):clip(head), BL, { band = 1, nopop = true })
dots(c, { {31,32},{37,30},{44,31},{49,34},{28,36},{52,38},{34,34},{42,34} }, PL.shade, PL)
dots(c, { {24,50},{25,52},{55,50},{54,52},{22,46},{57,46} }, PL.deep, PL)
for _, s in ipairs{ { {23,42},{25,40},{34,40} }, { {45,40},{54,40},{56,42} } } do c:fillMask(c:line(s, 2), CR) end
c:eyeLocked(29, 43) c:eyeLocked(46, 43)
c:cheek(25, 53) c:cheek(52, 53)
local beak = c:poly{ {34.5,48},{44.5,48},{39.5,62} }
c:part(beak, BK, { band = 1, nopop = true })
dots(c, { {37,51},{38,51} }, BK.hi, BK)
dots(c, { {37,54},{38,55},{39,55},{40,55},{41,54} }, P.ink)
dots(c, { {41,51} }, BK.deep, BK)
-- headwear
if V == 1 then
  local brim = c:ellipse(39.5, 31, 27, 5.5)
  c:part(brim, HAT, { band = 2 })
  brim:each(function(x, y) if (x + 2 * y) % 5 == 0 then c:put(x, y, HAT.shade, HAT) end end)
  local crown = c:rrect(27, 14, 52, 32, 6)
  c:part(crown, HAT, { band = 2, pop = { x = 30, y = 17 } })
  crown:each(function(x, y) if y < 25 and (x + y) % 4 == 0 then c:put(x, y, HAT.shade, HAT) end end)
  c:part(c:rect(27, 25, 52, 29), KC, { band = 1, nopop = true })
  -- tucked sprig quirk in the band
  c:fillMask(c:line({ {48,27},{52,18} }, 1), KC.deep)
  c:part(c:ellipse(51, 19, 2, 1.5), KC, { nopop = true }) c:part(c:ellipse(53, 22, 2, 1.5), KC, { nopop = true })
elseif V == 2 then
  local dome = c:ellipse(42, 31, 17, 9):clip(c:rect(0, 0, 79, 34))
  c:part(dome, HAT, { band = 2, pop = { x = 33, y = 25 } })
  for _, a in ipairs{ 30, 42, 54 } do c:fillMask(c:line({ {42,23},{a,33} }, 1):clip(dome:copy():shrink(1)), HAT.shade) end
  c:part(c:ellipse(25, 34, 12, 3.5), HAT, { band = 1 })
  c:part(c:rect(41, 21, 43, 22), LN, { nopop = true })
else
  local puff = c:ellipse(39.5, 17, 17, 9):add(c:ellipse(27, 22, 9, 7)):add(c:ellipse(52, 22, 9, 7))
  c:part(puff, TQ, { band = 2, pop = { x = 29, y = 14 } })
  for _, x in ipairs{ 33, 46 } do for y = 12, 24 do if puff:has(x, y) then c:put(x, y, TQ.shade, TQ) end end end
  c:part(c:rrect(22, 25, 57, 33, 3), TQ, { band = 1 })
  for x = 23, 56 do c:put(x, 29, AP.base, AP) c:put(x, 30, AP.shade, AP) end
end
-- prop
if V == 1 then -- trowel, crumbs of soil on the tip
  c:part(c:rrect(61, 62, 65, 73, 1), WOOD, { band = 1 })
  c:part(c:rect(60, 74, 66, 75), METAL, { nopop = true })
  local bl = c:poly{ {57,76},{69,76},{68,86},{63,93},{58,86} }
  c:part(bl, METAL, { band = 2 })
  c:fillMask(c:line({ {63,77},{63,89} }, 1), METAL.shade)
  dots(c, { {62,91},{64,90},{63,92} }, WOOD.deep, WOOD)
elseif V == 2 then
  c:fillMask(c:line({ {12,63},{16,58},{20,63} }, 1), LN.deep)
  c:part(c:rect(9, 63, 23, 66), LN, { band = 1 })
  c:part(c:rect(11, 67, 21, 80), rp("#fff2b4", "#fbe08a", "#e8b450", "#b07a40"), { band = 1 })
  for y = 67, 80 do c:put(16, y, LN.shade, LN) end
  for x = 11, 21 do c:put(x, 73, LN.base, LN) end
  c:part(c:rect(9, 81, 23, 84), LN, { band = 1 })
else
  c:part(c:line({ {17,98},{12,64} }, 3), METAL, { nopop = true })
  local bowl = c:ellipse(11, 60, 7, 4.5)
  c:part(bowl, METAL, { band = 1 })
  c:part(c:ellipse(11, 58.5, 5, 2):clip(bowl), rp("#f8c070", "#e88e4a", "#b85e44", "#7c3c40"), { band = 1, nopop = true })
  dots(c, { {8,58},{9,58} }, "#f8c070")
end
c:finish{ outline = true }
backdrop(BACK)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")
