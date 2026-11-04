-- npc-wren-thimblewick portrait (npc2 P1_39) species: wren (songbird)
-- Same design as the sprite: grumpy barred-brown wren, cream face patch + brow stripes, pink knit scarf,
-- silver thimble hat with a needle through it trailing pink thread. Backdrop: moss-green disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-wren-thimblewick"
local BR = { hi = "#d9a26a", base = "#a8693f", shade = "#74464a", deep = "#462838" }
local CR = { hi = P.cream, base = "#f2ddb6", shade = "#c8a9a6", deep = "#86697e" }
local MET = { hi = "#f4efe2", base = "#b9b6c4", shade = "#7d7b96", deep = "#4a4866" }
local NEED = { hi = "#f4efe2", base = "#c9c8d6", shade = "#8a89a6", deep = "#55536f" }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function keep(x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function eye(x, y)
  for j = 0, 4 do for i = 0, 4 do if not ((i == 0 or i == 4) and (j == 0 or j == 4)) then keep(x + i, y + j, P.cream) end end end
  for j = 1, 3 do for i = 1, 3 do keep(x + i, y + j, P.ink) end end
  keep(x + 1, y + 1, P.cream)
end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
-- cocked tail peeking over the right shoulder
local tail = c:poly{ { 54, 84 }, { 62, 88 }, { 74, 60 }, { 68, 57 } }
c:part(tail, BR, { band = 2 })
tail:each(function(x, y) if y % 4 == 0 and y < 84 then keep(x, y, BR.deep) end end)
-- body + speckled cream breast
local body = c:ellipse(39.5, 108, 29, 31):clip(c:rect(0, 0, 79, 99))
c:part(body, BR, { band = 2, pop = { 20, 86 } })
local brst = c:ellipse(39.5, 104, 13, 20):clip(body)
c:part(brst, CR, { band = 2, inner = false, nopop = true })
for _, q in ipairs{ { 34, 86 }, { 44, 88 }, { 38, 92 }, { 31, 95 }, { 46, 96 }, { 40, 98 } } do keep(q[1], q[2], CR.shade) end
for _, sg in ipairs{ -1, 1 } do
  local m = c:ellipse(39.5 + sg * 24, 92, 7, 12):clip(c:rect(0, 0, 79, 99))
  c:part(m, BR, { band = 2, nopop = sg > 0, pop = { 11, 84 } })
  m:each(function(x, y) if y % 3 == 0 and y > 84 then keep(x, y, BR.deep) end end)
end
-- pink knit scarf with hanging end
local sc = c:rrect(22, 71, 57, 79, 3)
c:part(sc, P.petal, { band = 2, pop = { 25, 72 } })
sc:each(function(x, y) if x % 2 == 0 and y > 72 and c:get(x, y) == P.petal.base then keep(x, y, P.petal.shade) end end)
c:part(c:poly{ { 27, 75 }, { 34, 75 }, { 33, 93 }, { 26, 91 } }, P.petal, { band = 1, sep = true, pop = { 28, 77 } })
keep(27, 91, P.petal.deep) keep(29, 92, P.petal.deep) keep(31, 93, P.petal.deep)
-- head with cheek tufts
local head = c:ellipse(39.5, 50, 20, 18)
head:add(c:poly{ { 21, 51 }, { 16, 58 }, { 24, 60 } }) head:add(c:poly{ { 58, 51 }, { 63, 58 }, { 55, 60 } })
c:part(head, BR, { band = 3, pop = { 25, 40 } })
for _, q in ipairs{ { 22, 47 }, { 23, 47 }, { 57, 48 }, { 56, 48 }, { 20, 52 }, { 59, 53 } } do keep(q[1], q[2], BR.shade) end
c:part(c:ellipse(39.5, 59, 12.5, 8):clip(head), CR, { band = 2, inner = false, nopop = true })
-- brow stripes then grumpy brows, eyes
c:line({ { 22, 41 }, { 33, 43 } }, 2):each(function(x, y) keep(x, y, CR.base) end)
c:line({ { 46, 43 }, { 57, 41 } }, 2):each(function(x, y) keep(x, y, CR.base) end)
c:line({ { 25, 43 }, { 34, 45 } }, 1):each(function(x, y) keep(x, y, P.ink) end)
c:line({ { 45, 45 }, { 54, 43 } }, 1):each(function(x, y) keep(x, y, P.ink) end)
eye(28, 46) eye(47, 46)
-- beak: upper + lower mandible, nostril, downturned corners
local bk = c:poly{ { 34.5, 53 }, { 44.5, 53 }, { 39.5, 60 } }
c:part(bk, P.gold, { band = 1, sep = true, pop = { 36, 53 } })
for x = 37, 42 do if bk:has(x, 56) then keep(x, 56, P.gold.deep) end end
keep(41, 54, P.gold.deep)
keep(34, 55, P.ink) keep(33, 56, P.ink) keep(45, 55, P.ink) keep(46, 56, P.ink)
keep(23, 55, P.petal.base) keep(24, 55, P.petal.base) keep(55, 55, P.petal.base) keep(56, 55, P.petal.base)
-- thimble hat, dimpled, rolled rim, needle
local hm = c:poly{ { 27, 34 }, { 52, 34 }, { 51, 18 }, { 32, 18 } }
hm:add(c:ellipse(41.5, 18, 9.5, 3))
c:part(hm, MET, { band = 3, pop = { 33, 19 } })
for y = 21, 31, 3 do for x = 30 + (y % 2), 50, 3 do
  if hm:has(x - 1, y) and hm:has(x + 1, y) and hm:has(x, y - 1) and hm:has(x, y + 1) then
    keep(x, y, c:get(x, y) == MET.shade and MET.deep or MET.shade)
  end
end end
c:part(c:rrect(25, 32, 54, 36, 2), MET, { band = 1, sep = true, pop = { 27, 33 } })
c:part(c:line({ { 47, 29 }, { 67, 8 } }, 2), NEED, { noshade = true, pop = { 60, 15 } })
keep(66, 9, NEED.deep)
c:finish{ outline = true }
for _, q in ipairs{ { 69, 7 }, { 70, 8 }, { 71, 9 }, { 72, 11 }, { 72, 12 }, { 72, 13 }, { 71, 15 }, { 71, 16 }, { 72, 18 }, { 73, 19 } } do
  if not c:get(q[1], q[2]) then c:put(q[1], q[2], P.petal.base, "fx") end
end
backdrop(P.moss)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
