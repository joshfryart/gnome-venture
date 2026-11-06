-- folk-bumblebee-2 sprite (folk F2_2) variant: 2
-- traveller: knit cap, scarf, pack, lantern
local V = 2
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local out = app.params.out or (DIR .. "/")
local INK = "#2b1c26"
local GOLD = ({ { hi = "#ffe07a", base = "#f5b83a", shade = "#c97d3a", deep = "#8a4f4a" },
  { hi = "#fff09a", base = "#f2d24e", shade = "#c99e4a", deep = "#8a6a52" },
  { hi = "#ffc770", base = "#ee9836", shade = "#bf6438", deep = "#7f3f48" } })[V]
local FUR = ({ { hi = "#5c4a78", base = "#40325a", shade = "#30264a", deep = "#261d3c" },
  { hi = "#6a5070", base = "#4a3854", shade = "#372942", deep = "#2a2036" },
  { hi = "#6e4a62", base = "#4e3450", shade = "#38263f", deep = "#2a1c33" } })[V]
local MUZ = { hi = GOLD.hi, base = GOLD.hi, shade = GOLD.base, deep = GOLD.shade }
local WING = { hi = "#eef6f2", base = "#cfe4ee", shade = "#9fb6d8", deep = "#7480b4" }
local STRAW = { hi = "#fff0b0", base = "#e8c46a", shade = "#b88848", deep = "#7c5848" }
local LEAF = { hi = "#b6e07a", base = "#76b24e", shade = "#477e52", deep = "#2f5248" }
local STEEL = { hi = "#eef2f4", base = "#aebccb", shade = "#7484a4", deep = "#4c5276" }
local WOOD = { hi = "#e0a86a", base = "#b0703e", shade = "#7c4a3e", deep = "#52323e" }
local TEAL = { hi = "#9ae6d8", base = "#3fb4aa", shade = "#2a7a88", deep = "#294e68" }
local RUST = { hi = "#ffa878", base = "#de6440", shade = "#a3404a", deep = "#6c2c46" }
local LEATHER = { hi = "#d29a66", base = "#9c6440", shade = "#6c4440", deep = "#4a2e3c" }
local BRASS = { hi = "#ffe48c", base = "#e0aa3c", shade = "#a86c3c", deep = "#6c4048" }
local GLOW = { hi = "#fff4b8", base = "#ffd968", shade = "#f0a848", deep = "#c47040" }
local ROSE = { hi = "#ffc4c8", base = "#ee8a9c", shade = "#bc5a7e", deep = "#7e3a62" }
local CREAM = { hi = "#fff6dc", base = "#f4e6c4", shade = "#cdbca8", deep = "#958aa0" }
local HONEY = { hi = "#ffd870", base = "#e8862a", shade = "#b85a2c", deep = "#86443a" }
local BG = ({ { hi = "#c8e6a8", base = "#a6d08a", shade = "#7aae6e", deep = "#55845a" },
  { hi = "#c8b8ec", base = "#a898d4", shade = "#7c6cb0", deep = "#584c8a" },
  { hi = "#ffd49a", base = "#f4b46a", shade = "#d48852", deep = "#a8644a" } })[V]
