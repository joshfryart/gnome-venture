-- npc-pak-lontar sprite (npc2 P1_27) species: water buffalo
-- Elder kerbau (water buffalo): sweeping bone horns, a flat-topped songkok cap, white walrus moustache + brows,
-- blue batik shirt; prop/quirk: a woven lontar-palm basket with a ginger kitten peeking out. 64x96, idle 4f.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-pak-lontar"
local W, H = 64, 96
local HIDE = { hi = "#a88c80", base = "#806660", shade = "#5c4656", deep = "#413044" }
local MUZ = { hi = "#f2d6bc", base = "#d6ac94", shade = "#ae8278", deep = "#7a5460" }
local HORN = { hi = "#f6e8c6", base = "#d8c09a", shade = "#a8907e", deep = "#6f5e6a" }
local PECI = { hi = "#625a8e", base = "#433c6c", shade = "#322c56", deep = "#262046" }
local SHIRT = { hi = "#7aaee0", base = "#4a7abc", shade = "#38559a", deep = "#2c3a6e" }
local HAIR = { hi = "#fbf1de", base = "#e6d8c4", shade = "#bcaab0", deep = "#8a7a8e" }
local BASK = { hi = "#f4cc76", base = "#d49c4a", shade = "#a86c3a", deep = "#7a4636" }
local CAT = { hi = "#f8b860", base = "#e2802e", shade = "#b8562e", deep = "#7e3a34" }
local HOOF = { hi = "#7a6a80", base = "#584a64", shade = "#3f344e", deep = "#2e2640" }
local GOLDR = { hi = "#ffe08a", base = "#f0b43c", shade = "#c47e2a", deep = "#8a4e26" }
local function eye(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, P.ink) end return end
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } }) do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function frame(p)
  local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
  local b, ce = p.bob or 0, p.ear or 0
  c:groundShadow(32, 88.5, 14, 3)
  c:part(c:rect(25, 80 + b, 29, 86), HIDE, { band = 1, nopop = true })
  c:part(c:rect(35, 80 + b, 39, 86), HIDE, { band = 1, nopop = true })
  for _, x in ipairs{ 27, 37 } do c:part(c:ellipse(x, 87.5, 3.5, 2), HOOF, { band = 1, nopop = true }) c:put(x, 87, HOOF.deep) end
  -- body: batik shirt
  c:part(c:rect(27, 53 + b, 37, 60 + b), HIDE, { band = 1, nopop = true })
  local sh = c:ellipse(32, 68 + b, 13, 12):clip(c:rect(0, 0, 63, 81 + b))
  c:part(sh, SHIRT, { band = 2, pop = { x = 23, y = 62 + b } })
  for y = 61, 80, 4 do for x = 22 + ((y // 4) % 2) * 2, 44, 4 do
    if sh:has(x - 1, y + b) and sh:has(x + 1, y + b) then c:put(x, y + b, GOLDR.base) end end end
  for _, cx in ipairs{ 19, 45 } do c:part(c:ellipse(cx, 66 + b, 3.5, 5.5), SHIRT, { band = 1, nopop = true }) end
  -- kitten in basket
  local ek = c:ellipse(32, 70 + b, 4, 3)
  ek:add(c:poly{ { 28, 69 + b }, { 29, 65 + b }, { 31, 68 + b } })
  ek:add(c:poly{ { 33, 68 + b }, { 35, 65 + b + ce }, { 36, 69 + b } })
  c:part(ek, CAT, { band = 1, pop = { x = 29, y = 68 + b } })
  c:put(30, 70 + b, P.ink) c:put(34, 70 + b, P.ink) c:put(32, 71 + b, "#e88a9a")
  c:put(31, 68 + b, CAT.shade) c:put(32, 67 + b, CAT.shade) c:put(33, 68 + b, CAT.shade)
  -- woven lontar basket
  local bowl = c:ellipse(32, 74 + b, 11, 6):clip(c:rect(0, 74 + b, 63, 95))
  c:part(bowl, BASK, { band = 2, nopop = true })
  bowl:each(function(x, y) if ((x // 2) + (y // 2)) % 2 == 0 and c:get(x, y) == BASK.base then c:put(x, y, BASK.shade) end end)
  c:part(c:ellipse(32, 74 + b, 11, 1.5), BASK, { band = 1, pop = { x = 24, y = 73 + b } })
  for _, x in ipairs{ 21, 43 } do c:part(c:ellipse(x, 74 + b, 2.5, 2), HIDE, { band = 1, nopop = true }) end
  -- horns, ears, head
  for _, s in ipairs{ -1, 1 } do
    local function X(x) return 32 + s * (32 - x) end
    c:part(c:line({ { X(22), 40 + b }, { X(15), 39 + b }, { X(11), 35 + b }, { X(11), 30 + b } }, 3), HORN, { band = 1, nopop = true })
    c:part(c:line({ { X(11), 30 + b }, { X(12), 26 + b } }, 2), HORN, { band = 1, nopop = true })
    c:put(X(14), 38 + b, HORN.shade) c:put(X(11), 33 + b, HORN.shade)
    c:part(c:ellipse(X(18), 46 + b, 3, 1.5), HIDE, { band = 1, nopop = true })
  end
  c:put(20, 37 + b, HORN.hi) c:put(10, 31 + b, HORN.hi)
  c:part(c:ellipse(32, 44 + b, 12, 10), HIDE, { band = 2, pop = { x = 24, y = 38 + b } })
  c:part(c:ellipse(32, 51 + b, 7.5, 4.5), MUZ, { band = 1, pop = { x = 28, y = 48 + b } })
  c:put(29, 51 + b, MUZ.deep) c:put(35, 51 + b, MUZ.deep) c:put(29, 52 + b, MUZ.shade) c:put(35, 52 + b, MUZ.shade)
  local mu = c:ellipse(28, 55 + b, 3, 1) mu:add(c:ellipse(36, 55 + b, 3, 1))
  mu:add(c:rect(24, 53 + b, 24, 54 + b)) mu:add(c:rect(40, 53 + b, 40, 54 + b))
  c:part(mu, HAIR, { band = 1, nopop = true })
  c:part(c:rect(23, 39 + b, 27, 39 + b), HAIR, { band = 1, nopop = true })
  c:part(c:rect(37, 39 + b, 41, 39 + b), HAIR, { band = 1, nopop = true })
  eye(c, 24, 41 + b, p.blink) eye(c, 37, 41 + b, p.blink)
  -- songkok cap
  c:part(c:rrect(24, 28 + b, 40, 35 + b, 1), PECI, { band = 2, pop = { x = 26, y = 29 + b } })
  for x = 25, 39 do c:put(x, 30 + b, PECI.deep) end
  for x = 25, 39, 2 do c:put(x, 34 + b, GOLDR.base) end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local FR = { { bob = 0 }, { bob = 1 }, { bob = 0 }, { bob = 0, blink = true, ear = 1 } }

local pc = app.pixelColor
local function img(c)
  local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % W, i // W, pc.rgba(tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16), 255)) end
  return im
end
local ims = {}
for _, p in ipairs(FR) do local c = frame(p) ims[#ims + 1] = img(c) end
local strip = Image(W * 4, H, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
for f = 1, 4 do strip:drawImage(ims[f], Point((f - 1) * W, 0)) end
local ss = Sprite(W * 4, H, ColorMode.RGB) ss.cels[1].image = strip ss:saveCopyAs(out .. NAME .. ".png") ss:close()
local spr = Sprite(W, H, ColorMode.RGB)
for _ = 2, 4 do spr:newEmptyFrame() end
for f = 1, 4 do spr:newCel(spr.layers[1], spr.frames[f], ims[f], Point(0, 0)) spr.frames[f].duration = (f == 4) and 0.2 or 0.35 end
spr.layers[1].name = "npc"
local tg = spr:newTag(1, 4) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
print(NAME .. " ok")

