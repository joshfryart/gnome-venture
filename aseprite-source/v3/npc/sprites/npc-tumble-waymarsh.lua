-- npc-tumble-waymarsh sprite (npc2 P1_37) species: hare
-- Tumble Waymarsh, wandering hare waymarker: orange travel coat, green scarf, brass monocle on a chain (prop).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-tumble-waymarsh"
local INK, CREAM = P.ink, P.cream
local function eye(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, INK) end return end
  c:put(x + 1, y, INK) c:put(x + 2, y, INK)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } }) do c:put(x + q[1], y + q[2], CREAM) end
  c:put(x + 1, y + 1, CREAM) c:put(x + 2, y + 1, INK) c:put(x + 1, y + 2, INK) c:put(x + 2, y + 2, INK)
end
local FUR = { hi = "#e8c08a", base = "#c48a52", shade = "#8e5a5a", deep = "#5a3a4e" }
local MUZ = { hi = "#f6ead2", base = "#eedcb8", shade = "#c9b0a6", deep = "#8f7a86" }
local EAR = { hi = "#f6b8c4", base = "#e48ea6", shade = "#b46a8a", deep = "#7e4a6e" }
local COAT = { hi = "#f6c45a", base = "#e8962c", shade = "#b0603c", deep = "#6e3a48" }
local SCARF = { hi = "#a6d46a", base = "#5fa040", shade = "#3c6e48", deep = "#284a46" }
local BRASS = { hi = "#fff0a0", base = "#e8b838", shade = "#a8743a", deep = "#6e4a3a" }
local GLASS = { hi = "#eef6f0", base = "#bfe0e6", shade = "#8eb4c8", deep = "#6a86a8" }
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, scale = 1, name = NAME }
  local b, l = p.b, p.l or 0
  c:groundShadow(32, 89, 13, 3)
  -- coat body with flared hem
  local body = c:ellipse(32, 73 + b, 11.5, 11)
  body:add(c:poly{ { 21, 76 + b }, { 43, 76 + b }, { 45, 85 + b }, { 19, 85 + b } })
  c:part(body, COAT, { pop = { x = 25, y = 66 + b } })
  for y = 66, 85 do if body:has(32, y + b) then c:put(32, y + b, COAT.deep) end end
  for _, y in ipairs{ 70, 75, 80 } do c:put(34, y + b, BRASS.base) c:put(35, y + b, BRASS.shade) end
  -- sleeves + paws
  for _, sx in ipairs{ 20, 44 } do
    c:part(c:ellipse(sx, 71 + b, 3, 5), COAT, { nopop = true })
    c:part(c:ellipse(sx, 77 + b, 2.5, 2), FUR, { nopop = true })
  end
  -- long hare feet (fixed)
  for _, fx in ipairs{ 26, 38 } do
    c:part(c:ellipse(fx, 87.5, 3.5, 2), FUR, { nopop = true })
    c:put(fx - 1, 86, FUR.hi) c:put(fx, 89, FUR.deep) c:put(fx + 1, 89, FUR.deep)
  end
  -- scarf: cowl + hanging tail with stripes
  c:part(c:rrect(21, 59 + b, 43, 63 + b, 2), SCARF, { pop = { x = 24, y = 60 + b } })
  local tail = c:poly{ { 36, 62 + b }, { 40, 62 + b }, { 41, 72 + b }, { 37, 71 + b } }
  c:part(tail, SCARF, { nopop = true })
  for x = 36, 41 do if tail:has(x, 66 + b) then c:put(x, 66 + b, SCARF.hi) end if tail:has(x, 69 + b) then c:put(x, 69 + b, SCARF.hi) end end
  -- ears (behind head)
  local function ear(pts, w, r) local m = c:line(pts, w) m:add(c:ellipse(pts[#pts][1], pts[#pts][2], r, r)) return m end
  local lp = { { 27, 40 + b }, { 25, 28 + b }, { 24 - l, 16 + b } }
  local rp = p.tw and { { 37, 40 + b }, { 39, 28 + b }, { 40, 23 + b }, { 44, 20 + b } } or { { 37, 40 + b }, { 39, 28 + b }, { 40 + l, 16 + b } }
  local eL, eR = ear(lp, 5, 2.5), ear(rp, 5, 2.5)
  c:part(eL, FUR, { pop = { x = 23, y = 17 + b } }) c:part(eR, FUR, { nopop = true })
  for _, q in ipairs{ { lp, eL }, { rp, eR } } do
    local inn = c:line(q[1], 2):clip(q[2]:shrink(1)):clip(c:rect(0, 0, 63, 36 + b))
    c:fillMask(inn, EAR.base)
  end
  -- head with cheek fluff
  local head = c:ellipse(32, 46 + b, 13, 11)
  head:add(c:ellipse(19.5, 50 + b, 2.5, 2.5)) head:add(c:ellipse(44.5, 50 + b, 2.5, 2.5))
  c:part(head, FUR, { pop = { x = 25, y = 38 + b } })
  c:part(c:ellipse(32, 52 + b, 5, 3), MUZ, { nopop = true })
  -- nose, mouth, teeth
  c:put(31, 50 + b, EAR.base) c:put(32, 50 + b, EAR.base) c:put(33, 50 + b, EAR.shade) c:put(32, 51 + b, EAR.shade)
  c:put(32, 52 + b, P.ink) c:put(31, 53 + b, P.ink) c:put(33, 53 + b, P.ink) c:put(32, 54 + b, MUZ.hi)
  -- eyes; monocle glass behind the right eye, brass ring around
  c:fillMask(c:ellipse(37.5, 45.5 + b, 3, 3), GLASS.base)
  c:put(35, 43 + b, GLASS.hi)
  eye(c, 24, 44 + b, p.blink) eye(c, 36, 44 + b, p.blink)
  local ring = c:ellipse(37.5, 45.5 + b, 4, 4):cut(c:ellipse(37.5, 45.5 + b, 3, 3))
  ring:each(function(x, y) c:put(x, y, (x < 37 and y < 46 + b) and BRASS.hi or ((x > 38 and y > 45 + b) and BRASS.shade or BRASS.base)) end)
  -- chain to the scarf (sways a pixel when settling)
  local cs = p.cs or 0
  for i, q in ipairs{ { 40, 50 }, { 41, 51 }, { 41, 52 }, { 41 + cs, 53 }, { 41 + cs, 54 }, { 40 + cs, 55 }, { 40, 56 }, { 40, 57 } } do
    c:put(q[1], q[2] + b, i % 2 == 0 and BRASS.shade or BRASS.base) end
  c:cheek(21, 50 + b)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = { frame{ b = 0 }, frame{ b = 1, l = 1, cs = 1 }, frame{ b = 0 }, frame{ b = 0, tw = true } }
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local function img(c) local im = Image(64, 96, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, h in pairs(c.pix) do im:putPixel(i % 64, i // 64, rgba(h)) end return im end
local imgs = {} for f, c in ipairs(frames) do imgs[f] = img(c) end
local strip = Image(256, 96, ColorMode.RGB) strip:clear(pc.rgba(0, 0, 0, 0))
for f = 1, 4 do strip:drawImage(imgs[f], Point((f - 1) * 64, 0)) end
local ss = Sprite(256, 96, ColorMode.RGB) ss.cels[1].image = strip ss:saveCopyAs(out .. NAME .. ".png") ss:close()
local spr = Sprite(64, 96, ColorMode.RGB)
for _ = 2, 4 do spr:newEmptyFrame() end
spr.layers[1].name = "npc"
for f = 1, 4 do spr:newCel(spr.layers[1], spr.frames[f], imgs[f], Point(0, 0)) spr.frames[f].duration = (f % 2 == 0) and 0.35 or 0.45 end
local tg = spr:newTag(1, 4) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
print(NAME .. " ok")
