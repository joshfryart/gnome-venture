-- folk-shrew-3 sprite (folk F1_3) variant: 3
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

NAME = "folk-shrew-3"

R = {
  fur = { hi = "#c89c74", base = "#a07456", shade = "#704e5a", deep = "#48323f" },
  belly = { hi = "#f4e2c0", base = "#dcc09a", shade = "#b09080", deep = "#806474" },
  pink = { hi = "#f8c0b6", base = "#e69494", shade = "#b4667e", deep = "#804660" },
  tail = { hi = "#ac8466", base = "#86604e", shade = "#5e4452", deep = "#3e2c3a" },
  smock = { hi = "#d88ea4", base = "#b0607e", shade = "#7e4266", deep = "#52304e" },
  apron = { hi = "#fbf0d6", base = "#ecdcbc", shade = "#c6b09c", deep = "#92807c" },
  scarf = { hi = "#8ed6c2", base = "#52aa9a", shade = "#3c7c7e", deep = "#2c525a" },
  wood = { hi = "#ecc08a", base = "#c8915a", shade = "#90604a", deep = "#5c3e3c" },
  soup = { hi = "#ffc870", base = "#f0a040", shade = "#c8702e", deep = "#8a4a30" },
  bg = { base = "#a8e2d2", shade = "#78c2b2", deep = "#56998e" },
}
R.arm = R.smock

-- cook: teal polka-dot headscarf with a top knot (ears through it), plum smock, cream apron, wooden soup ladle.
NECK = nil
BEHIND = function(b, p) end
CLOTHES = function(b, p, body)
  F(body, R.smock, 24, 69 + b, 2)
  local ap = C:rrect(25, 67 + b, 39, 87 + b, 2):clip(body:copy():grow(1))
  F(ap, R.apron, 26, 68 + b, 1)
  F(C:rrect(29, 77 + b, 35, 81 + b, 1), R.apron, nil, nil, 1)
  for x = 21, 43 do if body:has(x, 72 + b) and not ap:has(x, 72 + b) then C:put(x, 72 + b, R.smock.deep) end end
end
PROP = function(b, p)
  F(C:line({ { 44, 79 + b }, { 49, 66 + b }, { 53, 56 + b } }, 2), R.wood, nil, nil, 1, false)
  local bowl = C:ellipse(55, 53 + b, 4.5, 2.5)
  F(bowl, R.wood, 52, 52 + b, 1)
  F(C:ellipse(55, 52.5 + b, 2.5, 1.2), R.soup, 54, 52 + b, 1, false)
  if (p.tw or 0) > 0 then dots({ { 58, 57 + b } }, R.soup.base) end
end
HAT = function(b, p)
  local sc = C:ellipse(32, 48 + b, 15.5, 13):clip(C:rect(0, 0, 63, 41 + b))
  F(sc, R.scarf, 21, 38 + b, 2)
  local l = {}
  sc:each(function(x, y) if (x % 4 == 1) and ((y - b) % 3 == ((x // 4) % 2) * 1 + 0) then l[#l + 1] = { x, y } end end)
  dots(l, R.scarf.hi)
  under(sc, R.scarf.deep)
  local lob = U(C:ellipse(27.5, 33 + b, 4, 2.5), C:ellipse(36.5, 33 + b, 4, 2.5))
  F(lob, R.scarf, 25, 32 + b, 1)
  F(C:ellipse(32, 34.5 + b, 2, 2), R.scarf, nil, nil, 1, false)
  dots({ { 31, 34 + b }, { 33, 35 + b } }, R.scarf.deep)
  EARS(b, p, 39)
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
