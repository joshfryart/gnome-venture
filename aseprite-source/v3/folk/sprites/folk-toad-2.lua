-- folk-toad-2 sprite (folk F2_9) variant: 2
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
local NAME = "folk-toad-2"
local S = R("#e2ba7a", "#b2884e", "#7c5c4c", "#4a3a50")
local B = R("#f6ecc0", "#e0cc94", "#ae9a7e", "#706070")
local SC = R("#86dcc8", "#3ca2a2", "#2c6c80", "#283e5c")
local PK = R("#8e94d4", "#5c60aa", "#40407c", "#2e2a54")
local RL = R("#e47e8c", "#b24c64", "#7c3252", "#4e2442")
local BR = R("#fff0a6", "#e8b244", "#aa723c", "#6a4436")
local DISC = R("#c4ece2", "#8ad0c0", "#5aa0a0", "#3a7280")
H.back = function(c, b, p)
  c:part(c:rrect(17, 58 + b, 47, 80 + b, 4), PK, { band = 2, nopop = true })
  local rl = c:ellipse(32, 40 + b, 18, 3.5)
  c:part(rl, RL, { band = 1, pop = { x = 18, y = 38 + b } })
  for _, x in ipairs({ 22, 23, 41, 42 }) do for y = 37, 43 do if rl:has(x, y + b) then c:put(x, y + b, (x == 22 or x == 41) and PK.base or PK.deep) end end end
  c:put(15, 40 + b, RL.deep) c:put(16, 39 + b, RL.deep) c:put(48, 40 + b, RL.deep) c:put(47, 41 + b, RL.deep)
end
H.clothes = function(c, b, p)
  c:part(c:line({ { 24, 66 + b }, { 23, 78 + b } }, 2), PK, { band = 1, nopop = true })
  c:part(c:line({ { 40, 66 + b }, { 41, 78 + b } }, 2), PK, { band = 1, nopop = true })
  c:put(23, 74 + b, BR.base) c:put(41, 74 + b, BR.base)
  c:part(c:rrect(20, 63 + b, 44, 67 + b, 2), SC, { band = 1, pop = { x = 22, y = 64 + b } })
  c:part(c:poly({ { 25, 66 + b }, { 29, 66 + b }, { 28, 76 + b }, { 24, 75 + b } }), SC, { band = 1, nopop = true })
  c:put(24, 76 + b, SC.shade) c:put(26, 77 + b, SC.shade) c:put(28, 77 + b, SC.shade)
end
H.prop = function(c, b, p)
  local lx = 48 + (p.tw or 0)
  c:fillMask(c:line({ { 46, 78 + b }, { lx + 2, 80 + b } }, 1), BR.deep)
  c:part(c:rrect(lx, 81 + b, lx + 5, 82 + b, 1), BR, { band = 1, nopop = true })
  c:part(c:rect(lx, 83 + b, lx + 5, 87 + b), BR, { band = 1, nopop = true })
  for y = 84, 86 do for x = lx + 1, lx + 4 do c:put(x, y + b, (x <= lx + 2 and y <= 85) and "#fff2bc" or "#ffd862") end end
  c:part(c:rect(lx, 88 + b, lx + 5, 88 + b), BR, { band = 1, nopop = true })
end
H.top = function(c, b, p)
  for y = 43, 52 do c:put(31, y + b, "#f6de70") c:put(32, y + b, "#d8b04e") end
  for _, q in ipairs({ { 20, 53 }, { 22, 56 }, { 42, 56 }, { 43, 53 }, { 27, 50 }, { 36, 50 } }) do c:put(q[1], q[2] + b, S.shade) c:put(q[1] + 1, q[2] + b, S.shade) end
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
