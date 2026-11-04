-- npc-quill-brambleby sprite (npc2 P1_31) species: field mouse
-- 64x96 cell, 3/4 top-down, feet baseline y=90, centre x=32. idle(4). Golden field mouse in a red smock
-- with a leaf-garland collar; big round ears, pink tail curling up behind. Prop: a fat blackberry hugged to the belly.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-quill-brambleby"
local FUR = P.gold
local MUZ = { hi = P.cream, base = P.gold.hi, shade = P.gold.base, deep = P.gold.shade }
local function eye(c, x, y, bl)
  if bl then for i = 0, 3 do c:put(x + i, y + 2, P.ink) end return end
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs{ {0,1},{3,1},{0,2},{3,2},{1,3},{2,3} } do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, e, t = p.bob or 0, p.ear or 0, p.tail or 0
  c:groundShadow(32, 89.5, 13, 3)
  -- tail behind, curling up on the right
  c:part(c:line({ {40,83},{47,85},{52,82},{54,77+t},{52,73+t} }, 2), "petal", { band = 1, nopop = true })
  -- smock (hem fixed, body breathes)
  local body = c:ellipse(32, 71 + b, 12, 10)
  body:add(c:poly{ {21,71+b},{43,71+b},{45,85},{19,85} })
  c:part(body, "ember", { band = 2, pop = { x = 23, y = 67 + b } })
  for x = 19, 45 do if body:has(x, 84) and x % 3 ~= 0 then c:put(x, 84, P.gold.base) end end
  -- feet
  for _, fx in ipairs{ 26.5, 37.5 } do c:part(c:ellipse(fx, 88.5, 3.5, 2), "petal", { band = 1, nopop = true }) end
  -- sleeves
  c:part(c:ellipse(22, 68 + b, 3, 4), "ember", { band = 1, nopop = true })
  c:part(c:ellipse(42, 68 + b, 3, 4), "ember", { band = 1, nopop = true })
  -- blackberry hugged to the belly
  local berry = c:ellipse(32, 73 + b, 5, 4.5)
  c:part(berry, "dusk", { band = 2, nopop = true })
  berry:shrink(1):each(function(x, y) if (x + y) % 3 == 0 and (x - y) % 2 == 0 then
    c:put(x, y, (x < 32 and y < 73 + b) and P.dusk.hi or P.dusk.deep) end end)
  c:paint({ "m.m.m", ".mMm." }, 30, 67 + b, { m = "moss.base", M = "moss.shade" })
  -- paws
  c:part(c:ellipse(25.5, 73 + b, 2.5, 2), FUR, { band = 1, nopop = true })
  c:part(c:ellipse(38.5, 73 + b, 2.5, 2), FUR, { band = 1, nopop = true })
  c:part(c:ellipse(32, 56 + b, 9, 6), FUR, { band = 1, nopop = true }) -- furry neck
  -- leaf garland collar
  for i = 0, 5 do local x = 24 + i * 3
    c:part(c:ellipse(x, 61 + b + ((i == 0 or i == 5) and 0 or 1), 1.5, 1), "moss", { band = 1, nopop = i % 2 == 1 }) end
  -- ears (behind head)
  c:part(c:ellipse(19 - e, 27 + b, 6.5, 6.5), FUR, { band = 2 })
  c:part(c:ellipse(45 + e, 27 + b, 6.5, 6.5), FUR, { band = 2 })
  c:part(c:ellipse(19.5 - e, 28 + b, 3.5, 3.5), "petal", { band = 1, nopop = true })
  c:part(c:ellipse(44.5 + e, 28 + b, 3.5, 3.5), "petal", { band = 1, nopop = true })
  -- head
  local head = c:ellipse(32, 40 + b, 15, 12.5)
  head:add(c:ellipse(18, 44 + b, 2, 2)):add(c:ellipse(46, 44 + b, 2, 2))
  head:add(c:poly{ {30,28+b},{32,25+b},{33,28+b} })
  c:part(head, FUR, { band = 3, pop = { x = 24, y = 32 + b } })
  for _, q in ipairs{ {26,30},{27,30},{28,29},{31,28},{35,29},{36,29} } do c:put(q[1], q[2] + b, P.gold.hi) end
  c:part(c:ellipse(32, 47 + b, 6.5, 4), MUZ, { band = 1 })
  local nose = c:ellipse(32, 44.5 + b, 2, 1.5)
  c:part(nose, "petal", { band = 1, pop = { x = 30, y = 44 + b } })
  for _, q in ipairs{ {29,49},{30,50},{31,49},{32,49},{33,50},{34,49} } do c:put(q[1], q[2] + b, P.ink) end
  c:put(31, 50 + b, P.cream) c:put(32, 50 + b, P.cream)
  eye(c, 24, 38 + b, p.blink) eye(c, 36, 38 + b, p.blink)
  c:cheek(21, 44 + b) c:cheek(41, 44 + b)
  c:finish{ outline = true }
  for _, q in ipairs{ {13,45},{14,45},{15,46},{14,49},{15,48},{16,48} } do
    c:put(q[1], q[2] + b, P.wood.deep) c:put(63 - q[1], q[2] + b, P.wood.deep) end
  HP.assertClean(c)
  return c
end
local fr = {}
for _, p in ipairs{ { bob = 0 }, { bob = 1, ear = 1, tail = 1 }, { bob = 0 }, { bob = 0, blink = true, tail = -1 } } do fr[#fr + 1] = frame(p) end
HP.report(fr[1])
HP.sheet{ cellw = 64, cellh = 96, frames = fr, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png" }
