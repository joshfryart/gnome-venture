-- npc-unknown sprite (npc2 P1_37) species: moth
-- The Unknown: a hushed moth stranger, wide brown brimmed hat with crooked tip + gold band, folded eyespot wings as a cloak, feathery antennae, little lantern (prop).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-unknown"
local INK, CREAM = P.ink, P.cream
local function eye(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, INK) end return end
  c:put(x + 1, y, INK) c:put(x + 2, y, INK)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 } }) do c:put(x + q[1], y + q[2], CREAM) end
  c:put(x + 1, y + 1, CREAM) c:put(x + 2, y + 1, INK) c:put(x + 1, y + 2, INK) c:put(x + 2, y + 2, INK)
end
local FUZZ = { hi = "#f2e6cc", base = "#d4c4a8", shade = "#9a8a9a", deep = "#655a76" }
local HAT = { hi = "#a8785a", base = "#7e5040", shade = "#5a3a4a", deep = "#3e2a3c" }
local WING = { hi = "#a690c2", base = "#76609a", shade = "#53437a", deep = "#3a2d58" }
local GLOW = { hi = "#fff2b0", base = "#ffd468", shade = "#f0a040", deep = "#b8683c" }
local GOLD = P.gold
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, scale = 1, name = NAME }
  local b, s = p.b, p.s or 0
  c:groundShadow(32, 89, 12, 3)
  -- small dark feet (fixed)
  for _, fx in ipairs{ 28, 36 } do c:part(c:ellipse(fx, 88, 2.5, 1.5), HAT, { nopop = true }) end
  -- wing cloak: folded tent with scalloped hem
  local cloak = c:poly{ { 23, 58 + b }, { 41, 58 + b }, { 47, 85 + b }, { 17, 85 + b } }
  for _, x in ipairs{ 18, 23, 28, 36, 41, 46 } do cloak:add(c:ellipse(x, 85 + b, 2.5, 1.5)) end
  c:part(cloak, WING, { pop = { x = 22, y = 64 + b } })
  for y = 62, 86 do if cloak:has(32, y + b) then c:put(32, y + b, WING.deep) end end
  for _, x in ipairs{ 25, 39 } do
    local r = c:ellipse(x, 76 + b, 2.5, 2.5)
    c:fillMask(r, GOLD.base) c:fillMask(c:ellipse(x, 76 + b, 1.5, 1.5), WING.deep) c:put(x - 1, 75 + b, GOLD.hi)
  end
  for _, q in ipairs{ { 24, 67 }, { 26, 68 }, { 28, 69 }, { 40, 67 }, { 38, 68 }, { 36, 69 } } do c:put(q[1], q[2] + b, WING.hi) end
  -- paw + lantern hanging at the right front
  c:part(c:ellipse(45, 69 + b, 2, 2), FUZZ, { nopop = true })
  c:put(45 + s, 71 + b, GOLD.deep) c:put(46 + s, 72 + b, GOLD.deep)
  local lan = c:rrect(44 + s, 73 + b, 49 + s, 80 + b, 1)
  c:part(lan, GOLD, { nopop = true })
  c:fillMask(c:rect(45 + s, 75 + b, 48 + s, 79 + b), GLOW.base)
  c:put(46 + s, 76 + b, GLOW.hi) c:put(47 + s, 77 + b, GLOW.hi) c:put(46 + s, 77 + b, GLOW.hi)
  c:put(48 + s, 79 + b, GLOW.shade) c:put(45 + s, 79 + b, GLOW.shade)
  -- antennae (behind the hat), feathery barbs
  local ad = p.ad or 0
  for _, sg in ipairs{ -1, 1 } do
    local x0, y0, x1, y1 = 32 + sg * 7, 38 + b, 32 + sg * 15, 25 + b + ad
    local m = c:line({ { x0, y0 }, { x1, y1 } }, 1)
    for i = 1, 5 do local t = i / 6
      local x, y = math.floor(x0 + (x1 - x0) * t + .5), math.floor(y0 + (y1 - y0) * t + .5)
      m:set(x + sg, y) m:set(x - sg, y - 1) end
    c:part(m, FUZZ, { nopop = true, inner = false })
  end
  -- fluffy ruff
  local ruff = c:ellipse(32, 57 + b, 11, 3.5)
  for _, x in ipairs{ 22, 26, 30, 34, 38, 42 } do ruff:add(c:ellipse(x, 59.5 + b, 1.5, 1.5)) end
  c:part(ruff, FUZZ, { pop = { x = 24, y = 55 + b } })
  -- fuzzy head
  local head = c:ellipse(32, 47 + b, 11, 9)
  head:add(c:ellipse(21.5, 49 + b, 1.5, 1.5)) head:add(c:ellipse(42.5, 49 + b, 1.5, 1.5))
  c:part(head, FUZZ, { nopop = true })
  head:each(function(x, y) if y - b >= 42 and y - b <= 43 then c:put(x, y, FUZZ.shade) end end)
  eye(c, 25, 45 + b, p.blink) eye(c, 35, 45 + b, p.blink)
  c:put(31, 51 + b, FUZZ.hi) c:put(32, 51 + b, FUZZ.hi) c:put(32, 52 + b, FUZZ.shade)
  c:put(31, 53 + b, HAT.deep) c:put(32, 54 + b, HAT.deep) c:put(33, 53 + b, HAT.deep)
  c:cheek(23, 51 + b) c:cheek(40, 51 + b)
  -- hat: wide flat brim, squat cone with crooked tip and gold bead
  local hat = c:ellipse(32, 39 + b, 17, 3.5)
  hat:add(c:poly{ { 24, 39 + b }, { 40, 39 + b }, { 37, 27 + b }, { 28, 27 + b } })
  hat:add(c:line({ { 32, 28 + b }, { 34, 21 + b }, { 38, 17 + b }, { 42, 16 + b } }, 3))
  c:part(hat, HAT, { pop = { x = 29, y = 29 + b } })
  for x = 25, 39 do if hat:has(x, 35 + b) then c:put(x, 35 + b, GOLD.shade) end if hat:has(x, 34 + b) then c:put(x, 34 + b, GOLD.base) end end
  for x = 17, 47, 2 do c:put(x, 40 + b, GOLD.base) end
  c:part(c:ellipse(43, 16 + b + (p.pdy or 0), 1.5, 1.5), GOLD, { pop = { x = 42, y = 15 + b + (p.pdy or 0) } })
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = { frame{ b = 0 }, frame{ b = 1, s = 1, pdy = 1, ad = 1 }, frame{ b = 0 }, frame{ b = 0, blink = true } }
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
