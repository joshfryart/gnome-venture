-- npc-woad sprite (npc2 P1_38) species: moth
-- Woad, fuzzy moth dyer: lilac eye-spot wings, feathery antennae, berry beret, green smock, red scarf,
-- indigo-stained fingertips (quirk). Prop: a little clay pot of woad-blue dye with a drip.
-- 64x96 cell, feet baseline y=90, idle x4: base / breath+antennae settle / base / antenna twitch.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-woad"
local MOTH = { hi = "#f3e3d0", base = "#d9c2b0", shade = "#a68fa0", deep = "#6b5470" }
local BERET = { hi = P.petal.base, base = P.petal.shade, shade = P.petal.deep, deep = "#4e1c40" }
local INDIGO = { hi = "#7d9cf0", base = "#4a5ac8", shade = "#33388f", deep = "#22235a" }
local WLOW = { hi = P.dusk.base, base = P.dusk.shade, shade = P.dusk.deep, deep = "#241a45" }
local FEA = { hi = P.gold.hi, base = "#d9b070", shade = "#a6806a", deep = MOTH.deep }

local function feather(c, x0, y0, x1, y1, Lmax)
  local m = c:line({ { x0, y0 }, { x1, y1 } }, 1)
  local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0))
  local len = math.sqrt((x1 - x0) ^ 2 + (y1 - y0) ^ 2)
  local px, py = -(y1 - y0) / len, (x1 - x0) / len
  for i = 3, n, 2 do
    local t = i / n
    local x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
    local L = math.max(1, math.floor(Lmax * math.sin(math.pi * math.min(t, 0.9)) + 0.5))
    for s = 1, L do
      m:set(math.floor(x + px * s + .5), math.floor(y + py * s + .5))
      m:set(math.floor(x - px * s + .5), math.floor(y - py * s + .5))
    end
  end
  return m
end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, a, tw = p.b or 0, p.a or 0, p.tw or 0
  c:groundShadow(32, 89.5, 13, 3)
  -- wings
  c:part(c:ellipse(19, 75 + b, 6, 5.5), WLOW, { band = 1, nopop = true })
  c:part(c:ellipse(45, 75 + b, 6, 5.5), WLOW, { band = 1, nopop = true })
  for _, s in ipairs({ -1, 1 }) do
    local wx = 32 + s * 17
    local up = c:ellipse(wx, 59 + b, 8.5, 9.5)
    c:part(up, P.dusk, { band = 2, nopop = s > 0 })
    c:fillMask(c:line({ { 32 + s * 9, 65 + b }, { 32 + s * 21, 54 + b } }, 1):clip(up:shrink(1)), P.dusk.shade)
    local sx = 32 + s * 19
    for _, d in ipairs({ { 0, 0 }, { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 }, { 1, 1 }, { -1, -1 }, { 1, -1 }, { -1, 1 } }) do c:put(sx + d[1], 57 + b + d[2], P.cream) end
    c:put(sx, 57 + b, P.ink)
  end
  -- antennae (feathery), emerge from the beret
  c:part(feather(c, 27, 44 + b, 21, 25 + b + a, 1), FEA, { band = 1, nopop = true })
  c:part(feather(c, 37, 44 + b, 43 + tw, 25 + b + a - tw, 1), FEA, { band = 1, nopop = true })
  -- smock
  local sm = c:poly{ { 24, 66 + b }, { 40, 66 + b }, { 45, 88 + b }, { 19, 88 + b } }
  c:part(sm, P.moss, { band = 2 })
  -- boots (fixed)
  c:part(c:ellipse(27, 88, 3.5, 2.5), P.wood, { band = 1, pop = { 25, 87 } })
  c:part(c:ellipse(37, 88, 3.5, 2.5), P.wood, { band = 1, nopop = true })
  -- sleeves
  c:part(c:ellipse(21, 74 + b, 3, 4.5), P.moss, { band = 1, nopop = true })
  c:part(c:ellipse(43, 74 + b, 3, 4.5), P.moss, { band = 1, nopop = true })
  -- dye pot
  local pot = c:rrect(26, 76 + b, 38, 86 + b, 3)
  c:part(pot, P.wood, { band = 2 })
  c:part(c:ellipse(32, 76 + b, 6.5, 1.5), P.wood, { band = 1, sep = true, nopop = true })
  for x = 28, 36 do c:put(x, 76 + b, INDIGO.base) end
  c:put(28, 76 + b, INDIGO.hi) c:put(29, 76 + b, INDIGO.hi) c:put(36, 76 + b, INDIGO.shade)
  for y = 78, 80 do c:put(35, y + b, INDIGO.base) end c:put(35, 81 + b, INDIGO.shade)
  -- hands with indigo fingertips
  c:part(c:ellipse(25, 80 + b, 2, 2), MOTH, { band = 1, nopop = true })
  c:part(c:ellipse(39, 80 + b, 2, 2), MOTH, { band = 1, nopop = true })
  c:put(26, 81 + b, INDIGO.base) c:put(38, 81 + b, INDIGO.base) c:put(26, 80 + b, INDIGO.shade)
  -- head (fuzzy)
  local head = c:ellipse(32, 55 + b, 13, 11)
  for _, q in ipairs({ { 19, 58 }, { 20, 62 }, { 45, 58 }, { 44, 62 } }) do head:add(c:ellipse(q[1], q[2] + b, 1.5, 1.5)) end
  c:part(head, MOTH, { band = 2 })
  for _, q in ipairs({ { 22, 61 }, { 26, 64 }, { 38, 64 }, { 42, 60 }, { 33, 63 } }) do c:put(q[1], q[2] + b, MOTH.shade) end
  -- scarf
  local sc = c:rrect(23, 65 + b, 41, 68 + b, 1):add(c:line({ { 36, 68 + b }, { 37, 74 + b } }, 3))
  c:part(sc, P.ember, { band = 1 })
  -- beret (tilted left)
  local ber = c:ellipse(30, 46 + b, 14, 4):add(c:ellipse(30, 44 + b, 11, 4)):add(c:rect(30, 39 + b, 31, 40 + b))
  c:part(ber, BERET, { band = 2 })
  -- face: eyes, curled proboscis
  c:eyeLocked(24, 53 + b) c:eyeLocked(35, 53 + b)
  c:paint({ "GGG", "G.G", "G.." }, 31, 59 + b, { G = "gold.shade" })
  c:put(31, 59 + b, P.gold.hi)
  c:cheek(21, 59 + b) c:cheek(41, 59 + b)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local F = { { b = 0 }, { b = 1, a = 1 }, { b = 0 }, { b = 0, tw = 1 } }
local frames = {}
for i, p in ipairs(F) do frames[i] = frame(p) end
HP.report(frames[1])
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite" }
