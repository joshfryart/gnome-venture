-- folk-shrew-2 sprite (folk F1_3) variant: 2
-- Hearth Pop v3 generic rest-stop shrew villager, 64x96 cell, 3/4 top-down, feet y=90, idle(4).

local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local W, H = 64, 96
local NAME, R, BEHIND, CLOTHES, NECK, PROP, HAT
local C
local function F(m, r, px, py, band, inner)
  C:part(m, r, { band = band or 2, pop = px and { x = px, y = py } or nil, nopop = (px == nil), inner = inner })
  return m
end
local function U(...) local a = { ... } local m = a[1] for i = 2, #a do m:add(a[i]) end return m end
local function under(m, hex)
  local l = {}
  m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do C:put(q[1], q[2], hex) end
end
local function dots(list, hex) for _, q in ipairs(list) do C:put(q[1], q[2], hex) end end
-- tiny round shrew ears, pink inner; right ear flicks up 1px on the twitch frame
local function EARS(b, p, y)
  for i, ex in ipairs{ 19.5, 44.5 } do
    local ey = y + b - ((i == 2 and (p.tw or 0) > 0) and 1 or 0)
    F(C:ellipse(ex, ey, 3.5, 3.5), R.fur, i == 1 and 17 or nil, ey - 2, 1, false)
    F(C:ellipse(ex + (i == 1 and 0.5 or -0.5), ey + 0.5, 1.5, 1.5), R.pink, nil, nil, 1, false)
  end
end
local function eye(x, y)
  C:put(x + 1, y, P.ink) C:put(x + 2, y, P.ink)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } }) do C:put(x + q[1], y + q[2], P.cream) end
  C:put(x + 1, y + 1, P.cream) C:put(x + 2, y + 1, P.ink) C:put(x + 1, y + 2, P.ink) C:put(x + 2, y + 2, P.ink)
end

NAME = "folk-shrew-2"

R = {
  fur = { hi = "#a89c98", base = "#7e7280", shade = "#585068", deep = "#3a344a" },
  belly = { hi = "#e6dcd0", base = "#c8bab0", shade = "#9a8a94", deep = "#6c5e70" },
  pink = { hi = "#f2b4b4", base = "#d88892", shade = "#a85e7a", deep = "#74405c" },
  tail = { hi = "#968a90", base = "#6c6070", shade = "#4c445a", deep = "#332e40" },
  scarf = { hi = "#f6bc66", base = "#dc8a3e", shade = "#a45a40", deep = "#683846" },
  coat = { hi = "#7c9ed0", base = "#5272a2", shade = "#3c4e7c", deep = "#2e3658" },
  cap = { hi = "#c8b07a", base = "#9c8456", shade = "#6c5a4c", deep = "#463a3e" },
  pack = { hi = "#d8c088", base = "#b0945e", shade = "#7c6450", deep = "#4e3e3e" },
  roll = { hi = "#e88a80", base = "#c05a5c", shade = "#8a3e52", deep = "#5a2c42" },
  brass = { hi = "#f8dc90", base = "#d4a44c", shade = "#9a6c44", deep = "#5e4238" },
  glow = { hi = "#fff0b2", base = "#ffd068", shade = "#eca24a", deep = "#c8703a" },
  bg = { base = "#f7cf8a", shade = "#e0a868", deep = "#b47e52" },
}
R.arm = R.coat

-- traveller: tweed flat cap, mustard scarf with a fringed tail, indigo coat, bedroll pack, glowing brass lantern.
BEHIND = function(b, p)
  F(C:rrect(15, 60 + b, 49, 82 + b, 4), R.pack, 16, 62 + b, 2)
  local roll = C:rrect(12, 55 + b, 52, 61 + b, 3)
  F(roll, R.roll, 14, 56 + b, 2)
  for _, x in ipairs{ 18, 46 } do for y = 55, 61 do C:put(x, y + b, R.pack.shade) end end
  dots({ { 13, 58 + b }, { 14, 57 + b }, { 14, 59 + b }, { 51, 58 + b }, { 50, 57 + b }, { 50, 59 + b } }, R.roll.deep)
end
CLOTHES = function(b, p, body)
  F(body, R.coat, 24, 69 + b, 2)
  for y = 70, 85 do C:put(32, y + b, R.coat.deep) end
  for _, y in ipairs{ 71, 75, 79 } do F(C:rect(33, y + b, 34, y + 1 + b), R.brass, nil, nil, 1, false) end
  F(C:line({ { 24, 65 + b }, { 25, 78 + b } }, 2), R.pack, nil, nil, 1, false)
  F(C:line({ { 40, 65 + b }, { 39, 78 + b } }, 2), R.pack, nil, nil, 1, false)
end
NECK = function(b, p)
  local s = (p.tw or 0) + (p.s or 0)
  local sc = C:rrect(22, 58 + b, 42, 64 + b, 2)
  F(sc, R.scarf, 23, 58 + b, 2)
  for x = 24, 41, 3 do C:put(x, 62 + b, R.scarf.shade) end
  local tail = C:poly{ { 38, 61 + b }, { 42, 61 + b }, { 44 + s, 73 + b }, { 40 + s, 73 + b } }
  F(tail, R.scarf, 39, 63 + b, 1, false)
  for i = 0, 4, 2 do C:put(40 + s + i, 73 + b, R.scarf.deep) end
