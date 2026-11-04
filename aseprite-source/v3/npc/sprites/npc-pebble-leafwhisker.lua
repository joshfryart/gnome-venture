-- npc-pebble-leafwhisker sprite (npc2 P1_28) species: field mouse
-- Small honey-gold field mouse in a leaf-green smock, huge round pink-lined ears, long curling tail,
-- whiskers. Prop: wildflower crown. Idle: breath, ears settle, tail tip sways, f4 blink + left ear twitch.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-pebble-leafwhisker"
local FUR = { hi = "#ffd59a", base = "#eba557", shade = "#b8694a", deep = "#6e3a3e" }
local PINK = P.petal
local SMOCK = P.moss
local CREAM = { hi = P.cream, base = "#f3e2b8", shade = "#d4b98e", deep = "#9a7a5e" }
local TOK = { r = { name = "crown" } }
local function keep(c, x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, tw, el, ed = p.bob or 0, p.tail or 0, p.el or 0, p.ed or 0
  c:groundShadow(32, 89.5, 12, 3)
  -- long tail behind, curling up on the right
  c:part(c:line({ { 37, 80 + b }, { 45, 85 }, { 52, 83 }, { 55, 77 }, { 54 + tw, 72 }, { 51 + tw, 70 } }, 2), PINK, { band = 1 })
  -- long pink feet
  for _, fx in ipairs{ 27, 37 } do c:part(c:ellipse(fx, 88, 3.5, 2), PINK, { band = 1 }) end
  -- smock body, pocket, stitched hem
  local bd = c:ellipse(32, 72 + b, 10, 12)
  c:part(bd, SMOCK, { band = 2 })
  c:part(c:rrect(28, 74 + b, 34, 79 + b, 1), SMOCK, { band = 1, sep = true, nopop = true })
  c:stitch{ { 25, 81 + b }, { 39, 81 + b } }
  -- arms + pink hands
  c:part(c:ellipse(21.5, 70 + b, 2.5, 4), FUR, { band = 1 })
  c:part(c:ellipse(42.5, 70 + b, 2.5, 4), FUR, { band = 1 })
  c:part(c:ellipse(21.5, 74 + b, 2, 1.5), PINK, { band = 1, nopop = true })
  c:part(c:ellipse(42.5, 74 + b, 2, 1.5), PINK, { band = 1, nopop = true })
  c:part(c:ellipse(32, 59 + b, 8, 2), CREAM, { band = 1 })
  -- big round ears
  local function ear(cx, cy)
    c:part(c:ellipse(cx, cy, 7, 7), FUR, { band = 2 })
    c:part(c:ellipse(cx + 0.5, cy + 0.5, 4, 4), PINK, { band = 1, nopop = true })
  end
  ear(19 + el, 31 + b + ed) ear(45, 31 + b)
  -- head
  local hd = c:ellipse(32, 46 + b, 13, 11)
  hd:add(c:ellipse(19.5, 50 + b, 1.5, 1.5)) hd:add(c:ellipse(44.5, 50 + b, 1.5, 1.5))
  c:part(hd, FUR, { band = 2, pop = { 23, 39 + b } })
  -- muzzle, pink nose, w-mouth
  c:part(c:ellipse(32, 51 + b, 5.5, 3), CREAM, { band = 1, nopop = true })
  for x = 31, 33 do keep(c, x, 48 + b, PINK.base) end
  keep(c, 31, 48 + b, PINK.hi) keep(c, 32, 49 + b, PINK.shade)
  for _, q in ipairs{ { 30, 51 }, { 31, 52 }, { 32, 51 }, { 33, 52 }, { 34, 51 } } do keep(c, q[1], q[2] + b, P.ink) end
  if p.blink then
    for _, x in ipairs{ 24, 35 } do for i = 0, 4 do keep(c, x + i, 44 + b, P.ink) end end
  else c:eyeLocked(24, 42 + b) c:eyeLocked(35, 42 + b) end
  c:cheek(21, 48 + b) c:cheek(41, 48 + b)
  -- wildflower crown: vine + daisies
  local cb = b + (p.cr or 0)
  c:line({ { 21, 40 + cb }, { 25, 37 + cb }, { 32, 35 + cb }, { 39, 37 + cb }, { 43, 40 + cb } }, 1):each(function(x, y) c:put(x, y, SMOCK.shade, TOK) end)
  local function daisy(x, y, col)
    for _, d in ipairs{ { 0, -1 }, { -1, 0 }, { 1, 0 }, { 0, 1 } } do c:put(x + d[1], y + d[2], (d[1] + d[2] > 0) and col.shade or col.base, TOK) end
    c:put(x, y, P.gold.base, TOK)
  end
  daisy(23, 38 + cb, CREAM) daisy(28, 35 + cb, PINK) daisy(33, 34 + cb, P.sky) daisy(38, 35 + cb, CREAM) daisy(42, 38 + cb, P.dusk)
  c:put(22, 37 + cb, P.cream, TOK)
  c:finish{ outline = true }
  -- whiskers over the outline
  for _, w in ipairs{ { { 26, 51 }, { 19, 50 } }, { { 26, 52 }, { 20, 54 } }, { { 38, 51 }, { 45, 50 } }, { { 38, 52 }, { 44, 54 } } } do
    c:fillMask(c:line({ { w[1][1], w[1][2] + b }, { w[2][1], w[2][2] + b } }, 1), FUR.deep)
  end
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { bob = 0 }, { bob = 1, ed = 1, tail = 1, cr = 0 }, { bob = 0 }, { bob = 0, blink = true, el = -1, ed = -1, tail = -1 } } do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
