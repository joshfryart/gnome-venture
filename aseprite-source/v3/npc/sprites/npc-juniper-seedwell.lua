-- npc-juniper-seedwell sprite (npc2 P1_17) species: bumblebee
-- Seed-keeper bumblebee in a green leaf hood (curled leaf tip, midrib), antennae poking through,
-- striped face, glassy wings; carries a burlap seed sack with a bean sprout (prop).
-- Idle: breath dip with leaf tip drooping, blink + sprout leaf / antenna twitch on f4.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-juniper-seedwell"
local LEAF = P.moss
local CAPE = { hi = LEAF.hi, base = LEAF.base, shade = LEAF.shade, deep = LEAF.deep }
local FUZ = P.gold
local STR = { hi = P.dusk.shade, base = P.dusk.deep, shade = "#2a1f45", deep = "#2a1f45" }
local WING = { hi = P.cream, base = P.sky.hi, shade = P.sky.base, deep = P.sky.shade }
local function keep(c, x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function stripe(c, m, y0, y1)
  for y = y0, y1 do
    local x0, x1
    m:each(function(x, yy) if yy == y then x0 = math.min(x0 or x, x) x1 = math.max(x1 or x, x) end end)
    if x0 then for x = x0, x1 do if m:has(x, y) then
      local edge = not m:has(x - 1, y) or not m:has(x + 1, y)
      keep(c, x, y, edge and STR.deep or ((x - x0) / (x1 - x0 + 1) > 0.68 and STR.shade or STR.base))
    end end end
  end
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, set, tw = p.b or 0, p.set or 0, p.tw or 0
  c:groundShadow(32, 89.5, 13, 2.5)
  for _, x in ipairs{ 18, 46 } do
    local w = c:ellipse(x, 65 + b, 4, 6)
    c:part(w, WING, { band = 1, nopop = true })
    c:put(x, 63 + b, P.sky.base) c:put(x, 66 + b, P.sky.base)
  end
  for _, x in ipairs{ 27, 37 } do c:part(c:ellipse(x, 88, 3.5, 2), STR, { band = 1 }) end
  local body = c:ellipse(32, 78 + b, 11, 9)
  c:part(body, FUZ, { band = 2 })
  stripe(c, body, 76 + b, 77 + b) stripe(c, body, 82 + b, 83 + b)
  -- seed sack + bean sprout in the left hand
  c:part(c:ellipse(19, 83 + b, 4, 3.5), P.wood, { band = 1 })
  c:part(c:rect(18, 78 + b, 20, 79 + b), P.wood, { band = 1, nopop = true, sep = true })
  for x = 17, 21 do if x % 2 == 1 then c:put(x, 82 + b, P.wood.shade) end end
  c:part(c:rect(19, 75 + b, 19, 77 + b), LEAF, { noshade = true, nopop = true })
  c:part(c:ellipse(17, 74 + b, 1.5, 1), LEAF, { band = 1, nopop = true })
  c:part(c:ellipse(21, 74 + b - tw, 1.5, 1), LEAF, { band = 1, nopop = true })
  c:put(17, 74 + b, LEAF.hi) c:put(21, 74 + b - tw, LEAF.hi)
  c:part(c:ellipse(21, 76 + b, 2.5, 3), STR, { band = 1, nopop = true })
  c:part(c:ellipse(43, 76 + b, 2.5, 3), STR, { band = 1, nopop = true })
  -- leaf cape over the shoulders, pointed leaf hem
  local cape = c:ellipse(32, 68 + b, 14, 4.5)
  for _, x in ipairs{ 21, 27, 32, 37, 43 } do cape:add(HP.poly{ { x - 2.5, 70 + b }, { x, 74 + b }, { x + 2.5, 70 + b } }) end
  c:part(cape, CAPE, { band = 1 })
  for _, x in ipairs{ 21, 27, 37, 43 } do c:put(x, 71 + b, LEAF.shade) c:put(x, 72 + b, LEAF.shade) end
  -- leaf hood with a curled tip
  local hood = c:ellipse(32, 52 + b, 14, 12)
  hood:add(c:line({ { 32, 41 + b }, { 32, 36 + b }, { 33, 33 + b } }, 3))
  hood:add(c:line({ { 33, 33 + b }, { 35, 31 + b + set }, { 37, 31 + b + set } }, 2))
  c:part(hood, LEAF, { band = 2, pop = { x = 24, y = 44 + b } })
  for _, q in ipairs{ { 32, 35 }, { 32, 37 }, { 32, 39 }, { 32, 41 }, { 32, 43 }, { 29, 43 }, { 27, 44 }, { 35, 43 }, { 37, 44 }, { 33, 33 } } do
    keep(c, q[1], q[2] + b, LEAF.shade) end
  local face = c:ellipse(32, 57 + b, 9.5, 7.5)
  c:part(face, FUZ, { band = 1, pop = { x = 25, y = 54 + b } })
  stripe(c, face, 51 + b, 52 + b) stripe(c, face, 62 + b, 64 + b)
  if p.blink then
    for _, x in ipairs{ 27, 36 } do c:put(x, 57 + b, P.ink) c:put(x + 1, 57 + b, P.ink) end
  else c:eyeSmall(27, 55 + b) c:eyeSmall(36, 55 + b) end
  c:put(31, 58 + b, FUZ.deep) c:put(32, 58 + b, FUZ.deep) c:put(31, 60 + b, P.ink) c:put(32, 60 + b, P.ink)
  c:cheek(24, 58 + b) c:cheek(38, 58 + b)
  local ax = tw
  c:part(c:ellipse(21, 36 + b + set, 1.5, 1.5), STR, { band = 1, pop = { x = 20, y = 35 + b + set } })
  c:part(c:ellipse(43 + ax, 36 + b + set, 1.5, 1.5), STR, { band = 1, pop = { x = 42 + ax, y = 35 + b + set } })
  c:finish{ outline = true }
  c:fillMask(c:line({ { 27, 42 + b }, { 24, 39 + b + set }, { 22, 38 + b + set } }, 1), P.ink)
  c:fillMask(c:line({ { 37, 42 + b }, { 40 + ax, 39 + b + set }, { 42 + ax, 38 + b + set } }, 1), P.ink)
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ {}, { b = 1, set = 1 }, {}, { blink = true, tw = 1 } } do frames[#frames + 1] = frame(p) end
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
