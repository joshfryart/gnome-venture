-- npc-pip-burrowell sprite (npc2 P1_29) species: field mouse
-- Burrowing field mouse: huge round ears, crooked floppy brown cone hat, ochre vest, long pink tail, prop: little spade planted in the ground.
-- 64x96 cell, feet y=90 x=32. idle(4): base / breath(1px lower, hat tip settles) / base / blink + tail-tip flick.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-pip-burrowell"
local FUR = { hi = "#cfc3c6", base = "#a0939c", shade = "#71667e", deep = "#4a3f5c" }
local BEL = { hi = "#f4e6d4", base = "#e2cdb8", shade = "#b8a0a0", deep = "#7e6a80" }
local PNK = { hi = "#f9c6d2", base = "#ec98b2", shade = "#c46c96", deep = "#8a4a78" }
local HAT = { hi = "#b98656", base = "#8e5a3a", shade = "#653d36", deep = "#452a35" }
local VST = { hi = "#f2d06c", base = "#d49c3c", shade = "#a26535", deep = "#6b3e3c" }
local WOD = { hi = "#e9c38a", base = "#c4925a", shade = "#8f6046", deep = "#5c3b3e" }
local MET = { hi = "#e4ecee", base = "#a6b6c6", shade = "#6e7c9a", deep = "#46496c" }
local function eye(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, P.ink) end return end
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs{ {0,1},{3,1},{0,2},{3,2},{1,3},{2,3},{1,1} } do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function build(frames)
  local W, H, N = 64, 96, #frames
  local pc = app.pixelColor
  local function rgba(h) return pc.rgba(tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16), 255) end
  local imgs = {}
  for f, c in ipairs(frames) do
    local im = Image(W, H, ColorMode.RGB) im:clear(pc.rgba(0,0,0,0))
    for i, hex in pairs(c.pix) do im:putPixel(i % W, i // W, rgba(hex)) end
    imgs[f] = im
  end
  local strip = Image(W * N, H, ColorMode.RGB) strip:clear(pc.rgba(0,0,0,0))
  for f = 1, N do strip:drawImage(imgs[f], Point((f - 1) * W, 0)) end
  local s1 = Sprite(W * N, H, ColorMode.RGB) s1.cels[1].image = strip
  s1:saveCopyAs(out .. NAME .. ".png") s1:close()
  local spr = Sprite(W, H, ColorMode.RGB)
  for _ = 2, N do spr:newEmptyFrame() end
  local Ly = spr.layers[1] Ly.name = NAME
  for f = 1, N do spr:newCel(Ly, spr.frames[f], imgs[f], Point(0, 0)) end
  local tg = spr:newTag(1, N) tg.name = "idle"
  for f = 1, N do spr.frames[f].duration = (f == 2 or f == 4) and 0.35 or 0.55 end
  spr:saveAs(out .. NAME .. ".aseprite") spr:close()
  print(NAME .. ": " .. N .. " frames -> " .. out)
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, scale = 1, name = NAME }
  local b = p.bob or 0
  c:groundShadow(32, 89.5, 12, 3)
  -- spade (static, blade in the ground on the left)
  c:part(c:rect(13, 58, 14, 81), WOD, { band = 1, nopop = true })
  c:part(c:rect(11, 56, 16, 57), WOD, { band = 1, nopop = true })
  c:part(c:poly{ { 10, 81 }, { 17, 81 }, { 17, 86 }, { 14, 89 }, { 13, 89 }, { 10, 86 } }, MET, { band = 1, pop = { x = 11, y = 82 } })
  -- tail behind (twitches at the tip)
  local tw = p.tail or 0
  c:part(c:line({ { 38, 86 }, { 47, 87 }, { 52, 83 }, { 53, 77 }, { 51 + tw, 72 + (p.td or 0) } }, 2), PNK, { band = 1, nopop = true })
  for _, fx in ipairs{ 28, 36 } do c:part(c:ellipse(fx, 88, 3, 2), PNK, { band = 1, nopop = true }) end
  -- pear body: vest with cream belly
  local body = c:ellipse(32, 77 + b, 10, 10)
  c:part(body, VST, { band = 2, pop = { x = 25, y = 72 + b } })
  c:part(c:ellipse(32, 79 + b, 4.5, 6):clip(body), BEL, { band = 1, nopop = true })
  c:put(27, 78 + b, VST.deep) c:put(27, 82 + b, VST.deep)
  -- arms: left grips spade
  c:part(c:ellipse(19.5, 74 + b, 3, 3), FUR, { band = 1, nopop = true })
  c:part(c:ellipse(15.5, 72 + b, 2, 2), PNK, { band = 1, nopop = true })
  c:part(c:ellipse(42.5, 77 + b, 2.5, 3.5), FUR, { band = 1, nopop = true })
  -- ears
  c:part(c:ellipse(19, 47 + b, 7, 7), FUR, { band = 1, nopop = true })
  c:part(c:ellipse(45, 47 + b + (p.ear or 0), 7, 7), FUR, { band = 2, nopop = true })
  c:part(c:ellipse(19, 47.5 + b, 4.5, 4.5), PNK, { band = 1, pop = { x = 16, y = 45 + b } })
  c:part(c:ellipse(45, 47.5 + b + (p.ear or 0), 4.5, 4.5), PNK, { band = 2, nopop = true })
  -- head + snout
  c:part(c:ellipse(32, 55 + b, 12, 9.5), FUR, { band = 2, pop = { x = 23, y = 51 + b } })
  c:part(c:ellipse(32, 60.5 + b, 5, 3.5), BEL, { band = 1, nopop = true })
  c:part(c:ellipse(32, 62.5 + b, 1.5, 1.2), PNK, { band = 1, nopop = true })
  c:put(31, 62 + b, PNK.hi)
  eye(c, 25, 53 + b, p.blink) eye(c, 35, 53 + b, p.blink)
  -- crooked cone hat with floppy tip
  local hd = p.hd or 0
  local hm = c:ellipse(32, 46 + b, 12.5, 3)
  hm:add(c:poly{ { 23, 46 + b }, { 41, 46 + b }, { 34, 29 + b }, { 29, 29 + b } })
  hm:add(c:line({ { 31, 30 + b }, { 28, 24 + b }, { 23, 22 + b + hd } }, 3))
  c:part(hm, HAT, { band = 2, pop = { x = 28, y = 34 + b } })
  for x = 20, 44 do if hm:has(x, 44 + b) then c:put(x, 44 + b, (x % 3 == 0) and VST.base or HAT.deep) end end
  c:part(c:ellipse(21.5, 22.5 + b + hd, 1.5, 1.5), VST, { band = 1, nopop = true })
  c:finish{ outline = true }
  -- whiskers
  for _, w in ipairs{ { {26,60},{23,59} }, { {26,62},{23,63} }, { {38,60},{41,59} }, { {38,62},{41,63} } } do
    c:fillMask(c:line({ { w[1][1], w[1][2] + b }, { w[2][1], w[2][2] + b } }, 1), FUR.deep)
  end
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ {}, { bob = 1, hd = 1, td = 1 }, {}, { blink = true, tail = 2, td = -1 } } do frames[#frames + 1] = frame(p) end
build(frames)
