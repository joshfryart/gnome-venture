-- npc-tobias-trundle sprite (npc2 P1_36) species: tortoise
-- Old trundling tortoise: domed brown shell, cream plastron, mustard knit scarf, droopy grey whisker
-- moustache, heavy lids. Prop: hooked walking cane. 64x96, feet y=90, idle(4): breath, settle, blink.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-tobias-trundle"
local SKIN  = { hi = "#c4e07a", base = "#8fbf5c", shade = "#4f8a5a", deep = "#2c4d4c" }
local SNOUT = { hi = "#e6f2a8", base = "#c4e07a", shade = "#8fbf5c", deep = "#4f8a5a" }
local SHELL = { hi = "#d9a066", base = "#a86a3e", shade = "#74463a", deep = "#46293a" }
local PLAS  = { hi = "#fff0b8", base = "#ecc87a", shade = "#c0915c", deep = "#7a5040" }
local WHISK = { hi = P.cream, base = P.stone.hi, shade = P.stone.base, deep = P.stone.shade }
local SCARF, CANE = P.gold, P.wood
local function keep(c, x, y, hex) if x >= 0 and y >= 0 and x < c.w and y < c.h then local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.bob or 0
  c:groundShadow(32, 89.5, 16, 3)
  for _, fx in ipairs{ 25, 39 } do                                   -- elephant feet, fixed
    c:part(c:ellipse(fx, 87.5, 4.5, 2.5), SKIN, { band = 1, nopop = true })
    for i = -2, 2, 2 do keep(c, fx + i, 89, P.stone.hi) end
  end
  -- domed shell behind the body, marginal scutes on the rim
  local scy = 66 + b
  local shell = c:ellipse(32, scy, 18, 16)
  c:part(shell, SHELL, { band = 2, nopop = true })
  local inner = shell:shrink(3)
  shell:each(function(x, y) if not inner:has(x, y) then
    local a = math.deg(math.atan(y + .5 - scy, x + .5 - 32)) % 360
    if a % 20 < 2.5 then keep(c, x, y, SHELL.deep)
    elseif c:get(x, y) == SHELL.base and a > 150 and a < 270 then keep(c, x, y, SHELL.hi) end
  end end)
  -- cane (prop)
  local cane = c:line({ { 15, 89 }, { 16, 72 }, { 16, 60 + b } }, 2)
  cane:add(c:line({ { 16, 60 + b }, { 17, 57 + b }, { 20, 56 + b }, { 22, 58 + b }, { 22, 60 + b } }, 2))
  c:part(cane, CANE, { band = 1, inner = false })
  keep(c, 15, 78, CANE.shade) keep(c, 16, 70, CANE.shade)
  -- plastron belly with seams
  local body = c:ellipse(32, 71 + b, 12, 13)
  c:part(body, PLAS, { band = 2 })
  for _, yy in ipairs{ 66, 72, 78 } do local y = yy + b
    for x = 20, 44 do if body:has(x, y - 1) and body:has(x, y + 1) and body:has(x - 1, y) and body:has(x + 1, y) then keep(c, x, y, PLAS.shade) end end end
  for y = 59 + b, 83 + b do if body:has(32, y + 1) and body:has(32, y - 1) then keep(c, 32, y, PLAS.shade) end end
  -- arms: right rests on belly, left grips the cane
  c:part(c:ellipse(46, 69 + b, 3, 4.5), SKIN, { band = 1 })
  c:part(c:ellipse(19, 63 + b, 3, 3.5), SKIN, { band = 1 })
  keep(c, 21, 65 + b, SKIN.deep) keep(c, 20, 66 + b, SKIN.deep)
  -- knit scarf + tail
  local sc = c:rrect(19, 49 + b, 45, 54 + b, 2)
  c:part(sc, SCARF, { band = 1 })
  for x = 21, 43, 3 do keep(c, x, 51 + b, SCARF.shade) keep(c, x, 52 + b, SCARF.shade) end
  local tl = p.tail or 0
  c:part(c:poly{ { 37, 53 + b }, { 42, 53 + b }, { 43, 63 + b + tl }, { 38, 63 + b + tl } }, SCARF, { band = 1, sep = true })
  for x = 38, 43, 2 do keep(c, x, 63 + b + tl, SCARF.shade) end
  -- big head, crown scales
  local hy = 32 + b
  local head = c:ellipse(32, hy, 16, 16)
  c:part(head, SKIN, { band = 2, pop = { x = 22, y = hy - 8 } })
  for _, s in ipairs{ { 26, hy - 11 }, { 32, hy - 13 }, { 38, hy - 11 }, { 23, hy - 6 }, { 29, hy - 7 }, { 35, hy - 7 }, { 41, hy - 6 } } do
    c:ellipse(s[1], s[2], 3, 2):edge():each(function(x, y) if head:shrink(1):has(x, y) then keep(c, x, y, SKIN.shade) end end)
  end
  -- snout + nostrils, hooked beak
  c:part(c:ellipse(32, hy + 7, 6, 3.5), SNOUT, { band = 1, nopop = true })
  c:put(30, hy + 5, P.ink) c:put(33, hy + 5, P.ink)
  c:fillMask(c:line({ { 25, hy + 9 }, { 29, hy + 10 }, { 31, hy + 12 }, { 32, hy + 12 }, { 34, hy + 10 }, { 38, hy + 9 } }, 1), P.ink)
  -- eyes with heavy lids
  local ey = hy - 2
  for _, ex in ipairs{ 23, 36 } do
    if p.blink then
      for i = 0, 4 do c:put(ex + i, ey + 1, SKIN.shade) c:put(ex + i, ey + 2, P.ink) end
    else c:eyeLocked(ex, ey) end
    for i = 0, 4 do c:put(ex + i, ey - 1, SKIN.deep) end
  end
  c:cheek(19, hy + 4) c:cheek(43, hy + 4)
  -- droopy whisker moustache
  local mu = p.mu or 0
  local m = c:ellipse(27.5, hy + 12, 3.5, 1.5)
  m:add(c:ellipse(36.5, hy + 12, 3.5, 1.5))
  m:add(c:ellipse(24, hy + 14 + mu, 1.5, 2)) m:add(c:ellipse(40, hy + 14 + mu, 1.5, 2))
  c:part(m, WHISK, { band = 1, pop = { x = 25, y = hy + 11 } })
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { bob = 0 }, { bob = 1, mu = 1, tail = 1 }, { bob = 0 }, { bob = 0, blink = true } } do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
