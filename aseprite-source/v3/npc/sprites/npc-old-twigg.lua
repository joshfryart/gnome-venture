-- npc-old-twigg sprite (npc2 P1_27) species: stick insect
-- Elder walking-stick insect: almond seed-bark face, curled antennae, purple stitched hood-shawl, pink skirt,
-- four spindly legs; prop/quirk: a twig cane that is sprouting two fresh leaves. 64x96, idle 4f.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-old-twigg"
local W, H = 64, 96
local BARK = { hi = "#c99c6c", base = "#9a6e48", shade = "#6e4a44", deep = "#4a3040" }
local HOOD = { hi = "#a98ae0", base = "#7f5cc4", shade = "#5c4196", deep = "#3f2c6a" }
local SKIRT = { hi = "#f29ab0", base = "#d9668a", shade = "#a8496e", deep = "#713452" }
local GOLDR = { hi = "#ffe08a", base = "#f0b43c", shade = "#c47e2a", deep = "#8a4e26" }
local LEAF = { hi = "#c4e47a", base = "#7cba48", shade = "#4f8a4e", deep = "#33594a" }
local function eye(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, P.ink) end return end
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } }) do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function frame(p)
  local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
  local b, tip, tw, lf = p.bob or 0, p.tip or 0, p.tw or 0, p.leaf or 0
  c:groundShadow(32, 88.5, 12, 3)
  -- cane: planted, never moves
  c:part(c:line({ { 47, 89 }, { 47, 70 }, { 46, 59 }, { 47, 54 } }, 2), BARK, { band = 1, nopop = true })
  -- spindly legs, feet fixed
  for _, L in ipairs{ { 27, 77, 22, 83, 21, 89 }, { 30, 79, 28, 84, 27, 89 }, { 34, 79, 36, 84, 37, 89 }, { 37, 77, 42, 83, 43, 89 } } do
    c:part(c:line({ { L[1], L[2] + b }, { L[3], L[4] + b }, { L[5], L[6] } }, 2), BARK, { band = 1, nopop = true })
  end
  -- skirt
  local sk = c:poly{ { 24, 62 + b }, { 40, 62 + b }, { 44, 80 + b }, { 20, 80 + b } }
  c:part(sk, SKIRT, { band = 2, pop = { x = 23, y = 70 + b } })
  for x = 21, 43, 2 do if sk:has(x, 80 + b) then c:put(x, 80 + b, SKIRT.deep) end end
  -- hood + shawl
  local sh = c:poly{ { 19, 52 + b }, { 45, 52 + b }, { 48, 68 + b }, { 32, 75 + b }, { 16, 68 + b } }
  sh:add(c:ellipse(32, 38 + b, 13, 16))
  c:part(sh, HOOD, { band = 2, pop = { x = 24, y = 26 + b } })
  for x = 18, 46, 3 do
    local y = math.floor(68 + ((x <= 32) and (x - 16) or (48 - x)) * 7 / 16 - 1 + b)
    if sh:has(x, y) then c:put(x, y, GOLDR.base) end
  end
  c:fillMask(c:line({ { 22, 56 + b }, { 20, 66 + b } }, 1):clip(sh), HOOD.shade)
  -- arm to the cane
  c:part(c:line({ { 42, 60 + b }, { 46, 63 + b } }, 2), BARK, { band = 1, nopop = true })
  c:part(c:ellipse(46.5, 63.5 + b, 1.5, 1.5), BARK, { band = 1, nopop = true })
  -- almond seed face
  local fc = c:ellipse(32, 40 + b, 8, 9)
  fc:add(c:poly{ { 25, 43 + b }, { 39, 43 + b }, { 32, 53 + b } })
  c:part(fc, BARK, { band = 2, pop = { x = 28, y = 34 + b } })
  local ring = fc:copy():grow(1):cut(fc)
  ring:each(function(x, y) if sh:has(x, y) and (x + y) % 3 == 0 then c:put(x, y, GOLDR.base) end end)
  for y = 31, 34 do c:put(32, y + b, BARK.deep) end
  eye(c, 26, 37 + b, p.blink) eye(c, 35, 37 + b, p.blink)
  c:put(32, 43 + b, BARK.hi) c:put(32, 44 + b, BARK.shade) c:put(33, 44 + b, BARK.deep)
  for _, q in ipairs{ { 30, 47 }, { 31, 48 }, { 32, 48 }, { 33, 48 }, { 34, 47 } } do c:put(q[1], q[2] + b, BARK.deep) end
  c:put(26, 43 + b, "#e0849a") c:put(37, 43 + b, "#e0849a")
  -- clasp
  c:part(c:ellipse(32, 56.5 + b, 1.5, 1.5), GOLDR, { band = 1, pop = { x = 31, y = 55 + b } })
  -- curled antennae (tips settle / twitch)
  c:fillMask(c:line({ { 29, 23 + b }, { 26, 15 + b }, { 22, 11 + b + tip }, { 19, 12 + b + tip }, { 19, 15 + b + tip } }, 1), BARK.base)
  c:fillMask(c:line({ { 35, 23 + b }, { 38, 15 + b }, { 42, 11 + b + tip + tw }, { 45, 12 + b + tip + tw }, { 45, 15 + b + tip + tw } }, 1), BARK.base)
  c:put(26, 15 + b, BARK.hi) c:put(38, 15 + b, BARK.hi)
  -- sprouting cane top (quirk)
  c:part(c:ellipse(44.5, 52 + lf, 2, 1), LEAF, { band = 1, nopop = true })
  c:part(c:ellipse(50, 51 - lf, 2, 1), LEAF, { band = 1, nopop = true })
  c:put(44, 51 + lf, LEAF.hi) c:put(49, 50 - lf, LEAF.hi)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local FR = { { bob = 0 }, { bob = 1, tip = 0, leaf = 1 }, { bob = 0 }, { bob = 0, blink = true, tw = -1 } }

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

