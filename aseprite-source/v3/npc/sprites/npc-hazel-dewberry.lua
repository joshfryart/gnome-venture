-- npc-hazel-dewberry sprite (npc2 P1_14) species: frog
-- Hazel Dewberry: plump green frog berry-picker, straw boater with petal band, red dress + cream apron.
-- prop: woven basket of dewberries. idle 4f: base / breath (body+hat+basket 1px down, basket swings) / base / blink.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-hazel-dewberry"
local CR = { hi = P.cream, base = "#f3e6c8", shade = P.stone.hi, deep = P.stone.base }
local THR = { hi = P.cream, base = P.moss.hi, shade = P.moss.base, deep = P.moss.shade }

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, bx = p.b or 0, p.bx or 0
  c:groundShadow(32, 89, 15, 3)
  -- bell dress
  local dress = c:poly{ {24,66+b},{41,66+b},{47,86+b},{17,86+b} }
  dress:add(c:ellipse(32.5, 67+b, 9, 3))
  c:part(dress, P.ember, { band = 2 })
  for x = 18, 46 do if dress:has(x, 86+b) and x % 3 == 0 then c:put(x, 86+b, P.ember.deep, true) end end
  -- apron + straps + hem stitch
  c:part(c:poly{ {28,70+b},{37,70+b},{40,85+b},{25,85+b} }, CR, { band = 1 })
  c:part(c:line({ {28,70+b},{26,66+b} }, 1), CR, { nopop = true, noshade = true })
  c:part(c:line({ {37,70+b},{39,66+b} }, 1), CR, { nopop = true, noshade = true })
  c:stitch{ {27,83+b},{38,83+b} }
  -- webbed feet (fixed)
  for _, fx in ipairs{ 25, 40 } do
    local m = c:ellipse(fx, 88, 4.5, 2)
    for _, t in ipairs{ -4, 0, 4 } do m:add(c:ellipse(fx + t, 89, 1.2, 1)) end
    c:part(m, P.moss, { band = 1 })
  end
  -- left arm
  c:part(c:ellipse(17, 74+b, 2.5, 4), P.moss, { band = 1, nopop = true })
  -- basket of dewberries in the right hand
  local by = b
  c:part(c:line({ {42+bx,77+by},{43+bx,72+by},{46+bx,70+by},{49+bx,72+by},{50+bx,77+by} }, 1), P.wood, { nopop = true, band = 1 })
  for _, q in ipairs{ {44,76},{47,75},{50,76},{46,77},{49,77} } do
    c:part(c:ellipse(q[1]+bx, q[2]+by, 1.2, 1.2), P.dusk, { band = 1, nopop = true, sep = true })
    c:put(q[1]+bx-1, q[2]+by-1, P.dusk.hi, true)
  end
  local bk = c:rrect(41+bx, 78+by, 52+bx, 85+by, 2)
  c:part(bk, P.wood, { band = 2, nopop = true })
  for y = 80, 84, 2 do for x = 42, 51 do if (x + y) % 3 == 0 and bk:has(x+bx, y+by) then c:put(x+bx, y+by, P.wood.shade, true) end end end
  for x = 42, 51 do c:put(x+bx, 78+by, P.wood.hi, true) end
  c:part(c:ellipse(43+bx, 78+b, 2.5, 2), P.moss, { band = 1, nopop = true })
  -- wide frog head
  local head = c:ellipse(32.5, 57+b, 15, 9.5)
  c:part(head, P.moss, { band = 2, pop = { x = 21, y = 53+b } })
  c:part(c:ellipse(32.5, 64+b, 9, 2.5):clip(head), THR, { band = 1, nopop = true, inner = false })
  for _, q in ipairs{ {20,59},{44,56},{42,59} } do c:put(q[1], q[2]+b, P.moss.shade, true) c:put(q[1]+1, q[2]+b, P.moss.shade, true) end
  for x = 22, 43 do c:put(x, 60 + b + math.floor(1.6 * (1 - ((x - 32.5) / 11) ^ 2) + .5), P.moss.deep, true) end
  c:put(21, 59+b, P.moss.deep, true) c:put(44, 59+b, P.moss.deep, true)
  c:put(31, 57+b, P.moss.deep, true) c:put(34, 57+b, P.moss.deep, true)
  c:cheek(19, 61+b) c:cheek(44, 61+b)
  -- straw boater
  local brim = c:ellipse(32.5, 46+b, 14, 3)
  c:part(brim, P.gold, { band = 1, pop = { x = 21, y = 45+b } })
  local crown = c:rrect(25, 37+b, 40, 46+b, 3)
  c:part(crown, P.gold, { band = 2, pop = { x = 27, y = 39+b } })
  c:part(c:rect(25, 43+b, 40, 45+b):clip(crown), P.petal, { band = 1, nopop = true })
  brim:copy():cut(crown):each(function(x, y) if (x * 2 + y) % 5 == 0 and c:get(x, y) == P.gold.base then c:put(x, y, P.gold.shade, true) end end)
  for x = 27, 38, 3 do if c:get(x, 40+b) == P.gold.base then c:put(x, 40+b, P.gold.shade, true) end end
  -- bulging eye domes in front of the brim
  for _, ex in ipairs{ 23, 42 } do c:part(c:ellipse(ex, 51+b, 5, 4.5), P.moss, { band = 1, pop = { x = ex - 3, y = 48+b } }) end
  if p.blink then
    for _, ex in ipairs{ 21, 40 } do for i = 0, 4 do c:put(ex + i, 50+b, P.moss.shade, true) c:put(ex + i, 51+b, P.ink, true) end end
  else c:eyeLocked(21, 49+b) c:eyeLocked(40, 49+b) end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { b = 0 }, { b = 1, bx = -1 }, { b = 0 }, { b = 0, blink = true } } do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
