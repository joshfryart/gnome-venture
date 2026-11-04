-- npc-haru-pennywhistle sprite (npc2 P1_13) species: green bush-cricket
-- Haru, cheerful village musician: green cricket in a wide pink woven kasa hat and sea-blue tunic,
-- big folded hind-leg knees above the hips, long sweeping antennae. Prop: tin pennywhistle held across the chest.
-- 64x96 cell, 3/4 top-down, feet baseline y=90 centre x=32. idle(4): base, breath, base, blink + antenna twitch.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-haru-pennywhistle"

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.b
  local function dot(x, y, h) c:put(x, y, h, c.own[y * c.w + x]) end
  c:groundShadow(32, 89.5, 15, 3)
  -- hind legs: shin to the fixed foot, thigh up to a knee above the hip
  for _, s in ipairs{ -1, 1 } do
    local kx = 32 + s * 15
    c:part(c:line({ { kx, 65 + b }, { 32 + s * 13, 87 } }, 2), "moss", { band = 1, nopop = true })
    c:part(c:line({ { 32 + s * 8, 81 + b }, { kx, 65 + b } }, 4), "moss", { band = 1, pop = { kx - 1, 66 + b } })
    c:part(c:ellipse(32 + s * 13, 88.5, 3, 1.5), "wood", { band = 1, nopop = true })
  end
  -- little front feet
  for _, x in ipairs{ 28, 36 } do c:part(c:ellipse(x, 88.5, 2.5, 1.5), "wood", { band = 1, nopop = true }) end
  -- tunic: barrel with flared hem, cream V collar, belt
  local tun = c:ellipse(32, 75 + b, 10, 9)
  tun:add(c:poly{ { 23, 78 + b }, { 41, 78 + b }, { 43, 86 }, { 21, 86 } })
  c:part(tun, "sea", { band = 2 })
  for x = 21, 43 do if tun:has(x, 86) then dot(x, 86, P.sea.deep) end end
  c:part(c:poly{ { 28, 66 + b }, { 36, 66 + b }, { 32, 71 + b } }, { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }, { band = 1, nopop = true })
  for x = 22, 42 do if tun:has(x, 80 + b) then dot(x, 80 + b, P.wood.shade) end end
  -- pennywhistle across the chest: tin tube, gold mouthpiece, finger holes
  local fl = c:line({ { 19, 80 + b }, { 45, 69 + b } }, 2)
  c:part(fl, "stone", { band = 1, pop = { 22, 78 + b } })
  c:part(c:line({ { 43, 70 + b }, { 46, 69 + b } }, 2), "gold", { band = 1, nopop = true })
  for _, q in ipairs{ { 27, 76 }, { 30, 75 }, { 33, 74 }, { 36, 72 } } do dot(q[1], q[2] + b, P.stone.deep) end
  -- hands
  c:part(c:ellipse(25, 77.5 + b, 2.5, 2), "moss", { band = 1, nopop = true })
  c:part(c:ellipse(37, 72.5 + b, 2.5, 2), "moss", { band = 1, nopop = true })
  -- head: wide cricket head with a pale face shield
  local head = c:ellipse(32, 55 + b, 13, 9.5)
  c:part(head, "moss", { band = 2, pop = { 22, 52 + b } })
  c:part(c:rrect(29, 56 + b, 35, 61 + b, 2), { hi = P.cream, base = P.moss.hi, shade = P.moss.base, deep = P.moss.shade }, { band = 1, nopop = true })
  dot(31, 57 + b, P.moss.shade) dot(33, 57 + b, P.moss.shade)
  dot(31, 61 + b, P.wood.deep) dot(33, 61 + b, P.wood.deep)
  for x = 30, 34 do dot(x, 62 + b, P.ink) end dot(29, 61 + b, P.ink) dot(35, 61 + b, P.ink)
  local function eye(x, y)
    dot(x + 1, y, P.ink) dot(x + 2, y, P.ink)
    for _, q in ipairs{ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 }, { 1, 1 } } do dot(x + q[1], y + q[2], P.cream) end
    dot(x + 2, y + 1, P.ink) dot(x + 1, y + 2, P.ink) dot(x + 2, y + 2, P.ink)
  end
  if p.blink then for _, x in ipairs{ 23, 37 } do for i = 0, 3 do dot(x + i, 54 + b, P.ink) end end
  else eye(23, 51 + b) eye(37, 51 + b) end
  c:cheek(21, 57 + b) c:cheek(41, 57 + b)
  -- kasa hat: wide shallow woven cone, band, gold knob
  local hm = c:ellipse(32, 46 + b, 18.5, 3.5)
  hm:add(c:poly{ { 16, 46 + b }, { 48, 46 + b }, { 32, 31 + b } })
  c:part(hm, "petal", { band = 2, pop = { 27, 38 + b } })
  for _, ex in ipairs{ 19, 25, 39, 45 } do
    c:line({ { 32, 33 + b }, { ex, 46 + b } }, 1):clip(hm):each(function(x, y) if y > 35 + b then dot(x, y, P.petal.shade) end end)
  end
  for x = 15, 49 do if hm:has(x, 46 + b) and not hm:has(x, 47 + b) then dot(x, 49 + b - 3, P.petal.deep) end end
  for x = 23, 41 do if hm:has(x, 44 + b) then dot(x, 44 + b, (x % 3 == 0) and P.gold.base or P.petal.deep) end end
  c:part(c:ellipse(32, 31.5 + b, 1.5, 1.5), "gold", { band = 1, nopop = true })
  c:finish{ outline = true }
  -- antennae: long, sweeping out from under the brim; tips settle a beat late and twitch on blink
  local at = p.at or 0
  c:fillMask(c:line({ { 13, 44 + b }, { 9, 34 + b }, { 7, 24 + b + at }, { 9 + (p.tw or 0), 15 + b + at } }, 1), P.ink)
  c:fillMask(c:line({ { 51, 44 + b }, { 55, 34 + b }, { 57, 24 + b + at }, { 56, 14 + b + at } }, 1), P.ink)
  HP.assertClean(c)
  return c
end

local idle = { { b = 0 }, { b = 1, at = 1 }, { b = 0 }, { b = 0, blink = true, tw = 1 } }
local frames = {}
for _, p in ipairs(idle) do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
