-- npc-clover-thornwhistle sprite (npc2 P1_7) species: garden snail
-- Clover Thornwhistle: sleepy, kindly garden snail on eyestalks, wide straw sun-hat with a clover sprig,
-- violet poncho with red collar, spiral shell on the back. Prop: a wooden thorn whistle on a cord.
-- 64x96 cell, feet (snail foot) baseline y=90, idle 4 frames (breath, stalk settle, blink+stalk twitch).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-clover-thornwhistle"
local SKIN  = { hi = "#f6d9a2", base = "#dcaa6c", shade = "#a8744f", deep = "#6b4436" }
local SHELL = { hi = "#d9935a", base = "#a85f3a", shade = "#74393a", deep = "#4a2433" }
local MUZ   = { hi = P.cream, base = "#f7e3bc", shade = "#e0bf94", deep = "#a8744f" }
local PON, HAT, COL = P.dusk, P.gold, P.ember

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, e, tw = p.bob or 0, p.e or 0, p.tw or 0
  c:groundShadow(32, 89.5, 17, 3)
  -- spiral shell on the back, peeking up-right
  local sh = c:ellipse(46, 60 + b, 11, 11)
  c:part(sh, SHELL, { band = 2, pop = { x = 40, y = 53 + b } })
  local r1 = c:ellipse(47, 61 + b, 7, 7):edge():cut(c:rect(40, 52 + b, 47, 60 + b))
  local r2 = c:ellipse(48, 62 + b, 3.5, 3.5):edge()
  c:fillMask(r1:clip(sh:shrink(1)), SHELL.deep) c:fillMask(r2:clip(sh:shrink(1)), SHELL.shade)
  c:put(48, 62 + b, SHELL.hi)
  -- foot: static slimy sole on the ground
  local foot = c:ellipse(31, 86, 16, 4.5)
  c:part(foot, SKIN, { band = 1, pop = { x = 18, y = 85 } })
  for x = 17, 45, 4 do if foot:has(x, 89) then c:put(x, 89, SKIN.shade) end end
  -- arm nubs
  c:part(c:ellipse(17, 72 + b, 2.5, 2.5), SKIN, { band = 1 })
  c:part(c:ellipse(47, 72 + b, 2.5, 2.5), SKIN, { band = 1 })
  -- poncho
  local pon = c:poly{ { 22, 61 + b }, { 42, 61 + b }, { 47, 82 + b }, { 17, 82 + b } }
  pon:add(c:ellipse(32, 81 + b, 15, 4))
  c:part(pon, PON, { band = 2, pop = { x = 23, y = 66 + b } })
  for x = 18, 46, 3 do if pon:has(x, 84 + b) then c:put(x, 84 + b, PON.deep) end end
  c:stitch{ { 18, 82 + b }, { 46, 82 + b } }
  c:part(c:rrect(21, 59 + b, 43, 63 + b, 2), COL, { band = 1, pop = { x = 23, y = 60 + b } })
  -- prop: thorn whistle on a cord
  c:fillMask(c:line({ { 27, 64 + b }, { 30, 70 + b } }, 1), SHELL.deep)
  c:fillMask(c:line({ { 37, 64 + b }, { 34, 70 + b } }, 1), SHELL.deep)
  c:part(c:rrect(28, 70 + b, 36, 73 + b, 1), P.wood, { band = 1, pop = { x = 30, y = 70 + b } })
  c:put(28, 71 + b, P.cream) c:put(28, 72 + b, P.cream) c:put(33, 71 + b, P.ink)
  c:put(36, 70 + b, P.moss.shade) c:put(37, 69 + b, P.moss.base) -- thorn sprout at the tip
  -- eyestalks (behind the hat)
  local sL = c:line({ { 25, 41 + b }, { 22, 31 + b }, { 20, 25 + b + e } }, 2)
  local sR = c:line({ { 37, 41 + b }, { 40, 31 + b }, { 43 + tw, 25 + b + e } }, 2)
  c:part(sL, SKIN, { band = 1, nopop = true }) c:part(sR, SKIN, { band = 1, nopop = true })
  local function ball(x, y)
    c:part(c:ellipse(x + 2.5, y + 2.5, 3.5, 3.5), SKIN, { band = 1, nopop = true })
    if p.blink then
      for i = 0, 4 do c:put(x + i, y + 2, P.ink) end
      c:put(x + 1, y + 1, SKIN.hi) c:put(x + 2, y + 1, SKIN.hi) c:put(x + 3, y + 1, SKIN.hi)
    else c:eyeLocked(x, y) end
  end
  ball(18, 19 + b + e) ball(41 + tw, 19 + b + e)
  -- head
  local head = c:ellipse(31, 49 + b, 13, 11)
  c:part(head, SKIN, { band = 2, pop = { x = 22, y = 43 + b } })
  local muz = c:ellipse(31, 54 + b, 8, 5)
  c:part(muz, MUZ, { band = 1, pop = { x = 26, y = 51 + b } })
  -- snout pad + nostrils, small smile
  c:part(c:ellipse(31, 51 + b, 3, 1.5), SKIN, { band = 1, pop = { x = 29, y = 50 + b } })
  c:put(30, 52 + b, SKIN.deep) c:put(32, 52 + b, SKIN.deep)
  c:paint({ "i...i", ".iii." }, 29, 55 + b, { i = "ink" })
  c:cheek(20, 52 + b) c:cheek(41, 52 + b)
  -- straw sun-hat: wide brim, low cone, red band, clover sprig
  local hat = c:ellipse(31, 40 + b, 14, 3)
  hat:add(c:poly{ { 23, 40 + b }, { 39, 40 + b }, { 33, 29 + b }, { 29, 29 + b } })
  hat:add(c:ellipse(31, 29.5 + b, 2, 1.5))
  c:part(hat, HAT, { band = 2, pop = { x = 27, y = 33 + b } })
  for x = 18, 44 do if hat:has(x, 41 + b) and x % 3 == 0 then c:put(x, 41 + b, HAT.shade) end end
  local band = c:rect(24, 37 + b, 38, 38 + b):clip(hat)
  band:each(function(x, y) c:put(x, y, y == 38 + b and COL.shade or COL.base) end)
  c:part(c:ellipse(25, 34 + b, 1.5, 1.5), P.moss, { band = 1, nopop = true })
  c:part(c:ellipse(28, 34 + b, 1.5, 1.5), P.moss, { band = 1, nopop = true })
  c:part(c:ellipse(26.5, 32 + b, 1.5, 1.5), P.moss, { band = 1, nopop = true })
  c:put(26, 33 + b, P.moss.hi)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { bob = 0 }, { bob = 1, e = 1 }, { bob = 0 }, { bob = 0, blink = true, tw = 1 } } do frames[#frames + 1] = frame(p) end
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
