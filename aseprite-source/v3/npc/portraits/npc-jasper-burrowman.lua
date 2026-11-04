-- npc-jasper-burrowman portrait (npc2 P1_16) species: burrowing toad
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
-- Jasper Burrowman portrait: burrowing toad, tweed flat cap, blue sweater, spade over the shoulder.
local NAME = "npc-jasper-burrowman"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
-- spade blade behind shoulder
c:part(c:poly{ { 63, 24 }, { 75, 25 }, { 75, 36 }, { 69, 42 }, { 63, 36 } }, METAL, { band = 2, pop = { x = 65, y = 26 } })
c:fillMask(c:line({ { 69, 28 }, { 69, 37 } }, 1), METAL.shade)
-- body
local body = c:ellipse(39.5, 104, 34, 30):clip(c:rect(0, 70, 79, 99))
c:part(body, SWE, { band = 3, pop = { x = 14, y = 84 } })
for y = 82, 98, 4 do for x = 8 + (y % 8) // 2, 72, 4 do if body:has(x, y) then c:put(x, y, SWE.shade) end end end
c:part(c:poly{ { 27, 70 }, { 52, 70 }, { 39.5, 86 } }, CRM, { band = 1, nopop = true })
c:part(c:poly{ { 31, 70 }, { 48, 70 }, { 39.5, 81 } }, SKIN, { band = 1, nopop = true })
c:part(c:rect(39, 89, 40, 90), GOLD, { band = 1, nopop = true }) c:part(c:rect(39, 95, 40, 96), GOLD, { band = 1, nopop = true })
-- spade handle + paw
c:part(c:line({ { 61, 99 }, { 69, 42 } }, 3), WOOD, { band = 1, nopop = true })
c:part(c:ellipse(62, 88, 4.5, 3.5), SKIN, { band = 1, pop = { x = 60, y = 86 } })
dots(c, { { 59, 89 }, { 62, 90 } }, SKIN.deep)
-- head
local head = c:ellipse(39.5, 57, 21, 13)
c:part(head, SKIN, { band = 3, pop = { x = 24, y = 51 } })
c:part(c:ellipse(39.5, 66, 13, 4):clip(head), CRM, { band = 1, nopop = true })
c:part(c:ellipse(39.5, 54, 5, 3), SKIN, { band = 1, pop = { x = 37, y = 52 } })
dots(c, { { 37, 55 }, { 42, 55 } }, SKIN.deep)
ink(c, { { 20, 58 }, { 27, 61 }, { 39, 62 }, { 52, 61 }, { 59, 58 } })
dots(c, { { 23, 54 }, { 24, 55 }, { 56, 53 }, { 55, 57 }, { 27, 66 }, { 53, 65 }, { 31, 50 } }, SKIN.shade)
-- flat cap
local crown = c:ellipse(39.5, 27, 22, 10)
c:part(crown, CAP, { band = 3, pop = { x = 25, y = 22 } })
for _, x in ipairs{ 28, 39, 50 } do c:fillMask(c:line({ { x, 17 }, { x + (x - 39) // 4, 37 } }, 1):clip(crown:shrink(1)), GOLD.shade) end
c:fillMask(c:line({ { 17, 28 }, { 62, 28 } }, 1):clip(crown:shrink(1)), GOLD.shade)
c:part(c:ellipse(39.5, 17.5, 2, 1.5), CAPD, { band = 1, nopop = true })
c:part(c:ellipse(39.5, 36, 21, 3.5), CAPD, { band = 1, nopop = true })
-- eye bumps + eyes
c:part(c:ellipse(29, 44, 7, 6), SKIN, { band = 1, nopop = true })
c:part(c:ellipse(50, 44, 7, 6), SKIN, { band = 1, nopop = true })
c:eyeLocked(27, 42) c:eyeLocked(48, 42)
c:finish{ outline = true }
backdrop(c, R("#c6e4b0", "#9cc8a0", "#78a688", "#5c8670"))
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
