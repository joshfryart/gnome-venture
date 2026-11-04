-- npc-pebble-barkley sprite (npc2 P1_28) species: tortoise
-- Elder tortoise in a red button coat, bark-grained carapace wider than his body, bushy cream brows,
-- horn beak. Prop: crooked walking stick with a sprouting leaf (leaf settles / twitches). 4-frame idle.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-pebble-barkley"
local SKIN = { hi = "#d4e08e", base = "#97b85e", shade = "#5f8456", deep = "#344a4a" }
local BARK = { hi = "#c7956a", base = "#94603f", shade = "#64413f", deep = "#3e2836" }
local CREAM = { hi = P.cream, base = "#f3e2b8", shade = "#d4b98e", deep = "#9a7a5e" }
local HORN = { hi = "#efe0b0", base = "#c9b27e", shade = "#97805e", deep = "#5e4a42" }
local COAT = P.ember
local function keep(c, x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, lx, ld = p.bob or 0, p.leafx or 0, p.leaf or 0
  c:groundShadow(32, 89.5, 15, 3)
  -- carapace behind: marginal scute ring + radial seams + bark grain
  local sh = c:ellipse(32, 66 + b, 17.5, 15)
  c:part(sh, BARK, { band = 2, pop = { 19, 60 + b } })
  local rim = c:ellipse(32, 67 + b, 13.5, 11.5)
  rim:edge():each(function(x, y) if sh:has(x, y) then keep(c, x, y, BARK.deep) end end)
  for a = 0, 345, 30 do
    local r = math.rad(a + 15)
    c:line({ { 32 + math.cos(r) * 14, 67 + b + math.sin(r) * 12 }, { 32 + math.cos(r) * 18, 66 + b + math.sin(r) * 15.5 } }, 1)
      :clip(sh):each(function(x, y) keep(c, x, y, BARK.deep) end)
  end
  sh:each(function(x, y) if not rim:has(x, y) and (x * 7 + y * 3) % 11 == 0 and c:get(x, y) == BARK.base then keep(c, x, y, BARK.shade) end end)
  -- stumpy elephant feet with horn toenails
  for _, fx in ipairs{ 25.5, 38.5 } do
    c:part(c:ellipse(fx, 87.5, 4.5, 2.5), SKIN, { band = 1 })
    for i = -2, 2, 2 do keep(c, math.floor(fx) + i, 90, HORN.hi) end
  end
  -- red coat, centre seam, brass buttons
  local coat = c:ellipse(32, 72 + b, 11, 11.5)
  coat:add(c:poly{ { 22, 74 + b }, { 42, 74 + b }, { 43, 84 + b }, { 21, 84 + b } })
  c:part(coat, COAT, { band = 2 })
  for y = 64 + b, 84 + b do keep(c, 32, y, COAT.shade) end
  for _, y in ipairs{ 67, 73, 79 } do keep(c, 34, y + b, P.gold.hi) keep(c, 35, y + b, P.gold.shade) end
  -- sleeves + hands
  c:part(c:ellipse(20.5, 69 + b, 3, 4.5), COAT, { band = 1, sep = true })
  c:part(c:ellipse(43.5, 69 + b, 3, 4.5), COAT, { band = 1, sep = true })
  c:part(c:ellipse(20.5, 74 + b, 2.5, 2), SKIN, { band = 1 })
  -- wrinkled neck + gold collar band
  c:part(c:rrect(27, 52 + b, 37, 61 + b, 2), SKIN, { band = 1 })
  for x = 28, 36, 2 do keep(c, x, 57 + b, SKIN.shade) end
  c:part(c:rrect(24, 59 + b, 40, 61 + b, 1), P.gold, { band = 1 })
  -- big round head with crown scutes
  local hd = c:ellipse(32, 43 + b, 14, 11.5)
  c:part(hd, SKIN, { band = 2, pop = { 22, 36 + b } })
  for _, s in ipairs{ { { 27, 32 }, { 37, 32 }, { 39, 36 }, { 32, 38 }, { 25, 36 } },
                      { { 19, 39 }, { 25, 36.5 }, { 27, 39 }, { 21, 42 } },
                      { { 45, 39 }, { 39, 36.5 }, { 37, 39 }, { 43, 42 } } } do
    local q = {} for i, v in ipairs(s) do q[i] = { v[1], v[2] + b } end
    c:poly(q):edge():clip(hd):each(function(x, y) keep(c, x, y, SKIN.shade) end)
  end
  -- muzzle, horn beak + nostrils, smile
  c:part(c:ellipse(32, 49 + b, 7, 3.5), CREAM, { band = 1, nopop = true })
  for x = 30, 34 do keep(c, x, 46 + b, HORN.base) end
  for x = 31, 33 do keep(c, x, 47 + b, HORN.shade) end
  keep(c, 32, 48 + b, HORN.deep) keep(c, 30, 46 + b, HORN.hi)
  keep(c, 31, 46 + b, P.ink) keep(c, 33, 46 + b, P.ink)
  for _, q in ipairs{ { 28, 50 }, { 29, 51 }, { 30, 51 }, { 31, 51 }, { 32, 51 }, { 33, 51 }, { 34, 51 }, { 35, 51 }, { 36, 50 } } do keep(c, q[1], q[2] + b, P.ink) end
  -- eyes (blink on f4) + bushy cream elder brows
  if p.blink then
    for _, x in ipairs{ 24, 35 } do for i = 0, 4 do keep(c, x + i, 42 + b, P.ink) end end
  else c:eyeLocked(24, 39 + b) c:eyeLocked(35, 39 + b) end
  for _, q in ipairs{ { 23, 38 }, { 24, 37 }, { 25, 37 }, { 26, 37 }, { 27, 38 }, { 36, 38 }, { 37, 37 }, { 38, 37 }, { 39, 37 }, { 40, 38 } } do keep(c, q[1], q[2] + b, P.cream) end
  keep(c, 22, 38 + b, CREAM.shade) keep(c, 41, 38 + b, CREAM.shade)
  c:cheek(21, 46 + b) c:cheek(42, 46 + b)
  -- walking stick (planted, never moves) + sprouting leaf + gripping hand
  c:part(c:line({ { 48, 62 }, { 47, 70 }, { 48, 79 }, { 47, 89 } }, 2), P.wood, { band = 1, nopop = true })
  c:part(c:ellipse(48, 61, 2, 1.5), P.wood, { band = 1 })
  c:part(c:poly{ { 49 + lx, 60 + ld }, { 53 + lx, 55 + ld }, { 57 + lx, 55 + ld }, { 54 + lx, 59 + ld } }, P.moss, { band = 1, pop = { 52 + lx, 57 + ld } })
  c:part(c:poly{ { 47, 60 }, { 44, 57 + ld }, { 43, 59 + ld }, { 46, 61 } }, P.moss, { band = 1, nopop = true, sep = true })
  c:part(c:ellipse(46.5, 73 + b, 2.5, 2), SKIN, { band = 1 })
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local frames = {}
for _, p in ipairs{ { bob = 0 }, { bob = 1, leaf = 1 }, { bob = 0 }, { bob = 0, blink = true, leafx = 1 } } do frames[#frames + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
s:save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
print(NAME .. " ok")
