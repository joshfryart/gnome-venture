-- npc-quill-rootstock sprite (npc2 P1_31) species: rhinoceros beetle
-- 64x96 cell, 3/4 top-down, feet baseline y=90, centre x=32. idle(4). Stout beetle: violet shell helmet with
-- gold seam and a stubby horn, knobbed antennae, wing cases peeking behind a teal tunic, violet scarf.
-- Prop: a gnarled taproot with a fresh sprout, carried across the chest.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-quill-rootstock"
local function eye(c, x, y, bl)
  if bl then for i = 0, 3 do c:put(x + i, y + 2, P.ink) end return end
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs{ {0,1},{3,1},{0,2},{3,2},{1,3},{2,3} } do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, a, l = p.bob or 0, p.ant or 0, p.leaf or 0
  c:groundShadow(32, 89.5, 15, 3.2)
  -- wing cases peeking behind the body
  for _, s in ipairs{ -1, 1 } do
    local el = c:ellipse(32 + s * 12, 68 + b, 6, 10)
    c:part(el, "dusk", { band = 2, pop = { x = 32 + s * 12 - 3, y = 61 + b } })
  end
  -- stout tunic
  local body = c:rrect(20, 58 + b, 44, 86, 7)
  c:part(body, "sea", { band = 2, pop = { x = 23, y = 62 + b } })
  for x = 21, 43 do if body:has(x, 84) and x % 3 ~= 1 then c:put(x, 84, P.sea.deep) end end
  -- stubby feet
  c:part(c:ellipse(26, 88.5, 4, 2), "dusk", { band = 1, nopop = true })
  c:part(c:ellipse(38, 88.5, 4, 2), "dusk", { band = 1, nopop = true })
  c:part(c:ellipse(32, 54 + b, 7, 4), "skinB", { band = 1, nopop = true }) -- neck
  -- scarf + tail
  local sc = c:rrect(21, 56 + b, 43, 60 + b, 2)
  sc:add(c:poly{ {35,59+b},{39,59+b},{40,68+b+b},{36,67+b} })
  c:part(sc, "dusk", { band = 1, pop = { x = 23, y = 57 + b } })
  c:button(30, 58 + b)
  -- gnarled taproot across the chest, sprout up top-right
  local root = c:line({ {23,83+b},{29,77+b},{35,72+b},{40,66+b} }, 3)
  root:add(c:ellipse(30, 76 + b, 2, 2)):add(c:ellipse(36, 71 + b, 1.5, 1.5))
  c:part(root, "wood", { band = 1, pop = { x = 33, y = 72 + b } })
  for _, q in ipairs{ {28,78},{34,73},{38,68} } do c:put(q[1], q[2] + b, P.wood.deep) end
  c:fillMask(c:line({ {23,84+b},{20,87+b} }, 1), P.wood.shade)
  c:fillMask(c:line({ {25,82+b},{21,81+b} }, 1), P.wood.shade)
  c:part(c:ellipse(42, 62 + b + l, 2.5, 1.5), "moss", { band = 1 })
  c:part(c:ellipse(44, 66 + b, 2, 1.2), "moss", { band = 1, nopop = true })
  -- hands
  c:part(c:ellipse(27, 80 + b, 2.5, 2), "skinB", { band = 1, nopop = true })
  c:part(c:ellipse(38, 70 + b, 2.5, 2), "skinB", { band = 1, nopop = true })
  -- face + shell helmet
  c:part(c:ellipse(32, 45 + b, 12.5, 9.5), "skinB", { band = 2 })
  local helm = c:ellipse(32, 39 + b, 15, 13):cut(c:ellipse(32, 48 + b, 10, 8.5)):clip(c:rect(0, 0, 63, 50 + b))
  c:part(helm, "dusk", { band = 2, pop = { x = 22, y = 32 + b } })
  for y = 29, 38 do if helm:has(32, y + b) and y % 3 < 2 then c:put(32, y + b, P.gold.base) end end
  c:put(23, 31 + b, P.dusk.hi) c:put(22, 33 + b, P.dusk.hi)
  c:part(c:poly{ {30,28+b},{34,28+b},{33,23+b},{31,22+b} }, "dusk", { band = 1, pop = { x = 31, y = 24 + b, horizontal = false } })
  -- face
  eye(c, 25, 41 + b, p.blink) eye(c, 35, 41 + b, p.blink)
  c:put(31, 46 + b, P.skinB.hi) c:put(32, 46 + b, P.skinB.base) c:put(31, 47 + b, P.skinB.deep) c:put(32, 47 + b, P.skinB.deep)
  for _, q in ipairs{ {28,49},{29,50},{30,50},{31,50},{32,50},{33,50},{34,49} } do c:put(q[1], q[2] + b, P.ink) end
  c:cheek(24, 46 + b) c:cheek(38, 46 + b)
  -- antenna knobs (stalks after the outline)
  c:part(c:ellipse(21.5, 16.5 + b + a, 2, 2), "dusk", { band = 1, pop = { x = 20, y = 15 + b + a } })
  c:part(c:ellipse(42.5, 16.5 + b + a, 2, 2), "dusk", { band = 1, pop = { x = 41, y = 15 + b + a } })
  c:finish{ outline = true }
  c:fillMask(c:line({ {28,27+b},{26,23+b},{23,19+b+a} }, 1), P.ink)
  c:fillMask(c:line({ {36,27+b},{38,23+b},{41,19+b+a} }, 1), P.ink)
  HP.assertClean(c)
  return c
end
local fr = {}
for _, p in ipairs{ { bob = 0 }, { bob = 1, ant = 1 }, { bob = 0 }, { bob = 0, blink = true, ant = -1, leaf = -1 } } do fr[#fr + 1] = frame(p) end
HP.report(fr[1])
HP.sheet{ cellw = 64, cellh = 96, frames = fr, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png" }
