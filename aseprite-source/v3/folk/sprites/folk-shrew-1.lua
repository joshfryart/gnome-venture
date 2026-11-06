-- folk-shrew-1 sprite (folk F1_3) variant: 1
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

NAME = "folk-shrew-1"

R = {
  fur = { hi = "#b48c6c", base = "#8c6852", shade = "#604654", deep = "#3f2d3d" },
  belly = { hi = "#f0dcb8", base = "#d6b994", shade = "#ab8c80", deep = "#7a6070" },
  pink = { hi = "#f6bcb2", base = "#e2908e", shade = "#b2627a", deep = "#7e425e" },
  tail = { hi = "#9a7a66", base = "#7a5c4c", shade = "#56404e", deep = "#3a2a38" },
  cloth = { hi = "#b2cc7e", base = "#82a45a", shade = "#567858", deep = "#38524a" },
  straw = { hi = "#f4dc8e", base = "#dbb65c", shade = "#aa824c", deep = "#6e5040" },
  band = { hi = "#f08a7a", base = "#d05a5a", shade = "#9a3e56", deep = "#622c46" },
  wick = { hi = "#eab878", base = "#c48a52", shade = "#8c5e48", deep = "#5c3c3e" },
  leaf = { hi = "#bfe07a", base = "#7cb84a", shade = "#4c8448", deep = "#30583e" },
  carrot = { hi = "#ffb860", base = "#ee8436", shade = "#b85a3a", deep = "#7a3a36" },
  bg = { base = "#d2e6a0", shade = "#a8c67c", deep = "#7e9e64" },
}
R.arm = R.fur

-- gardener: wide woven straw hat with ears poking through two holes, sage dungarees, wicker basket of greens + carrot.
NECK = nil
BEHIND = function(b, p) end
CLOTHES = function(b, p, body)
  local m = U(body:copy():clip(C:rect(0, 72 + b, 63, 95)), C:rrect(26, 66 + b, 38, 73 + b, 1),
    C:line({ { 27, 67 + b }, { 23, 65 + b } }, 2), C:line({ { 37, 67 + b }, { 41, 65 + b } }, 2))
  F(m, R.cloth, 26, 73 + b, 2)
  for y = 80, 85 do dots({ { 32, y + b } }, R.cloth.deep) end
  for x = 28, 36 do dots({ { x, 75 + b } }, R.cloth.shade) end
  dots({ { 27, 67 + b }, { 37, 67 + b } }, R.straw.hi)
end
PROP = function(b, p)
  local s = p.tw or 0
  F(U(C:poly{ { 10, 78 + b }, { 8 - s, 70 + b }, { 13, 77 + b } }, C:poly{ { 13, 78 + b }, { 14, 68 + b }, { 16, 78 + b } }), R.leaf, 13, 70 + b, 1)
  F(C:line({ { 17, 78 + b }, { 19, 72 + b } }, 3), R.carrot, 18, 73 + b, 1, false)
  dots({ { 19, 71 + b }, { 20, 70 + b }, { 18, 70 + b } }, R.leaf.base)
  local bk = C:poly{ { 8, 78 + b }, { 21, 78 + b }, { 19, 86 + b }, { 10, 86 + b } }
  F(bk, R.wick, 10, 79 + b, 2)
  local l = {}
  bk:each(function(x, y) if (x + (y % 2) * 2) % 4 == 0 then l[#l + 1] = { x, y } end end)
  dots(l, R.wick.shade)
  under(bk, R.wick.deep)
  F(C:rect(7, 77 + b, 22, 78 + b), R.wick, 8, 77 + b, 1, false)
end
HAT = function(b, p)
  local brim = C:ellipse(32, 38 + b, 19.5, 5)
  F(brim, R.straw, 16, 36 + b, 2)
  local l = {}
  brim:each(function(x, y) if (x * 2 + y) % 5 == 0 then l[#l + 1] = { x, y } end end)
  dots(l, R.straw.shade)
  under(brim, R.straw.deep)
  EARS(b, p, 35)
  local crown = C:ellipse(32, 33 + b, 10, 6.5)
  F(crown, R.straw, 26, 28 + b, 2)
  l = {}
  crown:each(function(x, y) if (x + y * 2) % 5 == 0 and y < 34 + b then l[#l + 1] = { x, y } end end)
  dots(l, R.straw.shade)
  F(crown:copy():clip(C:rect(0, 35 + b, 63, 37 + b)), R.band, nil, nil, 1, false)
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
