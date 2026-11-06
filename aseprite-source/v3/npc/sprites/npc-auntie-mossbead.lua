-- npc-auntie-mossbead sprite (npc2 P1_0) species: tortoise
-- Auntie Mossbead: elder tortoise, olive speckled skin, domed shell with moss tufts on the rim, horn beak,
-- violet headwrap with gold dots and a moss sprig on the knot, bead necklace. Prop: teal woven basket of red berries.
-- Idle 4f: base / breath (1px lower, wrap knot lags) / base / slow blink. Feet + shadow fixed.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-auntie-mossbead"
local SKIN = { hi = "#cfdc8e", base = "#94ae5e", shade = "#5f7f5c", deep = "#36504e" }
local PLAS = { hi = "#fff0b0", base = "#ecd27a", shade = "#bf9a5a", deep = "#7a5a44" }
local HORN = { hi = "#f6e6b4", base = "#d9b56e", shade = "#a07a54", deep = "#5e4440" }
local SHELL, WRAP, BASK = P.wood, P.dusk, P.sea
local function D(c, x, y, hex) c:put(x, y, hex, c.own[y * c.w + x] or "d") end
local function eye(c, x, y, blink)
  if blink then for i = 0, 3 do D(c, x + i, y + 2, P.ink) end D(c, x, y + 1, SKIN.shade) return end
  D(c, x + 1, y, P.ink) D(c, x + 2, y, P.ink)
  for _, q in ipairs{ {0,1},{3,1},{0,2},{3,2},{1,3},{2,3},{1,1} } do D(c, x + q[1], y + q[2], P.cream) end
  D(c, x + 2, y + 1, P.ink) D(c, x + 1, y + 2, P.ink) D(c, x + 2, y + 2, P.ink)
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.b or 0
  c:groundShadow(32, 89, 15, 2.5)
  for _, x in ipairs{ 25, 39 } do
    c:part(c:ellipse(x, 86.5, 4, 3), SKIN, { nopop = true })
    for _, dx in ipairs{ -2, 0, 2 } do D(c, x + dx, 89, HORN.base) end
  end
  -- domed shell behind, scute seams, moss on the rim
  local sh = c:ellipse(32, 69 + b, 18, 15)
  c:part(sh, SHELL, { band = 2 })
  for y = 58, 78 do for _, x in ipairs{ 18, 46 } do if sh:has(x, y + b) then D(c, x, y + b, SHELL.deep) end end end
  for _, q in ipairs{ {15,62},{17,73},{47,62},{47,73} } do D(c, q[1], q[2] + b, SHELL.deep) D(c, q[1] + 1, q[2] + b, SHELL.deep) end
  local mo = HP.mask()
  for _, q in ipairs{ {15,64},{18,57},{24,54.5},{40,54.5},{46,57},{49,64} } do mo:add(HP.ellipse(q[1], q[2] + b, 2.5, 2.2)) end
  c:part(mo, P.moss, { band = 1 })
  -- neck
  c:part(c:rect(27, 55 + b, 37, 64 + b), SKIN, { nopop = true })
  -- plastron belly
  local bd = c:ellipse(32, 75 + b, 12, 10.5)
  c:part(bd, PLAS, { band = 2 })
  bd:each(function(x, y) if (y == 71 + b or y == 77 + b or x == 32) and c:get(x, y) ~= P.ink then D(c, x, y, PLAS.shade) end end)
  -- arms
  c:part(c:ellipse(19, 69 + b, 3, 4.5), SKIN, { nopop = true })
  c:part(c:ellipse(45, 69 + b, 3, 4.5), SKIN, { nopop = true })
  -- bead necklace
  for i = 0, 5 do
    local x = 22 + i * 4
    local y = 62 + b + math.floor(2 * math.sin(math.pi * i / 5) + .5)
    c:part(c:ellipse(x, y, 1.6, 1.6), (i % 2 == 0) and P.ember or P.gold, { nopop = true })
    D(c, x - 1, y - 1, P.cream)
  end
  -- basket of berries (prop)
  for _, q in ipairs{ {28,73},{31,72},{34,73},{37,73},{30,74.5},{35,74.5} } do
    c:part(c:ellipse(q[1], q[2] + b, 1.5, 1.5), P.ember, { nopop = true })
    D(c, math.floor(q[1]) - 1, math.floor(q[2]) + b - 1, P.ember.hi)
  end
  local bowl = c:ellipse(32, 76 + b, 9.5, 5.5):clip(c:rect(0, 75 + b, 63, 95))
  c:part(bowl, BASK, { band = 1, nopop = true })
  bowl:each(function(x, y) if y > 75 + b and (x + y * 2) % 4 == 0 and c:get(x, y) == BASK.base then D(c, x, y, BASK.shade) end end)
  for x = 23, 41 do if bowl:has(x, 75 + b) and x % 2 == 0 then D(c, x, 75 + b, BASK.hi) end end
  c:part(c:ellipse(23, 75 + b, 2, 1.5), SKIN, { nopop = true })
  c:part(c:ellipse(41, 75 + b, 2, 1.5), SKIN, { nopop = true })
  -- head
  local head = c:ellipse(32, 47 + b, 12, 9)
  c:part(head, SKIN, { band = 2, pop = { 23, 45 + b } })
  for _, q in ipairs{ {25,50},{27,52},{38,52},{41,49},{22,47},{36,54} } do if c:get(q[1], q[2] + b) == SKIN.base then D(c, q[1], q[2] + b, SKIN.hi) end end
  for _, q in ipairs{ {24,51},{25,52},{26,52},{27,53},{28,53},{40,51},{39,52},{38,52},{37,53},{36,53} } do D(c, q[1], q[2] + b, SKIN.deep) end
  c:part(c:poly{ {29,51+b},{35,51+b},{34,54+b},{32,56+b},{30,54+b} }, HORN, { band = 1, pop = { 30, 51 + b } })
  D(c, 31, 52 + b, HORN.deep) D(c, 33, 52 + b, HORN.deep)
  eye(c, 24, 44 + b, p.blink) eye(c, 37, 44 + b, p.blink)
  if not p.blink then for x = 24, 27 do D(c, x, 43 + b, SKIN.shade) end for x = 37, 40 do D(c, x, 43 + b, SKIN.shade) end end
  -- headwrap + knot + moss sprig
  local kn = p.kn or 0
  local wr = c:ellipse(32, 39 + b, 13, 5.5)
  local knot = c:ellipse(39, 32 + b + kn, 5, 4.5)
  local all = wr:copy():add(knot)
  c:part(all, WRAP, { band = 2, pop = { 23, 36 + b } })
  for x = 19, 45 do local ly
    for y = 30 + b, 46 + b do if wr:has(x, y) then ly = y end end
    if ly and c:get(x, ly) ~= P.ink then D(c, x, ly, x > 38 and P.gold.shade or P.gold.base) end
  end
  all:each(function(x, y) local v = c:get(x, y) if (x * 3 + y * 5) % 9 == 0 and (v == WRAP.base or v == WRAP.hi) then D(c, x, y, P.gold.hi) end end)
  for _, q in ipairs{ {35,36},{36,37},{37,38},{33,35} } do D(c, q[1], q[2] + b, WRAP.deep) end
  for _, q in ipairs{ {39,27,P.moss.base},{40,26,P.moss.hi},{38,26,P.moss.shade},{41,25,P.moss.base},{37,25,P.moss.base} } do D(c, q[1], q[2] + b + kn, q[3]) end
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { b = 0 }, { b = 1, kn = -1 }, { b = 0 }, { b = 0, blink = true } } do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
