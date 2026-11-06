-- npc-petalpin-greenfinger sprite (npc2 P1_29) species: bear cub
-- Gardener bear cub: puffy pink beret with a flower pin, green apron over a blue shirt, prop: small tin watering can.
-- 64x96 cell, feet y=90 x=32. idle(4): base / breath(1px lower, beret nub settles) / base / blink + ear flick + can drip.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-petalpin-greenfinger"
local FUR = { hi = "#f2c27a", base = "#d8954a", shade = "#a8623a", deep = "#6e3a45" }
local CRM = { hi = "#fbefd2", base = "#f0d7a8", shade = "#cfa77e", deep = "#9a6e6e" }
local BER = { hi = "#f79ac0", base = "#e0559a", shade = "#ab3480", deep = "#6e2263" }
local EAR = { hi = "#f7b6c8", base = "#e98aa6", shade = "#c0607f", deep = "#8a3f66" }
local APR = { hi = "#a8d672", base = "#6aa84f", shade = "#3f7a4a", deep = "#284d45" }
local SHI = { hi = "#7fc4e0", base = "#3f8fc0", shade = "#2e5f96", deep = "#283f6e" }
local TIN = { hi = "#e6eef0", base = "#a9bccb", shade = "#6f7f9c", deep = "#454a6e" }
local NOS = { hi = "#e98aa0", base = "#b9506e", shade = "#7e3456", deep = "#56243f" }
local PET = { hi = "#fbe9a0", base = "#f6d35a", shade = "#e0a33a", deep = "#a8623a" }
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
  c:groundShadow(32, 89.5, 13, 3)
  for _, fx in ipairs{ 27, 37 } do c:part(c:ellipse(fx, 87.5, 3.5, 2.5), FUR, { band = 1, nopop = true }) end
  -- body: round shirt + apron
  c:part(c:ellipse(32, 76 + b, 12, 10.5), SHI, { band = 2, pop = { x = 23, y = 71 + b } })
  c:part(c:rrect(25, 71 + b, 39, 86 + b, 3):clip(c:ellipse(32, 76 + b, 12, 10.5)), APR, { band = 1, nopop = true })
  c:part(c:rrect(29, 79 + b, 35, 83 + b, 1), APR, { band = 1, nopop = true })
  c:put(28, 72 + b, APR.hi) c:put(29, 72 + b, APR.hi)
  -- arms
  c:part(c:ellipse(20.5, 75 + b, 3, 4), FUR, { band = 1, nopop = true })
  -- watering can (prop) in the right paw
  c:part(c:line({ { 53, 81 + b }, { 58, 74 + b } }, 2), TIN, { band = 1, nopop = true })
  c:part(c:ellipse(59, 73 + b, 1.5, 1.5), TIN, { band = 1, nopop = true })
  c:part(c:line({ { 45, 73 + b }, { 48, 69 + b }, { 51, 73 + b } }, 1), TIN, { band = 1, nopop = true })
  c:part(c:rrect(44, 73 + b, 53, 83 + b, 2), TIN, { band = 2, pop = { x = 45, y = 75 + b } })
  for x = 45, 52 do c:put(x, 76 + b, TIN.shade) end
  c:part(c:ellipse(44, 76 + b, 3, 3), FUR, { band = 1, nopop = true })
  if p.drip then c:put(60, 77, SHI.hi) c:put(60, 78, SHI.base) end
  -- ears (behind head)
  local eo = p.ear or 0
  c:part(c:ellipse(19.5, 41 + b + eo, 5, 5), FUR, { band = 1, nopop = true })
  c:part(c:ellipse(44.5, 41 + b, 5, 5), FUR, { band = 2, nopop = true })
  c:part(c:ellipse(19.5, 41.5 + b + eo, 2.5, 2.5), EAR, { band = 1, nopop = true })
  c:part(c:ellipse(44.5, 41.5 + b, 2.5, 2.5), EAR, { band = 1, nopop = true })
  -- head
  c:part(c:ellipse(32, 52 + b, 15, 12.5), FUR, { band = 2, pop = { x = 21, y = 47 + b } })
  c:part(c:ellipse(32, 57.5 + b, 6.5, 4.5), CRM, { band = 1, nopop = true })
  c:part(c:ellipse(32, 54.5 + b, 2, 1.5), NOS, { band = 1, nopop = true })
  c:put(31, 54 + b, NOS.hi)
  c:put(31, 59 + b, FUR.deep) c:put(32, 60 + b, FUR.deep) c:put(33, 59 + b, FUR.deep)
  eye(c, 24, 48 + b, p.blink) eye(c, 36, 48 + b, p.blink)
  c:put(22, 54 + b, EAR.base) c:put(23, 54 + b, EAR.base) c:put(41, 54 + b, EAR.base) c:put(42, 54 + b, EAR.base)
  -- beret: puffy, tilted right, darker band, stalk nub
  local nub = p.nub or 0
  c:part(c:ellipse(32.5, 34 + b + nub, 1.5, 2), BER, { band = 1, nopop = true })
  local bm = c:ellipse(33, 40 + b, 14.5, 5.5)
  c:part(bm, BER, { band = 2, pop = { x = 24, y = 37 + b } })
  for x = 19, 47 do if bm:has(x, 44 + b) then c:put(x, 44 + b, BER.shade) end end
  for x = 20, 46, 3 do if bm:has(x, 43 + b) then c:put(x, 43 + b, BER.hi) end end
  -- flower pin (petal pin)
  for _, q in ipairs({ { 41, 39 + b }, { 43, 39 + b }, { 42, 38 + b }, { 42, 40 + b } }) do c:put(q[1], q[2], PET.base) end
  c:put(41, 38 + b, PET.hi) c:put(43, 40 + b, PET.shade) c:put(42, 39 + b, "#e8792f")
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ {}, { bob = 1, nub = 1 }, {}, { blink = true, ear = -1, drip = true } } do frames[#frames + 1] = frame(p) end
build(frames)
