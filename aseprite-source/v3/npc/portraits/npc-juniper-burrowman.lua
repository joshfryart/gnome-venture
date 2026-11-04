-- npc-juniper-burrowman portrait (npc2 P1_16) species: field mouse
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
-- Juniper Burrowman portrait: field mouse, purple pom beanie, sky cowl, taupe coat, holding a brass lantern.
local NAME = "npc-juniper-burrowman"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
-- body + cowl
local body = c:ellipse(39.5, 104, 33, 30):clip(c:rect(0, 72, 79, 99))
c:part(body, COAT, { band = 3, pop = { x = 14, y = 86 } })
c:fillMask(c:line({ { 42, 76 }, { 42, 99 } }, 1):clip(body), COAT.shade)
c:part(c:rect(45, 84, 46, 85), GOLD, { band = 1, nopop = true }) c:part(c:rect(45, 92, 46, 93), GOLD, { band = 1, nopop = true })
c:part(c:ellipse(39.5, 73, 22, 6), SKY, { band = 2, pop = { x = 22, y = 70 } })
for _, x in ipairs{ 28, 36, 44, 52 } do c:put(x, 76, SKY.shade) c:put(x, 77, SKY.shade) end
-- ears
c:part(c:ellipse(18, 36, 9, 9), FUR, { band = 2, nopop = true })
c:part(c:ellipse(61, 36, 9, 9), FUR, { band = 2, nopop = true })
c:part(c:ellipse(19, 37, 5.5, 5.5), PINK, { band = 1, pop = { x = 16, y = 34 } })
c:part(c:ellipse(60, 37, 5.5, 5.5), PINK, { band = 1, pop = { x = 57, y = 34 } })
-- head
c:part(c:ellipse(39.5, 53, 20, 17), FUR, { band = 3, pop = { x = 25, y = 46 } })
c:part(c:ellipse(39.5, 61, 10, 6), MUZ, { band = 2, nopop = true })
c:part(c:poly{ { 36, 56 }, { 43, 56 }, { 39.5, 59.5 } }, PINK, { band = 1, nopop = true })
dots(c, { { 37, 56 }, { 38, 56 } }, PINK.hi)
ink(c, { { 39, 60 }, { 39, 62 } })
dots(c, { { 36, 63 }, { 37, 64 }, { 38, 64 }, { 39, 63 }, { 40, 63 }, { 41, 64 }, { 42, 64 }, { 43, 63 } }, INK)
for _, l in ipairs{ { { 30, 60 }, { 23, 58 } }, { { 30, 62 }, { 23, 63 } }, { { 49, 60 }, { 56, 58 } }, { { 49, 62 }, { 56, 63 } } } do c:fillMask(c:line(l, 1), FUR.deep) end
c:eyeLocked(28, 47) c:eyeLocked(47, 47)
c:cheek(25, 55) c:cheek(52, 55)
-- beanie
c:part(c:ellipse(39.5, 37, 19, 12):clip(c:rect(0, 0, 79, 37)), PURP, { band = 3, pop = { x = 27, y = 30 } })
c:part(c:rrect(20, 35, 59, 40, 2), NAVY, { band = 1, nopop = true })
c:stitch{ { 22, 37 }, { 57, 37 } }
local pom = c:ellipse(39.5, 22, 5, 5)
for _, q in ipairs{ { 34, 21 }, { 45, 21 }, { 39, 16 }, { 36, 18 }, { 43, 18 } } do pom:set(q[1], q[2]) end
c:part(pom, PURP, { band = 1, pop = { x = 37, y = 19 } })
-- lantern (front, lower-left) + paw
local ly = 76
ink(c, { { 13, ly - 4 }, { 18, ly - 9 }, { 23, ly - 4 } })
c:part(c:poly{ { 10, ly }, { 26, ly }, { 23, ly - 3 }, { 13, ly - 3 } }, GOLD, { band = 1, nopop = true })
c:part(c:rect(11, ly + 1, 25, ly + 17), GOLD, { band = 1, pop = { x = 11, y = ly + 1 } })
c:fillMask(c:rect(13, ly + 3, 23, ly + 14), GLOW.base)
c:fillMask(c:rect(13, ly + 12, 23, ly + 14), GLOW.shade)
c:fillMask(c:rect(13, ly + 3, 15, ly + 5), GLOW.hi)
c:fillMask(c:rect(18, ly + 3, 18, ly + 14), GOLD.shade)
c:part(c:ellipse(18, ly + 9, 1.5, 3), R("#fbefb0", "#f08838", "#c05a3a", "#803e60"), { band = 1, nopop = true })
c:part(c:rect(10, ly + 17, 26, ly + 19), GOLD, { band = 1, nopop = true })
c:part(c:ellipse(18, ly - 9, 3.5, 3), FUR, { band = 1, pop = { x = 16, y = ly - 11 } })
c:finish{ outline = true }
backdrop(c, R("#e0d4f0", "#c8b4e0", "#a690c8", "#8a72ae"))
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
