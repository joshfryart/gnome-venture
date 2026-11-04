-- npc-grandmother-hoshi sprite (npc2 P1_12) species: mouse
-- Grandmother Hoshi: elder grey mouse, white bun with a star hairpin, gold round glasses, plum kimono + red obi,
-- cradles a calico lucky-cat figurine (prop). Long pink tail curls on the ground.
-- 64x96 cell, feet baseline y=90 at x=32. idle x4: base / breath+tail+pin settle / base / blink+tail flick.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-grandmother-hoshi"
local FUR = { hi = P.stone.base, base = "#8e8ca2", shade = P.stone.shade, deep = P.stone.deep }
local HAIR = { hi = "#faf6ff", base = P.stone.hi, shade = "#c8c3da", deep = "#b4aecb" }
local KIMO = { hi = "#c98fb8", base = "#9a5a8e", shade = "#6e3a72", deep = "#45244f" }
local CR = { hi = P.cream, base = "#f3e6c8", shade = P.stone.hi, deep = P.stone.base }
local function mir(pts) local r = {} for i, q in ipairs(pts) do r[i] = { 64 - q[1], q[2] } end return r end
local function sh(pts, dx, dy) local r = {} for i, q in ipairs(pts) do r[i] = { q[1] + dx, q[2] + dy } end return r end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local O = { r = { name = "detail" } }
  local function put(x, y, h) c:put(x, y, h, O) end
  local function fm(m, h) m:each(function(x, y) put(x, y, h) end) end
  local b = p.b or 0
  c:groundShadow(32, 89.5, 13, 2.5)
  -- tail curling on the ground (tip settles / flicks)
  local tx, ty = p.tx or 0, p.ty or 0
  fm(c:line({ { 41, 86 }, { 48, 87 }, { 53, 85 }, { 55, 81 }, { 54 + tx, 78 + ty } }, 1), P.petal.shade)
  put(48, 87, P.petal.base) put(53, 85, P.petal.base)
  -- little pink feet (static)
  for _, fx in ipairs{ 27.5, 36.5 } do c:part(c:ellipse(fx, 88.5, 2.5, 1.5), P.petal, { band = 1, nopop = true }) end
  -- plum kimono: bell shape, overlap seam, deep hem
  local km = c:poly(sh({ { 24, 64 }, { 40, 64 }, { 45, 84 }, { 19, 84 } }, 0, b))
  km:add(c:ellipse(32, 67 + b, 9, 4))
  c:part(km, KIMO, { band = 2, nopop = true })
  fm(c:line({ { 34, 70 + b }, { 30, 84 + b } }, 1):clip(km), KIMO.shade)
  km:each(function(x, y) if not km:has(x, y + 1) then put(x, y, KIMO.deep) end end)
  -- wide hanging sleeves
  local sl = { { 25, 65 }, { 19, 70 }, { 16, 80 }, { 23, 81 }, { 27, 72 } }
  for side = 1, 2 do
    local m = c:poly(sh(side == 1 and sl or mir(sl), 0, b))
    c:part(m, KIMO, { band = 2, nopop = side == 2 })
    m:each(function(x, y) if not m:has(x, y + 1) then put(x, y, KIMO.deep) end end)
  end
  -- obi with gold dash stitch
  local obi = c:rect(18, 73 + b, 46, 76 + b):clip(km)
  c:part(obi, P.ember, { band = 1, nopop = true })
  for x = 20, 44 do if x % 3 < 2 then put(x, 74 + b, P.gold.base) end end
  -- crossed collar
  fm(c:line({ { 29, 64 + b }, { 32, 69 + b } }, 1), P.cream) fm(c:line({ { 35, 64 + b }, { 33, 68 + b } }, 1), CR.shade)
  -- calico lucky-cat figurine, held in both paws
  c:part(c:ellipse(32, 77.5 + b, 3.5, 3), CR, { band = 1, nopop = true })
  c:part(c:ellipse(32, 71.5 + b, 3.5, 3), CR, { band = 1, nopop = true })
  put(29, 68 + b, CR.base) put(35, 68 + b, CR.base)
  c:part(c:rect(36, 67 + b, 37, 70 + b), CR, { band = 1, nopop = true })
  put(29, 70 + b, P.ember.hi) put(30, 70 + b, P.ember.hi) put(29, 71 + b, P.ember.base) put(29, 68 + b, P.ember.hi)
  put(34, 78 + b, P.gold.base) put(35, 78 + b, P.gold.base) put(34, 79 + b, P.gold.shade)
  put(30, 72 + b, P.ink) put(34, 72 + b, P.ink) put(32, 73 + b, P.petal.base)
  put(31, 75 + b, P.ember.base) put(32, 75 + b, P.gold.hi) put(33, 75 + b, P.ember.base)
  c:part(c:ellipse(27.5, 78 + b, 1.5, 1.5), FUR, { band = 1, nopop = true })
  c:part(c:ellipse(36.5, 79 + b, 1.5, 1.5), FUR, { band = 1, nopop = true })
  -- big round ears
  for _, ex in ipairs{ 19, 45 } do
    c:part(c:ellipse(ex, 44 + b, 6, 6), FUR, { band = 2, nopop = true })
    c:part(c:ellipse(ex + 0.5, 44.5 + b, 3.5, 3.5), P.petal, { band = 1, nopop = true })
  end
  -- bun
  c:part(c:ellipse(32, 38 + b, 6.5, 4.5), HAIR, { band = 2 })
  put(30, 36 + b, HAIR.shade) put(31, 37 + b, HAIR.shade) put(34, 39 + b, HAIR.shade)
  -- head, white fringe cap with scalloped edge
  local hd = c:ellipse(32, 53 + b, 13, 10.5)
  c:part(hd, FUR, { band = 3 })
  local hm = hd:copy():clip(c:rect(0, 0, 63, 46 + b))
  for x = 21, 43, 4 do hm:add(c:ellipse(x, 46 + b, 2, 1.5)) end
  hm:clip(hd)
  c:part(hm, HAIR, { band = 2 })
  for _, q in ipairs{ { 27, 44 }, { 31, 44 }, { 35, 44 }, { 39, 45 } } do put(q[1], q[2] + b, HAIR.shade) end
  -- star hairpin through the bun (settles on breath)
  local pin = p.pin or 0
  fm(c:line({ { 27, 40 + b }, { 40, 34 + b } }, 1), P.wood.shade)
  local sy = 32 + b + pin
  for _, q in ipairs{ { 42, -2 }, { 41, -1 }, { 42, -1 }, { 43, -1 }, { 40, 0 }, { 41, 0 }, { 42, 0 }, { 43, 0 }, { 44, 0 }, { 41, 1 }, { 43, 1 } } do put(q[1], sy + q[2], P.gold.base) end
  put(42, sy - 1, P.gold.hi) put(43, sy + 1, P.gold.shade)
  -- muzzle, nose, mouth, whiskers
  c:part(c:ellipse(32, 59.5 + b, 5, 3.5), CR, { band = 1, nopop = true })
  put(31, 57 + b, P.petal.hi) put(32, 57 + b, P.petal.base) put(31, 58 + b, P.petal.shade) put(32, 58 + b, P.petal.shade)
  for _, q in ipairs{ { 30, 60 }, { 31, 61 }, { 32, 61 }, { 33, 60 } } do put(q[1], q[2] + b, P.ink) end
  for _, q in ipairs{ { 22, 58 }, { 21, 57 }, { 22, 60 }, { 21, 61 }, { 41, 58 }, { 42, 57 }, { 41, 60 }, { 42, 61 } } do put(q[1], q[2] + b, FUR.deep) end
  put(23, 56 + b, P.petal.base) put(24, 56 + b, P.petal.base) put(39, 56 + b, P.petal.base) put(40, 56 + b, P.petal.base)
  -- round gold glasses + eyes
  for _, cx in ipairs{ 26, 38 } do
    local ring = c:ellipse(cx + 0.5, 52.5 + b, 3.5, 3.5)
    fm(ring:copy():cut(ring:shrink(1)), P.gold.base)
    put(cx - 2, 50 + b, P.gold.hi)
    local x, y = cx - 1, 51 + b
    if p.blink then
      for i = 0, 2 do for j = 0, 2 do put(x + i, y + j, FUR.base) end end
      for i = 0, 2 do put(x + i, y + 2, P.ink) end
    else
      for i = 0, 2 do for j = 0, 2 do put(x + i, y + j, P.cream) end end
      put(x + 1, y + 1, P.ink) put(x + 2, y + 1, P.ink) put(x + 1, y + 2, P.ink) put(x + 2, y + 2, P.ink)
    end
  end
  for x = 30, 34 do put(x, 51 + b, P.gold.shade) end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { b = 0 }, { b = 1, ty = 1, pin = -1 }, { b = 0 }, { b = 0, blink = true, tx = 1, ty = -1 } } do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
