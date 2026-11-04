-- npc-sakuya-brushwick sprite (npc2 P1_33) species: frog
-- Sakuya Brushwick, grumpy calligrapher frog: wide flat straw kasa, bulging lidded eyes, plum haori over a cream belly,
-- ember sash, webbed feet. Prop: a big ink brush; quirk: ink smudge on the cheek. idle x4: base, breath, base, blink.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-sakuya-brushwick"
local FROG = { hi = "#b6d86a", base = "#7cae44", shade = "#4f8048", deep = "#355a44" }
local BELLY = { hi = P.cream, base = "#f0dca0", shade = "#c8ad7c", deep = "#94786a" }
local STRAW = { hi = "#f2d690", base = "#d6aa5a", shade = "#a87844", deep = "#6e4c40" }
local BRISTLE = { hi = "#6e5a78", base = "#4c3c58", shade = "#3a2c46", deep = "#2f2238" }
local function under(c, m, hex) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end) end
local function eye(c, x, y)
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs{ {0,1},{3,1},{0,2},{3,2},{1,3},{2,3} } do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, hb = p.b or 0, p.hb or 0
  c:groundShadow(32, 88.5, 14, 3)
  for _, fx in ipairs{ 26, 39 } do
    local m = c:ellipse(fx, 87.5, 4, 1.8)
    for _, t in ipairs{ -3, 0, 3 } do m:add(HP.ellipse(fx + t, 88.6, 1.3, 1.3)) end
    c:part(m, FROG, { band = 1, pop = { x = fx - 3, y = 86 } })
  end
  -- haori robe, open front belly, sash
  local robe = c:ellipse(32.5, 70 + b, 12.5, 9.5)
  robe:add(c:rrect(22, 54 + b, 43, 66 + b, 4))
  robe:add(c:poly{ { 20, 72 + b }, { 45, 72 + b }, { 46, 85 + b }, { 19, 85 + b } })
  c:part(robe, P.dusk, { band = 2, pop = { x = 25, y = 63 + b } })
  under(c, robe, P.dusk.deep)
  local bel = c:poly{ { 29, 54 + b }, { 36, 54 + b }, { 38, 85 + b }, { 27, 85 + b } }:clip(robe)
  c:part(bel, BELLY, { band = 1, nopop = true })
  c:fillMask(c:line({ { 29, 54 + b }, { 27, 72 + b } }, 1), P.dusk.hi)
  c:fillMask(c:line({ { 36, 54 + b }, { 38, 72 + b } }, 1), P.dusk.hi)
  c:part(c:rect(19, 74 + b, 46, 76 + b):clip(robe), P.ember, { band = 1, nopop = true })
  c:part(c:rect(31, 73 + b, 34, 77 + b), P.ember, { band = 1, pop = { x = 31, y = 73 + b } })
  for _, s in ipairs{ -1, 1 } do
    local sl = c:rrect(s < 0 and 15 or 44, 64 + b, s < 0 and 21 or 50, 77 + b, 2)
    c:part(sl, P.dusk, { band = 1, nopop = true }) under(c, sl, P.dusk.deep)
  end
  c:part(c:ellipse(18, 78 + b, 2.2, 1.8), FROG, { band = 1, nopop = true })
  -- prop: big ink brush, tip down
  local hd = c:line({ { 48, 59 + b }, { 47, 79 + b } }, 2)
  c:fillMask(hd:copy():grow(1), P.ink) c:part(hd, P.wood, { band = 1, nopop = true })
  for y = 62, 76, 5 do c:put(47, y + b, P.wood.deep) c:put(48, y + b, P.wood.deep) end
  local fe = c:rect(46, 79 + b, 48, 80 + b)
  c:fillMask(fe:copy():grow(1), P.ink) c:part(fe, P.stone, { band = 1, nopop = true })
  local br = c:poly{ { 45, 81 + b }, { 49, 81 + b }, { 48, 84 + b }, { 47, 86 + b }, { 46, 84 + b } }
  c:fillMask(br:copy():grow(1), P.ink) c:part(br, BRISTLE, { band = 1, pop = { x = 45, y = 81 + b } })
  c:part(c:ellipse(47, 77 + b, 2.2, 1.8), FROG, { band = 1, nopop = true })
  -- head with eye bulges
  local head = c:ellipse(32.5, 47 + b, 15, 8.5)
  head:add(c:ellipse(24.5, 42 + b, 5, 4.5)) head:add(c:ellipse(40.5, 42 + b, 5, 4.5))
  c:part(head, FROG, { band = 2, pop = { x = 20, y = 45 + b } })
  c:part(c:ellipse(32.5, 55 + b, 11, 3):clip(head), BELLY, { band = 1, nopop = true })
  for _, q in ipairs{ { 20, 49 }, { 21, 50 }, { 44, 48 }, { 45, 49 }, { 38, 45 }, { 27, 46 } } do c:put(q[1], q[2] + b, FROG.shade) end
  c:fillMask(c:line({ { 21, 53 + b }, { 23, 52 + b }, { 42, 52 + b }, { 44, 53 + b } }, 1), P.ink)
  c:put(30, 48 + b, P.ink) c:put(35, 48 + b, P.ink)
  c:put(42, 50 + b, BRISTLE.base) c:put(43, 50 + b, BRISTLE.base) c:put(43, 49 + b, BRISTLE.shade)
  if p.blink then
    for _, x in ipairs{ 23, 39 } do for i = 0, 3 do c:put(x + i, 42 + b, FROG.base) c:put(x + i, 43 + b, P.ink) c:put(x + i, 44 + b, FROG.shade) end end
  else eye(c, 23, 41 + b) eye(c, 39, 41 + b) end
  for _, q in ipairs{ { 22, 39 }, { 23, 39 }, { 24, 39 }, { 25, 40 }, { 26, 40 } } do c:put(q[1], q[2] + b, FROG.deep) c:put(65 - q[1], q[2] + b, FROG.deep) end
  -- wide flat kasa
  local hy = b + hb
  local hm = c:ellipse(32.5, 34 + hy, 20, 4.5)
  hm:add(c:poly{ { 14, 34 + hy }, { 51, 34 + hy }, { 32.5, 17 + hy } }) hm:add(c:ellipse(32.5, 17.5 + hy, 1.5, 1.5))
  c:part(hm, STRAW, { band = 2, pop = { x = 27, y = 25 + hy } })
  under(c, hm, STRAW.deep)
  local inner = hm:copy():shrink(1)
  for _, bx in ipairs{ 17, 23, 29, 36, 42, 48 } do
    local n = 0
    c:line({ { 32.5, 19 + hy }, { bx, 36 + hy } }, 1):clip(inner):each(function(x, y) n = n + 1 if (x + y) % 2 == 0 then c:put(x, y, STRAW.shade) end end)
  end
  c:fillMask(c:line({ { 19, 32 + hy }, { 32.5, 33 + hy }, { 46, 32 + hy } }, 1):clip(inner), P.ember.base)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end

local F = { { b = 0 }, { b = 1, hb = 0 }, { b = 0 }, { b = 0, blink = true } }
local frames = {}
for _, p in ipairs(F) do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", scale = 1 }
local pc = app.pixelColor
local function rgba(h) return pc.rgba(tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16), 255) end
local spr = Sprite(64, 96, ColorMode.RGB)
for _ = 2, 4 do spr:newEmptyFrame() end
for f, c in ipairs(frames) do
  local im = Image(64, 96, ColorMode.RGB) im:clear(pc.rgba(0, 0, 0, 0))
  for i, hex in pairs(c.pix) do im:putPixel(i % 64, i // 64, rgba(hex)) end
  spr:newCel(spr.layers[1], spr.frames[f], im, Point(0, 0))
end
local tg = spr:newTag(1, 4) tg.name = "idle"
spr:saveAs(out .. NAME .. ".aseprite") spr:close()
print(NAME .. " ok")
