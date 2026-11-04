-- folk-toad-1 sprite (folk F2_9) variant: 1
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local INK = "#2b1c26"
local GOLDI = "#dca23c"
local function R(a, b, c2, d) return { hi = a, base = b, shade = c2, deep = d } end
local function hash(x, y, s) local n = math.sin(x * 12.9898 + y * 78.233 + s * 37.719) * 43758.5453 return n - math.floor(n) end
local function warts(c, m, r, seed, dens)
  local l = {}
  m:each(function(x, y) if hash(x, y, seed) < dens and m:has(x - 1, y - 1) and m:has(x + 2, y + 2) then l[#l + 1] = { x, y } end end)
  for _, p in ipairs(l) do
    local v = c:get(p[1], p[2])
    if v == r.base or v == r.shade then c:put(p[1], p[2], r.hi) c:put(p[1] + 1, p[2] + 1, r.deep) end
  end
end
local H = {}
local NAME = "folk-toad-1"
local S = R("#b8c45c", "#7f9a40", "#566e44", "#383c4e")
local B = R("#f4e8aa", "#dcc47c", "#a8906c", "#6e5a60")
local STRAW = R("#f8de8c", "#deb658", "#a87e44", "#6e4a3e")
local RUST = R("#f28c5c", "#c45230", "#8a3232", "#56243c")
local DEN = R("#a0bcdc", "#6c8aba", "#4c5a8c", "#34365e")
local STEEL = R("#e2e8ea", "#9eaab6", "#666e88", "#3e3e5a")
local WOOD = R("#d69c5c", "#9e663a", "#6a4036", "#42283c")
local DISC = R("#cfe6f2", "#8cc0d8", "#6a90b8", "#4e6492")
local function weave(c, m, r) local l = {} m:each(function(x, y) if (x + 2 * y) % 4 == 0 and c:get(x, y) == r.base then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do c:put(q[1], q[2], r.shade) end end
H.clothes = function(c, b, p)
  c:part(c:rrect(25, 70 + b, 39, 85 + b, 2), DEN, { band = 1, pop = { x = 26, y = 72 + b } })
  c:part(c:line({ { 26, 70 + b }, { 24, 65 + b } }, 2), DEN, { band = 1, nopop = true })
  c:part(c:line({ { 38, 70 + b }, { 40, 65 + b } }, 2), DEN, { band = 1, nopop = true })
  c:stitch({ { 28, 78 + b }, { 36, 78 + b } })
  c:put(26, 71 + b, STRAW.hi) c:put(38, 71 + b, STRAW.hi)
  c:part(c:poly({ { 22, 64 + b }, { 42, 64 + b }, { 32, 71 + b } }), RUST, { band = 1, pop = { x = 25, y = 65 + b } })
end
H.prop = function(c, b, p)
  local t = p.tw or 0
  c:part(c:rrect(44, 71 + b, 46, 78 + b, 1), WOOD, { band = 1, nopop = true })
  c:part(c:rect(44, 79 + b, 46, 79 + b), STEEL, { band = 1, nopop = true })
  c:part(c:poly({ { 42, 80 + b }, { 48, 80 + b }, { 45 + t, 86 + b } }), STEEL, { band = 1, pop = { x = 43, y = 80 + b } })
  c:put(45 + t, 85 + b, WOOD.shade)
end
H.top = function(c, b, p)
  local brim = c:ellipse(32, 42 + b, 14, 3.5)
  c:part(brim, STRAW, { band = 1, nopop = true }) weave(c, brim, STRAW)
  local cr = c:rrect(25, 33 + b, 39, 41 + b, 3)
  c:part(cr, STRAW, { band = 2, pop = { x = 27, y = 34 + b } }) weave(c, cr, STRAW)
  for x = 25, 39 do for y = 38, 39 do if cr:has(x, y + b) then c:put(x, y + b, (y == 39) and RUST.shade or RUST.base) end end end
  c:put(36, 36 + b, "#6aa84a") c:put(37, 35 + b, "#8cc45a") c:put(37, 37 + b, "#4e7a44") c:put(38, 36 + b, "#6aa84a")
end
local function eye4(c, x, y, blink, lid)
  if blink then
    for j = 0, 3 do for i = 0, 3 do c:put(x + i, y + j, lid) end end
    for i = 0, 3 do c:put(x + i, y + 2, INK) end
    return
  end
  c:put(x + 1, y, INK) c:put(x + 2, y, INK)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } }) do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, INK) c:put(x + 1, y + 2, INK) c:put(x + 2, y + 2, INK)
