-- npc-wren-thimblewick sprite (npc2 P1_39) species: wren (songbird)
-- Grumpy seamstress wren: round barred body, cocked-up tail, cream brow stripes, pink knit scarf.
-- Prop/quirk: a silver thimble worn as a hat with a needle stuck through it trailing pink thread.
-- 64x96 cell, 3/4 top-down, feet baseline y=90, x=32. idle x4: base, breath(-1px, thread sways, tail settles), base, blink + tail twitch.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-wren-thimblewick"
local BR = { hi = "#d9a26a", base = "#a8693f", shade = "#74464a", deep = "#462838" }
local CR = { hi = P.cream, base = "#f2ddb6", shade = "#c8a9a6", deep = "#86697e" }
local MET = { hi = "#f4efe2", base = "#b9b6c4", shade = "#7d7b96", deep = "#4a4866" }
local NEED = { hi = "#f4efe2", base = "#c9c8d6", shade = "#8a89a6", deep = "#55536f" }
local LEG = { hi = "#e0a46a", base = "#c27a46", shade = "#8a4d43", deep = "#53303a" }

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local function keep(x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
  local function eye(x, y)
    for j = 0, 4 do for i = 0, 4 do if not ((i == 0 or i == 4) and (j == 0 or j == 4)) then keep(x + i, y + j, P.cream) end end end
    for j = 1, 3 do for i = 1, 3 do keep(x + i, y + j, P.ink) end end
    keep(x + 1, y + 1, P.cream)
  end
  local b = p.b or 0
  c:groundShadow(32, 89.5, 12, 2.5)
  -- thin legs + three-toed feet (fixed)
  for _, lx in ipairs{ 27, 36 } do
    c:part(c:rect(lx, 83, lx + 1, 88), LEG, { noshade = true, nopop = true })
    c:part(c:rect(lx - 2, 89, lx + 3, 90), LEG, { band = 1, nopop = true })
    keep(lx - 1, 90, LEG.deep) keep(lx + 2, 90, LEG.deep)
  end
  -- cocked tail behind the body, barred
  local tx, ty = p.tx or 0, b + (p.tt or 0)
  local tail = c:poly{ { 39, 70 + b }, { 45, 72 + b }, { 55 + tx, 49 + ty }, { 50 + tx, 46 + ty } }
  c:part(tail, BR, { band = 1 })
  tail:each(function(x, y) if (y - ty) % 3 == 0 and y < 67 + b then keep(x, y, BR.shade) end end)
  -- round body + cream breast + flank barring
  local body = c:ellipse(32, 72 + b, 13, 12)
  c:part(body, BR, { band = 2, pop = { 23, 64 + b } })
  local belly = c:ellipse(30.5, 75 + b, 8, 8):clip(body)
  c:part(belly, CR, { band = 1, inner = false, pop = { 26, 70 + b } })
  for _, q in ipairs{ { 40, 74 }, { 41, 74 }, { 40, 77 }, { 41, 77 }, { 39, 80 }, { 40, 80 } } do keep(q[1], q[2] + b, BR.shade) end
  -- stub wings with bars
  for _, w in ipairs{ { 19.5, -1 }, { 44.5, 1 } } do
    local m = c:ellipse(w[1], 71 + b, 3.5, 6.5)
    c:part(m, BR, { band = 1, nopop = w[2] > 0 })
    m:each(function(x, y) if (y - b) % 3 == 0 and y > 67 + b and y < 77 + b then keep(x, y, BR.deep) end end)
  end
  -- pink knit scarf + hanging end
  local sc = c:rrect(21, 60 + b, 43, 64 + b, 2)
  c:part(sc, P.petal, { band = 1, pop = { 23, 61 + b } })
  sc:each(function(x, y) if x % 2 == 0 and y == 63 + b then keep(x, y, P.petal.shade) end end)
  c:part(c:poly{ { 23, 62 + b }, { 28, 62 + b }, { 27, 71 + b }, { 22, 70 + b } }, P.petal, { band = 1, nopop = true, sep = true })
  keep(23, 70 + b, P.petal.deep) keep(25, 71 + b, P.petal.deep)
  -- big round head, cream face patch
  local head = c:ellipse(32, 50 + b, 14, 11.5)
  c:part(head, BR, { band = 2, pop = { 22, 46 + b } })
  local face = c:ellipse(32, 57 + b, 8.5, 5):clip(head)
  c:part(face, CR, { band = 1, inner = false, nopop = true })
  -- pale brow stripes, then grumpy ink brows sloping to the middle
  for _, s in ipairs{ { 20, 45, 26, 46 }, { 38, 46, 44, 45 } } do
    c:line({ { s[1], s[2] + b }, { s[3], s[4] + b } }, 1):each(function(x, y) keep(x, y, CR.base) end)
  end
  for _, s in ipairs{ { 22, 47, 27, 48 }, { 37, 48, 42, 47 } } do
    c:line({ { s[1], s[2] + b }, { s[3], s[4] + b } }, 1):each(function(x, y) keep(x, y, P.ink) end)
  end
  if p.blink then
    for i = 0, 4 do keep(23 + i, 51 + b, P.ink) keep(37 + i, 51 + b, P.ink) end
  else eye(23, 49 + b) eye(37, 49 + b) end
  -- short pointed beak + downturned corners
  c:part(c:poly{ { 29.5, 54 + b }, { 34.5, 54 + b }, { 32, 58 + b } }, P.gold, { band = 1, pop = { 30, 54 + b } })
  keep(29, 56 + b, P.ink) keep(28, 57 + b, P.ink) keep(35, 56 + b, P.ink) keep(36, 57 + b, P.ink)
  keep(21, 53 + b, P.petal.base) keep(42, 53 + b, P.petal.base)
  -- thimble hat (quirk), dimpled, rolled rim
  local h = b + (p.hb or 0)
  local hm = c:poly{ { 24, 41 + h }, { 40, 41 + h }, { 39, 30 + h }, { 26, 30 + h } }
  hm:add(c:ellipse(32.5, 30 + h, 6.5, 2.5))
  c:part(hm, MET, { band = 2, pop = { 27, 31 + h } })
  for y = 32 + h, 38 + h, 2 do
    for x = 26 + ((y - h) % 4 == 0 and 1 or 0), 38, 2 do
      if hm:has(x - 1, y) and hm:has(x + 1, y) and hm:has(x, y - 1) and hm:has(x, y + 1) then
        keep(x, y, c:get(x, y) == MET.shade and MET.deep or MET.shade)
      end
    end
  end
  c:part(c:rrect(22, 40 + h, 42, 43 + h, 1), MET, { band = 1, sep = true, pop = { 24, 41 + h } })
  c:part(c:line({ { 38, 37 + h }, { 49, 26 + h } }, 1), NEED, { noshade = true, nopop = true })
  keep(49, 26 + h, NEED.deep)
  c:finish{ outline = true }
  -- trailing pink thread (after outline: a fine 1px line)
  local th = p.th or 0
  for _, q in ipairs{ { 50, 25 }, { 51, 25 }, { 52, 26 }, { 53, 27 }, { 53 + th, 28 }, { 53 + th, 29 }, { 52 + th, 30 }, { 52 + th, 31 } } do
    if not c:get(q[1], q[2] + h) then c:put(q[1], q[2] + h, P.petal.base, "fx") end
  end
  HP.assertClean(c)
  return c
end

local frames = {}
for _, p in ipairs{ { b = 0 }, { b = 1, tt = 1, th = 1 }, { b = 0 }, { b = 0, blink = true, tx = 1 } } do frames[#frames + 1] = frame(p) end
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
