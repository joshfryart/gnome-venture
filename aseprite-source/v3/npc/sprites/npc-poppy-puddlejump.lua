-- npc-poppy-puddlejump sprite (npc2 P1_30) species: hare-eared rabbit
-- Bouncy tan rabbit: one tall ear, one flopped tip (quirk), orange jumper, green scarf.
-- prop: moss wreath with a red poppy. 64x96 cell, feet y=90, idle x4 (ear twitch on frame 4).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-poppy-puddlejump"
local FUR = { hi = "#f6d6a0", base = "#dca86c", shade = "#b0743f", deep = "#6a3e2e" }
local JMP = { hi = "#ffb47a", base = "#f0823e", shade = "#c4513a", deep = "#6e2038" }
local CR = { hi = P.cream, base = "#f3e2bf", shade = "#d9b99a", deep = "#9a6f63" }
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, ed, et, sc = p.b or 0, p.ed or 0, p.et or 0, p.sc or 0
  c:groundShadow(32, 89, 13, 3)
  c:part(c:ellipse(27, 88.5, 4, 1.5), FUR, { band = 1 })
  c:part(c:ellipse(38, 88.5, 4, 1.5), FUR, { band = 1 })
  c:put(25, 89, FUR.deep) c:put(36, 89, FUR.deep)
  local body = c:ellipse(32, 77 + b, 11, 9)
  c:part(body, JMP, { band = 2 })
  for x = 22, 42, 2 do if body:has(x, 84 + b) then c:put(x, 84 + b, JMP.shade) end end
  for _, s in ipairs{ 21, 43 } do
    c:part(c:ellipse(s, 75 + b, 3, 4.5), JMP, { band = 1, nopop = true })
    c:part(c:ellipse(s, 80 + b, 2, 1.5), FUR, { band = 1, nopop = true })
  end
  -- scarf + hanging tail
  c:part(c:rrect(21, 64 + b, 43, 68 + b, 2), "moss", { band = 1 })
  c:part(c:line({ {38,67+b},{39,72+b},{40+sc,77+b} }, 3), "moss", { band = 1, nopop = true })
  c:put(39 + sc, 79 + b, P.moss.deep) c:put(41 + sc, 79 + b, P.moss.deep)
  -- ears (behind head): left tall, right flopped
  local le = c:poly{ {22,44+ed},{30,44+ed},{30+et,20+ed},{22+et,20+ed} }
  le:add(c:ellipse(26 + et, 19 + ed, 4, 5))
  c:part(le, FUR, { band = 1 })
  c:part(c:line({ {26+et,18+ed},{26,38+ed} }, 2), "petal", { band = 1, nopop = true, inner = false })
  local re = c:poly{ {34,44+ed},{42,44+ed},{42,28+ed},{34,28+ed} }
  re:add(c:ellipse(38, 28 + ed, 4, 3))
  re:add(c:line({ {39,27+ed},{44,25+ed},{48,28+ed} }, 4))
  c:part(re, FUR, { band = 1 })
  c:part(c:line({ {38,30+ed},{38,39+ed} }, 2), "petal", { band = 1, nopop = true, inner = false })
  -- head + cheek fluff
  local h = c:ellipse(32, 53 + b, 13, 11)
  h:add(c:ellipse(19, 57 + b, 2, 2)) h:add(c:ellipse(45, 57 + b, 2, 2))
  c:part(h, FUR, { band = 2, pop = { x = 24, y = 45 + b } })
  -- wreath + poppy
  c:part(c:line({ {20,48+b},{25,44+b},{32,42+b},{39,44+b},{44,48+b} }, 2), "moss", { band = 1, inner = false, nopop = true })
  for _, q in ipairs{ {22,46},{28,43},{35,43} } do c:put(q[1], q[2] + b, P.moss.hi) end
  local pop = c:ellipse(40, 44 + b, 2.5, 2.5)
  for _, q in ipairs{ {40,41},{43,44},{40,47},{37,44} } do pop:set(q[1], q[2] + b) end
  c:part(pop, "ember", { band = 1, pop = { x = 38, y = 43 + b } })
  c:put(40, 44 + b, P.ink) c:put(41, 45 + b, P.ember.deep)
  -- face
  c:part(c:ellipse(32, 59 + b, 6, 3.5), CR, { band = 1 })
  c:paint({ "hPP", ".P." }, 31, 55 + b, { P = "petal.base", h = "petal.hi" })
  c:put(32, 57 + b, CR.deep) c:put(31, 58 + b, CR.deep) c:put(33, 58 + b, CR.deep)
  c:put(32, 60 + b, P.cream) c:put(32, 61 + b, CR.shade)
  if p.blink then
    for _, x in ipairs{ 25, 38 } do c:put(x, 52 + b, P.ink) c:put(x + 1, 52 + b, P.ink) end
  else c:eyeSmall(25, 50 + b) c:eyeSmall(38, 50 + b) end
  c:cheek(22, 56 + b) c:cheek(41, 56 + b)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local F = { frame{}, frame{ b = 1, ed = 1, sc = -1 }, frame{}, frame{ et = -1, sc = 1 } }
HP.sheet{ cellw = 64, cellh = 96, frames = F, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite" }
print(NAME .. " ok")
