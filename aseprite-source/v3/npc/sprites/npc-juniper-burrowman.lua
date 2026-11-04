-- npc-juniper-burrowman sprite (npc2 P1_16) species: field mouse
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local INK = "#2b1c26"
local function R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local function ink(c, pts, w) c:fillMask(c:line(pts, w or 1), INK) end
local function dots(c, list, hex) for _, q in ipairs(list) do c:put(q[1], q[2], hex) end end
local function blink(c, x, y, skin) for i = 0, 4 do for j = 0, 4 do c:put(x + i, y + j, skin) end end for i = 0, 4 do c:put(x + i, y + 3, INK) end end
local function saveSprite(frames, name)
  local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = #frames } } }
  s:save{ png = out .. name .. ".png", scale = 1 }
  local pc = app.pixelColor
  local spr = Sprite(64, 96, ColorMode.RGB)
  for _ = 2, #frames do spr:newEmptyFrame() end
  for f, c in ipairs(frames) do
    local im = Image(64, 96, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
    for i, h in pairs(c.pix) do im:putPixel(i % 64, i // 64, pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255)) end
    spr:newCel(spr.layers[1], spr.frames[f], im, Point(0, 0))
  end
  local tg = spr:newTag(1, #frames) tg.name = "idle"
  spr:saveAs(out .. name .. ".aseprite") spr:close()
end
local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
-- jasper palette (toad) / juniper palette (mouse)
local SKIN = R("#b8d86a", "#7fb04a", "#4f7f4a", "#3a4a5c")
local CRM  = R("#f6eccc", "#e8d6a8", "#c4a88a", "#8a6f7a")
local SWE  = R("#6fb6d8", "#3f86b4", "#2f5a8c", "#2a3a6a")
local CAP  = R("#d8a462", "#b07a3e", "#7f5236", "#573447")
local CAPD = R("#b07a3e", "#8f6038", "#6a4434", "#573447")
local GOLD = R("#f8dc78", "#e0a838", "#a8702e", "#6e4436")
local WOOD = R("#e0b070", "#b7834a", "#835a3c", "#5a3a3c")
local METAL= R("#dfe6ea", "#9fb0bf", "#6b7896", "#464a6e")
local FUR  = R("#d39a62", "#a8693d", "#7a4636", "#533040")
local MUZ  = R("#f3d7a6", "#e0b67d", "#b98763", "#85594f")
local PINK = R("#f8b8c4", "#e88aa0", "#b8607e", "#803e60")
local PURP = R("#9a7ae0", "#6e52b8", "#4b3a8a", "#33285e")
local NAVY = R("#4b3a8a", "#33285e", "#2e2450", "#2e2450")
local SKY  = R("#d6f0f0", "#a6d6dc", "#78a8bc", "#50709a")
local COAT = R("#c8b4a4", "#a08a80", "#776270", "#514258")
local GLOW = R("#fbefb0", "#f6d878", "#e8b050", "#c0803c")
-- Juniper Burrowman: round field mouse, purple pom beanie, sky cowl, taupe coat, long pink tail; prop: little brass lantern.
local NAME = "npc-juniper-burrowman"
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, tw, pd, le = p.b or 0, p.tw or 0, p.pd or 0, p.le or 0
  c:groundShadow(32, 89.5, 14, 3.5)
  -- tail (base fixed, tip twitches)
  c:part(c:line({ { 41, 85 }, { 48, 87 }, { 53, 84 }, { 54 + tw, 79 - tw } }, 2), PINK, { band = 1, nopop = true })
  -- feet
  c:part(c:ellipse(27, 88.5, 3.5, 2), PINK, { band = 1, nopop = true })
  c:part(c:ellipse(37, 88.5, 3.5, 2), PINK, { band = 1, nopop = true })
  -- coat
  local coat = c:ellipse(32, 77 + b, 12, 10):clip(c:rect(0, 0, 63, 87))
  c:part(coat, COAT, { band = 2, pop = { x = 24, y = 72 + b } })
  c:fillMask(c:line({ { 32, 70 + b }, { 32, 86 } }, 1):clip(coat), COAT.shade)
  c:put(34, 74 + b, GOLD.base) c:put(34, 79 + b, GOLD.base)
  -- right paw
  c:part(c:ellipse(44, 72 + b, 3, 4), COAT, { band = 1, nopop = true })
  c:part(c:ellipse(44.5, 76.5 + b, 2.5, 2), FUR, { band = 1, nopop = true })
  -- lantern on left (hangs, settles one frame late)
  local ly = 76 + b + (p.ll or 0)
  ink(c, { { 15, ly - 4 }, { 17, ly - 6 }, { 19, ly - 4 } })
  c:part(c:rect(13, ly - 3, 21, ly - 2), GOLD, { band = 1, nopop = true })
  c:part(c:rect(14, ly - 1, 20, ly + 6), GOLD, { band = 1, nopop = true })
  c:fillMask(c:rect(15, ly, 19, ly + 5), GLOW.base)
  dots(c, { { 15, ly }, { 16, ly } }, GLOW.hi)
  dots(c, { { 17, ly + 3 }, { 17, ly + 2 } }, "#f08838")
  dots(c, { { 19, ly + 5 }, { 18, ly + 5 } }, GLOW.shade)
  c:part(c:ellipse(19.5, 70 + b, 3, 4), COAT, { band = 1, nopop = true })
  c:part(c:ellipse(17.5, 72 + b, 2.5, 2), FUR, { band = 1, nopop = true })
  -- cowl
  c:part(c:ellipse(32, 66 + b, 14, 4), SKY, { band = 1, pop = { x = 22, y = 64 + b } })
  -- ears
  local ey = 47 + b + pd
  c:part(c:ellipse(19, ey + le, 5.5, 5.5), FUR, { band = 1, nopop = true })
  c:part(c:ellipse(45, ey, 5.5, 5.5), FUR, { band = 1, nopop = true })
  c:part(c:ellipse(19.5, ey + 0.5 + le, 3, 3), PINK, { band = 1, nopop = true })
  c:part(c:ellipse(44.5, ey + 0.5, 3, 3), PINK, { band = 1, nopop = true })
  -- head
  c:part(c:ellipse(32, 55 + b, 13, 11), FUR, { band = 2, pop = { x = 23, y = 50 + b } })
  c:part(c:ellipse(32, 60 + b, 7, 4), MUZ, { band = 1, nopop = true })
  c:part(c:rect(31, 57 + b, 33, 58 + b), PINK, { band = 1, nopop = true }) c:put(31, 57 + b, PINK.hi)
  dots(c, { { 32, 59 + b }, { 31, 61 + b }, { 33, 61 + b } }, INK)
  c:fillMask(c:line({ { 24, 59 + b }, { 21, 58 + b } }, 1), FUR.deep)
  c:fillMask(c:line({ { 40, 59 + b }, { 43, 58 + b } }, 1), FUR.deep)
  if p.blink then blink(c, 24, 51 + b, FUR.base) blink(c, 35, 51 + b, FUR.base)
  else c:eyeLocked(24, 51 + b) c:eyeLocked(35, 51 + b) end
  -- beanie + band + pom
  c:part(c:ellipse(32, 46 + b, 11, 7):clip(c:rect(0, 0, 63, 46 + b)), PURP, { band = 2, pop = { x = 25, y = 42 + b } })
  c:part(c:rrect(21, 45 + b, 43, 48 + b, 1), NAVY, { band = 1, nopop = true })
  for x = 23, 41, 3 do c:put(x, 46 + b, GOLD.base) end
  c:part(c:ellipse(32, 37 + b + pd, 3, 3), PURP, { band = 1, pop = { x = 31, y = 36 + b + pd } })
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
saveSprite({ frame{}, frame{ b = 1, pd = 1 }, frame{ ll = 1 }, frame{ blink = true, tw = 1, le = -1 } }, NAME)
