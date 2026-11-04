-- npc-pomeroy-crumbworth sprite (npc2 P1_30) species: field mouse
-- Rotund old field mouse gent: big round ears, mustard frock coat, cream cravat, pink curling tail.
-- prop: silver pocket watch on a chain (swings on frame 4). 64x96 cell, feet y=90, idle x4.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-pomeroy-crumbworth"
local FUR = P.wood
local CR = { hi = P.cream, base = "#f3e2bf", shade = "#d9b99a", deep = "#9a6f63" }
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, ed, tw, ws = p.b or 0, p.ed or 0, p.tw or 0, p.ws or 0
  c:groundShadow(32, 89, 15, 3)
  c:part(c:line({ {41,85},{47,86},{52,83},{54,78},{53+tw,74},{50+tw,73} }, 2), "petal", { band = 1, nopop = true })
  c:part(c:ellipse(27, 88.5, 3.5, 1.5), "petal", { band = 1 })
  c:part(c:ellipse(37, 88.5, 3.5, 1.5), "petal", { band = 1 })
  local coat = c:ellipse(32, 75 + b, 12, 11)
  coat:cut(c:poly{ {31,82+b},{33,82+b},{35,88+b},{29,88+b} })
  c:part(coat, "gold", { band = 2 })
  for y = 76, 85 do if coat:has(32 + (y - 76) // 4, y + b) then end end
  c:fillMask(c:line({ {28,67+b},{31,80+b} }, 1):clip(coat), P.gold.shade)
  c:fillMask(c:line({ {36,67+b},{33,80+b} }, 1):clip(coat), P.gold.shade)
  c:part(c:poly{ {25,64+b},{39,64+b},{32,73+b} }, CR, { band = 1 })
  c:put(30, 76 + b, P.wood.deep) c:put(30, 79 + b, P.wood.deep)
  -- watch chain + silver watch
  c:fillMask(c:line({ {33,73+b},{36,75+b},{38+ws,77+b} }, 1), P.stone.hi)
  local w = c:ellipse(39 + ws, 79 + b, 2, 2)
  c:part(w, "stone", { band = 1, nopop = true })
  c:put(39 + ws, 79 + b, P.cream) c:put(38 + ws, 78 + b, P.cream)
  -- sleeves + paws
  for _, s in ipairs{ {20,-1}, {44,1} } do
    c:part(c:ellipse(s[1], 73 + b, 3, 5), "gold", { band = 1, nopop = true })
    c:part(c:ellipse(s[1], 79 + b, 2, 1.5), "petal", { band = 1, nopop = true })
  end
  -- ears (behind head)
  for _, x in ipairs{ 19, 45 } do
    c:part(c:ellipse(x, 39 + ed, 6.5, 6), FUR, { band = 1 })
    c:part(c:ellipse(x + (x < 32 and 0 or 0), 40 + ed, 4, 3.5), "petal", { band = 1, nopop = true })
  end
  -- head
  c:part(c:ellipse(32, 51 + b, 15, 11.5), FUR, { band = 2, pop = { x = 24, y = 43 + b } })
  c:part(c:poly{ {28,42+b},{30,37+b},{32,40+b},{34,36+b},{36,42+b} }, FUR, { band = 1, inner = false, nopop = true })
  c:part(c:ellipse(32, 57 + b, 7, 4), CR, { band = 1 })
  c:part(c:ellipse(32, 53 + b, 1.5, 1), "petal", { band = 1, nopop = true })
  c:put(31, 52 + b, P.petal.hi)
  for _, q in ipairs{ {30,57},{31,58},{32,57},{33,58},{34,57} } do c:put(q[1], q[2] + b, CR.deep) end
  for _, l in ipairs{ { {24,56},{19,55} }, { {24,58},{19,59} }, { {40,56},{45,55} }, { {40,58},{45,59} } } do
    c:fillMask(c:line({ {l[1][1], l[1][2] + b}, {l[2][1], l[2][2] + b} }, 1), P.wood.deep)
  end
  if p.blink then
    for _, x in ipairs{ 25, 37 } do c:put(x, 50 + b, P.ink) c:put(x + 1, 50 + b, P.ink) end
  else c:eyeSmall(25, 48 + b) c:eyeSmall(37, 48 + b) end
  c:cheek(22, 53 + b) c:cheek(41, 53 + b)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local F = { frame{}, frame{ b = 1, ed = 2, tw = -1 }, frame{}, frame{ blink = true, ws = 1, tw = 1 } }
HP.sheet{ cellw = 64, cellh = 96, frames = F, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite" }
print(NAME .. " ok")
