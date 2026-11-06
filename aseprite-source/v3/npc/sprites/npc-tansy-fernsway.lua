-- npc-tansy-fernsway sprite (npc2 P1_35) species: star-nosed mole
-- Tansy Fernsway: plump star-nosed mole herbalist. Rose beret with a darned patch, knitted moss shawl,
-- cream apron, big pink digging paws. Prop: a fern frond held in the right paw.
-- 64x96 cell, 3/4 top-down, feet y=90 x=32. idle x4: base / breath+frond lag / base / blink+star-nose twitch+frond nod.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local NAME = "npc-tansy-fernsway"
local FUR = { hi = "#b98a66", base = "#8a6450", shade = "#5f4555", deep = "#3c2c40" }
local MUZ = { hi = "#f3dcbc", base = "#d9b38f", shade = "#a87f7c", deep = "#6e4f5e" }
local PAW = { hi = "#ffd0dc", base = "#f0a0b4", shade = "#c06c8c", deep = "#7d3c5e" }
local BER = { hi = "#f08aa0", base = "#d0506e", shade = "#9a3460", deep = "#5e2048" }
local CR  = { hi = P.cream, base = "#f3e6c8", shade = P.stone.hi, deep = P.stone.base }
local function under(c, m, hex) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end) end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, tw, fs = p.b or 0, p.tw or 0, p.fs or 0
  c:groundShadow(32, 89, 14, 3)
  -- body + apron + shawl
  local body = c:ellipse(32, 76 + b, 14, 12):clip(c:rect(0, 0, 63, 86))
  c:part(body, FUR, { band = 2, pop = { x = 21, y = 71 + b } })
  under(c, body, FUR.deep)
  local apron = c:rrect(27, 74 + b, 37, 87 + b, 2):clip(body)
  c:part(apron, CR, { band = 1, nopop = true })
  c:stitch{ { 28, 82 + b }, { 36, 82 + b } }
  local sh = c:poly{ { 18, 66 + b }, { 46, 66 + b }, { 47, 72 + b }, { 32, 81 + b }, { 17, 72 + b } }
  sh:add(c:ellipse(32, 66 + b, 14, 3))
  c:part(sh, P.moss, { band = 2, pop = { x = 21, y = 65 + b } })
  sh:each(function(x, y) if (y - b) % 3 == 0 and (x + y) % 2 == 0 and c:get(x, y) == P.moss.base then c:put(x, y, P.moss.shade) end end)
  under(c, sh, P.moss.deep)
  c:button(32, 78 + b)
  -- left paw with claws
  c:part(c:ellipse(18, 77 + b, 3.5, 3), PAW, { band = 1, pop = { x = 16, y = 75 + b } })
  for i = 0, 2 do c:put(16 + i * 2, 80 + b, CR.base) end
  -- head: round fur ball, fluffy cheeks, pale muzzle
  local head = c:ellipse(32, 50 + b, 15, 13)
  for _, q in ipairs{ { 17.5, 53 }, { 46.5, 53 }, { 19, 59 }, { 45, 59 } } do head:add(c:ellipse(q[1], q[2] + b, 1.5, 1.5)) end
  c:part(head, FUR, { band = 2, pop = { x = 22, y = 45 + b } })
  for _, q in ipairs{ { 20, 47 }, { 21, 46 }, { 23, 45 }, { 19, 50 }, { 44, 56 }, { 43, 58 } } do
    c:put(q[1], q[2] + b, q[1] < 32 and FUR.hi or FUR.shade) end
  c:part(c:ellipse(32, 56 + b, 7.5, 5), MUZ, { band = 1, nopop = true, inner = false })
  -- beret
  local hb = p.hb or 0
  local ber = c:ellipse(30, 40 + b + hb, 14, 4.5)
  ber:add(c:ellipse(30, 37 + b + hb, 11.5, 4.5))
  c:part(ber, BER, { band = 2, pop = { x = 21, y = 36 + b + hb } })
  under(c, ber, BER.deep)
  c:part(c:ellipse(30, 32 + b + hb, 1.5, 1.5), BER, { band = 1, nopop = true, inner = false })
  for x = 35, 37 do for y = 37, 38 do c:put(x, y + b + hb, BER.shade) end end
  c:put(35, 37 + b + hb, P.gold.base) c:put(37, 38 + b + hb, P.gold.base)
  -- eyes (tiny mole eyes), cheeks
  local ey = 46 + b
  if p.blink then for _, x in ipairs{ 25, 26, 37, 38 } do c:put(x, ey + 1, P.ink) end
  else c:eyeSmall(25, ey) c:eyeSmall(37, ey) end
  c:cheek(21, 52 + b) c:cheek(41, 52 + b)
  -- star nose: 10 fleshy rays round a core (twitch = rotate)
  local nose = c:ellipse(32, 54 + b, 2, 1.5)
  for k = 0, 9 do local a = math.rad(k * 36 + tw * 16 - 90)
    nose:add(c:ellipse(32 + math.cos(a) * 4, 54 + b + math.sin(a) * 3.2, 1, 1)) end
  c:part(nose, P.petal, { band = 1, pop = { x = 30, y = 52 + b }, inner = false })
  c:put(31, 54 + b, P.petal.deep) c:put(33, 54 + b, P.petal.deep)
  for _, q in ipairs{ { 30, 59 }, { 31, 60 }, { 32, 60 }, { 33, 60 }, { 34, 59 } } do c:put(q[1], q[2] + b, P.ink) end
  -- fern frond in the right paw
  local pts = { { 47, 75 + b }, { 50, 67 + b }, { 53 + fs, 59 + b }, { 55 + fs * 2, 51 + b } }
  local leaf = HP.mask()
  for i = 1, 3 do local a, z = pts[i], pts[i + 1]
    for t = 0, 3 do
      local x, y = a[1] + (z[1] - a[1]) * t / 4, a[2] + (z[2] - a[2]) * t / 4
      local k = (i - 1) * 4 + t
      local L = math.max(1, 5 - k // 3)
      local side = (k % 2 == 0) and -1 or 1
      if k >= 2 then leaf:add(c:line({ { x, y }, { x + side * L, y - 1 - L // 2 } }, 2)) end
    end
  end
  leaf:add(c:ellipse(pts[4][1], pts[4][2], 1.5, 2))
  c:part(leaf, P.moss, { band = 1, pop = { x = pts[4][1] - 1, y = pts[4][2] - 1 }, inner = false })
  c:fillMask(c:line(pts, 1), P.moss.deep)
  c:part(c:ellipse(47, 76 + b, 3.5, 3), PAW, { band = 1, pop = { x = 45, y = 74 + b } })
  for i = 0, 2 do c:put(45 + i * 2, 74 + b, CR.base) end
  -- feet (fixed)
  for _, x in ipairs{ 26, 38 } do
    local m = c:ellipse(x, 88, 4, 2.5)
    c:part(m, PAW, { band = 1, nopop = true }) under(c, m, PAW.deep)
    for i = -2, 2, 2 do c:put(x + i, 89, CR.base) end
  end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ {}, { b = 1, fs = 1 }, {}, { blink = true, tw = 1, fs = -1 } } do frames[#frames + 1] = frame(p) end
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
