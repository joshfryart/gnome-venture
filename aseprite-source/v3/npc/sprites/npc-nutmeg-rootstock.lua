-- npc-nutmeg-rootstock sprite (npc2 P1_25) species: star-nosed mole
-- Squat star-nosed mole grafter: pink star nose, brass spectacles, ribbed green beanie with a grafted sprig,
-- moss coat, big pink digging paws, a dirt-tipped trowel (prop). 64x96, feet y=90.
-- Idle 4f: base / breath + sprig settle / base / blink + sprig twitch.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-nutmeg-rootstock"
local FUR = { hi = "#9a7f72", base = "#6e5852", shade = "#4c3c4a", deep = "#33263a" }
local MUZ = { hi = "#e3c3a8", base = "#b8937e", shade = "#8a6a6c", deep = "#5a4452" }
local HAND = { hi = P.cream, base = P.petal.hi, shade = P.petal.base, deep = P.petal.shade }
local COAT = P.moss
local CAP = { hi = P.moss.base, base = P.moss.shade, shade = P.moss.deep, deep = "#1d3638" }
local BAND = { hi = P.moss.hi, base = P.moss.hi, shade = P.moss.base, deep = P.moss.shade }

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, lf = p.b or 0, p.lf or 0
  c:groundShadow(32, 89.5, 15, 3)
  -- pink toes (never move)
  for _, x in ipairs{ 25, 39 } do
    c:part(c:ellipse(x, 88.5, 4, 1.5), HAND, { band = 1, nopop = true })
    for i = -2, 2, 2 do c:put(x + i, 89, HAND.shade) end
  end
  -- wide coat body
  local body = c:ellipse(32, 74 + b, 15, 13.5):clip(c:rect(0, 0, 63, 87))
  c:part(body, COAT, { band = 2 })
  for y = 68 + b, 86 do if body:has(33, y) then c:put(33, y, COAT.deep) end end
  for _, y in ipairs{ 72, 78 } do c:part(c:rect(35, y + b, 36, y + 1 + b), P.gold, { band = 1, nopop = true }) end
  -- sleeves
  c:part(c:ellipse(19, 68 + b, 4, 5), COAT, { band = 1 })
  c:part(c:ellipse(45, 68 + b, 4, 5), COAT, { band = 1 })
  -- trowel (prop): dirt-tipped blade up, brass ferrule, wood grip
  local blade = c:poly{ { 47, 60 + b }, { 54, 60 + b }, { 53, 54 + b }, { 50.5, 48 + b }, { 48, 54 + b } }
  c:part(blade, P.stone, { band = 1, nopop = true })
  c:put(49, 55 + b, P.stone.hi) c:put(49, 56 + b, P.stone.hi) c:put(50, 52 + b, P.stone.hi)
  c:put(50, 49 + b, P.wood.shade) c:put(50, 50 + b, P.wood.base) c:put(51, 50 + b, P.wood.shade)
  c:part(c:rect(49, 61 + b, 52, 61 + b), P.gold, { band = 1, nopop = true })
  c:part(c:rect(49, 62 + b, 52, 69 + b), P.wood, { band = 1 })
  -- big pink digging paws with cream claws
  c:part(c:ellipse(50.5, 69 + b, 3.5, 3), HAND, { band = 1 })
  c:part(c:ellipse(15.5, 72 + b, 3.5, 3.5), HAND, { band = 1 })
  for _, q in ipairs{ { 12, 73 }, { 12, 75 }, { 14, 76 }, { 54, 70 }, { 53, 72 } } do c:put(q[1], q[2] + b, P.cream) end
  -- collar
  c:part(c:ellipse(32, 64 + b, 12, 2.5), BAND, { band = 1, nopop = true })
  -- head
  c:part(c:ellipse(32, 52 + b, 13.5, 11), FUR, { band = 2 })
  -- beanie: ribbed crown + folded band
  local E = c:ellipse(32, 51.5 + b, 15, 12.5)
  local crown = E:copy():clip(c:rect(0, 0, 63, 42 + b))
  local band = E:copy():clip(c:rect(0, 43 + b, 63, 45 + b))
  c:part(crown, CAP, { band = 2 })
  local ci = crown:shrink(1)
  for x = 20, 44, 3 do for y = 38, 42 do if ci:has(x, y + b) then c:put(x, y + b, CAP.shade) end end end
  c:part(band, BAND, { band = 1, nopop = true })
  -- grafted sprig on top: twig, twine wrap, one leaf
  c:part(c:line({ { 32, 39 + b }, { 33, 36 + b }, { 35, 34 + b + lf } }, 2), P.wood, { band = 1, nopop = true })
  c:put(33, 37 + b, P.gold.base)
  c:part(c:ellipse(37.5, 33 + b + lf, 2, 1.2), P.moss, { band = 1, nopop = true })
  -- muzzle + star nose
  c:part(c:ellipse(32, 58.5 + b, 6, 4), MUZ, { band = 1, nopop = true })
  c:paint({ ".h.h.h.", "p.ppp.p", ".ppDpp.", "p.ppp.p", ".p.p.p." }, 29, 57 + b,
    { p = "petal.base", h = "petal.hi", D = "petal.deep" })
  -- eyes behind brass spectacles
  for _, x in ipairs{ 24, 35 } do
    if p.blink then c:paint({ "iiiii" }, x, 50 + b, { i = "ink" })
    else c:eyeLocked(x, 48 + b) end
    local ring = c:ellipse(x + 2.5, 50.5 + b, 3.6, 3.6):cut(c:ellipse(x + 2.5, 50.5 + b, 2.6, 2.6))
    ring:each(function(rx, ry) c:put(rx, ry, (rx < x + 2 and ry < 50 + b) and P.gold.hi or P.gold.shade) end)
  end
  for x = 30, 34 do c:put(x, 50 + b, P.gold.shade) end
  c:cheek(19, 56 + b) c:cheek(43, 56 + b)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { b = 0 }, { b = 1, lf = 1 }, { b = 0 }, { b = 0, blink = true, lf = -1 } } do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
