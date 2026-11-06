-- npc-hazel-brambleby sprite (npc2 P1_13) species: honeybee
-- Hazel, warm and chatty forager: plump gold honeybee with a brown forehead stripe and a leaf cap,
-- knitted moss cardigan over a striped abdomen, small glassy wings, elbowed antennae.
-- Prop: a bramble sprig of blackberries. 64x96 cell, feet y=90. idle(4): base, breath, base, blink + wing flick.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-hazel-brambleby"
local WING = { hi = P.cream, base = P.sky.hi, shade = P.sky.base, deep = P.sky.shade }
local BERRY = { hi = P.dusk.base, base = P.dusk.deep, shade = "#2a1f45", deep = "#2a1f45" }

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.b
  local function dot(x, y, h) c:put(x, y, h, c.own[y * c.w + x]) end
  c:groundShadow(32, 89.5, 13, 3)
  -- wings behind the shoulders, flick up on frame 4
  local wf = p.wf or 0
  c:part(c:ellipse(19, 63 + b - wf, 6, 3.5), WING, { band = 1, nopop = true })
  c:part(c:ellipse(45, 63 + b - wf, 6, 3.5), WING, { band = 1, nopop = true })
  dot(16, 62 + b - wf, P.cream) dot(17, 62 + b - wf, P.cream)
  -- feet
  for _, x in ipairs{ 27, 37 } do c:part(c:ellipse(x, 88.5, 3, 1.5), "wood", { band = 1, nopop = true }) end
  -- striped abdomen peeking under the cardigan
  local ab = c:ellipse(32, 81.5 + b * 0.5, 11, 5.5)
  c:part(ab, "gold", { band = 1, nopop = true })
  ab:each(function(x, y) if y == 82 or y == 85 then dot(x, y, (x > 36) and P.wood.deep or P.wood.shade) end end)
  -- cardigan
  local cd = c:ellipse(32, 71 + b, 11.5, 8.5)
  c:part(cd, "moss", { band = 2 })
  for y = 64, 79 do if cd:has(32, y + b) then dot(32, y + b, P.moss.shade) end end
  dot(31, 70 + b, P.gold.hi) dot(31, 74 + b, P.gold.hi)
  for _, q in ipairs{ { 25, 72 }, { 27, 75 }, { 37, 73 }, { 39, 69 } } do dot(q[1], q[2] + b, P.moss.shade) end
  -- bramble sprig (prop): stem, leaf, berry cluster
  c:part(c:line({ { 42, 78 + b }, { 45, 62 + b } }, 1), "wood", { band = 1, nopop = true })
  c:part(c:poly{ { 44, 66 + b }, { 50, 64 + b }, { 52, 67 + b }, { 46, 68 + b } }, "moss", { band = 1, nopop = true })
  for _, q in ipairs{ { 45, 59 }, { 48, 59 }, { 43, 57 }, { 46, 56 }, { 49, 56 } } do
    c:part(c:ellipse(q[1], q[2] + b, 1.5, 1.5), BERRY, { band = 1, nopop = true })
  end
  dot(45, 55 + b, P.dusk.hi) dot(43, 56 + b, P.dusk.base)
  -- hands
  c:part(c:ellipse(42, 74.5 + b, 2.5, 2), "gold", { band = 1, nopop = true })
  c:part(c:ellipse(21, 74.5 + b, 2.5, 2), "gold", { band = 1, nopop = true })
  -- head: round gold with a brown forehead stripe
  local head = c:ellipse(32, 53 + b, 12.5, 10)
  c:part(head, "gold", { band = 2, pop = { 24, 48 + b } })
  head:each(function(x, y) if y >= 45 + b and y <= 47 + b then dot(x, y, (x > 38 or y == 47 + b) and P.wood.shade or P.wood.base) end end)
  dot(25, 45 + b, P.wood.hi)
  -- leaf cap tilted on top
  c:part(c:poly{ { 24, 44 + b }, { 31, 38 + b }, { 41, 40 + b }, { 36, 44 + b } }, "moss", { band = 1, pop = { 29, 41 + b } })
  for x = 27, 37 do local y = math.floor(43 - (x - 27) * 0.35 + 0.5) + b dot(x, y, P.moss.deep) end
  -- face
  local function eye(x, y)
    dot(x + 1, y, P.ink) dot(x + 2, y, P.ink)
    for _, q in ipairs{ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 }, { 1, 1 } } do dot(x + q[1], y + q[2], P.cream) end
    dot(x + 2, y + 1, P.ink) dot(x + 1, y + 2, P.ink) dot(x + 2, y + 2, P.ink)
  end
  if p.blink then for _, x in ipairs{ 24, 36 } do for i = 0, 3 do dot(x + i, 52 + b, P.ink) end end
  else eye(24, 49 + b) eye(36, 49 + b) end
  dot(31, 55 + b, P.wood.base) dot(32, 55 + b, P.wood.shade)
  dot(29, 57 + b, P.ink) for x = 30, 33 do dot(x, 58 + b, P.ink) end dot(34, 57 + b, P.ink)
  c:cheek(22, 55 + b) c:cheek(40, 55 + b)
  c:finish{ outline = true }
  -- elbowed antennae with knobs
  local at = p.at or 0
  c:fillMask(c:line({ { 27, 43 + b }, { 26, 35 + b }, { 21, 31 + b + at } }, 1), P.ink)
  c:fillMask(c:line({ { 39, 41 + b }, { 40, 34 + b }, { 45 + (p.tw or 0), 31 + b + at } }, 1), P.ink)
  c:fillMask(c:rect(20, 30 + b + at, 21, 31 + b + at), P.ink)
  c:fillMask(c:rect(45 + (p.tw or 0), 30 + b + at, 46 + (p.tw or 0), 31 + b + at), P.ink)
  HP.assertClean(c)
  return c
end

local idle = { { b = 0 }, { b = 1, at = 1 }, { b = 0 }, { b = 0, blink = true, wf = 1, tw = 1 } }
local frames = {}
for _, p in ipairs(idle) do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