end
PROP = function(b, p)
  local x, y = 44 + (p.s or 0), 79 + b
  F(C:rect(x - 3, y, x + 2, y + 1), R.brass, x - 3, y, 1, false)
  C:fillMask(C:rect(x - 3, y + 2, x + 2, y + 7), R.glow.base)
  dots({ { x - 1, y + 4 }, { x, y + 4 }, { x - 1, y + 5 }, { x, y + 5 } }, R.glow.hi)
  for yy = y + 2, y + 7 do C:put(x + 1, yy, R.glow.shade) C:put(x - 3, yy, R.brass.shade) C:put(x + 2, yy, R.brass.deep) end
  F(C:rect(x - 3, y + 8, x + 2, y + 8), R.brass, nil, nil, 1, false)
end
HAT = function(b, p)
  local cap = C:ellipse(32, 41 + b, 15.5, 7.5):clip(C:rect(0, 0, 63, 43 + b))
  F(cap, R.cap, 22, 36 + b, 2)
  local l = {}
  cap:each(function(x, y) if (x + y) % 4 == 0 and (x - y) % 3 == 0 then l[#l + 1] = { x, y } end end)
  dots(l, R.cap.shade)
  local peak = C:ellipse(32, 42.5 + b, 8, 1.5)
  F(peak, R.cap, nil, nil, 1, false)
  under(peak, R.cap.deep)
  dots({ { 31, 35 + b }, { 32, 35 + b } }, R.cap.deep)
  EARS(b, p, 44)
end

local function frame(p)
  local c = HP.canvas{ w = W, h = H, name = NAME }
  C = c
  local b, tw = p.b or 0, p.tw or 0
  c:groundShadow(32, 89, 14, 3)
  -- long thin shrew tail curling out on the ground (tip flicks on the twitch frame)
  F(c:line({ { 39, 84 }, { 46, 87 }, { 52, 86 }, { 55 + tw, 82 - tw } }, 2), R.tail, nil, nil, 1, false)
  BEHIND(b, p)
  local body = c:ellipse(32, 75 + b, 11.5, 10.5)
  F(body, R.fur, 24, 69 + b, 2)
  F(c:ellipse(32.5, 77 + b, 6.5, 7.5):clip(body), R.belly, nil, nil, 1, false)
  CLOTHES(b, p, body)
  -- tiny pink five-toed feet (never move)
  for _, fx in ipairs{ 27, 37 } do
    F(c:ellipse(fx, 88, 3.5, 2), R.pink, fx - 2, 87, 1, false)
    dots({ { fx - 1, 89 }, { fx + 1, 89 } }, R.pink.shade)
  end
  PROP(b, p)
  for i, ax in ipairs{ 20.5, 43.5 } do
    F(c:ellipse(ax, 72 + b, 2.5, 4.5), R.arm, i == 1 and 19 or nil, 69 + b, 1, false)
    F(c:ellipse(ax, 77 + b, 2, 1.8), R.pink, nil, nil, 1, false)
  end
  F(c:rect(25, 58 + b, 39, 66 + b), R.fur, nil, nil, 1, false)
  if NECK then NECK(b, p) end
  -- big round head with cheek fluff
  local head = U(c:ellipse(32, 48 + b, 15, 12.5), c:poly{ { 18, 46 + b }, { 14, 53 + b }, { 21, 55 + b } }, c:poly{ { 46, 46 + b }, { 50, 53 + b }, { 43, 55 + b } })
  F(head, R.fur, 22, 40 + b, 2)
  for _, s in ipairs{ { 25, 41 }, { 29, 39 }, { 34, 39 }, { 39, 41 } } do dots({ { s[1], s[2] + b }, { s[1] + 1, s[2] - 1 + b } }, R.fur.hi) end
  -- long pointed mobile shrew snout over the chest, pink bulb nose
  local sn = U(c:poly{ { 26, 52 + b }, { 38, 52 + b }, { 34.5, 66 + b }, { 29.5, 66 + b } }, c:ellipse(32, 53 + b, 6.5, 4))
  F(sn, R.fur, 29, 51 + b, 1, false)
  for y = 55, 63 do dots({ { 31, y + b } }, R.fur.hi) end
  under(sn, R.fur.deep)
  F(c:ellipse(32, 66.5 + b, 2.5, 2), R.pink, 31, 65 + b, 1, false)
  dots({ { 31, 67 + b }, { 33, 67 + b } }, R.pink.deep)
  if p.blink then
    for _, x in ipairs{ 24, 37 } do for i = 0, 3 do c:put(x + i, 47 + b, P.ink) end end
  else eye(24, 45 + b) eye(37, 45 + b) end
  c:cheek(21, 51 + b) c:cheek(41, 51 + b)
  HAT(b, p)
  c:finish{ outline = true }
  for _, w in ipairs{ { 26, 58, 22, 57 }, { 27, 60, 23, 61 }, { 38, 58, 42, 57 }, { 37, 60, 41, 61 } } do
    c:fillMask(c:line({ { w[1], w[2] + b }, { w[3], w[4] + b } }, 1), R.fur.deep)
  end
  HP.assertClean(c)
  return c
end

local PARAMS = { { b = 0 }, { b = 1, s = 1 }, { b = 0 }, { b = 0, blink = true, tw = 1 } }
local frames = {}
for _, p in ipairs(PARAMS) do frames[#frames + 1] = frame(p) end
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local imgs = {}
for f, c in ipairs(frames) do
  local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % W, i // W, rgba(hex)) end
  imgs[f] = im
end
local strip = Image(W * 4, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
for f = 1, 4 do strip:drawImage(imgs[f], Point((f - 1) * W, 0)) end
local s1 = Sprite(W * 4, H, ColorMode.RGB) s1.cels[1].image = strip s1:saveCopyAs(out .. NAME .. ".png") s1:close()
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, 4 do spr:newEmptyFrame() end
for f = 1, 4 do spr:newCel(spr.layers[1], spr.frames[f], imgs[f], Point(0, 0)) end
local tg = spr:newTag(1, 4) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
print(NAME .. " sprite ok")
