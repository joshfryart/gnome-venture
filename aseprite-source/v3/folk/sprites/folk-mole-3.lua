-- folk-mole-3 sprite (folk F1_5) variant: 3
-- mole villager cook: toque, lavender smock, cream apron, soup ladle
local NAME, V = "folk-mole-3", 3
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local INK = P.ink
local function R(a, b, c, d) return { hi = a, base = b, shade = c, deep = d } end
local FUR = ({ R("#8e7480", "#6b5462", "#4c3a4f", "#35283d"), R("#80849a", "#5e617a", "#44445e", "#302f46"), R("#b9aaa6", "#958589", "#6d5e6d", "#4a3e51") })[V]
local PINK = R("#ffc4c0", "#f2949a", "#c96878", "#8f4660")
local CLAW = R("#f6ead2", "#e2d1b6", "#b9a28f", "#8a7480")
local STRAW = R("#fbe39a", "#e9bf5c", "#b98a3e", "#7d5934")
local GREEN = R("#b6d68a", "#7fae5a", "#4f7f4a", "#33533f")
local STEEL = R("#dfe7ea", "#a9b6c2", "#75809a", "#4b5270")
local WOOD = R("#d39a5e", "#a56c3d", "#74472e", "#4e2f2a")
local SOIL = "#5a3b33"
local RUST = R("#ff9a6e", "#e0603f", "#a83d3e", "#6e2a3a")
local PACK = R("#c9b07a", "#a08655", "#73603f", "#4c3d2f")
local CAP = R("#6fc3c0", "#3f9298", "#2d6475", "#22435a")
local LEATH = R("#a8735a", "#7e5040", "#5a3536", "#3e2530")
local BRASS = R("#ffe08a", "#e2a93a", "#a8702c", "#6e4a28")
local GLOW = R("#fff2b8", "#ffd96a", "#f2a93f", "#c4703a")
local LAV = R("#d9b8ef", "#b18ad6", "#7f62ac", "#563f80")
local CRM = R("#fff1d6", "#f2dfbd", "#d0b9a0", "#9c8590")
local COP = R("#ffb98a", "#e07e4c", "#a8523e", "#6f3437")
local SOUP = R("#ffd98a", "#f2a83e", "#c9742f", "#8a4a2e")
local BG = ({ R("#cfe6a6", "#a9cf7e", "#84ad62", "#5f8a4f"), R("#ffc4a0", "#f0a07a", "#d07a5e", "#a65a4e"), R("#e6d2f4", "#c9aee6", "#a68bc9", "#7f68a8") })[V]
local function on(c, m, from, to) local l = {} m:each(function(x, y) if c:get(x, y) == from then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do c:put(q[1], q[2], to) end end
local function pp(c, list, hex) for _, q in ipairs(list) do c:put(q[1], q[2], hex) end end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, tw = p.b or 0, p.tw or 0
  c:groundShadow(32, 89.5, 16, 3)
  if V == 2 then -- backpack + bedroll behind
    c:part(c:rrect(36, 44 + b, 55, 76 + b, 3), PACK, { band = 2, nopop = true })
    c:part(c:rrect(37, 44 + b, 54, 50 + b, 2), PACK, { band = 1, nopop = true })
    c:part(c:ellipse(46, 41 + b, 10, 3.5), CAP, { band = 1, nopop = true })
    for _, x in ipairs{ 40, 46, 52 } do for y = 39, 43 do if c:get(x, y + b) then c:put(x, y + b, RUST.base) end end end
    pp(c, { { 38, 39 + b }, { 39, 38 + b } }, CAP.hi)
  end
  for _, fx in ipairs{ 26, 38 } do
    c:part(c:ellipse(fx, 88.5, 3.5, 2), PINK, { band = 1, nopop = true })
    pp(c, { { fx - 3, 90 }, { fx - 1, 90 }, { fx + 1, 90 } }, CLAW.base)
  end
  local body = c:ellipse(32, 73 + b, 14.5, 13)
  body:add(c:ellipse(32, 80 + b, 15.5, 7))
  c:part(body, FUR, { band = 2, nopop = true })
  if V == 1 then
    local ov = body:copy():clip(c:rect(0, 77 + b, 63, 95))
    ov:add(c:rrect(25, 64 + b, 38, 78 + b, 1))
    ov:add(c:line({ { 26, 64 + b }, { 22, 60 + b } }, 2)) ov:add(c:line({ { 37, 64 + b }, { 41, 60 + b } }, 2))
    c:part(ov, GREEN, { band = 2, nopop = true })
    pp(c, { { 26, 65 + b }, { 37, 65 + b } }, STRAW.hi)
    for x = 29, 34 do c:put(x, 69 + b, GREEN.deep) end
    pp(c, { { 29, 70 + b }, { 34, 70 + b }, { 29, 71 + b }, { 34, 71 + b } }, GREEN.deep)
    pp(c, { { 26, 67 + b }, { 26, 68 + b }, { 27, 66 + b } }, GREEN.hi)
  elseif V == 2 then
    c:part(c:line({ { 22, 61 + b }, { 24, 81 + b } }, 2), LEATH, { band = 1, nopop = true })
    c:part(c:line({ { 41, 61 + b }, { 39, 81 + b } }, 2), LEATH, { band = 1, nopop = true })
    c:part(c:rect(38, 70 + b, 41, 72 + b), BRASS, { band = 1, nopop = true })
    c:part(c:rrect(19, 55 + b, 45, 62 + b, 2), RUST, { band = 2, nopop = true })
    for x = 21, 43, 3 do c:put(x, 61 + b, RUST.shade) end
  else
    c:part(body:copy():clip(c:rect(0, 60 + b, 63, 95)), LAV, { band = 2, nopop = true })
    local ap = c:rrect(25, 66 + b, 38, 86 + b, 2):clip(body)
    c:part(ap, CRM, { band = 2, nopop = true })
    for x = 25, 38 do if ap:has(x, 74 + b) then c:put(x, 74 + b, LAV.shade) end end
    for x = 28, 35 do c:put(x, 79 + b, CRM.deep) end
    pp(c, { { 28, 80 + b }, { 35, 80 + b }, { 28, 81 + b }, { 35, 81 + b } }, CRM.deep)
    for x = 19, 44, 2 do if body:has(x, 60 + b) then c:put(x, 60 + b, LAV.hi) end end
  end
  -- props behind paws
  if V == 1 then
    c:part(c:rect(46, 62 + b, 47, 69 + b), WOOD, { band = 1, nopop = true })
    c:part(c:rect(45, 72 + b, 48, 73 + b), STEEL, { band = 1, nopop = true })
    local bl = c:poly{ { 44 + tw, 74 + b }, { 49 + tw, 74 + b }, { 49 + tw, 79 + b }, { 47 + tw, 84 + b }, { 46 + tw, 84 + b }, { 44 + tw, 79 + b } }
    c:part(bl, STEEL, { band = 2, nopop = true })
    for y = 75, 80 do c:put(45 + tw, y + b, STEEL.hi) end
    pp(c, { { 46 + tw, 82 + b }, { 47 + tw, 83 + b }, { 46 + tw, 83 + b } }, SOIL)
  elseif V == 2 then
    local s = tw
    c:fillMask(c:line({ { 15 + s, 73 + b }, { 17, 71 + b }, { 19 + s, 73 + b } }, 1), BRASS.deep)
    c:part(c:rect(13 + s, 74 + b, 21 + s, 75 + b), BRASS, { band = 1, nopop = true })
    c:part(c:rect(14 + s, 76 + b, 20 + s, 82 + b), GLOW, { band = 1, nopop = true })
    for y = 76, 82 do c:put(17 + s, y + b, BRASS.shade) end
    pp(c, { { 16 + s, 79 + b }, { 16 + s, 80 + b } }, GLOW.hi)
    c:put(15 + s, 77 + b, GLOW.hi)
    c:part(c:rect(13 + s, 83 + b, 21 + s, 84 + b), BRASS, { band = 1, nopop = true })
  else
    c:part(c:line({ { 47, 72 + b }, { 50, 62 + b }, { 51, 58 + b } }, 2), COP, { band = 1, nopop = true })
    c:part(c:ellipse(51.5, 55.5 + b - tw, 4, 3), COP, { band = 1, nopop = true })
    c:part(c:ellipse(51.5, 55 + b - tw, 2.5, 1.5), SOUP, { band = 1, nopop = true })
    c:put(50, 54 + b - tw, SOUP.hi)
  end
  -- paws: big outward spades with claws
  for _, sx in ipairs{ -1, 1 } do
    local cx = 31.5 + sx * 14.5
    local pw = c:ellipse(cx + 0.5, 70 + b, 4.5, 3.5)
    c:part(pw, PINK, { band = 1, nopop = true })
    local ex = sx < 0 and 12 or 50
    if not (sx > 0 and V ~= 2) and not (sx < 0 and V == 2) then
      for _, y in ipairs{ 68, 70, 72 } do c:part(c:rect(ex, y + b, ex + 1, y + b), CLAW, { band = 0, nopop = true }) end
    else
      for _, x in ipairs{ cx - 2, cx, cx + 2 } do c:put(math.floor(x + 0.5), 67 + b, CLAW.base) end
    end
    c:put(math.floor(cx - 1), 69 + b, PINK.hi)
  end
  -- head
  local head = c:ellipse(32, 45 + b, 15.5, 13.5)
  c:part(head, FUR, { band = 2, nopop = true })
  c:fillMask(c:ellipse(28, 37 + b, 7, 2.5):clip(head), FUR.hi)
  for y = 38, 56, 3 do for x = 19 + (y % 2) * 2, 45, 5 do
    if c:get(x, y + b) == FUR.base then c:put(x, y + b, FUR.shade) c:put(x + 1, y + b - 1, FUR.shade) end
  end end
  -- whiskers, snout
  pp(c, { { 25, 52 + b }, { 24, 52 + b }, { 23, 51 + b }, { 38, 52 + b }, { 39, 52 + b }, { 40, 51 + b } }, FUR.hi)
  local sn = c:ellipse(32, 52.5 + b, 4, 3) sn:add(c:rect(30, 47 + b, 33, 51 + b))
  c:part(sn, PINK, { band = 1, nopop = true })
  pp(c, { { 30, 48 + b }, { 30, 49 + b }, { 29, 51 + b } }, PINK.hi)
  pp(c, { { 30, 53 + b }, { 33, 53 + b } }, PINK.deep)
  if tw > 0 then pp(c, { { 30, 54 + b }, { 33, 54 + b } }, PINK.deep) end
  pp(c, { { 30, 56 + b }, { 31, 57 + b }, { 32, 57 + b }, { 33, 56 + b } }, INK)
  pp(c, { { 22, 50 + b }, { 23, 50 + b }, { 40, 50 + b }, { 41, 50 + b } }, PINK.base)
  for _, ex in ipairs{ 26, 36 } do
    if p.blink then pp(c, { { ex, 46 + b }, { ex + 1, 46 + b } }, INK)
    else pp(c, { { ex, 45 + b }, { ex + 1, 45 + b }, { ex, 46 + b }, { ex + 1, 46 + b } }, INK) c:put(ex, 45 + b, P.cream) end
    pp(c, { { ex, 43 + b }, { ex + 1, 43 + b } }, FUR.hi)
  end
  -- headwear
  if V == 1 then
    local brim = c:ellipse(32, 35 + b, 21, 5)
    c:part(brim, STRAW, { band = 2, nopop = true })
    brim:each(function(x, y) if (x * 2 + y) % 5 == 0 and c:get(x, y) == STRAW.base then c:put(x, y, STRAW.shade) end end)
    local cr = c:rrect(23, 25 + b, 40, 34 + b, 4)
    c:part(cr, STRAW, { band = 2, nopop = true })
    c:part(c:rect(23, 31 + b, 40, 33 + b):clip(cr), GREEN, { band = 1, nopop = true })
    pp(c, { { 26, 27 + b }, { 27, 26 + b }, { 15, 33 + b }, { 16, 33 + b } }, STRAW.hi)
  elseif V == 2 then
    c:part(c:ellipse(32, 35 + b, 12, 6), CAP, { band = 2, nopop = true })
    for y = 30, 37 do c:put(31, y + b, CAP.shade) end
    c:part(c:ellipse(32, 40 + b, 9, 2.5), CAP, { band = 1, nopop = true })
    for x = 24, 39 do c:put(x, 41 + b, CAP.deep) end
    c:part(c:rect(30, 28 + b, 33, 29 + b), RUST, { band = 1, nopop = true })
    pp(c, { { 25, 32 + b }, { 26, 31 + b }, { 27, 31 + b } }, CAP.hi)
  else
    local pf = c:ellipse(26, 26 + b, 5.5, 5) pf:add(c:ellipse(32, 22 + b, 6.5, 6.5)) pf:add(c:ellipse(37, 26 + b, 5.5, 5))
    pf:add(c:rect(22, 27 + b, 41, 31 + b))
    c:part(pf, CRM, { band = 2, nopop = true })
    for _, x in ipairs{ 27, 32, 36 } do for y = 24, 30 do if pf:has(x, y + b) and (y % 3 ~= 0) then c:put(x, y + b, CRM.shade) end end end
    c:part(c:rrect(22, 31 + b, 41, 36 + b, 1), CRM, { band = 1, nopop = true })
    for x = 23, 40 do c:put(x, 33 + b, LAV.base) end
    pp(c, { { 28, 18 + b }, { 29, 17 + b }, { 22, 23 + b } }, CRM.hi)
  end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local W, H = 64, 96
local params = { { b = 0 }, { b = 1 }, { b = 0 }, { b = 0, blink = true, tw = 1 } }
local imgs = {}
for i, p in ipairs(params) do
  local c = frame(p)
  local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  local x0, y0, x1, y1 = 99, 99, 0, 0
  for idx, hex in pairs(c.pix) do local x, y = idx % W, idx // W im:putPixel(x, y, rgba(hex))
    x0, y0, x1, y1 = math.min(x0, x), math.min(y0, y), math.max(x1, x), math.max(y1, y) end
  print(NAME, i, x0, y0, x1, y1)
  imgs[i] = im
end
local strip = Image(W * 4, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
for i = 1, 4 do strip:drawImage(imgs[i], Point((i - 1) * W, 0)) end
local s1 = Sprite(W * 4, H, ColorMode.RGB) s1.cels[1].image = strip s1:saveCopyAs(out .. NAME .. ".png") s1:close()
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, 4 do spr:newEmptyFrame() end
for i = 1, 4 do spr:newCel(spr.layers[1], spr.frames[i], imgs[i], Point(0, 0)) end
local tg = spr:newTag(1, 4) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
