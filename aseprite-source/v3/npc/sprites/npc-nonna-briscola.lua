-- npc-nonna-briscola sprite (npc2 P1_25) species: sea otter
-- Elder sea-otter nonna: red polka-dot babushka knotted under the chin, moss shawl, grey brows,
-- clutching a fresh fish (prop). 64x96, feet y=90. Idle 4f: base / breath + knot settle / base / blink + tail flick.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-nonna-briscola"
local FUR = { hi = "#d9a070", base = "#a86c44", shade = "#74463a", deep = "#4a2c34" }
local MUZ = { hi = P.cream, base = "#f0dcb4", shade = "#c9a99a", deep = "#8a6a78" }
local SCARF, SHAWL, FISH = P.ember, P.moss, P.sea

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, tt, kt = p.b or 0, p.tail or 0, p.knot or 0
  c:groundShadow(32, 89.5, 14, 3)
  -- thick tapering otter tail curling out behind, right
  local tail = c:line({ { 38, 84 }, { 45, 87 } }, 5)
  tail:add(c:line({ { 45, 87 }, { 50, 86 + tt }, { 53, 84 + tt } }, 3))
  c:part(tail, FUR, { band = 1, nopop = true })
  -- webbed feet (never move)
  for _, x in ipairs{ 27, 37 } do
    c:part(c:ellipse(x, 88.5, 3.5, 1.5), FUR, { band = 1, nopop = true })
    c:put(x - 1, 89, FUR.deep) c:put(x + 1, 89, FUR.deep)
  end
  -- round body + pale belly
  local body = c:ellipse(32, 76 + b, 12.5, 11):clip(c:rect(0, 0, 63, 88))
  c:part(body, FUR, { band = 2 })
  c:part(c:ellipse(32, 80 + b, 7, 5):clip(body), MUZ, { band = 1, nopop = true })
  -- moss shawl with a front point, gold stitch
  local sh = c:ellipse(32, 67 + b, 14, 5)
  sh:add(c:poly{ { 19, 67 + b }, { 45, 67 + b }, { 32, 76 + b } })
  c:part(sh, SHAWL, { band = 2 })
  c:stitch{ { 23, 69 + b }, { 32, 74 + b }, { 41, 69 + b } }
  -- fish (prop) across the belly, nose left
  local fish = c:ellipse(31, 81 + b, 8, 2.5)
  fish:add(c:poly{ { 38, 81 + b }, { 44, 78 + b }, { 42, 81 + b }, { 44, 84 + b } })
  c:part(fish, FISH, { band = 1, nopop = true })
  for x = 25, 37 do if fish:has(x, 82 + b) then c:put(x, 82 + b, FISH.hi) end end
  c:put(28, 79 + b, P.gold.base) c:put(32, 79 + b, P.gold.base)
  c:put(25, 80 + b, P.ink) c:put(26, 80 + b, FISH.deep)
  -- paws gripping the fish
  c:part(c:ellipse(27, 83 + b, 2, 1.5), FUR, { band = 1, nopop = true })
  c:part(c:ellipse(36, 83 + b, 2, 1.5), FUR, { band = 1, nopop = true })
  -- head
  c:part(c:ellipse(32, 53 + b, 14, 11.5), FUR, { band = 2 })
  -- babushka: cap, side flaps, strands along the jaw, knot + tails under the chin
  local scarf = c:ellipse(32, 52 + b, 15.5, 13):clip(c:rect(0, 0, 63, 45 + b))
  scarf:add(c:poly{ { 16, 45 + b }, { 21, 45 + b }, { 20, 57 + b }, { 17, 55 + b } })
  scarf:add(c:poly{ { 43, 45 + b }, { 48, 45 + b }, { 47, 55 + b }, { 44, 57 + b } })
  scarf:add(c:line({ { 20, 57 + b }, { 29, 64 + b } }, 2))
  scarf:add(c:line({ { 44, 57 + b }, { 35, 64 + b } }, 2))
  scarf:add(c:ellipse(32, 65 + b, 2.5, 1.5))
  scarf:add(c:poly{ { 30, 66 + b }, { 27, 69 + b + kt }, { 30, 69 + b + kt } })
  scarf:add(c:poly{ { 34, 66 + b }, { 37, 69 + b + kt }, { 34, 69 + b + kt } })
  c:part(scarf, SCARF, { band = 2 })
  local inner = scarf:shrink(1)
  for y = 38, 57, 3 do for x = 17 + (y % 2) * 2, 47, 4 do
    if inner:has(x, y + b) then c:put(x, y + b, P.cream) end end end
  -- grey elder cheek ruff
  for _, q in ipairs{ { 21, 58 }, { 22, 59 }, { 42, 58 }, { 41, 59 } } do c:put(q[1], q[2] + b, P.stone.hi) end
  -- muzzle, nose, mouth, whisker dots
  c:part(c:ellipse(32, 58 + b, 6.5, 4), MUZ, { band = 1, nopop = true })
  c:paint({ "LNNNN", ".NNN.", "..N.." }, 30, 54 + b, { L = FUR.shade, N = "#5a3440" })
  c:put(31, 54 + b, P.cream)
  c:paint({ "...i...", ".ii.ii." }, 29, 57 + b, { i = "ink" })
  for _, q in ipairs{ { 27, 58 }, { 27, 60 }, { 37, 58 }, { 37, 60 } } do c:put(q[1], q[2] + b, MUZ.shade) end
  c:cheek(22, 56 + b) c:cheek(41, 56 + b)
  -- grey brows + eyes
  c:paint({ "Bhhh" }, 23, 46 + b, { B = "stone.base", h = "stone.hi" })
  c:paint({ "hhhB" }, 37, 46 + b, { B = "stone.base", h = "stone.hi" })
  for _, x in ipairs{ 24, 35 } do
    if p.blink then c:paint({ "i...i", ".iii." }, x, 49 + b, { i = "ink" })
    else c:eyeLocked(x, 47 + b) end
  end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { b = 0 }, { b = 1, tail = 1, knot = 1 }, { b = 0 }, { b = 0, blink = true, tail = -1 } } do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
