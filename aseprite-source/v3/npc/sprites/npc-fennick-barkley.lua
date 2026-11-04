-- npc-fennick-barkley sprite (npc2 P1_10) species: frog
-- Squat green frog in a red knitted hood with a little peak, purple smock, gold bead collar; prop: steaming bark-tea mug.
-- 64x96 cell, feet baseline y=90, idle 4 frames (base, breath, base, blink + steam twitch).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-fennick-barkley"
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local PALE = { hi = P.cream, base = P.moss.hi, shade = P.moss.base, deep = P.moss.shade }
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.bob or 0
  c:groundShadow(32, 89.5, 15, 3)
  -- webbed feet (never move)
  for _, fx in ipairs{ 25, 39 } do
    local m = c:ellipse(fx, 88, 5, 2)
    c:part(m, "moss", { band = 1, sep = true })
    c:put(fx - 2, 89, P.moss.deep) c:put(fx + 1, 89, P.moss.deep)
  end
  -- purple smock
  local body = c:ellipse(32, 75 + b, 12, 11):clip(c:rect(0, 0, 63, 87))
  c:part(body, "dusk", { band = 2 })
  c:stitch{ { 24, 67 + b }, { 28, 69 + b }, { 32, 70 + b }, { 36, 69 + b }, { 40, 67 + b } }
  -- arms
  c:part(c:ellipse(19.5, 74 + b, 3, 4), "moss", { band = 1, sep = true, nopop = true })
  c:part(c:ellipse(45, 74 + b, 3, 4), "moss", { band = 1, sep = true, nopop = true })
  -- mug prop (right hand)
  local mug = c:rrect(43, 70 + b, 49, 79 + b, 1)
  c:part(mug, "wood", { band = 2 })
  for y = 72, 77 do c:put(50, y + b, P.wood.shade) end c:put(51, 73 + b, P.wood.shade) c:put(51, 76 + b, P.wood.shade)
  c:put(52, 74 + b, P.wood.deep) c:put(52, 75 + b, P.wood.deep)
  for x = 43, 49 do c:put(x, 79 + b, P.wood.deep) end
  for x = 44, 48 do c:put(x, 75 + b, P.wood.deep) end -- grain band
  c:part(c:rect(44, 70 + b, 48, 71 + b), CR, { band = 1, nopop = true })
  c:part(c:ellipse(43, 76 + b, 2.5, 2.5), "moss", { band = 1, sep = true, nopop = true })
  -- red knitted hood (peak on top, flaps to the shoulders)
  local hood = c:ellipse(32, 50 + b, 19.5, 15)
  hood:add(c:poly{ { 27, 37 + b }, { 37, 37 + b }, { 33, 31 + b + (p.peak or 0) }, { 31, 31 + b + (p.peak or 0) } })
  hood:add(c:rrect(12, 50 + b, 20, 66 + b, 3)) hood:add(c:rrect(44, 50 + b, 52, 66 + b, 3))
  c:part(hood, "ember", { band = 2 })
  for y = 54, 64, 3 do c:put(15, y + b, P.ember.shade) c:put(48, y + b, P.ember.deep) end -- knit ribs
  c:put(32, 32 + b + (p.peak or 0), P.ember.hi)
  -- wide flat frog head
  local head = c:ellipse(32, 53 + b, 15.5, 10)
  c:part(head, "moss", { band = 2, pop = { 20, 49 + b } })
  c:part(c:ellipse(32, 59 + b, 9, 3):clip(head), PALE, { band = 1, nopop = true, inner = false })
  -- eye bumps on top of head
  for _, ex in ipairs{ 23.5, 40.5 } do c:part(c:ellipse(ex, 43 + b, 5.5, 4.5), "moss", { band = 1, sep = true, nopop = true }) end
  local ey = 41 + b
  if p.blink then
    for _, x in ipairs{ 21, 38 } do for i = 0, 4 do c:put(x + i, ey + 2, P.ink) end c:put(x, ey + 1, P.moss.shade) end
  else c:eyeLocked(21, ey) c:eyeLocked(38, ey) end
  -- snout: lit ridge + nostrils
  for x = 30, 34 do c:put(x, 50 + b, P.moss.hi) end
  c:put(30, 51 + b, P.ink) c:put(34, 51 + b, P.ink)
  -- wide mouth, corners up
  for x = 22, 42 do c:put(x, 56 + b, P.ink) end
  c:put(21, 55 + b, P.ink) c:put(43, 55 + b, P.ink)
  c:cheek(19, 54 + b) c:cheek(44, 54 + b)
  c:finish{ outline = true }
  -- steam (no outline)
  local s = p.steam or 0
  for _, q in ipairs{ { 45, 67 }, { 46, 66 }, { 45, 65 }, { 47, 68 } } do c:put(q[1] + s, q[2] + b, P.stone.hi) end
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { bob = 0 }, { bob = 1, peak = 1 }, { bob = 0 }, { bob = 0, blink = true, steam = 1 } } do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
