-- npc-clementine-moss sprite (npc2 P1_6) species: garden snail
-- Clementine Moss: gentle snail-folk housekeeper. Upright slug body on a flared foot, clementine-orange
-- spiral shell on her back (right), blue polka-dot headscarf hood knotted at the left, tall eye stalks.
-- prop/quirk: a little moss tuft with a sprout growing on top of her shell. 64x96 cell, idle x4.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-clementine-moss"
local SHELL = { hi = "#ffc37a", base = "#f28a3a", shade = "#c45a34", deep = "#6e2c38" }
local SKIN = { hi = "#f6e6b0", base = "#dcc084", shade = "#a98563", deep = "#5e4048" }
local SCARF = P.sea
local APRON = { hi = P.cream, base = "#f3e6c8", shade = P.stone.hi, deep = P.stone.base }
local MOSS = P.moss
local function eye4(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, P.ink) end c:put(x, y + 1, SKIN.shade) c:put(x + 3, y + 1, SKIN.shade) return end
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs{ {0,1},{3,1},{0,2},{3,2},{1,3},{2,3} } do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function spiral(cx, cy, r0, turns, rot)
  local pts, T = {}, turns * 2 * math.pi
  for i = 0, 70 do local t = i / 70 * T local r = r0 * (1 - t / T * 0.9)
    pts[#pts + 1] = { cx + math.cos(t + rot) * r, cy + math.sin(t + rot) * r } end
  return pts
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, st, tl = p.b or 0, p.st or 0, p.tl or 0
  c:groundShadow(32, 88.5, 17, 3.5)
  -- shell behind, up-right
  local scx, scy = 43, 57 + b
  local shell = c:ellipse(scx, scy, 13.5, 13.5)
  c:part(shell, SHELL, { band = 3, pop = { x = 35, y = 49 + b } })
  c:line(spiral(scx + 0.5, scy + 0.5, 11, 2.2, 3.6), 1):clip(shell:shrink(2)):each(function(x, y) c:put(x, y, SHELL.deep, "g") end)
  c:put(34, 50 + b, SHELL.hi) c:put(35, 51 + b, SHELL.hi)
  -- moss tuft on the shell (quirk)
  local tuft = c:ellipse(44, 44 + b, 5, 2)
  tuft:add(c:line({ {41, 44 + b}, {40, 40 + b + tl} }, 1))
  tuft:add(c:line({ {45, 43 + b}, {46, 38 + b + tl} }, 1))
  tuft:add(c:line({ {48, 44 + b}, {50, 41 + b + tl} }, 1))
  c:part(tuft, MOSS, { band = 1, pop = { x = 41, y = 43 + b } })
  c:part(c:ellipse(46, 37 + b + tl, 1.5, 1), MOSS, { nopop = true, noshade = true, sep = true })
  -- slug body + fixed flared foot
  local body = c:poly{ {24, 60 + b}, {39, 60 + b}, {43, 86}, {19, 86} }
  body:add(c:ellipse(31.5, 87.5, 14, 2))
  c:part(body, SKIN, { band = 2, pop = { x = 24, y = 64 + b } })
  for _, x in ipairs{ 20, 25, 30, 35, 40 } do c:put(x, 88, SKIN.shade) end
  c:put(22, 87, SKIN.hi) c:put(23, 87, SKIN.hi)
  -- apron + straps + pocket
  local ap = c:rrect(25, 67 + b, 38, 84, 2)
  ap:add(c:line({ {26, 67 + b}, {26, 61 + b} }, 2)):add(c:line({ {37, 67 + b}, {37, 61 + b} }, 2))
  c:part(ap, APRON, { band = 1, nopop = true })
  c:part(c:rect(29, 75 + b, 34, 78 + b), APRON, { band = 1, nopop = true, sep = true })
  c:stitch{ {29, 70 + b}, {34, 70 + b} }
  -- arm nubs
  c:part(c:ellipse(21, 69 + b, 2.5, 3.5), SKIN, { band = 1, nopop = true })
  c:part(c:ellipse(42, 69 + b, 2.5, 3.5), SKIN, { band = 1, nopop = true })
  -- eye stalks (bases hidden under the scarf)
  local sL = c:line({ {27, 40 + b}, {25, 30 + b}, {23, 23 + b} }, 2)
  local sR = c:line({ {36, 40 + b}, {38, 30 + b}, {40 + (p.tw or 0), 23 + b + st} }, 2)
  c:part(sL:add(sR), SKIN, { band = 1, nopop = true })
  -- head
  local head = c:ellipse(31.5, 48 + b, 13, 10.5)
  c:part(head, SKIN, { band = 2, pop = { x = 22, y = 47 + b } })
  -- scarf hood with polka dots
  local scarf = c:ellipse(31.5, 43 + b, 14.5, 8.5):cut(c:ellipse(31.5, 52 + b, 11, 7.5))
  c:part(scarf, SCARF, { band = 2, pop = { x = 22, y = 38 + b } })
  scarf:each(function(x, y) if (x + 2 * y) % 7 == 0 and c:get(x, y) == SCARF.base and scarf:has(x + 1, y) and scarf:has(x, y + 1) then c:put(x, y, P.cream) end end)
  -- knot + flaps at lower left
  local fl = p.fl or 0
  local knot = c:ellipse(19, 50 + b, 2.5, 2)
  knot:add(c:poly{ {17, 51 + b}, {19, 52 + b}, {15, 58 + b + fl}, {13, 56 + b + fl} })
  knot:add(c:poly{ {19, 52 + b}, {21, 52 + b}, {21, 59 + b + fl}, {18, 58 + b + fl} })
  c:part(knot, SCARF, { band = 1, sep = true, nopop = true })
  -- eyeballs on stalk tips
  local eL = c:ellipse(23, 21 + b, 3.5, 3.5)
  local eR = c:ellipse(40 + (p.tw or 0), 21 + b + st, 3.5, 3.5)
  c:part(eL, SKIN, { band = 1, sep = true, nopop = true }) c:part(eR, SKIN, { band = 1, sep = true, nopop = true })
  eye4(c, 21, 19 + b, p.blink) eye4(c, 38 + (p.tw or 0), 19 + b + st, p.blink)
  -- face: snout bump, smile, cheeks
  local sn = c:ellipse(31.5, 51.5 + b, 2, 1.5)
  sn:each(function(x, y) c:put(x, y, sn:has(x, y + 1) and SKIN.base or SKIN.shade) end)
  c:put(31, 51 + b, SKIN.hi)
  c:paint({ "i..i", ".ii." }, 30, 54 + b, { i = "ink" })
  c:cheek(23, 52 + b) c:cheek(39, 52 + b)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local F = { { b = 0 }, { b = 1, st = 1, tl = 1, fl = 1 }, { b = 0 }, { b = 0, blink = true, tw = 1 } }
local frames = {}
for _, p in ipairs(F) do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
