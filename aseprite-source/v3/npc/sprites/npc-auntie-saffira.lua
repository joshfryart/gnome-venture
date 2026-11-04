-- npc-auntie-saffira sprite (npc2 P1_1) species: cat
-- Elder blue-grey cat auntie in a saffron hood (ears poke through), teal cloak, curled tail.
-- Prop: small brass lantern held low in the left paw. Idle: breath, hood tip droops, blink + tail-tip flick.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-auntie-saffira"
local FUR, HOOD, CLOAK = P.stone, P.gold, P.sea
local MUZ = { hi = P.cream, base = "#f3e6c8", shade = "#cfc3d0", deep = P.stone.base }
local GLOW = { hi = P.cream, base = P.gold.hi, shade = P.gold.base, deep = P.gold.shade }
local function under(c, m, hex) local l = {} m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], hex, c.own[q[2] * c.w + q[1]]) end end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, tw, hb = p.b or 0, p.tw or 0, p.hb or 0
  c:groundShadow(32, 89, 13, 3)
  -- curled tail behind, striped, cream tip
  local tail = c:line({ { 40, 80 + b }, { 47, 79 + b }, { 51, 74 + b }, { 52, 68 + b }, { 51 + tw, 64 + b } }, 3)
  c:part(tail, FUR, { band = 1 })
  for _, q in ipairs({ { 46, 78 }, { 47, 79 }, { 50, 74 }, { 51, 74 }, { 51, 69 }, { 52, 69 } }) do c:put(q[1], q[2] + b, FUR.deep) end
  for x = 49, 53 do for y = 62, 64 do if tail:has(x, y + b) then c:put(x, y + b, x < 51 + tw and P.cream or MUZ.shade) end end end
  -- paws (fixed)
  for _, fx in ipairs({ 27.5, 36.5 }) do local m = c:ellipse(fx, 88, 3, 1.5) c:part(m, FUR, { band = 1 }) under(c, m, FUR.deep) end
  -- cloak, scalloped gold-trimmed hem, folds
  local cl = c:poly{ { 23, 58 + b }, { 41, 58 + b }, { 46, 87 }, { 18, 87 } }
  cl:add(c:ellipse(32, 60 + b, 11, 4))
  for x = 19, 45, 4 do cl:cut(c:rect(x, 86, x, 86)) end
  c:part(cl, CLOAK, { band = 2, pop = { x = 24, y = 63 + b } })
  under(c, cl, CLOAK.deep)
  c:line({ { 27, 66 + b }, { 25, 84 } }, 1):clip(cl):each(function(x, y) c:put(x, y, CLOAK.shade, c.own[y * 64 + x]) end)
  c:line({ { 38, 66 + b }, { 40, 84 } }, 1):clip(cl):each(function(x, y) c:put(x, y, CLOAK.deep, c.own[y * 64 + x]) end)
  for x = 18, 46 do if cl:has(x, 84) and x % 3 ~= 0 then c:put(x, 84, P.gold.base, c.own[84 * 64 + x]) end end
  c:part(c:ellipse(44, 70 + b, 2.5, 2), FUR, { band = 1 })
  -- saffron hood: crown, drape to shoulders, drooping back-right tip with tassel
  local hood = c:ellipse(32, 40 + b, 16, 14)
  hood:add(c:poly{ { 18, 44 + b }, { 46, 44 + b }, { 45, 60 + b }, { 19, 60 + b } })
  hood:add(c:line({ { 40, 29 + b }, { 47, 26 + b }, { 51, 28 + b + hb } }, 4))
  c:part(hood, HOOD, { band = 2, pop = { x = 21, y = 34 + b } })
  under(c, hood, HOOD.deep)
  c:part(c:ellipse(52, 31 + b + hb, 1.5, 1.5), P.ember, { band = 1 })
  -- face
  local face = c:ellipse(32, 46 + b, 11, 9)
  c:part(face, FUR, { band = 2, pop = { x = 24, y = 40 + b } })
  local rim = face:grow(1):cut(face):clip(hood)
  rim:each(function(x, y) if y < 47 + b then c:put(x, y, HOOD.hi, c.own[y * 64 + x]) end end)
  for _, q in ipairs({ { 30, 38 }, { 30, 39 }, { 32, 37 }, { 32, 38 }, { 34, 38 }, { 34, 39 } }) do c:put(q[1], q[2] + b, FUR.shade) end
  -- ears through the hood
  local eL = c:poly{ { 19, 33 + b }, { 21, 19 + b }, { 29, 28 + b } }
  local eR = c:poly{ { 35, 28 + b }, { 43, 19 + b }, { 45, 33 + b } }
  c:part(eL, FUR, { band = 1 }) c:part(eR, FUR, { band = 1 })
  c:fillMask(c:poly{ { 21, 30 + b }, { 22, 23 + b }, { 26, 28 + b } }, P.petal.base)
  c:fillMask(c:poly{ { 38, 28 + b }, { 42, 23 + b }, { 43, 30 + b } }, P.petal.shade)
  -- eyes (gold cat eyes, slit pupil) / blink
  for _, ex in ipairs({ 25, 36 }) do
    if p.blink then for i = 0, 2 do c:put(ex + i, 44 + b, P.ink) end c:put(ex + 1, 43 + b, FUR.shade)
    else c:paint({ "iii", "hgG", "giG", "GiG" }, ex, 42 + b, { i = "ink", h = "cream", g = "gold.hi", G = "gold.base" }) end
  end
  local mz = c:ellipse(32, 50 + b, 4, 2)
  c:part(mz, MUZ, { band = 1, nopop = true, inner = false })
  c:paint({ ".PP.", ".ii.", "i..i" }, 30, 48 + b, { P = "petal.base", i = "ink" })
  c:cheek(23, 48 + b) c:cheek(39, 48 + b)
  for _, q in ipairs({ { 23, 51 }, { 24, 50 }, { 40, 50 }, { 41, 51 } }) do c:put(q[1], q[2] + b, FUR.deep) end
  c:part(c:ellipse(32, 59 + b, 1.5, 1), P.ember, { band = 1 })
  -- lantern in the left paw
  local ly = b
  c:part(c:rect(15, 74 + ly, 21, 75 + ly), P.wood, { band = 1 })
  local gl = c:rect(15, 76 + ly, 21, 82 + ly)
  c:part(gl, GLOW, { band = 1, pop = { x = 16, y = 77 + ly } })
  for y = 76, 82 do c:put(15, y + ly, P.wood.shade) c:put(21, y + ly, P.wood.deep) end
  local fx = p.fl and 1 or 0
  c:put(18 + fx, 79 + ly, P.ember.base) c:put(18, 80 + ly, P.ember.shade) c:put(18 + fx, 78 + ly, P.gold.base)
  c:part(c:rect(15, 83 + ly, 21, 84 + ly), P.wood, { band = 1 })
  c:part(c:ellipse(18, 71 + b, 2.5, 2), FUR, { band = 1 })
  return c
end
local FR = { { b = 0 }, { b = 1, hb = 1 }, { b = 0 }, { b = 0, blink = true, tw = 1, fl = true } }
local frames = {}
for _, p in ipairs(FR) do local c = frame(p) c:finish{ outline = true } HP.assertClean(c) frames[#frames + 1] = c end
HP.report(frames[1])
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
