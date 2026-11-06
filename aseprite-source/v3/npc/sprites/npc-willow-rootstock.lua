-- npc-willow-rootstock sprite (npc2 P1_38) species: hare
-- Willow Rootstock, hare grafter-gardener: blue headband with a knot bow, violet shirt, cream apron,
-- right ear flopped at the tip (quirk). Prop: grafted sapling in a burlap root ball (gold graft band).
-- 64x96 cell, feet baseline y=90, idle x4: base / breath+ears settle / base / blink.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-willow-rootstock"
local FUR = { hi = "#f2c98e", base = "#d49a5e", shade = "#a0684e", deep = "#5e3a3e" }
local MUZ = { hi = P.cream, base = "#f6e2c0", shade = "#d8b49a", deep = "#a0684e" }
local APR = { hi = P.cream, base = "#f3e6c8", shade = P.stone.hi, deep = P.stone.base }
local BAND = { hi = P.sea.base, base = P.sea.shade, shade = P.sea.deep, deep = "#22305a" }
local BUR = { hi = "#e0c08a", base = "#b89464", shade = "#86664e", deep = "#53403e" }
local LEAF = { hi = P.moss.hi, base = "#9ccf5c", shade = P.moss.shade, deep = P.moss.deep }

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, e, lv = p.b or 0, p.e or 0, p.leaf or 0
  c:groundShadow(32, 89.5, 13, 3)
  -- ears behind the head; right ear flops at the tip
  local eL = c:line({ { 27, 50 + b }, { 25, 34 + b }, { 24, 19 + b + e } }, 6)
  local eR = c:line({ { 37, 50 + b }, { 40, 37 + b }, { 43, 29 + b + e }, { 48, 31 + b + 2 * e } }, 6)
  c:part(eL, FUR, { band = 1, pop = { 23, 24 + b + e } })
  c:part(eR, FUR, { band = 1, pop = { 39, 37 + b } })
  c:fillMask(c:line({ { 25, 45 + b }, { 25, 34 + b }, { 24, 23 + b + e } }, 2):clip(eL:shrink(1)), P.petal.base)
  c:fillMask(c:line({ { 38, 45 + b }, { 40, 37 + b }, { 42, 32 + b + e } }, 2):clip(eR:shrink(1)), P.petal.base)
  c:put(26, 40 + b, P.petal.shade) c:put(26, 41 + b, P.petal.shade) c:put(41, 38 + b, P.petal.shade)
  c:put(44, 29 + b + e, FUR.deep) c:put(45, 29 + b + e, FUR.deep)
  -- body + apron
  local body = c:ellipse(32, 78 + b, 11, 9.5)
  c:part(body, P.dusk, { band = 2 })
  c:part(c:rrect(26, 73 + b, 38, 88, 2):clip(body), APR, { band = 1, nopop = true })
  c:stitch{ { 29, 81 + b }, { 35, 81 + b } }
  -- sleeves + left paw
  c:part(c:ellipse(21, 75 + b, 3, 4.5), P.dusk, { band = 1 })
  c:part(c:ellipse(43, 75 + b, 3, 4.5), P.dusk, { band = 1, nopop = true })
  c:part(c:ellipse(21, 80 + b, 2.5, 2), FUR, { band = 1, nopop = true })
  -- big hare feet (fixed)
  c:part(c:ellipse(26, 88, 4.5, 2.5), FUR, { band = 1, pop = { 24, 87 } })
  c:part(c:ellipse(38, 88, 4.5, 2.5), FUR, { band = 1, nopop = true })
  -- prop: grafted sapling
  c:fillMask(c:line({ { 48, 80 + b }, { 48, 72 + b }, { 49, 66 + b } }, 1), P.wood.shade)
  c:put(48, 74 + b, P.gold.base) c:put(48, 75 + b, P.gold.shade)
  c:part(c:ellipse(45.5, 70 + b + lv, 2, 1), LEAF, { band = 1 })
  c:part(c:ellipse(51.5, 67 + b + lv, 2, 1), LEAF, { band = 1, nopop = true })
  c:part(c:ellipse(49, 63 + b + lv, 1, 1.5), LEAF, { band = 1, nopop = true })
  local ball = c:ellipse(48, 83 + b, 4, 3)
  c:part(ball, BUR, { band = 1 })
  c:fillMask(c:line({ { 45, 85 + b }, { 51, 81 + b } }, 1):clip(ball), BUR.deep)
  c:part(c:ellipse(44, 81 + b, 2.5, 2), FUR, { band = 1, nopop = true })
  -- head
  local head = c:ellipse(32, 56 + b, 14, 11)
  head:add(c:ellipse(19.5, 61 + b, 2, 2)):add(c:ellipse(44.5, 61 + b, 2, 2))
  c:part(head, FUR, { band = 2, sep = true, pop = { 22, 50 + b } })
  local band = c:ellipse(32, 62 + b, 16, 15):cut(c:ellipse(32, 62 + b, 16, 12.5)):clip(head)
  c:part(band, BAND, { band = 1 })
  local bow = c:ellipse(46, 49 + b, 2, 1.5):add(c:ellipse(48, 53 + b, 1.5, 1.5))
  c:part(bow, BAND, { band = 1, sep = true })
  c:part(c:ellipse(32, 62 + b, 5, 3), MUZ, { band = 1, nopop = true })
  c:put(31, 60 + b, P.petal.hi) c:put(32, 60 + b, P.petal.base) c:put(33, 60 + b, P.petal.shade) c:put(32, 61 + b, P.petal.deep)
  c:put(32, 62 + b, P.ink) c:put(31, 63 + b, P.ink) c:put(33, 63 + b, P.ink)
  if p.blink then
    for _, x in ipairs({ 24, 35 }) do
      c:put(x, 56 + b, P.ink) c:put(x + 4, 56 + b, P.ink)
      for i = 1, 3 do c:put(x + i, 57 + b, P.ink) end
    end
  else c:eyeLocked(24, 54 + b) c:eyeLocked(35, 54 + b) end
  c:cheek(21, 60 + b) c:cheek(41, 60 + b)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local F = { { b = 0 }, { b = 1, e = 1, leaf = 1 }, { b = 0 }, { b = 0, blink = true } }
local frames = {}
for i, p in ipairs(F) do frames[i] = frame(p) end
HP.report(frames[1])
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite" }
