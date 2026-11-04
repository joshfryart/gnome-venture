-- npc-jasper-burrowman sprite (npc2 P1_16) species: burrowing toad
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
-- Jasper Burrowman: squat burrowing toad, tweed flat cap, blue V-neck sweater; prop: garden spade planted at his side.
local NAME = "npc-jasper-burrowman"
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.b or 0
  c:groundShadow(32, 89.5, 17, 3.5)
  -- spade (planted, never moves)
  c:part(c:poly{ { 44, 80 }, { 52, 80 }, { 52, 86 }, { 48, 89 }, { 44, 86 } }, METAL, { band = 1, pop = { x = 45, y = 81 } })
  c:part(c:rect(47, 59, 48, 79), WOOD, { band = 1, nopop = true })
  c:part(c:rrect(45, 56, 50, 58, 1), WOOD, { band = 1, nopop = true })
  -- body
  local body = c:ellipse(32, 76 + b, 14, 10):clip(c:rect(0, 0, 63, 87))
  c:part(body, SWE, { band = 2, pop = { x = 23, y = 71 + b } })
  for x = 20, 44, 2 do if body:has(x, 85) then c:put(x, 85, SWE.shade) end end
  c:part(c:poly{ { 25, 67 + b }, { 39, 67 + b }, { 32, 75 + b } }, CRM, { band = 1, nopop = true })
  c:part(c:poly{ { 28, 67 + b }, { 36, 67 + b }, { 32, 72 + b } }, SKIN, { band = 1, nopop = true })
  c:put(32, 77 + b, GOLD.base) c:put(32, 81 + b, GOLD.base)
  -- arms: left hangs, right grips spade
  c:part(c:ellipse(19, 73 + b, 3.5, 4.5), SWE, { band = 1, nopop = true })
  c:part(c:ellipse(18.5, 78 + b, 2.5, 2), SKIN, { band = 1, nopop = true })
  c:part(c:ellipse(45, 67 + b, 3.5, 4), SWE, { band = 1, nopop = true })
  c:part(c:ellipse(47.5, 61 + b, 2.5, 2.5), SKIN, { band = 1, nopop = true })
  -- webbed feet (fixed)
  c:part(c:ellipse(25, 88, 5, 2.5), SKIN, { band = 1, pop = { x = 22, y = 87 } })
  c:part(c:ellipse(39, 88, 5, 2.5), SKIN, { band = 1, pop = { x = 36, y = 87 } })
  dots(c, { { 23, 90 }, { 26, 90 }, { 37, 90 }, { 40, 90 } }, SKIN.deep)
  -- wide head
  local head = c:ellipse(32, 58 + b, 16, 10)
  c:part(head, SKIN, { band = 2, pop = { x = 20, y = 54 + b } })
  c:part(c:ellipse(32, 64 + b, 10, p.puff and 4.5 or 3.5):clip(head), CRM, { band = 1, nopop = true })
  c:part(c:ellipse(32, 56.5 + b, 4, 2), SKIN, { band = 1, pop = { x = 30, y = 55 + b } })
  dots(c, { { 30, 57 + b }, { 34, 57 + b } }, SKIN.deep)
  ink(c, { { 19, 58 + b }, { 23, 61 + b }, { 32, 62 + b }, { 41, 61 + b }, { 45, 58 + b } })
  dots(c, { { 20, 53 + b }, { 44, 52 + b }, { 42, 56 + b }, { 22, 63 + b }, { 45, 61 + b } }, SKIN.shade)
  -- flat cap (crown + brim)
  local crown = c:ellipse(32, 38 + b, 15, 6.5)
  c:part(crown, CAP, { band = 2, pop = { x = 22, y = 35 + b } })
  for _, x in ipairs{ 25, 32, 39 } do c:fillMask(c:line({ { x, 32 + b }, { x, 44 + b } }, 1):clip(crown:shrink(1)), GOLD.shade) end
  c:fillMask(c:line({ { 17, 38 + b }, { 47, 38 + b } }, 1):clip(crown:shrink(1)), GOLD.shade)
  c:put(32, 32 + b, GOLD.hi)
  c:part(c:ellipse(32, 43.5 + b, 15, 2.5), CAPD, { band = 1, nopop = true })
  -- eye bumps under the brim
  c:part(c:ellipse(24.5, 49 + b, 5, 4), SKIN, { band = 1, nopop = true })
  c:part(c:ellipse(39.5, 49 + b, 5, 4), SKIN, { band = 1, nopop = true })
  if p.blink then blink(c, 22, 47 + b, SKIN.base) blink(c, 37, 47 + b, SKIN.base)
  else c:eyeLocked(22, 47 + b) c:eyeLocked(37, 47 + b) end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
saveSprite({ frame{}, frame{ b = 1 }, frame{}, frame{ blink = true, puff = true } }, NAME)
