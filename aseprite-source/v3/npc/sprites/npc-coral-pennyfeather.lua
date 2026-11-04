-- npc-coral-pennyfeather sprite (npc2 P1_7) species: coral finch (songbird)
-- Coral Pennyfeather: cheery plump coral-pink finch in a plaid tam with a gold pom, cream apron with a
-- stitched flower, fanned tail. Prop: a fishing pole with a feather lure (her "penny feathers").
-- 64x96 cell, feet baseline y=90, idle 4 frames (breath + pom/lure settle, blink + tail flick).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-coral-pennyfeather"
local CO  = { hi = "#ffb8a0", base = "#f5876f", shade = "#c95a63", deep = "#7d2c5e" }
local CRM = { hi = P.cream, base = "#f7e8c6", shade = "#e2cba6", deep = P.stone.base }
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, l, pd, tf = p.bob or 0, p.l or 0, p.pd or 0, p.tf or 0
  c:groundShadow(32, 89.5, 13, 3)
  -- static legs + three-toed feet
  for _, fx in ipairs{ 27, 36 } do
    local f = c:rect(fx, 84, fx + 1, 89):add(c:rect(fx - 2, 89, fx + 3, 90))
    c:part(f, P.gold, { band = 1, nopop = true })
  end
  -- fanned tail behind, lower-left
  local tail = c:poly{ { 21, 72 + b }, { 11, 63 + b + tf }, { 9, 67 + b + tf }, { 12, 73 + b + tf }, { 20, 79 + b } }
  c:part(tail, CO, { band = 1, pop = { x = 12, y = 65 + b + tf } })
  c:fillMask(c:line({ { 19, 75 + b }, { 11, 68 + b + tf } }, 1):clip(tail:shrink(1)), CO.shade)
  -- body
  local body = c:ellipse(32, 74 + b, 13, 12)
  c:part(body, CO, { band = 2, sep = true, pop = { x = 23, y = 66 + b } })
  local apron = c:rrect(25, 69 + b, 39, 86 + b, 3):clip(body)
  c:part(apron, CRM, { band = 1, pop = { x = 27, y = 70 + b } })
  c:put(32, 77 + b, P.petal.base) c:put(31, 78 + b, P.petal.base) c:put(33, 78 + b, P.petal.base) c:put(32, 79 + b, P.petal.base)
  c:put(32, 78 + b, P.gold.base) c:put(32, 80 + b, P.moss.shade) c:put(33, 81 + b, P.moss.shade)
  -- prop: fishing pole (held in right wing), feather lure
  c:part(c:line({ { 47, 86 + b }, { 53, 24 + b } }, 2), P.wood, { band = 1, nopop = true })
  local lure = c:ellipse(57, 40 + b + l, 1.5, 3)
  c:part(lure, P.sea, { band = 1, nopop = true })
  c:put(57, 39 + b + l, P.sea.hi) c:put(57, 36 + b + l, P.gold.base)
  -- wings
  c:part(c:ellipse(20, 73 + b, 3.5, 6), CO, { band = 1, sep = true })
  c:part(c:ellipse(46, 72 + b, 3.5, 6), CO, { band = 1, sep = true })
  -- head
  local head = c:ellipse(32, 50 + b, 13, 12)
  c:part(head, CO, { band = 2, sep = true, pop = { x = 23, y = 46 + b } })
  if p.blink then
    for _, x in ipairs{ 24, 35 } do for i = 0, 4 do c:put(x + i, 50 + b, P.ink) end end
  else c:eyeLocked(24, 47 + b) c:eyeLocked(35, 47 + b) end
  -- conical finch beak
  local beak = c:poly{ { 29, 53 + b }, { 35, 53 + b }, { 33, 57 + b }, { 31, 57 + b } }
  c:part(beak, P.gold, { band = 1, pop = { x = 30, y = 53 + b } })
  c:put(30, 55 + b, P.gold.deep) c:put(31, 55 + b, P.gold.deep) c:put(32, 55 + b, P.gold.deep) c:put(33, 55 + b, P.gold.deep)
  c:cheek(21, 54 + b) c:cheek(41, 54 + b)
  -- plaid tam + pom
  local cap = c:ellipse(31, 40 + b, 15, 4.5):add(c:ellipse(30, 37 + b, 12, 4))
  c:part(cap, P.ember, { band = 2, pop = { x = 21, y = 37 + b } })
  cap:shrink(1):each(function(x, y)
    local v = c:get(x, y)
    local dark = (v == P.ember.shade or v == P.ember.deep)
    if x % 5 == 0 then c:put(x, y, dark and P.gold.shade or P.gold.base)
    elseif (y - b) % 4 == 0 then c:put(x, y, dark and P.moss.shade or P.moss.base) end
  end)
  c:part(c:ellipse(38, 32 + b + pd, 3, 2.5), P.gold, { band = 1, pop = { x = 36, y = 31 + b + pd } })
  c:finish{ outline = true }
  -- fishing line (after outline)
  c:fillMask(c:line({ { 54, 23 + b }, { 56, 29 + b }, { 57, 35 + b + l } }, 1), P.stone.deep)
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { bob = 0 }, { bob = 1, pd = 1, l = 1 }, { bob = 0 }, { bob = 0, blink = true, tf = -1 } } do frames[#frames + 1] = frame(p) end
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