end
local function toad(c, p)
  local b = p.bob or 0
  c:groundShadow(32, 89.5, 15, 3)
  if H.back then H.back(c, b, p) end
  for _, sx in ipairs({ -1, 1 }) do c:part(c:ellipse(32 + sx * 8.5, 83.5, 5, 4), S, { band = 1, nopop = true }) end
  for _, fx in ipairs({ 23, 41 }) do
    local ft = c:ellipse(fx, 88.5, 5.5, 1.8)
    for _, t in ipairs({ -4, 0, 4 }) do ft:add(c:ellipse(fx + t, 89.2, 1.3, 1.1)) end
    c:part(ft, S, { band = 1, nopop = true })
    c:put(fx - 2, 89, S.deep) c:put(fx + 2, 89, S.deep)
  end
  local body = c:ellipse(32, 75 + b, 12, 10)
  c:part(body, S, { band = 2, pop = { x = 24, y = 70 + b } })
  warts(c, body, S, 3, 0.06)
  c:part(c:ellipse(32, 78 + b, 7, 6), B, { band = 1, nopop = true })
  for _, sx in ipairs({ -1, 1 }) do c:part(c:ellipse(32 + sx * 13, 72 + b, 2.5, 4.5), S, { band = 1, nopop = true }) end
  if H.clothes then H.clothes(c, b, p) end
  if H.prop then H.prop(c, b, p) end
  for _, sx in ipairs({ -1, 1 }) do
    local hx = 32 + sx * 13
    c:part(c:ellipse(hx, 77 + b, 2.5, 2), S, { band = 1, nopop = true })
    c:put(hx, 78 + b, S.deep)
  end
  local head = c:ellipse(32, 54 + b, 16, 11)
  head:add(c:ellipse(17, 51 + b, 2.5, 2)) head:add(c:ellipse(47, 51 + b, 2.5, 2))
  c:part(head, S, { band = 2, pop = { x = 21, y = 47 + b } })
  warts(c, head, S, 7, 0.05)
  c:part(c:ellipse(32, 64 + b, 10, 3):clip(head), B, { band = 1, nopop = true })
  c:put(30, 55 + b, S.deep) c:put(33, 55 + b, S.deep)
  c:fillMask(c:line({ { 18, 57 + b }, { 20, 59 + b }, { 25, 60 + b }, { 32, 61 + b }, { 39, 60 + b }, { 44, 59 + b }, { 46, 57 + b } }, 1), INK)
  for _, q in ipairs({ { 20, 61 }, { 21, 61 }, { 42, 61 }, { 43, 61 } }) do c:put(q[1], q[2] + b, P.petal.base) end
  if H.top then H.top(c, b, p) end
  for _, ex in ipairs({ 24, 40 }) do
    c:part(c:ellipse(ex, 45 + b, 5, 4.5), S, { band = 1, pop = { x = ex - 3, y = 42 + b } })
    c:fillMask(c:ellipse(ex, 46 + b, 2.8, 2.8), GOLDI)
  end
  eye4(c, 22, 44 + b, p.blink, S.base) eye4(c, 38, 44 + b, p.blink, S.base)
  if H.front then H.front(c, b, p) end
  c:finish{ outline = true }
  HP.assertClean(c)
end
local FR = { { bob = 0 }, { bob = 1 }, { bob = 0 }, { bob = 0, blink = true, tw = 1 } }
local frames = {}
for i, p in ipairs(FR) do local c = HP.canvas{ w = 64, h = 96, name = NAME } toad(c, p) frames[i] = c end
local W, Hh, N = 64, 96, 4
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local imgs = {}
for f, c in ipairs(frames) do
  local im = Image(W, Hh, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % W, i // W, rgba(hex)) end
  imgs[f] = im
end
local strip = Image(W * N, Hh, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
for f = 1, N do strip:drawImage(imgs[f], Point((f - 1) * W, 0)) end
local sp = Sprite(W * N, Hh, ColorMode.RGB) sp.cels[1].image = strip sp:saveCopyAs(out .. NAME .. ".png") sp:close()
local spr = Sprite(W, Hh, ColorMode.RGB)
for _ = 2, N do spr:newEmptyFrame() end
local L = spr.layers[1] L.name = NAME
for f = 1, N do spr:newCel(L, spr.frames[f], imgs[f], Point(0, 0)) end
local tg = spr:newTag(1, N) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
print(NAME .. " sprite ok")