local BLUSH = "#f39a8e"
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function under(c, m, hex) local l = {} m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do c:put(q[1], q[2], hex) end end
local function overlay(c, m, f, t) local l = {} m:each(function(x, y) local v = c:get(x, y)
  if v == f.hi or v == f.base then l[#l + 1] = { x, y, t.base } elseif v == f.shade then l[#l + 1] = { x, y, t.shade } elseif v == f.deep then l[#l + 1] = { x, y, t.deep } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], q[3]) end end
local function recol(c, m, map) local l = {} m:each(function(x, y) local v = map[c:get(x, y) or ""] if v then l[#l + 1] = { x, y, v } end end) for _, q in ipairs(l) do c:put(q[1], q[2], q[3]) end end
local function px(c, list, hex) for _, q in ipairs(list) do c:put(q[1], q[2], hex) end end
local function zig(y0, h, x0, x1) local m = HP.mask() for x = x0, x1 do local z = x % 2 for y = y0 + z, y0 + h - 1 do m:set(x, y) end end return m end
local NAME = "folk-bumblebee-" .. V
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, scale = 1, name = NAME }
  local b, ad, tw = p.b or 0, p.ad or 0, p.tw or 0
  local hy = 49 + b
  c:groundShadow(32, 89.5, 12, 2.5)
  -- wings (fore + hind), behind
  for _, s in ipairs{ -1, 1 } do
    local wy = 63 + b
    local hind = oval(32 + s * 13, wy + 6, 5, 3, s * -10)
    local fore = oval(32 + s * 14, wy, (V == 3) and 7 or 8, 4, s * -30)
    c:part(hind, WING, { band = 1, nopop = true })
    c:part(fore, WING, { band = 1, nopop = true })
    c:fillMask(c:line({ { 32 + s * 9, wy + 2 }, { 32 + s * 19, wy - 3 } }, 1):clip(fore:shrink(1)), WING.shade)
  end
  if V == 2 then -- travel pack on the back, bedroll on top
    local pk = c:rrect(38, 60 + b, 51, 77 + b, 3)
    c:part(pk, LEATHER, { band = 2, pop = { x = 40, y = 66 + b } }) under(c, pk, LEATHER.deep)
    c:part(c:rrect(40, 64 + b, 50, 69 + b, 2), { hi = LEATHER.base, base = LEATHER.base, shade = LEATHER.shade, deep = LEATHER.deep }, { band = 1, nopop = true })
    px(c, { { 46, 69 + b }, { 47, 69 + b } }, BRASS.base)
    c:part(c:rrect(37, 57 + b, 53, 62 + b, 2), TEAL, { band = 1, pop = { x = 50, y = 58 + b } })
    px(c, { { 49, 58 + b }, { 49, 59 + b }, { 49, 60 + b }, { 49, 61 + b } }, TEAL.deep)
  end
  -- legs + feet (fixed)
  for _, x in ipairs{ 28, 36 } do c:part(c:rect(x - 1, 83, x + 1, 88), FUR, { band = 1, nopop = true }) end
  for _, x in ipairs{ 27.5, 36.5 } do
    local f = c:ellipse(x, 88.5, 3, 1.6) c:part(f, FUR, { band = 1, pop = { x = math.floor(x) - 1, y = 88 } }) under(c, f, FUR.deep)
  end
  -- fuzzy round body with stripes
  local rx, ry = (V == 2) and 11 or 12.5, (V == 3) and 11 or 10
  local body = c:ellipse(32, 75 + b, rx, ry)
  for _, q in ipairs{ { 32 - rx, 71 }, { 32 + rx, 71 }, { 32 - rx + 1, 78 }, { 32 + rx - 1, 78 } } do body:add(HP.ellipse(q[1], q[2] + b, 1.5, 1.5)) end
  c:part(body, GOLD, { band = 2, pop = { x = 24, y = 70 + b } })
  local stripes = (V == 3) and { 65 } or { 70, 77 }
  for _, y in ipairs(stripes) do overlay(c, zig(y + b, 3, 0, 63):clip(body), GOLD, FUR) end
  for y = 68, 84, 3 do for x = 22 + (y % 2) * 2, 42, 4 do recol(c, c:rect(x, y + b, x, y + b):clip(body), { [GOLD.base] = GOLD.shade, [FUR.base] = FUR.hi }) end end
  under(c, body, GOLD.deep)
  if V == 1 then -- green bib overall, straps, pocket
    local bib = c:rrect(26, 70 + b, 38, 86 + b, 2):clip(body:copy())
    c:part(bib, LEAF, { band = 2, pop = { x = 27, y = 71 + b } })
    c:part(c:line({ { 27, 71 + b }, { 25, 63 + b } }, 2), LEAF, { band = 1, nopop = true })
    c:part(c:line({ { 37, 71 + b }, { 39, 63 + b } }, 2), LEAF, { band = 1, nopop = true })
    c:rect(29, 76 + b, 35, 80 + b):edge():each(function(x, y) c:put(x, y, LEAF.shade) end)
    px(c, { { 27, 70 + b }, { 37, 70 + b } }, STRAW.hi)
  elseif V == 2 then
    c:part(c:line({ { 23, 66 + b }, { 41, 83 + b } }, 2):clip(body:copy()), LEATHER, { band = 1, nopop = true })
    px(c, { { 31, 74 + b }, { 32, 74 + b }, { 31, 75 + b } }, BRASS.base)
  else -- rose smock, scalloped hem, cream apron, round collar
    local sm = body:copy():clip(c:rect(0, 68 + b, 63, 95))
    for x = 22, 42, 4 do sm:add(HP.ellipse(x, 85.5 + b, 1.6, 1.4)) end
    c:part(sm, ROSE, { band = 2, pop = { x = 22, y = 70 + b } }) under(c, sm, ROSE.deep)
    local ap = c:rrect(27, 72 + b, 37, 86 + b, 2) c:part(ap, CREAM, { band = 2, nopop = true })
    c:rect(29, 78 + b, 35, 81 + b):edge():each(function(x, y) c:put(x, y, CREAM.shade) end)
    for _, s in ipairs{ -1, 1 } do c:part(c:ellipse(32 + s * 3.5, 66.5 + b, 3.5, 2), CREAM, { band = 1, nopop = true }) end
  end
  -- arms
  local SLV = (V == 3) and ROSE or FUR
  for _, s in ipairs{ -1, 1 } do c:part(c:ellipse(32 + s * 12.5, 73 + b, 2.5, 3.5), SLV, { band = 1, nopop = true }) end
  local function hand(x, y) c:part(c:ellipse(x, y, 2, 2), FUR, { band = 1, pop = { x = math.floor(x) - 1, y = math.floor(y) - 1 } }) end
  if V == 1 then -- trowel held up
    c:part(c:rect(45, 71 + b, 46, 78 + b), WOOD, { band = 1, nopop = true })
    c:part(c:rect(45, 69 + b, 46, 70 + b), STEEL, { band = 1, nopop = true })
    local bl = c:poly{ { 43, 68 + b }, { 48, 68 + b }, { 48, 64 + b }, { 46 + tw, 59 + b }, { 43, 64 + b } }
    c:part(bl, STEEL, { band = 1, pop = { x = 44, y = 64 + b } })
    hand(45.5, 76 + b) hand(19.5, 76 + b)
  elseif V == 2 then -- lantern hanging from the left hand
    c:fillMask(c:line({ { 19, 77 + b }, { 17, 79 + b } }, 1), BRASS.deep)
    c:part(c:poly{ { 14, 81 + b }, { 20, 81 + b }, { 19, 79 + b }, { 15, 79 + b } }, BRASS, { band = 1, nopop = true })
    c:part(c:rect(14, 82 + b, 20, 86 + b), GLOW, { band = 1, nopop = true })
    px(c, { { 17, 82 + b }, { 17, 83 + b }, { 17, 84 + b }, { 17, 85 + b }, { 17, 86 + b } }, BRASS.shade)
    px(c, tw > 0 and { { 15, 83 + b }, { 16, 84 + b }, { 15, 84 + b } } or { { 15, 82 + b }, { 15, 83 + b } }, GLOW.hi)
    c:part(c:rect(13, 87 + b, 21, 87 + b), BRASS, { band = 1, nopop = true })
    hand(19.5, 76 + b) hand(44.5, 76 + b)
  else -- ladle with a honey drip
    c:part(c:line({ { 45, 75 + b }, { 49, 61 + b } }, 2), STEEL, { band = 1, nopop = true })
    local bowl = c:ellipse(50.5, 58.5 + b, 3.5, 2.5) c:part(bowl, STEEL, { band = 1, nopop = true }) under(c, bowl, STEEL.deep)
    c:part(c:ellipse(50.5, 57.5 + b, 2.5, 1), HONEY, { band = 1, pop = { x = 49, y = 57 + b } })
    local dr = { { 53, 58 + b }, { 53, 59 + b }, { 53, 60 + b } } if tw > 0 then dr[#dr + 1] = { 53, 61 + b } end
    px(c, dr, HONEY.base)
    hand(45.5, 76 + b) hand(18.5, 76 + b)
  end
  -- head: round, cheek fluff, dark fur crown with drip hairline
  local head = c:ellipse(32, hy, 16, 13.5)
  for _, a in ipairs{ 150, 165, 180, 195, 345, 0, 15, 30 } do
    local r = math.rad(a) head:add(HP.ellipse(32 + math.cos(r) * 15.5, hy + math.sin(r) * 13, 1.5, 1.5)) end
  c:part(head, GOLD, { band = 2, pop = { x = 21, y = hy - 2 } })
  local crown = head:copy():clip(c:rect(0, 0, 63, hy - 6))
  for x = 18, 46 do local d = ({ 1, 2, 0, 1, 2, 0, 1 })[(x * 3) % 7 + 1]
    for y = hy - 5, hy - 6 + d do if head:has(x, y) then crown:set(x, y) end end end
  c:part(crown, FUR, { band = 1, inner = false, pop = { x = 24, y = hy - 10 } })
  -- face: dark compound-eye patches, eyes, muzzle, button nose, smile
  for _, ex in ipairs{ 25.5, 38.5 } do c:part(c:ellipse(ex, hy + 2, 3.5, 3.5), FUR, { band = 1, nopop = true, inner = false }) end
  for _, ex in ipairs{ 24, 37 } do
    if p.blink then for i = 0, 3 do c:put(ex + i, hy + 2, INK) end
    else
      c:put(ex + 1, hy, INK) c:put(ex + 2, hy, INK)
      for _, q in ipairs{ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 }, { 1, 1 } } do c:put(ex + q[1], hy + q[2], "#fdf1d6") end
      c:put(ex + 2, hy + 1, INK) c:put(ex + 1, hy + 2, INK) c:put(ex + 2, hy + 2, INK)
    end
  end
  local mz = c:ellipse(32, hy + 7.5, 4.5, 2.5) c:part(mz, MUZ, { band = 1, nopop = true, inner = false })
  px(c, { { 31, hy + 5 }, { 32, hy + 5 }, { 31, hy + 6 }, { 32, hy + 6 } }, FUR.base) c:put(31, hy + 5, FUR.hi)
  px(c, { { 29, hy + 8 }, { 30, hy + 9 }, { 31, hy + 9 }, { 32, hy + 9 }, { 33, hy + 9 }, { 34, hy + 8 } }, INK)
  px(c, { { 21, hy + 6 }, { 22, hy + 6 }, { 42, hy + 6 }, { 43, hy + 6 } }, BLUSH)
  -- headwear + antenna tips
  local ants
  if V == 1 then -- wide straw hat
    local hm = c:ellipse(32, hy - 9, 19, 4)
    c:part(hm, STRAW, { band = 1, pop = { x = 17, y = hy - 11 } }) under(c, hm, STRAW.deep)
    local cr = c:rrect(24, hy - 18, 40, hy - 9, 4)
    c:part(cr, STRAW, { band = 2, pop = { x = 26, y = hy - 16 } })
    c:part(c:rect(24, hy - 12, 40, hy - 10):clip(cr), LEAF, { band = 1, nopop = true })
    hm:copy():add(cr):each(function(x, y) if c:get(x, y) == STRAW.base and (x + 2 * y) % 5 == 0 then c:put(x, y, STRAW.shade) end end)
    ants = { { { 27, hy - 17 }, { 25, hy - 21 }, { 22, hy - 24 + ad } }, { { 37, hy - 17 }, { 39, hy - 21 }, { 42 + tw, hy - 24 + ad - tw } } }
  elseif V == 2 then -- knit beanie with pom
    local cap = c:ellipse(32, hy - 7, 15.5, 8):clip(c:rect(0, 0, 63, hy - 5))
    c:part(cap, TEAL, { band = 2, pop = { x = 24, y = hy - 12 } })
    local rim = c:rrect(16, hy - 7, 48, hy - 3, 2) c:part(rim, TEAL, { band = 1, nopop = true }) under(c, rim, TEAL.deep)
    for x = 17, 47, 2 do if c:get(x, hy - 5) == TEAL.base then c:put(x, hy - 5, TEAL.shade) end end
    local pom = c:ellipse(34, hy - 16 + ad, 3, 3) c:part(pom, RUST, { band = 1, pop = { x = 33, y = hy - 18 + ad } })
    ants = { { { 22, hy - 10 }, { 19, hy - 15 }, { 17, hy - 20 + ad } }, { { 42, hy - 10 }, { 45, hy - 15 }, { 47 + tw, hy - 20 + ad - tw } } }
  else -- knotted polka-dot kerchief + amber cowlick
    local kf = c:ellipse(32, hy - 5, 16.5, 9.5):clip(c:rect(0, 0, 63, hy - 3))
    c:part(kf, CREAM, { band = 2, pop = { x = 23, y = hy - 11 } })
    for y = hy - 13, hy - 4, 4 do for x = 19 + (y % 8 == 0 and 2 or 0), 46, 5 do
      if kf:has(x, y) and kf:has(x + 1, y) then px(c, { { x, y }, { x + 1, y } }, ROSE.base) end end end
    for x = 16, 48 do if kf:has(x, hy - 3) then c:put(x, hy - 3, CREAM.shade) end end
    local kn = c:ellipse(45, hy - 11, 2.5, 2) kn:add(c:poly{ { 46, hy - 11 }, { 52, hy - 15 - ad }, { 53, hy - 12 - ad }, { 47, hy - 9 } })
    kn:add(c:poly{ { 46, hy - 10 }, { 53, hy - 8 + ad }, { 51, hy - 6 + ad }, { 46, hy - 8 } })
    c:part(kn, CREAM, { band = 1, nopop = true })
    c:put(45, hy - 11, ROSE.base)
    c:part(c:poly{ { 30, hy - 4 }, { 33, hy - 4 }, { 34, hy - 1 }, { 32, hy - 2 }, { 30, hy } }, GOLD, { band = 1, nopop = true, inner = false })
    ants = { { { 27, hy - 12 }, { 25, hy - 17 }, { 23, hy - 22 + ad } }, { { 37, hy - 12 }, { 39, hy - 17 }, { 41 + tw, hy - 22 + ad - tw } } }
  end
  for _, a in ipairs(ants) do local t = a[3] c:part(c:ellipse(t[1] + .5, t[2] - .5, 1.6, 1.6), FUR, { band = 1, pop = { x = t[1] - 1, y = t[2] - 2 } }) end
  c:finish{ outline = true }
  for _, a in ipairs(ants) do c:fillMask(c:line({ a[1], a[2], { a[3][1], a[3][2] + 1 } }, 1), INK) end
  HP.assertClean(c)
  return c
end
local P4 = { { b = 0 }, { b = 1, ad = 1 }, { b = 0 }, { b = 0, blink = true, tw = 1 } }
local frames = {} for i, p in ipairs(P4) do frames[i] = frame(p) end
local W, H, pc = 64, 96, app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local imgs = {}
for f, c in ipairs(frames) do local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % W, i // W, rgba(hex)) end imgs[f] = im end
local strip = Image(W * 4, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
for f = 1, 4 do strip:drawImage(imgs[f], Point((f - 1) * W, 0)) end
local sp = Sprite(W * 4, H, ColorMode.RGB) sp.cels[1].image = strip sp:saveCopyAs(out .. NAME .. ".png") sp:close()
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, 4 do spr:newEmptyFrame() end
for f = 1, 4 do spr:newCel(spr.layers[1], spr.frames[f], imgs[f], Point(0, 0)) end
local tg = spr:newTag(1, 4) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
print(NAME .. " sprite ok")
