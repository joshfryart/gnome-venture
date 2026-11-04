-- npc-captain-pipi-shellback sprite (npc2 P1_5) species: turtle
-- Jolly sea-turtle captain: green head with pale muzzle, white peaked cap with navy band + gold badge and brown visor,
-- navy coat with cream lapels + gold buttons, big brown shell behind, holding a grey ship's cat (prop). Idle 4f.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-captain-pipi-shellback"
local NAVY = { hi = "#6f8fd6", base = "#3f5aa8", shade = "#2e4180", deep = "#222c5c" }
local CR = { hi = P.cream, base = "#efe3c2", shade = "#c9c3d6", deep = P.stone.shade }
local MUZ = { hi = "#e4f2a8", base = P.moss.hi, shade = "#9cc867", deep = P.moss.shade }
local function eye(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, P.ink) end return end
  for j = 0, 3 do for i = 0, 3 do if not ((i == 0 or i == 3) and (j == 0 or j == 3)) then c:put(x + i, y + j, P.cream) end end end
  c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
  for i = 0, 3 do c:put(x + i, y - 1, P.moss.shade) end
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, tw, ce = p.b or 0, p.tw or 0, p.ce or 0
  c:groundShadow(32, 89.5, 15, 2.5)
  -- stubby flipper feet with claws (never move)
  c:part(c:ellipse(25.5, 88.5, 4, 2), P.moss, { band = 1, pop = { x = 23, y = 87 } })
  c:part(c:ellipse(38.5, 88.5, 4, 2), P.moss, { band = 1, pop = { x = 36, y = 87 } })
  for _, x in ipairs{ 23, 25, 27, 36, 38, 40 } do c:put(x, 90, P.cream) end
  -- shell behind: rim scutes
  local shell = c:ellipse(32, 69 + b, 17.5, 15)
  c:part(shell, P.wood, { band = 2, pop = { x = 19, y = 61 + b } })
  local rim = shell:copy():cut(shell:shrink(2))
  rim:each(function(x, y) if (x + y) % 5 == 0 then c:put(x, y, P.wood.deep) end end)
  c:fillMask(c:line({ { 18, 58 + b }, { 15, 63 + b } }, 1):clip(shell), P.wood.hi)
  -- navy coat
  local coat = c:ellipse(32, 72 + b, 11, 11)
  coat:add(c:rect(22, 72 + b, 42, 84))
  c:part(coat, NAVY, { band = 2, pop = { x = 25, y = 65 + b } })
  c:part(c:poly{ { 27, 61 + b }, { 37, 61 + b }, { 32, 69 + b } }, CR, { band = 1, nopop = true })
  for _, y in ipairs{ 66, 70 } do c:button(24, y + b) c:button(40, y + b) end
  -- neck
  c:part(c:ellipse(32, 59 + b, 5, 2.5), P.moss, { band = 1, nopop = true })
  -- ship's cat held in front
  local cat = c:ellipse(32, 79 + b, 6.5, 4)
  c:part(c:line({ { 37, 81 + b }, { 43, 81 + b }, { 45 + tw, 77 + b - tw } }, 2), P.stone, { band = 1, nopop = true })
  c:part(cat, P.stone, { band = 1, nopop = true })
  local ch = c:ellipse(32, 73 + b, 5, 4)
  ch:add(c:poly{ { 27, 72 + b }, { 28, 67 + b + ce }, { 31, 70 + b } })
  ch:add(c:poly{ { 33, 70 + b }, { 36, 67 + b }, { 37, 72 + b } })
  c:part(ch, P.stone, { band = 1, pop = { x = 29, y = 71 + b } })
  c:put(28, 69 + b + ce, P.petal.base) c:put(36, 69 + b, P.petal.base)
  if p.blink then c:put(30, 73 + b, P.ink) c:put(29, 73 + b, P.ink) c:put(34, 73 + b, P.ink) c:put(35, 73 + b, P.ink)
  else c:put(30, 72 + b, P.gold.base) c:put(30, 73 + b, P.ink) c:put(34, 72 + b, P.gold.base) c:put(34, 73 + b, P.ink) end
  c:put(32, 74 + b, P.petal.base)
  c:part(c:ellipse(26, 79 + b, 2.5, 2), P.moss, { band = 1, nopop = true })
  c:part(c:ellipse(38, 79 + b, 2.5, 2), P.moss, { band = 1, nopop = true })
  -- turtle head + pale muzzle
  c:part(c:ellipse(32, 48 + b, 12.5, 10), P.moss, { band = 2, pop = { x = 24, y = 46 + b } })
  c:part(c:ellipse(32, 53 + b, 6.5, 3), MUZ, { band = 1, nopop = true })
  c:put(30, 51 + b, P.moss.deep) c:put(34, 51 + b, P.moss.deep)
  for x = 28, 36 do c:put(x, 54 + b, P.ink) end
  c:put(27, 53 + b, P.ink) c:put(37, 53 + b, P.ink) c:put(31, 55 + b, P.ember.base) c:put(32, 55 + b, P.ember.base) c:put(31, 55 + b, P.ember.shade)
  c:put(31, 55 + b, P.ember.base)
  eye(c, 23, 46 + b, p.blink) eye(c, 37, 46 + b, p.blink)
  c:cheek(21, 51 + b) c:cheek(41, 51 + b)
  -- peaked cap: crown top, navy band, gold badge, brown visor
  local hb = p.hb or 0
  local crown = c:ellipse(32, 35 + b + hb, 14.5, 6)
  c:part(crown, CR, { band = 2, pop = { x = 23, y = 32 + b + hb } })
  local band = c:poly{ { 21, 38 + b + hb }, { 43, 38 + b + hb }, { 42, 42 + b + hb }, { 22, 42 + b + hb } }
  c:part(band, NAVY, { band = 1, nopop = true })
  c:part(c:ellipse(32, 43.5 + b + hb, 9, 1.5), P.wood, { band = 1, nopop = true })
  c:part(c:rect(31, 39 + b + hb, 33, 41 + b + hb), P.gold, { band = 1, pop = { x = 31, y = 39 + b + hb } })
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { b = 0 }, { b = 1, ce = 1, tw = -1 }, { b = 0 }, { b = 0, blink = true, tw = 1 } } do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
